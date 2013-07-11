####################################
#  Controller for design/toolbar module
####################################

define [ 'jquery', 'text!/module/design/toolbar/template.html', 'event' ], ( $, toolbar_tmpl, event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        toolbar_tmpl = '<script type="text/x-handlebars-template" id="toolbar-tmpl">' + toolbar_tmpl + '</script>'
        #load remote html template
        $( toolbar_tmpl ).appendTo '#main-toolbar'

        #load remote module1.js
        require [ './module/design/toolbar/view', './module/design/toolbar/model' ], ( View, model ) ->

            #view
            view       = new View()
            view.model = model
            view.render()

            #save
            view.on 'TOOLBAR_SAVE_CLICK', () ->
                console.log 'design_toolbar_click:saveStack'
                model.saveStack()

            #duplicate
            view.on 'TOOLBAR_DUPLICATE_CLICK', () ->
                console.log 'design_toolbar_click:duplicateStack'
                model.duplicateStack()

            #delete
            view.on 'TOOLBAR_DELETE_CLICK', () ->
                console.log 'design_toolbar_click:deleteStack'
                model.deleteStack()

            #new
            view.on 'TOOLBAR_NEW_CLICK', () ->
                console.log 'design_toolbar_click:newStack'
                model.newStack()

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

            #export png
            view.on 'TOOLBAR_EXPORT_PNG_CLICK', () ->
                console.log 'design_toolbar_click:exportPng'

            #export json
            view.on 'TOOLBAR_EXPORT_JSON_CLICK', () ->
                console.log 'design_toolbar_click:exportJson'
                model.exportJson('test-text.txt')


    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule