
###
----------------------------
  The View for application
----------------------------
###

define [
  "backbone"
  "./subviews/SessionDialog"
  "./subviews/HeaderView"
  "./subviews/WelcomeDialog"
  "./subviews/SettingsDialog"
  "./subviews/Navigation"
  "./subviews/AppTpl"
  "./subviews/FullnameSetup"
  'i18n!/nls/lang.js'
  'CloudResources'
  'constant'
  'UI.modalplus'
], ( Backbone, SessionDialog, HeaderView, WelcomeDialog, SettingsDialog, Navigation, AppTpl, FullnameSetup, lang, CloudResources, constant, modalPlus )->

  Backbone.View.extend {

    el : $("body")[0]

    events :
      "click .click-select" : "selectText"

    initialize : ()->
      @header = new HeaderView()

      new Navigation()

      @listenTo App.user, "change:state", @toggleWelcome

      @listenTo App.model.appList(), "change:terminateFail", @askForForceTerminate

      ### env:dev ###
      require ["./ide/subviews/DebugTool"], (DT)-> new DT()
      ### env:dev:end ###
      ### env:debug ###
      require ["./ide/subviews/DebugTool"], (DT)-> new DT()
      ### env:debug:end ###

      $(window).on "beforeunload", @checkUnload
      $(window).on 'keydown', @globalKeyEvent
      return

    checkUnload : ()-> if App.canQuit() then undefined else lang.IDE.BEFOREUNLOAD_MESSAGE

    globalKeyEvent: (event) ->
      nodeName = event.target.nodeName.toLowerCase()
      if nodeName is "input" or nodeName is "textarea" or event.target.contentEditable is 'true'
        return

      switch event.which
        when 8
          event.preventDefault()
          return
        when 191
          modal MC.template.shortkey(), true
          return false

      return

    toggleWSStatus : ( isConnected )->
      if isConnected
        $(".disconnected-msg").remove()
      else
        if $(".disconnected-msg").show().length > 0
          return

        $( AppTpl.disconnectedMsg() ).appendTo("body").on "mouseover", ()->
          $(".disconnected-msg").addClass "hovered"
          $("body").on "mousemove.disconnectedmsg", ( e )->
            msg = $(".disconnected-msg")

            if not msg.length
              $("body").off "mousemove.disconnectedmsg"
              return

            pos = msg.offset()
            x = e.pageX
            y = e.pageY
            if x < pos.left || y < pos.top || x >= pos.left + msg.outerWidth() || y >= pos.top + msg.outerHeight()
              $("body").off "mousemove.disconnectedmsg"
              msg.removeClass "hovered"
            return
          return

    toggleWelcome : ()->
      if App.user.isFirstVisit()
        new WelcomeDialog()
      else if App.user.fullnameNotSet()
        new FullnameSetup()
      return

    askForAwsCredential : ()-> new WelcomeDialog({ askForCredential : true })

    showSessionDialog : ()->
      (new SessionDialog()).promise()

    # This is use to select text when clicking on the text.
    selectText : ( event )->
      try
        range = document.body.createTextRange()
        range.moveToElementText event.currentTarget
        range.select()
        console.warn "Select text by document.body.createTextRange"
      catch e
        if window.getSelection
          range = document.createRange()
          range.selectNode event.currentTarget
          window.getSelection().addRange range
          console.warn "Select text by document.createRange"
      return false


    askForForceTerminate : ( model )->
      if not model.get("terminateFail") then return

      modal AppTpl.forceTerminateApp {
        name : model.get("name")
      }

      $("#forceTerminateApp").on "click", ()->
        model.terminate( true ).fail (err)->
          error = if err.awsError then err.error + "." + err.awsError else err.error
          notification sprintf lang.NOTIFY.ERROR_FAILED_TERMINATE, name, error
        return
      return

    notifyUnpay : ()->
      notification "error", "Failed to charge your account. Please update your billing info."
      return
  }
