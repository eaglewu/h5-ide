####################################
#  Controller for design/property/launchconfig module
####################################

define [ 'jquery',
         'text!/module/design/property/asg/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view     = null
    current_model    = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-asg-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( uid, current_main ) ->


        require [ './module/design/property/asg/view',
                  './module/design/property/asg/model',
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model
            #

            #view
            view.model    = model
            view.render()




    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
