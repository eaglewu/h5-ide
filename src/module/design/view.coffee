#############################
#  View(UI logic) for design
#############################

define [ 'event', 'text!./module/design/template.html', 'backbone', 'jquery', 'handlebars' ], ( ide_event, template ) ->

    DesignView = Backbone.View.extend {

        el          : '#tab-content-design'

        initialize  : ->

        render   : () ->
            console.log 'design render'
            #render
            this.$el.html template
            #push DESIGN_COMPLETE
            this.trigger 'DESIGN_COMPLETE'

        listen   : ( model ) ->
            #set this.model
            this.model = model
            #listen model
            this.listenTo this.model, 'change:snapshot', this.writeOldDesignHtml

        html : ->
            data =
                resource : $( '#resource-panel' ).html(),
                property : $( '#property-panel' ).html(),
                canvas   : $( '#canvas-panel'   ).html()
            data

        writeOldDesignHtml : ( event ) ->
            console.log 'writeOldDesignHtml'
            return if _.isNumber event.attributes.snapshot
            #
            $( '#canvas-panel' ).one( 'DOMNodeInserted', '.canvas-svg-group', this, _.debounce( this.canvasChange, 200, true ))
            #
            $( '#resource-panel' ).html this.model.get( 'snapshot' ).resource
            $( '#canvas-panel'   ).html this.model.get( 'snapshot' ).canvas
            ###
            this.$el.empty().html this.model.get 'snapshot'
            $( '#property-panel' ).html this.model.get( 'snapshot' ).property
            $( '#property-panel' ).empty()
            ###
            null

        canvasChange : ( event ) ->
            console.log 'canvas:listen DOMNodeInserted'
            console.log MC.data.current_tab_type
            if MC.data.current_tab_type is 'OLD_APP' or MC.data.current_tab_type is 'OLD_STACK'
                ide_event.trigger ide_event.SWITCH_WAITING_BAR
                MC.data.current_tab_type = null
            null

        showLayerPanel : ( state ) ->
            console.log 'showLayerPanel'
            # state include:
            # 1. open fail
            # 2. process( starting, stopping, updating, terminating, changed fail )

    }

    return DesignView
