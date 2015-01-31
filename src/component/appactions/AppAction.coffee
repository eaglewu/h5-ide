
###
----------------------------
  App Action Method
----------------------------
###

define [
  "backbone"
  "component/appactions/template"
  "ThumbnailUtil"
  'i18n!/nls/lang.js'
  'CloudResources'
  'constant'
  'UI.modalplus'
  'ApiRequest'
  'kp_dropdown'
  'OsKp'
  'TaGui'
  'OpsModel'
], ( Backbone, AppTpl, Thumbnail, lang, CloudResources, constant, modalPlus, ApiRequest, AwsKp, OsKp, TA, OpsModel)->
  AppAction = Backbone.View.extend

    saveStack : ( dom, self )->

      $( dom ).attr("disabled", "disabled")

      self.__saving = true

      newJson = self.workspace.design.serialize()
      Thumbnail.generate( (self.parent||self).getSvgElement() ).catch( ()->
        return null
      ).then ( thumbnail )->
        self.workspace.opsModel.save( newJson, thumbnail ).then ()->
          self.__saving = false
          $( dom ).removeAttr("disabled")
          notification "info", sprintf(lang.NOTIFY.ERR_SAVE_SUCCESS, newJson.name)
        , ( err )->
          self.__saving = false
          $( dom ).removeAttr("disabled")

          if err.error is 252
            message = lang.NOTIFY.ERR_SAVE_FAILED_NAME
          else
            message = sprintf(lang.NOTIFY.ERR_SAVE_FAILED, newJson.name)
          notification "error", message
    runStack: (event, workspace)->
      @workspace = workspace
      cloudType = @workspace.opsModel.type
      that = @
      if $(event.currentTarget).attr('disabled')
        return false
      @modal = new modalPlus
        title: lang.IDE.RUN_STACK_MODAL_TITLE
        template: MC.template.modalRunStack
        disableClose: true
        width: '450px'
        confirm:
          text: if Design.instance().credential() then lang.IDE.RUN_STACK_MODAL_CONFIRM_BTN else lang.IDE.RUN_STACK_MODAL_NEED_CREDENTIAL
          disabled: true
      if cloudType is OpsModel.Type.OpenStack
        @modal.find(".estimate").hide()
        @modal.resize()
      @renderKpDropdown(@modal, cloudType)
      cost = Design.instance().getCost()
      @modal.tpl.find('.modal-input-value').val @workspace.opsModel.get("name")
      currency = Design.instance().getCurrency()
      @modal.tpl.find("#label-total-fee").find('b').text("#{currency + cost.totalFee}")

      # load TA
      TA.loadModule('stack').then ()=>
        @modal.resize()
        @modal?.toggleConfirm false

      appNameDom = @modal.tpl.find('#app-name')
      checkAppNameRepeat = @checkAppNameRepeat.bind @
      appNameDom.keyup ->
        checkAppNameRepeat(appNameDom.val())

      self = @
      @modal.on 'confirm', ()=>
        @hideError()
        if not Design.instance().credential()
          App.showSettings App.showSettings.TAB.Credential
          return false
        # setUsage
        appNameRepeated = @checkAppNameRepeat(appNameDom.val())
        if not @defaultKpIsSet(cloudType) or appNameRepeated
          return false

        @modal.tpl.find(".btn.modal-confirm").attr("disabled", "disabled")
        @json = @workspace.design.serialize usage: 'runStack'
        @json.usage = $("#app-usage-selectbox").find(".dropdown .item.selected").data('value')
        @json.name = appNameDom.val()
        @workspace.opsModel.run(@json, appNameDom.val()).then ( ops )->
          self.modal.close()
          App.openOps( ops )
        , (err)->
          self.modal.close()
          error = if err.awsError then err.error + "." + err.awsError else " #{err.error} : #{err.result || err.msg}"
          notification 'error', sprintf(lang.NOTIFY.FAILA_TO_RUN_STACK_BECAUSE_OF_XXX,self.workspace.opsModel.get('name'),error)
      App.user.on 'change:credential', ->
        if Design.instance().credential() and that.modal.isOpen()
          that.modal.find(".modal-confirm").text lang.IDE.RUN_STACK_MODAL_CONFIRM_BTN
      @modal.on 'close', ->
        App.user.off 'change:credential'

    renderKpDropdown: (modal, cloudType)->
      if cloudType is OpsModel.Type.OpenStack
        unless OsKp::hasResourceWithDefaultKp()
          return false
        osKeypair = new OsKp()
        KeypairModel = Design.modelClassForType(constant.RESTYPE.OSKP)
        defaultKp = _.find KeypairModel.allObjects(), (obj) -> obj.get('name') is 'DefaultKP'
        if modal.isOpen() then modal.find("#kp-runtime-placeholder").html(osKeypair.render(defaultKp.get("keyName")).$el)
        modal.tpl.find('.default-kp-group').show()
        osKeypair.$input.on 'change', ()->
          osKeypair.setDefaultKeyPair()
        return false
      if AwsKp.hasResourceWithDefaultKp()
        keyPairDropdown = new AwsKp()
        if modal then modal.tpl.find("#kp-runtime-placeholder").html keyPairDropdown.render().el else return false
        hideKpError = @hideError.bind @
        keyPairDropdown.dropdown.on 'change', ->
          hideKpError('kp')
        modal.tpl.find('.default-kp-group').show()
        modal.on 'close', ->
          keyPairDropdown.remove()
      null

    hideError: (type)->
      selector = if type then $("#runtime-error-#{type}") else $(".runtime-error")
      selector.hide()

    defaultKpIsSet: (cloudType)->
      if cloudType is OpsModel.Type.OpenStack
        if OsKp::hasResourceWithDefaultKp() and OsKp::defaultKpNotSet()
          @showError('kp', lang.IDE.RUN_STACK_MODAL_KP_WARNNING)
          return false
        else
          return true
      if not AwsKp.hasResourceWithDefaultKp()
        return true
      kpModal = Design.modelClassForType( constant.RESTYPE.KP )
      defaultKP = kpModal.getDefaultKP()
      if not defaultKP.get('isSet') or not ((@modal||@updateModal) and (@modal || @updateModal).tpl.find("#kp-runtime-placeholder .item.selected").size())
        @showError('kp', lang.IDE.RUN_STACK_MODAL_KP_WARNNING)
        return false
      true

    checkAppNameRepeat: (nameVal)->
      if App.model.appList().findWhere(name: nameVal)
        @showError('appname', lang.PROP.MSG_WARN_REPEATED_APP_NAME)
        return true
      else if not nameVal
        @showError('appname', lang.PROP.MSG_WARN_NO_APP_NAME)
        return true
      else
        @hideError('appname')
        return false

    showError: (id, msg)->
        $("#runtime-error-#{id}").text(msg).show()

    deleteStack : ( id, name ) ->
      name = name || App.model.stackList().get( id ).get( "name" )

      modal = new modalPlus({
        title: lang.TOOLBAR.TIP_DELETE_STACK
        width: 390
        confirm:
          text: lang.TOOLBAR.POP_BTN_DELETE_STACK
          color: "red"
        template: AppTpl.removeStackConfirm {msg:  sprintf lang.TOOLBAR.POP_BODY_DELETE_STACK, name}
      })
      modal.on "confirm", ()->
        modal.close()
        opsModel = App.model.stackList().get( id )
        p = opsModel.remove()
        if opsModel.isPersisted()
          p.then ()->
            notification "info", sprintf(lang.NOTIFY.ERR_DEL_STACK_SUCCESS, name)
          , ()->
            notification "error", sprintf(lang.NOTIFY.ERR_DEL_STACK_FAILED, name)

    duplicateStack : (id) ->
      opsModel = App.model.stackList().get(id)
      if not opsModel then return
      opsModel.fetchJsonData().then ()->
        App.openOps( App.model.createStackByJson opsModel.getJsonData() )
      , ()->
        notification "error", lang.NOTIFY.ERROR_CANT_DUPLICATE
      return

    startApp : ( id )->
      app = App.model.appList().get(id)
      startAppModal = new modalPlus {
        template: AppTpl.loading()
        title: lang.TOOLBAR.TIP_START_APP
        confirm:
          text: lang.TOOLBAR.POP_BTN_START_APP
          color: 'blue'
          disabled: false
        disableClose: true
      }
      startAppModal.tpl.find('.modal-footer').hide()
      @checkBeforeStart(app).then (result)->
        {hasEC2Instance, hasDBInstance, hasASG, lostDBSnapshot, awsError} = result
        if awsError and awsError isnt 403
          startAppModal.close()
          notification 'error', lang.NOTIFY.ERROR_FAILED_LOAD_AWS_DATA
          return false
        startAppModal.tpl.find('.modal-footer').show()
        startAppModal.tpl.find('.modal-body').html AppTpl.startAppConfirm {hasEC2Instance, hasDBInstance, hasASG, lostDBSnapshot}
        startAppModal.on 'confirm', ->
          startAppModal.close()
          App.model.appList().get( id ).start().fail ( err )->
            error = if err.awsError then err.error + "." + err.awsError else err.error
            notification 'error', sprintf(lang.NOTIFY.ERROR_FAILED_START , name, error)
            return
          return
        return

    checkBeforeStart: (app)->
      comp = null
      cloudType = app.type
      defer = new Q.defer()
      if cloudType is OpsModel.Type.OpenStack
        console.log "CloudType is OpenStack"
        defer.resolve({})
      else
        ApiRequest("app_info", {
          region_name : app.get("region")
          app_ids     : [app.get("id")]
        }).then (ds)->  comp = ds[0].component
        .then ->
          name = App.model.appList().get( app.get("id") ).get("name")
          hasEC2Instance =!!( _.filter comp, (e)->
            e.type is constant.RESTYPE.INSTANCE).length
          hasDBInstance = !!(_.filter comp, (e)->
            e.type is constant.RESTYPE.DBINSTANCE).length
          hasASG = !!(_.filter comp, (e)->
            e.type is constant.RESTYPE.ASG).length
          dbInstance = _.filter comp, (e)->
            e.type is constant.RESTYPE.DBINSTANCE
          snapshots = CloudResources Design.instance().credentialId(), constant.RESTYPE.DBSNAP, app.get("region")
          awsError = null
          snapshots.fetchForce().fail (error)->
            awsError = error.awsError
          .finally ->
            lostDBSnapshot = _.filter dbInstance, (e)->
              e.resource.DBSnapshotIdentifier and not snapshots.findWhere({id: e.resource.DBSnapshotIdentifier})
            defer.resolve {hasEC2Instance, hasDBInstance, hasASG, lostDBSnapshot, awsError}
      defer.promise

    checkBeforeStop: (app)->
      cloudType = app.type
      if cloudType is OpsModel.Type.OpenStack
        console.log "CloudType is OpenStack"
        defer = new Q.defer()
        defer.resolve()
        return defer.promise
      else
        resourceList = CloudResources Design.instance().credentialId(), constant.RESTYPE.DBINSTANCE, app.get("region")
        resourceList.fetchForce()

    stopApp : ( id )->
      app  = App.model.appList().get( id )
      name = app.get("name")
      that = this
      cloudType = app.type
      isProduction = app.get('usage') is "production"
      appName = app.get('name')
      stopModal = new modalPlus {
        template: AppTpl.loading()
        title:  if isProduction then lang.TOOLBAR.POP_TIT_STOP_PRD_APP else lang.TOOLBAR.POP_TIT_STOP_APP
        confirm:
          text: lang.TOOLBAR.POP_BTN_STOP_APP
          color: 'red'
          disabled: isProduction
        disableClose: true
      }
      stopModal.tpl.find(".modal-footer").hide()
      awsError = null

      @checkBeforeStop(app)
      .fail (error)->
        console.log error
        if error.awsError then awsError = error.awsError
      .finally ()->
        resourceList = CloudResources Design.instance().credentialId(), constant.RESTYPE.DBINSTANCE, app.get("region")
        if awsError and awsError isnt 403
          stopModal.close()
          notification 'error', lang.NOTIFY.ERROR_FAILED_LOAD_AWS_DATA
          return false

        if cloudType is OpsModel.Type.OpenStack
          stopModal.tpl.find(".modal-footer").show()
          stopModal.tpl.find('.modal-body').css('padding', "0").html AppTpl.stopAppConfirm {isProduction, appName}
          stopModal.resize()
          $("#appNameConfirmIpt").on "keyup change", ()->
            if $("#appNameConfirmIpt").val() is name
              stopModal.tpl.find('.modal-confirm').removeAttr "disabled"
            else
              stopModal.tpl.find('.modal-confirm').attr "disabled", "disabled"
        else
          app.fetchJsonData().then ()->
            comp = app.getJsonData().component
            toFetch = {}
            for uid, com of comp
              if com.type is constant.RESTYPE.INSTANCE or com.type is constant.RESTYPE.LC
                imageId = com.resource.ImageId
                if imageId then toFetch[ imageId ] = true
            toFetchArray  = _.keys toFetch
            amiRes = CloudResources Design.instance().credentialId(), constant.RESTYPE.AMI, app.get("region")
            amiRes.fetchAmis( _.keys toFetch ).then ->
              hasInstanceStore = false
              amiRes.each (e)->
                if e.id in toFetchArray and e.get("rootDeviceType") is 'instance-store'
                  hasInstanceStore = true
                  null
              hasEC2Instance = (_.filter comp, (e)->
                e.type == constant.RESTYPE.INSTANCE)?.length

              hasDBInstance = _.filter comp, (e)->
                e.type == constant.RESTYPE.DBINSTANCE

              dbInstanceName = _.map hasDBInstance, (e)->
                return e.resource.DBInstanceIdentifier
              hasNotReadyDB = resourceList.filter (e)->
                (e.get('DBInstanceIdentifier') in dbInstanceName) and e.get('DBInstanceStatus') isnt 'available'

              hasAsg = (_.filter comp, (e)->
                e.type == constant.RESTYPE.ASG)?.length

              stopModal.tpl.find(".modal-footer").show()
              if hasNotReadyDB and hasNotReadyDB.length
                stopModal.tpl.find('.modal-body').html AppTpl.cantStop {cantStop : hasNotReadyDB}
                stopModal.tpl.find('.modal-confirm').remove()
              else
                hasDBInstance = hasDBInstance?.length
                stopModal.tpl.find('.modal-body').css('padding', "0").html AppTpl.stopAppConfirm {isProduction, appName, hasEC2Instance, hasDBInstance, hasAsg, hasInstanceStore}
              stopModal.resize()

              $("#appNameConfirmIpt").on "keyup change", ()->
                if $("#appNameConfirmIpt").val() is name
                  stopModal.tpl.find('.modal-confirm').removeAttr "disabled"
                else
                  stopModal.tpl.find('.modal-confirm').attr "disabled", "disabled"

        stopModal.on "confirm", ()->
          stopModal.close()
          app.stop().fail ( err )->
            console.log err
            error = if err.awsError then err.error + "." + err.awsError else err.error
            notification sprintf(lang.NOTIFY.ERROR_FAILED_STOP , name, error)

    terminateApp : ( id )->
      self = @
      app  = App.model.appList().get( id )
      name = app.get("name")
      production = app.get("usage") is 'production'
      terminateConfirm = new modalPlus(
        title: if production then lang.TOOLBAR.POP_TIT_TERMINATE_PRD_APP else lang.TOOLBAR.POP_TIT_TERMINATE_APP
        template: AppTpl.loading()
        confirm: {
          text: lang.TOOLBAR.POP_BTN_TERMINATE_APP
          color: "red"
          disabled: production
        }
        disableClose: true
      )
      cloudType = app.type
      if cloudType is OpsModel.Type.OpenStack
        @__terminateApp(id, null, terminateConfirm)
        return false

      terminateConfirm.tpl.find('.modal-footer').hide()
      # get Resource list
      resourceList = CloudResources Design.instance().credentialId(), constant.RESTYPE.DBINSTANCE, app.get("region")
      resourceList.fetchForce().then (result)->
        self.__terminateApp(id, resourceList, terminateConfirm)
      .fail (error)->
        if error.awsError is 403 then self.__terminateApp(id, resourceList, terminateConfirm)
        else
          terminateConfirm.close()
          notification 'error', lang.NOTIFY.ERROR_FAILED_LOAD_AWS_DATA
          return false

    __terminateApp: (id, resourceList, terminateConfirm)->
      app  = App.model.appList().get( id )
      name = app.get("name")
      production = app.get("usage") is 'production'
      cloudType = app.type
      # renderLoading

      fetchJsonData = ->
        if cloudType is OpsModel.Type.OpenStack
          defer = new Q.defer()
          defer.resolve()
          defer.promise
        else
          app.fetchJsonData()

      fetchJsonData().then ->
        if cloudType is OpsModel.Type.OpenStack
          hasDBInstance = null
          notReadyDB = []
        else
          comp = app.getJsonData().component
          hasDBInstance = _.filter comp, (e)->
            e.type == constant.RESTYPE.DBINSTANCE
          dbInstanceName = _.map hasDBInstance, (e)->
            return e.resource.DBInstanceIdentifier
          notReadyDB = resourceList.filter (e)->
            (e.get('DBInstanceIdentifier') in dbInstanceName) and e.get('DBInstanceStatus') isnt 'available'

        # Render Terminate Confirm
        terminateConfirm.tpl.find('.modal-body').html AppTpl.terminateAppConfirm {production, name, hasDBInstance, notReadyDB}
        terminateConfirm.tpl.find('.modal-footer').show()
        terminateConfirm.resize()

        if notReadyDB?.length
          terminateConfirm.tpl.find("#take-rds-snapshot").attr("checked", false).change  ->
            terminateConfirm.tpl.find(".modal-confirm").attr 'disabled', $(this).is(":checked")

        $("#appNameConfirmIpt").on "keyup change", ()->
          if $("#appNameConfirmIpt").val() is name
            terminateConfirm.tpl.find('.modal-confirm').removeAttr "disabled"
          else
            terminateConfirm.tpl.find('.modal-confirm').attr "disabled", "disabled"
          return

        terminateConfirm.on "confirm", ()->
          terminateConfirm.close()
          takeSnapshot = terminateConfirm.tpl.find("#take-rds-snapshot").is(':checked')
          app.terminate(null, {create_snapshot:takeSnapshot}).fail ( err )->
            error = if err.awsError then err.error + "." + err.awsError else err.error
            notification sprintf(lang.NOTIFY.ERROR_FAILED_TERMINATE , name, error)
          return
        return

    forgetApp : ( id )->
      self = @
      app  = App.model.appList().get( id )
      name = app.get("name")
      production = app.get("usage") is 'production'
      forgetConfirm = new modalPlus(
        title: lang.IDE.TITLE_CONFIRM_TO_FORGET
        template: AppTpl.loading()
        confirm: {
          text: lang.TOOLBAR.BTN_FORGET_CONFIRM
          color: "red"
          disabled: production
        }
        disableClose: true
      )
      forgetConfirm.tpl.find('.modal-footer').hide()
      self.__forgetApp(id, forgetConfirm)

    __forgetApp: (id, forgetConfirm)->
      app  = App.model.appList().get( id )
      name = app.get("name")
      production = app.get("usage") is 'production'

      # Disable forget app with state
      hasState = false
      if Design.instance().get("agent").enabled
        for uid,comp of Design.instance().serialize().component
          if comp.type in [ constant.RESTYPE.INSTANCE, constant.RESTYPE.LC ] and comp.state and comp.state.length>0
            hasState = true
            break
          null

      app.fetchJsonData().then ->
        # Render Forget Confirm
        forgetConfirm.tpl.find('.modal-body').html AppTpl.forgetAppConfirm {production, name, hasState}
        forgetConfirm.tpl.find('.modal-footer').show()
        forgetConfirm.resize()

        if hasState
          forgetConfirm.tpl.find('.modal-confirm').attr "disabled", "disabled"

        $("#appNameConfirmIpt").on "keyup change", ()->
          if $("#appNameConfirmIpt").val() is name
            forgetConfirm.tpl.find('.modal-confirm').removeAttr "disabled"
          else
            forgetConfirm.tpl.find('.modal-confirm').attr "disabled", "disabled"
          return

        forgetConfirm.on "confirm", ()->
          forgetConfirm.close()
          app.terminate(true, false).fail ( err )->
            error = if err.awsError then err.error + "." + err.awsError else err.error
            notification "Fail to forget your app \"#{name}\". (ErrorCode: #{error})"
          return
        return


    showPayment: (elem)->
      showPaymentDefer = Q.defer()

      # check should Show.
      paymentState = App.user.get("paymentState")

      if not App.user.shouldPay()
        showPaymentDefer.resolve({})
      else
        result = {
          first_name: App.user.get("firstName")
          last_name: App.user.get("lastName")
          url: App.user.get("paymentUrl")
          card: App.user.get("creditCard")
        }
        updateDom = MC.template.paymentUpdate  result
        if elem
          $(elem).html updateDom
          $(elem).trigger 'paymentRendered'
        else
          paymentModal = new modalPlus(
            title: lang.IDE.PAYMENT_INVALID_BILLING
            template: updateDom
            disableClose: true
            confirm:
              text: if Design.instance().credential() then lang.IDE.RUN_STACK_MODAL_CONFIRM_BTN else lang.IDE.RUN_STACK_MODAL_NEED_CREDENTIAL
              disabled: true
          )
          paymentModal.find('.modal-footer').hide()

          paymentModal.listenTo App.user, "paymentUpdate", ()->
            if paymentModal.isClosed then return false
            if not App.user.shouldPay()
              showPaymentDefer.resolve({result: result, modal: paymentModal})
      showPaymentDefer.promise


  new AppAction()
