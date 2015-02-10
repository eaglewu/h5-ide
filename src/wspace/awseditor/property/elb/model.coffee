#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', "Design", 'constant', 'sslcert_dropdown', "CloudResources" ], ( PropertyModel, Design, constant, SSLCertDropdown, CloudResources ) ->

    ElbModel = PropertyModel.extend {

        init : ( uid ) ->

            component = Design.instance().component( uid )

            @getAppData( uid )

            attr        = component?.toJSON()
            attr.uid    = uid
            attr.isVpc  = true
            attr.description = component?.get("description")

            # Format ping
            pingArr  = component.getHealthCheckTarget()
            attr.pingProtocol = pingArr[0]
            attr.pingPort     = pingArr[1]
            attr.pingPath     = pingArr[2]

            if attr.sslCert
                attr.sslCert = attr.sslCert?.toJSON()

            # See if we need to should certificate
            for i in attr.listeners
                if i.protocol is "SSL" or i.protocol is "HTTPS"
                    attr.showCert = true
                    break

            # Get SSL Cert List
            currentSSLCert = component.connectionTargets("SslCertUsage")[0]
            allCertModelAry = Design.modelClassForType(constant.RESTYPE.IAM).allObjects()

            attr.noSSLCert = true
            attr.sslCertItem = _.map allCertModelAry, (sslCertModel) ->
                if currentSSLCert is sslCertModel then attr.noSSLCert = false

                disableCertEdit = false
                if sslCertModel.get('certId') and sslCertModel.get('arn')
                    disableCertEdit = true

                {
                    uid: sslCertModel.id,
                    name: sslCertModel.get('name'),
                    selected: currentSSLCert is sslCertModel,
                    disableCertEdit: disableCertEdit
                }

            if attr.ConnectionDraining
                if attr.ConnectionDraining.Enabled is true
                    attr.connectionDrainingEnabled = true
                    attr.connectionDrainingTimeout = attr.ConnectionDraining.Timeout
                else
                    attr.connectionDrainingEnabled = false

            @set attr
            null

        getAppData : ( uid )->
            uid = uid or @get("uid")

            myElbComponent = Design.instance().component( uid )

            elb = CloudResources(Design.instance().credentialId(), constant.RESTYPE.ELB, Design.instance().region()).get(myElbComponent.get('appId'))

            if not elb then return

            elb = elb.attributes

            @set {
                appData    : true
                isInternet : elb.Scheme is 'internet-facing'
                DNSName    : elb.Dnsname
                CanonicalHostedZoneNameID : elb.CanonicalHostedZoneNameID
            }
            null

        setScheme   : ( value ) ->
            value = value is "internal"
            Design.instance().component( @get("uid") ).setInternal( value )

            # Trigger an event to tell canvas that we want an IGW
            if not value
                Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()
            null

        setElbCrossAZ : ( value )->
            Design.instance().component( @get("uid") ).set( "crossZone", !!value )
            null

        setHealthProtocol   : ( value ) ->
            Design.instance().component( @get("uid") ).setHealthCheckTarget( value )
            null

        setHealthPort: ( value ) ->
            Design.instance().component( @get("uid") ).setHealthCheckTarget( undefined, value )
            null

        setHealthPath: ( value ) ->
            Design.instance().component( @get("uid") ).setHealthCheckTarget( undefined, undefined, value )
            null

        setHealthInterval: ( value ) ->
            Design.instance().component( @get("uid") ).set("healthCheckInterval", value )
            null

        setHealthTimeout: ( value ) ->
            Design.instance().component( @get("uid") ).set("healthCheckTimeout", value )
            null

        setHealthUnhealth: ( value ) ->
            Design.instance().component( @get("uid") ).set("unHealthyThreshold", value )
            null

        setHealthHealth: ( value ) ->
            Design.instance().component( @get("uid") ).set("healthyThreshold", value )
            null

        setListener: ( idx, value ) ->
            Design.instance().component( @get("uid") ).setListener( idx, value )
            null

        removeListener : ( idx )->
            Design.instance().component( @get("uid") ).removeListener( idx )
            null

        setCert : ( value )->
            Design.instance().component( @get("uid") ).connectionTargets("SslCertUsage")[0].set( value )
            null

        addCert : ( value )->
            SslCertModel = Design.modelClassForType( constant.RESTYPE.IAM )
            (new SslCertModel( value )).assignTo( Design.instance().component( @get("uid") ) )
            null

        removeCert : ( value ) ->
            Design.instance().component( value ).remove()
            null

        updateElbAZ : ( azArray )->
            Design.instance().component( @get("uid") ).set("AvailabilityZones", azArray )
            null

        changeCert : ( certUID ) ->
            design = Design.instance()
            if certUID
                design.component( certUID ).assignTo( design.component( @get("uid") ) )
            else
                for cn in design.component( @get("uid") ).connections("SslCertUsage")
                    cn.remove()
            null

        updateCert : (certUID, certObj) ->
            Design.instance().component( certUID ).updateValue( certObj )
            null

        getOtherCertName : (currentName) ->

            allCertModelAry = Design.modelClassForType(constant.RESTYPE.IAM).allObjects()

            otherCertNameAry = []
            _.each allCertModelAry, (sslCertModel) ->
                sslCertName = sslCertModel.get('name')
                if currentName isnt sslCertName
                    otherCertNameAry.push(sslCertName)

            return otherCertNameAry

        setConnectionDraining : (enabled, timeout) ->

            if not enabled
                timeout = null

            elbModel = Design.instance().component( @get("uid") )
            elbModel.set('ConnectionDraining', {
                Enabled: enabled,
                Timeout: timeout
            })

        setAdvancedProxyProtocol : (enable, portAry) ->

            elbModel = Design.instance().component( @get("uid") )
            elbModel.setPolicyProxyProtocol(enable, portAry)

        initNewSSLCertDropDown : (idx, $listenerItem) ->

            that = this
            elbModel = Design.instance().component( @get("uid") )

            sslCertDropDown = new SSLCertDropdown()
            sslCertDropDown.uid = @get('uid')
            sslCertDropDown.listenerNum = idx

            sslCertModel = elbModel.getSSLCert(idx)
            if sslCertModel
                sslCertDropDown.sslCertName = sslCertModel.get('name')

            return sslCertDropDown

        setIdletimeout : (value) ->

            elbModel = Design.instance().component( @get("uid") )
            elbModel.set('idleTimeout', value)

    }

    new ElbModel()
