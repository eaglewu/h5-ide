#############################
#  View(UI logic) for dialog
#############################

define [ 'event',
         'text!./module/header/template/header.html',
         'text!./module/header/template/notifyitem.html',
         'backbone', 'jquery', 'handlebars'
], ( ide_event, tmpl, notifyitemTmpl ) ->

    notifyitemTmpl = Handlebars.compile notifyitemTmpl

    HeaderView = Backbone.View.extend {

        el       : '#header'

        template : Handlebars.compile tmpl

        events   :
            'click #btn-logout'                     : 'clickLogout'
            'click #awscredential-modal'            : 'clickOpenAWSCredential'
            'DROPDOWN_CLOSE #header--notification'  : 'dropdownClosed'
            'click .dropdown-app-name'              : 'clickAppName'
            'click #guide-tutorial'                 : 'openTutorial'

        render   : () ->
            console.log 'header render'
            @$el.html @template @model.attributes
            ide_event.trigger ide_event.HEADER_COMPLETE

        update : ()->
            $("#header").find(".no-credential").toggle( not @model.get("has_cred") )
            $("#header--user").data("tooltip", @model.get("user_email"))
            $("#header--user--name").text(@model.get("user_name"))

            @setAlertCount( @model.get("unread_num") )
            null

        updateNotification : ()->
            @setAlertCount( @model.get("unread_num") )

            html = ""
            for i in @model.attributes.info_list
                html += notifyitemTmpl i

            $("#notification-panel-wrapper").find(".scroll-content").html html

            $("#notification-panel-wrapper").css( "max-height", parseInt( $("body").height() * 0.8) )
            null

        clickLogout : () ->
            this.trigger 'BUTTON_LOGOUT_CLICK'

        dropdownClosed : () ->
            # Remove All Unread Count
            $("#notification-panel-wrapper").find(".scroll-content").children().removeClass("unread")
            @setAlertCount()

            this.trigger 'DROPDOWN_MENU_CLOSED'
            null

        clickAppName : (event) ->
            console.log 'click dropdown app name'

            this.trigger 'DROPDOWN_APP_NAME_CLICK', event.currentTarget.id

        clickOpenAWSCredential : () ->
            this.trigger 'AWSCREDENTIAL_CLICK'

        setAlertCount : ( count ) ->
            $('#header--notification').find('span').text( count || "" )
            null

        openTutorial : ->
            console.log 'openTutorial'
            require [ 'component/tutorial/main' ], ( tutorial_main ) ->
                tutorial_main.loadModule()

    }

    return HeaderView
