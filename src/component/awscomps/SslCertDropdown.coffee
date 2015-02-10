define [ 'constant', 'CloudResources','sslcert_manage', 'combo_dropdown', 'component/awscomps/SslCertTpl', 'i18n!/nls/lang.js' ], ( constant, CloudResources, sslCertManage, comboDropdown, template, lang ) ->

    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            region = Design.instance().region()
            @sslCertCol = CloudResources Design.instance().credentialId(), constant.RESTYPE.IAM, region
            @sslCertCol.on 'update', @processCol, @

        initDropdown: ->
            options =
                manageBtnValue      : lang.PROP.INSTANCE_MANAGE_SSL_CERT
                filterPlaceHolder   : lang.PROP.INSTANCE_FILTER_SSL_CERT

            @dropdown = new comboDropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manage, @
            @dropdown.on 'change', @set, @
            @dropdown.on 'filter', @filter, @
            @dropdown.on 'quick_create', @quickCreate, @

        initialize: () ->
            @initCol()
            @initDropdown()

        quickCreate: () ->
            new sslCertManage().render().quickCreate()

        render: ->

            selectionName = @sslCertName or 'None'

            @el = @dropdown.el

            if selectionName is 'None'
                $(@el).addClass('empty')
                @sslCertCol.fetch()

            @dropdown.setSelection selectionName

            # @setDefault()

            @

        setDefault: ->

            if @sslCertCol.isReady()

                data = @sslCertCol.toJSON()
                if data and data[0] and @uid
                    if @dropdown.getSelection() is 'None'

                        compModel = Design.instance().component(@uid)

                        if compModel

                            listenerAry = compModel.get('listeners')
                            currentListenerObj = listenerAry[@listenerNum]
                            if currentListenerObj and currentListenerObj.protocol in ['HTTPS', 'SSL']

                                compModel.setSSLCert(@listenerNum, data[0].id)
                                @dropdown.trigger 'change', data[0].id
                                @dropdown.setSelection data[0].Name
                                $(@el).removeClass('empty')

        processCol: ( filter, keyword ) ->

            if @sslCertCol.isReady()

                data = @sslCertCol.toJSON()
                @setDefault()

                if filter
                    len = keyword.length
                    data = _.filter data, ( d ) ->
                        d.Name.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1

                @renderDropdownList data

            false

        renderDropdownList: ( data ) ->

            if data.length
                selection = @dropdown.getSelection()
                _.each data, ( d ) ->
                    if d.Name and d.Name is selection
                        d.selected = true
                    null
                @dropdown.setContent(template.dropdown_list data).toggleControls true
            else
                @dropdown.setContent(template.no_sslcert({})).toggleControls true

        renderNoCredential: () ->
            @dropdown.render('nocredential').toggleControls false

        show: ->
            if Design.instance().credential()
                @sslCertCol.fetch()
                @processCol()
            else
                @renderNoCredential()

        manage: ->
            new sslCertManage().render()

        set: ( id, data ) ->

            if @uid and id

                listenerAry = Design.instance().component(@uid).get('listeners')
                currentListenerObj = listenerAry[@listenerNum]
                if currentListenerObj and currentListenerObj.protocol in ['HTTPS', 'SSL']
                    Design.instance().component(@uid).setSSLCert(@listenerNum, id)

        filter: (keyword) ->
            @processCol( true, keyword )
