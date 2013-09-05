#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    current_region = null

    OverviewView = Backbone.View.extend {

        el              : $( '#tab-content-dashboard' )

        overview_result: Handlebars.compile $( '#overview-result-tmpl' ).html()
        global_list: Handlebars.compile $( '#global-list-tmpl' ).html()
        region_app_stack: Handlebars.compile $( '#region-app-stack-tmpl' ).html()
        region_resource: Handlebars.compile $( '#region-resource-tmpl' ).html()
        recent: Handlebars.compile $( '#recent-tmpl' ).html()
        recent_launched_app : Handlebars.compile $( '#recent-launched-app-tmpl' ).html()
        recent_stopped_app : Handlebars.compile $( '#recent-stopped-app-tmpl' ).html()
        loading: $( '#loading-tmpl' ).html()

        events   :
            'click #global-region-spot > li'            : 'mapRegionClick'
            'click #global-region-create-stack-list li' : 'createStackClick'
            'click .global-region-status-content li a'  : 'openItem'
            'click .global-region-status-tab-item'      : 'switchRecent'
            'click #region-switch-list li'              : 'switchRegion'
            'click #region-resource-tab a'              : 'switchAppStack'
            'click #region-aws-resource-tab a'          : 'switchRegionResource'
            'click #global-refresh'                     : 'refreshAll'

            'click .region-resource-thumbnail'          : 'clickRegionResourceThumbnail'
            'modal-shown .start-app'                    : 'startAppClick'
            'modal-shown .stop-app'                     : 'stopAppClick'
            'modal-shown .terminate-app'                : 'terminateAppClick'
            'modal-shown .duplicate-stack'              : 'duplicateStackClick'
            'modal-shown .delete-stack'                 : 'deleteStackClick'



        refreshAll: ->
            location.reload()

        showLoading: ( selector ) ->
            @$el.find( selector ).html @loading

        switchRegion: ( event ) ->
            target = $ event.currentTarget
            region = target.data 'region'
            current_region = region
            regionName = target.find('a').text()

            if regionName is @$el.find( '#region-switch span' ).text()
                return

            @$el.find( '#region-switch span' )
                .text(regionName)
                .data 'region', region

            if region is 'global'
                @$el.find( '#global-view' ).show()
                @$el.find( '#region-view' ).hide()
            else
                @showLoading('#region-app-stack-wrap, #region-resource-wrap')
                @$el.find( '#global-view' ).hide()
                @$el.find( '#region-view' ).show()

                @trigger 'SWITCH_REGION', region
                @renderRegionAppStack()


        switchRecent: ( event ) ->
            target = $ event.currentTarget
            id = target.attr 'id'

            tabContentMap =
                'global-region-status-tab-app': 'global-region-status-app-content'
                'global-region-status-tab-stack': 'global-region-status-stack-content'

            if not target.hasClass 'on'
                _.each tabContentMap, ( cid, tid ) =>
                    if tid is id
                        @$el.find( "##{cid}" ).show()
                        target.addClass 'on'
                    else
                        @$el.find( "##{cid}" )
                            .hide()
                            .end()
                            .find( "##{tid}" )
                            .removeClass 'on'

        switchAppStack: ( event ) ->
            @switchTab event, '#region-resource-tab a', '.region-resource-list'

        switchRegionResource: ( event ) ->
            @switchTab event, '#region-aws-resource-tab a', '#region-aws-resource-data div.table-head-fix'


        # switch tab helper
        switchTab: ( event, tabSelector, listSelector ) ->
            tabSelector =  if tabSelector instanceof $ then tabSelector else $( tabSelector )
            listSelector =  if listSelector instanceof $ then listSelector else $( listSelector )

            target = $ event.currentTarget
            currentIndex = @$el.find(tabSelector).index target

            if not target.hasClass 'on'
                tabSelector.each ( index ) ->
                    if index is currentIndex
                        $( @ ).addClass( 'on' )
                    else
                        $( @ ).removeClass( 'on' )

                listSelector.each ( index ) ->
                    if index is currentIndex
                        $( @ ).show()
                    else
                        $( @ ).hide()
            null

        renderGlobalList: ( event ) ->
            tmpl = @global_list @model.toJSON()
            $( this.el ).find('#global-view').html tmpl

        renderRegionAppStack: ( tab ) ->
            @regionAppStackRendered = true
            tab = 'stack' if not tab
            context = _.extend {}, @model.toJSON()
            context[ tab ] = true
            tmpl = @region_app_stack context
            $( this.el )
                .find('#region-view')
                .html( tmpl )
                .find('.region-resource-thumbnail img')
                .error @_thumbError

        _thumbError: ( event ) ->
            target = $ event.currentTarget
            target.hide()

        renderRegionResource: ( event ) ->
            tmpl = @region_resource @model.toJSON()
            $( this.el ).find('#region-resource-wrap').html tmpl

        reRenderRegionPartial: ( type, data ) ->
            tmplAll = $( '#region-resource-tmpl' ).html()
            beginRegex = new RegExp "\\{\\{\\s*#each\\s+#{type}\\s*\\}\\}", 'i'
            endRegex = new RegExp "\\{\\{\\s*/each\\s*\\}\\}", 'i'

            startPos = @_regexIndexOf tmplAll, beginRegex
            endPos = tmplAll.indexOf '</tbody>', startPos

            tmpl = tmplAll.slice startPos, endPos
            template = Handlebars.compile tmpl

            $( this.el ).find("##{type} tbody").html template data

            null


        renderRecent: ->
            $( this.el ).find( '#global-region-status-widget' ).html this.recent this.model.attributes
            null

        updateLoadTime: ( time ) ->
            @$el.find('#global-refresh span').text time

        _regexIndexOf: (str, regex, startpos) ->
            indexOf = str.substring(startpos || 0).search(regex)
            if indexOf >= 0 then (indexOf + (startpos || 0)) else indexOf

        ############################################################################################

        renderMapResult : ->
            console.log 'dashboard overview-result render'

            cur_tmpl = (this.overview_result this.model.attributes)

            $( this.el ).find('#global-region-spot').html cur_tmpl

            null

        renderRecentLaunchedApp : ->
            console.log 'dashboard recent launched app render'
            $( this.el ).find( '#recent-launched-app' ).html this.recent_launched_app this.model.attributes
            null

        renderRecentStoppedApp : ->
            console.log 'dashboard recent stopped app render'
            $( this.el ).find( '#recent-stopped-app' ).html this.recent_stopped_app this.model.attributes
            null

        mapRegionClick : ( event ) ->
            region = event.currentTarget.id
            current_region = region

            $( "#region-switch-list li[data-region=#{region}]" ).click()
            scrollbar.scrollTo($('#global-region-wrap'), {'top': $('#global-region-tabbar-wrap')[0].offsetTop + 200})

            false

        createStackClick : ( event ) ->
            console.log 'dashboard region create stack'
            ide_event.trigger ide_event.ADD_STACK_TAB, ($(event.currentTarget).data 'region')

        render : ( template ) ->
            console.log 'dashboard overview render'
            $( this.el ).html template

        openItem : (event) ->
            console.log 'click item'

            me = this
            id = event.currentTarget.id

            if id.indexOf('app-') == 0
                ide_event.trigger ide_event.OPEN_APP_TAB, $("#"+id).data('option').name, $("#"+id).data('option').region, id
            else if id.indexOf('stack-') == 0
                ide_event.trigger ide_event.OPEN_STACK_TAB, $("#"+id).data('option').name, $("#"+id).data('option').region, id

            null

        clickRegionResourceThumbnail : (event) ->
            console.log 'click app/stack thumbnail'

            item_info   = $(event.currentTarget).next('.region-resource-info')[0]
            id          = $(item_info).find('.modal')[0].id
            name        = $($(item_info).find('.region-resource-item-name')[0]).text()

            ##check params:region, id, name

            if id.indexOf('app-') is 0
                ide_event.trigger ide_event.OPEN_APP_TAB, name, current_region, id

            else
                ide_event.trigger ide_event.OPEN_STACK_TAB, name, current_region, id

            null

        deleteStackClick : (event) ->
            console.log 'click to delete stack'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard delete stack'

                modal.close()
                ide_event.trigger ide_event.DELETE_STACK, current_region, id, name

            null

        duplicateStackClick : (event) ->
            console.log 'click to duplicate stack'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            # set default name
            new_name = MC.aws.aws.getDuplicateName(name)
            $('#modal-input-value').val(new_name)

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard duplicate stack'
                new_name = $('#modal-input-value').val()

                #check duplicate stack name
                if not new_name
                    notification 'warning', lang.ide.PROP_MSG_WARN_NO_STACK_NAME
                else if new_name.indexOf(' ') >= 0
                    notification 'warning', lang.ide.PROP_MSG_WARN_WHITE_SPACE
                else if not MC.aws.aws.checkStackName null, new_name
                    notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_STACK_NAME
                else
                    modal.close()

                    ide_event.trigger ide_event.DUPLICATE_STACK, current_region, id, new_name, name

            null

        startAppClick : (event) ->
            console.log 'click to start app'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            # check credential
            if $.cookie('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'dashboard region start app'
                    modal.close()
                    ide_event.trigger ide_event.START_APP, current_region, id, name

            null

        stopAppClick : (event) ->
            console.log 'click to stop app'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            # check credential
            if $.cookie('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'dashboard region stop app'
                    modal.close()
                    ide_event.trigger ide_event.STOP_APP, current_region, id, name

            null

        terminateAppClick : (event) ->
            console.log 'click to terminate app'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            # check credential
            if $.cookie('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'dashboard region terminal app'
                    modal.close()
                    ide_event.trigger ide_event.TERMINATE_APP, current_region, id, name

            null

        updateThumbnail : ( url ) ->
            console.log 'updateThumbnail, url = ' + url
            _.each $( '#region-stat-stack' ).children(), ( item ) ->
                $item = $ item
                if $item.attr('style').indexOf( url ) isnt -1
                    new_url = 'https://s3.amazonaws.com/madeiracloudthumbnail/' + url + '?time=' + Math.round(+new Date())
                    console.log 'new_url = ' + new_url
                    $item.removeAttr 'style'
                    $item.css 'background-image', 'url(' + new_url + ')'

            null

    }

    OverviewView
