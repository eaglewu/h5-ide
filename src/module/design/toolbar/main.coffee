####################################
#  Controller for design/toolbar module
####################################

define [ 'jquery', 'text!/module/design/toolbar/template.html', 'event' ], ( $, toolbar_tmpl, ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        toolbar_tmpl = '<script type="text/x-handlebars-template" id="toolbar-tmpl">' + toolbar_tmpl + '</script>'
        #load remote html template
        $( 'head' ).append toolbar_tmpl

        #load remote module1.js
        require [ './module/design/toolbar/view', './module/design/toolbar/model' ], ( View, model ) ->

            #view
            view       = new View()
            view.model = model
            view.render()

            #listen RELOAD_RESOURCE
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, () ->
                console.log 'toolbar:RELOAD_RESOURCE'
                #check re-render
                view.reRender()

            #save
            view.on 'TOOLBAR_SAVE_CLICK', () ->
                console.log 'design_toolbar_click:saveStack'
                model.saveStack()

            #duplicate
            view.on 'TOOLBAR_DUPLICATE_CLICK', () ->
                console.log 'design_toolbar_click:get_ready_for_stack'

                model.once 'TOOLBAR_STACK_READY', () ->
                    console.log 'design_toolbar_click:duplicateStack'
                    model.duplicateStack()

            #delete
            view.on 'TOOLBAR_DELETE_CLICK', () ->
                console.log 'design_toolbar_click:deleteStack'
                model.deleteStack()

            #run
            view.on 'TOOLBAR_RUN_CLICK', () ->
                console.log 'design_toolbar_click:runStack'
                model.runStack( 'stack_test_run' )

            #zoomin
            view.on 'TOOLBAR_ZOOMIN_CLICK', () ->
                console.log 'design_toolbar_click:zoomInStack'
                model.zoomInStack()

            #zoomout
            view.on 'TOOLBAR_ZOOMOUT_CLICK', () ->
                console.log 'design_toolbar_click:zoomOutStack'
                model.zoomOutStack()

            #export to png
            view.on 'TOOLBAR_EXPORT_PNG_CLICK', () ->
                console.log 'design_toolbar_click:exportPngIcon'
                model.savePNG false

            #
            model.on 'SAVE_PNG_COMPLETE', ( base64_image ) ->
                console.log 'SAVE_PNG_COMPLETE'
                view.exportPNG base64_image

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule