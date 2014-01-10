#############################
#  View Mode for design/property/vpc (app)
#############################

define [ '../base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

    VPCAppModel = PropertyModel.extend {

        init : ( vpc_uid ) ->

          myVPCComponent = Design.instance().component( vpc_uid )

          appData = MC.data.resource_list[ Design.instance().region() ]
          vpc     = appData[ myVPCComponent.get 'appId' ]

          if not vpc then return false

          vpc = $.extend true, {}, vpc
          vpc.name = myVPCComponent.get 'name'

          TYPE_RTB = constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
          TYPE_ACL = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl

          # Get Main Route Table and Default ACL
          # TODO ( Update this code ):
          ############################
          # for key, value of MC.canvas_data.component
          #   if value.type == TYPE_RTB
          #     if value.resource.AssociationSet[0] && value.resource.AssociationSet[0].Main == "true"
          #       vpc.mainRTB = value.resource.RouteTableId
          #       if vpc.defaultACL
          #         break
          #   else if value.type == TYPE_ACL
          #     if value.resource.Default == "true"
          #       vpc.defaultACL = value.resource.NetworkAclId
          #       if vpc.mainRTB
          #         break
          ############################

          if vpc.dhcpOptionsId
            if not appData[ vpc.dhcpOptionsId ]
              vpc.default_dhcp = true

            else
              dhcpData = appData[ vpc.dhcpOptionsId ].dhcpConfigurationSet.item
              dhcp = {}

              for i in dhcpData
                if i.key is 'domain-name-servers'
                  for j, idx in i.valueSet
                    if j is 'AmazonProvidedDNS'
                      tmp = i.valueSet[0]
                      i.valueSet[0]   = j
                      i.valueSet[idx] = tmp
                      break
                dhcp[ MC.camelCase( i.key ) ] = i.valueSet

              vpc.dhcp = dhcp

          @set vpc
          null
    }

    new VPCAppModel()
