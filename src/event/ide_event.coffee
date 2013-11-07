###

###

define [ 'underscore', 'backbone' ], () ->

    ###
    #private
    event = {
        NAVIGATION_COMPLETE : 'NAVIGATION_COMPLETE'
    }

    #bind event to Backbone.Events
    _.extend event, Backbone.Events

    #public
    event
    ###

    class Event

        #module
        NAVIGATION_COMPLETE    : 'NAVIGATION_COMPLETE'
        HEADER_COMPLETE        : 'HEADER_COMPLETE'
        DASHBOARD_COMPLETE     : 'DASHBOARD_COMPLETE'
        DESIGN_COMPLETE        : 'DESIGN_COMPLETE'
        RESOURCE_COMPLETE      : 'RESOURCE_COMPLETE'
        DESIGN_SUB_COMPLETE    : 'DESIGN_SUB_COMPLETE'

        IDE_AVAILABLE          : 'IDE_AVAILABLE'

        #
        LOGOUT_IDE             : 'LOGOUT_IDE'

        #
        OPEN_DESIGN            : 'OPEN_DESIGN'
        OPEN_PROPERTY          : 'OPEN_PROPERTY'
        #OPEN_TOOLBAR          : 'OPEN_TOOLBAR'
        SAVE_DESIGN_MODULE     : 'SAVE_DESIGN_MODULE'
        RELOAD_AZ              : 'RELOAD_AZ'

        #design overlay
        SHOW_DESIGN_OVERLAY    : 'SHOW_DESIGN_OVERLAY'
        HIDE_DESIGN_OVERLAY    : 'HIDE_DESIGN_OVERLAY'

        #resource panel
        UPDATE_RESOURCE_STATE  : 'UPDATE_RESOURCE_STATE'

        #tab
        ADD_STACK_TAB          : 'ADD_STACK_TAB'
        OPEN_STACK_TAB         : 'OPEN_STACK_TAB'
        OPEN_APP_TAB           : 'OPEN_APP_TAB'
        OPEN_APP_PROCESS_TAB   : 'OPEN_APP_PROCESS_TAB'
        PROCESS_RUN_SUCCESS    : 'PROCESS_RUN_SUCCESS'
        RELOAD_STACK_TAB       : 'RELOAD_STACK_TAB'
        CLOSE_TAB              : 'CLOSE_TAB'
        #TERMINATE_APP_TAB     : 'TERMINATE_APP_TAB'

        #switch ide.html
        SWITCH_TAB             : 'SWITCH_TAB'
        SWITCH_DASHBOARD       : 'SWITCH_DASHBOARD'
        SWITCH_APP_PROCESS     : 'SWITCH_APP_PROCESS'
        SWITCH_LOADING_BAR     : 'SWITCH_LOADING_BAR'
        SWITCH_WAITING_BAR     : 'SWITCH_WAITING_BAR'
        SWITCH_MAIN            : 'SWITCH_MAIN'

        #tabbar
        UPDATE_TABBAR          : 'UPDATE_TABBAR'
        UPDATE_TAB_DATA        : 'UPDATE_TAB_DATA'
        DELETE_TAB_DATA        : 'DELETE_TAB_DATA'
        UPDATE_TAB_ICON        : 'UPDATE_TAB_ICON'
        UPDATE_REGION_THUMBNAIL: 'UPDATE_REGION_THUMBNAIL'
        UPDATE_TAB_CLOSE_STATE : 'UPDATE_TAB_CLOSE_STATE'
        UPDATE_TABBAR_TYPE    : 'UPDATE_TABBAR_TYPE'

        #status bar & ta
        UPDATE_STATUS_BAR      : 'UPDATE_STATUS_BAR'
        UPDATE_TA_MODAL        : 'UPDATE_TA_MODAL'
        UNLOAD_TA_MODAL        : 'UNLOAD_TA_MODAL'
        TA_SYNC_START          : 'TA_SYNC_START'
        TA_SYNC_FINISH          : 'TA_SYNC_FINISH'

        #result app stack region empty_region list
        RESULT_APP_LIST        : 'RESULT_APP_LIST'
        RESULT_STACK_LIST      : 'RESULT_STACK_LIST'
        RESULT_EMPTY_REGION_LIST  : 'RESULT_EMPTY_REGION_LIST'
        UPDATE_DASHBOARD       : 'UPDATE_DASHBOARD'

        #return overview region tab
        RETURN_OVERVIEW_TAB    : 'RETURN_OVERVIEW_TAB'
        RETURN_REGION_TAB      : 'RETURN_REGION_TAB'

        #appedit
        RESTORE_CANVAS         : 'RESTORE_CANVAS'
        APPEDIT_2_APP          : 'APPEDIT_2_APP'
        APPEDIT_UPDATE_ERROR   : 'APPEDIT_UPDATE_ERROR'

        # User Input Change Event
        NEED_IGW               : 'NEED_IGW'
        ENABLE_RESOURCE_ITEM   : 'ENABLE_RESOURCE_ITEM'
        DISABLE_RESOURCE_ITEM  : 'DISABLE_RESOURCE_ITEM'

        DELETE_COMPONENT       : 'DELETE_COMPONENT'

        PROPERTY_REFRESH_ENI_IP_LIST : 'PROPERTY_REFRESH_ENI_IP_LIST'

        CANVAS_CREATE_LINE     : 'CANVAS_CREATE_LINE'
        CANVAS_DELETE_OBJECT   : 'CANVAS_DELETE_OBJECT'

        #when get instance info by DescribeInstances in ASG
        CANVAS_UPDATE_APP_RESOURCE  : 'CANVAS_UPDATE_APP_RESOURCE'

        CREATE_LINE_TO_CANVAS  : 'CREATE_LINE_TO_CANVAS'
        DELETE_LINE_TO_CANVAS  : 'DELETE_LINE_TO_CANVAS'

        REDRAW_SG_LINE         : 'REDRAW_SG_LINE'
        UPDATE_SG_LINE         : 'UPDATE_SG_LINE'

        #app/stack operation
        START_APP              : 'START_APP'
        STOP_APP               : 'STOP_APP'
        TERMINATE_APP          : 'TERMINATE_APP'
        DELETE_STACK           : 'DELETE_STACK'
        DUPLICATE_STACK        : 'DUPLICATE_STACK'
        SAVE_STACK             : 'SAVE_STACK'
        UPDATE_APP_LIST        : 'UPDATE_APP_LIST'
        UPDATE_STACK_LIST      : 'UPDATE_STACK_LIST'
        UPDATE_STATUS_BAR_SAVE_TIME : 'UPDATE_STATUS_BAR_SAVE_TIME'

        #app/stack state
        #STARTED_APP           : 'STARTED_APP'
        #STOPPED_APP           : 'STOPPED_APP'
        #TERMINATED_APP        : 'TERMINATED_APP'
        #STACK_DELETE          : 'STACK_DELETE'
        UPDATE_APP_STATE       : 'UPDATE_APP_STATE'

        #canvas event save stack/app by ctrl+s
        CANVAS_SAVE            : 'CANVAS_SAVE'

        #navigation to dashboard - region
        NAVIGATION_TO_DASHBOARD_REGION : 'NAVIGATION_TO_DASHBOARD_REGION'

        #websocket meteor collection
        RECONNECT_WEBSOCKET            : 'RECONNECT_WEBSOCKET'
        WS_COLLECTION_READY_REQUEST    : 'WS_COLLECTION_READY_REQUEST'
        UPDATE_REQUEST_ITEM            : 'UPDATE_REQUEST_ITEM'

        #quickstart data ready
        RESOURCE_QUICKSTART_READY      : 'RESOURCE_QUICKSTART_READY'

        #trigger property view's undelegateEvents
        UNDELEGATE_PROPERTY_DOM_EVENTS : 'UNDELEGATE_PROPERTY_DOM_EVENTS'

        #app ready and generate thumbnail
        SAVE_APP_THUMBNAIL     : 'SAVE_APP_THUMBNAIL'

        #update process
        UPDATE_PROCESS         : 'UPDATE_PROCESS'

        #update header
        UPDATE_HEADER          : 'UPDATE_HEADER'

        #refresh region resource
        UPDATE_REGION_RESOURCE : 'UPDATE_REGION_RESOURCE'

        #updated aws credential
        UPDATE_AWS_CREDENTIAL  : 'UPDATE_AWS_CREDENTIAL'

        #demo account
        ACCOUNT_DEMONSTRATE    : 'ACCOUNT_DEMONSTRATE'

        #update app resource
        UPDATE_APP_RESOURCE    : 'UPDATE_APP_RESOURCE'

        constructor : ->
            _.extend this, Backbone.Events

        onListen : ( type ,callback ) ->
            this.once type, callback

        onLongListen : ( type ,callback ) ->
            this.on type, callback

        offListen : ( type, function_name ) ->
            if function_name then this.off type, function_name else this.off type

    event = new Event()

    event
