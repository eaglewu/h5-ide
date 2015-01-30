define [
    'constant'
    'i18n!/nls/lang.js'
    '../template/TplCredential'
    'Credential'
    'ApiRequest'
    'UI.modalplus'
    'UI.tooltip'
    'UI.notification'
    'backbone'
], ( constant, lang, TplCredential, Credential, ApiRequest, Modal ) ->

    credentialFormView = Backbone.View.extend
        events:
            'keyup input' : 'updateSubmitBtn'

        initialize: ( options ) ->
            _.extend @, options

        render: ->
            if @credential
                data = @credential.toJSON()
                title = 'Update Cloud Credential'
                confirmText = 'Update'
            else
                data = {}
                title = 'Add Cloud Credential'
                confirmText = 'Add'

            @$el.html TplCredential.credentialForm data

            @modal = new Modal
                title: title
                template: @el
                confirm:
                    text: confirmText
                    disabled: true

            @modal.on 'confirm', ->
                @trigger 'confirm'
            , @

            @

        loading: ->
            @$( '#CredSetupWrap' ).hide()
            action =  if @credential then 'Update' else 'Add'
            @$el.append( TplCredential.credentialLoading { action: action } )
            @modal.toggleFooter false

        loadingEnd: ->
            @$('.loading-zone').remove()
            @$( '#CredSetupWrap' ).show()
            @modal.toggleFooter true

        remove: ->
            @modal?.close()
            Backbone.View.prototype.remove.apply @, arguments

        updateSubmitBtn : ()->
            d = @getData()

            if d.alias.length and d.awsAccount.length and d.awsAccessKey.length and d.awsSecretKey.length
                @modal.toggleConfirm false
            else
                @modal.toggleConfirm true
            return

        getData: ->
            that = @

            alias         : that.$( '#CredSetupAlias' ).val()
            awsAccount    : that.$( '#CredSetupAccount' ).val()
            awsAccessKey  : that.$( '#CredSetupAccessKey' ).val()
            awsSecretKey  : that.$( '#CredSetupSecretKey' ).val()




    Backbone.View.extend
        events:
            'click .setup-credential': 'showAddForm'
            'click .update-link'     : 'showUpdateForm'
            'click .show-button-list': 'showButtonList'
            'click .delete-link'     : 'showRemoveConfirmModel'

        className: 'credential'

        initialize: ->
            @listenTo @model, 'change:credentials', @render

        render: () ->
            credentials = @model.credentials()

            data = @model.toJSON()
            data.isAdmin = @model.amIAdmin()

            # Only support provider aws::global for now.
            # so if a non-demo credential exsit, the user can not add another credential then.

            # Only admin can add, update or remove credential
            if data.isAdmin
                if credentials.length is 0
                    data.addable = true
                else
                    data.addable = not _.some credentials, ( cred ) ->
                        not cred.isDemo()

            applist = @model.apps()

            data.credentials = _.map credentials, ( c ) ->
                json = c.toJSON()
                json.isAdmin = data.isAdmin
                json.name = constant.PROVIDER_NAME[json.provider]
                json.needed = _.some applist, ( app ) -> app.get( 'provider' ) is json.provider

                json


            @$el.html TplCredential.credentialManagement data
            @

        showButtonList: ->
            @$( '.button-list' ).toggle()
            false

        getCredentialById: ( id ) -> _.findWhere @model.credentials(), { id: id }

        makeModalLoading: ( modal, action ) ->
            modal
                .setContent( TplCredential.credentialLoading { action: action } )
                .toggleFooter false
            @

        stopModalLoading: ( modal, originContent ) ->
            modal
                .setContent( originContent )
                .toggleFooter true
            @

        showModalError: ( modal, message ) -> modal.$( '.cred-setup-msg' ).text message

        showAddForm: -> @showFormModal()

        showUpdateForm: ( e ) ->
            credentialId = $( e.currentTarget ).data 'id'
            credential = @getCredentialById credentialId
            @showFormModal credential

        addCredential: ( data ) ->
            that = @
            credentialData = {
                alias : data.alias
                account_id: data.awsAccount
                access_key: data.awsAccessKey
                secret_key: data.awsSecretKey
            }
            credentialData.provider = data.provider or constant.PROVIDER.AWSGLOBAL

            credential = new Credential credentialData, { project: @model }

            @formView.loading()
            credential.save().then () ->
                that.formView.remove()
            , ( error ) ->
                if error.error is ApiRequest.Errors.UserInvalidCredentia
                    msg = lang.IDE.SETTINGS_ERR_CRED_VALIDATE
                else
                    msg = lang.IDE.SETTINGS_ERR_CRED_UPDATE

                that.formView.loadingEnd()
                that.showModalError that.formView, msg


        updateCredential: ( credential, newData, force ) ->
            that = @
            @formView.loading()

            credential.save( newData, force ).then () ->
                that.updateConfirmView.close( 2 )
                that.formView.remove()
            , ( error ) ->
                that.formView.loadingEnd()

                if error.error is ApiRequest.Errors.UserInvalidCredentia
                    msg = lang.IDE.SETTINGS_ERR_CRED_VALIDATE
                else if error.error is ApiRequest.Errors.ChangeCredConfirm
                    that.showUpdateConfirmModel credential, newData
                else
                    msg = lang.IDE.SETTINGS_ERR_CRED_UPDATE

                msg and that.showModalError that.formView, msg

        removeCredential: ( credential ) ->
            that = @
            @makeModalLoading @removeConfirmView, 'Remove'

            credential.destroy().then () ->
                that.removeConfirmView?.close()
            , ( error ) ->
                that.stopModalLoading that.removeConfirmView, TplCredential.removeConfirm
                that.showModalError that.removeConfirmView, lang.IDE.SETTINGS_ERR_CRED_REMOVE

        showUpdateConfirmModel: ( credential, newData ) ->
            @updateConfirmView?.close()
            @updateConfirmView = new Modal {
                title: 'Update Cloud Credential'
                template: TplCredential.updateConfirm
                confirm:
                    text: 'Confirm to Update'
                    color: 'red'
            }

            @updateConfirmView.on 'confirm', ->
                @updateCredential credential, newData, true
            , @

        showRemoveConfirmModel: ( e ) ->
            credentialId = $( e.currentTarget ).data 'id'
            credential = @getCredentialById credentialId

            @removeConfirmView?.close()
            @removeConfirmView = new Modal {
                title: 'Delete Cloud Credential'
                template: TplCredential.removeConfirm
                confirm:
                    text: 'Remove Credential'
            }

            @removeConfirmView.on 'confirm', () ->
                @removeCredential credential
            , @

        showFormModal:( credential, provider ) ->
            @formView = new credentialFormView( provider:provider, credential: credential ).render()
            @formView.on 'confirm', ->
                if credential
                    @updateCredential credential, @formView.getData()
                else
                    @addCredential @formView.getData()
            , @

            @

        remove: ->
            @formView?.remove()
            @updateConfirmView?.close()
            @removeConfirmView?.close()
            Backbone.View.prototype.remove.apply @, arguments

