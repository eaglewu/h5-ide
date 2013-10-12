#############################
#  View(UI logic) for reset
#############################

define [ 'event',
         'text!./module/reset/template.html', 'text!./module/reset/email.html',
         'text!./module/reset/password.html', 'text!./module/reset/loading.html',
         'text!./module/reset/expire.html',   'text!./module/reset/success.html',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, tmpl, email_tmpl, password_tmpl, loading_tmpl, expire_tmpl, success_tmpl ) ->

    ResetView = Backbone.View.extend {

        el       :  '#container'

        template      : Handlebars.compile tmpl
        email_tmpl    : Handlebars.compile email_tmpl
        password_tmpl : Handlebars.compile password_tmpl
        loading_tmpl  : Handlebars.compile loading_tmpl
        expire_tmpl   : Handlebars.compile expire_tmpl
        success_tmpl  : Handlebars.compile success_tmpl

        events   :
            'keyup #reset-pw-email' : 'changeSendButtonState'
            'click #reset-btn'      : 'resetPasswordButtonEvent'
            'click #reset-password' : 'resetPasswordEvent'
            'blur #reset-pw'        : 'verificationPassword'

        initialize : ->
            #

        render   : ( type, key ) ->
            console.log 'reset render'
            console.log type, key

            switch type
                when 'normal'
                    @$el.html @template()
                when 'email'
                    @$el.html @email_tmpl()
                when 'password'
                    @$el.html @loading_tmpl()
                when 'expire'
                    @$el.html @expire_tmpl()
                when 'success'
                    @$el.html @success_tmpl()
                else
                    @$el.html @template()

        passwordRender : ->
            console.log 'passwordRender'
            @$el.html @password_tmpl()

        changeSendButtonState : ( event ) ->
            console.log 'changeSendButtonState'
            $('#email-verification-status').hide()
            if event.target.value then $( '#reset-btn' ).removeAttr 'disabled' else  $( '#reset-btn' ).attr 'disabled', true

        resetPasswordButtonEvent : ->
            console.log 'resetPasswordButtonEvent'
            $('#email-verification-status').hide()
            $( '#reset-btn' ).attr( 'disabled', true )
            $( '#reset-btn' ).attr( 'value', 'Reset...' )
            this.trigger 'RESET_EMAIL', $( '#reset-pw-email' ).val()
            false

        resetPasswordEvent : ->
            console.log 'resetPasswordEvent'
            if @verificationPassword()
                $( '#reset-password' ).attr( 'value', 'Reset...' )
                $( '#reset-password' ).attr( 'disabled', true )
                this.trigger 'RESET_PASSWORD', $( '#reset-pw' ).val()
            false

        verificationPassword : ->
            value = $('#reset-pw').val().trim()
            status = $('#password-verification-status')
            status.removeClass 'error-status'

            #signup.verification.confirm_password()
            if value isnt ''
                if value.length > 5 # &&
                  #/[A-Z]{1}/.test(value) &&
                  #/[0-9]{1}/.test(value)
                  # status.show().text 'This password is OK.'
                  status.hide()
                  true
                else
                  status.addClass('error-status').show().text 'Password must contain at least 6 characters.'
                  false
            else
                status.addClass('error-status').show().text 'Password is required.'
                false

        showErrorMessage : ->
            console.log 'showErrorMessage'
            $( '#reset-btn' ).attr( 'disabled', false )
            $( '#reset-btn' ).attr( 'value', 'Send Reset Password Email' )
            status = $('#email-verification-status')
            status.addClass( 'error-status' ).show().text 'The username or email address is not registered with MadeiraCloud.'
            false

        #showPassowordErrorMessage : ->
        #    console.log 'showPassowordErrorMessage'
        #    $( '#reset-password' ).attr( 'disabled', false )
        #    status = $('#password-verification-status')
        #    status.addClass( 'error-status' ).show().text 'Password set error.'
        #    false

    }

    return ResetView
