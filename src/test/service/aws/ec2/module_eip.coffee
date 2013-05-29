#*************************************************************************************
#* Filename     : eip_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 13:27:40
#* Description  : qunit test module for eip_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'eip_service'], ( MC, $, test_util, session_service, eip_service ) ->

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
    #aws/ec2 test
    ################################################
    module "Module aws/ec2 - eip"
    #-----------------------------------------------
    #Test DescribeAddresses()
    #-----------------------------------------------
    test_DescribeAddresses = () ->
        asyncTest "/aws/ec2 eip.DescribeAddresses()", () ->
            ips = null
            allocation_ids = null
            filters = null

            eip_service.DescribeAddresses username, session_id, region_name, ips, allocation_ids, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAddresses succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAddresses() succeed"
                else
                #DescribeAddresses failed
                    ok false, "DescribeAddresses() failed" + aws_result.error_message
            
                start()
                test_DisassociateAddress()


    test_DescribeAddresses()

