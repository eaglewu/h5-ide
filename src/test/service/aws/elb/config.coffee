#*************************************************************************************
#* Filename     : elb_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 15:59:16
#* Description  : qunit test config for elb_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require.config {


    baseUrl         : '/'

    deps            : [ '/test/service/aws/elb/testsuite.js' ]

    shim            :

        'jquery'    :
            exports : '$'

        'MC'        :
            deps    : [ 'jquery','constant' ]
            exports : 'MC'

        'underscore':
            exports : '_'

    paths           :

        #vender
        'jquery'    : 'vender/jquery/jquery'
        'underscore': 'vender/underscore/underscore'

        #core lib
        'MC'        : 'lib/MC.core'

        #common lib
        'constant'  : 'lib/constant'

        #result_vo
        'result_vo'          : 'service/result_vo'

        #session_service
        'session_vo'        : 'service/session/session_vo'
        'session_parser'    : 'service/session/session_parser'
        'session_service'   : 'service/session/session_service'

        #test_util(for qunit test)
        'test_util'         : 'test/service/test_util'



        #elb service
        'elb_vo'        : 'service/aws/elb/elb/elb_vo'
        'elb_parser'    : 'service/aws/elb/elb/elb_parser'
        'elb_service'   : 'service/aws/elb/elb/elb_service'
}#end
