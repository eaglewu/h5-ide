#############################
#  View(UI logic) for dialog
#############################

define [ "./SettingsDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus" ,"backbone" ], ( SettingsTpl, lang, ApiRequest, Modal ) ->

    SettingsDialog = Backbone.View.extend {

      events :
        "click #SettingsNav span"         : "switchTab"
        "click #AccountPwd"               : "showPwd"
        "click #AccountCancelPwd"         : "hidePwd"
        "click #AccountUpdatePwd"         : "changePwd"
        "click .cred-setup, .cred-cancel" : "showCredSetup"
        "click .cred-setup-cancel"        : "cancelCredSetup"
        "click #CredSetupRemove"          : "showRemoveCred"
        "click #CredRemoveConfirm"        : "removeCred"
        "click #CredSetupSubmit"          : "submitCred"
        "click #CredSetupConfirm"         : "confirmCred"

        "click #TokenCreate"               : "createToken"
        "click .tokenControl .icon-edit"   : "editToken"
        "click .tokenControl .icon-delete" : "removeToken"
        "click .tokenControl .tokenDone"   : "doneEditToken"
        "click #TokenRemove"               : "confirmRmToken"
        "click #TokenRmCancel"             : "cancelRmToken"

        "keyup  #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey" : "updateSubmitBtn"
        "change #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey" : "updateSubmitBtn"
        "change #AccountCurrentPwd, #AccountNewPwd"                          : "updatePwdBtn"
        "keyup  #AccountCurrentPwd, #AccountNewPwd"                          : "updatePwdBtn"

        "click #AccountEmail"                       : "showEmail"
        "click #AccountCancelEmail"                 : "hideEmail"
        "click #AccountUpdateEmail"                 : "changeEmail"
        "click #AccountCancelFullName"              : "hideFullName"
        "change #AccountNewEmail, #AccountEmailPwd" : "updateEmailBtn"
        "keyup  #AccountNewEmail, #AccountEmailPwd" : "updateEmailBtn"
        "click #AccountUpdateFullName"              : "changeFullName"
        "change #AccountFirstName, #AccountLastName": "updateFullNameBtn"
        "keyup #AccountFirstName, #AccountLastName" : "updateFullNameBtn"
        'click #AccountFullName'                    : "showFullName"


      initialize : ( options )->

        attributes =
          username     : App.user.get("username")
          first_name   : App.user.get("first_name") || ""
          last_name    : App.user.get("last_name")  || ""
          email        : App.user.get("email")
          account      : App.user.get("account")
          awsAccessKey : App.user.get("awsAccessKey")
          awsSecretKey : App.user.get("awsSecretKey")

          credRemoveTitle : sprintf lang.IDE.SETTINGS_CRED_REMOVE_TIT, App.user.get("username")
          credNeeded : !!App.model.appList().length

        @modal = new Modal {
          template: SettingsTpl attributes
          title: lang.IDE.HEAD_LABEL_SETTING
          disableFooter: true
          compact: true
          width: "490px"
        }
        @setElement @modal.tpl
        @modal.$("#SettingsNav span[data-target='AccountTab']").click()
        @modal.resize()

        tab = 0
        if options
          tab = options.defaultTab || 0

          if tab is SettingsDialog.TAB.CredentialInvalid
            @showCredSetup()
            @modal.tpl.find(".modal-close").hide()
            @modal.tpl.find("#CredSetupMsg").text lang.IDE.SETTINGS_ERR_CRED_VALIDATE

          if tab < 0 then tab = Math.abs( tab )

        @modal.$("#SettingsNav").children().eq( tab ).click()

        @updateTokenTab()
        return

      updateCredSettings : ()->
        attributes =
          username     : App.user.get("username")
          email        : App.user.get("email")
          account      : App.user.get("account")
          awsAccessKey : App.user.get("awsAccessKey")
          awsSecretKey : App.user.get("awsSecretKey")

          credRemoveTitle : sprintf lang.IDE.SETTINGS_CRED_REMOVE_TIT, App.user.get("username")

        @modal.setContent SettingsTpl attributes
        @modal.$("#SettingsNav").children().eq( SettingsDialog.TAB.Credential ).click()



      switchTab : ( evt )->
        $this = $(evt.currentTarget)
        if $this.hasClass "selected" then return

        @modal.$("#SettingsBody").children().hide()
        @modal.$("#SettingsNav").children().removeClass("selected")
        @modal.$("#"+$this.addClass("selected").attr("data-target")).show()
        return

      showPwd : ()->
        @modal.$("#AccountPwd").hide()
        @modal.$("#AccountPwdWrap").show()
        @modal.$("#AccountCurrentPwd").focus()
        return

      hidePwd : ()->
        @modal.$("#AccountPwd").show()
        @modal.$("#AccountPwdWrap").hide()
        @modal.$("#AccountCurrentPwd, #AccountNewPwd").val("")
        @modal.$("#AccountInfo").empty()
        return

      updatePwdBtn : ()->
        old_pwd = @modal.$("#AccountCurrentPwd").val() || ""
        new_pwd = @modal.$("#AccountNewPwd").val() || ""

        if old_pwd.length and new_pwd.length
          @modal.$("#AccountUpdatePwd").removeAttr "disabled"
        else
          @modal.$("#AccountUpdatePwd").attr "disabled", "disabled"
        return

      changePwd : ()->
        that = @
        old_pwd = @modal.$("#AccountCurrentPwd").val() || ""
        new_pwd = @modal.$("#AccountNewPwd").val() || ""
        if new_pwd.length < 6
          @modal.$('#AccountInfo').text lang.IDE.SETTINGS_ERR_INVALID_PWD
          return

        @modal.$("#AccountInfo").empty()

        @modal.$("#AccountUpdatePwd").attr "disabled", "disabled"

        App.user.changePassword( old_pwd, new_pwd ).then ()->
          notification 'info', lang.NOTIFY.SETTINGS_UPDATE_PWD_SUCCESS
          $("#AccountCancelPwd").click()
          return
        , ( err )->
          if err.error is 2
            that.modal.$('#AccountInfo').html "#{lang.IDE.SETTINGS_ERR_WRONG_PWD} <a href='/reset/' target='_blank'>#{lang.IDE.SETTINGS_INFO_FORGET_PWD}</a>"
          else
            that.modal.$('#AccountInfo').text lang.NOTIFY.SETTINGS_UPDATE_PWD_FAILURE

          that.modal.$("#AccountUpdatePwd").removeAttr "disabled"

        return

      showEmail : ()->
        @hideFullName()
        $(".accountEmailRO").hide()
        $("#AccountEmailWrap").show()
        $("#AccountNewEmail").focus()
        return

      hideEmail : ()->
        $(".accountEmailRO").show()
        $("#AccountEmailWrap").hide()
        $("#AccountNewEmail, #AccountEmailPwd").val("")
        $("#AccountEmailInfo").empty()
        return

      showFullName: ()->
        @hideEmail()
        $(".accountFullNameRO").hide()
        $("#AccountFullNameWrap").show()
        $("#AccountFirstName").val(App.user.get("firstName") || "").focus()
        $("#AccountLastName").val(App.user.get("lastName") || "")
        return

      hideFullName: ()->
        $(".accountFullNameRO").show()
        $("#AccountFullNameWrap").hide()
        $("#AccountFirstName, #AccountLastName").val("")

      updateEmailBtn : ()->
        old_pwd = $("#AccountNewEmail").val() || ""
        new_pwd = $("#AccountEmailPwd").val() || ""

        if old_pwd.length and new_pwd.length >= 6
          $("#AccountUpdateEmail").removeAttr "disabled"
        else
          $("#AccountUpdateEmail").attr "disabled", "disabled"
        return

      updateFullNameBtn: ()->
        first_name = $("#AccountFirstName").val() || ""
        last_name  = $("#AccountLastName").val()  || ""

        if first_name.length and last_name.length
          $("#AccountUpdateFullName").removeAttr "disabled"
        else
          $("#AccountUpdateFullName").attr "disabled", "disabled"
        return

      changeFullName: ()->
        that = @
        first_name = $("#AccountFirstName").val() || ""
        last_name  = $("#AccountLastName").val()  || ""

        if first_name.length and last_name.length
          ApiRequest("account_update_account", {attributes : {first_name, last_name}})
          .then (result)->
            App.user.set("first_name", first_name)
            App.user.set("last_name", last_name)
            console.log(result)
            that.hideFullName()
            $(".fullNameText").text(first_name + " " + last_name)


      changeEmail : ()->
        email = $("#AccountNewEmail").val() || ""
        pwd   = $("#AccountEmailPwd").val() || ""

        $("#AccountEmailInfo").empty()
        $("#AccountUpdateEmail").attr "disabled", "disabled"

        App.user.changeEmail( email, pwd ).then ()->
          notification 'info', lang.NOTIFY.SETTINGS_UPDATE_EMAIL_SUCCESS
          $("#AccountCancelEmail").click()
          $(".accountEmailRO").children("span").text( App.user.get("email") )
          return
        , ( err )->
          switch err.error
            when 116
              text = lang.IDE.SETTINGS_UPDATE_EMAIL_FAIL3
            when 117
              text = lang.IDE.SETTINGS_UPDATE_EMAIL_FAIL2
            else
              text = lang.IDE.SETTINGS_UPDATE_EMAIL_FAIL1

          $('#AccountEmailInfo').text text
          $("#AccountUpdateEmail").removeAttr "disabled"
        return

      showCredSetup : ()->
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredSetupWrap").show()
        @modal.$("#CredSetupAccount").focus()[0].select()
        @modal.$("#CredSetupRemove").toggle App.user.hasCredential()
        @updateSubmitBtn()
        return

      cancelCredSetup : ()->
        @modal.$("#CredentialTab").children().hide()
        if App.user.hasCredential()
          @modal.$("#CredAwsWrap").show()
        else
          @modal.$("#CredDemoWrap").show()
        return

      showRemoveCred : ()->
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredRemoveWrap").show()
        return

      removeCred : ()->
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredRemoving").show()
        @modal.$("#modal-box .modal-close").hide()

        self = this
        App.user.changeCredential().then ()->
          self.updateCredSettings()
          return
        , ()->
          self.modal.$("#CredSetupMsg").text lang.IDE.SETTINGS_ERR_CRED_REMOVE
          self.modal.$("#modal-box .modal-close").show()
          self.showCredSetup()
        return

      updateSubmitBtn : ()->
        account    = @modal.$("#CredSetupAccount").val()
        accesskey  = @modal.$("#CredSetupAccessKey").val()
        privatekey = @modal.$("#CredSetupSecretKey").val()

        if account.length and accesskey.length and privatekey.length
          @modal.$("#CredSetupSubmit").removeAttr "disabled"
        else
          @modal.$("#CredSetupSubmit").attr "disabled", "disabled"
        return

      submitCred : ()->
        # First validate credential
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredUpdating").show()
        @modal.$("#modal-box .modal-close").hide()

        accesskey  = @modal.$("#CredSetupAccessKey").val()
        privatekey = @modal.$("#CredSetupSecretKey").val()

        self = this

        App.user.validateCredential( accesskey, privatekey ).then ()->
          self.setCred()
          return
        , ()->
          self.modal.$("#CredSetupMsg").text lang.IDE.SETTINGS_ERR_CRED_VALIDATE
          self.modal.$("#modal-box .modal-close").show()
          self.showCredSetup()
          return

      setCred : ()->
        account    = @modal.$("#CredSetupAccount").val()
        accesskey  = @modal.$("#CredSetupAccessKey").val()
        privatekey = @modal.$("#CredSetupSecretKey").val()

        # A quickfix to avoid the limiation of the api.
        # Avoid user setting the account to demo_account
        if account is "demo_account"
          account = "user_demo_account"
          @modal.$("#CredSetupAccount").val(account)

        self = this
        App.user.changeCredential( account, accesskey, privatekey, false ).then ()->
          self.updateCredSettings()
        , ( err )->
          if err.error is ApiRequest.Errors.ChangeCredConfirm
            self.showCredConfirm()
          else
            self.showCredUpdateFail()
          return

      showCredUpdateFail : ()->
        @modal.$("#CredSetupMsg").text lang.IDE.SETTINGS_ERR_CRED_UPDATE
        @modal.$("#modal-box .modal-close").show()
        @showCredSetup()

      showCredConfirm : ()->
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredConfirmWrap").show()
        @modal.$("#modal-box .modal-close").show()

      confirmCred : ()->
        account    = @modal.$("#CredSetupAccount").val()
        accesskey  = @modal.$("#CredSetupAccessKey").val()
        privatekey = @modal.$("#CredSetupSecretKey").val()

        # When we confirm to update. The key should be validated already.
        self = this
        App.user.changeCredential( account, accesskey, privatekey, true ).then ()->
          self.updateCredSettings()
        , ()->
          self.showCredUpdateFail()
        return

      editToken : ( evt )->
        $t = $(evt.currentTarget)
        $p = $t.closest("li").toggleClass("editing", true)
        $p.children(".tokenName").removeAttr("readonly").focus().select()
        return

      removeToken : ( evt )->
        $p = $(evt.currentTarget).closest("li")
        name = $p.children(".tokenName").val()
        @rmToken = $p.children(".tokenToken").text()
        @modal.$("#TokenManager").hide()
        @modal.$("#TokenRmConfirm").show()
        @modal.$("#TokenRmTit").text( sprintf lang.IDE.SETTINGS_CONFIRM_TOKEN_RM_TIT, name )
        return

      createToken : ()->
        @modal.$("#TokenCreate").attr "disabled", "disabled"

        self = this
        App.user.createToken().then ()->
          self.updateTokenTab()
          self.modal.$("#TokenCreate").removeAttr "disabled"
        , ()->
          notification "error", lang.NOTIFY.FAIL_TO_CREATE_TOKEN
          self.modal.$("#TokenCreate").removeAttr "disabled"
        return

      doneEditToken : ( evt )->
        $p = $(evt.currentTarget).closest("li").removeClass("editing")
        $p.children(".tokenName").attr "readonly", true

        token        = $p.children(".tokenToken").text()
        newTokenName = $p.children(".tokenName").val()

        for t in  App.user.get("tokens")
          if t.token is token
            oldName = t.name
          else if t.name is newTokenName
            duplicate = true

        if not newTokenName or duplicate
          $p.children(".tokenName").val( oldName )
          return

        App.user.updateToken( token, newTokenName ).fail ()->
          # If anything goes wrong, revert the name
          oldName = ""
          $p.children(".tokenName").val( oldName )
          notification "error", lang.NOTIFY.FAIL_TO_UPDATE_TOKEN
        return

      confirmRmToken : ()->
        @modal.$("#TokenRemove").attr "disabled", "disabled"

        self = this
        App.user.removeToken( @rmToken ).then ()->
          self.updateTokenTab()
          self.cancelRmToken()
        , ()->
          notification lang.NOTIFY.FAIL_TO_DELETE_TOKEN
          self.cancelRmToken()

        return

      cancelRmToken : ()->
        @rmToken = ""
        @modal.$("#TokenRemove").removeAttr "disabled"
        @modal.$("#TokenManager").show()
        @modal.$("#TokenRmConfirm").hide()
        return

      updateTokenTab : ()->
        tokens = App.user.get("tokens")
        @modal.$("#TokenManager").find(".token-table").toggleClass( "empty", tokens.length is 0 )
        if tokens.length
          @modal.$("#TokenList").html MC.template.accessTokenTable( tokens )
        else
          @modal.$("#TokenList").empty()
        return
    }

    SettingsDialog.TAB =
      CredentialInvalid : -1
      Normal            : 0
      Credential        : 1
      Token             : 2

    SettingsDialog
