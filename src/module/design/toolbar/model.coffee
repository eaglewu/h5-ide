#############################
#  View Mode for design/toolbar module
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'stack_service', 'stack_model', 'app_model', 'constant' ], (MC, Backbone, $, _, ide_event, stack_service, stack_model, app_model, constant) ->

    #item state map
    # {app_id:{'name':name, 'state':state, 'is_running':true|false, 'is_pending':true|false, 'is_use_ami':true|false},
    #  stack_id:{'name':name, 'is_run':true|false, 'is_duplicate':true|false, 'is_delete':true|false}}
    item_state_map  = {}

    # save data for thumbnail
    process_data_map   = {}  # {<'process-' + region + '-' + name'->:<data>}}

    # mapping request id with tab id
    req_map         = {}  # {req_id : {'flag':flag, 'id':id, 'name':name}}

    # flag of on tab or dashboard
    is_tab = true

    #websocket
    ws = MC.data.websocket

    #private
    ToolbarModel = Backbone.Model.extend {

        defaults :
            'item_flags'    : null

        initialize : ->

            me = this

            #####listen STACK_SAVE_RETURN
            me.on 'STACK_SAVE_RETURN', (result) ->
                console.log 'STACK_SAVE_RETURN'

                region  = result.param[3]
                data    = result.param[4]
                id      = data.id

                name = data.name

                if !result.is_error

                    console.log 'save stack successfully'

                    # track
                    # analytics.track "Saved Stack",
                    #     stack_name: data.name,
                    #     stack_region: data.region,
                    #     stack_id: data.id

                    #update initial data
                    MC.canvas_property.original_json = JSON.stringify( data )

                    ide_event.trigger ide_event.UPDATE_STACK_LIST, 'SAVE_STACK', [id]

                    #update key
                    key = result.resolved_data.key
                    if key isnt MC.canvas_data.key
                        MC.canvas_data.key = key
                        data.key = key

                    #call save png
                    _.delay () ->
                        me.savePNG true, data
                    , 500

                    #set toolbar flag
                    me.setFlag id, 'SAVE_STACK', name

                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'SAVE_STACK', name

                    ide_event.trigger ide_event.UPDATE_STATUS_BAR_SAVE_TIME

                    id
                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'SAVE_STACK', name

                    null

            #####listen STACK_CREATE_RETURN
            me.on 'STACK_CREATE_RETURN', (result) ->
                console.log 'STACK_CREATE_RETURN'

                region  = result.param[3]
                data    = result.param[4]
                id      = data.id

                name    = data.name

                if !result.is_error
                    console.log 'create stack successfully'

                    new_id = result.resolved_data.id
                    key = result.resolved_data.key

                    # track
                    # analytics.track "Saved Stack",
                    #     stack_name: data.name,
                    #     stack_region: data.region,
                    #     stack_id: new_id

                    #temp
                    MC.canvas_data.id = new_id
                    MC.canvas_data.key = key
                    #
                    MC.data.origin_canvas_data = $.extend true, {}, MC.canvas_data

                    #update initial data
                    MC.canvas_property.original_json = JSON.stringify( data )

                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'CREATE_STACK', name

                    ide_event.trigger ide_event.UPDATE_STACK_LIST, 'NEW_STACK', [new_id]

                    ide_event.trigger ide_event.UPDATE_TABBAR, new_id, name + ' - stack'

                    ide_event.trigger ide_event.UPDATE_STATUS_BAR_SAVE_TIME

                    MC.data.stack_list[region].push {'id':new_id, 'name':name}

                    #call save png
                    _.delay () ->
                        me.savePNG true, MC.canvas_data
                    , 500

                    #set toolbar flag
                    me.setFlag id, 'CREATE_STACK', MC.canvas_data

                    new_id

                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'CREATE_STACK', name

                    null

            #####listen STACK_SAVE__AS_RETURN
            me.on 'STACK_SAVE__AS_RETURN', (result) ->
                console.log 'STACK_SAVE__AS_RETURN'

                region      = result.param[3]
                id          = result.param[4]
                new_name    = result.param[5]
                name        = result.param[6]

                if !result.is_error
                    console.log 'save as stack successfully'

                    #update stack name list
                    new_id = result.resolved_data.id
                    MC.data.stack_list[region].push {'id':new_id, 'name':new_name}

                    #save png
                    key = result.resolved_data.key
                    ide_event.trigger ide_event.UPDATE_REGION_THUMBNAIL, key, new_id

                    #trigger event
                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'DUPLICATE_STACK', name
                    ide_event.trigger ide_event.UPDATE_STACK_LIST, 'DUPLICATE_STACK', [new_id]

                    # open the duplicated stack when using toolbar
                    # if is_tab
                    #     ide_event.trigger ide_event.OPEN_STACK_TAB, new_name, region, new_id

                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'DUPLICATE_STACK', name

            #####listen STACK_REMOVE_RETURN
            me.on 'STACK_REMOVE_RETURN', (result) ->
                console.log 'STACK_REMOVE_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                if !result.is_error
                    console.log 'send delete stack successful message'

                    #update stack name list
                    if MC.aws.aws.checkStackName(id, name)
                        for item in MC.data.stack_list[region]
                            if item.id is id and item.name is name
                                MC.data.stack_list[region].splice MC.data.stack_list[region].indexOf(item), 1
                                break

                    #trigger event
                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'REMOVE_STACK', name
                    ide_event.trigger ide_event.UPDATE_STACK_LIST, 'REMOVE_STACK', [id]
                    ide_event.trigger ide_event.CLOSE_TAB, name, id

                    me.setFlag id, 'DELETE_STACK'

                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'REMOVE_STACK', name

            #####listen STACK_RUN_RETURN
            me.on 'STACK_RUN_RETURN', (result) ->
                console.log 'STACK_RUN_RETURN'

                region      = result.param[3]
                id          = result.param[4]
                app_name    = result.param[5]

                ide_event.trigger ide_event.OPEN_APP_PROCESS_TAB, id, app_name, region, result

                # handle request
                me.handleRequest result, 'RUN_STACK', region, id, app_name

                # track
                # analytics.track "Launched Stack",
                #     stack_id: id,
                #     stack_region: region,
                #     stack_app_name: app_name

            #####listen APP_START_RETURN
            me.on 'APP_START_RETURN', (result) ->
                console.log 'APP_START_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                me.handleRequest result, 'START_APP', region, id, name

                # track
                # analytics.track "Started App",
                #     app_id: id,
                #     app_region: region,
                #     app_name: name

            #####listen APP_STOP_RETURN
            me.on 'APP_STOP_RETURN', (result) ->
                console.log 'APP_STOP_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                me.handleRequest result, 'STOP_APP', region, id, name

                # track
                # analytics.track "Stopped App",
                #     app_id: id,
                #     app_region: region,
                #     app_name: name

            #####listen APP_TERMINATE_RETURN
            me.on 'APP_TERMINATE_RETURN', (result) ->
                console.log 'APP_TERMINATE_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]
                flag    = result.param[6]

                if not flag or flag == 0    # send request to terminate the app
                    me.handleRequest result, 'TERMINATE_APP', region, id, name

                else    # force terminating the app
                    if !result.is_error      # success
                        me.setFlag id, 'TERMINATED_APP', region
                        ide_event.trigger ide_event.TERMINATED_APP, name, id

                        # remove the app name from app_list
                        if name in MC.data.app_list[region]
                            MC.data.app_list[region].splice MC.data.app_list[region].indexOf(name), 1

                    else            # failed
                        me.setFlag id, 'STOPPED_APP', region

                    # update resource
                    ide_event.trigger ide_event.UPDATE_REGION_RESOURCE, region

                # track
                # analytics.track "Terminated App",
                #     app_id: id,
                #     app_region: region,
                #     app_name: name

            #####listen APP_UPDATE_RETURN
            me.on 'APP_UPDATE_RETURN', (result) ->
                console.log 'APP_UPDATE_RETURN'

                region  = result.param[3]
                id      = result.param[5]

                name    = item_state_map[id].name

                me.handleRequest result, 'SAVE_APP', region, id, name

                #
                #MC.canvas_data             = $.extend true, {}, result.param[4]
                #MC.data.origin_canvas_data = $.extend true, {}, result.param[4]
                null

            #####listen APP_GETKEY_RETURN
            me.on 'APP_GET_KEY_RETURN', (result) ->
                console.log 'APP_GET_KEY_RETURN'

                region = result.param[3]
                app_id = result.param[4]
                app_name = result.param[5]

                idx = 'process-' + region + '-' + app_name
                data = $.extend(true, {}, process_data_map[idx])
                delete process_data_map[idx]

                if !result.is_error
                    # trigger toolbar save png event
                    console.log 'app key:' + result.resolved_data

                    data.key = result.resolved_data
                    data.id  = app_id

                    me.savePNG true, data

        setFlag : (id, flag, value) ->
            me = this

            if flag is 'NEW_STACK'
                item_state_map[id] = {'name':MC.canvas_data.name, 'is_run':true, 'is_duplicate':false, 'is_delete':false, 'is_zoomin':false, 'is_zoomout':true}
                is_tab = true

            else if flag is 'OPEN_STACK'
                id = id.resolved_data[0].id
                item_state_map[id] = {'name':MC.canvas_data.name, 'is_run':true, 'is_duplicate':true, 'is_delete':true, 'is_zoomin':false, 'is_zoomout':true}
                is_tab = true

            else if flag is 'SAVE_STACK'
                item_state_map[id].name         = value
                item_state_map[id].is_run       = true
                item_state_map[id].is_duplicate = true
                item_state_map[id].is_delete    = true

            else if flag is 'CREATE_STACK'
                item_state_map[value.id] = {'name':value.name, 'is_run':true, 'is_duplicate':true, 'is_delete':true, 'is_zoomin':item_state_map[id].is_zoomin, 'is_zoomout':item_state_map[id].is_zoomout}

                delete item_state_map[id]

                id = value.id

            else if flag is 'DELETE_STACK'
                delete item_state_map[id]
                return

            else if flag is 'ZOOMIN_STACK'
                item_state_map[id].is_zoomin    = value
                item_state_map[id].is_zoomout   = true

            else if flag is 'ZOOMOUT_STACK'
                item_state_map[id].is_zoomout   = value
                item_state_map[id].is_zoomin    = true

            else if flag is 'OPEN_APP'
                is_running = false
                is_pending = false

                if MC.canvas_data.state == constant.APP_STATE.APP_STATE_STOPPED
                    is_running = false
                else if MC.canvas_data.state == constant.APP_STATE.APP_STATE_RUNNING
                    is_running = true
                else
                    is_running = false
                    is_pending = true

                id = id.resolved_data[0].id
                item_state_map[id] = { 'name':MC.canvas_data.name, 'state':MC.canvas_data.state, 'is_running':is_running, 'is_pending':is_pending, 'is_zoomin':false, 'is_zoomout':true, 'is_app_updating':false, 'has_instance_store_ami':me.isInstanceStore(MC.canvas_data) }

                is_tab = true

            else if flag is 'RUNNING_APP'
                if id of item_state_map
                    item_state_map[id].state = constant.APP_STATE.APP_STATE_RUNNING
                    item_state_map[id].is_running = true
                    item_state_map[id].is_pending = false

                region = value
                ide_event.trigger ide_event.UPDATE_TAB_ICON, 'running', id

                # update app resource
                ide_event.trigger ide_event.UPDATE_APP_RESOURCE, region, id
                #app_model.resource { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  id

            else if flag is 'STOPPED_APP'
                if id of item_state_map
                    item_state_map[id].state = constant.APP_STATE.APP_STATE_STOPPED
                    item_state_map[id].is_running = false
                    item_state_map[id].is_pending = false

                region = value
                ide_event.trigger ide_event.UPDATE_TAB_ICON, 'stopped', id

                # update app resource
                ide_event.trigger ide_event.UPDATE_APP_RESOURCE, region, id
                #app_model.resource { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  id

            else if flag is 'TERMINATED_APP'
                (delete item_state_map[id]) if id of item_state_map

                # update app resource
                ide_event.trigger ide_event.UPDATE_APP_RESOURCE, value

                return

            else if flag is 'PENDING_APP'
                if id of item_state_map
                    item_state_map[id].is_pending = true

                region = value
                ide_event.trigger ide_event.UPDATE_TAB_ICON, 'pending', id

                # update app resource
                #app_model.resource { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  id

            else if flag is 'UPDATE_APP'
                if id of item_state_map
                    item_state_map[id].is_app_updating = value

            if id == MC.canvas_data.id and is_tab
                me.set 'item_flags', item_state_map[id]

                if id.indexOf('app-') == 0
                    me.trigger 'UPDATE_TOOLBAR', 'app'
                else
                    me.trigger 'UPDATE_TOOLBAR', 'stack'

        setTabFlag : (flag) ->
            me = this

            is_tab = flag

            if flag
                id = MC.canvas_data.id

                rid = k for k,v of item_state_map when id == k

                if rid
                    me.set 'item_flags', item_state_map[id]

                    if id.indexOf('app-') == 0
                        me.trigger 'UPDATE_TOOLBAR', 'app'
                    else
                        me.trigger 'UPDATE_TOOLBAR', 'stack'

            null

        #save stack
        saveStack : (data) ->
            me = this

            region  = data.region
            id      = data.id
            name    = data.name

            #instance store ami check
            #data.has_instance_store_ami = me.isInstanceStore data

            #check whether data change
            ori_data = MC.canvas_property.original_json
            new_data = JSON.stringify(data)
            if ori_data == new_data
                me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'SAVE_STACK', name
                return

            if id.indexOf('stack-', 0) == 0   #save
                stack_model.save_stack { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, data

            else    #new
                stack_model.create { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, data

        #duplicate
        duplicateStack : (region, id, new_name, name) ->
            me = this

            stack_model.save_as { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, new_name, name

        #delete
        deleteStack : (region, id, name) ->
            me = this

            stack_model.remove { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

        #run
        runStack : (app_name, data) ->
            me = this

            id      = data.id
            region  = data.region

            #src, username, session_id, region_name, stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null
            if MC.aws.aws.checkDefaultVPC()
                stack_model.run { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, app_name, null, MC.aws.vpc.generateComponentForDefaultVPC()

            else
                stack_model.run { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, app_name

            # save stack data for generating png
            idx = 'process-' + region + '-' + app_name
            process_data_map[idx] = data

            null

        updateApp : ( is_update )->
            @setFlag MC.canvas_data.id, 'UPDATE_APP', is_update
            null

        #zoomin
        zoomIn : () ->
            me = this

            if MC.canvas_property.SCALE_RATIO > 1
                MC.canvas.zoomIn()

            flag = true
            if MC.canvas_property.SCALE_RATIO <= 1
                flag = false

            me.setFlag MC.canvas_data.id, 'ZOOMIN_STACK', flag

        #zoomout
        zoomOut : () ->
            me = this

            if MC.canvas_property.SCALE_RATIO < 1.6
                MC.canvas.zoomOut()

            flag = true
            if MC.canvas_property.SCALE_RATIO >= 1.6
                flag = false

            me.setFlag MC.canvas_data.id, 'ZOOMOUT_STACK', flag

        savePNG : (is_thumbnail, data) ->
            console.log 'savePNG, is_thumbnail = ' + is_thumbnail
            me = this
            #
            callback = ( result ) ->
                console.log 'phantom callback'
                console.log result.data.host
                return if result.data.host isnt MC_HOST.replace( 'http://', '' ).replace( 'https://', '' ).replace( '/', '' )
                if result.data.res.status is 'success'
                    if result.data.res.thumbnail is 'true'
                        console.log 's3 url = ' + result.data.res.result
                        window.removeEventListener 'message', callback

                        #push event
                        ide_event.trigger ide_event.UPDATE_REGION_THUMBNAIL, result.data.res.result, result.data.res.id
                    else
                        me.trigger 'SAVE_PNG_COMPLETE', result.data.res.result
                        window.removeEventListener 'message', callback
                else
                    #window.removeEventListener 'message', callback
            window.addEventListener 'message', callback
            json_data = if MC.data.current_tab_id.split( '-' )[0] is 'app' then JSON.stringify(MC.forge.stack.compactServerGroup( MC.canvas_data )) else JSON.stringify(data)
            #
            phantom_data =
                'origin_host': window.location.origin,
                'usercode'   : $.cookie( 'usercode'   ),
                'session_id' : $.cookie( 'session_id' ),
                'thumbnail'  : is_thumbnail,
                'json_data'  : json_data,
                'stack_id'   : data.id
                'url'        : data.key
                'create_date': MC.dateFormat new Date(), 'hh:mm MM-dd-yyyy'
            #
            console.log 'phantom_data'
            console.log phantom_data
            sendMessage = ->
                $( '#phantom-frame' )[0].contentWindow.postMessage phantom_data, MC.SAVEPNG_URL
            if $( '#phantom-frame' )[0] is undefined
                $('#phantom-frame')[0].onload = () ->
                    sendMessage()
                    null
            else
                sendMessage()
            #
            me.trigger 'SAVE_PNG_COMPLETE', null if !is_thumbnail
            null

        isChanged : (data) ->
            #check if there are changes
            ori_data = MC.canvas_property.original_json
            new_data = JSON.stringify( data )

            if ori_data != new_data
                return true
            else
                return false

        startApp : (region, id, name) ->
            me = this

            app_model.start { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

            item = {'region':region, 'name':name, 'id':id, 'flag_list':{'is_pending':true}}
            me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, "START_APP", item)

        stopApp : (region, id, name) ->
            me = this

            app_model.stop { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

            item = {'region':region, 'name':name, 'id':id, 'flag_list':{'is_pending':true}}
            me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, "STOP_APP", item)

        terminateApp : (region, id, name, flag) ->
            me = this

            app_model.terminate { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name, flag

            item = {'region':region, 'name':name, 'id':id, 'flag_list':{'is_pending':true}}
            me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, "TERMINATE_APP", item)

        saveApp : (data) ->
            me = this

            region  = data.region
            id      = data.id
            name    = data.name

            app_model.update { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, data, id

            # save app data for generating png
            idx = 'process-' + region + '-' + name
            process_data_map[idx] = data

            item = {'region':region, 'name':name, 'id':id, 'flag_list':{'is_pending':true}}
            me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, "SAVE_APP", item)

        handleRequest : (result, flag, region, id, name) ->
            me = this

            if flag isnt 'RUN_STACK'
                me.setFlag id, 'PENDING_APP', region

            if !result.is_error

                #me.trigger 'TOOLBAR_REQUEST_SUCCESS', flag, name

                req_id = result.resolved_data.id
                console.log 'request id:' + req_id

                req_map[req_id] =
                    flag    : flag
                    id      : id
                    name    : name

                # item = {'region':region, 'name':name, 'id':id, 'time_update':result.resolved_data.time_submit, 'flag_list':{'is_pending':true}}
                # me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, flag, item)

                null

            else

                #me.trigger 'TOOLBAR_REQUEST_FAILED', flag, name

                if flag isnt 'RUN_STACK'
                    me.setFlag id, 'STOPPED_APP', region

                else
                    # remove the app name from app_list
                    if name in MC.data.app_list[region]
                        MC.data.app_list[region].splice MC.data.app_list[region].indexOf(name), 1

        #reqHandle : (flag, id, name, req, dag) ->
        reqHandle : (idx, dag) ->
            me = this

            # fetch request
            req_list = MC.data.websocket.collection.request.find({'_id' : idx}).fetch()

            if req_list.length > 0
                req = req_list[0]
                req_id = req.id
                time_update = if 'time_end' of req and req.time_end then req.time_end else req.time_begin

                # filter request
                if req_id of req_map

                    flag    = req_map[req_id].flag
                    id      = req_map[req_id].id
                    name    = req_map[req_id].name
                    region  = req.region

                    # check
                    if not flag or not region or not id or not name
                        return
                    if not time_update
                        time_update = Date.now()/1000

                    # for app update
                    item = {'region':region, 'id':id, 'name':name, 'time_update':time_update}
                    flag_list = {}

                    switch req.state
                        when constant.OPS_STATE.OPS_STATE_INPROCESS
                            flag_list.is_inprocess = true

                            dones = 0
                            steps = 0

                            if 'dag' of dag # changed request

                                steps = dag.dag.step.length
                                # check rollback
                                dones++ for step in dag.dag.step when step[1].toLowerCase() is 'done'
                                console.log 'done steps:' + dones

                            # rollback
                            tab_name = 'process-' + region + '-' + name
                            if tab_name of MC.process and dones>0
                                dones = if !('dones' of MC.process[tab_name].flag_list) or (MC.process[tab_name].flag_list.dones < dones) then dones else MC.process[tab_name].flag_list.dones

                            flag_list.dones = dones
                            flag_list.steps = steps

                            if dones > 0 and steps > 0
                                flag_list.rate = Math.round(flag_list.dones*100/flag_list.steps)
                            else
                                flag_list.rate = 0

                        when constant.OPS_STATE.OPS_STATE_FAILED

                            flag_list.is_failed = true
                            flag_list.err_detail = req.data.replace(/\\n/g, '<br />')

                            if flag is 'RUN_STACK'
                                # remove the app name from app_list
                                if name in MC.data.app_list[region]
                                    MC.data.app_list[region].splice MC.data.app_list[region].indexOf(name), 1

                            else if flag is 'TERMINATE_APP'

                                appId = id
                                appName = name

                                mainContent = 'The app ' + appName + ' failed to terminate. Do you want to force deleting it?'
                                descContent = ''
                                template = MC.template.modalForceDeleteApp {
                                    title : 'Force to delete app',
                                    main_content : mainContent,
                                    desc_content : descContent
                                }
                                modal template, false, () ->
                                    $('#modal-confirm-delete').click () ->
                                        # force to delete app
                                        me.terminateApp(region, appId, appName, 1)
                                        modal.close()

                            else
                                me.setFlag id, 'STOPPED_APP', region

                        when constant.OPS_STATE.OPS_STATE_DONE

                            lst = req.data.split(' ')
                            app_id = lst[lst.length-1]

                            flag_list.app_id = app_id
                            flag_list.is_done = true

                            item.id = app_id

                            switch flag
                                when 'RUN_STACK'
                                    me.setFlag app_id, 'RUNNING_APP', region

                                    item.id = app_id
                                    #item.has_instance_store_ami = me.isInstanceStore(process_data_map[region][name])

                                when 'START_APP'
                                    me.setFlag id, 'RUNNING_APP', region

                                when 'STOP_APP'
                                    me.setFlag id, 'STOPPED_APP', region

                                when 'TERMINATE_APP'
                                    me.setFlag id, 'TERMINATED_APP', region

                                    # remove the app name from app_list
                                    if name in MC.data.app_list[region]
                                        MC.data.app_list[region].splice MC.data.app_list[region].indexOf(name), 1

                                when 'SAVE_APP'
                                    flag_list.is_updated = true
                                    if id of item_state_map
                                        if item_state_map[id].is_running
                                            me.setFlag id, 'RUNNING_APP', region
                                        else
                                            me.setFlag id, 'STOPPED_APP', region

                                else
                                    console.log 'not support toolbar operation:' + flag
                                    return

                        else
                            console.log 'not support request state:' + req.state

                    # update process state
                    if flag_list
                        item.flag_list = flag_list
                        me.updateAppState(req.state, flag, item)

                    # update app list, region aws resource and notification
                    if req.state is constant.OPS_STATE.OPS_STATE_DONE or req.state is constant.OPS_STATE.OPS_STATE_FAILED
                        # update app list
                        app_list = []
                        if item.id.indexOf('app-') == 0
                            app_list.push item.id

                        if app_list
                            ide_event.trigger ide_event.UPDATE_APP_LIST, flag, app_list
                        else
                            ide_event.trigger ide_event.UPDATE_APP_LIST

                        # update region resource
                        ide_event.trigger ide_event.UPDATE_REGION_RESOURCE, region

                        # update notification
                        if req.state is constant.OPS_STATE.OPS_STATE_DONE
                            me.trigger 'TOOLBAR_HANDLE_SUCCESS', flag, name
                        else if req.state is constant.OPS_STATE.OPS_STATE_FAILED
                            me.trigger 'TOOLBAR_HANDLE_FAILED', flag, name

                        # save png
                        if req.state is constant.OPS_STATE.OPS_STATE_DONE
                            if flag is 'RUN_STACK' or flag is 'SAVE_APP'
                                me.saveAppThumbnail flag, region, name, item.id

                        # remove request from req_map
                        delete req_map[req_id]

            # update header
            ide_event.trigger ide_event.UPDATE_HEADER, req


        updateAppState : (req_state, flag, data) ->
            me = this

            state = null

            switch req_state
                when constant.OPS_STATE.OPS_STATE_DONE
                    if flag is 'RUN_STACK'
                        state = constant.APP_STATE.APP_STATE_RUNNING

                    else if flag is 'START_APP'
                        state = constant.APP_STATE.APP_STATE_RUNNING

                    else if flag is 'STOP_APP'
                        state = constant.APP_STATE.APP_STATE_STOPPED

                    else if flag is 'TERMINATE_APP'
                        state = constant.APP_STATE.APP_STATE_TERMINATED

                    else if flag is 'SAVE_APP'
                        state = constant.APP_STATE.APP_STATE_RUNNING

                when constant.OPS_STATE.OPS_STATE_FAILED
                    state = constant.APP_STATE.APP_STATE_STOPPED

                when constant.OPS_STATE.OPS_STATE_INPROCESS
                    if flag is 'RUN_STACK'
                        state = constant.APP_STATE.APP_STATE_INITIALIZING

                    else if flag is 'START_APP'
                        state = constant.APP_STATE.APP_STATE_STARTING

                    else if flag is 'STOP_APP'
                        state = constant.APP_STATE.APP_STATE_STOPPING

                    else if flag is 'TERMINATE_APP'
                        state = constant.APP_STATE.APP_STATE_TERMINATING

                    else if flag is 'SAVE_APP'
                        state = constant.APP_STATE.APP_STATE_UPDATING

                else
                    console.log 'not support request state:' + req_state

            if state
                console.log 'UPDATE_APP_STATE, state:' + state + ', data:' + data

                # set flag
                data.flag_list.flag = flag

                # update MC.process[id]
                tab_name = data.id
                if flag is 'RUN_STACK'
                    tab_name = 'process-' + data.region + '-' + data.name
                MC.process[tab_name] = data

                # push event
                if flag is 'RUN_STACK'
                    ide_event.trigger ide_event.UPDATE_PROCESS, tab_name

                else
                    ide_event.trigger ide_event.UPDATE_APP_STATE, state, tab_name

                    if flag is 'SAVE_APP'
                        if req_state is constant.OPS_STATE.OPS_STATE_DONE
                            #ide_event.trigger ide_event.APPEDIT_2_APP, tab_name, data.region
                            console.log 'app update success'

                        else if req_state is constant.OPS_STATE.OPS_STATE_FAILED
                            #ide_event.trigger ide_event.APPEDIT_2_APP, tab_name
                            console.log 'app update failed'

        isInstanceStore : (data) ->

            is_instance_store = false

            if 'property' of data and 'stoppable' of data.property and data.property.stoppable == false
                is_instance_store = true

            is_instance_store

        saveAppThumbnail  :   (flag, region, app_name, app_id) ->
            me = this

            idx = 'process-' + region + '-' + app_name
            if idx of process_data_map
                data = $.extend(true, {}, process_data_map[idx])

                if data
                    if flag is 'RUN_STACK'
                        # generate s3 key
                        app_model.getKey { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, app_id, app_name

                    else
                        me.savePNG true, data

            null

        convertCloudformation : () ->

            me = this

            stack_service.export_cloudformation {sender:me}, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, ( forge_result ) ->

                if !forge_result.is_error
                #export_cloudformation succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    me.trigger 'CONVERT_CLOUDFORMATION_COMPLETE', forge_result.resolved_data

                else
                #export_cloudformation failed

                    console.log 'stack.export_cloudformation failed, error is ' + forge_result.error_message



    }

    model = new ToolbarModel()

    return model
