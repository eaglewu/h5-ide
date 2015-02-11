define [ 'constant', 'CloudResources','sns_manage', 'combo_dropdown', 'component/awscomps/SnsTpl', 'i18n!/nls/lang.js' ], ( constant, CloudResources, snsManage, comboDropdown, template, lang ) ->

    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            region = Design.instance().region()
            @subCol = CloudResources Design.instance().credentialId(), constant.RESTYPE.SUBSCRIPTION, region
            @topicCol = CloudResources Design.instance().credentialId(), constant.RESTYPE.TOPIC, region

            @listenTo @topicCol, 'update', @processCol
            @listenTo @topicCol, 'change', @processCol
            @listenTo @subCol, 'update', @processCol

        initDropdown: ->
            options =
                manageBtnValue      : lang.PROP.INSTANCE_MANAGE_SNS
                filterPlaceHolder   : lang.PROP.INSTANCE_FILTER_SNS
                classList           : 'sns-dropdown'
                resourceName        : lang.PROP.RESOURCE_NAME_SNS

            @dropdown = new comboDropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manage, @
            @dropdown.on 'change', @set, @
            @dropdown.on 'filter', @filter, @
            @dropdown.on 'quick_create', @quickCreate, @


        initialize: ( options ) ->
            if options and options.selection
                @selection = options.selection
            @initCol()
            @initDropdown()
            if Design.instance().credential() and not Design.instance().credential().isDemo()
                @topicCol.fetch()
                @subCol.fetch()

        render: ( needInit ) ->
            selection = @selection
            if needInit
                if @topicCol.first()
                    @selection = selection = @topicCol.first().get( 'Name' )
                    @processCol()
                    @trigger 'change', @topicCol.first().id, selection
                else
                    selection = template.dropdown_no_selection()
            else
                if not selection
                    selection = template.dropdown_no_selection()

            @dropdown.setSelection selection
            @el = @dropdown.el
            @

        quickCreate: ->
            new snsManage().render().quickCreate()

        processCol: ( filter, keyword ) ->
            that = @
            if @topicCol.isReady() and @subCol.isReady()
                data = @topicCol.map ( tModel ) ->
                    tData = tModel.toJSON()
                    sub = that.subCol.where TopicArn: tData.id
                    tData.sub = sub.map ( sModel ) -> sModel.toJSON()
                    tData.subCount = tData.sub.length
                    tData

                if filter is true
                    len = keyword.length
                    data = _.filter data, ( d ) ->
                        d.Name.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1

                selection = @selection
                _.each data, ( d ) ->
                    if d.Name and d.Name is selection
                        d.selected = true
                        null

                @renderDropdownList data, filter

            false


        renderDropdownList: ( data, filter ) ->
            if _.isEmpty( data ) and not filter
                region = Design.instance().region()
                regionName = constant.REGION_SHORT_LABEL[ region ]
                @dropdown
                    .setContent( template.nosns regionName: regionName )
                    .toggleControls( true, 'manage')
                    .toggleControls( false, 'filter' )
            else
                @dropdown.setContent( template.dropdown_list data ).toggleControls true

        renderNoCredential: () ->
            @dropdown.render('nocredential').toggleControls false

        show: ->
            if Design.instance().credential() and not Design.instance().credential().isDemo()
                @topicCol.fetch()
                @subCol.fetch()
                if not @dropdown.$( '.item' ).length
                    @processCol()
            else
                @renderNoCredential()

        manage: ->
            new snsManage().render()

        set: ( id, data ) ->
            @trigger 'change', id, data.name

        filter: ( keyword ) ->
            @processCol( true, keyword )

        remove: ->
            @dropdown.remove()
            Backbone.View.prototype.remove.apply @, arguments




