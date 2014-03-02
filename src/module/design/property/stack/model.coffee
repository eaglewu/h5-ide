#############################
#  View Mode for design/property/stack
#############################

define ['../base/model', 'constant', "Design" ], ( PropertyModel, constant, Design ) ->

  typeMap =
    'ec2-classic' : 'EC2 Classic'
    'ec2-vpc'     : 'EC2 VPC'
    'default-vpc' : 'Default VPC'
    'custom-vpc'  : 'Custom VPC'

  StackModel = PropertyModel.extend {

    init : () ->

      design = Design.instance()

      agentData = design.get('agent')

      @set {
        name      : design.get("name").replace(/\s+/g, '')
        id        : design.get("id")
        usage     : design.get("usage")
        type      : typeMap[ design.type() ]
        region    : constant.REGION_SHORT_LABEL[ design.region() ]
        isApp     : @isApp
        isAppEdit : @isAppEdit
        isStack   : @isStack
        isImport  : design.modeIsAppView()
        opsEnable : agentData.enabled
      }

      vpc = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC()
      if vpc then @set "vpcid", vpc.get("appId")

      @getNetworkACL()

      if @isApp
        @getAppSubscription()
      else
        @getSubscription()

      if @isStack
        @set 'isStack', true


      @set Design.instance().getCost()
      null

    addSubscription : ( data ) ->

      SubscriptionModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription )

      subs = @get("subscription")

      if not data.uid
        sub_comp = new SubscriptionModel( data )
        sub = sub_comp.toJSON()
        sub.confirmed = true
        subs.push sub
      else
        sub_comp = Design.instance().component( data.uid )
        sub_comp.set("protocol", data.protocol)
        sub_comp.set("endpoint", data.endpoint)
        for sub, idx in subs
          if sub.id is data.uid
            sub.protocol = data.protocol
            sub.endpoint = data.endpoint
            sub.confirmed= data.confirmed
            break
      null

    deleteSNS : ( uid ) ->

      sub_list = @get 'subscription'
      for sub, idx in sub_list
        if sub.id is uid
          sub_list.splice idx, 1
          break

      Design.instance().component(uid).remove()
      null

    getSubscription : () ->

      SubscriptionModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription )
      TopicModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic )



      subs = _.map SubscriptionModel.allObjects(), ( sub )-> sub.toJSON()
      subState = @getSubState()

      #set confirmed of subscription
      for sub in subs
        if subState and subState[ sub.protocol + "-" + sub.endpoint ] is false
          sub.confirmed = false
        else
          sub.confirmed = true

      @set "subscription", subs
      @set "has_asg", TopicModel.isTopicNeeded()
      null

    getSubState : () ->

      TopicModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic )
      topic = TopicModel.allObjects()[0]
      if topic
        topic_arn = topic.get("appId")

      subRes   = MC.data.resource_list[ Design.instance().region() ].Subscriptions
      subState = {}

      if topic_arn and subRes
        for sub in subRes
          # Ignore Subscription that has `topic` attribute
          if sub.TopicArn is topic_arn
            subState[ sub.Protocol + "-" + sub.Endpoint ] = sub.SubscriptionArn isnt "PendingConfirmation"

      subState


    getAppSubscription : () ->

      TopicModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic )
      topic = TopicModel.allObjects()[0]
      if topic
        topic_arn = topic.get("appId")
        @set 'snstopic', {
          name : topic.get("name")
          arn  : topic_arn
        }

      subs = MC.data.resource_list[ Design.instance().region() ].Subscriptions
      subscription = []

      if topic_arn and subs
        for sub in subs
          # Ignore Subscription that has `topic` attribute
          if sub.TopicArn is topic_arn
            subscription.push {
              protocol : sub.Protocol
              endpoint : sub.Endpoint
              arn      : sub.SubscriptionArn
              confirmed: sub.SubscriptionArn isnt "PendingConfirmation"
            }

      @set 'subscription', subscription

    createAcl : ()->
      ACLModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )
      (new ACLModel()).id

    getNetworkACL : ()->

      if not Design.instance().typeIsVpc()
        return

      ACLModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )

      networkAcls = []
      defaultACL  = null

      _.each ACLModel.allObjects(), ( acl )->

        deletable = true
        if Design.instance().modeIsApp()
          deletable = false
        else if acl.isDefault()
          deletable = false
        else if Design.instance().modeIsAppEdit()
          # If the acl has appId, deletable is false
          deletable = not acl.get("appId")

        aclObj = {
          uid         : acl.id
          name        : acl.get("name")
          rule        : acl.getRuleCount()
          association : acl.getAssoCount()
          deletable   : deletable
        }

        if acl.isDefault()
          defaultACL = aclObj
        else
          networkAcls.splice( _.sortedIndex( networkAcls, aclObj, "name" ), 0, aclObj )

        null

      if defaultACL
        networkAcls.splice( 0, 0, defaultACL )

      @set "networkAcls", networkAcls
      null

    removeAcl : ( acl_uid )->
      Design.instance().component( acl_uid ).remove()
      @getNetworkACL()
      null

    setAgentEnable : (isEnable) ->

      if isEnable is true

        # clear all instance userdata
        InstanceModel = Design.modelClassForType(constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance)
        instanceModels = InstanceModel.allObjects()
        _.each instanceModels, (instanceModel) ->
          instanceModel.set('userData', '')
          null

        # clear all lc userdata
        LCModel = Design.modelClassForType(constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration)
        lcModels = LCModel.allObjects()
        _.each lcModels, (lcModel) ->
          lcModel.set('userData', '')
          null

      MC.aws.aws.enableStackAgent(isEnable)

    isAllInstanceNotHaveUserData : () ->

      result = true

      # find all instance userdata
      InstanceModel = Design.modelClassForType(constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance)
      instanceModels = InstanceModel.allObjects()
      _.each instanceModels, (instanceModel) ->
        userData = instanceModel.get('userData')
        if userData then result = false
        null

      # find all lc userdata
      LCModel = Design.modelClassForType(constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration)
      lcModels = LCModel.allObjects()
      _.each lcModels, (lcModel) ->
        userData = lcModel.get('userData')
        if userData then result = false
        null

      return result

  }

  new StackModel()
