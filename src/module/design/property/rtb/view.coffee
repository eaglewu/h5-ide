#############################
#  View(UI logic) for design/property/rtb
#############################

define [ '../base/view', 'text!./template/stack.html', 'event' ], ( PropertyView, template, ide_event ) ->

    template = Handlebars.compile template

    RTBView = PropertyView.extend {

        events   :

            'change .ipt-wrapper'             : 'addIp'
            'REMOVE_ROW  .multi-input'        : 'removeIp'
            'ADD_ROW     .multi-input'        : 'processParsley'
            'BEFORE_REMOVE_ROW  .multi-input' : 'beforeRemoveIp'
            'change #rt-name'                 : 'changeName'
            'click #set-main-rt'              : 'setMainRT'
            'change .propagation'             : 'changePropagation'

            "focus .ip-main-input"      : 'onFocusCIDR'
            "keypress .ip-main-input"   : 'onPressCIDR'
            "blur .ip-main-input"       : 'onBlurCIDR'

        render     : () ->
            console.log 'property:rtb render'
            @$el.html template @model.attributes

            # find empty inputbox and focus
            me = this
            inputElemAry = $('.ip-main-input')
            _.each inputElemAry, (inputElem) ->
                inputValue = $(inputElem).val()
                if !inputValue
                    MC.aws.aws.disabledAllOperabilityArea(true)
                    me.forceShow()
                    $(inputElem).focus()

            @model.attributes.title

        processParsley: ( event ) ->
            $( event.currentTarget )
            .find( 'input' )
            .last()
            .removeClass( 'parsley-validated' )
            .removeClass( 'parsley-error' )
            .next( '.parsley-error-list' )
            .remove()

        addIp : ( event ) ->

            # data = event.target.parentNode.parentNode.parentNode.dataset
            # children = event.target.parentNode.parentNode.parentNode.children
            # uid = $("#rt-name").data 'uid'
            # this.trigger 'SET_ROUTE', uid, data, children

        beforeRemoveIp : ( event ) ->
            vals = 0
            $("#property-rtb-ips input").each ()->
                v = $(this).val()
                if v
                    ++vals

            # If we only have valid item and user is trying to remove it.
            # prevent deletion
            if vals <= 1 and event.value
                return false

            null

        removeIp : ( event ) ->

            data = event.target.dataset

            children = event.target.children

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_ROUTE', uid, data, children

        changeName : ( event ) ->

            target = $ event.currentTarget
            name = target.val()
            id = $("#rt-name").data 'uid'

            MC.validate.preventDupname target, id, name, 'Instance'

            if target.parsley 'validate'
                @trigger 'SET_NAME', id, name
                @setTitle name

        setMainRT : () ->

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_MAIN_RT', uid

        changePropagation : ( event ) ->

            console.log event
            uid = $("#rt-name").data 'uid'
            this.trigger 'SET_PROPAGATION', uid, event.target.dataset.uid

        onPressCIDR : ( event ) ->

            if (event.keyCode is 13)
                $(event.currentTarget).blur()

        onFocusCIDR : ( event ) ->

            MC.aws.aws.disabledAllOperabilityArea(true)
            null

        onBlurCIDR : ( event ) ->

            inputElem = $(event.currentTarget)
            inputValue = inputElem.val()

            parentElem = inputElem.parents('.multi-input')
            gwType = parentElem.attr('data-type')
            gwUIDRef = parentElem.attr('data-ref')
            gwUID = gwUIDRef.slice(1).split('.')[0]

            allCidrAry = []
            repeatFlag = false
            allCidrInputElemAry = inputElem.parents('.option-group').find('.ip-main-input')
            _.each allCidrInputElemAry, (inputElem) ->
                cidrValue = $(inputElem).val()
                if cidrValue isnt inputValue
                    allCidrAry.push(cidrValue)
                else
                    if repeatFlag then allCidrAry.push(cidrValue)
                    if !repeatFlag then repeatFlag = true
                null

            haveError = true
            if !inputValue
                mainContent = 'CIDR block is required.'
                descContent = 'Please provide a IP ranges for this route.'
            else if !MC.validate 'cidr', inputValue
                mainContent = inputValue + ' is not a valid form of CIDR block.'
                descContent = 'Please provide a valid IP range. For example, 10.0.0.1/24.'
            else if !MC.aws.rtb.isNotCIDRConflict(inputValue, allCidrAry)
                mainContent = inputValue + ' conflicts with other route.'
                descContent = 'Please choose a CIDR block not conflicting with existing route.'
            else
                haveError = false

            if haveError
                brotherElemAry = inputElem.parents('.multi-ipt-row').prev('.multi-ipt-row')
                if brotherElemAry.length isnt 0
                    MC.aws.aws.disabledAllOperabilityArea(false)
                    return

                dialog_template = MC.template.setupCIDRConfirm {
                    remove_content : 'Remove Route',
                    main_content : mainContent,
                    desc_content : descContent
                }
                modal dialog_template, false, () ->

                    $('.modal-close').click () ->
                        inputElem.focus()

                    $('#cidr-remove').click () ->
                        connectionObj = MC.canvas_data.layout.component.node[gwUID].connection[0]
                        if connectionObj
                            lineUID = connectionObj.line
                            rtUID = connectionObj.target
                            $("#svg_canvas").trigger("CANVAS_OBJECT_DELETE", {
                                'id': lineUID,
                                'type': 'line'
                            })
                        MC.aws.aws.disabledAllOperabilityArea(false)
                        modal.close()
            else
                data = event.target.parentNode.parentNode.parentNode.dataset
                children = event.target.parentNode.parentNode.parentNode.children
                uid = $("#rt-name").data 'uid'
                this.trigger 'SET_ROUTE', uid, data, children
                MC.aws.aws.disabledAllOperabilityArea(false)

            null

    }

    new RTBView()
