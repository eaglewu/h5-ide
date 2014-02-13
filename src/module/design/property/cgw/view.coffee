#############################
#  View(UI logic) for design/property/cgw
#############################

define [ '../base/view', 'text!./template/stack.html', 'event', 'constant', "Design" ], ( PropertyView, template, ide_event, constant, Design ) ->

    template = Handlebars.compile template

    CGWView = PropertyView.extend {

        events   :
            "click #property-cgw .cgw-routing input" : 'onChangeRouting'
            "change #property-cgw-bgp"               : 'onChangeBGP'
            "change #property-cgw-name"              : 'onChangeName'

            "focus #property-cgw-ip"    : 'onFocusIP'
            "keypress #property-cgw-ip" : 'onPressIP'
            "blur #property-cgw-ip"     : 'onBlurIP'

        render     : () ->
            @$el.html template @model.toJSON()
            @model.get 'name'

        onChangeRouting : () ->
            $( '#property-cgw-bgp-wrapper' ).toggle $('#property-routing-dynamic').is(':checked')
            @model.setBGP ""

        onChangeBGP : ( event ) ->
            $target = $ event.currentTarget
            region = Design.instance().region()
            if not $target.val()
                @model.setBGP ""
                return

            $target.parsley 'custom', ( val ) ->
                val = + val
                if val < 1 or val > 65534
                    return 'Must be between 1 and 65534'
                if val is 7224 and region is 'us-east-1'
                    return 'ASN number 7224 is reserved in Virginia'
                if val is 9059 and region is 'eu-west-1'
                    return 'ASN number 9059 is reserved in Ireland'

            if $target.parsley 'validate'
                @model.setBGP $target.val()
            null

        onChangeName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if @checkDupName( target, "Customer Gateway" )
                @model.setName name
                @setTitle name

        onPressIP : ( event ) ->
            if (event.keyCode is 13)
                $('#property-cgw-ip').blur()

        onFocusIP : ( event ) ->
            @disabledAllOperabilityArea(true)
            null

        onBlurIP : ( event ) ->

            ipAddr = $('#property-cgw-ip').val()

            haveError = true
            if !ipAddr
                mainContent = 'IP Address is required.'
                descContent = 'Please provide a IP Address of this Customer Gateway.'
            else if !MC.validate 'ipv4', ipAddr
                mainContent = "#{ipAddr} is not a valid IP Address."
                descContent = 'Please provide a valid IP Address. For example, 192.168.1.1.'
            else if !MC.aws.eni.isPublicIPAddress(ipAddr)
                mainContent = "IP Address #{ipAddr} is invalid for customer gateway."
                descContent = "The address must be static and can't be behind a device performing network address translation (NAT)."
            else
                haveError = false

            if not haveError
                @model.setIP event.target.value
                @disabledAllOperabilityArea( false )
                return

            dialog_template = MC.template.setupCIDRConfirm {
                remove_content : 'Remove Customer Gateway'
                main_content : mainContent
                desc_content : descContent
            }

            that = this
            modal dialog_template, false, () ->

                $('.modal-close').click () -> $('#property-cgw-ip').focus()

                $('#cidr-remove').click () ->
                    $canvas.clearSelected()
                    Design.instance().component( that.model.get("uid") ).remove()

                    that.disabledAllOperabilityArea(false)
                    modal.close()

            , {
                $source: $(event.target)
            }
    }

    new CGWView()
