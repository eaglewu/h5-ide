#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/model', 'constant', 'Design', "CloudResources" ], ( PropertyModel, constant, Design, CloudResources ) ->

  ASGModel = PropertyModel.extend {

    init : ( uid ) ->

        asg_comp = Design.instance().component( uid )
        if asg_comp.type is "ExpandedAsg"
          asg_comp = asg_comp.get("originalAsg")
          uid = asg_comp.get("id")
        data =
          uid        : uid
          name       : asg_comp.get 'name'
          description: asg_comp.get 'description'
          minSize    : asg_comp.get 'minSize'
          maxSize    : asg_comp.get 'maxSize'
          capacity   : asg_comp.get 'capacity'
          tags       : asg_comp.tags()
          isEditable : @isAppEdit

        @set data

        region = Design.instance().region()
        asg_data = CloudResources(Design.instance().credentialId(), constant.RESTYPE.ASG, region).get(asg_comp.get('appId'))?.toJSON()

        if asg_data
            @set 'hasData', true
            @set 'awsResName', asg_data.AutoScalingGroupName
            @set 'arn', asg_data.id
            @set 'createTime', asg_data.CreatedTime
            @set "tagSet", asg_data.tagSet
            if asg_data.TerminationPolicies and asg_data.TerminationPolicies
                @set 'term_policy_brief', asg_data.TerminationPolicies.join(" > ")

            @handleInstance asg_comp, asg_data

        if not @isAppEdit and asg_comp.type is constant.RESTYPE.ASG
            if not asg_data
                return false
            @set 'lcName',   asg_data.LaunchConfigurationName
            @set 'cooldown', asg_data.DefaultCooldown
            @set 'healCheckType', asg_data.HealthCheckType
            @set 'healthCheckGracePeriod', asg_data.HealthCheckGracePeriod
            @set 'notiTopicName', @getNotificationTopicName()

            @handlePolicy asg_comp, asg_data
            @handleNotify asg_comp, asg_data


        else
            data = asg_comp?.toJSON()
            data.uid = uid
            @set data
            lc = asg_comp.getLc()

            if not lc
                @set "emptyAsg", true
                return

            @set "has_elb", !!lc.connections("ElbAmiAsso").length
            @set "isEC2HealthCheck", asg_comp.isEC2HealthCheckType()
            @set 'detail_monitor', !!lc.get( 'monitoring' )

            # Notification
            n = asg_comp.getNotification()
            @set "notification", n
            @set "has_notification", n.instanceLaunch or n.instanceLaunchError or n.instanceTerminate or n.instanceTerminateError or n.test

            @notiObject = asg_comp.getNotiObject()

            # Policies
            @set "policies", _.map data.policies, ( p )->
                data = $.extend true, {}, p.attributes
                data.alarmData.period = Math.round( data.alarmData.period / 60 )
                data

        null

    handleInstance: ( asg_comp, asg_data ) ->
        # Get generated instances
        instance_count  = 0
        instance_groups = []
        instances_map   = {}

        if asg_data.Instances and asg_data.Instances
            instance_count = asg_data.Instances.length

            for instance, idx in asg_data.Instances
                ami =
                    status : if instance.HealthStatus is 'Healthy' then 'green' else 'red'
                    healthy: instance.HealthStatus
                    name   : instance.InstanceId

                az = instance.AvailabilityZone
                if instances_map[ az ]
                    instances_map[ az ].push ami
                else
                    instances_map[ az ] = [ ami ]

            for az, instances of instances_map
                instance_groups.push {
                    name : az
                    instances : instances
                }

        else
            instance_count = 0

        @set 'instance_groups', instance_groups
        @set 'instance_count',  instance_count

    handleNotify: ( asg_comp, asg_data ) ->
        # Get notifications
        region       = Design.instance().region()
        notification = CloudResources(Design.instance().credentialId(), constant.RESTYPE.NC, region).findWhere({AutoScalingGroupName:asg_data.AutoScalingGroupName})

        sendNotify = false
        nc_array = [false, false, false, false, false]
        nc_map   =
            "autoscaling:EC2_INSTANCE_LAUNCH" : 0
            "autoscaling:EC2_INSTANCE_LAUNCH_ERROR" : 1
            "autoscaling:EC2_INSTANCE_TERMINATE" : 2
            "autoscaling:EC2_INSTANCE_TERMINATE_ERROR" : 3
            "autoscaling:TEST_NOTIFICATION" : 4

        if notification
          for t in notification.get("NotificationType")
            nc_array[ nc_map[ t ] ] = true
            sendNotify = true

        @set 'notifies',   nc_array
        @set 'sendNotify', sendNotify

    handlePolicy: ( asg_comp, asg_data ) ->
        # Get policy
        policies = []
        cloudWatchPolicyMap = {}

        region = Design.instance().region()
        spCln  = CloudResources(Design.instance().credentialId(), constant.RESTYPE.SP, region)
        cwCln  = CloudResources(Design.instance().credentialId(), constant.RESTYPE.CW, region)

        for sp in asg_comp.get("policies")
            policy_data = spCln.get( sp.get 'appId' )?.toJSON()
            if not policy_data
                continue

            policy =
                adjusttype : policy_data.AdjustmentType
                adjustment : policy_data.ScalingAdjustment
                step       : policy_data.MinAdjustmentStep
                cooldown   : policy_data.Cooldown
                name       : policy_data.PolicyName
                arn        : sp.get 'appId'

            alarm_data  = cwCln.get( sp.get("alarmData").appId )?.toJSON()
            if alarm_data
                actions_arr = [ alarm_data.InsufficientDataActions, alarm_data.OKActions, alarm_data.AlarmActions ]
                trigger_arr = [ 'INSUFFICIANT_DATA', 'OK', 'ALARM' ]

                for actions, idx in actions_arr
                    if not actions then continue

                    for action in actions
                        if action isnt policy.arn
                            continue

                        # Set arn to empty if we have cloudwatch.
                        # So that view can show cloudwatch info.
                        policy.arn = ""

                        policy.evaluation = sp.get("alarmData").comparisonOperator
                        policy.metric     = alarm_data.MetricName
                        policy.notify     = actions.length is 2
                        policy.periods    = alarm_data.EvaluationPeriods
                        policy.minute     = Math.round( alarm_data.Period / 60 )
                        policy.statistics = alarm_data.Statistic
                        policy.threshold  = alarm_data.Threshold
                        policy.trigger    = trigger_arr[ idx ]
            else
                console.warn "handlePolicy():can not find CloudWatch info of ScalingPolicy"

            policies.push policy

            @set 'policies', _.sortBy(policies, "name")


    setHealthCheckType : ( type ) ->
      Design.instance().component( @get("uid") ).set( "healthCheckType", type )

    setASGMin : ( value ) ->

        uid = @get 'uid'

        Design.instance().component( uid ).set( "minSize", value )

        null

    setASGMax : ( value ) ->

        uid = @get 'uid'

        Design.instance().component( uid ).set( "maxSize", value )

        null

    setASGDesireCapacity : ( value ) ->

        uid = @get 'uid'

        Design.instance().component( uid ).set( "capacity", value )

        null

    setASGCoolDown : ( value ) ->
      Design.instance().component( @get("uid") ).set( "cooldown", value )

    setHealthCheckGrace : ( value ) ->
      Design.instance().component( @get("uid") ).set( "healthCheckGracePeriod", value )

    setNotification : ( notification )->
      n = Design.instance().component( @get("uid") ).setNotification( notification )
      @notiObject = n
      null

    removeTopic: ->
      n = Design.instance().component( @get("uid") ).setNotification( notification )
      n?.removeTopic()


    getNotificationTopicName: () ->
      Design.instance().component( @get("uid") ).getNotificationTopicName()

    setNotificationTopic: ( appId, name ) ->
      Design.instance().component( @get("uid") ).setNotificationTopic( appId, name )

    setTerminatePolicy : ( policies ) ->
      Design.instance().component( @get("uid") ).set("terminationPolicies", policies)
      @set "terminationPolicies", policies
      null

    delPolicy : ( uid ) ->
      Design.instance().component( uid ).remove()
      null

    isDupPolicyName : ( policy_uid, name ) ->
      _.some Design.instance().component( @get("uid") ).get("policies"), ( p ) ->
        if p.id isnt policy_uid and p.get( 'name' ) is name
          return true

    defaultScalingPolicyName : () ->
      component = Design.instance().component( @get("uid") )
      if component.type is "ExpandedAsg"
        component = component.get("originalAsg")
      policies = component.get("policies")
      count = policies.length
      name = "#{@attributes.name}-policy-#{count}"
      currentNames = _.map policies, ( policy ) ->
        policy.get 'name'

      while name in currentNames
        name = "#{@attributes.name}-policy-#{++count}"
      name

    getPolicy : ( uid )->
      data = $.extend true, {}, Design.instance().component( uid ).attributes
      data.alarmData.period = Math.round( data.alarmData.period / 60 )
      data

    setPolicy : ( policy_detail ) ->
      asg = Design.instance().component( @get("uid") )
      if asg.type is "ExpandedAsg"
        asg = asg.get('originalAsg')

      if policy_detail.sendNotification
        Design.modelClassForType( constant.RESTYPE.TOPIC ).ensureExistence()

      if not policy_detail.uid
        PolicyModel = Design.modelClassForType( constant.RESTYPE.SP )
        policy = new PolicyModel( policy_detail )
        asg.addScalingPolicy( policy )

        policy_detail.uid = policy.id
        @get("policies").push( policy?.toJSON() )

      else
        policy = Design.instance().component( policy_detail.uid )
        alarmData = policy_detail.alarmData
        policy.setAlarm( alarmData )
        delete policy_detail.alarmData
        policy.set policy_detail
        policy_detail.alarmData = alarmData

      if policy_detail.sendNotification and policy_detail.topic
        policy.setTopic policy_detail.topic.appId, policy_detail.topic.name

      null

  }

  new ASGModel()
