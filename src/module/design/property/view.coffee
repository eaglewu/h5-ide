#############################
#  View(UI logic) for design/property
#############################

define [ 'event',
         './base/main',
         'constant',
         'text!./template.html'
         'Design'
         'backbone', 'jquery', 'handlebars'
], ( ide_event, PropertyBaseModule, CONST, template, Design ) ->

    PropertyView = Backbone.View.extend {

        propertyHeadStateMap : {}

        events:
            'click': 'test'

        # store current open tab [ property|state ]
        currentTab: 'property'

        # store current uid
        uid: null

        # store lastest render component id
        lastUid: null

        initialize : ->

            ##########################
            # Handlebar helper
            ##########################

            Handlebars.registerHelper 'emptyStr', ( v1 ) ->
                if v1 in [ '', undefined, null ]
                    '-'
                else
                    new Handlebars.SafeString v1


            Handlebars.registerHelper 'timeStr', ( v1 ) ->
                d = new Date( v1 )

                if isNaN( Date.parse( v1 ) ) or not d.toLocaleDateString or not d.toTimeString
                    if v1
                        return new Handlebars.SafeString v1
                    else
                        return '-'

                d = new Date( v1 )
                d.toLocaleDateString() + " " + d.toTimeString()

            Handlebars.registerHelper "plusone", ( v1 ) ->
                v1 = parseInt( v1, 10 )
                if isNaN( v1 )
                    return v1
                else
                    return '' + (v1 + 1)

            #listen
            $( document.body )
                .on( 'click', '#hide-property-panel', this.togglePropertyPanel )
                .on( 'click', '.option-group-head', _.bind( this.toggleOption, this ))
                .on( 'click', '#hide-second-panel', _.bind( this.hideSecondPanel, this ))
                .on( 'click', '#btn-switch-state, #btn-switch-property', _.bind( this.switchTab, this ) )

            ###
            # Move from render to initialize
            ###
            $( "body" ).on("click", ".click-select", this.selectText )

            null

        switchTab: ( event ) ->
            target = event.currentTarget
            if target.id is 'btn-switch-state'
                if @currentTab isnt 'state'
                    @renderState @lastUid, true
            else
                if @currentTab is 'state'
                    @renderProperty @lastUid

        __hideProperty: () ->
            $( '#property-panel .sub-property' ).hide()

        __hideState: () ->
            $( '#property-panel .sub-stateeditor' ).hide()

        __showProperty: () ->
            $( '#property-panel .sub-property' ).show()

        __showState: () ->
            $( '#property-panel .sub-stateeditor' ).show()

        __hasProperty: () ->
            $( '#property-panel .sub-property' ).children() > 0

        __hasState: () ->
            $( '#property-panel .sub-stateeditor' ).children() > 0

        __hideResourcePanel: () ->
            hideButton = $ '#hide-resource-panel'
            if hideButton.hasClass 'icon-caret-left'
                hideButton.click()

        renderProperty: ( uid, type, force ) ->
            @__hideState()
            $( '#property-panel' ).removeClass('state').removeClass('state-wide')
            if not type and uid
                comp = Design.instance().component uid
                type = comp.type if comp

            @__initProperty type, uid, force


            @currentTab = 'property'
            @__showProperty()
            @lastUid = uid
            @

        renderStateCount: ( component ) ->
            if component
                count = component.get( 'state' ) and component.get( 'state' ).length or 0
                $( '#btn-switch-state b' ).text "(#{count})"

        renderState: ( uid, force ) ->

            @__hideProperty()
            @__hideResourcePanel()
            $( '#property-panel' ).addClass 'state'

            @lastUid = uid
            @currentTab = 'state'

            if @lastUid is uid and @__hasProperty()

            else

                if not uid
                    uid = Design.instance().canvas.selectedNode[ 0 ]

                if uid
                    comp = Design.instance().component uid
                    if comp
                        type = comp.type
                        if not _.contains [ CONST.RESTYPE.LC, CONST.RESTYPE.INSTANCE ], type
                            @renderProperty uid
                            return
                        else if _.contains [ CONST.RESTYPE.LC ], type
                            if Design.instance().modeIsApp()
                                currentStackState = Design.instance().get('state')
                                if currentStackState is 'Stopped'
                                    ide_event.trigger ide_event.OPEN_STATE_EDITOR, uid
                                    @__showState()
                                return

                            ide_event.trigger ide_event.OPEN_STATE_EDITOR, uid
                            @__showState()
                            return

                    if Design.instance().modeIsApp()

                        # for asg or isg

                        resId = $('#asgList-wrap .asgList-item.selected').attr('id')

                        if resId

                            compObj = MC.aws.aws.getCompByResIdForState(resId)
                            if compObj and compObj.parent and compObj.parent.type is 'AWS.AutoScaling.Group'
                                lcComp = compObj.parent.get('lc')
                                if lcComp and lcComp.id
                                    ide_event.trigger ide_event.OPEN_STATE_EDITOR, lcComp.id, resId
                                    @__showState()
                                    return

                        resId = $('#instanceList-wrap .instanceList-item.selected').data('id')

                        if resId

                            compObj = MC.aws.aws.getCompByResIdForState(resId)
                            if compObj and compObj.parent and compObj.parent.type is 'AWS.EC2.Instance'
                                if compObj.parent and compObj.parent.id
                                    ide_event.trigger ide_event.OPEN_STATE_EDITOR, compObj.parent.id, resId
                                    @__showState()
                                    return

            ide_event.trigger ide_event.OPEN_STATE_EDITOR, uid
            @__showState()
            if force then @forceShow()
            @

        __initProperty: ( type, uid, force ) ->
            @render()
            @load()

            # Load property
            # Format `type` so that PropertyBaseModule knows about it.
            # Here, type can be : ( according to the previous version of property/main )
            # - "component_asg_volume"   => Volume Property
            # - "component_asg_instance" => Instance main
            # - "component"
            # - "stack"

            design    = Design.instance()

            # If type is "component", type should be changed to ResourceModel's type
            if uid
                component = design.component( uid )
                if component and component.type is type and design.modeIsApp() and component.get( 'appId' ) and not component.hasAppResource()
                    type = 'Missing_Resource'
            else
                type = "Stack"


            # Get current model of design
            if design.modeIsApp() or design.modeIsAppView()
                tab_type = PropertyBaseModule.TYPE.App

            else if design.modeIsStack()
                tab_type = PropertyBaseModule.TYPE.Stack

            else
                # If component has associated aws resource (a.k.a has appId), it's AppEdit mode ( Partially Editable )
                # Otherwise, it's Stack mode ( Fully Editable )
                if not component or component.get("appId")
                    tab_type = PropertyBaseModule.TYPE.AppEdit
                else
                    tab_type = PropertyBaseModule.TYPE.Stack


            # Tell `PropertyBaseModule` to load corresponding property panel.
            try
                PropertyBaseModule.load type, uid, tab_type
                @afterLoad()

                if force then @forceShow()
                ### env:prod ###
            catch error
                console.error error
                ### env:prod:end ###
            finally

            null

        render     : () ->
            # Blur any focused input
            # Better than $("input:focus")
            $(document.activeElement).filter("input").blur()

            $( '#property-panel .sub-property' )
                .html( template )
                .removeClass( 'state state-wide' )
            @

        restore: ( snapshot ) ->
            @currentTab = snapshot.propertyTab
            @uid = snapshot.activeModuleId
            null

        getCurrentCompUid : () ->
            event = {}
            @trigger "GET_CURRENT_UID", event
            event.uid


        togglePropertyPanel : ( event ) ->
            console.log 'togglePropertyPanel'
            $( '#property-panel' ).toggleClass( 'hidden' ).toggleClass( 'transition', true )
            $( '#hide-property-panel' ).toggleClass 'icon-caret-left'
            $( '#hide-property-panel' ).toggleClass 'icon-caret-right'
            $( '#status-bar-modal' ).toggleClass 'toggle'
            false

        toggleOption : ( event ) ->
            $toggle = $(event.currentTarget)

            if $toggle.is("button") or $toggle.is("a")
                return

            hide    = $toggle.hasClass("expand")
            $target = $toggle.next()

            if hide
                $target.css("display", "block").slideUp(200)
            else
                $target.slideDown(200)

            $toggle.toggleClass("expand")

            stackId = Design.instance().get("id")
            if !@propertyHeadStateMap[stackId]
                @propertyHeadStateMap[stackId] = {}

            if $('#property-second-panel').is(':hidden')
                # added by song ######################################
                # record head state
                headElemAry = $('#property-panel').find('.option-group-head')
                headExpandStateAry = []
                headCompUID = @getCurrentCompUid()
                if !headCompUID then headCompUID = stackId

                _.each headElemAry, (headElem) ->
                    $headElem = $(headElem)
                    expandState = $headElem.hasClass('expand')
                    headExpandStateAry.push(expandState)
                    null

                if headCompUID
                    stackMap = @propertyHeadStateMap[stackId]
                    stackMap[ headCompUID ] = headExpandStateAry

                    component = Design.instance().component( headCompUID )
                    if component
                        stackMap[ component.type ] = headExpandStateAry

                # added by song ######################################

            return false

        optionToggle : ( event ) ->
            $target = $(this)
            $toggle = $target.prev()
            if $toggle.hasClass "expand"
                $target.removeClass("transition").css({
                    "max-height" : "100000px"
                    "overflow"   : "visible"
                })

        # This method is used to show the panel immediately if the panel is hidden.
        forceShow : () ->
            $( '#property-panel' ).removeClass 'hidden transition'
            $( '#hide-property-panel' ).removeClass( 'icon-caret-left' ).addClass( 'icon-caret-right' )
            null

        showSecondPanel : () ->
            $("#hide-second-panel").data("tooltip", "Back to " + $("#property-title").text())

            $("#property-second-panel").show().animate({left:"0%"}, 200)

            $("#property-first-panel").animate {left:"-30%"}, 200, ()->
                $("#property-first-panel").hide()

        immShowSecondPanel : ()->
            $("#hide-second-panel").data("tooltip", "Back to " + $("#property-title").text())

            $("#property-second-panel").show().css({left:"0%"})

            $("#property-first-panel").css({left:"-30%",display:"none"})
            null

        hideSecondPanel : () ->
            $panel = $("#property-second-panel")
            $panel.animate {left:"100%"}, 200, ()->
                $("#property-second-panel").hide()
            $("#property-first-panel").show().animate {left:"0%"}, 200

            this.trigger "HIDE_SUBPANEL"
            false

        immHideSecondPanel : () ->
            $("#property-second-panel").css({
                display : "none"
                left    : "100%"
            }).children(".scroll-wrap").children(".property-content").empty()

            $("#property-first-panel").css {
                display : "block"
                left    : "0px"
            }
            null

        load : () ->
            # 1. Force to lost focus, so that value can be saved. Better than $("input:focus").
            $( document.activeElement ).filter( 'input, textarea' ).blur()

            # 2. Hide second panel if there's any
            @immHideSecondPanel()
            null

        afterLoad : ()->
            stackId = MC.canvas_data.id
            if $('#property-second-panel').is(':hidden')
                # added by song ######################################
                # restore head state
                headCompUID = @getCurrentCompUid()
                if !headCompUID then headCompUID = stackId

                headExpandStateAry = null
                stackMap = @propertyHeadStateMap[stackId]
                if stackMap
                    headExpandStateAry = stackMap[headCompUID]
                    component = Design.instance().component( headCompUID )
                    if not headExpandStateAry and component
                        headExpandStateAry = stackMap[ component.type ]

                if headExpandStateAry
                    headElemAry = $('#property-panel').find('.option-group-head')
                    _.each headElemAry, (headElem, i) ->
                        $headElem = $(headElem)
                        if headExpandStateAry[i]
                            $headElem.addClass('expand')
                        else
                            $headElem.removeClass('expand')
                        null

                # clear invalid state in map
                stateMap = @propertyHeadStateMap[stackId]
                if stateMap
                    for compUID, stateAry of stateMap
                        if Design.instance().component( compUID )
                            continue
                        if compUID is stackId or compUID.indexOf( 'i-' ) is 0
                            continue
                        delete stateMap[ compUID ]
                # added by song ######################################
            null

        showPropertyPanel : ->
            console.log 'showPropertyPanel'
            $( '#hide-property-panel' ).trigger 'click' if $( '#hide-property-panel' ).hasClass 'icon-caret-left'


        # This is use to select text when clicking on the text.
        selectText : ( event )->
            try
                range = document.body.createTextRange()
                range.moveToElementText event.currentTarget
                range.select()
                console.warn "Select text by document.body.createTextRange"
            catch e
                if window.getSelection
                    range = document.createRange()
                    range.selectNode event.currentTarget
                    window.getSelection().addRange range
                    console.warn "Select text by document.createRange"

            return false

    }

    return PropertyView
