
(()->
    location = window.location

    if /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.exec( location.hostname )
        # This is a ip address
        console.error "VisualOps IDE can not be browsed with IP address."
        return

    hosts = location.hostname.split(".")
    if hosts.length >= 3
        MC_DOMAIN = hosts[ hosts.length - 2 ] + "." + hosts[ hosts.length - 1]
    else
        MC_DOMAIN = location.hostname

    window.API_HOST  = "api." + MC_DOMAIN
    window.API_PROTO = location.protocol + "//"
    window.language  = window.version = ""

    # Redirect
    if location.hostname.toLowerCase().indexOf( "visualops.io" ) >= 0 and location.protocol is "http:"
        window.location = location.href.replace("http:","https:")
        return
)()


goto500 = ()->
    hash = window.location.pathname
    if hash.length == 1
        hash = ""
    else
        hash = hash.replace("/", "#")
    window.location = '/500/' + hash
    return

# variable to record $.ajax
xhr = null

checkAllCookie = -> !!($.cookie('usercode') and $.cookie('session_id'))

# language detect
langType = ->
    document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + "lang\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1") || (if navigator.language and navigator.language.toLowerCase() is "zh-cn" then "zh-cn" else "en-us")
deepth = 'RESET'

timezone = (new Date().getTimezoneOffset())/-60
# route function
userRoute = (routes)->
    hashArray = window.location.hash.split('#').pop().split('/')
    pathArray = window.location.pathname.split('/')
    pathArray.shift()
    #console.log pathArray , hashArray
    # run routes func
    routes[pathArray[0]]?(pathArray, hashArray)
    return
# guid
guid = ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c)->
        r = Math.random() * 16 | 0
        v = if c == 'x' then r else (r&0x3|0x8)
        v.toString(16)
    ).toUpperCase()
# api
api = (option)->
    xhr = $.ajax
        url: API_PROTO + API_HOST + option.url
        dataType: 'json'
        type: 'POST'
        jsonp: false
        data: JSON.stringify(
            jsonrpc: '2.0',
            id: guid(),
            method: option.method || '',
            params: option.data || {}
        )
        success: (res)->
            option.success?(res.result[1], res.result[0])
        error: (xhr,status,error)->
            #console.log error
            if status!='abort'
                option.error?(status, -1)
    xhr

# register i18n handlebars helper
Handlebars.registerHelper 'i18n', (str)->
    i18n?(str) || str

loadPageVar = (sVar) ->
    decodeURI(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURI(sVar).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1")) + location.hash

getRef = ()->
    ref = loadPageVar('ref')
    if ref.charAt(0) is "/"
        ref
    else
        "/"

gotoRef = ->
    ref = location.pathname + location.hash
    location.href = "/login?ref=#{ref}"

getSearch = -> (window.location.search || "")
# init the page . load i18n source file
loadLang = (cb)->
    $.ajax({
        url: '/nls/' + langType() + '/lang.js'
        jsonp: false
        dataType: "jsonp"
        jsonpCallback: "define"
        beforeSend: ->
            template = Handlebars.compile $("#loading-template").html()
            $("#main-body").html template()
        success: (data)->
            window.langsrc = data
            return
            #console.log 'Success', data
        error: (error)->
            goto500()
            console.log error, "error"
    }).done ->
        templates = $("[type='text/x-language-template']")
        if templates.size() then templates.each (index, element)->
            element = $(element)
            template = Handlebars.compile element.html()
            $("#"+element.data('target')).html template(window.langsrc)
        cb()

window.onhashchange = ->
    init()

# temp i18n function
i18n = (str) ->
    langsrc[deepth][str]

# render template
render = (tempName, data)->
    template = Handlebars.compile $(tempName).html()
    $("#main-body").html template(data)

# init function
init = ->
    ua = navigator.userAgent.toLowerCase()
    browser = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
            /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
            /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
            /(msie) ([\w.]+)/.exec( ua ) ||
            ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) || []

    support =
        chrome  : 10
        webkit  : 6
        msie    : 10
        mozilla : 4
        opera   : 10

    if browser[1] is "webkit"
        safari = /version\/([\d\.]+).*safari/.exec( ua )
        if safari then browser[2] = safari[1]

    if (parseInt(browser[2], 10) || 0) < support[browser[1]]
      $("header").after "<div id='unsupported-browser'><p>#{langsrc.LOGIN.browser_not_support_1}</p> <p>#{langsrc.LOGIN.browser_not_support_2}<a href='https://www.google.com/intl/en/chrome/browser/' target='_blank'>Chrome</a>, <a href='http://www.mozilla.org/en-US/firefox/all/' target='_blank'>Firefox</a> or <a href='http://windows.microsoft.com/en-us/internet-explorer/download-ie' target='_blank'>IE</a>#{langsrc.LOGIN.browser_not_support_3}</p></div>"

    userRoute(
        "invite": ( pathArray, hashArray ) ->
            if !checkAllCookie()
                gotoRef()
                return

            deepth = 'INVITE'
            hashTarget = hashArray[0]
            unless hashTarget is 'member' then return

            checkInviteKey( hashArray[ 1 ] ).then ( result ) ->
                retCode = result.result[0]
                if retCode is 0
                    projectId = atob( hashArray[ 1 ] ).split( '&' )[ 0 ]
                    location.href = "/workspace/#{projectId}"
                else if retCode is 120 # is for other user
                    render '#expire-template', {other_user: true}
                else # expired link (110)
                    render '#expire-template'
            , () ->
                render '#expire-template'

        "reset": (pathArray, hashArray)->
            deepth = 'RESET'
            hashTarget = hashArray[0]
            if hashTarget == 'password'
                # check if reset link is valid
                checkPassKey hashArray[1],(statusCode,result)->
                    if !statusCode
                        console.log 'Right Verify Code!'
                        render "#password-template"
                        $('form.box-body').find('input').eq(0).focus()
                        $('#reset-form').on 'submit' , (e)->
                            e.preventDefault()
                            if validPassword()
                                $("#reset-password").attr('disabled',true).val langsrc.RESET.reset_waiting
                                #window.location.hash = "#success"
                                ajaxChangePassword(hashArray, $("#reset-pw").val())
                                #console.log('jump...')
                            return false
                    else
                        #console.log 'ERROR_CODE_MESSAGE',langsrc.service["ERROR_CODE_#{statusCode}_MESSAGE"]
                        tempLang = tempLang||langsrc.RESET['expired-info']
                        langsrc.RESET['expired-info'] = langsrc.SERVICE['RESET_PASSWORD_ERROR_'+statusCode] || tempLang
                        window.location.hash = "expire"
                        return
                        #console.log "Error Verify Code!"
            else if hashTarget == "expire"
                render '#expire-template'
                $(".account-instruction a").attr("href", "/login"+getSearch())
            else if hashTarget == "email"
                render "#email-template"
                $('form.box-body').find('input').eq(0).focus()
            else if hashTarget == "success"
                render "#success-template"
                $(".account-instruction a").attr("href", "/login"+getSearch())
            else
                render '#default-template'
                $(".title-link").find("a").eq(0).attr("href", "/register/"+ getSearch())
                $(".title-link").find("a").eq(1).attr("href", "/login/"+ getSearch())
                $("#reset-pw-email").focus()
                $('#reset-pw-email').keyup ->
                    if @value
                        $('#reset-btn').removeAttr('disabled')
                    else
                        $("#reset-btn").attr('disabled',true)
                $('#reset-form').on 'submit', ->
                    #console.log 'sendding....'
                    $('#reset-pw-email').off 'keyup'
                    $("#reset-btn").attr('disabled',true)
                    $("#reset-pw-email").attr('disabled',true)
                    $('#reset-btn').val window.langsrc.RESET.reset_waiting
                    sendEmail($("#reset-pw-email").val())
                    false
        'login': (pathArray, hashArray)->
            if checkAllCookie() then window.location = getRef()
            deepth = 'LOGIN'
            render "#login-template"
            $(".account-btn-wrap a").attr("href", "/reset/"+getSearch()) # pass ref url
            $("#login-register").find("a").attr("href", "/register/"+getSearch())
            $user = $("#login-user")
            $password = $("#login-password")
            submitBtn = $("#login-btn").attr('disabled',false)
            $("#login-form input").eq(0).focus()
            checkValid = ->
                if $(@).val().trim() then $(@).parent().removeClass('error')
            $user.on 'keyup', checkValid
            $password.on 'keyup', checkValid
            $("#login-form").on 'submit', (e)->
                e.preventDefault()
                if $user.val()&&$password.val()
                    $(".error-msg").hide()
                    $(".control-group").removeClass('error')
                    submitBtn.attr('disabled',true).val langsrc.RESET.reset_waiting
                    ajaxLogin [$user.val(),$password.val(), {timezone: timezone}] , (statusCode)->
                        if statusCode is 100
                          $('#error-msg-1').hide()
                          $('#error-msg-3').show().text langsrc.SERVICE.ERROR_CODE_100_MESSAGE
                        else
                          $('#error-msg-1').show()
                          $('#error-msg-3').hide()
                        submitBtn.attr('disabled',false).val langsrc.LOGIN['login-btn']
                else
                    $("#error-msg-2").show()
                    if !$user.val().trim() then $user.parent().addClass('error') else $user.parent().removeClass('error')
                    if !$password.val().trim() then $password.parent().addClass('error') else $password.parent().removeClass('error')
                    return false

        'register': (pathArray, hashArray)->
            deepth = 'REGISTER'

            if hashArray[0] == 'success'
                render "#success-template"
                $('#register-get-start').click ->
                    window.location = getRef()
                    return
                    #console.log('Getting start...')
                return false
            if checkAllCookie() then window.location = getRef()
            render '#register-template'
            $(".title-link a").attr("href", "/login/"+ getSearch())
            $form = $("#register-form")
            $form.find('input').eq(0).focus()
            $firstName = $("#register-firstname")
            $lastName  = $("#register-lastname")
            $username = $('#register-username')
            $email = $('#register-email')
            $password = $('#register-password')
            usernameTimeout = undefined
            emailTimeout = undefined
            $('#register-btn').attr('disabled',false)


            checkFullname = (e, cb)->
                status = $("#fullname-verification-status")
                firstName = $firstName.val()
                lastName = $lastName.val()
                if firstName.trim() is "" or lastName.trim() is ""
                    status.removeClass("verification-status").addClass('error-status').text langsrc.REGISTER.firstname_and_lastname_required
                    return false
                else
                  status.removeClass('verification-status').removeClass('error-status').text ""
                  return true

            # username validation
            checkUsername = (e,cb)->
                username = $username.val()
                status = $('#username-verification-status')
                if username.trim() isnt ""
                    if /[^A-Za-z0-9\_]{1}/.test(username) isnt true
                        if username.length > 40
                            status.removeClass('verification-status').addClass('error-status').text langsrc.REGISTER.username_maxlength
                            if cb then cb(0) else return false
                        else
                            if status.hasClass('error-status') then status.removeClass('verification-status').removeClass('error-status').text ""
                            if cb
                                ajaxCheckUsername username, status, cb
                            else
                                return true
                    else
                        status.removeClass('verification-status').addClass('error-status').text langsrc.REGISTER.username_not_matched
                        if cb then cb(0) else return false
                else
                    status.removeClass('verification-status').addClass('error-status').text langsrc.REGISTER.username_required
                    if cb then cb(0) else return false

            # user Email validation
            checkEmail = (e,cb,weak)->
                email = $email.val()
                status = $("#email-verification-status")
                reg_str = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
                if email.trim() isnt ""
                    if reg_str.test(email)
                        if status.hasClass('error-status') then status.removeClass('verification-status').removeClass('error-status').text ""
                        if cb
                            ajaxCheckEmail email, status, cb
                        else
                            return true
                    else
                        status.removeClass('verification-status').addClass('error-status').text langsrc.REGISTER.email_not_valid
                        if cb then cb(0) else return false
                else
                    status.removeClass('verification-status').addClass('error-status').text langsrc.REGISTER.email_required
                    if cb then cb(0) else return false

            # password validation
            checkPassword = (e,cb)->
                password = $password.val()
                status = $("#password-verification-status")
                if password isnt ""
                    if password.length > 5
                        status.removeClass('verification-status').removeClass('error-status').text ""
                        if cb then cb(1) else return true
                    else
                        status.removeClass('verification-status').addClass('error-status').text langsrc.REGISTER.password_shorter
                        if cb then cb(0) else return false
                else
                    status.removeClass('verification-status').addClass('error-status').text langsrc.REGISTER.password_required
                    if cb then cb() else return false
            ajaxCheckUsername = (username, status,cb)->
                xhr?.abort()
                window.clearTimeout(usernameTimeout)
                #console.log('aborted!', usernameTimeout)
                usernameTimeout = window.setTimeout ->
                    checkUserExist([username, null] , (statusCode)->
                        if !statusCode
                            if not checkUsername()
                                return false
                            status.removeClass('error-status').addClass('verification-status').show().text langsrc.REGISTER.username_available
                            cb?(1)
                        else if(statusCode == 'error')
                            #console.log 'NetWork Error while checking username'
                            $('.error-msg').eq(0).text(langsrc.SERVICE.NETWORK_ERROR).show()
                            $('#register-btn').attr('disabled',false).val(langsrc.REGISTER["register-btn"])
                        else if checkUsername()
                            status.removeClass('verification-status').addClass('error-status').text langsrc.REGISTER.username_taken
                            cb?(0)
                        else
                            cb?(0)
                    )
                ,500
                return
                #console.log 'Setup a new validation request'
            ajaxCheckEmail = (email, status, cb)->
                xhr?.abort()
                window.clearTimeout(emailTimeout)
                emailTimeout = window.setTimeout ->
                    checkUserExist([null, email], (statusCode)->
                        if !statusCode
                            if not checkEmail()
                                return false
                            status.removeClass('error-status').addClass('verification-status').show().text langsrc.REGISTER.email_available
                            cb?(1)
                        else if(statusCode == 'error')
                            #console.log 'NetWork Error while checking username'
                            $('.error-msg').eq(0).text(langsrc.SERVICE.NETWORK_ERROR).show()
                            $('#register-btn').attr('disabled',false).val(langsrc.REGISTER["register-btn"])
                        else
                            status.removeClass('verification-status').addClass('error-status').text langsrc.REGISTER.email_used
                            cb?(0)
                    )
                ,500
                return
                #console.log 'Set up a new validation request'
            resetRegForm = (force)->
                if force
                    $(".verification-status").removeAttr('style')
                    $('.error-status').removeClass('error-status')
                $('#register-btn').attr('disabled',false).val(langsrc.REGISTER['register-btn'])
            $username.on 'keyup blur change', (e)->
                checkUsername e, (a)->
                    resetRegForm() unless a
                    return a
            $firstName.on 'keyup blur change', ->
                checkFullname()
            $lastName.on 'keyup blur change', ->
                checkFullname()
            $email.on 'keyup blur change', (e)->
                checkEmail e, (a)->
                    resetRegForm() unless a
                    return a
            $password.on 'keyup blur change', (e)->
                checkPassword e, (a)->
                    resetRegForm() unless a
                    return a
            $form.on 'submit', (e)->
                e.preventDefault()
                $('.error-msg').removeAttr('style')
                if $username.next().hasClass('error-status') or $email.next().hasClass('error-status')
                    #console.log "Error Message Exist"
                    return false
                fullnameResult = checkFullname()
                userResult = checkUsername()
                emailResult = checkEmail()
                passwordResult = checkPassword()
                if !(userResult && emailResult && passwordResult && fullnameResult)
                    return false
                $('#register-btn').attr('disabled',true).val(langsrc.REGISTER.reginster_waiting)
                #console.log('check user input here.')
                checkUsername(e , (usernameAvl)->
                    if !usernameAvl
                        resetRegForm()
                        return false
                    checkEmail(e, (emailAvl)->
                        if !emailAvl
                            resetRegForm()
                            return false
                        checkPassword(e, (passwordAvl)->
                            if !passwordAvl
                                resetRegForm()
                                return false
                            if (usernameAvl&&emailAvl&&passwordAvl)
                                #console.log('Success!!!!!')
                                ajaxRegister([$username.val(), $password.val(), $email.val(), {first_name: $firstName.val(), last_name: $lastName.val(), timezone: timezone}],(statusCode)-> # params needs to be confirmed.
                                    resetRegForm(true)
                                    $("#register-status").show().text langsrc.SERVICE['ERROR_CODE_'+statusCode+'_MESSAGE']
                                    return false
                                )
                        )
                    )
                )

    )

# handle reset password input
validPassword = ->
    status = $("#password-verification-status")
    value =  $("#reset-pw").val()
    status.removeClass 'error-status'
    if value isnt ""
        if value.length > 5
            status.hide()
            true
        else
            status.addClass("error-status").show().text langsrc.RESET.reset_password_shorter
            false
    else
        status.addClass("error-status").show().text langsrc.RESET.reset_password_required
        false

# error Message
showErrorMessage = ->
    #console.log 'showErrorMessage'
    $('#reset-pw-email').attr('disabled',false)
    $("#reset-btn").attr('disabled',false).val(window.langsrc.RESET.reset_btn)
    $("#reset-status").removeClass('verification-status').addClass("error-msg").show().text(langsrc.RESET.reset_error_state)
    false

#handleErrorCode
handleErrorCode = (statusCode)->
    console.error 'ERROR_CODE_MESSAGE',langsrc.SERVICE["ERROR_CODE_#{statusCode}_MESSAGE"]
# handleNetError
handleNetError = (status)->
    goto500()
    console.error status, "Net Work Error, Redirecting..."

# verify  key with callback
checkPassKey = (keyToValid,fn)->
    api(
        url: '/account/'
        method: 'check_validation'
        data: [keyToValid,'reset']
        success: (result, statusCode)->
            console.log(statusCode, result)
            fn(statusCode)
        error: (status)->
            handleNetError(status)
            false
    )

checkInviteKey = ( key ) ->
    api {
        url: '/project/'
        method: 'check_invitation'
        data: [ $.cookie('session_id'), key ]
    }

setCredit = (result)->
    # Clear any cookie that's not ours
    domain = { "domain" : window.location.hostname.replace("ide", "") }
    for ckey, cValue of $.cookie()
        if ckey isnt 'stack_store_id_local' and ckey isnt 'stack_store_id'
            $.removeCookie ckey, domain

    COOKIE_OPTION =
        expires : 30
        path    : '/'

    $.cookie "usercode",   result.username,   COOKIE_OPTION
    $.cookie "session_id", result.session_id, COOKIE_OPTION

    # Set a cookie for WWW
    $.cookie "has_session", !!result.session_id, {
        domain  : window.location.hostname.replace("ide", "")
        path    : "/"
        expires : 30
    }

# ajax register
ajaxRegister = (params, errorCB)->
    #console.log params
    api(
        url: '/account/'
        method: 'register'
        data: params
        success: (result, statusCode)->
            if !statusCode
                setCredit(result)
                window.location.hash = "success"
                return
                #console.log('registered successfully')
            else
                errorCB(statusCode)
        error: (status)->
            handleNetError(status)
    )

# send Email with callback
ajaxLogin = (params, errorCB)->
    api(
        url: '/session/'
        method: 'login'
        data: params
        success: (result, statusCode)->
            if(!statusCode)
                setCredit(result)
                window.location = getRef()
                return
                #console.log 'Login Now!'
            else
                errorCB(statusCode)
        error: (status)->
            handleNetError(status)
    )
sendEmail = (params)->
    checkUserExist [params,null], (statusCode)->
        if !statusCode
            showErrorMessage()
            return false
        api(
            url: '/account/'
            method: 'reset_password'
            data: [params]
            success: (result, statusCode)->
                if(!statusCode)
                    #console.log(result, statusCode)
                    window.location.hash = 'email'
                    true

                else
                    handleErrorCode(statusCode)
                    showErrorMessage()
                    false
            error: (status)->
                handleNetError(status)
        )

# check user exits
checkUserExist = (params,fn)->
    api({
        url: '/account/'
        method: 'check_repeat'
        data: params
        success: (result,statusCode)->
            #console.log result , statusCode
            fn(statusCode)
        error: (status)->
            #console.log 'Net Work Error'
            fn('error')
    })

# ajax to reset password
ajaxChangePassword = (hashArray,newPw)->
    api
        url: "/account/"
        method: "update_password"
        data: [hashArray[1],newPw]
        success: (result, statusCode)->
            #console.log result , statusCode
            if(!statusCode)
                window.location.hash = 'success'
                return
                #console.log 'Password Updated Successfully'
            else
                handleErrorCode(statusCode)
        error: (status)->
            handleNetError(status)
    #console.log 'Updating Password...'

loadLang(init)
