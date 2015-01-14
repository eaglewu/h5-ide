define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    'underscore'
    'OsKp'
    '../ossglist/view'
    'ApiRequest'
    'ApiRequestOs'
    'i18n!/nls/lang.js'
], ( constant, OsPropertyView, template, CloudResources, _, OsKp, SgListView, ApiRequest, ApiRequestOs, lang ) ->

  OsPropertyView.extend {

    events:

        'click .os-server-image-info'        : 'openImageInfoPanel'
        'click .property-btn-get-system-log' : 'openSysLogModal'

    initialize: ->

        @sgListView = new SgListView {
            panel: @panel,
            targetModel: @model.embedPort()
        }

    render: ->

        appData = @getRenderData()

        # if appData and appData.launch_at
        #     appData.launch_at = new Date(appData.launch_at)
        addrData = {}

        # get address info
        addressData = appData?.address?.addresses
        if addressData
            _.each addressData, (addrAry) ->
                _.each addrAry, (addrObj) ->
                    if addrObj.type is 'fixed'
                        addrData.fixedIp = addrObj.addr
                        addrData.macAddress = addrObj.mac_addr
                    if addrObj.type is 'floating'
                        addrData.floatingIp = addrObj.addr
                    null
                null

        @flavorList = App.model.getOpenstackFlavors( Design.instance().get("provider"), Design.instance().region() )
        flavorObj = @flavorList.get(appData.flavor_id)
        appData.vcpus = flavorObj.get("vcpus")
        appData.ram = Math.round(flavorObj.get("ram") / 1024)
        appData.image_name = @model.getImage()?.name
        appData.image_id = @model.getImage()?.id
        @$el.html template.appTemplate _.extend(appData, addrData)
        # append sglist
        @$el.append @sgListView.render().el
        @

    openSysLogModal : () ->
        serverId = @model.get('appId')

        that = this
        region = Design.instance().region()

        reqApi = "os_server_GetConsoleOutput" # for openstack
        ApiRequestOs(reqApi, {
            region : region
            server_id    : serverId
        }).then @refreshSysLog, @refreshSysLog

        new modalPlus({
            template:MC.template.modalInstanceSysLog {log_content: ''}
            width: 900
            title: lang.IDE.SYSTEM_LOG + serverId
            confirm: hide: true
        }).tpl.attr("id", "modal-instance-sys-log")

        false

    refreshSysLog : (result) ->
        $('#modal-instance-sys-log .instance-sys-log-loading').hide()

        if result and result.output

            logContent = result.output
            $contentElem = $('#modal-instance-sys-log .instance-sys-log-content')

            $contentElem.html MC.template.convertBreaklines({content:logContent})
            $contentElem.show()

        else

            $('#modal-instance-sys-log .instance-sys-log-info').show()

        modal.position()

    openImageInfoPanel: ->

        serverData = @getRenderData()?.system_metadata
        serverData.image_name = @model.getImage()?.name
        serverData.image_id = @model.getImage()?.id
        @showFloatPanel(template.imageTemplate(serverData))

    }, {
        handleTypes: [ constant.RESTYPE.OSSERVER ]
        handleModes: [ 'app' ]
    }
