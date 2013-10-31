#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'i18n!nls/lang.js', 'backbone', 'jquery', 'handlebars',
        'UI.selectbox',
        'UI.tooltip',
        'UI.notification',
        'UI.modal',
        'UI.tablist',
        'UI.toggleicon'], ( ide_event, MC, lang ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-instance-tmpl' ).html()
        ip_list_template : Handlebars.compile $( '#property-ip-list-tmpl' ).html()

        events   :
            'change .instance-name'                       : 'instanceNameChange'
            'change #property-instance-count'             : 'countChange'
            'change .instance-type-select'                : 'instanceTypeSelect'
            'change #property-instance-ebs-optimized'     : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data'         : 'userdataChange'
            'change #property-instance-ni-description'    : 'eniDescriptionChange'
            'change #property-instance-source-check'      : 'sourceCheckChange'
            'change #property-instance-public-ip'         : 'publicIpChange'
            'OPTION_CHANGE #instance-type-select'         : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select'               : "tenancySelect"
            'OPTION_CHANGE #keypair-select'               : "setKP"
            'EDIT_UPDATE #keypair-select'                 : "addKP"
            'click #instance-ip-add'                      : "addIPtoList"
            'click #property-network-list .icon-remove'   : "removeIPfromList"
            "EDIT_FINISHED #keypair-select"               : "updateKPSelect"

            'change .input-ip'    : 'updateEIPList'
            'click .toggle-eip'   : 'addEIP'
            'click #property-ami' : 'openAmiPanel'

        render     : ( attributes ) ->
            console.log 'property:instance render'
            #
            this.undelegateEvents()

            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                this.model.attributes.component.resource.VpcId = defaultVPCId

            $( '.property-details' ).html this.template this.model.attributes

            this.refreshIPList()

            this.delegateEvents this.events

            $( "#keypair-select" ).on("click", ".icon-remove", _.bind(this.deleteKP, this) )

        instanceNameChange : ( event ) ->
            console.log 'instanceNameChange'

            target = $ event.currentTarget
            name = target.val()
            id = @model.get 'get_uid'


            MC.validate.preventDupname target, id, name, 'Instance'


            if target.parsley 'validate'
                this.model.set 'name', name
            null

        countChange : ( event ) ->
            target = $ event.currentTarget

            that = this

            target.parsley 'custom', ( val ) ->
                if isNaN( val ) or val > 99 or val < 1
                    return 'This value must be >= 1 and <= 99'

            if target.parsley 'validate'

                instanceUID = that.model.get 'get_uid'
                MC.aws.eni.updateAllInstanceENIIPToAutoAssign(instanceUID)
                this.refreshIPList()

                val = +target.val()
                @trigger "COUNT_CHANGE", val
                $(".property-instance-name-wrap").toggleClass("single", val == 1)
                $("#property-instance-name-count").text val
                @setEditableIP val == 1

        setEditableIP : ( enable ) ->
            $parent = $("#property-network-list")

            if enable
                $parent.find(".input-ip").removeAttr "disabled"
                $parent.find(".name").data "tooltip", "Specify an IP address or leave it as .x to automatically assign an IP."

            else
                $parent.find(".input-ip").attr "disabled", "disabled"
                $parent.find(".name").data "tooltip", "Automatically assigned IP."

        instanceTypeSelect : ( event, value )->

            canset = @model.canSetInstanceType value
            if canset isnt true
                notification "error", canset
                event.preventDefault()
                return

            has_ebs = @model.setInstanceType value
            $ebs = $("#property-instance-ebs-optimized")
            $ebs.closest(".property-control-group").toggle has_ebs
            if not has_ebs
                $ebs.prop "checked", false

            instanceUID = this.model.get 'get_uid'
            MC.aws.eni.reduceAllENIIPList(instanceUID)
            this.refreshIPList()

        ebsOptimizedSelect : ( event ) ->
            this.model.set 'ebs_optimized', event.target.checked

        tenancySelect : ( event, value ) ->
            $type = $("#instance-type-select")
            $t1   = $type.find("[data-id='t1.micro']")

            if $t1.length
                show = value isnt "dedicated"
                $t1.toggle( show )

                if $t1.hasClass("selected") and not show
                    $type.find(".item:not([data-id='t1.micro'])").eq(0).click()

            @model.setTenancy value
            null

        cloudwatchSelect : ( event ) ->
            this.model.set 'cloudwatch', event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            this.model.set 'user_data', event.target.value

        eniDescriptionChange : ( event ) ->
            this.model.set 'eni_description', event.target.value

        sourceCheckChange : ( event ) ->
            this.model.set 'source_check', event.target.checked

        publicIpChange : ( event ) ->

            this.model.set 'public_ip', event.target.checked

        setKP : ( event, id ) ->
            @model.setKP id
            null

        addKP : ( event, id ) ->
            result = @model.addKP id
            if not result
                notification "error", "KeyPair with the same name already exists."
                return result

        updateKPSelect : () ->
            # Add remove icon to the newly created item
            $("#keypair-select").find(".item:last-child").append('<span class="icon-remove"></span>')


        addIPtoList: (event) ->

            subnetCIDR = ''
            instanceUID = this.model.get 'get_uid'

            # validate max ip num
            maxIPNum = MC.aws.eni.getENIMaxIPNum(instanceUID)
            currentENIComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
            if !currentENIComp then return false

            currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
            if maxIPNum is currentIPNum
                return false
            # validate max ip num

            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(instanceUID)
                subnetCIDR = subnetObj.cidrBlock
            else
                subnetUID = MC.canvas_data.component[instanceUID].resource.SubnetId.split('.')[0][1...]
                subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

            ipPrefixSuffix = MC.aws.subnet.genCIDRPrefixSuffix(subnetCIDR)
            tmpl = $(MC.template.networkListItem({
                ipPrefix: ipPrefixSuffix[0],
                ipSuffix: ipPrefixSuffix[1]
            }))

            $('#property-network-list').append tmpl
            this.trigger 'ADD_NEW_IP'

            this.updateEIPList()
            false

        removeIPfromList: (event, id) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            this.trigger 'REMOVE_IP', index

            this.updateEIPList()

        openAmiPanel : ( event ) ->
            console.log 'openAmiPanel'
            target = $('#property-ami')

            console.log MC.template.aimSecondaryPanel target.data( 'secondarypanel-data' )

            data = target.data( 'secondarypanel-data' )
            data.instance_type = data.instanceType
            ide_event.trigger ide_event.PROPERTY_OPEN_SUBPANEL, {
                title : data.imageId
                dom   : MC.template.aimSecondaryPanel data
                id    : 'Ami'
            }
            null

        addEIP : ( event ) ->

            # todo, need a index of eip
            index = $(event.currentTarget).closest("li").index()
            if event.target.className.indexOf('associated') >= 0 then attach = true else attach = false
            this.trigger 'ATTACH_EIP', index, attach

            this.updateEIPList()

        updateEIPList: (event) ->

            currentAvailableIPAry = []
            ipInuptListItem = $('#property-network-list li.input-ip-item')
            validSuccess = true
            that = this
            instanceUID = that.model.get 'get_uid'
            eniComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
            eniUID = eniComp.uid

            currentInputValue = currentIdx = null
            if event and event.currentTarget
                currentInputValue = $(event.currentTarget).val()
                currentIdx = $(event.currentTarget).parents('li.input-ip-item').index()

            _.each ipInuptListItem, (ipInputItem, idx) ->

                if event and event.currentTarget
                    currentInputValue = $(event.currentTarget).val()

                inputValuePrefix = $(ipInputItem).find('.input-ip-prefix').text()
                inputValue = $(ipInputItem).find('.input-ip').val()
                currentInputIP = inputValuePrefix + currentInputValue

                prefixAry = inputValuePrefix.split('.')

                ################################### validation
                validDOM = $(ipInputItem).find('.input-ip')

                validDOM.parsley 'custom', ( val ) ->

                    ###### validation format
                    ipIPFormatCorrect = false
                    # for 10.0.0.
                    if prefixAry.length is 4
                        if inputValue is 'x'
                            ipIPFormatCorrect = true
                        if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
                            ipIPFormatCorrect = true
                    # for 10.0.
                    else
                        if inputValue is 'x.x'
                            ipIPFormatCorrect = true
                        if MC.validate 'ipaddress', (inputValuePrefix + inputValue)
                            ipIPFormatCorrect = true
                    if !ipIPFormatCorrect
                        return 'Invalid IP address'

                    ###### validation if in subnet
                    # ipAddr = inputValuePrefix + inputValue
                    if currentInputValue.indexOf('x') is -1
                        ipInSubnet = false
                        subnetCIDR = ''
                        defaultVPCId = MC.aws.aws.checkDefaultVPC()
                        if defaultVPCId
                            subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(instanceUID)
                            subnetCIDR = subnetObj.cidrBlock
                        else
                            subnetUID = MC.canvas_data.component[instanceUID].resource.SubnetId.split('.')[0][1...]
                            subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

                        ipInSubnet = MC.aws.subnet.isIPInSubnet(currentInputIP, subnetCIDR)

                        if !ipInSubnet
                            return 'This IP address conflicts with subnet’s IP range'

                    ###### validation if conflict with other eni
                    if currentInputValue.indexOf('x') is -1
                        innerRepeat = false
                        _.each ipInuptListItem, (ipInputItem1, idx1) ->
                            inputValue1 = $(ipInputItem1).find('.input-ip').val()
                            if currentIdx isnt idx1 and inputValue1 is currentInputValue
                                innerRepeat = true
                            null
                        if innerRepeat
                            return 'This IP address conflicts with other IP'
                        if MC.aws.eni.haveIPConflictWithOtherENI(currentInputIP, eniUID)
                            return 'This IP address conflicts with other network interface’s IP'

                    null

                if event and event.currentTarget and currentIdx is idx
                    if not validDOM.parsley 'validate'
                        validSuccess = false
                ################################### validation

                inputHaveEIP = $(ipInputItem).find('.input-ip-eip-btn').hasClass('associated')
                currentAvailableIPAry.push({
                    ip: inputValuePrefix + inputValue,
                    eip: inputHaveEIP
                })
                null

            if !validSuccess
                return

            this.trigger 'SET_IP_LIST', currentAvailableIPAry

            # if is Server Group, disabled ip inputbox
            instanceUID = this.model.get 'get_uid'
            countNum = MC.canvas_data.component[instanceUID].number
            if countNum is 1
                @setEditableIP true
            else
                @setEditableIP false

            this.changeIPAddBtnState()

        changeIPAddBtnState : () ->

            disabledBtn = false
            instanceUID = this.model.get 'get_uid'

            maxIPNum = MC.aws.eni.getENIMaxIPNum(instanceUID)
            currentENIComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
            if !currentENIComp
                disabledBtn = true
                return

            currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
            if maxIPNum is currentIPNum
                disabledBtn = true

            instanceType = MC.canvas_data.component[instanceUID].resource.InstanceType
            if disabledBtn
                tooltipStr = sprintf(lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instanceType, maxIPNum)
                $('#instance-ip-add').addClass('disabled').attr('data-tooltip', tooltipStr).data('tooltip', tooltipStr)
            else
                $('#instance-ip-add').removeClass('disabled').attr('data-tooltip', 'Add IP Address').data('tooltip', 'Add IP Address')

            null

        deleteKP : ( event ) ->
            me = this
            $li = $(event.currentTarget).closest("li")

            selected = $li.hasClass("selected")
            using = if using is "true" then true else selected

            removeKP = () ->

                $li.remove()
                # If deleting selected kp, select the first one
                if selected
                    $("#keypair-select").find(".item").eq(0).click()

                me.model.deleteKP $li.attr("data-id")

            if using
                data =
                    title   : "Delete Key Pair"
                    confirm : "Delete"
                    color   : "red"
                    body    : "<p class='modal-text-major'>Are you sure you want to delete #{$li.text()}</p><p class='modal-text-minor'>Resources using this key pair will change automatically to use DefaultKP.</p>"
                # Ask for confirm
                modal MC.template.modalApp data
                $("#btn-confirm").one "click", ()->
                    removeKP()
                    modal.close()
            else
                removeKP()

            return false

        refreshIPList : ( event ) ->
            this.model.getEni()
            $( '#property-network-list' ).html(this.ip_list_template(this.model.attributes))
            this.changeIPAddBtnState()
    }

    view = new InstanceView()

    return view
