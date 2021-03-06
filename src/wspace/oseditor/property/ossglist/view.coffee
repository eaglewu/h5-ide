define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    '../ossg/view'
    'UI.selection'
    '../validation/ValidationBase'
], ( constant, OsPropertyView, template, CloudResources, SgView, bindSelection, ValidationBase ) ->

    OsPropertyView.extend {

        events:

            "change .selection[data-target]": "updateAttribute"

            "select_dropdown_button_click .item-list": "addItem"
            "click .item-list .item": "editItem"
            "click .item-readable-list .item": "editItem"

            "select_item_add .item-list": "attachItem"
            "select_item_remove .item-list": "unAttachItem"
            "click .item-list .item .item-remove": "unAttachItemClick"
            "mousedown .item-list .item .item-remove": "unAttachItemMousedown"

        initialize: (options) ->

            that = @
            @targetModel = options.targetModel
            @panel = options.panel

            @selectTpl =

                button: () ->
                    return template.addButton()

                sgItem: (item) ->

                    return template.item({
                        name: item.text
                    })

                sgOption: (data) ->

                    sgModel = Design.instance().component(data.value)
                    return template.option({
                        name: data.text,
                        ruleCount: sgModel.get('rules').length,
                        memberCount: sgModel.getMemberList().length,
                        description: sgModel.get('description')
                    })
            return

        # getAttachSGForApp: () ->
        #
        #     attachedSGModel = []
        #     region = Design.instance().region()
        #     targetAppModel = CloudResources(@targetModel.type, region)?.get @targetModel.get('appId')
        #     if targetAppModel and targetAppModel.security_groups
        #         _.each targetAppModel.security_groups, (sgId) ->
        #             sgAppModel = CloudResources(constant.RESTYPE.OSSG, region)?.get(sgId)
        #             attachedSGModel.push(sgAppModel) if sgAppModel
        #             null
        #     return attachedSGModel

        render: ->

            SGValid = ValidationBase.getClass(constant.RESTYPE.OSSG)
            bindSelection(@$el, @selectTpl, new SGValid({
                view: @
            }))
            @refreshList()
            @

        refreshList: () ->

            currentMode = Design.instance().mode()

            if @targetModel and not @targetModel.get('appId')
                currentMode = 'stack'

            # all sg
            OSSGModel = Design.modelClassForType(constant.RESTYPE.OSSG)
            allSGModels = OSSGModel.allObjects()
            sgList = []
            _.each allSGModels, (sgModel) ->
                sgName = sgModel.get('name')
                sgUID = sgModel.get('id')
                sgList.push({
                    name: sgName,
                    uid: sgUID,
                    id: sgModel.id,
                    ruleCount: sgModel.get('rules').length,
                    memberCount: sgModel.getMemberList().length,
                    description: sgModel.get('description')
                })

            if currentMode in ['stack', 'appedit']

                # attached sg
                if @targetModel

                    attachedSGModels = @targetModel.connectionTargets("OsSgAsso")
                    attachedSGList = []
                    _.each attachedSGModels, (sgModel) ->
                        sgUID = sgModel.get('id')
                        attachedSGList.push(sgUID)

                    @$el.html template.stack({
                        sgList: sgList,
                        attachedSGList: attachedSGList.join(',')
                    })

                else

                    @$el.html template.app({
                        attachedSGList: sgList
                    })

                @refreshRemoveState()

            else

                # attached sg
                if @targetModel

                    attachedSGModels = @targetModel.connectionTargets("OsSgAsso")
                    attachedSGList = []
                    _.each attachedSGModels, (sgModel) ->
                        attachedSGList.push({
                            id: sgModel.id,
                            name: sgModel.get('name'),
                            ruleCount: sgModel.get('rules').length,
                            memberCount: sgModel.getMemberList().length,
                            description: sgModel.get('description')
                        })
                    @$el.html template.app({
                        attachedSGList: attachedSGList
                    })

                else

                    @$el.html template.app({
                        attachedSGList: sgList
                    })

        refreshRemoveState: () ->

            if @targetModel

                attachedSGModels = @targetModel.connectionTargets("OsSgAsso")
                if attachedSGModels.length <= 1
                    @$el.find('.item-list .item-remove').addClass('hide')
                else
                    @$el.find('.item-list .item-remove').removeClass('hide')

        getSelectItemModel: ($sgItem) ->

            sgId = $sgItem.data('value') or $sgItem.data('id')
            sgModel = Design.instance().component(sgId)
            return sgModel

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()
            return

        addItem: (event, value) ->

            OSSGModel = Design.modelClassForType(constant.RESTYPE.OSSG)

            if value
                oSSGModel = new OSSGModel({name: value})
            else
                oSSGModel = new OSSGModel({})

            sgUID = oSSGModel.get('id')
            @attachItem(null, sgUID)
            @refreshList()
            $newItem = @$el.find('.item-list .item[data-value="' + sgUID + '"]')
            $newItem.click()
            return false

        editItem: (event) ->

            $target = $(event.currentTarget)
            sgModel = @getSelectItemModel($target)

            sgView = new SgView({
                sgModel: sgModel,
                listView: @
            })

            isReadable = $target.parents('.item-readable-list').length

            if isReadable

                $target.parents('.item-readable-list').find('.item').removeClass('active')
                $target.addClass('active')

            @showFloatPanel sgView.render().el, () ->
                $target.removeClass('active') if isReadable

            return false

        attachItem: (event, sgUID) ->

            sgModel = Design.instance().component(sgUID)
            sgModel.attachSG(@targetModel)
            @refreshRemoveState()

        unAttachItem: (event, sgUID) ->

            sgModel = Design.instance().component(sgUID)
            sgModel.unAttachSG(@targetModel)
            @refreshRemoveState()

        unAttachItemClick: (event) ->

            $target = $(event.currentTarget)
            $sgItem = $target.parents('.item')
            sgModel = @getSelectItemModel($sgItem)
            sgModel.unAttachSG(@targetModel)
            @refreshList()
            return false

    }, {
        handleTypes: [ 'ossglist' ]
        handleModes: [ 'stack', 'appedit', 'app' ]
    }
