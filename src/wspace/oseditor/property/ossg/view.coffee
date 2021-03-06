define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    'UI.selection'
    'UI.bubblepopup'
    '../validation/ValidationBase'
], ( constant, OsPropertyView, template, CloudResources, bindSelection, bubblePopup, ValidationBase ) ->

    OsPropertyView.extend {

        events:

            "change .selection[data-target]": "updateAttribute"
            "click .direction-switch .t-m-btn": "switchDirection"
            "click .rule-item-remove": "removeRule"
            "click .os-sg-remove": "removeSG"
            "focus .os-sg-new-input": "focusNewInput"

        className: 'float-panel-sg'

        initialize: (options) ->

            that = @

            that.sgModel = options.sgModel
            that.listView = options.listView

            @selectTpl =

                ipValid: (value) ->

                    if MC.validate('cidr', value)
                        return true

                    if Design.instance().component(value)
                        return true

                    return false

                portValid: (value) ->

                    return false if not (value and value[0])

                    value = value[0]

                    rule = that.getRuleValue(@)

                    # for tcp and udp
                    if rule.protocol in ['tcp', 'udp', 'all']
                        return true if that.getPortRange(value)
                    # for icmp
                    else
                        return true if that.getICMPRange(value)

                    return false

                ipTipTpl: () ->

                    return template.sgIPInputTip()
            return

        render: ->

            that = @

            SGValid = ValidationBase.getClass(constant.RESTYPE.OSSG)
            bindSelection(@$el, @selectTpl, new SGValid({
                view: @,
                model: that.sgModel
            }))

            ingressRules = []
            egressRules = []
            sgRules = that.sgModel.get('rules')

            _.each sgRules, (ruleModel) ->

                ruleStrObj = that.getRuleStr(ruleModel)

                if ruleStrObj.direction is 'ingress'
                    ingressRules.push(ruleStrObj)
                else if ruleStrObj.direction is 'egress'
                    egressRules.push(ruleStrObj)

            memberModelList = @sgModel.getMemberList()

            memberList = _.map memberModelList, (member) ->
                if member.isEmbedded and member.isEmbedded()
                    member = member.owner()
                return {
                    name: member.get('name')
                }

            currentMode = Design.instance().mode()
            if not @sgModel.get('appId')
                currentMode = 'stack'

            modeIsAppEdit = currentMode is 'appedit'
            modeIsApp = currentMode is 'app'

            @$el.html template.stack({
                id: @sgModel.get('appId'),
                name: @sgModel.get('name'),
                description: @sgModel.get('description'),
                defaultSG: @sgModel.isDefault(),
                ingressRules: ingressRules,
                egressRules: egressRules,
                memberList: memberList,
                modeIsAppEdit: modeIsAppEdit,
                modeIsApp: modeIsApp
            })

            _.delay () ->
                that.$el.find('.rule-item').each () ->
                    that.initSGList($(this))

            if not modeIsApp
                @addNewItem(@$el.find('.rule-list'))

            @setTitle(@sgModel.get('name'))

            @updateCount()

            @

        nullStr: 'N/A'

        initSGList: ($ruleItem) ->

            allSGModels = Design.modelClassForType(constant.RESTYPE.OSSG).allObjects()
            allSGObjs = _.map allSGModels, (sgModel) ->
                return {
                    text: sgModel.get('name')
                    value: sgModel.id
                }

            $selectDom = $ruleItem.find('select.selection[data-target="ip"]')
            selectDom = $selectDom[0]
            if selectDom and selectDom.selectize
                # selectDom.selectize.clearOptions()
                selectDom.selectize.addOption(allSGObjs)

        switchDirection: (event) ->

            $target = $(event.currentTarget)
            @$el.find('.direction-switch .t-m-btn').removeClass('active')
            $target.addClass('active')

            @$el.find('.rule-container').addClass('hide')
            if $target.hasClass('ingress')
                @$el.find('.rule-container.ingress').removeClass('hide')
            else
                @$el.find('.rule-container.egress').removeClass('hide')

        setTitle: ( title ) -> @$( 'h1' ).text title

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            if "protocol|port|ip".indexOf( attr ) >= 0

                rule = @getRuleValue($target)
                if not rule then return

                if attr is 'protocol'
                    @setDefaultPort(rule, $target)

                $ruleItem = $target.parents('.rule-item')
                ruleModel = @sgModel.getRule( $ruleItem.data('id') )

                if ruleModel
                    rule.appId = ""
                    ruleModel.set( rule )
                else
                    newRuleId = @sgModel.addRule(rule) if rule
                    @addNewItem($ruleItem)
                    $ruleItem.data('id', newRuleId)
                    @updateCount()
                    @listView.refreshList()

            if attr is 'name'
                @sgModel.set('name', value)
                @setTitle(value)
                @listView.refreshList()

            if attr is 'description'
                @sgModel.set('description', value)

            @refreshDeleteState()

        refreshDeleteState: () ->

            @$el.find('.rule-item').each () ->
                if $(this).data('id')
                    $(this).find('.icon-delete').removeClass('hide')
                else
                    $(this).find('.icon-delete').addClass('hide')

        addNewItem: ($lastItem) ->

            that = @

            if @$el.find('input.os-sg-new-input').length <= 1

                if $lastItem.hasClass('rule-item')
                    $newItem = $(template.sgNewInput()).insertAfter($lastItem)
                else
                    $newItem = $(template.sgNewInput()).appendTo($lastItem)

        removeRule: (event) ->

            $target = $(event.currentTarget)
            $ruleItem = $target.parents('.rule-item')
            ruleId = $ruleItem.data('id')
            if ruleId
                @sgModel.removeRule(ruleId)
                $ruleItem.remove()
                @updateCount()
                @listView.refreshList()

        setDefaultPort: (rule, $target) ->

            $ruleContainer = $target.parents('.rule-item')
            $port = $ruleContainer.find('input[data-target="port"]')

            $port.removeAttr('disabled')
            if rule.protocol in ['tcp', 'udp']
                $port.val('1-65535')
            else if rule.protocol is 'icmp'
                $port.val('-1/-1')
            else if rule.protocol is null
                $port.val(@nullStr)
                $port.attr('disabled', 'disabled')

        getPortStr: (min, max) ->

            if min is null or max is null
                return '1-65535'

            if min is max
                return min + ''
            else
                return min + '-' + max

        getICMPStr: (type, code) ->

            type = -1 if type is null
            code = -1 if code is null
            return type + '/' + code

        getPortRange: (portStr) ->

            return [null, null] if portStr is '1-65535'

            portRange = MC.validate.portRange(portStr)
            if portRange and MC.validate.portValidRange(portRange)
                return null if portRange[0] is 0
                if portRange.length is 1
                    portRange[1] = portRange[0]
                return portRange
            else
                return null

        getICMPRange: (icmpStr) ->

            icmpAry = icmpStr.split('/')
            if icmpAry and icmpAry.length is 2
                icmpType = Number(icmpAry[0])
                icmpCode = Number(icmpAry[1])
                if not isNaN(icmpType) and not isNaN(icmpCode) and _.isNumber(icmpType) and _.isNumber(icmpCode)
                    return null if icmpType < -1 or icmpType > 255
                    return null if icmpCode < -1 or icmpCode > 255
                    icmpType = null if icmpType is -1
                    icmpCode = null if icmpCode is -1
                    icmpAry[0] = icmpType
                    icmpAry[1] = icmpCode
                    return icmpAry
            return null

        # for model to use
        getRuleValue: ($target) ->

            # direction        : @get( "direction" )
            # port_range_min   : @get( "portMin" )
            # port_range_max   : @get( "portMax" )
            # protocol         : @get( "protocol" )
            # remote_group_id  : if sg then sg.createRef( "id" ) else null
            # remote_ip_prefix : @get( "ip" )
            # id               : @get( "appId" )

            $ruleItem = $target.parents('.rule-item')

            $ruleContainer = $ruleItem.parents('.rule-container')

            $protocol = $ruleItem.find('select[data-target="protocol"]')
            $port = $ruleItem.find('input[data-target="port"]')
            $ip = $ruleItem.find('select[data-target="ip"]')

            protocol = $protocol.getValue()
            port = $port.getValue()
            ip = $ip.getValue()

            ip = null if ip is '0.0.0.0/0' or not ip
            sg = null

            sgModel = Design.instance().component(ip)
            if sgModel
                sg = sgModel
                ip = null

            direction = 'ingress'
            if $ruleContainer.hasClass('egress')
                direction = 'egress'

            if protocol is 'all'
                protocol = null
                port_range_min = null
                port_range_max = null
            else if protocol is 'icmp'
                port = @getICMPRange(port)
                if port is null
                    port_range_min = null
                    port_range_max = null
                else
                    port_range_min = port[0]
                    port_range_max = port[1]
            else
                port = @getPortRange(port)
                if port is null
                    port_range_min = null
                    port_range_max = null
                else
                    port_range_min = port[0]
                    port_range_max = port[1]

            return {
                direction: direction,
                protocol: protocol,
                portMin: port_range_min,
                portMax: port_range_max,
                ip: ip,
                sg: sg
            }

        # for view to use
        getRuleStr: (ruleModel) ->

            # protocol: protocol,
            # port: @getPortRange(port),
            # ip: ip

            rule = ruleModel.toJSON()

            direction = rule.direction
            ip = rule.remote_ip_prefix
            protocol = rule.protocol

            ip = '0.0.0.0/0' if ip is null
            sgModel = ruleModel.get('sg')
            if sgModel
                ip = sgModel.get('name')
                sgId = sgModel.id

            if rule.protocol in ['tcp', 'udp']
                port = @getPortStr(rule.port_range_min, rule.port_range_max)
            else if rule.protocol in ['icmp']
                port = @getICMPStr(rule.port_range_min, rule.port_range_max)
            else
                protocol = 'all'
                port = @nullStr

            ruleData = {
                id: ruleModel.id,
                direction: direction,
                protocol: protocol,
                port: port,
                ip: ip,
                sgId: sgId
            }

        removeSG: (event) ->

            that = @
            bubblePopup $(event.currentTarget), template.sgRemovePopup(), {
                '.confirm': () ->
                    that.sgModel.remove()
                    that.listView.refreshList()
                    that.listView.hideFloatPanel()
            }

        updateCount: () ->

            sgRules = @sgModel.get('rules')
            ingressRules = _.filter sgRules, (ruleModel) ->
                return ruleModel.get('direction') is 'ingress'

            @$el.find('.sg-rule-count').text(sgRules.length)
            @$el.find('.sg-ingress-count').text(ingressRules.length)
            @$el.find('.sg-egress-count').text(sgRules.length - ingressRules.length)
            @$el.find('.sg-member-count').text(@sgModel.getMemberList().length)

        focusNewInput: (event) ->

            that = @
            $lastItem = $(event.currentTarget)
            $newItem = $(template.newItem()).insertAfter($lastItem)

            that.initSGList($newItem) if $newItem

            _.delay () ->
                $newItem.find('.selection[data-target="port"]').focus()

            $lastItem.remove()

    }, {
        handleTypes: [ 'ossg' ]
        handleModes: [ 'stack', 'appedit', 'app' ]
    }
