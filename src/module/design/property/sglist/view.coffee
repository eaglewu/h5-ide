#############################
#  View(UI logic) for design/property/sglist
#############################

define [ 'text!./template/stack.html' ], ( template ) ->

	template = Handlebars.compile template

	SGListView = Backbone.View.extend {

		events   :
			'click #sg-info-list .sg-edit-icon'    : 'openSgPanel'
			'click #add-sg-btn'                    : 'openSgPanel'
			'click .sg-list-association-check'     : 'assignSGToComp'
			'click .sg-list-delete-btn'            : 'deleteSGFromComp'
			'OPTION_CHANGE #sg-rule-filter-select' : 'sortSgRule'

		render     : () ->
			@model.getSGInfoList()
			@model.getRuleInfoList()

			@setElement $('.sg-group')
			@$el.html template @model.attributes
			$('#property-head-sg-num').text( @model.attributes.sg_length )

		openSgPanel : ( event ) ->
			sgUID = $(event.target).parents('li').attr('sg-uid')
			if !sgUID
				sgUID = MC.aws.sg.createNewSG()
				this.trigger 'ASSIGN_SG_TOCOMP', sgUID, true

			this.trigger 'OPEN_SG', sgUID

		refreshSGList: () ->
			this.render()

		assignSGToComp: (event) ->
			$target  = $(event.currentTarget)
			$checked = $target.closest("#sg-info-list").find(":checked")

			if $checked.length is 0
				return false

			sgUID     = $target.attr('sg-uid')
			sgChecked = $target.prop('checked')
			this.trigger 'ASSIGN_SG_TOCOMP', sgUID, sgChecked
			this.render()
			$('#property-head-sg-num').text(this.model.attributes.sg_length)

		deleteSGFromComp : (event) ->

			that = this

			$target = $(event.currentTarget)
			sgUID = $target.parents('li').attr('sg-uid')

			memberNum = Number($target.attr('members'))
			sgName = $target.attr('sg-name')

			# show dialog to confirm that delete sg
			if memberNum
				mainContent = 'Are you sure you want to delete ' + sgName + '?'
				descContent = 'The firewall settings of ' + sgName + '\'s member will be affected. Member only has this security group will be using DefaultSG.'
				template = MC.template.modalDeleteSGOrACL {
					title : 'Delete Security Group',
					main_content : mainContent,
					desc_content : descContent
				}
				modal template, false, () ->
					$('#modal-confirm-delete').click () ->
						that.trigger 'DELETE_SG_FROM_COMP', sgUID
						that.render()
						modal.close()

			else
				that.trigger 'DELETE_SG_FROM_COMP', sgUID
				that.render()

		sortSgRule : ( event ) ->
			sg_rule_list = $('#sglist-rule-list')

			sortType = $(event.target).find('.selected').attr('data-id')

			sorted_items = $('#sglist-rule-list li')
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

	new SGListView()
