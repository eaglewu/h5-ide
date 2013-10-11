#############################
#  View(UI logic) for design/property/vpc
#############################

define [ 'event', 'i18n!nls/lang.js', 'backbone', 'jquery', 'handlebars', 'underscore', 'UI.multiinputbox' ], ( ide_event, lang ) ->

    # Helpers
    mapFilterInput = ( selector ) ->
        $inputs = $( selector )
        result  = []

        for ipt in $inputs
            if ipt.value
                result.push ipt.value

        if result.length == 0 then null else result

    updateAmazonCB = () ->
        rowLength = $( "#property-domain-server" ).children().length
        if rowLength > 3
            $( '#property-amazon-dns' ).attr( "disabled", true )
        else
            $( '#property-amazon-dns' ).removeAttr( "disabled" )


    VPCView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-vpc-tmpl' ).html()

        events   :
            'change #property-vpc-name'       : 'onChangeName'
            'change #property-cidr-block'     : 'onChangeCidr'
            'change #property-dns-resolution' : 'onChangeDnsSupport'
            'change #property-dns-hostname'   : 'onChangeDnsHostname'
            'OPTION_CHANGE #property-tenancy' : 'onChangeTenancy'

            'click #property-dhcp-none'    : 'onRemoveDhcp'
            'click #property-dhcp-default' : 'onRemoveDhcp'
            'click #property-dhcp-spec'    : 'onUseDHCP'
            'click #property-amazon-dns'   : 'onChangeAmazonDns'

            'change .property-control-group-sub .input' : 'onChangeDhcpOptions'
            'OPTION_CHANGE #property-netbios-type'      : 'onChangeDhcpOptions'
            'REMOVE_ROW #property-dhcp-options'         : 'onChangeDhcpOptions'
            'ADD_ROW .multi-input'                      : 'processParsley'

        render   : () ->

            data = $.extend( true, {}, this.model.attributes )

            selectedType = data.dhcp.netbiosType || 0
            data.dhcp.netbiosTypes = [
                  { id : "default" , value : lang.ide.PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE_NOT_SPECIFIED, selected : selectedType == 0 }
                , { id : 1 , value : 1, selected : selectedType == 1 }
                , { id : 2 , value : 2, selected : selectedType == 2 }
                , { id : 4 , value : 4, selected : selectedType == 4 }
                , { id : 8 , value : 8, selected : selectedType == 8 }
            ]

            $( '.property-details' ).html this.template data
            $( '#property-domain-server' ).on( 'ADD_ROW REMOVE_ROW', updateAmazonCB )
            updateAmazonCB()
            multiinputbox.update( $("#property-domain-server") )

        processParsley: ( event ) ->
            $( event.currentTarget )
                .find( 'input' )
                .last()
                .removeClass( 'parsley-validated' )
                .removeClass( 'parsley-error' )
                .next( '.parsley-error-list' )
                .remove()

        onChangeName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            target.parsley 'custom', ( val ) ->
                if not MC.validate 'awsName',  val
                    return 'This value should be a valid VPC name.'

            if target.parsley 'validate'
                this.trigger "CHANGE_NAME", name

        onChangeCidr : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if target.parsley 'validate'
                this.model.setCIDR event.target.value

        onChangeTenancy : ( event, newValue ) ->
            this.model.setTenancy newValue
            null

        onChangeDnsSupport : ( event ) ->
            this.model.setDnsSupport event.target.checked
            null

        onChangeDnsHostname : ( event ) ->
            this.model.setDnsHosts event.target.checked
            null

        onRemoveDhcp : ( event ) ->

            isDefault = $( event.currentTarget ).closest("section").find("input").attr("id") is "property-dhcp-default"

            $("#property-dhcp-desc").show()
            $("#property-dhcp-options").hide()

            this.model.removeDhcp isDefault

            # if noDhcp
            #     this.notChangingDHCP = true
            #     # User select none DHCP option.
            #     # Need to reset everything here.
            #     $("#property-dhcp-options .multi-ipt-row:not(:first-child)").remove()
            #     $("#property-dhcp-options .multi-ipt-row .input").val("")
            #     $("#property-dhcp-domain").val( this.model.defaultDomainName this.uid )
            #     $("#property-amazon-dns").prop("checked", true)
            #     $("#property-netbios-type .dropdown .item:first-child").click()
            #     this.notChangingDHCP = false

            null

        onChangeAmazonDns : ( event ) ->
            useAmazonDns = $("#property-amazon-dns").is(":checked")
            allowRows    = if useAmazonDns then 3 else 4
            $inputbox    = $("#property-domain-server").attr( "data-max-row", allowRows )
            $rows        = $inputbox.children()
            $inputbox.toggleClass "max", $rows.length >= allowRows

            this.onChangeDhcpOptions event
            null

        onUseDHCP : ( event ) ->
            $("#property-dhcp-desc").hide()
            $("#property-dhcp-options").show()
            this.onChangeDhcpOptions()

        onChangeDhcpOptions : ( event ) ->

            if event and not $( event.currentTarget ).parsley( 'validateForm' )
                return

            # Gather all the infomation to submit
            data =
                domainName     : $("#property-dhcp-domain").val()
                useAmazonDns   : $("#property-amazon-dns").is(":checked")
                domainServers  : mapFilterInput "#property-domain-server .input"
                ntpServers     : mapFilterInput "#property-ntp-server .input"
                netbiosServers : mapFilterInput "#property-netbios-server .input"
                netbiosType    : parseInt( $("#property-netbios-type .selection").html(), 10 ) || 0

            console.log "DHCP Options Changed", data

            this.model.setDHCPOptions data
            null
    }

    view = new VPCView()

    return view
