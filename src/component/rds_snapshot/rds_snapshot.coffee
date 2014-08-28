define ['CloudResources', 'ApiRequest', 'constant', 'combo_dropdown', "UI.modalplus", 'toolbar_modal', "i18n!/nls/lang.js", 'component/rds_snapshot/template'], (CloudResources, ApiRequest , constant, combo_dropdown, modalPlus, toolbar_modal, lang, template)->
    fetched = false
    deleteCount = 0
    deleteErrorCount = 0
    fetching = false
    regionsMark = {}
    snapshotRes = Backbone.View.extend
        constructor: ()->
            @collection = CloudResources constant.RESTYPE.DBSNAP, Design.instance().region()
            @listenTo @collection, 'update', (@onChange.bind @)
            @listenTo @collection, 'change', (@onChange.bind @)
            @

        onChange: ->
            @initManager()
            @trigger 'datachange', @

        remove: ()->
            @.isRemoved = true
            Backbone.View::remove.call @

        render: ()->
            @renderManager()

        renderDropdown: ()->
            option =
                filterPlaceHolder: lang.ide.PROP_SNAPSHOT_FILTER_VOLUME
            @dropdown = new combo_dropdown(option)
            @instances = CloudResources constant.RESTYPE.DBINSTANCE, Design.instance().region()
            selection = lang.ide.PROP_INSTANCE_SNAPSHOT_SELECT
            @dropdown.setSelection selection

            @dropdown.on 'open', @openDropdown, @
            @dropdown.on 'filter', @filterDropdown, @
            @dropdown.on 'change', @selectSnapshot, @
            @dropdown

        renderRegionDropdown: (exceptRegion)->
            option =
                filterPlaceHolder: lang.ide.PROP_SNAPSHOT_FILTER_REGION
            @regionsDropdown = new combo_dropdown(option)
            @regions = _.keys constant.REGION_LABEL
            if exceptRegion
              @regions = _.without @regions, exceptRegion
            selection = lang.ide.PROP_VOLUME_SNAPSHOT_SELECT_REGION
            @regionsDropdown.setSelection selection
            @regionsDropdown.on 'open', @openRegionDropdown, @
            @regionsDropdown.on 'filter', @filterRegionDropdown, @
            @regionsDropdown.on 'change', @selectRegion, @
            @regionsDropdown

        openRegionDropdown: (keySet)->
            currentRegion = Design.instance().get 'region'
            data = _.map @regions, (region)->
                {name: constant.REGION_LABEL[region]+" - "+constant.REGION_SHORT_LABEL[ region ], selected: region == currentRegion, region: region}
            dataSet =
                isRuntime: false
                data: data
            if keySet
                dataSet.data = keySet
                dataSet.hideDefaultNoKey = true
            content = template.keys dataSet
            @regionsDropdown.toggleControls false, 'manage'
            @regionsDropdown.toggleControls true, 'filter'
            @regionsDropdown.setContent content

        openDropdown: (keySet)->
            @instances.fetch().then =>
                data = @instances.toJSON()
                if data.length < 1
                  @dropdown.setContent template.noinstance()
                  return false
                dataSet =
                    isRuntime: false
                    data: data
                if keySet
                    dataSet.data = keySet
                    dataSet.hideDefaultNoKey = true
                content = template.keys dataSet
                @dropdown.toggleControls false, 'manage'
                @dropdown.toggleControls true, 'filter'
                @dropdown.setContent content

        filterDropdown: (keyword)->
            hitKeys = _.filter @instances.toJSON(), ( data ) ->
                data.id.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1
            if keyword
                @openDropdown hitKeys
            else
                @openDropdown()


        filterRegionDropdown: (keyword)->
            hitKeys = _.filter @regions, ( data ) ->
                data.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1
            if keyword
                @openRegionDropdown hitKeys
            else
                @openRegionDropdown()


        selectSnapshot: (e)->
            $("#property-db-instance-choose .selection .manager-content-sub").remove()
            @manager.$el.find('[data-action="create"]').prop 'disabled', false

        selectRegion: (e)->
            @manager.$el.find('[data-action="duplicate"]').prop 'disabled', false

        renderManager: ()->
            @manager = new toolbar_modal @getModalOptions()
            @manager.on 'refresh', @refresh, @
            @manager.on "slidedown", @renderSlides, @
            @manager.on "slideup", @resetSlide, @
            @manager.on 'action', @doAction, @
            @manager.on 'detail', @detail, @
            @manager.on 'close', =>
                @manager.remove()
                @collection.remove()
            @manager.on 'checked', @processDuplicate, @

            @manager.render()
            if not App.user.hasCredential()
                @manager?.render 'nocredential'
                return false
            @initManager()

        resetSlide: ->
          @manager.$el.find(".slidebox").removeAttr('style')

        processDuplicate: ( event, checked ) ->
            if checked.length is 1
                @M$('[data-btn=duplicate]').prop 'disabled', false
            else
                @M$('[data-btn=duplicate]').prop 'disabled', true

        refresh: ->
            fetched = false
            @initManager()

        setContent: ->
            fetching = false
            fetched = true
            data = @collection.toJSON()
            _.each data, (e,f)->
                if e.PercentProgress is 100
                    e.completed = true
                if e.SnapshotCreateTime
                    e.started = (new Date(e.SnapshotCreateTime)).toString()
                null
            dataSet =
                items: data
            content = template.content dataSet
            @manager?.setContent content

        initManager: ()->
            setContent = @setContent.bind @
            currentRegion = Design.instance().get('region')
            if (not fetched and not fetching) or (not regionsMark[currentRegion])
                fetching = true
                regionsMark[currentRegion] = true
                @collection.fetchForce().then setContent, setContent
            else if not fetching
                @setContent()

        renderSlides: (which, checked)->
            tpl = template['slide_'+ which]
            slides = @getSlides()
            slides[which]?.call @, tpl, checked

        getSlides: ->
            'delete': (tpl, checked)->
                checkedAmount = checked.length
                if not checkedAmount
                    return
                data = {}
                if checkedAmount is 1
                    data.selectedName = checked[0].data.name
                else
                    data.selectedCount = checkedAmount
                @manager.setSlide tpl data
            'create':(tpl)->
                data =
                    volumes : {}
                @manager.setSlide tpl data
                @dropdown = @renderDropdown()
                @manager.$el.find('#property-db-instance-choose').html(@dropdown.$el)
                @manager.$el.find(".slidebox").css('overflow',"visible")
            'duplicate': (tpl, checked)->
                data = {}
                data.originSnapshot = checked[0]
                data.region = Design.instance().get('region')
                if not checked
                    return
                data.newCopyName = checked[0].id.split(':').pop()+ "-copy"
                snapshot = @collection.get checked[0].id
                console.log(snapshot)
                @manager.setSlide tpl data
                if snapshot.isAutomated()
                  @regionsDropdown = @renderRegionDropdown()
                else
                  @regionsDropdown = @renderRegionDropdown(snapshot.collection.region())
                @regionsDropdown.on 'change', =>
                    @manager.$el.find('[data-action="duplicate"]').prop 'disabled', false
                @manager.$el.find('#property-region-choose').html(@regionsDropdown.$el)
                @manager.$el.find(".slidebox").css('overflow',"visible")

        doAction: (action, checked)->
            @["do_"+action] and @["do_"+action]('do_'+action,checked)

        do_create: (validate, checked)->
            if not $('#property-snapshot-name-create').parsley 'validate'
              return false
            dbInstance = @instances.findWhere('id': $('#property-db-instance-choose').find('.selectbox .selection .manager-content-main').data('id'))
            if not dbInstance
                return false
            data =
                "DBSnapshotIdentifier": $("#property-snapshot-name-create").val()
                'DBInstanceIdentifier': dbInstance.id
            @switchAction 'processing'
            afterCreated = @afterCreated.bind @
            @collection.create(data).save().then afterCreated, afterCreated

        do_delete: (invalid, checked)->
            that = @
            deleteCount += checked.length
            @switchAction 'processing'
            afterDeleted = that.afterDeleted.bind that
            _.each checked, (data)=>
                @collection.findWhere(id: data.data.id).destroy().then afterDeleted, afterDeleted

        do_duplicate: (invalid, checked)->
            sourceSnapshot = checked[0]
            targetRegion = $('#property-region-choose').find('.selectbox .selection .manager-content-main').data('id')
            if (@regions.indexOf targetRegion) < 0
                return false
            @switchAction 'processing'
            newName = @manager.$el.find('#property-snapshot-name').val()
            afterDuplicate = @afterDuplicate.bind @
            accountNumber = App.user.attributes.account
            if not /^\d+$/.test accountNumber.split('-').join('')
              notification('error', lang.ide.PROP_DB_SNAPSHOT_ACCOUNT_NUMBER_INVALID)
              return false
            @collection.findWhere(id: sourceSnapshot.data.id).copyTo( targetRegion, newName).then afterDuplicate, afterDuplicate


        afterCreated: (result,newSnapshot)->
            @manager.cancel()
            if result.error
                notification 'error', lang.ide.PROP_DB_SNAPSHOT_CREATE_FAILED +result.msg
                return false
            notification 'info', lang.ide.PROP_DB_SNAPSHOT_CREATE_SUCCESS
            #@collection.add newSnapshot

        afterDuplicate: (result)->
            currentRegion = Design.instance().get('region')
            @manager.cancel()
            if result.error
                notification 'error', lang.ide.PROP_DB_SNAPSHOT_DUPLICATE_FAILED+ (result.awsResult || result.msg)
                return false
            #cancelselect && fetch
            if result.attributes.region is currentRegion
                @collection.add result
                notification 'info', lang.ide.PROP_DB_SNAPSHOT_DUPLICATE_SUCCESS
            else
                @initManager()
                notification 'info', lang.ide.PROP_DB_SNAPSHOT_DUPLICATE_SUCCESS_OTHER_REGION

        afterDeleted: (result)->
            deleteCount--
            if result.error
                deleteErrorCount++
            if deleteCount is 0
                if deleteErrorCount > 0
                    notification 'error', deleteErrorCount+ lang.ide.PROP_DB_SNAPSHOT_DELETE_FAILED
                else
                    notification 'info',  lang.ide.PROP_DB_SNAPSHOT_DELETE_SUCCESS
                @manager.unCheckSelectAll()
                deleteErrorCount = 0
                @manager.cancel()

        switchAction: ( state ) ->
            if not state
                state = 'init'
            @M$( '.slidebox .action' ).each () ->
                if $(@).hasClass state
                    $(@).show()
                else
                    $(@).hide()

        detail: (event, data, $tr) ->
          snapshotId = data.id
          snapshotData = @collection.get(snapshotId).toJSON()
          detailTpl = template.detail snapshotData
          @manager.setDetail($tr, detailTpl)

        getModalOptions: ->
            that = @
            region = Design.instance().get('region')
            regionName = constant.REGION_SHORT_LABEL[ region ]

            title: "Manage DB Snapshots in #{regionName}"
            slideable: true
            context: that
            buttons: [
                {
                    icon: 'new-stack'
                    type: 'create'
                    name: 'Create Snapshot'
                }
                {
                    icon: 'duplicate'
                    type: 'duplicate'
                    disabled: true
                    name: 'Duplicate'
                }
                {
                    icon: 'del'
                    type: 'delete'
                    disabled: true
                    name: 'Delete'
                }
                {
                    icon: 'refresh'
                    type: 'refresh'
                    name: ''
                }
            ]
            columns: [
                {
                    sortable: true
                    width: "30%" # or 40%
                    name: 'Name'
                }
                {
                    sortable: true
                    rowType: 'number'
                    width: "20%" # or 40%
                    name: 'Capicity'
                }
                {
                    sortable: true
                    rowType: 'datetime'
                    width: "40%" # or 40%
                    name: 'status'
                }
                {
                    sortable: false
                    width: "10%" # or 40%
                    name: 'Detail'
                }
            ]

    snapshotRes
