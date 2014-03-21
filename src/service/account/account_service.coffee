#*************************************************************************************
#* Filename     : account_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-09-13 09:00:21
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

    URL = '/account/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "account." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
                    forge_result = {}
                    forge_result = parser result, return_code, param_ary

                    callback forge_result

                error : ( result, return_code ) ->

                    forge_result = {}
                    forge_result.return_code      = return_code
                    forge_result.is_error         = true
                    forge_result.error_message    = result.toString()

                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
                    forge_result.param = param_ary

                    callback forge_result
            }

        catch error
            console.log "account." + method + " error:" + error.toString()


        true
    # end of send_request



    #///////////////// Parser for register return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRegisterResult = ( result ) ->

        session_info = {}

        #resolve result
        session_info.usercode    = result[0]
        session_info.email       = result[1]
        session_info.session_id  = result[2]
        session_info.account_id  = result[3]
        session_info.mod_repo    = result[4]
        session_info.mod_tag     = result[5]
        session_info.state       = result[6]
        session_info.has_cred    = result[7]
        session_info.is_invitated= result[8]

        #return session_info
        session_info

    #private (parser register return)
    parserRegisterReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveRegisterResult result

            forge_result.resolved_data = resolved_data

        else if return_code == constant.RETURN_CODE.E_EXIST

            resolved_data = result

            forge_result.resolved_data = resolved_data

        #3.return vo
        forge_result

    # end of parserRegisterReturn


    #///////////////// Parser for update_account return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveUpdateAccountResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO
        result

    #private (parser update_account return)
    parserUpdateAccountReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveUpdateAccountResult result

            forge_result.resolved_data = resolved_data

        #3.return vo
        forge_result

    # end of parserUpdateAccountReturn


    #///////////////// Parser for reset_password return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveResetPasswordResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO
        result

    #private (parser reset_password return)
    parserResetPasswordReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveResetPasswordResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserResetPasswordReturn


    #///////////////// Parser for update_password return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveUpdatePasswordResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO
        result

    #private (parser update_password return)
    parserUpdatePasswordReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveUpdatePasswordResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserUpdatePasswordReturn


    #///////////////// Parser for check_repeat return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveCheckRepeatResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO
        result

    #private (parser check_repeat return)
    parserCheckRepeatReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveCheckRepeatResult result

            forge_result.resolved_data = resolved_data

        else if return_code == constant.RETURN_CODE.E_EXIST

            resolved_data = result

            forge_result.resolved_data = resolved_data

        #3.return vo
        forge_result

    # end of parserCheckRepeatReturn


    #///////////////// Parser for check_validation return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveCheckValidationResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO
        result

    #private (parser check_validation return)
    parserCheckValidationReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveCheckValidationResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserCheckValidationReturn


    #///////////////// Parser for reset_key return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveResetKeyResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO
        result

    #private (parser reset_key return)
    parserResetKeyReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveResetKeyResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserResetKeyReturn

    #///////////////// Parser for is_invitated return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveIsInvitatedResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser is_invitated return)
    parserIsInvitatedReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveIsInvitatedResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserIsInvitatedReturn


    #///////////////// Parser for apply_trial return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveApplyTrialResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser apply_trial return)
    parserApplyTrialReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveApplyTrialResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserApplyTrialReturn


    #def register(self, username, password, email):
    register = ( src, username, password, email, callback ) ->
        send_request "register", src, [ username, password, email ], parserRegisterReturn, callback
        true

    #def update_account(self, username, session_id, attributes):
    update_account = ( src, username, session_id, attributes, callback ) ->
        send_request "update_account", src, [ username, session_id, attributes ], parserUpdateAccountReturn, callback
        true

    #def reset_password(self, username):
    reset_password = ( src, username, callback ) ->
        send_request "reset_password", src, [ username ], parserResetPasswordReturn, callback
        true

    #def update_password(self, id, new_pwd):
    update_password = ( src, id, new_pwd, callback ) ->
        send_request "update_password", src, [ id, new_pwd ], parserUpdatePasswordReturn, callback
        true

    #def check_repeat(self, username, email):
    check_repeat = ( src, username, email, callback ) ->
        send_request "check_repeat", src, [ username, email ], parserCheckRepeatReturn, callback
        true

    #def check_validation(self, key, flag):
    check_validation = ( src, key, flag, callback ) ->
        send_request "check_validation", src, [ key, flag ], parserCheckValidationReturn, callback
        true

    #def reset_key(self, username, session_id, flag):
    reset_key = ( src, username, session_id, flag=null, callback ) ->
        send_request "reset_key", src, [ username, session_id, flag ], parserResetKeyReturn, callback
        true

    #def is_invitated(self, username, session_id):
    is_invitated = ( src, username, session_id, callback ) ->
        send_request "is_invitated", src, [ username, session_id ], parserIsInvitatedReturn, callback
        true

    #def apply_trial(self, username, session_id, message=None):
    apply_trial = ( src, username, session_id, message=null, callback ) ->
        send_request "apply_trial", src, [ username, session_id, message ], parserApplyTrialReturn, callback
        true

    #############################################################
    #public
    register                     : register
    update_account               : update_account
    reset_password               : reset_password
    update_password              : update_password
    check_repeat                 : check_repeat
    check_validation             : check_validation
    reset_key                    : reset_key
    is_invitated                 : is_invitated
    apply_trial                  : apply_trial
