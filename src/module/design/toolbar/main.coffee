####################################
#  Controller for design/toolbar module
####################################

define [ 'jquery',
         'event',
         'i18n!nls/lang.js'
], ( $, ide_event, lang ) ->

    #private
    loadModule = () ->

        require [ './module/design/toolbar/view', './module/design/toolbar/model' ], ( View, model ) ->

            #view
            view       = new View()
            view.model = model
            view.listen()
            view.render()

            #listen OPEN_DESIGN
            ide_event.onLongListen ide_event.OPEN_SUB_DESIGN, ( region_name, type, current_platform, tab_name, tab_id ) ->
                console.log 'toolbar:OPEN_SUB_DESIGN, region_name = ' + region_name + ', type = ' + type
                #
                model.setFlag tab_id, type
                #
                # MC.ta.validAll() if type is 'OPEN_STACK'

            ###
            #listen OPEN_TOOLBAR
            ide_event.onLongListen ide_event.OPEN_TOOLBAR, ( tab_id, type ) ->
                console.log 'toolbar:OPEN_TOOLBAR, tab_id = ' + tab_id + ', type = ' + type
                console.log MC.canvas_data
            ###

            #listen toolbar state change
            model.on 'UPDATE_TOOLBAR', (type) ->
                console.log 'update toolbar status'
                view.render type

            ide_event.onLongListen ide_event.SWITCH_DASHBOARD, () ->
                console.log 'toolbar:SWITCH_DASHBOARD'
                model.setTabFlag(false)
                null

            ide_event.onLongListen ide_event.SWITCH_TAB, () ->
                setTimeout () ->
                    console.log 'SWITCH_TAB toolbar id:' + MC.forge.other.canvasData.get 'id'
                    model.setTabFlag(true)
                , 500

            #save
            ide_event.onLongListen ide_event.SAVE_STACK, (data) ->
                console.log ide_event.SAVE_STACK

                try

                    # save Design
                    MC.forge.other.canvasData.save   data

                    # save origin_data
                    MC.forge.other.canvasData.origin data

                    # save db
                    model.saveStack                  data

                catch err
                    msg = sprintf lang.ide.TOOL_MSG_ERR_SAVE_FAILED, data.name
                    view.notify 'error', msg

                null

            #duplicate
            ide_event.onLongListen ide_event.DUPLICATE_STACK, (region, id, new_name, name) ->
                console.log ide_event.DUPLICATE_STACK + ':' + region + ',' + id + ',' + new_name + ',' + name
                model.duplicateStack(region, id, new_name, name)

            #delete
            ide_event.onLongListen ide_event.DELETE_STACK, (region, id, name) ->
            #view.on 'TOOLBAR_DELETE_CLICK', (data) ->
                console.log ide_event.DELETE_STACK + ':' + region + ',' + id + ',' + name
                model.deleteStack(region, id, name)

            #zoomin
            view.on 'TOOLBAR_ZOOM_IN', () ->
                console.log 'TOOLBAR_ZOOM_IN'
                model.zoomIn()

            #zoomout
            view.on 'TOOLBAR_ZOOM_OUT', () ->
                console.log 'TOOLBAR_ZOOM_OUT'
                model.zoomOut()

            view.on 'UPDATE_APP', ( is_update ) ->
                model.updateApp is_update
                null

            #run
            view.on 'TOOLBAR_RUN_CLICK', (app_name, data) ->
                console.log 'design_toolbar_click:runStack'
                model.runStack(app_name, data)

            #export to png
            view.on 'TOOLBAR_EXPORT_PNG_CLICK', () ->
                console.log 'design_toolbar_click:exportPngIcon'
                model.generatePNG()

            view.on 'CONVERT_CLOUDFORMATION', () ->
                model.convertCloudformation()

            model.on 'EXPORT_PNG', ( base64_image, uid, blob ) ->
                view.exportPNG base64_image, uid, blob

            view.on 'APP_UPDATING', ( data ) ->
                console.log 'design_toolbar APP_2_APPEDIT'

                if _.isObject data
                    #data = MC.forge.stack.expandServerGroup data
                    model.saveApp(data)
                else
                    console.log 'current is not object, data is ' + data

            # model.on 'CONVERT_CLOUDFORMATION_COMPLETE', ( cf_json ) ->
            #     view.saveCloudFormation cf_json

            # app operation
            ide_event.onLongListen 'STOP_APP', (region, app_id, app_name) ->
                console.log 'design_toolbar STOP_APP region:' + region + ', app_id:' + app_id + ', app_name:' + app_name
                model.stopApp(region, app_id, app_name)

            ide_event.onLongListen 'START_APP', (region, app_id, app_name) ->
                console.log 'design_toolbar START_APP region:' + region + ', app_id:' + app_id + ', app_name:' + app_name
                model.startApp(region, app_id, app_name)

            ide_event.onLongListen 'TERMINATE_APP', (region, app_id, app_name, flag) ->
                console.log 'design_toolbar TERMINATE_APP region:' + region + ', app_id:' + app_id + ', app_name:' + app_name + ', flag:' + flag
                model.terminateApp(region, app_id, app_name, flag)

            ide_event.onLongListen ide_event.CANVAS_SAVE, () ->
                console.log 'design_toolbar_click:saveStack'
                model.saveStack()

            ide_event.onLongListen ide_event.UPDATE_REQUEST_ITEM, (idx, dag) ->
                console.log 'toolbar listen UPDATE_REQUEST_ITEM index:' + idx
                model.reqHandle idx, dag

            ide_event.onLongListen ide_event.APPEDIT_2_APP, ( tab_id, region ) ->
                console.log 'APPEDIT_2_APP, tab_id = ' + tab_id + ', region = ' + region
                view.saveSuccess2App tab_id, region

            model.on 'TOOLBAR_REQUEST_SUCCESS', (flag, value) ->

                if flag
                    str_idx = 'TOOLBAR_HANDLE_' + flag
                    if str_idx of lang.ide
                        msg = sprintf lang.ide.TOOL_MSG_INFO_REQ_SUCCESS, lang.ide[str_idx], value
                        view.notify 'info', msg

            model.on 'TOOLBAR_REQUEST_FAILED', (flag, value) ->

                if flag
                    str_idx = 'TOOLBAR_HANDLE_' + flag
                    if str_idx of lang.ide
                        msg = sprintf lang.ide.TOOL_MSG_ERR_REQ_FAILED, lang.ide[str_idx], value
                        view.notify 'error', msg

            model.on 'TOOLBAR_HANDLE_SUCCESS', (flag, value) ->
                if flag
                    if modal and modal.isPopup()
                        if (flag is "SAVE_STACK" or flag is "CREATE_STACK")
                            # run stack
                            if $('#modal-run-stack')[0] isnt undefined

                                # old design flow
                                #data = $.extend true, {}, MC.canvas_data

                                # new design flow
                                data  = MC.forge.other.canvasData.data()

                                app_name = $('.modal-input-value').val()
                                # set app name
                                data.name = app_name
                                # set usage
                                data.usage = 'others'
                                usage = $('#app-usage-selectbox .selected').data 'value'
                                if usage
                                    data.usage = usage

                                model.runStack data

                                # old design flow
                                #MC.data.app_list[MC.canvas_data.region].push app_name

                                # new design flow
                                region = MC.forge.other.canvasData.get 'region'
                                MC.data.app_list[ region ].push app_name

                                modal.close()

                            # start to export cf
                            else if $('#modal-export-cf')[0] isnt undefined
                                # convert cf
                                model.convertCloudformation()

                        else if flag is "EXPORT_CLOUDFORMATION"
                            #download
                            view.saveCloudFormation value

                    str_idx = 'TOOLBAR_HANDLE_' + flag
                    if str_idx of lang.ide
                        msg = sprintf lang.ide.TOOL_MSG_INFO_HDL_SUCCESS, lang.ide[str_idx], value

                        view.notify 'info', msg

            model.on 'TOOLBAR_HANDLE_FAILED', (flag, value) ->

                if flag
                    if modal and modal.isPopup()
                        # run stack
                        if (flag == "SAVE_STACK" or flag == "CREATE_STACK")
                            # disable button
                            $('#btn-confirm').attr 'disabled', true
                            $('.modal-close').attr 'disabled', false

                    str_idx = 'TOOLBAR_HANDLE_' + flag
                    if str_idx of lang.ide
                        msg = sprintf lang.ide.TOOL_MSG_ERR_HDL_FAILED, lang.ide[str_idx], value
                        view.notify 'error', msg

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
