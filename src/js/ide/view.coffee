#############################
#  View(UI logic) for Main
#############################

define [ 'event',
         'i18n!nls/lang.js',
         'forge_handle',
         'UI.notification',
         'backbone', 'jquery', 'handlebars', 'underscore' ], ( ide_event, lang, forge_handle ) ->

    MainView = Backbone.View.extend {

        el       : $ '#main'

        delay    : null

        initialize : ->
            $( window ).on 'beforeunload', @_beforeunloadEvent

        showMain : ->
            console.log 'showMain'
            #
            @toggleWaiting() if $( '#waiting-bar-wrapper' ).hasClass 'waiting-bar'
            #
            clearTimeout @delay if @delay
            #
            MC.data.loading_wrapper_html = $( '#loading-bar-wrapper' ).html() if !MC.data.loading_wrapper_html
            #
            return if $( '#loading-bar-wrapper' ).html().trim() is ''
            #
            target = $('#loading-bar-wrapper').find( 'div' )
            target.fadeOut 'normal', () ->
                target.remove()
                $( '#wrapper' ).removeClass 'main-content'

        showLoading : ( tab_id, is_transparent ) ->
            console.log 'showLoading, tab_id = ' + tab_id + ' , is_transparent = ' + is_transparent
            $( '#loading-bar-wrapper' ).html if !is_transparent then MC.data.loading_wrapper_html else MC.template.loadingTransparent()
            #
            @delay = setTimeout () ->
                console.log 'setTimeout close loading'
                if $( '#loading-bar-wrapper' ).html().trim() isnt ''
                    ide_event.trigger ide_event.SWITCH_MAIN
                    ide_event.trigger ide_event.CLOSE_TAB, null, tab_id if tab_id
                    notification 'error', lang.ide.IDE_MSG_ERR_OPEN_TAB, true
            , 1000 * 30
            #
            @_hideStatubar()
            null

        toggleWaiting : () ->
            console.log 'toggleWaiting'
            $( '#waiting-bar-wrapper' ).toggleClass 'waiting-bar'
            #
            @_hideStatubar()

        showDashbaordTab : () ->
            console.log 'showDashbaordTab'
            console.log 'MC.data.dashboard_type = ' + MC.data.dashboard_type
            if MC.data.dashboard_type is 'OVERVIEW_TAB' then this.showOverviewTab() else this.showRegionTab()

        showOverviewTab : () ->
            console.log 'showOverviewTab'
            #
            $( '#tab-content-dashboard' ).addClass  'active'
            $( '#tab-content-region' ).removeClass  'active'
            $( '#tab-content-design' ).removeClass  'active'
            $( '#tab-content-process' ).removeClass 'active'
            #

        showRegionTab : () ->
            console.log 'showRegionTab'
            #
            $( '#tab-content-region' ).addClass       'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-design' ).removeClass    'active'
            $( '#tab-content-process' ).removeClass   'active'
            #

        showTab : () ->
            console.log 'showTab'
            #
            $( '#tab-content-design' ).addClass       'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-region' ).removeClass    'active'
            $( '#tab-content-process' ).removeClass   'active'
            #

        showProcessTab : () ->
            console.log 'showProcessTab'
            #
            $( '#tab-content-process' ).addClass      'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-region' ).removeClass    'active'
            $( '#tab-content-design' ).removeClass    'active'
            #

        disconnectedMessage : ( type ) ->
            console.log 'disconnectedMessage'
            #
            return if $( '#disconnected-notification-wrapper' ).html() and type is 'show'
            #
            if type is 'show'
                $( '#disconnected-notification-wrapper' ).html MC.template.disconnectedNotification()
            else
                $( '#disconnected-notification-wrapper' ).empty()

        _beforeunloadEvent : ->


            return if MC.data.current_tab_id in [ 'dashboard', undefined ]
            return if !forge_handle.cookie.getCookieByName( 'userid' )
            return if MC.data.current_tab_id.split( '-' )[0] in [ 'app', 'process' ]

            if _.isEqual( MC.canvas_data, MC.data.origin_canvas_data )
                return undefined
            else
                return lang.ide.BEFOREUNLOAD_MESSAGE

        _hideStatubar : ->
            console.log '_hideStatubar'
            #
            $( '#status-bar-modal' ).empty() if $.trim( $( '#status-bar-modal' ).html() )
    }

    view = new MainView()

    return view
