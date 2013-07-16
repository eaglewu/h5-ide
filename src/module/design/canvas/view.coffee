#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'MC.canvas', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    CanvasView = Backbone.View.extend {

        el       : $( '#canvas' )

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.resizeCanvasPanel
            $( document ).delegate '#svg_canvas', 'CANVAS_NODE_SELECTED',     this.showProperty
            $( document ).delegate '#svg_canvas', 'CANVAS_NODE_CHANGE_PARENT', this.changeNodeParent
            $( document ).delegate '#svg_canvas', 'CANVAS_GROUP_CHANGE_PARENT', this.changeGroupParent

        render   : ( template ) ->
            console.log 'canvas render'
            $( '#canvas' ).html template
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            console.log 're-canvas render'
            if $.trim( this.$el.html() ) is 'loading...' then $( '#canvas' ).html template

        resizeCanvasPanel : ( type ) ->
            console.log 'resizeCanvasPanel = ' + type
            #temp resize canvas panel
            canvasPanelResize()
            #temp
            require [ 'canvas_layout' ], ( canvas_layout ) -> canvas_layout.listen()

        showProperty : ( event, uid ) ->
            console.log 'showProperty, uid = ' + uid
            ide_event.trigger ide_event.OPEN_PROPERTY, uid

        changeNodeParent : ( event, option ) ->
            ide_event.trigger ide_event.CANVAS_NODE_CHANGE_PARENT, option.src_node, option.tgt_parent

        changeGroupParent : ( event, option ) ->
            ide_event.trigger ide_event.CANVAS_GROUP_CHANGE_PARENT, option.src_group, option.tgt_parent

    }

    return CanvasView