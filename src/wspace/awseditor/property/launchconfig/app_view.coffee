#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    LCAppView = PropertyView.extend {

        events:
            'change #property-instance-enable-cloudwatch'   : 'cloudwatchSelect'
            'change #property-instance-user-data'           : 'userdataChange'
            'change #property-res-desc'                     : 'onChangeDescription'
            'change .launch-configuration-name'             : 'lcNameChange'

        kpModalClosed: false

        render: () ->
            data = _.extend isEditable: @model.isAppEdit, @model.toJSON()
            @$el.html template data
            data.name

        onChangeDescription : (event) -> @model.setDesc $(event.currentTarget).val()

        lcNameChange : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if MC.aws.aws.checkResName( @model.get('uid'), target, "LaunchConfiguration" )
                @model.setName name
                @setTitle name
            null

        cloudwatchSelect : ( event ) ->
            @model.setCloudWatch event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            @model.setUserData event.target.value

        elbNameChange: (event) ->
            target = $ event.currentTarget
            name = target.val()

            if MC.aws.aws.checkResName( @model.get('uid'), target, "Launch Configuration")
                @model.setName name
                @setTitle name
    }

    new LCAppView()
