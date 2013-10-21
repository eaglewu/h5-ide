#############################
#  View Mode for design/property/vpc
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    VPCModel = PropertyModel.extend {

        ###
        defaults :
            uid            : null
            component      : null
            dnsSupport     : null
            dnsHosts       : null
            defaultTenancy : null
            noneDhcp       : null
        ###

        init : ( uid ) ->
            component = MC.canvas_data.component[ uid ]

            data = {
                uid            : uid
                component      : component
                dnsSupport     : component.resource.EnableDnsSupport   == "true"
                dnsHosts       : component.resource.EnableDnsHostnames == "true"
                defaultTenancy : component.resource.InstanceTenancy    == "default"
                dhcp           : this.getDHCPOptions uid
            }

            this.set data
            null

        setName : ( newName ) ->
            MC.canvas_data.component[ this.attributes.uid ].name = newName
            vpcCIDR = MC.canvas_data.component[ this.attributes.uid ].resource.CidrBlock
            MC.canvas.update this.attributes.uid, "text", "label", newName + ' (' + vpcCIDR + ')'
            null

        setCIDR : ( newCIDR ) ->

            oldCIDR = MC.canvas_data.component[ this.attributes.uid ].resource.CidrBlock
            MC.canvas_data.component[ this.attributes.uid ].resource.CidrBlock = newCIDR

            vpcName = MC.canvas_data.component[this.attributes.uid].name
            MC.canvas.update this.attributes.uid, "text", "label", vpcName + ' (' + newCIDR + ')'

            MC.aws.vpc.updateAllSubnetCIDR(newCIDR, oldCIDR)
            null

        setTenancy : ( tenancy ) ->
            component = MC.canvas_data.component[ this.attributes.uid ]
            component.resource.InstanceTenancy = tenancy

            # Set all AMI to be tenacy
            for uid, comp of MC.canvas_data.component
                if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
                    comp.resource.Placement.Tenancy = "dedicated"
            null

        setDnsSupport : ( enable ) ->
            component = MC.canvas_data.component[ this.attributes.uid ]
            component.resource.EnableDnsSupport = if enable then "true" else "false"
            null

        setDnsHosts : ( enable ) ->
            component = MC.canvas_data.component[ this.attributes.uid ]
            component.resource.EnableDnsHostnames = if enable then "true" else "false"
            null

        getDHCPComponent : ( vpcUid ) ->
            vpc    = MC.canvas_data.component[ vpcUid ]
            dhcpid = vpc.resource.DhcpOptionsId
            dhcpid = if dhcpid is "default" then "" else MC.extractID( dhcpid )

            if dhcpid == ""
                # Create a new DHCP Component
                dhcpid = MC.guid()

                component_data = $.extend true, {}, MC.canvas.DHCP_JSON.data
                component_data.uid = dhcpid
                component_data.resource.VpcId = "@#{vpcUid}.resource.VpcId"

                components = MC.canvas_data.component
                components[ dhcpid ] = component_data

                vpc.resource.DhcpOptionsId = "@#{dhcpid}.resource.DhcpOptionsId"
                return component_data

            return MC.canvas_data.component[ dhcpid ]

        removeDhcp : ( isDefault ) ->
            component = MC.canvas_data.component[ this.attributes.uid ]
            dhcpid = MC.extractID component.resource.DhcpOptionsId

            # DhcpOptionsId is "default" means use no dhcp
            # DhcpOPtionsId is "" means use default dhcp
            component.resource.DhcpOptionsId = if isDefault then "" else "default"
            delete MC.canvas_data.component[ dhcpid ]

        # DHCP Options Setting
        setDHCPOptions : ( options ) ->

            configSet = []
            if options.domainName
                configSet.push
                    Key : "domain-name"
                    ValueSet : [ Value : options.domainName ]

            if options.domainServers || options.useAmazonDns
                values = []
                if options.useAmazonDns
                    values.push Value : "AmazonProvidedDNS"

                if options.domainServers
                    values.push Value : s for s in options.domainServers

                configSet.push
                    Key : "domain-name-servers"
                    ValueSet : values

            if options.ntpServers
                values = []
                values.push Value : s for s in options.ntpServers
                configSet.push
                    Key : "ntp-servers"
                    ValueSet : values

            if options.netbiosServers
                values = []
                values.push Value : s for s in options.netbiosServers
                configSet.push
                    Key : "netbios-name-servers"
                    ValueSet : values

            if options.netbiosType
                configSet.push
                    Key : "netbios-node-type"
                    ValueSet : [ Value : options.netbiosType ]

            @getDHCPComponent( @attributes.uid ).resource.DhcpConfigurationSet = configSet
            null

        # TODO : Generate default domain name for dhcp
        defaultDomainName : ( vpcUid ) ->
            ""

        getDHCPOptions : ( vpcUid ) ->
            components = MC.canvas_data.component
            dhcpid = MC.extractID components[ vpcUid ].resource.DhcpOptionsId

            mock =
                domainName   : this.defaultDomainName vpcUid
                useAmazonDns : true

            if dhcpid is "default"
                mock.none = true
                return mock

            if dhcpid is ""
                mock.default = true
                return mock

            dhcp   = components[ dhcpid ]
            config = dhcp.resource.DhcpConfigurationSet

            keyMap =
                "domain-name-servers"  : "domainServers"
                "netbios-name-servers" : "netbiosServers"
                "ntp-servers"          : "ntpServers"

            data = {
                useAmazonDns : false
                hasDhcp      : true
            }
            for i in config
                if i.Key == "domain-name"
                    data.domainName  = i.ValueSet[0].Value

                else if i.Key == "netbios-node-type"
                    data.netbiosType = i.ValueSet[0].Value

                else
                    key = keyMap[ i.Key ]
                    if !key
                        continue

                    data[key] = values = []
                    for value in i.ValueSet
                        if value.Value == "AmazonProvidedDNS"
                            data.useAmazonDns = true
                        else
                            values.push value.Value
            data
    }

    new VPCModel()
