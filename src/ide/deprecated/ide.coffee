#############################
#  main for ide
#############################

define [ 'MC', 'event', 'handlebars'
		 'i18n!nls/lang.js',
		 './view', 'canvas_layout',
		 'header', 'navigation', 'tabbar', 'dashboard', 'design_module', 'process', 'constant',
		 'base_model',
		 'common_handle', 'validation', 'aws_handle'
], ( MC, ide_event, Handlebars, lang, view, canvas_layout, header, navigation, tabbar, dashboard, design, process, constant, base_model, common_handle, validation ) ->

	initialize : () ->

		#############################
		#  check network
		#############################

		_.delay () ->
			console.log '---------- check network ----------'
			if !MC.data.is_loading_complete and $( '#loading-bar-wrapper' ).html().trim() isnt ''
				ide_event.trigger ide_event.SWITCH_MAIN
				notification 'error', lang.ide.IDE_MSG_ERR_CONNECTION, true
		, 50 * 1000

		#############################
		#  validation cookie
		#############################

		#clear cookie in 'ide.visualops.io'
		#common_handle.cookie.clearInvalidCookie()

		#############################
		#  initialize MC.data
		#############################

		#set MC.data
		#MC.data = {}

		# set default 'dashboard'
		MC.data.current_tab_id = 'dashboard'

		#global config data by region
		MC.data.config = {}
		MC.data.config[r] = {} for r in constant.REGION_KEYS

		#global cache for all ami
		MC.data.dict_ami = {}

		#global stack name list
		MC.data.stack_list = {}
		MC.data.stack_list[r] = [] for r in constant.REGION_KEYS
		#global app name list
		MC.data.app_list = {}
		MC.data.app_list[r] = [] for r in constant.REGION_KEYS

		#
		MC.data.nav_new_stack_list = {}
		MC.data.nav_app_list       = {}
		MC.data.nav_stack_list     = {}

		#global resource data (Describe* return)
		MC.data.resource_list = {}
		MC.data.resource_list[r] = {} for r in constant.REGION_KEYS

		#set untitled
		MC.data.untitled = 0
		#set tab
		MC.tab          = {}
		#set process tab
		MC.process      = {}
		MC.data.process = {}
		MC.storage.remove 'process'

		#save <div class="loading-wrapper" class="main-content active">
		MC.data.loading_wrapper_html = null
		MC.data.is_loading_complete = false

		#save resouce service name
		MC.data.resouceapi = []
		#dependency MC.data.is_loading_complete and MC.data.design_submodule_count = -1
		MC.data.ide_available_count = 0

		#temp
		#MC.data.IDEView = view

		MC.data.account_attribute = {}
		MC.data.account_attribute[r] = { 'support_platform':'', 'default_vpc':'', 'default_subnet':{} } for r in constant.REGION_KEYS

		#
		MC.data.demo_stack_list = constant.DEMO_STACK_NAME_LIST
		#
		MC.open_failed_list = {}

		#trusted advisor
		MC.ta            = {}
		MC.ta            = validation
		MC.ta.list       = []
		MC.ta.state_list = {}

		#state editor
		MC.data.state = {}

		# State clipboard
		MC.data.stateClipboard = []

		#temp
		MC.data.running_app_list = {}

		# include 'NEW_STACK' 'OPEN_STACK' 'OPEN_APP'
		MC.data.open_tab_data    = {}

		#############################
		#  listen ide_event
		#############################

		#listen main view event
		#listen RETURN_OVERVIEW_TAB and RETURN_REGION_TAB
		ide_event.onLongListen ide_event.RETURN_OVERVIEW_TAB, () -> view.showOverviewTab()
		ide_event.onLongListen ide_event.RETURN_REGION_TAB,   () -> view.showRegionTab()
		#listen SWITCH_TAB and SWITCH_DASHBOARD
		ide_event.onLongListen ide_event.SWITCH_TAB,          () -> view.showTab()
		ide_event.onLongListen ide_event.SWITCH_DASHBOARD,    () -> view.showDashbaordTab()
		ide_event.onLongListen ide_event.SWITCH_PROCESS,      () -> view.showProcessTab()
		#
		ide_event.onLongListen ide_event.SWITCH_MAIN,         () -> view.showMain()
		ide_event.onLongListen ide_event.SWITCH_LOADING_BAR,  ( tab_id, is_transparent ) -> view.showLoading tab_id, is_transparent
		ide_event.onLongListen ide_event.SWITCH_WAITING_BAR,  () -> view.toggleWaiting()
		ide_event.onLongListen ide_event.HIDE_STATUS_BAR,     () -> view.hideStatubar()

		#listen IDE_AVAILABLE
		ide_event.onLongListen ide_event.IDE_AVAILABLE, () ->
			console.log 'IDE_AVAILABLE'
			MC.data.ide_available_count = MC.data.ide_available_count + 1
			console.log '----------- ide:SWITCH_MAIN -----------'
			ide_event.trigger ide_event.SWITCH_MAIN if MC.data.ide_available_count is 4

		#############################
		#  load module
		#############################

		#load header
		header.loadModule()
		#load tabbar
		tabbar.loadModule()
		#load dashboard
		dashboard.loadModule()

		#listen DASHBOARD_COMPLETE
		ide_event.onListen ide_event.DASHBOARD_COMPLETE, () ->
			console.log 'DASHBOARD_COMPLETE'
			navigation.loadModule()

		#listen NAVIGATION_COMPLETE
		ide_event.onListen ide_event.NAVIGATION_COMPLETE, () ->
			console.log 'NAVIGATION_COMPLETE'
			#load design
			design.loadModule()
			#temp
			setTimeout () ->
				#load layout
				console.log 'layout'
				#layout.ready()
				canvas_layout.canvas_initialize()
			, 2000

		#listen DESIGN_COMPLETE
		ide_event.onListen ide_event.DESIGN_COMPLETE, () ->
			console.log 'DESIGN_COMPLETE'
			process.loadModule()
			#
			#ide_event.trigger ide_event.SWITCH_MAIN

		#############################
		#  base model
		#############################

		base_model.sub ( error ) ->
			console.log 'sub'
			if error.return_code is constant.RETURN_CODE.E_SESSION
				# LEGACY code
				App.acquireSession()

				if error.param[0].method is 'info'
					if error.param[0].url in [ '/stack/', '/app/' ]
						ide_event.trigger ide_event.CLOSE_DESIGN_TAB, error.param[4][0]
			else

				label = 'ERROR_CODE_' + error.return_code + '_MESSAGE'
				console.warn lang.service[ label ],error

				return if error.error_message.indexOf( 'AWS was not able to validate the provided access credentials' ) isnt -1
				return if error.param[0].url is '/session/' and error.param[0].method is 'login'

				if error.return_code == -1 and error.error_message == "200"
					if error.param[0].url is '/aws/' and error.param[0].method is 'resource'
						notification 'warning', lang.service["ERROR_CODE_-1_MESSAGE_AWS_RESOURCE"]
					else
						notification 'warning', lang.service[label]
					return null

				if lang.service[ label ]
					error_msg = lang.service[ label ] + "(" + error.return_code + ")"
				else
					error_msg = "unknown error (" + error.return_code + ")"

				if error_msg and $(".error_item").text().indexOf(error_msg) is -1
					notification 'error', error_msg, false

			null

		null
