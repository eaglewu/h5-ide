#*************************************************************************************
#* Filename     : autoscaling_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:03
#* Description  : qunit test module for autoscaling_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'autoscaling_service'], ( MC, $, test_util, session_service, autoscaling_service ) ->

    #test user
    username    = test_util.username
    password    = test_util.password

    #session info
    session_id  = ""
    usercode    = ""
    region_name = ""

    can_test    = false

    test "Check test user", () ->
        if username == "" or password == ""
            ok false, "please set the username and password first(/test/service/test_util), then try again"
        else
            ok true, "passwd"
            can_test = true

    if !can_test
        return false


    ################################################
    #session login
    ################################################
    module "Module Session"

    asyncTest "session.login", () ->
        session_service.login username, password, ( forge_result ) ->
            if !forge_result.is_error
            #login succeed
                session_info = forge_result.resolved_data
                session_id   = session_info.session_id
                usercode     = session_info.usercode
                region_name  = session_info.region_name
                ok true, "login succeed" + "( usercode : " + usercode + " , region_name : " + region_name + " , session_id : " + session_id + ")"
                username = usercode
                start()
            else
            #login failed
                ok false, "login failed, error is " + forge_result.error_message + ", cancel the follow-up test!"
                start()



    ################################################
    #aws/autoscaling test
    ################################################
    module "Module aws/autoscaling - autoscaling"
    #-----------------------------------------------
    #Test DescribeAdjustmentTypes()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeAdjustmentTypes()", () ->
        

        autoscaling_service.DescribeAdjustmentTypes username, session_id, region_name, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeAdjustmentTypes succeed
                data = aws_result.resolved_data
                ok true, "DescribeAdjustmentTypes() succeed"
                start()
            else
            #DescribeAdjustmentTypes failed
                ok false, "DescribeAdjustmentTypes() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeAutoScalingGroups()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeAutoScalingGroups()", () ->
        
        group_names = null
        max_records = null
        next_token = null

        autoscaling_service.DescribeAutoScalingGroups username, session_id, region_name, group_names, max_records, next_token, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeAutoScalingGroups succeed
                data = aws_result.resolved_data
                ok true, "DescribeAutoScalingGroups() succeed"
                start()
            else
            #DescribeAutoScalingGroups failed
                ok false, "DescribeAutoScalingGroups() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeAutoScalingInstances()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeAutoScalingInstances()", () ->
        
        instance_ids = null
        max_records = null
        next_token = null

        autoscaling_service.DescribeAutoScalingInstances username, session_id, region_name, instance_ids, max_records, next_token, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeAutoScalingInstances succeed
                data = aws_result.resolved_data
                ok true, "DescribeAutoScalingInstances() succeed"
                start()
            else
            #DescribeAutoScalingInstances failed
                ok false, "DescribeAutoScalingInstances() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeAutoScalingNotificationTypes()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeAutoScalingNotificationTypes()", () ->
        

        autoscaling_service.DescribeAutoScalingNotificationTypes username, session_id, region_name, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeAutoScalingNotificationTypes succeed
                data = aws_result.resolved_data
                ok true, "DescribeAutoScalingNotificationTypes() succeed"
                start()
            else
            #DescribeAutoScalingNotificationTypes failed
                ok false, "DescribeAutoScalingNotificationTypes() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeLaunchConfigurations()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeLaunchConfigurations()", () ->
        
        config_names = null
        max_records = null
        next_token = null

        autoscaling_service.DescribeLaunchConfigurations username, session_id, region_name, config_names, max_records, next_token, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeLaunchConfigurations succeed
                data = aws_result.resolved_data
                ok true, "DescribeLaunchConfigurations() succeed"
                start()
            else
            #DescribeLaunchConfigurations failed
                ok false, "DescribeLaunchConfigurations() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeMetricCollectionTypes()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeMetricCollectionTypes()", () ->
        

        autoscaling_service.DescribeMetricCollectionTypes username, session_id, region_name, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeMetricCollectionTypes succeed
                data = aws_result.resolved_data
                ok true, "DescribeMetricCollectionTypes() succeed"
                start()
            else
            #DescribeMetricCollectionTypes failed
                ok false, "DescribeMetricCollectionTypes() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeNotificationConfigurations()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeNotificationConfigurations()", () ->
        
        group_names = null
        max_records = null
        next_token = null

        autoscaling_service.DescribeNotificationConfigurations username, session_id, region_name, group_names, max_records, next_token, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeNotificationConfigurations succeed
                data = aws_result.resolved_data
                ok true, "DescribeNotificationConfigurations() succeed"
                start()
            else
            #DescribeNotificationConfigurations failed
                ok false, "DescribeNotificationConfigurations() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribePolicies()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribePolicies()", () ->
        
        group_name = null
        policy_names = null
        max_records = null
        next_token = null

        autoscaling_service.DescribePolicies username, session_id, region_name, group_name, policy_names, max_records, next_token, ( aws_result ) ->
            if !aws_result.is_error
            #DescribePolicies succeed
                data = aws_result.resolved_data
                ok true, "DescribePolicies() succeed"
                start()
            else
            #DescribePolicies failed
                ok false, "DescribePolicies() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeScalingActivities()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeScalingActivities()", () ->
        

        autoscaling_service.DescribeScalingActivities username, session_id, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeScalingActivities succeed
                data = aws_result.resolved_data
                ok true, "DescribeScalingActivities() succeed"
                start()
            else
            #DescribeScalingActivities failed
                ok false, "DescribeScalingActivities() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeScalingProcessTypes()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeScalingProcessTypes()", () ->
        

        autoscaling_service.DescribeScalingProcessTypes username, session_id, region_name, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeScalingProcessTypes succeed
                data = aws_result.resolved_data
                ok true, "DescribeScalingProcessTypes() succeed"
                start()
            else
            #DescribeScalingProcessTypes failed
                ok false, "DescribeScalingProcessTypes() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeScheduledActions()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeScheduledActions()", () ->
        

        autoscaling_service.DescribeScheduledActions username, session_id, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeScheduledActions succeed
                data = aws_result.resolved_data
                ok true, "DescribeScheduledActions() succeed"
                start()
            else
            #DescribeScheduledActions failed
                ok false, "DescribeScheduledActions() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeTags()
    #-----------------------------------------------
    asyncTest "/aws/autoscaling autoscaling.DescribeTags()", () ->
        
        filters = null
        max_records = null
        next_token = null

        autoscaling_service.DescribeTags username, session_id, region_name, filters, max_records, next_token, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeTags succeed
                data = aws_result.resolved_data
                ok true, "DescribeTags() succeed"
                start()
            else
            #DescribeTags failed
                ok false, "DescribeTags() failed" + aws_result.error_message
                start()

