
define [
    'backbone'
    'constant'
    '../template/TplPanel'
    './panels/ResourcePanel'
    './panels/ConfigPanel'
    './panels/PropertyPanel'
    'component/stateeditor/view'

], ( Backbone, constant, PanelTpl, ResourcePanel, ConfigPanel, PropertyPanel, StatePanel )->

  Panels = {
    resource : ResourcePanel
    config   : ConfigPanel
    property : PropertyPanel
    state    : StatePanel
  }

  __defaultArgs = { uid: '', type: 'default' }
  __openArgs = __defaultArgs
  __currentPanel = 'resource'

  Backbone.View.extend

    events:
        'click .anchor li'       : '__scrollTo'

    initialize: ( options ) ->
        _.extend @, options
        @render()

    render: () ->
        @setElement @parent.$el.find(".OEPanelRight")

        @$el.html PanelTpl {}
        @open 'resource'

        @

    renderSubPanel: ( subPanel, args ) ->
        args = _.extend { workspace: @workspace, panel: @ }, args

        @subPanel?.remove()
        @subPanel = new subPanel( args )

        $(document.activeElement).filter("input, textarea").blur()

        @$( '.panel-body' ).html @subPanel.render().el

    scrollTo: ( className ) ->
        $container = @$ '.panel-body'
        $target = $( "section.#{className}" )

        top = $container.offset().top
        newTop = $target.offset().top - top + $container.scrollTop()

        $container.animate scrollTop: newTop

    open: ( panelName, args = __openArgs ) ->
        lastPanel = __currentPanel
        lastArgs = _.extend {}, __openArgs
        __openArgs = args
        __currentPanel = panelName

        targetPanel = Panels[ panelName ]
        unless targetPanel then return
        if @hidden() then return

        @$el.removeClass( 'hide' )
        @hideFloatPanel() unless lastPanel is __currentPanel and _.isEqual( lastArgs, args )

        @$el.prop 'class', "OEPanelRight #{panelName}"
        $('.sidebar-title').prop 'class', "sidebar-title #{panelName}"
        @renderSubPanel targetPanel, args

    floatPanelShowCount: 0

    showFloatPanel: ( dom ) ->
        @floatPanelShowCount++
        @$( '.panel-float' ).html dom if dom
        @$( '.panel-float' ).removeClass 'hidden'

        _.defer () =>
            @$( '.panel-body' ).one 'click', @__hideFloatPanel @floatPanelShowCount

    __hideFloatPanel: ( showCount ) ->
        that = @
        () -> if showCount is that.floatPanelShowCount then that.hideFloatPanel()

    hideFloatPanel: () ->
        @$( '.panel-float' ).addClass 'hidden'

    show: ->
        @$el.removeClass 'hidden'
        @

    hide: ->
        @$el.addClass 'hidden'
        $('.sidebar-title').prop 'class', 'sidebar-title'
        @

    shown: -> not @$el.hasClass( 'hidden' )
    hidden: -> not @shown()

    openResource: ( args ) -> @open 'property', args
    openState   : ( args ) -> @open 'state', args
    openCurrent : ( args ) -> @open __currentPanel, args
    openProperty: ( args ) -> @open 'property', args
    openConfig  : ( args ) ->
        @open 'config', args
        __openArgs = __defaultArgs


    __openOrHidePanel: ( e ) ->
        targetPanelName = $( e.currentTarget ).prop 'class'
        if __currentPanel is targetPanelName and @shown()
            @hide()
        else
            @show()
            @open targetPanelName, __openArgs

    __scrollTo: ( e ) ->
        targetClassName = $( e.currentTarget ).data 'scrollTo'
        @scrollTo targetClassName
