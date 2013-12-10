#############################
#  View Mode for component/unmanagedvpc
#############################

define [ 'aws_model', 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( aws_model, constant ) ->

    UnmanagedVPCModel = Backbone.Model.extend {

        defaults :
            'resource_list'    : null

        initialize : ->

            me = this

            @on 'AWS_RESOURCE_RETURN', ( result ) ->
                console.log 'AWS_RESOURCE_RETURN', result

                if result and not result.is_error and result.resolved_data

                    # create resoruces
                    resources = me.createResources result.resolved_data

                    # set vo
                    me.set 'resource_list', $.extend true, {}, resources

                    null

        getStatResourceService : ->
            console.log 'getStatResourceService'

            # set resources
            resources =
                'AWS.VPC.VPC'           : {}
                'AWS.ELB'               : {}
                'AWS.EC2.Instance'      : {}
                'AWS.VPC.RouteTable'    : {}
                'AWS.VPC.Subnet'        : {}
                'AWS.VPC.VPNGateway'    : {}
                'AWS.VPC.VPNConnection' : {}
                'AWS.AutoScaling.Group' : {}

            aws_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, resources, 'statistic', 1

            null

        createResources : ( data ) ->
            console.log 'createResources', data

            resources = {}

            try

                _.each data, ( obj, region ) ->

                    vpcs = {}
                    _.each obj, ( vpc_obj, vpc_id ) ->

                        l2_res = {
                            'AWS.VPC.VPC'                               : {'id':[vpc_id]},

                            'AWS.AutoScaling.Group'                     : {'id':[]},
                            'AWS.ELB'                                   : {'id':[]},
                            'AWS.VPC.DhcpOptions'                       : {'id':[]},
                            'AWS.VPC.CustomerGateway'                   : {'id':[]},
                            'AWS.AutoScaling.LaunchConfiguration'       : {'id':[]},    # asg name
                            'AWS.AutoScaling.NotificationConfiguration' : {'id':[]},    # asg name

                            'AWS.EC2.Instance'                          : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.RouteTable'                        : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.Subnet'                            : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.VPNGateway'                        : {'filter':{'attachment.vpc-id':vpc_id}},
                            'AWS.EC2.SecurityGroup'                     : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.NetworkAcl'                        : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.NetworkInterface'                  : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.InternetGateway'                   : {'filter':{'attachment.vpc-id':vpc_id}},
                            'AWS.EC2.AvailabilityZone'                  : {'filter':{'region-name':region}},

                            'AWS.EC2.EBS.Volume'                        : {'filter':{'attachment.instance-id':[]}},
                            'AWS.EC2.EIP'                               : {'filter':{'instance-id':[]}},
                            'AWS.VPC.VPNConnection'                     : {'filter':{'vpn-gateway-id':''}},
                            'AWS.AutoScaling.ScalingPolicy'             : {'filter':{'AutoScalingGroupName':[]}},
                        }

                        new_value = {}

                        _.each l2_res, ( attrs, type ) ->
                            filter = {}

                            # set id
                            if 'id' of attrs
                                if attrs['id'].length == 0
                                    if type of vpc_obj
                                        filter['id'] = _.keys(vpc_obj[type])

                                    if (type is 'AWS.AutoScaling.LaunchConfiguration' or type is 'AWS.AutoScaling.NotificationConfiguration') and 'AWS.AutoScaling.Group' of vpc_obj
                                        filter['id'] = _.keys(vpc_obj['AWS.AutoScaling.Group'])

                                else
                                    filter['id'] = attrs['id']

                            # set filter
                            if 'filter' of attrs
                                filter['filter'] = {}

                                for k, v of attrs['filter']
                                    if not v or v.length == 0
                                        if k in ['instance-id', 'attachment.instance-id'] and 'AWS.EC2.Instance' of vpc_obj
                                            filter['filter'][k] = _.keys(vpc_obj['AWS.EC2.Instance'])

                                        if k is 'vpn-gateway-id' and 'AWS.VPC.VPNGateway' of vpc_obj
                                            filter['filter'][k] = _.keys(vpc_obj['AWS.VPC.VPNGateway'])[0]

                                        if k is 'AutoScalingGroupName' and 'AWS.AutoScaling.Group' of vpc_obj
                                            filter['filter'][k] = _.keys(vpc_obj['AWS.AutoScaling.Group'])

                                    else

                                        filter['filter'][k] = attrs['filter'][k]

                            if 'id' of filter or 'filter' of filter
                                new_value[type] = filter

                        if _.keys(new_value).length > 0
                            vpcs[ vpc_id ] = new_value

                    resources[ region ] = vpcs

                console.log 'new resources is ', resources

            catch error
                console.log 'createResources error', error, data

            resources
    }

    return UnmanagedVPCModel