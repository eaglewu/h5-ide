module.exports = {

    static_lang: {
        src: [ '<%= src %>/js/login/config.js', '<%= src %>/js/ide/config.js', '<%= src %>/js/register/config.js', '<%= src %>/js/reset/config.js' ],
        actions: [
            {
                name: 'language',
                search: 'locale: language',
                replace: 'locale: "en-us"',
                flags: 'g'
            }
        ]
    },

    dynamic_lang: {
        src: [ '<%= src %>/js/login/config.js', '<%= src %>/js/ide/config.js', '<%= src %>/js/register/config.js', '<%= src %>/js/reset/config.js' ],
        actions: [
            {
                name: 'language',
                search: 'locale: "en-us"',
                replace: 'locale: language',
                flags: 'g'
            }
        ]
    },

    static_jquery: {
        src: [ '<%= src %>/js/login/config.js', '<%= src %>/js/ide/config.js', '<%= src %>/js/register/config.js', '<%= src %>/js/reset/config.js' ],
        actions: [
            {
                name: 'current jquery',
                search: 'current_jquery',
                replace: '"//code.jquery.com/jquery-2.0.3.min"',
                flags: 'g'
            }
        ]
    },

    dynamic_jquery: {
        src: [ '<%= src %>/js/login/config.js', '<%= src %>/js/ide/config.js', '<%= src %>/js/register/config.js', '<%= src %>/js/reset/config.js' ],
        actions: [
            {
                name: 'current jquery',
                search: '"//code.jquery.com/jquery-2.0.3.min"',
                replace: 'current_jquery',
                flags: 'g'
            }
        ]
    },

    s3_url: {
        src: [ '<%= release %>/module/dashboard/overview/view.js', '<%= release %>/module/dashboard/overview/template_data.html' ],
        actions: [
            {
                name: 's3 url',
                search: 'madeiracloudthumbnails-dev.s3.amazonaws.com',
                replace: 'madeiracloudthumbnails.s3.amazonaws.com',
                flags: 'g'
            }
        ]
    },

    intercome: {
        src: [ '<%= release %>/ide.html' ],
        actions: [
            {
                name: 'prod',
                search: '<!-- env:prod --#>',
                replace: '<!-- env:prod -->',
                flags: 'g'
            }
        ]
    },

    google_analytics: {
        src: [ '<%= release %>/login.html', '<%= release %>/ide.html', '<%= release %>/register.html', '<%= release %>/reset.html' ],
        actions: [
            {
                name: 'prod',
                search: '<!-- env:prod --#>',
                replace: '<!-- env:prod -->',
                flags: 'g'
            }
        ]
    },

    href_release: {
        src: [ '<%= release %>/component/awscredential/view.*', '<%= release %>/js/ide/ide.*', '<%= release %>/js/login/template.html', '<%= release %>/module/header/model.*', '<%= release %>/module/register/*.*', '<%= release %>/module/reset/*.*', '<%= release %>/lib/forge/other.js' ],
        actions: [
            {
                name: 'href-register',
                search: '"register.html',
                replace: '"/register/',
                flags: 'g'
            },
            {
                name: 'href-reset',
                search: '"reset.html',
                replace: '"/reset/',
                flags: 'g'
            },
            {
                name: 'href-login',
                search: '"login.html',
                replace: '"/login/',
                flags: 'g'
            },
            {
                name: 'href-500',
                search: '"500.html',
                replace: '"/500/',
                flags: 'g'
            }
        ]
    },

    href_debug: {
        src: [ '<%= debug %>/component/awscredential/view.*', '<%= debug %>/js/ide/ide.*', '<%= debug %>/js/login/template.html', '<%= debug %>/module/header/model.*', '<%= debug %>/module/register/*.*', '<%= debug %>/module/reset/*.*', '<%= debug %>/lib/forge/other.js' ],
        actions: [
            {
                name: 'href-register',
                search: '"register.html',
                replace: '"/register/',
                flags: 'g'
            },
            {
                name: 'href-reset',
                search: '"reset.html',
                replace: '"/reset/',
                flags: 'g'
            },
            {
                name: 'href-login',
                search: '"login.html',
                replace: '"/login/',
                flags: 'g'
            },
            {
                name: 'href-500',
                search: '"500.html',
                replace: '"/500/',
                flags: 'g'
            }
        ]
    }

};
