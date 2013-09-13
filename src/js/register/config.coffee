
require.config {

	baseUrl               : './'

	waitSeconds           : 30

	deps                  : [ 'main' ]

	locale                : 'en-us'

	urlArgs               : 'v=' + version

	paths                 :

		#main
		'main'            : 'js/register/main'
		'router'          : 'js/register/router'
		'reg_main'        : 'module/register/main'

		#vender
		'jquery'          : 'vender/jquery/jquery'
		'underscore'      : 'vender/underscore/underscore'
		'backbone'        : 'vender/backbone/backbone'
		'handlebars'      : 'vender/handlebars/handlebars'

		'domReady'        : 'vender/requirejs/domReady'
		'i18n'            : 'vender/requirejs/i18n'
		'text'            : 'vender/requirejs/text'

		#
		'base_main'       : 'module/base/base_main'

		#
		'event'           : 'event/ide_event'

		#
		'UI.notification'    : 'ui/common/UI.notification'

		#core lib
		'MC'              : 'lib/MC.core'

		#common lib
		'constant'        : 'lib/constant'

		#base_model
		'base_model'      : 'model/base_model'

		#result_vo
		'result_vo'       : 'service/result_vo'

		#forge handle
		'forge_handle'    : 'lib/forge/main'

	shim                  :

		'jquery'          :
			exports       : '$'

		'underscore'      :
			exports       : '_'

		'backbone'        :
			deps          : [ 'underscore', 'jquery' ]
			exports       : 'Backbone'

		'handlebars'      :
			exports       : 'Handlebars'

		'MC'              :
			deps          : [ 'jquery','constant' ]
			exports       : 'MC'

}

#requirejs.onError = ( err ) ->
#    console.log 'error type: ' + err.requireType + ', modules: ' + err.requireModules
