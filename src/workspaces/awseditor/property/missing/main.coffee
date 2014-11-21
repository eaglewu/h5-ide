####################################
#  Controller for design/property/cgw module
####################################

define [ '../base/main', '../base/model', '../base/view', 'constant', 'i18n!/nls/lang.js' ], ( PropertyModule, PropertyModel, PropertyView, constant, lang ) ->

    MissingView = PropertyView.extend {
        render : () ->
            comp = Design.instance().component @model.get 'uid'
            if Design.instance().get('state') in ['Stopped', "Stopping" ] and comp.type is constant.RESTYPE.ASG
                @$el.html MC.template.missingAsgWhenStop asgName: comp.get 'name'
                return "#{comp.get 'name'} Deleted"

            else
                @$el.html MC.template.missingPropertyPanel()
                return lang.PROP.MISSING_RESOURCE_UNAVAILABLE
    }

    view  = new MissingView()

    m = PropertyModel.extend {
        init : ( uid ) ->
            @set 'uid', uid
    }

    model = new m()

    MissingModule = PropertyModule.extend {

        handleTypes : "Missing_Resource"

        initApp : () ->
            @model = model
            @view  = view
            null

        initAppEdit : ()->
            @model = model
            @view  = view
            null
    }
    null
