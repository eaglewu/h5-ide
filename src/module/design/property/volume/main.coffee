####################################
#  Controller for design/property/volume module
####################################

define [ 'jquery',
         'text!./template.html',
         'text!./app_template.html',
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
        if tab_type is 'OPEN_APP' and MC.forge.app.existing_app_resource( uid )
            loadAppModule uid
            return

        #
        require [ './module/design/property/volume/view',
                  './module/design/property/volume/model'
        ], ( view, model ) ->

            # added by song
            model.clear({silent: true})

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
                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.volume_detail.name

            renderPropertyPanel( uid )

            view.on "DEVICE_NAME_CHANGED", ( name )->
                model.setDeviceName name
                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.volume_detail.name
                null

            view.on 'VOLUME_SIZE_CHANGED', ( value ) ->
                model.setVolumeSize value
                MC.canvas.update model.attributes.uid, "text", "volume_size", value + "GB"

            view.on 'VOLUME_TYPE_STANDARD', ()->
                model.setVolumeTypeStandard()

            view.on 'VOLUME_TYPE_IOPS', ( value )->
                model.setVolumeTypeIops value

            view.on 'IOPS_CHANGED' , ( value ) ->
                model.setVolumeIops value

            model.once 'REFRESH_PANEL', ()->
                view.render()

    loadAppModule = ( uid ) ->
        require [ './module/design/property/volume/app_view',
                  './module/design/property/volume/app_model'
        ], ( view, model ) ->

            # added by song
            model.clear({silent: true})

            #
            if current_view then view.delegateEvents view.events

            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.init uid
            view.render()
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name

    unLoadModule = () ->
        if !current_view then return
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
