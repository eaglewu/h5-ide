####################################
#  Controller for design/property/launchconfig module
####################################


define [ "../base/main",
         "./model",
         "./view",
         "./app_view",
         "../sglist/main",
         "constant",
         "event"
], ( PropertyModule, model, view, app_view, sglist_main, constant, ide_event ) ->

    model.on "KP_DOWNLOADED", (data, option)->
        app_view.updateKPModal(data, option)

    app_view.on "OPEN_AMI", (id)->
        PropertyModule.loadSubPanel "STATIC", id

    view.on "OPEN_AMI", (id)->
        PropertyModule.loadSubPanel "STATIC", id

    # ide_event.onLongListen ide_event.PROPERTY_DISABLE_USER_DATA_INPUT, (flag) ->
    #     view.disableUserDataInput(flag)
    #     null

    LCModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        initStack : () ->
            @model = model
            @model.isApp = false
            @view  = view
            null

        afterLoadStack : () ->
            sglist_main.loadModule @model
            null

        initApp : () ->
            @model = model
            @model.isApp = true
            @view  = app_view
            null

        initAppEdit : () ->
            @model = model
            @model.isApp = @model.isAppEdit = true
            @view  = app_view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null

        afterLoadAppEdit : () ->
            sglist_main.loadModule @model
            null
    }
    null
