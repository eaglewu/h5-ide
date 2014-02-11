#############################
#  View Mode for design/property/instance
#############################

define [ "Design", "constant", 'lib/forge/app' ], ( Design, constant, forge_app ) ->

	SGListModel = Backbone.Model.extend {

		getSGInfoList : ->

			design       = Design.instance()
			parent_model = @parent_model

			readonly = false
			if design.modeIsApp() or design.modeIsAppView()
				readonly = true
			else if design.modeIsAppEdit()
				if parent_model.isSGListReadOnly
					readonly = parent_model.isSGListReadOnly()

			resource_id = parent_model.get("uid")
			resource = design.component( resource_id )

			if resource
				isELBParent   = resource.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
				isStackParent = false
				resource_id   = resource.id
			else
				isELBParent   = false
				isStackParent = true
				resource_id   = ""

			sg_list  = []

			enabledSG    = {}
			enabledSGArr = []

			SgAssoModel = Design.modelClassForType( "SgAsso" )

			## ## ## Get All SG
			for sg in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).allObjects()
				# Ignore ElbSG if the property panel is not stack/elb
				if sg.isElbSg() and not ( isELBParent or isStackParent )
					continue

				sgChecked = !!SgAssoModel.findExisting( sg, resource )

				needShow = isStackParent or ( not readonly ) or sgChecked
				if not needShow
					continue

				if sg.isDefault() or readonly or sg.get("appId")
					deletable = false
				else
					deletable = true

				assos = sg.connections( "SgAsso" )
				# SgAsso is a connection to represent SG <=> Resource
				# See what SG is used by this resource
				for asso in assos
					if asso.connectsTo( resource_id )
						enabledSG[ sg.id ] = true
						enabledSGArr.push sg
						break

				sg_list.push {
					uid         : sg.id
					color       : sg.color
					name        : sg.get("name")
					desc        : sg.get("description")
					ruleCount   : sg.ruleCount()
					memberCount : assos.length
					hideCheck   : readonly or isStackParent
					deletable   : deletable
					used        : enabledSG[ sg.id ]
				}


			## ## ## Get All Rules
			# SgRuleSet is a connection to represent SG <=> SG
			sgRuleAry = []
			for usedSG in enabledSGArr
				ruleSets = usedSG.connections( "SgRuleSet" )
				for ruleset in ruleSets
 					sgRuleAry = sgRuleAry.concat( ruleset.toPlainObjects( usedSG.id ) )


			SgRuleSetModel = Design.modelClassForType( "SgRuleSet" )

			# Set
			@set {
				is_stack_sg  : isStackParent
				only_one_sg  : enabledSGArr.length is 1
				sg_list      : sg_list
				sg_length    : if isStackParent then sg_list.length else enabledSGArr.length
				readonly     : readonly
				# Remove duplicate rules
				sg_rule_list : SgRuleSetModel.getPlainObjFromRuleSets( sgRuleAry )
			}

			@sortSGList()
			@sortSGRule()
			null

		sortSGList : ()->
			@attributes.sg_list = @attributes.sg_list.sort ( a_sg, b_sg )->
				if a_sg.name is "DefaultSG" then return -1
				if b_sg.name is "DefaultSG" then return 1
				if a_sg.name <  b_sg.name   then return -1
				if a_sg.name == b_sg.name   then return 0
				if a_sg.name >  b_sg.name   then return 1
			@attributes.sg_list


		sortSGRule : ( key )->
			sgRuleList = _.sortBy @attributes.sg_rule_list, ( key or "direction" )
			@set "sg_rule_list", sgRuleList
			null

		assignSG : ( sgUID, sgChecked ) ->

			SgAsso = Design.modelClassForType( "SgAsso" )
			design = Design.instance()

			uid = @parent_model.get("uid")

			console.assert( uid, "Resource not found when assigning SG" )

			# If an old SgAsso is created, new will return that old SgAsso
			asso = new SgAsso( design.component( uid ), design.component( sgUID ) )

			if sgChecked is false
				asso.remove()
			null

		deleteSG : (sgUID) ->
			Design.instance().component( sgUID ).remove()
			null

		isElbSg : (sgUID)->
			Design.instance().component( sgUID ).isElbSg()

		getElbNameBySgId : (sgUID)->
			sg = Design.instance().component( sgUID )
			if sg.isElbSg()
				for elb in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_ELB ).allObjects()
					if elb.getElbSg() is sg
						return elb.get("name")

			""

		createNewSG : ()->
			SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
			model = new SgModel()
			component = Design.instance().component( @parent_model.get("uid") )
			if component
				SgAsso = Design.modelClassForType("SgAsso")
				new SgAsso( model, component )
			model.id

	}

	new SGListModel()
