####################################
#  Controller for design/property/volume module
####################################

define [ "../base/main",
         "./model",
         "./view",
         "./app_model",
         "./app_view",
         "constant"
], ( PropertyModule, model, view, app_model, app_view, constant )->

    VolumeModule = PropertyModule.extend {

        hanldeTypes : [ constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume, "component_asg_volume" ]

        setupStack : () ->
            me = this
            @view.on "DEVICE_NAME_CHANGED", ( name )->
                @model.setDeviceName name
                null

            @view.on 'VOLUME_SIZE_CHANGED', ( value ) ->
                me.model.setVolumeSize value
                MC.canvas.update model.attributes.uid, "text", "volume_size", value + "GB"

            @view.on 'VOLUME_TYPE_STANDARD', ()->
                me.model.setVolumeTypeStandard()

            @view.on 'VOLUME_TYPE_IOPS', ( value )->
                me.model.setVolumeTypeIops value

            @view.on 'IOPS_CHANGED' , ( value ) ->
                me.model.setVolumeIops value

            @model.once 'REFRESH_PANEL', ()->
                me.view.render()

            null

        initStack : ()->
            @model = model
            @view  = view
            null

        initApp : ()->
            @model = app_model
            @view  = app_view
            null
    }
    null
