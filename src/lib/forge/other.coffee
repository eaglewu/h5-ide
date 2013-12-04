define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	#############################
	#  core
	#############################

	isCurrentTab = ( tab_id ) ->
		console.log 'isCurrentTab', tab_id

		if MC.data.current_tab_id is tab_id
			true
		else
			false

	# set current tab id
	setCurrentTabId = ( tab_id ) ->
		console.log 'setCurrentTabId', tab_id
		MC.data.current_tab_id = tab_id
		null

	# get stack app by
	searchStackAppById = ( id ) ->

		value = null

		try

			temp  = if id.split('-')[0] is 'stack' then MC.data.nav_stack_list else MC.data.nav_app_list
			_.each temp, ( obj ) ->
				_.each obj.region_name_group, ( item ) ->
					value = item if item.id is id
					return true

		catch error
			console.log 'searchStackAppById error, id is ' + id
			console.log error

		value

	#############################
	#  process
	#############################

	addProcess = ( id, data ) ->
		console.log 'addProcess', id, data
		MC.process[ id ] = data
		null

	deleteProcess = ( id ) ->
		console.log 'deleteProcess', id
		delete MC.process[ id ]
		delete MC.data.process[ id ]
		console.log MC.process
		null

	getProcess = ( id ) ->
		console.log 'getProcess', id
		MC.process[ id ]

	filterProcess = ( id ) ->
		console.log 'filterProcess', id

		obj   = @searchStackAppById id
		state = null

		if obj and obj.state in [ constant.APP_STATE.APP_STATE_STARTING, constant.APP_STATE.APP_STATE_STOPPING, constant.APP_STATE.APP_STATE_TERMINATING, constant.APP_STATE.APP_STATE_UPDATING ]
			state = obj.state

		state

	initDataProcess = ( id, type, data ) ->
		console.log 'initDataProcess', id, type, data
		MC.data.process             = {}
		MC.data.process             = $.extend true, {}, data
		MC.data.process[ id ].state = type if MC.data.process and MC.data.process[ id ]
		console.log 'current MC.data.process', MC.data.process
		null

	#############################
	#  cache id
	#############################

	# cacheIDMap[ tab_id ] =
	#	type : <appview>
	#	origin_tab_id : <origin_tab_id>
	#	region : <region_name>
	#	data : <vpc_resource result>

	cacheIDMap = {}

	createUID = ( length = 8 ) ->
		chars  = undefined
		str    = undefined
		chars  = "0123456789abcdefghiklmnopqrstuvwxyz".split("")
		length = Math.floor(Math.random() * chars.length)  unless length
		str = ""
		i = 0

		while i < length
			str += chars[Math.floor(Math.random() * chars.length)]
			i++

		str

	addCacheMap = ( type, id, origin_tab_id, region ) ->
		console.log 'addCacheMap', type, id, region
		cacheIDMap[ id ] = { 'type' : type, 'origin_tab_id' : origin_tab_id, 'region' : region }

	delCacheMap = ( id ) ->
		console.log 'delCacheMap', id
		delete cacheIDMap[ id ]

	setCacheMap = ( id, data ) ->
		console.log 'setCacheMap', id, data

		if getCacheMap id
			cacheIDMap[ id ].data = data
		else
			null

	getCacheMap = ( id ) ->
		console.log 'getCacheMap', id
		cacheIDMap[ id ]

	processType = ( id ) ->
		console.log 'processType', id

		# tab id sample process-cs6dbvrc
		if getCacheMap( id ) and getCacheMap( id ).type is 'appview'
			return 'appview'

		# tab id sample process-us-west-1-untitled-112
		else if id.split('-')[0] is 'process' and id.split( '-' ).length > 2
			return 'process'

		# undefined
		else
			return undefined

	#public
	isCurrentTab       : isCurrentTab

	searchStackAppById : searchStackAppById

	addProcess         : addProcess
	getProcess         : getProcess
	deleteProcess      : deleteProcess
	filterProcess      : filterProcess
	initDataProcess    : initDataProcess

	createUID          : createUID
	addCacheMap        : addCacheMap
	delCacheMap        : delCacheMap
	setCacheMap        : setCacheMap
	getCacheMap        : getCacheMap
	processType        : processType

	setCurrentTabId    : setCurrentTabId