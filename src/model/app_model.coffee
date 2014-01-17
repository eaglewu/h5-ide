#*************************************************************************************
#* Filename     : app_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:40
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'app_service', 'base_model' ], ( Backbone, _, app_service, base_model ) ->

    AppModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #create api (define function)
        create : ( src, username, session_id, region_name, spec ) ->

            me = this

            src.model = me

            app_service.create src, username, session_id, region_name, spec, ( forge_result ) ->

                if !forge_result.is_error
                #create succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'APP_CREATE_RETURN', forge_result

                else
                #create failed

                    console.log 'app.create failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #update api (define function)
        update : ( src, username, session_id, region_name, spec, app_id ) ->

            me = this

            src.model = me

            app_service.update src, username, session_id, region_name, spec, app_id, ( forge_result ) ->

                if !forge_result.is_error
                #update succeed

                else
                #update failed

                    console.log 'app.update failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'APP_UPDATE_RETURN', forge_result


        #rename api (define function)
        rename : ( src, username, session_id, region_name, app_id, new_name, app_name=null ) ->

            me = this

            src.model = me

            app_service.rename src, username, session_id, region_name, app_id, new_name, app_name, ( forge_result ) ->

                if !forge_result.is_error
                #rename succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'APP_RENAME_RETURN', forge_result

                else
                #rename failed

                    console.log 'app.rename failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #terminate api (define function)
        terminate : ( src, username, session_id, region_name, app_id, app_name=null, flag=null ) ->

            me = this

            src.model = me

            app_service.terminate src, username, session_id, region_name, app_id, app_name, flag, ( forge_result ) ->

                if !forge_result.is_error
                #terminate succeed

                else
                #terminate failed

                    console.log 'app.terminate failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'APP_TERMINATE_RETURN', forge_result



        #start api (define function)
        start : ( src, username, session_id, region_name, app_id, app_name=null ) ->

            me = this

            src.model = me

            app_service.start src, username, session_id, region_name, app_id, app_name, ( forge_result ) ->

                if !forge_result.is_error
                #start succeed

                else
                #start failed

                    console.log 'app.start failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'APP_START_RETURN', forge_result


        #stop api (define function)
        stop : ( src, username, session_id, region_name, app_id, app_name=null ) ->

            me = this

            src.model = me

            app_service.stop src, username, session_id, region_name, app_id, app_name, ( forge_result ) ->

                if !forge_result.is_error
                #stop succeed

                else
                #stop failed

                    console.log 'app.stop failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'APP_STOP_RETURN', forge_result



        #reboot api (define function)
        reboot : ( src, username, session_id, region_name, app_id, app_name=null ) ->

            me = this

            src.model = me

            app_service.reboot src, username, session_id, region_name, app_id, app_name, ( forge_result ) ->

                if !forge_result.is_error
                #reboot succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'APP_REBOOT_RETURN', forge_result

                else
                #reboot failed

                    console.log 'app.reboot failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #info api (define function)
        info : ( src, username, session_id, region_name=null, app_ids=null ) ->

            me = this

            src.model = me

            app_service.info src, username, session_id, region_name, app_ids, ( forge_result ) ->

                if !forge_result.is_error
                #info succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'APP_INFO_RETURN', forge_result

                else
                #info failed

                    console.log 'app.info failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #list api (define function)
        list : ( src, username, session_id, region_name=null, app_ids=null ) ->

            me = this

            src.model = me

            app_service.list src, username, session_id, region_name, app_ids, ( forge_result ) ->

                if !forge_result.is_error
                #list succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'APP_LST_RETURN', forge_result

                else
                #list failed

                    console.log 'app.list failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #resource api (define function)
        resource : ( src, username, session_id, region_name, app_id ) ->

            me = this

            src.model = me

            app_service.resource src, username, session_id, region_name, app_id, ( forge_result ) ->

                if !forge_result.is_error
                #resource succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'APP_RESOURCE_RETURN', forge_result

                else
                #resource failed

                    console.log 'app.resource failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #summary api (define function)
        summary : ( src, username, session_id, region_name=null ) ->

            me = this

            src.model = me

            app_service.summary src, username, session_id, region_name, ( forge_result ) ->

                if !forge_result.is_error
                #summary succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'APP_SUMMARY_RETURN', forge_result

                else
                #summary failed

                    console.log 'app.summary failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #getKey api (define function)
        getKey : ( src, username, session_id, region_name, app_id, app_name ) ->

            me = this

            src.model = me

            app_service.getKey src, username, session_id, region_name, app_id, app_name, ( forge_result ) ->

                if !forge_result.is_error
                #getKey succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'APP_GET_KEY_RETURN', forge_result

                else
                #getKey failed

                    console.log 'app.getKey failed, error is ' + forge_result.error_message
                    me.pub forge_result




    }

    #############################################################
    #private (instantiation)
    app_model = new AppModel()

    #public (exposes methods)
    app_model

