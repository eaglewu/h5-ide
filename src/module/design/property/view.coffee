#############################
#  View(UI logic) for design/property
#############################

define [ 'event',
         'text!./template.html'
         'backbone', 'jquery', 'handlebars'
], ( ide_event, template ) ->

    template = Handlebars.compile template

    PropertyView = Backbone.View.extend {

        el         : '#property-panel'

        back_dom   : 'none'

        initialize : ->

            ##########################
            # Handlebar helper
            ##########################

            Handlebars.registerHelper 'ifCond', ( v1, v2, options ) ->
                return options.fn this if v1 is v2
                return options.inverse this

            Handlebars.registerHelper 'emptyStr', ( v1 ) ->
                if v1 then new Handlebars.SafeString v1 else '-'

            Handlebars.registerHelper 'timeStr', ( v1 ) ->
                d = new Date( v1 )

                if isNaN( Date.parse( v1 ) ) or not d.toLocaleDateString or not d.toTimeString
                    if v1
                        return new Handlebars.SafeString v1
                    else
                        return '-'

                d = new Date( v1 )
                d.toLocaleDateString() + " " + d.toTimeString()

            #listen
            $( document.body ).on( 'click',           '#hide-property-panel', this.togglePropertyPanel                )
                              .on( 'click',           '.option-group-head',   this.toggleOption                       )
                              .on( 'click',           '#hide-second-panel',   _.bind( this.hideSecondPanel, this     ))
                              .on( 'DOMNodeInserted', '.property-wrap',       this, _.debounce( this.domChange, 0, false ))

        render     : ( template ) ->
            console.log 'property render'
            this.$el.html template
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            console.log 're-property render'
            if $.trim( this.$el.html() ) is 'loading...' then $( '#property-panel' ).html template

        togglePropertyPanel : ( event ) ->
            console.log 'togglePropertyPanel'
            $( '#property-panel' ).toggleClass( 'hiden' ).toggleClass( 'transition', true )
            $( '#canvas-panel' ).toggleClass 'right-hiden'
            $( '#hide-property-panel' ).toggleClass 'icon-caret-left'
            $( '#hide-property-panel' ).toggleClass 'icon-caret-right'
            false

        refresh : ->
            console.log 'refresh'
            selectbox.init()
            temp_view.ready()

        updateHtml : ( back_dom ) ->
            console.log 'update property html'
            $( '#property-panel' ).html back_dom
            null

        toggleOption : ( event ) ->
            $target = $(event.target)

            if $target.is("button") or $target.is("a")
                return

            $toggle = $(this)
            hide    = $toggle.hasClass("expand")
            $target = $toggle.next()

            if hide
                $target.css("display", "block").slideUp(200)
            else
                $target.slideDown(200)

            $toggle.toggleClass("expand")

            stackId = MC.canvas_data.id
            if !MC.data.propertyHeadStateMap[stackId]
                MC.data.propertyHeadStateMap[stackId] = {}

            if $('#property-second-panel').is(':hidden')
                # added by song ######################################
                # record head state
                headElemAry = $('#property-panel').find('.option-group-head')
                headExpandStateAry = []
                headCompUID = $('#property-panel').attr('component-uid')
                if !headCompUID then headCompUID = stackId

                _.each headElemAry, (headElem) ->
                    $headElem = $(headElem)
                    expandState = $headElem.hasClass('expand')
                    headExpandStateAry.push(expandState)
                    null

                if headCompUID
                    MC.data.propertyHeadStateMap[stackId][headCompUID] = headExpandStateAry

                console.log(headExpandStateAry)
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

        setTitle : ( title ) ->
            $("#property-title").html( title )

        showSecondPanel : ( data ) ->
            $("#property-second-title").html( data.title ).attr( "data-id", data.id )
            $("#hide-second-panel").data("tooltip", "Back to " + $("#property-title").text())

            $("#property-second-panel").show().animate({left:"0%"}, 200).find(".property-content").html( data.dom )
            $("#property-first-panel").animate {left:"-30%"}, 200, ()->
                $("#property-first-panel").hide()

        hideSecondPanel : () ->
            $panel = $("#property-second-panel")
            $panel.animate {left:"100%"}, 200, ()->
                $("#property-second-panel").hide()
            $("#property-first-panel").show().animate {left:"0%"}, 200

            this.trigger "HIDE_SUBPANEL", $("#property-second-title").attr( "data-id" )
            false

        immHideSecondPanel : () ->
            $("#property-second-panel").css {
                display : "none"
                left    : "100%"
            }

            $("#property-first-panel").css {
                display : "block"
                left    : "0px"
            }
            null

        domChange : ( event ) ->
            console.log 'property:listen DOMNodeInserted'
            #console.log event.target
            #console.log event.data.back_dom

            #
            back_dom = event.data.back_dom
            #
            # return if back_dom is 'none'
            ###
            temp = $( event.data.back_dom ).find( '#property-second-panel' ).find( '.property-content' ).html()
            if temp isnt ''
                event.data.back_dom = 'none'
                $( '.property-content' ).html temp
            ###

            stackId = MC.canvas_data.id
            if $('#property-second-panel').is(':hidden')
                # added by song ######################################
                # restore head state
                headCompUID = $('#property-panel').attr('component-uid')
                if !headCompUID then headCompUID = stackId

                headExpandStateAry = null
                if MC.data.propertyHeadStateMap[stackId]
                    headExpandStateAry = MC.data.propertyHeadStateMap[stackId][headCompUID]

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
                if MC.data.propertyHeadStateMap[stackId]
                    _.each MC.data.propertyHeadStateMap[stackId], (stateAry, compUID) ->
                        if !MC.canvas_data.component[compUID] and compUID isnt stackId and compUID.indexOf('i-') isnt 0
                            delete MC.data.propertyHeadStateMap[stackId][compUID]
                        null
                # added by song ######################################


            event.data.back_dom = 'none'
            # $( '#property-panel' ).html back_dom

            null
    }

    return PropertyView
