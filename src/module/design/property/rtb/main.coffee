####################################
#  Controller for design/property/rtb module
####################################

define [ '../base/main',
         './model',
         './view',
         './app_model',
         './app_view',
         'event',
         'constant'
], ( PropertyModule, model, view, app_model, app_view, ide_event, constant ) ->

    ideEvents = {}
    ideEvents[ ide_event.CANVAS_DELETE_OBJECT ] = () ->
        @model.reInit()
        @view.render()

    ideEvents[ ide_event.CANVAS_CREATE_LINE ] = () ->
        @model.reInit()
        @view.render()

    RTBModule = PropertyModule.extend {

        handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable, /rtb-tgt/, /rtb-src/ ]

        initStack : () ->
            @model = model
            @view  = view
            null

        initApp  : () ->
            @model = app_model
            @view  = app_view
            null

        initAppEdit  : () ->
            @model = app_model
            @view  = app_view
            null

    }
    null
