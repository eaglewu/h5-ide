#############################
#  View(UI logic) for design/property/sg
#############################

define [ 'event', 'MC', 'constant', 'backbone', 'jquery', 'handlebars', 'UI.editablelabel' ], ( ide_event, MC, constant ) ->

	InstanceView = Backbone.View.extend {

		el       : $ document
		tagName  : $ '#sg-secondary-panel-wrap'

		template : Handlebars.compile $( '#property-sg-tmpl' ).html()

		app_template : Handlebars.compile $( '#property-sg-app-tmpl' ).html()

		instance_expended_id : 0

		events   :
			#for sg rule
			'click .rule-edit-icon'   : 'showEditRuleModal'
			'click #sg-add-rule-icon' : 'showCreateRuleModal'
			'click .rule-remove-icon' : 'removeRulefromList'

			#for sg modal
			'click #sg-modal-direction input'          : 'radioSgModalChange'
			'OPTION_CHANGE #modal-protocol-select'     : 'sgModalSelectboxChange'
			'OPTION_CHANGE #protocol-icmp-main-select' : 'icmpMainSelect'
			'OPTION_CHANGE .protocol-icmp-sub-select'  : 'icmpSubSelect'
			'click #sg-modal-save'                     : 'saveSgModal'
			'click .editable-label'                    : 'editablelabelClick'
			'change #sg-protocol-tcp input'            : 'tcpValueChange'
			'change #sg-protocol-udp input'            : 'udpValueChange'
			'change #sg-protocol-custom input'         : 'customValueChange'

			#for sg detail
			'change #securitygroup-name'           : 'setSGName'
			'change #securitygroup-description'    : 'setSGDescription'
			'OPTION_CHANGE #sg-rule-filter-select' : 'sortSgRule'

			'OPTION_CHANGE #sg-add-model-source-select' : 'modalRuleSourceSelected'

		render     : (is_app_view) ->

			if is_app_view

				$dom = this.app_template this.model.attributes

			else

				if this.model.attributes.sg_detail.component.name == 'DefaultSG'
					this.model.attributes.isDefault = true
				else
					this.model.attributes.isDefault = false

				$dom = this.template this.model.attributes

			# Right now, hack to focus the input. Find a better way later
			setTimeout ()->
				input = $('#securitygroup-name').focus()[0]
				input.focus() if input
			, 200

			$dom

		#SG SecondaryPanel
		showEditRuleModal : (event) ->
			if this.model.get('is_elb_sg') then return
			modal MC.template.modalSGRule {isAdd:false}, true

		showCreateRuleModal : (event) ->
			if this.model.get('is_elb_sg') then return
			isclassic = false
			if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC
				isclassic = true

			# get sg list
			sgList = []
			_.each MC.canvas_data.component, (compObj) ->
				if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
					if !MC.aws.elb.isELBDefaultSG(compObj.uid)
						sgList.push({
							sgName: compObj.name
							sgUID: compObj.uid
						})
				null


			modal MC.template.modalSGRule {isAdd:true, isclassic: isclassic, sgList: sgList}, true
			return false

		removeRulefromList: (event, id) ->
			if this.model.get('is_elb_sg') then return
			rule = {}
			li_dom = $(event.target).parents('li').first()
			rule.inbound = li_dom.data('inbound')
			rule.protocol = li_dom.data('protocol')
			rule.fromport = li_dom.data('fromport')
			rule.toport = li_dom.data('toport')
			rule.iprange = li_dom.data('iprange')
			# sg_uid = $("#sg-secondary-panel").attr "uid"
			this.trigger 'REMOVE_SG_RULE', rule
			$(event.target).parents('li').first().remove()

			ruleCount =$("#sg-rule-list").children().length
			$("#sg-rule-empty").toggle ruleCount == 0
			$("#rule-count").text ruleCount

		radioSgModalChange : (event) ->
			if $('#sg-modal-direction input:checked').val() is "inbound"
				$('#rule-modal-ip-range').text "Source"
			else
				$('#rule-modal-ip-range').text "Destination"

		sgModalSelectboxChange : (event, id) ->
			$('#sg-protocol-select-result').find('.show').removeClass('show')
			$('.sg-protocol-option-input').removeClass("show")
			$('#sg-protocol-' + id).addClass('show')
			$('#modal-protocol-select').data('protocal-type', id)
			null

		icmpMainSelect : ( event, id ) ->
			$("#protocol-icmp-main-select").data('protocal-main', id)
			if id is "3" || id is "5" || id is "11" || id is "12"
				$( '#protocol-icmp-sub-select-' + id).addClass('shown')
			else
				$('.protocol-icmp-sub-select').removeClass('shown')

		icmpSubSelect : ( event, id ) ->
			$("#protocol-icmp-main-select").data('protocal-sub', id)

		setSGName : ( event ) ->
			id = @model.get( 'sg_detail' ).component.uid
			target = $ event.currentTarget
			name = target.val()

			MC.validate.preventDupname target, id, name, 'SG'

			if target.parsley 'validate'
				this.trigger 'SET_SG_NAME', name

			parentCompUID = $('#property-panel').attr('component-uid')
			MC.aws.sg.updateSGColorLabel(parentCompUID)

		setSGDescription : ( event ) ->
			# sg_uid = $("#sg-secondary-panel").attr "uid"
			this.trigger 'SET_SG_DESC', event.target.value

		saveSgModal : ( event ) ->
			sg_direction = $('#sg-modal-direction input:checked').val()
			descrition_dom = $('#securitygroup-modal-description')
			tcp_port_dom = $('#sg-protocol-tcp input')
			udp_port_dom = $('#sg-protocol-udp input')
			custom_protocal_dom = $( '#sg-protocol-custom input' )
			protocol_type =  $('#modal-protocol-select').data('protocal-type')
			rule = {}

			sourceValue = $.trim($('#sg-add-model-source-select').find('.selected').attr('data-id'))

			# sgUID = @model.get( 'sg_detail' ).component.uid
			# sgName = @model.get( 'sg_detail' ).component.name
			sgUID = ''
			sgName = ''
			if descrition_dom.hasClass('input')
				if sourceValue isnt 'custom'
					selectDom = $('#sg-add-model-source-select').find('.selected')
					sgUID = selectDom.attr('data-sg-uid')
					sgName = selectDom.text()
					sg_descrition = '@' + sgUID + '.resource.GroupId'
				else
					sg_descrition = descrition_dom.val()
			else
				sg_descrition = descrition_dom.html()

			# validation #####################################################
			validateMap =
				'custom':
					dom: custom_protocal_dom
					method: ( val ) ->
						if not MC.validate.portRange(val)
							return 'Must be a valid format of number.'
						if Number(val) < 0 or Number(val) > 255
							return 'The protocol number range must be 0-255.'
						null
				'tcp':
					dom: tcp_port_dom
					method: ( val ) ->
						portAry = []
						portAry = MC.validate.portRange(val)
						if not portAry
							return 'Must be a valid format of port range.'
						if not MC.validate.portValidRange(portAry)
							return 'Port range needs to be a number or a range of numbers between 0 and 65535.'
						null
				'udp':
					dom: udp_port_dom
					method: ( val ) ->
						portAry = []
						portAry = MC.validate.portRange(val)
						if not portAry
							return 'Must be a valid format of port range.'
						if not MC.validate.portValidRange(portAry)
							return 'Port range needs to be a number or a range of numbers between 0 and 65535.'
						null

			if protocol_type of validateMap
				needValidate = validateMap[ protocol_type ]
				needValidate.dom.parsley 'custom', needValidate.method

			descrition_dom.parsley 'custom', ( val ) ->
				if !MC.validate 'cidr', val
					return 'Must be a valid form of CIDR block.'
				null

			if (sourceValue is 'custom' and (not descrition_dom.parsley 'validate')) or (needValidate and not needValidate.dom.parsley 'validate')
				return
			# validation #####################################################

			rule.protocol = protocol_type
			protocol_val = $("#protocol-icmp-main-select").data('protocal-main')
			protocol_val_sub = $("#protocol-icmp-main-select").data('protocal-sub')
			switch protocol_type
				when "tcp", "udp"
					protocol_val = $( '#sg-protocol-' + protocol_type + ' input' ).val()
					if '-' in protocol_val
						rule.fromport = protocol_val.split('-')[0].trim()
						rule.toport = protocol_val.split('-')[1].trim()
					else
						rule.fromport = protocol_val
						rule.toport = protocol_val

				when "icmp"
					rule.fromport = protocol_val
					rule.toport = protocol_val_sub

				when "custom"
					rule.protocol = $( '#sg-protocol-custom input' ).val()
					rule.fromport = ""
					rule.toport = ""

				when "all"
					rule.protocol = -1
					rule.fromport = ""
					rule.toport = ""

			rule.direction = sg_direction

			if sourceValue is 'custom'
				rule.ipranges = sg_descrition
			else
				rule.ipranges = sgName

			# sg_uid = $("#sg-secondary-panel").attr "uid"
			# cur_count = Number $("#rule-count").text()
			# cur_count = cur_count + 1
			# $("#rule-count").text cur_count
			# $("#sg-rule-list").append MC.template.sgRuleItem {rule:rule}

			# $("#sg-rule-empty").toggle cur_count == 0

			rule.ipranges = sg_descrition

			this.trigger "SET_SG_RULE", rule

			uid = @model.get( 'sg_detail' ).component.uid
			@model.getSG(uid)
			$dom = this.render()
			$("#property-second-panel").find(".property-content").html($dom)

			MC.canvas.reDrawSgLine()

			modal.close()

		editablelabelClick : ( event ) ->
			editablelabel.create.call $(event.target)

		tcpValueChange : ( event ) ->
			#protocol_val = $( '#sg-protocol-tcp input' ).val()
			null

		udpValueChange : ( event ) ->
			#protocol_val = $( '#sg-protocol-udp input' ).val()
			null

		customValueChange : ( event ) ->
			#protocol_val = $( '#sg-protocol-custom input' ).val()
			null

		modalRuleSourceSelected : (event) ->
			value = $.trim($(event.target).find('.selected').attr('data-id'))

			if value is 'custom'
				$('#securitygroup-modal-description').show()
				$('#sg-add-model-source-select .selection').width(69)
			else
				$('#securitygroup-modal-description').hide()
				$('#sg-add-model-source-select .selection').width(255)

			null

		sortSgRule : ( event ) ->
			sg_rule_list = $('#sg-rule-list')

			sortType = $(event.target).find('.selected').attr('data-id')

			sorted_items = $('#sg-rule-list li')
			if sortType is 'direction'
				sorted_items = sorted_items.sort(this._sortDirection)
			else if sortType is 'source/destination'
				sorted_items = sorted_items.sort(this._sortSource)
			else if sortType is 'protocol'
				sorted_items = sorted_items.sort(this._sortProtocol)

			sg_rule_list.html sorted_items

		_sortDirection : ( a, b) ->
			return $(a).attr('data-direction') >
				$(b).attr('data-direction')

		_sortProtocol : ( a, b) ->
			return $(a).attr('data-protocol') >
				$(b).attr('data-protocol')

		_sortSource : ( a, b) ->
			return $(a).attr('data-iprange') >
				$(b).attr('data-iprange')
	}

	view = new InstanceView()

	return view
