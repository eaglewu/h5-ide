#############################
#  View(UI logic) for design/property/cgw
#############################

define [ 'i18n!/nls/lang.js', '../base/view', './template/stack', 'constant', "Design", 'UI.modalplus' ], ( lang, PropertyView, template, constant, Design, modalPlus ) ->

    CGWView = PropertyView.extend {

        events   :
            "click #property-cgw .cgw-routing input" : 'onChangeRouting'
            "change #property-cgw-bgp"               : 'onChangeBGP'
            "change #property-cgw-name"              : 'onChangeName'

            "focus #property-cgw-ip"                 : 'onFocusIP'
            "keypress #property-cgw-ip"              : 'onPressIP'
            "blur #property-cgw-ip"                  : 'onBlurIP'
            'change #property-res-desc'              : 'onChangeDescription'

        render     : () ->
            @$el.html template @model.toJSON()
            @model.get 'name'

        onChangeDescription : (event) -> @model.setDesc $(event.currentTarget).val()

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
                    return lang.PARSLEY.MUST_BE_BETWEEN_1_AND_65534
                if val is 7224 and region is 'us-east-1'
                    return lang.PARSLEY.ASN_NUMBER_7224_RESERVED
                if val is 9059 and region is 'eu-west-1'
                    return lang.PARSLEY.ASN_NUMBER_9059_RESERVED_IN_IRELAND

            if $target.parsley 'validate'
                @model.setBGP $target.val()
            null

        onChangeName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if MC.aws.aws.checkResName( @model.get('uid'), target, "Customer Gateway" )
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
                mainContent = lang.PROP.CGW_IP_VALIDATE_REQUIRED
                descContent = lang.PROP.CGW_IP_VALIDATE_REQUIRED_DESC
            else if !MC.validate 'ipv4', ipAddr
                mainContent = sprintf(lang.PROP.CGW_IP_VALIDATE_INVALID, ipAddr)
                descContent = lang.PROP.CGW_IP_VALIDATE_INVALID_DESC
            else if MC.aws.aws.isValidInIPRange(ipAddr, 'private')
                mainContent = sprintf(lang.PROP.CGW_IP_VALIDATE_INVALID_CUSTOM, ipAddr)
                descContent = lang.PROP.CGW_IP_VALIDATE_INVALID_CUSTOM_DESC
            else
                haveError = false

            if not haveError
                @model.setIP event.target.value
                @disabledAllOperabilityArea( false )
                return

            dialog_template = MC.template.setupCIDRConfirm {
                remove_content : lang.PROP.CGW_REMOVE_CUSTOM_GATEWAY
                main_content : mainContent
                desc_content : descContent
            }

            that = this
            modal = new modalPlus {
                template: dialog_template,
                title: lang.IDE.SET_UP_CIDR_BLOCK
                width: 420
                confirm: text: "OK", color: "blue"
                cancel: hide: true
            }

            $("""<a id="cidr-removed" class="link-red left link-modal-danger">#{lang.PROP.CGW_REMOVE_CUSTOM_GATEWAY}</a>""")
            .appendTo(modal.find(".modal-footer"))
            modal.on "confirm", ()->
                modal.close()
            modal.on "close", ()->
                $('#property-cgw-ip').focus()
            modal.find("#cidr-removed").on "click",(e)->
                e.preventDefault()
                console.log "Not Work....."
                Design.instance().component( that.model.get("uid") ).remove()
                that.disabledAllOperabilityArea(false)
                modal.close()

    }

    new CGWView()
