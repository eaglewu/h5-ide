
define [
  './DashboardTpl'
  './DashboardTplData'
  "./ImportAppTpl"
  "constant"
  "i18n!/nls/lang.js"
  "CloudResources"
  "UI.modalplus"
  'AppAction'
  "backbone"
  "UI.tooltip"
  "UI.table"
  "UI.bubble"
  "UI.scrollbar"
  "UI.nanoscroller"
], ( Template, TemplateData, ImportAppTpl, constant, lang, CloudResources, Modal, appAction )->

  Backbone.View.extend {

    events :
      'click #OsReloadResource' : 'reloadResource'
      'click .icon-new-stack'   : 'createStack'

      'click .ops-list-switcher'              : 'switchAppStack'
      "click .dash-ops-list > li"             : "openItem"
      "click .dash-ops-list .delete-stack"    : "deleteStack"
      'click .dash-ops-list .duplicate-stack' : 'duplicateStack'
      "click .dash-ops-list .start-app"       : "startApp"
      'click .dash-ops-list .stop-app'        : 'stopApp'
      'click .dash-ops-list .terminate-app'   : 'terminateApp'

      'click .resource-tab'                   : 'switchResource'

      "click #ImportStack"  : "importStack"
      "click #VisualizeApp" : "importApp"

    resourcesTab: 'OSSERVER'

    initialize : ()->
      @opsListTab = "stack"
      @lastUpdate = +(new Date())

      @setElement( $(Template.frame()).eq(0).appendTo("#main") )

      @updateOpsList()
      @updateResList()
      @updateRegionResources(true)

      self = @
      setInterval ()->
        if not $("#OsReloadResource").hasClass("reloading")
          $("#OsReloadResource").text( MC.intervalDate(self.lastUpdate/1000) )
        return
      , 1000 * 60

      # Add a custom template to the MC.template, so that the UI.bubble can use it to render.
      MC.template.osDashboardBubble = _.bind @osDashboardBubble, @
      return

    awake : ()-> @$el.show().children(".nano").nanoScroller(); return
    sleep : ()-> @$el.hide()

    osDashboardBubble : ( data )->
      # get Resource Data
      d = {
        id   : data.id
        data : @model.getOsResDataById( constant.RESTYPE[data.type], data.id )?.toJSON()
      }
      d.data = d.data.system_metadata

      # Make Boolean to String to show in handlebarsjs
      _.each d.data, (e,key)->
          if _.isBoolean e
              d.data[key] = e.toString()
          if e == ""
              d.data[key] = "None"
          if (_.isArray e) and e.length is 0
              d.data[key] = ['None']
          if (_.isObject e) and (not _.isArray e)
              delete d.data[key]

      return TemplateData.bubbleResourceInfo  d

    ###
      rendering
    ###
    updateOpsList : ()->
      $opsListView = @$el.find(".dash-ops-list-wrapper")

      tojson = {thumbnail:true}
      filter = (m)-> m.isExisting()
      mapper = (m)-> m.toJSON(tojson)
      stacks = App.model.stackList().filter( filter )
      apps   = App.model.appList().filter( filter )

      # Update count
      $switcher = $opsListView.children("nav")
      $switcher.find(".count").text( apps.length )
      $switcher.find(".stack").find(".count").text( stacks.length )

      # Update list
      if @opsListTab is "stack"
        html = Template.stackList( stacks.map(mapper) )
      else
        html = Template.appList( apps.map(mapper) )

      $opsListView.children("ul").html html
      return

    updateResList: () ->
      @$('.dash-ops-resource-list').html Template.resourceList {}

    updateAppProgress : ( model )->
      if model.get("region") is @model.region and @regionOpsTab is "app"

        console.log "Dashboard Updated due to app progress changes."

        $li = $el.find(".dash-ops-list").children("[data-id='#{model.id}']")
        if not $li.length then return
        $li.children(".region-resource-progess").show().css({width:model.get("progress")+"%"})
        return

    ###
      View logics
    ###
    switchAppStack: ( evt ) ->
      $target = $(evt.currentTarget)
      if $target.hasClass("on") then return
      $target.addClass("on").siblings().removeClass("on")

      @opsListTab = if $target.hasClass("stack") then "stack" else "app"
      @updateOpsList()
      return

    switchResource : ( evt )->
      @$(".resource-list-nav").children().removeClass("on")
      @resourcesTab = $(evt.currentTarget).addClass("on").attr("data-type")
      @updateRegionResources()
      return

    updateResourceCount : (init)->
      that = @
      provider = App.user.get("default_provider")
      quotaMap = App.model.getOpenstackQuotas(provider)
      $nav = $(".resource-list-nav")
      resourceMap = {
        elbs: "Neutron::port"
        fips: "Neutron::floatingip"
        rts: "Neutron::router"
        servers: "Nova::instances"
        snaps: "Cinder::snapshots"
        volumes: "Cinder::volumes"
      }
      if init is true and quotaMap
        _.each resourceMap, (value, key)->
          dom = $nav.children(".#{key}")
          quota = quotaMap[value]
          that.animateUsage(dom, 0, quota)
          dom.find('.count-usage').text( "-" )

      resourceCount = @model.getResourcesCount()
      for r, count of resourceCount
        child = $nav.children(".#{r}")
        if typeof count == "number" and quotaMap
          @animateUsage(child, count , quotaMap[resourceMap[r]])
      return

    animateUsage: (elem, usage, quota)->
      $path = elem.find(".quota-path.usage")
      $path.attr("stroke-dashoffset", ($path[0].getTotalLength() * (1-usage/quota)).toFixed(2) )
      elem.find('.count-usage').text( usage )
      elem.find('.count-quota').text( "/" + quota )

    updateRegionResources : ( type )->
      @updateResourceCount(type)
      if type and @resourcesTab not in type then return

      type = constant.RESTYPE[ @resourcesTab ]
      if not @model.isOsResReady( type )
        tpl = '<div class="dashboard-loading"><div class="loading-spinner"></div></div>'
      else
        tpl = TemplateData["resource_#{@resourcesTab}"]( @model.getOsResData( type ) )

      $(".resource-list-body").html( tpl )

    openItem    : ( event )-> App.openOps( $(event.currentTarget).attr("data-id") )
    createStack : ( event )-> App.createOps( @model.region, @model.provider )

    markUpdated : ()-> @lastUpdate = +(new Date()); return

    reloadResource : ()->
      if $("#OsReloadResource").hasClass("reloading")
        return

      $("#OsReloadResource").addClass("reloading").text("")
      App.discardAwsCache().done ()->
        $("#OsReloadResource").removeClass("reloading").text("just now")
      return

    deleteStack    : (event)-> appAction.deleteStack $( event.currentTarget ).closest("li").attr("data-id"); false
    duplicateStack : (event)-> appAction.duplicateStack $( event.currentTarget ).closest("li").attr("data-id"); false
    startApp       : (event)-> appAction.startApp $( event.currentTarget ).closest("li").attr("data-id"); false
    stopApp        : (event)-> appAction.stopApp $( event.currentTarget ).closest("li").attr("data-id"); false
    terminateApp   : (event)-> appAction.terminateApp $( event.currentTarget ).closest("li").attr("data-id"); false

    importStack : ()->
      modal = new Modal {
        title         : lang.IDE.POP_IMPORT_JSON_TIT
        template      : Template.importJSON()
        width         : "470"
        disableFooter : true
      }

      reader = new FileReader()
      reader.onload = ( evt )->
        error = App.importJson( reader.result )
        if _.isString error
          $("#import-json-error").html error
        else
          modal.close()
          reader = null
        null

      reader.onerror = ()->
        $("#import-json-error").html lang.IDE.POP_IMPORT_ERROR
        null

      hanldeFile = ( evt )->
        evt.stopPropagation()
        evt.preventDefault()

        $("#modal-import-json-dropzone").removeClass("dragover")
        $("#import-json-error").html("")

        evt = evt.originalEvent
        files = (evt.dataTransfer || evt.target).files
        if not files or not files.length then return
        reader.readAsText( files[0] )
        null

      $("#modal-import-json-file").on "change", hanldeFile
      zone = $("#modal-import-json-dropzone").on "drop", hanldeFile
      zone.on "dragenter", ()-> $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", true)
      zone.on "dragleave", ()-> $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", false)
      zone.on "dragover", ( evt )->
        dt = evt.originalEvent.dataTransfer
        if dt then dt.dropEffect = "copy"
        evt.stopPropagation()
        evt.preventDefault()
        null
      null

    importApp : ()->
      self = @
      if not @visModal
        @visModal = new Modal {
          title         : lang.IDE.DASH_IMPORT_APP
          width         : "770"
          template      : ImportAppTpl({})
          disableFooter : true
          compact       : true
          onClose       : ()-> self.visModal = null; return
        }

        @visModal.tpl.on "click", "#VisualizeReload", ()->
          self.importApp()
          self.visModal.tpl.find(".unmanaged-vpc-empty").hide()
          self.visModal.tpl.find(".loading-spinner").show()
          false

        @visModal.tpl.on "click", ".visualize-vpc-btn", (event)-> self.doImportApp(event)

      @model.importApp().then ( data )->
        self.visModal.tpl.find(".modal-body").html ImportAppTpl({
          ready : true
          data  : data
        })
      , ()->
        self.visModal.tpl.find(".modal-body").html ImportAppTpl({fail:true})

      return

    doImportApp : ( evt )->
      $tgt   = $(evt.currentTarget)
      id     = $tgt.attr("data-id")
      region = $tgt.closest("ul").attr("data-region")

      @visModal.close()
      App.openOps App.model.createImportOps( region, "openstack", @model.provider, id )
      false


  }
