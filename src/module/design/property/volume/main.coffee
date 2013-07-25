####################################
#  Controller for design/property/volume module
####################################

define [ 'jquery',
         'text!/module/design/property/volume/template.html',
         'text!/module/design/property/volume/app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-volume-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-volume-app-tmpl">' + app_template + '</script>'
    #load remote html template
    $( 'head' ).append( template ).append( app_template )
    console.log 'volume loaded'

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

        #
        require [ './module/design/property/volume/' + view_type,
                  './module/design/property/volume/model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model

            renderPropertyPanel = ( uid ) ->

                model.getVolume uid
                #render
                #view.render( view.model.attributes )
                view.render()

            renderPropertyPanel( uid )

            view.on "DEVICE_NAME_CHANGED", ( name )->

                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setDeviceName volume_uid, name

                renderPropertyPanel( volume_uid )

            view.on 'VOLUME_SIZE_CHANGED', ( value ) ->

                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setVolumeSize volume_uid, value

                #renderPropertyPanel( volume_uid )

            view.on 'VOLUME_TYPE_STANDARD', ()->

                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setVolumeTypeStandard volume_uid

            view.on 'VOLUME_TYPE_IOPS', ( value )->


                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setVolumeTypeIops volume_uid, value

                #renderPropertyPanel( volume_uid )

            view.on 'IOPS_CHANGED' , ( value ) ->

                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setVolumeIops volume_uid, value

                #renderPropertyPanel( volume_uid )

            model.once 'REFRESH_PANEL', ()->

                view.render()


    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
