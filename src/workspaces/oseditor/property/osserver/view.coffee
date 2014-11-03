define [
  'constant'
  '../OsPropertyView'
  './template'
  'CloudResources'
  'underscore'
  'OsKp'
  '../ossglist/view'
], ( constant, OsPropertyView, template, CloudResources, _, OsKp, SgListView ) ->

  OsPropertyView.extend {

    events:

      "change #property-os-server-credential": "onChangeCredential"
      "change #property-os-server-name": "updateServerAttr"
      "change #property-os-server-image": "updateServerAttr"
      "change #property-os-server-CPU":  "updateServerAttr"
      "change #property-os-server-RAM": "updateServerAttr"
      "change #property-os-server-keypair": "updateServerAttr"
      "change #property-os-server-adminPass": "updateServerAttr"
      "change #property-os-server-userdata": "updateServerAttr"
      'change #property-os-server-fip': "updateServerAttr"
      'change #property-os-server-aip': "updateServerAttr"

    initialize: ->
        @sgListView = @reg new SgListView targetModel: @model?.embedPort()
        @listenTo @model, 'change:fip', @render

    render: ->
      json = @model.toJSON()
      @flavorList = App.model.getOpenstackFlavors( Design.instance().get("provider"), Design.instance().region() )
      json.imageList = CloudResources(constant.RESTYPE.OSIMAGE, Design.instance().region()).toJSON()
      json.floatingIp = !!@model.embedPort().getFloatingIp()
      json.fixedIp = @model.embedPort().get('ip')
      json.isAppEdit = @modeIsAppEdit()
      json.agentEnabled = Design.instance().get('agent').enabled
      @$el.html template.stackTemplate json
      kpDropdown = new OsKp(@model,template.kpSelection {isAppEdit: @modeIsAppEdit()})
      @$el.find("#property-os-server-keypair").html(kpDropdown.render().$el)
      @stopListening @workspace.design
      @listenTo @workspace.design, "change:agent" , @render
      @bindSelectizeEvent()

      # append sglist
      @$el.append @sgListView.render().el

      @

    bindSelectizeEvent: ()->
      that = @
      flavorGroup = _.groupBy that.flavorList.toJSON(), 'vcpus'
      currentFlavor = that.flavorList.get(that.model.get('flavorId'))
      avaliableRams = _.map ( _.pluck flavorGroup[currentFlavor.get('vcpus')], 'ram'), (e)-> {text: e/1024 + " G", value: e}
      @$el.find("#property-os-server-image").on 'select_initialize', ()->
        @.selectize.setValue(that.model.get('imageId'))
      @$el.find("#property-os-server-credential").on 'select_initialize', ()->
        that.checkWindowsDistro that.model.get("imageId")
      @$el.find('#property-os-server-RAM').on 'select_initialize', ()->
        @.selectize.addOption avaliableRams
        @.selectize.setValue currentFlavor.get('ram')
      @$el.find('#property-os-server-CPU').on 'select_initialize', ()->
        avaliableCPUs = _.map flavorGroup, (e,index)->
          {text: index + " Core", value: index}
        @.selectize.addOption avaliableCPUs
        @.selectize.setValue currentFlavor.get('vcpus')

    onChangeCredential: (event, value)->
      result = if event then $(event.currentTarget).getValue() else value
      @model.set('credential', result)
      if result is "keypair"
        @$el.find("#property-os-server-keypair").parent().show()
        @$el.find('#property-os-server-adminPass').parent().hide()
      else
        @$el.find("#property-os-server-keypair").parent().hide()
        @$el.find('#property-os-server-adminPass').parent().show()

    checkWindowsDistro: (imageId)->
      image = CloudResources(constant.RESTYPE.OSIMAGE, Design.instance().region()).get(imageId)
      distro = image.get("os_distro")
      distroIsWindows = distro is 'windows'
      $serverCredential = @$el.find("#property-os-server-credential")
      $serverCredential.parents(".group").toggle(not distroIsWindows)
      if distroIsWindows
        @model.set('credential', 'adminPass')
        $serverCredential[0].selectize?.setValue('adminPass')
        @onChangeCredential(null, 'adminPass')

    updateServerAttr: (event)->
      target = $(event.currentTarget)
      attr = target.data('target')
      selectize = target[0].selectize

      if attr is 'imageId'
        @model.setImage target.val()
        @checkWindowsDistro(target.val())

      if attr is 'name'
        @setTitle target.val()

      if attr is 'CPU'
        flavorGroup = _.groupBy @flavorList.models, (e)-> return e.get 'vcpus'
        availableRams = flavorGroup[target.val()]
        if availableRams?.length
          ramSelectize = @$el.find("#property-os-server-RAM")[0].selectize
          if not ramSelectize then return false
          ramValue = ramSelectize.getValue()
          availableRamsValue = _.map (_.pluck (_.map availableRams, (ram)-> ram.toJSON()), 'ram'), (e)-> {text: (e/1024 + " G"), value: e}
          currentRamFlavor = _.find(availableRams, (e)-> return e.get('ram') is +ramValue)
          if not currentRamFlavor
            ramValue = _.min(_.pluck availableRamsValue, 'value')
            currentRamFlavor = _.find(availableRams, (e)-> return e.get('ram') is +ramValue)
          @model.set("flavorId", currentRamFlavor.get('id'))
          @updateRamOptions(availableRamsValue, ramValue)
        else
          return false
        return false

      if attr is 'RAM'
        oldRamFlavor = @flavorList.get @model.get('flavorId')
        flavorGroup = _.groupBy @flavorList.models, (e)-> e.get 'vcpus'
        availableRams = flavorGroup[oldRamFlavor.get('vcpus')]
        targetFlavor = _.find availableRams, (e)->return e.get('ram') is +selectize.getValue()
        @model.set('flavorId', targetFlavor.get('id'))
        return false

      if attr is "fixedIp"
        serverPort = @model.embedPort()
        serverPort.setIp(target.val())
        return false

      if attr is 'associateFip'
        serverPort = @model.embedPort()
        serverPort.setFloatingIp target.getValue() #bool type use jQuery $el.getValue()
        return false

      @model.set(attr, target.val()) if attr

    updateRamOptions: (availableRams, currentRam)->
      ramSelection = @$el.find("#property-os-server-RAM")[0].selectize
      ramSelection.clearOptions()
      ramSelection.load (callback)->
        callback availableRams
        ramSelection.refreshOptions(false)
        ramSelection.setValue(currentRam)

    selectTpl:

      imageSelect: (item) ->
        imageList = CloudResources constant.RESTYPE.OSIMAGE, Design.instance().region()
        imageObj = imageList.get(item.value)?.toJSON()
        if not imageObj
          item.distro = "ami-unknown"
          return template.imageListKey(item)

        imageObj.distro = imageObj.os_type + "." + imageObj.architecture
        template.imageListKey(imageObj)

      imageValue: (item) ->
        imageList = CloudResources constant.RESTYPE.OSIMAGE, Design.instance().region()
        imageObj = imageList.get(item.value)?.toJSON()
        if not imageObj
          item.distro = "ami-unknown"
          item.text = item.text || "Unknow"
          return template.imageValue(item)

        imageObj.distro = imageObj.os_type + "." + imageObj.architecture
        template.imageValue(imageObj)

      kpButton: ()->
        template.kpButton()
  }, {
    handleTypes: [ constant.RESTYPE.OSSERVER ]
    handleModes: [ 'stack', 'appedit' ]
  }

#  Panel.openProperty({uid:'server0001',type: "OS::Nova::Server"})
