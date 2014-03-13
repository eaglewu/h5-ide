#############################
#  View Mode for design/resource
#############################

define [ 'i18n!nls/lang.js',
         'ec2_service', 'ebs_model', 'aws_model', 'ami_model', 'favorite_model', 'MC', 'constant', 'event', 'subnet_model', 'Design',
         'backbone', 'jquery', 'underscore'
], ( lang, ec2_service, ebs_model, aws_model, ami_model, favorite_model, MC, constant, ide_event, subnet_model, Design ) ->

    #private
    ami_instance_type = null
    community_ami = {}

    ResourcePanelModel = Backbone.Model.extend {

        defaults :
            'availability_zone'  : null
            'resource_snapshot'  : null
            'quickstart_ami'     : null
            'my_ami'             : null
            'favorite_ami'       : null
            'community_ami'      : null
            'check_required_service_count' : null

        # max service count is 2
        # include describeAvailableZonesService and quickstartService
        service_count : 0

        initialize : ->

            me = this

            ######listen EC2_EBS_DESC_SSS_RETURN
            me.on 'EC2_EBS_DESC_SSS_RETURN', ( result ) ->
                console.log 'EC2_EBS_DESC_SSS_RETURN'

                region_name = result.param[3]

                if !result.is_error

                    me.set 'resource_snapshot', result.resolved_data
                    MC.data.config[region_name].snapshot_list = result.resolved_data

                null

            ######listen AWS_QUICKSTART_RETURN
            me.on 'AWS_QUICKSTART_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'AWS_QUICKSTART_RETURN: ' + region_name

                if !result.is_error

                    ami_list = []
                    ami_instance_type = result.resolved_data.ami_instance_type
                    region_ami_instance_type = result.resolved_data.region_ami_instance_type

                    if not MC.data.instance_type
                        MC.data.instance_type = {}
                    MC.data.instance_type[result.param[3]] = ami_instance_type

                    # new ami <=> instance type info data
                    if region_ami_instance_type
                        if not MC.data.region_instance_type
                            MC.data.region_instance_type = {}
                        MC.data.region_instance_type[result.param[3]] = region_ami_instance_type

                    # get instance type info for constant.INSTANCE_TYPE
                    instanceTypeMap = {}
                    instanceTypeData = result.resolved_data.instance_type
                    _.each instanceTypeData, (value1, key1) ->
                        _.each value1, (value2, key2) ->
                            try
                                descStr = value2.description
                                nameStr = value2.name
                                descAry = descStr.split(',')
                                newDescAry = ['', '', '', '']

                                _.each descAry, (str, idx) ->
                                    newStr = $.trim(str)
                                    if idx < 3
                                        newDescAry[idx + 1] = newStr
                                    else
                                        newDescAry[0] = nameStr
                                    null

                                typeStr = key1 + '.' + key2
                                instanceTypeMap[typeStr] = newDescAry
                            catch err
                                console.log(err)
                            null
                        null
                    constant.INSTANCE_TYPE = instanceTypeMap

                    _.map result.resolved_data.ami, ( value, key ) ->

                        value.imageId = key

                        _.map value, ( val, key ) ->
                            if val == ''
                                value[key] = 'None'
                            null

                        if value.kernelId == undefined or value.kernelId == ''
                            value.kernelId = "None"

                        #cache quickstart ami item to MC.data.dict_ami
                        value.osType = MC.aws.ami.getOSType(value)
                        if not value.osFamily
                            value.osFamily = MC.aws.aws.getOSFamily(value.osType)
                        instanceTypeAry = MC.aws.ami.getInstanceType(value)

                        value.instance_type = instanceTypeAry.join ', '
                        MC.data.dict_ami[key] = value

                        ami_list.push value
                        null

                    #sort ami list
                    ami_list.sort (a, b) ->
                        if a.osType > b.osType
                            return 1
                        else if a.osType < b.osType
                            return -1
                        else
                            return if a.architecture >= b.architecture then 1 else -1

                    # filter nat ami when in classic style
                    quickstart_amis = []

                    # old design flow
                    #if MC.canvas_data.platform is 'ec2-classic'

                    # new design flow
                    if Design.instance().typeIsClassic()
                        quickstart_amis.push i for i in ami_list when i.name.indexOf('ami-vpc-nat') < 0
                    else
                        quickstart_amis =  ami_list

                    console.log 'get quistart ami: -> data region: ' + region_name + ', stack region: ' + Design.instance().region()
                    if region_name == Design.instance().region()
                        me.set 'quickstart_ami', quickstart_amis

                    #cache config data for current region
                    MC.data.config[region_name].ami                 = result.resolved_data.ami
                    MC.data.config[region_name].ami_instance_type   = result.resolved_data.ami_instance_type
                    MC.data.config[region_name].region_instance_type = result.resolved_data.region_instance_type
                    if result.resolved_data.region_ami_instance_type
                        MC.data.config[region_name].region_ami_instance_type   = result.resolved_data.region_ami_instance_type
                    MC.data.config[region_name].instance_type       = result.resolved_data.instance_type
                    MC.data.config[region_name].price               = result.resolved_data.price
                    MC.data.config[region_name].vpc_limit           = result.resolved_data.vpc_limit
                    # reset az
                    MC.data.config[region_name].zone                = null
                    if MC.common.cookie.getCookieByName('has_cred') isnt 'true'
                        MC.data.config[region_name].zone = {'item':[]}
                        MC.data.config[region_name].zone.item.push {'regionName':region_name, 'zoneName':i, 'zoneState':'available'} for i in result.resolved_data.zone

                    MC.data.config[region_name].ami_list = ami_list

                    MC.data.config[region_name].favorite_ami = null
                    MC.data.config[region_name].my_ami = null

                    #get my AMI
                    me.myAmiService region_name

                    #get favorite AMI
                    me.favoriteAmiService region_name

                    # service_count +1
                    me.stackLoadDepend 'quickstartService:NEW'

                    #describe ami in stack
                    me.describeStackAmiService region_name

                    ide_event.trigger ide_event.RESOURCE_QUICKSTART_READY, region_name

                else
                    # to do

                #
                null

            ######listen EC2_AMI_DESC_IMAGES_RETURN
            me.on 'EC2_AMI_DESC_IMAGES_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'EC2_AMI_DESC_IMAGES_RETURN: ' + region_name

                if !result.is_error and result.param[5] and result.param[5][0] and result.param[5][0] == 'self'
                #####my ami

                    console.log 'EC2_AMI_DESC_IMAGES_RETURN: My AMI'

                    my_ami_list = {}

                    #cache my ami to my_ami
                    MC.data.config[region_name].my_ami = {}

                    if result.resolved_data

                        _.map result.resolved_data, (value)->
                            #cache my ami item to MC.data.dict_ami
                            try
                                value.osType = MC.aws.ami.getOSType value
                                if not value.osFamily
                                    value.osFamily = MC.aws.aws.getOSFamily(value.osType)
                                instanceTypeAry = MC.aws.ami.getInstanceType(value)
                                value.instanceType = instanceTypeAry.join ', '
                                MC.aws.ami.convertBlockDeviceMapping value
                                MC.data.dict_ami[value.imageId] = value
                            catch err
                                console.info 'Resolve My AMI error'
                                return true
                            null

                        my_ami_list = result.resolved_data

                        MC.data.config[region_name].my_ami = result.resolved_data


                    console.log 'get my ami: -> data region: ' + region_name + ', stack region: ' + Design.instance().region()
                    if region_name == Design.instance().region()
                        me.set 'my_ami', my_ami_list

                else
                #####

                    console.log 'EC2_AMI_DESC_IMAGES_RETURN:'

                    if result.resolved_data
                        _.map result.resolved_data, (value)->

                            #cache ami item in stack to MC.data.dict_ami
                            value.osType = MC.aws.ami.getOSType value
                            if not value.osFamily
                                value.osFamily = MC.aws.aws.getOSFamily(value.osType)
                            instanceTypeAry = MC.aws.ami.getInstanceType(value)
                            value.instanceType = instanceTypeAry.join ', '
                            MC.aws.ami.convertBlockDeviceMapping value
                            MC.data.dict_ami[value.imageId] = value

                            null

                null

            ######listen AWS__PUBLIC_RETURN
            me.on 'AWS__PUBLIC_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'AWS__PUBLIC_RETURN: ' + region_name

                community_ami_list = {}

                if !result.is_error and  result.resolved_data
                    community_ami_list = _.extend result.resolved_data.ami, {timestamp: ( new Date() ).getTime()}
                    favorite_ami_ids = _.pluck ( me.get 'favorite_ami' ), 'resource_id'

                    for key, value of community_ami_list.result
                        if _.contains favorite_ami_ids, key
                            value.favorite = true


                    console.log 'get community ami: -> data region: ' + region_name + ', stack region: ' + Design.instance().region()
                    if region_name == Design.instance().region()
                        me.set 'community_ami', community_ami_list

                else

                    notification 'warning', lang.ide.RES_MSG_WARN_GET_COMMUNITY_AMI_FAILED

                null

            ######listen FAVORITE_INFO_RETURN
            me.on 'FAVORITE_INFO_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'FAVORITE_INFO_RETURN: ' + region_name


                legalData = _.filter result.resolved_data, (value, key) ->
                    return value.resource_info

                _.map legalData, ( value, key ) ->

                    value.resource_info = JSON.parse value.resource_info

                    _.map value.resource_info, ( val, key ) ->
                        if val == ''
                            value.resource_info[key] = 'None'

                        null

                    #cache favorite ami item to MC.data.dict_ami

                    value.resource_info.imageId         = value.resource_id
                    value.resource_info.osType = MC.aws.ami.getOSType value.resource_info
                    if not value.resource_info.osFamily
                        value.resource_info.osFamily = MC.aws.aws.getOSFamily(value.resource_info.osType)
                    instanceTypeAry = MC.aws.ami.getInstanceType(value.resource_info)
                    value.resource_info.instanceType    = instanceTypeAry.join ', '
                    MC.data.dict_ami[value.resource_id] = value.resource_info

                    null


                console.log 'get favorite ami: -> data region: ' + region_name + ', stack region: ' + Design.instance().region()
                if region_name == Design.instance().region()
                    me.set 'favorite_ami', legalData

                #cache favorite_ami
                MC.data.config[region_name].favorite_ami = {}
                MC.data.config[region_name].favorite_ami = legalData

                null

            #####listen FAVORITE_ADD_RETURN
            me.on 'FAVORITE_ADD_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'FAVORITE_ADD_RETURN: ' + region_name

                if !result.is_error
                    delete MC.data.config[region_name].favorite_ami
                    me.favoriteAmiService region_name
                    notification 'info', lang.ide.RES_MSG_INFO_ADD_AMI_FAVORITE_SUCCESS
                else
                    notification 'error', lang.ide.RES_MSG_ERR_ADD_FAVORITE_AMI_FAILED
                null

            #listen FAVORITE_REMOVE_RETURN
            me.on 'FAVORITE_REMOVE_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'FAVORITE_REMOVE_RETURN: ' + region_name
                if !result.is_error
                    delete MC.data.config[region_name].favorite_ami
                    me.favoriteAmiService region_name
                    notification 'info', lang.ide.RES_MSG_INFO_REMVOE_FAVORITE_AMI_SUCCESS
                else
                    notification 'error', lang.ide.RES_MSG_ERR_REMOVE_FAVORITE_AMI_FAILED


                null

            #listen VPC_SNET_DESC_SUBNETS_RETURN
            me.on 'VPC_SNET_DESC_SUBNETS_RETURN', ( result ) ->

                region_name = result.param[3]
                default_vpc = ''
                if result.param[5] and $.type(result.param[5]) == 'array'
                    default_vpc = result.param[5][0].Value[0]

                console.log 'VPC_SNET_DESC_SUBNETS_RETURN ' + region_name + ', ' + default_vpc

                if !result.is_error

                    if $.type(result.resolved_data) == 'array'

                        $.each result.resolved_data, (idx, value) ->

                            MC.data.account_attribute[region_name].default_subnet[value.availabilityZone] = value

                            MC.data.resource_list[region_name][value.subnetId] = value

                            null

                    else

                        console.log 'no default subnet found in default vpc ' + default_vpc

                null

        #call service
        describeAvailableZonesService : ( region_name ) ->

            me = this

            #init
            me.set 'availability_zone', null

            if  MC.data.config[region_name] and MC.data.config[region_name].zone

                res = $.extend true, {}, MC.data.config[region_name].zone

                #if type != 'NEW_STACK'
                if MC.data.current_tab_type isnt 'NEW_STACK'

                    $.each res.item, ( idx, value ) ->

                        # old design flow
                        #$.each MC.canvas_data.layout.component.group, ( i, zone ) ->

                        # new design flow
                        $.each Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone ).allObjects(), ( i, zone ) ->

                            if zone.attributes.name == value.zoneName

                                res.item[idx].isUsed = true

                                null

                # service_count +1
                me.stackLoadDepend 'describeAvailableZonesService:OLD'

                #
                me.set 'availability_zone', res

            else

                #get service(model)
                ec2_service.DescribeAvailabilityZones { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, null, ( result ) ->

                    if !result.is_error
                    #DescribeAvailabilityZones succeed

                        region_name = result.param[3]
                        console.log 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN: ' + region_name

                        _.map result.resolved_data.item, (value)->
                            value.zoneShortName = value.zoneName.slice(-1).toUpperCase()
                            null

                        res = $.extend true, {}, result.resolved_data

                        #if type != 'NEW_STACK'
                        if MC.data.current_tab_type isnt 'NEW_STACK'

                            $.each res.item, ( idx, value ) ->


                                # old design flow
                                #$.each MC.canvas_data.layout.component.group, ( i, zone ) ->

                                # new design flow
                                $.each Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone ).allObjects(), ( i, zone ) ->

                                    if zone.attributes.name == value.zoneName

                                        res.item[idx].isUsed = true

                                        null

                        console.log 'get az: -> data region: ' + region_name + ', stack region: ' + Design.instance().region()
                        if region_name == Design.instance().region()
                            me.set 'availability_zone', res

                        #cache az to MC.data.config[region_name].zone
                        MC.data.config[region_name].zone = result.resolved_data

                        # service_count +1
                        me.stackLoadDepend 'describeAvailableZonesService:NEW'

                        null
                    else
                        #DescribeAvailabilityZones failed
                        console.log 'ec2.DescribeAvailabilityZones failed, error is ' + result.error_message

        #call service
        describeSnapshotsService : ( region_name ) ->

            me = this

            #init
            me.set 'resource_snapshot', null

            #if demo account, not request api
            if MC.common.cookie.getCookieByName( 'account_id' ) is 'demo_account'
                return

            #check cached data
            if (MC.data.config[region_name] and MC.data.config[region_name].snapshot_list )

                me.set 'resource_snapshot', MC.data.config[region_name].snapshot_list

            else

                #get service(model)
                ebs_model.DescribeSnapshots { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null,  ["self"], null, null

        #call service
        quickstartService : ( region_name ) ->

            me = this

            #init
            me.set 'quickstart_ami', null

            #check cached data
            if (MC.data.config[region_name] and MC.data.config[region_name].ami_list )

                ami_list = MC.data.config[region_name].ami_list

                # filter nat ami when in classic style
                quickstart_amis = []

                if Design.instance().typeIsClassic()
                    quickstart_amis.push i for i in ami_list when i.name.indexOf('ami-vpc-nat') < 0
                else
                    quickstart_amis =  ami_list

                me.set 'quickstart_ami', quickstart_amis

                #get my AMI
                me.myAmiService region_name

                #get favorite AMI
                me.favoriteAmiService region_name

                # service_count +1
                me.stackLoadDepend 'quickstartService:OLD'

                #describe ami in stack
                me.describeStackAmiService region_name

                ide_event.trigger ide_event.RESOURCE_QUICKSTART_READY, region_name

            else
                #get service(model)
                aws_model.quickstart { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name

            null

        #call service
        myAmiService : ( region_name ) ->
            console.log 'myAmiService', region_name

            me = this

            #init
            me.set 'my_ami' , Math.round(+new Date())

            #if demo account, not request api
            if MC.common.cookie.getCookieByName( 'account_id' ) is 'demo_account'
                return

            #check cached data
            if MC.data.config[region_name] and MC.data.config[region_name].my_ami

                me.set 'my_ami', MC.data.config[region_name].my_ami

            else
                #get service(model)
                ami_model.DescribeImages { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, ["self"], null, null

            null

        describeStackAmiService : ( region_name )->

            me = this

            stack_ami_list = []

            dict_ami = MC.data.dict_ami
            if not dict_ami then return

            for instance in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance ).allObjects()
                if not dict_ami[ instance.get("imageId") ]
                    stack_ami_list.push instance.get("imageId")

            if stack_ami_list.length != 0
                ami_model.DescribeImages { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, _.uniq( stack_ami_list )

        describeCommunityAmiService : ( region_name, name, platform, isPublic, architecture, rootDeviceType, perPageNum, returnPage ) ->

            me = this

            if perPageNum == undefined or perPageNum == null

                perPageNum = 50

            if returnPage == undefined or returnPage == null or returnPage == 0 or returnPage == "0"

                returnPage = 1

            filters = {
                ami : {
                    name            :   name
                    platform        :   platform
                    isPublic        :   isPublic
                    architecture    :   architecture
                    rootDeviceType  :   rootDeviceType
                    perPageNum      :   parseInt(perPageNum, 10)
                    returnPage      :   parseInt(returnPage, 10)

                }

            }

            ami_list = []
            if community_ami[region_name] == undefined
                #get service(model)
                aws_model.Public { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, filters

            null

        #call service
        favoriteAmiService : ( region_name ) ->
            console.log 'favoriteAmiService', region_name

            me = this

            #init
            me.set 'favorite_ami', null

            #check cached data
            if MC.data.config[region_name] and MC.data.config[region_name].favorite_ami

                me.set 'favorite_ami', MC.data.config[region_name].favorite_ami

            else

                #get service(model)
                favorite_model.info { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name

            null

        addFav: ( region_name, amiId ) ->
            # temp hack
            amiVO = JSON.stringify @get( 'community_ami' ).result[ amiId ]
            amiId = { id: amiId, provider: 'AWS', 'resource': 'AMI', service: 'EC2' }

            me =  this

            favorite_model.add { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, amiId

        removeFav: ( region_name, amiId ) ->

            amiId = [ amiId ]

            me = this

            favorite_model.remove { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, amiId

            # remove favorite action is not very important and for instant reason I omit return value validation and change data directly.

            delete MC.data.config[region_name].favorite_ami
            @resetFavData 'remove', amiId[ 0 ]

        resetFavData: ( action, data ) ->
            if action is 'add'

            else if action is 'remove'
                favorite_ami = @get 'favorite_ami'
                new_favorite_ami = _.reject favorite_ami, ( ami ) ->
                    return ami.resource_id is data

                @set 'favorite_ami', new_favorite_ami

        getIgwStatus : ->
            !!Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway ).allObjects().length

        getVgwStatus : ->
            !!Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway ).allObjects().length

        describeSubnetInDefaultVpc : ( region_name ) ->

            me = this

            default_vpc = MC.data.account_attribute[region_name].default_vpc

            if !default_vpc

                console.log "hasn't get default_vpc for region " + region_name

            else

                if default_vpc != 'none'

                    filters = [ {Name: 'vpc-id', Value: [ default_vpc ]}, {Name: 'defaultForAz', Value: [ 'true' ]} ]
                    subnet_model.DescribeSubnets {sender: me}, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, filters

                else

                    console.log 'current region ' + region_name + ' has no default vpc'

            null

        stackLoadDepend : ( name ) ->
            console.log 'stackLoadDepend, name = ' + name

            # accumulate
            @service_count = @service_count + 1

            # add deppend api name to resourceapi array
            MC.data.resouceapi.push name

            # set service_count
            @set 'check_required_service_count', @service_count

            null

    }

    model = new ResourcePanelModel()

    return model
