#############################
#  View Mode for dashboard(region)
#############################

define [ 'backbone', 'jquery', 'underscore', 'aws_model', 'constant' ], (Backbone, $, _, aws_model, constant) ->

    current_region = null
    resource_source = null

    #private
    RegionModel = Backbone.Model.extend {

        defaults :
            temp : null
            'resourse_list'         : null


        initialize : ->
            me = this

            aws_model.on 'AWS_RESOURCE_RETURN', ( result ) ->

                resource_source = result.resolved_data[current_region]

                me.setResource resource_source
                
                null


            null
            
        #temp
        temp : ->
            me = this
            null

        setResource : ( resources ) ->

            lists = {}

            elb = resources.DescribeLoadBalancers.LoadBalancerDescriptions

            if $.isEmptyObject elb then lists.ELB = 0 else if  elb.member.constructor == Array then lists.ELB = elb.member.length else lists.ELB = 1

                
            
            console.error lists

        describeAWSResourcesService : ( region )->

            me = this

            current_region = region

            resources = [
                constant.AWS_RESOURCE.INSTANCE
                constant.AWS_RESOURCE.EIP
                constant.AWS_RESOURCE.VOLUME
                constant.AWS_RESOURCE.VPC
                constant.AWS_RESOURCE.VPN
                constant.AWS_RESOURCE.ELB
            ]

            aws_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  resources

    }

    model = new RegionModel()

    return model