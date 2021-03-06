
define [
  "CloudResources"
  "Design"
  "UI.modalplus"
  "../template/TplLeftPanel"
  "constant"
  'dhcp_manage'
  'snapshotManager'
  'rds_snapshot'
  'sslcert_manage'
  'sns_manage'
  'kp_manage'
  'rds_pg'
  'rds_snapshot'
  'eip_manager'
  './AmiBrowser'
  'i18n!/nls/lang.js'
  'ApiRequest'
  'OpsModel'
  "backbone"
  "UI.dnd"
], ( CloudResources, Design, Modal, LeftPanelTpl, constant, dhcpManager, EbsSnapshotManager, RdsSnapshotManager, sslCertManager, snsManager, keypairManager,rdsPgManager, rdsSnapshot, eipManager, AmiBrowser, lang, ApiRequest, OpsModel )->

  # Update Left Panel when window size changes
  __resizeAccdTO = null
  $( window ).on "resize", ()->
    if __resizeAccdTO then clearTimeout(__resizeAccdTO)
    __resizeAccdTO = setTimeout ()->
      $("#OpsEditor").filter(":visible").children(".OEPanelLeft").trigger("RECALC")
    , 150
    return


  MC.template.resPanelAmiInfo = ( data )->
    if not data.region or not data.imageId then return

    ami = CloudResources( Design.instance().credentialId(), constant.RESTYPE.AMI, data.region ).get( data.imageId )
    if not ami then return

    ami = ami.toJSON()
    ami.imageSize = ami.imageSize || ami.blockDeviceMapping[ami.rootDeviceName]?.volumeSize

    try
      config = App.model.getOsFamilyConfig( data.region )
      config = config[ ami.osFamily ] || config[ constant.OS_TYPE_MAPPING[ami.osType] ]
      config = if ami.rootDeviceType  is "ebs" then config.ebs else config['instance store']
      config = config[ ami.architecture ]
      config = config[ ami.virtualizationType || "paravirtual" ]
      ami.instanceType = config.join(", ")
    catch e

    return MC.template.bubbleAMIInfo( ami )

  MC.template.resPanelDbSnapshot = ( data )->
    if not data.region or not data.id then return

    ss = CloudResources( Design.instance().credentialId(), constant.RESTYPE.DBSNAP, data.region ).get( data.id )
    if not ss then return

    LeftPanelTpl.resourcePanelBubble( ss.toJSON() )

  MC.template.resPanelSnapshot = ( data )->
    if not data.region or not data.id then return

    ss = CloudResources( Design.instance().credentialId(), constant.RESTYPE.SNAP, data.region ).get( data.id )
    if not ss then return
    newData = {}
    _.each ss.toJSON(), (value, key)->
      newKey = lang.IDE["DASH_BUB_"+ key.toUpperCase()] || key
      newData[newKey] = value
      return
    LeftPanelTpl.resourcePanelBubble( newData )



  LcItemView = Backbone.View.extend {

    tagName   : 'li'
    className : 'resource-item asg'

    initialize: ( options ) ->
      @parent = options.parent
      ( @parent or @ ).$el.find(".resource-list-asg").append @$el

      @listenTo @model, 'change:name', @render
      @listenTo @model, 'change:imageId', @render
      @listenTo @model, 'destroy', @remove

      @render()
      @$el.attr({
        "data-type"   : "ASG"
        "data-option" : '{"lcId":"' + @model.id + '"}'
      })
      return

    render : ()->
      @$el.html LeftPanelTpl.reuse_lc({
        name      : @model.get("name")
        cachedAmi : @model.getAmi() || @model.get("cachedAmi")
      })
  }



  Backbone.View.extend {

    events :
      "click nav button"             : "switchPanel"
      "click .btn-fav-ami"           : "toggleFav"
      "OPTION_CHANGE .AmiTypeSelect" : "changeAmiType"
      "click .BrowseCommunityAmi"    : "browseCommunityAmi"
      "click .ManageEbsSnapshot"     : "manageEbsSnapshot"
      "click .ManageRdsSnapshot"     : "manageRdsSnapshot"
      "click .fixedaccordion-head"   : "updateAccordion"
      "RECALC"                       : "recalcAccordion"
      "mousedown .resource-item"     : "startDrag"
      "click .refresh-resource-panel": "refreshPanelData"
      'click .resources-dropdown-wrapper li' : 'resourcesMenuClick'

      'OPTION_CHANGE #resource-list-sort-select-snapshot' : 'resourceListSortSelectSnapshotEvent'
      'OPTION_CHANGE #resource-list-sort-select-rds-snapshot' : 'resourceListSortSelectRdsEvent'

      'click .container-item'        : 'toggleConstraint'
      'keyup #filter-containers'     : 'filterContainers'
      'change #filter-containers'    : 'filterContainers'
      'click .group-header'          : 'toggleGroup'


    initialize : (options)->
      _.extend this, options

      @subViews = []

      region       = @workspace.design.region()
      credentialId = @workspace.design.credentialId()

      @listenTo CloudResources( credentialId, "MyAmi",               region ), "update", @updateMyAmiList
      @listenTo CloudResources( credentialId, constant.RESTYPE.AZ,   region ), "update", @updateAZ
      @listenTo CloudResources( credentialId, constant.RESTYPE.SNAP, region ), "update", @updateSnapshot
      @listenTo CloudResources( credentialId, constant.RESTYPE.DBSNAP, region ), "update", @updateRDSSnapshotList

      design = @workspace.design
      @listenTo design, Design.EVENT.ChangeResource, @onResChanged
      @listenTo design, Design.EVENT.AddResource,    @updateDisableItems
      @listenTo design, Design.EVENT.RemoveResource, @updateDisableItems
      @listenTo design, Design.EVENT.AddResource,    @updateLc

      @listenTo @workspace, "toggleRdsFeature", @toggleRdsFeature

      @__amiType = "QuickStartAmi" # QuickStartAmi | MyAmi | FavoriteAmi

      @setElement @parent.$el.find(".OEPanelLeft")

      $(document)
        .off('keydown', @bindKey.bind @)
        .on('keydown', @bindKey.bind @)

      @render()

    render : ()->

      hasVGW = hasCGW = true
      isMesos = @workspace.opsModel.isMesos()

      if Design.instance().region() is 'cn-north-1'
          hasVGW = hasCGW = false

      if Design.instance().get('state') is "Stopped"
        # Shouldn't loop
        return false

      @$el.html( LeftPanelTpl.panel({
        rdsDisabled : @workspace.isRdsDisabled()
        hasVGW : hasVGW
        hasCGW : hasCGW
        isMesos: isMesos
      }) )

      @$el.toggleClass("hidden", @__leftPanelHidden || false)
      @recalcAccordion()

      @updateAZ()
      @updateSnapshot()

      if isMesos
        if @workspace.opsModel.getMesosData()
          @getContainerList()
        @updateMesos()
        if @workspace.design.modeIsApp() and Design.modelClassForType( constant.RESTYPE.MESOSMASTER ).getMarathon()
          @workspace.opsModel.getMesosData().on 'change', @getContainerList, @
      else
        @updateAmi()

      @updateRDSList()
      @updateRDSSnapshotList()

      @updateDisableItems()
      @renderReuse()

      return

    switchPanel : (event) ->
      if not event
        @$el.find('.resource-panel').addClass('hide')
        @$el.find('.container-panel').removeClass('hide')
        return

      $button = $(event.currentTarget)

      # switch
      @$el.find('.container-panel').addClass('hide')
      @$el.find('.resource-panel').addClass('hide')
      if $button.hasClass('sidebar-nav-resource')
          @$el.find('.resource-panel').removeClass('hide')
      else
          @$el.find('.container-panel').removeClass('hide')

    toggleConstraint: ( e ) ->

      amimationDuration = 150

      $item = $ e.currentTarget

      @$( '.container-item' ).removeClass 'selected'
      $item.addClass("selected")

      $constraint = $item.next '.constraint-list'

      if $constraint.is(':visible')
        #$constraint.stop().slideUp()
      else
        @$( '.constraint-list' ).each ->
          $c = $( @ )
          if $c.is(':visible') then $c.stop().slideUp(amimationDuration)

        $constraint.stop().slideDown(amimationDuration)

      @highlightCanvas(e)

    highlightCanvas: (event) ->

      $item = $(event.currentTarget)
      hosts = $item.data('hosts')
      hostAry = hosts.split(',')
      models = []
      MasterModel = Design.modelClassForType(constant.RESTYPE.MESOSMASTER)
      _.each hostAry, (host) ->
        if host
          model = MasterModel.getCompByIp(host)
          if model.type is constant.RESTYPE.LC
            asgModel = model.connectionTargets("LcUsage")[0]
            expandedList = asgModel.get("expandedList") || []
            for expandedAsg in expandedList
              models.push expandedAsg.getLc()
          models.push(model) if model
      @workspace.view.highLightModels(models) if models.length

    resourceListSortSelectRdsEvent : (event) ->

        selectedId = 'date'

        if event

            $currentTarget = $(event.currentTarget)
            selectedId = $currentTarget.find('.selected').data('id')

        $sortedList = []

        if selectedId is 'date'

            $sortedList = @$el.find('.resource-list-rds-snapshot li').sort (a, b) ->
                return (new Date($(b).data('date'))) - (new Date($(a).data('date')))

        if selectedId is 'engine'

            $sortedList = @$el.find('.resource-list-rds-snapshot li').sort (a, b) ->
                return $(a).data('engine') - $(b).data('engine')

        if selectedId is 'storge'

            $sortedList = @$el.find('.resource-list-rds-snapshot li').sort (a, b) ->
                return Number($(b).data('storge')) - Number($(a).data('storge'))

        if $sortedList.length
            @$el.find('.resource-list-rds-snapshot').html($sortedList)

    resourceListSortSelectSnapshotEvent : (event) ->

        selectedId = 'date'

        if event

            $currentTarget = $(event.currentTarget)
            selectedId = $currentTarget.find('.selected').data('id')

        $sortedList = []

        if selectedId is 'date'

            $sortedList = @$el.find('.resource-list-snapshot li').sort (a, b) ->
                return (new Date($(b).data('date'))) - (new Date($(a).data('date')))

        if selectedId is 'storge'

            $sortedList = @$el.find('.resource-list-snapshot li').sort (a, b) ->
                return Number($(a).data('storge')) - Number($(b).data('storge'))

        if $sortedList.length
            @$el.find('.resource-list-snapshot').html($sortedList)

    bindKey: (event)->
      that = this
      keyCode = event.which
      metaKey = event.ctrlKey or event.metaKey
      shiftKey = event.shiftKey
      tagName = event.target.tagName.toLowerCase()
      is_input = tagName is 'input' or tagName is 'textarea'
      # Switch to Resource Pannel [R]
      if metaKey is false and shiftKey is false and keyCode is 82 and is_input is false
        that.toggleResourcePanel()
        return false

    renderReuse: ->
      for lc in @workspace.design.componentsOfType( constant.RESTYPE.LC )
        new LcItemView({model:lc, parent:@})
      @

    updateLc : ( resModel ) ->
      if resModel.type is constant.RESTYPE.LC and not resModel.get( 'appId' )
        new LcItemView({model:resModel, parent:@})

    onResChanged : ( resModel )->
      if not resModel then return
      if resModel.type isnt constant.RESTYPE.AZ then return
      @updateAZ()
      return

    updateAZ : ( resModel )->
      if not @workspace.isAwake() then return

      if resModel and resModel.type isnt constant.RESTYPE.AZ then return

      region = @workspace.design.region()
      usedAZ = ( az.get("name") for az in @workspace.design.componentsOfType(constant.RESTYPE.AZ) || [] )

      availableAZ = []
      for az in CloudResources( @workspace.design.credentialId(), constant.RESTYPE.AZ, region ).where({category:region}) || []
        if usedAZ.indexOf(az.id) is -1
          availableAZ.push(az.id)

      @$el.find(".az").toggleClass("disabled", availableAZ.length is 0).data("option", { name : availableAZ[0] }).children(".resource-count").text( availableAZ.length )
      return

    updateSnapshot : ()->
      region     = @workspace.design.region()
      cln        = CloudResources( @workspace.design.credentialId(), constant.RESTYPE.SNAP, region ).where({category:region}) || []
      cln.region = if cln.length then region else constant.REGION_SHORT_LABEL[region]

      @$el.find(".resource-list-snapshot").html LeftPanelTpl.snapshot( cln )

    toggleRdsFeature : ()->
      @$el.find(".ManageRdsSnapshot").parent().toggleClass( "disableRds", @workspace.isRdsDisabled() )
      if not @workspace.isRdsDisabled()
        @updateRDSList()
        @updateRDSSnapshotList()

      @updateDisableItems()
      @$el.children(".sidebar-title").find(".icon-rds-snap,.icon-pg").toggleClass("disabled", @workspace.isRdsDisabled())
      return

    updateRDSList : () ->
      cln = CloudResources( @workspace.design.credentialId(), constant.RESTYPE.DBENGINE, @workspace.design.region() ).groupBy("DBEngineDescription")
      @$el.find(".resource-list-rds").html LeftPanelTpl.rds( cln )

    updateRDSSnapshotList : () ->
      region     = @workspace.design.region()
      cln        = CloudResources( @workspace.design.credentialId(), constant.RESTYPE.DBSNAP, region ).toJSON()
      cln.region = if cln.length then region else constant.REGION_SHORT_LABEL[region]

      @$el.find(".resource-list-rds-snapshot").html LeftPanelTpl.rds_snapshot( cln )

    changeAmiType : ( evt, attr )->
      @__amiType = attr || "QuickStartAmi"
      @updateAmi()
      if not $(evt.currentTarget).parent().hasClass(".open")
        $(evt.currentTarget).parent().click()
      return

    updateAmi : ()->
      ms = CloudResources( @workspace.design.credentialId(), @__amiType, @workspace.design.region() ).getModels().sort ( a, b )->
        a = a.attributes
        b = b.attributes
        if a.osType is "windows" and b.osType isnt "windows" then return 1
        if a.osType isnt "windows" and b.osType is "windows" then return -1
        ca = a.osType
        cb = b.osType
        if ca is cb
          ca = a.architecture
          cb = b.architecture
          if ca is cb
            ca = a.name
            cb = b.name
        return if ca > cb then 1 else -1

      ms.fav    = @__amiType is "FavoriteAmi"
      ms.region = @workspace.opsModel.get("region")

      html = LeftPanelTpl.ami ms
      @$el.find(".resource-list-ami").html(html)#.parent().nanoScroller("reset")

    updateMesos: () ->
      region = @workspace.design.region()
      imageId = (_.findWhere constant.MESOS_AMI_IDS, {region}).imageId
      isAppEdit = Design.instance().modeIsAppEdit()
      data = { region, imageId, isAppEdit }
      html = LeftPanelTpl.mesos data
      @$(".resource-list-ami").html(html)

    updateDisableItems : ( resModel )->
      if not @workspace.isAwake() then return
      @updateAZ( resModel )

      design  = @workspace.design
      RESTYPE = constant.RESTYPE

      # VPC related
      $ul = @$el.find(".resource-item.igw").parent()
      $ul.children(".resource-item.igw").toggleClass("disabled", design.componentsOfType(RESTYPE.IGW).length > 0)
      $ul.children(".resource-item.vgw").toggleClass("disabled", design.componentsOfType(RESTYPE.VGW).length > 0)

      # Subnet group
      az = {}
      for subnet in design.componentsOfType(RESTYPE.SUBNET)
        az[ subnet.parent().get("name") ] = true

      @sbg = @$el.find(".resource-item.subnetgroup")
      if Design.instance().region() in ['cn-north-1']
          minAZCount = 1
      else
          minAZCount = 2
      if _.keys( az ).length < minAZCount
        disabled = true
        tooltip  = sprintf lang.IDE.RES_TIP_DRAG_CREATE_SUBNET_GROUP, minAZCount
        @sbg.toggleClass("disabled", true).attr("data-tooltip", )
      else
        disabled = false
        tooltip = lang.IDE.RES_TIP_DRAG_NEW_SUBNET_GROUP

      if @workspace.isRdsDisabled()
        disabled = true
        tooltip = lang.IDE.RES_MSG_RDS_DISABLED

      @sbg.toggleClass("disabled", disabled).attr("data-tooltip", tooltip)
      return

    updateFavList   : ()-> if @__amiType is "FavoriteAmi" then @updateAmi()
    updateMyAmiList : ()-> if @__amiType is "MyAmi" then @updateAmi()

    toggleFav : ( evt )->
      $tgt = $( evt.currentTarget ).toggleClass("fav")
      amiCln = CloudResources( @workspace.design.credentialId(), "FavoriteAmi", @workspace.design.region() )
      if $tgt.hasClass("fav")
        amiCln.fav( $tgt.attr("data-id") )
      else
        amiCln.unfav( $tgt.attr("data-id") )
      return false

    toggleLeftPanel : ()->
      @__leftPanelHidden = @$el.toggleClass("hidden").hasClass("hidden")
      null

    toggleResourcePanel: ()->
      @toggleLeftPanel()

    updateAccordion : ( event, noAnimate ) ->
      $target    = $( event.currentTarget )
      $accordion = $target.closest(".accordion-group")

      if event.target and not $( event.target ).hasClass("fixedaccordion-head")
        return

      if $accordion.hasClass "expanded"
        return false

      @__openedAccordion = $accordion.index()

      $expanded = $accordion.siblings ".expanded"

      $accordionWrap   = $accordion.closest ".fixedaccordion"
      $accordionParent = $accordionWrap.parents('.OEPanelLeft')

      titleHeight = $target.outerHeight()
      height      = $accordionParent.outerHeight() - 82 - ($accordionWrap.children().length-1) * titleHeight

      if noAnimate
        $accordion.innerHeight(height).addClass("expanded")#.children(".nano").nanoScroller("reset")
        $expanded.innerHeight(titleHeight).removeClass("expanded")
        return false

      $accordion.animate {height:height+"px"}, 200, ()-> $accordion.addClass("expanded")
      $expanded.animate {height:titleHeight+"px"}, 200, ()-> $expanded.removeClass("expanded")
      false

    recalcAccordion : () ->
      leftpane = @$el
      if not leftpane.length
        return

      $accordions = leftpane.find(".fixedaccordion").children()
      titleHeight = $accordions.children(".fixedaccordion-head").outerHeight()
      height = leftpane.outerHeight() - 82 - $accordions.length * titleHeight
      $accordions.children(".accordion-body").innerHeight(height)

      $accordion  = $accordions.filter(".expanded")
      if $accordion.length is 0
        $accordion = $accordions.eq( @__openedAccordion || 0 )

      $accordion.innerHeight(height+titleHeight)
      $accordion.siblings().innerHeight(titleHeight)

      $target = $accordion.removeClass( 'expanded' ).children( '.fixedaccordion-head' )
      this.updateAccordion( { currentTarget : $target[0] }, true )

    browseCommunityAmi : ()->
      region     = @workspace.design.region()
      credential = @workspace.design.credentialId()
      # Start listening fav update.
      @listenTo CloudResources( credential, "FavoriteAmi", region ), "update", @updateFavList

      amiBrowser = new AmiBrowser({ region : region, credential : credential })
      amiBrowser.onClose = ()=>
        @stopListening CloudResources( credential, "FavoriteAmi", region ), "update", @updateFavList
      return false

    manageEbsSnapshot : ()-> new EbsSnapshotManager().render()
    manageRdsSnapshot : ()-> new RdsSnapshotManager().render()

    refreshPanelData : ( evt )->
      $tgt = $( evt.currentTarget ).find(".icon-refresh")
      if $tgt.hasClass("reloading") then return

      $tgt.addClass("reloading")
      region     = @workspace.design.region()
      credential = @workspace.design.credentialId()

      jobs = [
        CloudResources( credential, "MyAmi", region ).fetchForce()
        CloudResources( credential, constant.RESTYPE.SNAP, region ).fetchForce()
      ]

      if @workspace.isRdsDisabled()
        jobs.push @workspace.fetchRdsData()
      else
        jobs.push CloudResources( credential, constant.RESTYPE.DBSNAP, region ).fetchForce()

      Q.all(jobs).done ()-> $tgt.removeClass("reloading")
      return

    resourcesMenuClick : (event) ->
      $currentDom = $(event.currentTarget)
      currentAction = $currentDom.data('action')

      switch currentAction
        when 'keypair'
          manager = keypairManager
        when 'snapshot'
          manager = EbsSnapshotManager
        when 'sns'
          manager = snsManager
        when 'sslcert'
          manager = sslCertManager
        when 'dhcp'
          manager = dhcpManager
        when 'rdspg'
          manager = rdsPgManager
        when 'rdssnapshot'
          manager = rdsSnapshot
        when 'eip'
          manager = eipManager

      new manager( workspace: @workspace ).render()

    startDrag : ( evt )->
      if evt.button isnt 0 then return false
      $tgt = $( evt.currentTarget )
      if $tgt.hasClass("disabled") then return false
      if evt.target && $( evt.target ).hasClass("btn-fav-ami") then return

      type = constant.RESTYPE[ $tgt.attr("data-type") ]

      dropTargets = "#OpsEditor .OEPanelCenter"
      if type is constant.RESTYPE.INSTANCE
        dropTargets += ",#changeAmiDropZone"

      option = $.extend true, {}, $tgt.data("option") || {}
      option.type = type

      $tgt.dnd( evt, {
        dropTargets  : $( dropTargets )
        dataTransfer : option
        eventPrefix  : if type is constant.RESTYPE.VOL then "addVol_" else "addItem_"
        onDragStart  : ( data )->
          if type is constant.RESTYPE.AZ
            data.shadow.children(".res-name").text( $tgt.data("option").name )
          else if type is constant.RESTYPE.ASG
            data.shadow.text( "ASG" )
      })
      return false

    remove: ->
      _.invoke @subViews, 'remove'
      @subViews = null
      Backbone.View.prototype.remove.call this
      return

    getContainerList: () ->

      that = @
      mesosData = @workspace.opsModel.getMesosData()

      appData = null
      taskData = null
      interval = 30 * 1000

      reqLoop = () ->
        leaderIp = mesosData.get('leaderIp')
        unless leaderIp then return
        if that.workspace.isAwake()
          deferArray = [
            that.getMarathonAppList(leaderIp).then (data) ->
              appData = data
            that.getMarathonTaskList(leaderIp).then (data) ->
              taskData = data
          ]
        else
          deferArray = []
        Q.all(deferArray).then (data) ->
          that.renderContainerList(appData, taskData) if appData
        .fail ()->
          that.renderMarathonNotReady()
        .finally () ->
          clearTimeout that.timeOutLoop
          that.timeOutLoop = setTimeout () ->
            reqLoop()
          , interval

      reqLoop()

    getMarathonAppList: (leaderIp) ->

      ApiRequest("marathon_app_list", {
        "key_id" : @workspace.opsModel.credentialId(),
        "leader_ip" : leaderIp
      })

    getMarathonTaskList: (leaderIp) ->

      ApiRequest("marathon_task_list", {
        "key_id" : @workspace.opsModel.credentialId(),
        "leader_ip" : leaderIp
      })

    renderMarathonNotReady: ()->
      if @workspace.__mesosIsReady
        return false

      @$('.marathon-app-ready').show().html LeftPanelTpl.mesosNotReady


    renderContainerList: (appData, taskData) ->

      if not @workspace.isAwake() then return
      that = @
      @workspace.__mesosIsReady = true
      dataApps = appData[1]?.apps
      dataTasks = taskData[1]?.tasks

      hostAppMap = {}
      if dataTasks and dataTasks.length
        _.each dataTasks, (task) ->
          appId = task.appId
          host = task.host
          hostAppMap[appId] = [] if not hostAppMap[appId]
          hostAppMap[appId].push(host)

      if dataApps and dataApps.length

        that.$('.marathon-app-list').show()
        that.$('.marathon-app-ready').hide()

        viewData = []
        _.each dataApps, (app) ->
          viewData.push({
            id: app.id,
            task: app.tasksRunning,
            instance: app.instances,
            cpu: app.cpus,
            memory: app.mem,
            hosts: (_.uniq (hostAppMap[app.id] or [])).join(',')
          })

        that.tempTaskFlag = that.$el.find("li.container-item.selected").data("name")
        __tempFilterWord = that.$("#filter-containers").val()
        that.$('.marathon-app-list').html LeftPanelTpl.containerList(viewData)
        that.$("#filter-containers").val(__tempFilterWord)
        that.filterContainers()
        that.recalcAccordion()

        # recover selected item state
        task = that.$el.find(".container-item[data-name='#{that.tempTaskFlag}']")
        if that.tempTaskFlag and task
          task.addClass("selected")
        else
          @workspace.view.removeHighlight()
      else
        that.$('.marathon-app-list').hide()
        that.$('.marathon-app-ready').show().html LeftPanelTpl.emptyContainer()

    removeHighlight: ()->
      @$(".container-item.selected").removeClass("selected")

    toggleGroup: (event) ->

        $header = $(event.currentTarget)
        $header.toggleClass('expand')
        $container = $header.next '.container-list'
        if $header.hasClass('expand')
            $container.removeClass('hide')
        else
            $container.addClass('hide')

    filterContainers: ()->
      keyword = @$("#filter-containers").val().toLowerCase()
      $(".container-list .container-item").each (index, item)->
        containerName = $(item).data("name").toLowerCase()
        shouldShow =  containerName.indexOf(keyword) >= 0
        if not shouldShow and $(item).hasClass("selected")
          $(item).next().hide()
        $(item).toggle(shouldShow)

  }
