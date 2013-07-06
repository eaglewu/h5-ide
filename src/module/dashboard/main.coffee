####################################
#  Controller for dashboard module
####################################

define [ 'jquery',
    'text!/module/dashboard/overview/template.html',
    'text!/module/dashboard/region/template.html',
    'text!/module/dashboard/overview/template_data.html',
    'text!/module/dashboard/region/template_data.html',
    'event',
    'MC'
], ( $, overview_tmpl, region_tmpl, overview_tmpl_data, region_tmpl_data, ide_event, MC ) ->


    current_region = null

    overview_app    = null
    overview_stack  = null
    should_update_overview = false

    #private
    loadModule = () ->
        #add handlebars script
        #overview_tmpl = '<script type="text/x-handlebars-template" id="overview-tmpl">' + overview_tmpl + '</script>'
        #load remote html ovverview_tmpl
        #$( overview_tmpl ).appendTo 'head'

        #add handlebars script
        #overview_tmpl = '<script type="text/x-handlebars-template" id="region-tmpl">' + region_tmpl + '</script>'
        #load remote html ovverview_tmpl
        #$( overview_tmpl ).appendTo 'head'

        MC.IDEcompile 'overview', overview_tmpl_data, {'.overview-result' : 'overview-result-tmpl', '.overview-empty' : 'overview-empty-tmpl', '.stat-info' : 'stat-info-tmpl','.platform-attr' : 'platform-attr-tmpl', '.recent-edited-stack' : 'recent-edited-stack-tmpl', '.recent-launched-app' : 'recent-launched-app-tmpl', '.recent-stopped-app' : 'recent-stopped-app-tmpl' }

        MC.IDEcompile 'region', region_tmpl_data, {'.resource-tables': 'region-resource-tables-tmpl', '.unmanaged-resource-tables': 'region-unmanaged-resource-tables-tmpl', '.aws-status': 'aws-status-tmpl', '.vpc-attrs': 'vpc-attrs-tmpl', '.stat-app-count' : 'stat-app-count-tmpl', '.stat-stack-count' : 'stat-stack-count-tmpl', '.stat-app' : 'stat-app-tmpl', '.stat-stack' : 'stat-stack-tmpl' }

        #set MC.data.dashboard_type default
        MC.data.dashboard_type = 'OVERVIEW_TAB'

        #load remote ./module/dashboard/overview/view.js
        require [ './module/dashboard/overview/view', './module/dashboard/overview/model', 'constant', 'UI.tooltip' ], ( View, model, constant ) ->

            console.log '------------ overview view load ------------ '

            #
            region_view = null

            #view
            view       = new View()
            view.model = model
            view.render overview_tmpl

            #push DASHBOARD_COMPLETE
            ide_event.trigger ide_event.DASHBOARD_COMPLETE

            model.on 'change:result_list', () ->
                console.log 'dashboard_change:result_list'
                should_update_overview = true
                #refresh view
                view.renderMapResult()
                view.renderStatInfo()

            model.on 'change:region_empty_list', () ->
                console.log 'dashboard_change:region_empty'
                #refresh view
                view.renderMapEmpty()

            model.on 'change:region_classic_list', () ->
                console.log 'dashboard_region_classic_list'
                #set MC.data.supported_platforms
                MC.data.supported_platforms = model.get 'region_classic_list'
                #refresh view
                view.renderPlatformAttrs()

            model.on 'change:recent_edited_stacks', () ->
                console.log 'dashboard_change:recent_eidted_stacks'
                #model.get 'recent_edited_stacks'
                view.renderRecentEditedStack()

            model.on 'change:recent_launched_apps', () ->
                console.log 'dashboard_change:recent_launched_apps'
                #model.get 'recent_launched_apps'
                view.renderRecentLaunchedApp()

            model.on 'change:recent_stoped_apps', () ->
                console.log 'dashboard_change:recent_stoped_apps'
                #model.get 'recent_stoped_apps'
                view.renderRecentStoppedApp()

            #model
            model.resultListListener()
            model.emptyListListener()
            model.describeAccountAttributesService()

            ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->
                console.log 'overview RESULT_APP_LIST'

                overview_app = result

                if overview_stack
                    model.updateMap model, overview_app, overview_stack

                model.updateRecentList( model, result, 'recent_launched_apps' )
                model.updateRecentList( model, result, 'recent_stoped_apps' )

                if should_update_overview
                    view.renderMapResult()
                    view.renderStatInfo()
                    view.renderMapEmpty()

                null

            ide_event.onLongListen 'RESULT_STACK_LIST', ( result ) ->
                console.log 'overview RESULT_STACK_LIST'

                overview_stack = result

                if overview_app
                    model.updateMap model, overview_app, overview_stack
                else
                    ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->
                        overview_app = result
                        model.updateMap model, overview_app, overview_stack

                model.updateRecentList( model, result, 'recent_edited_stacks' )

                if should_update_overview
                    view.renderMapResult()
                    view.renderStatInfo()
                    view.renderMapEmpty()

                null

            ide_event.onLongListen ide_event.NAVIGATION_TO_DASHBOARD_REGION, ( result ) ->

                console.log 'NAVIGATION_TO_DASHBOARD_REGION'
                view.trigger 'RETURN_REGION_TAB', result

                null

            #listen
            view.on 'RETURN_REGION_TAB', ( region ) ->
                console.log 'RETURN_REGION_TAB'
                #set MC.data.dashboard_type

                current_region = region

                MC.data.dashboard_type = 'REGION_TAB'
                #push event
                ide_event.trigger ide_event.RETURN_REGION_TAB, constant.REGION_LABEL[ region ]

                if region_view isnt null

                    region_view.region = current_region
                    
                    region_view.model.resetData()
                    region_view.model.describeAWSResourcesService region
                    region_view.model.describeRegionAccountAttributesService region
                    region_view.model.describeAWSStatusService region
                    region_view.model.getItemList 'app', region, overview_app
                    region_view.model.getItemList 'stack', region, overview_stack
                    return

                #load remote ./module/dashboard/region/view.js
                require [ './module/dashboard/region/view', './module/dashboard/region/model', 'UI.tooltip', 'UI.bubble', 'UI.modal', 'UI.table', 'UI.tablist' ], ( View, model ) ->

                    console.log '------------ region view load ------------ '

                    #view
                    region_view        = new View()
                    region_view.model  = model
                    region_view.region = current_region
                    region_view.render region_tmpl

                    model.on 'change:vpc_attrs', () ->
                        console.log 'dashboard_change:vpc_attrs'
                        #model.get 'vpc_attrs'
                        region_view.renderVPCAttrs()

                    model.on 'change:unmanaged_list', () ->
                        console.log 'dashboard_change:unmanaged_list'
                        unmanaged_list = model.get 'unmanaged_list'
                        region_view.renderUnmanagedRegionResource( unmanaged_list.time_stamp )

                        null

                    model.on 'change:status_list', () ->
                        console.log 'dashboard_change:status_list'
                        unmanaged_list = model.get 'status_list'
                        region_view.renderAWSStatus()

                        null

                    #listen
                    model.on 'change:cur_app_list', () ->
                        console.log 'dashboard_region_change:cur_app_list'
                        #model.get 'cur_app_list'
                        region_view.renderRegionStatApp()

                    model.on 'change:cur_stack_list', () ->
                        console.log 'dashboard_region_change:cur_stack_list'
                        #model.get 'cur_stack_list'
                        region_view.renderRegionStatStack()

                    model.on 'change:region_resource_list', () ->
                        console.log 'dashboard_region_resource_list'
                        #refresh view
                        region_view.renderRegionResource()

                    model.on 'change:region_resource', () ->
                        console.log 'dashboard_region_resources'
                        #refresh view
                        region_view.renderRegionResource()

                    model.on 'REGION_RESOURCE_CHANGED', ()->
                        console.log 'region resource table render'
                        region_view.renderRegionResource()

                    region_view.on 'RETURN_OVERVIEW_TAB', () ->
                        #set MC.data.dashboard_type
                        MC.data.dashboard_type = 'OVERVIEW_TAB'
                        #push event
                        ide_event.trigger ide_event.RETURN_OVERVIEW_TAB, null
                        return

                    region_view.on 'RUN_APP_CLICK', (app_id) ->
                        console.log 'dashboard_region_click:run_app'
                        # call service
                        model.runApp(current_region, app_id)
                    region_view.on 'STOP_APP_CLICK', (app_id) ->
                        console.log 'dashboard_region_click:stop_app'
                        model.stopApp(current_region, app_id)
                    region_view.on 'TERMINATE_APP_CLICK', (app_id) ->
                        console.log 'dashboard_region_click:terminate_app'
                        model.terminateApp(current_region, app_id)
                    region_view.on 'DUPLICATE_STACK_CLICK', (stack_id, new_name) ->
                        console.log 'dashboard_region_click:duplicate_stack'
                        model.duplicateStack(current_region, stack_id, new_name)
                    region_view.on 'DELETE_STACK_CLICK', (stack_id) ->
                        console.log 'dashboard_region_click:delete_stack'
                        model.deleteStack(current_region, stack_id)
                    region_view.on 'REFRESH_REGION_BTN', () ->
                        model.describeAWSResourcesService current_region

                    model.describeAWSResourcesService current_region
                    model.describeRegionAccountAttributesService current_region
                    model.describeAWSStatusService current_region
                    model.getItemList 'app', current_region, overview_app
                    model.getItemList 'stack', current_region, overview_stack

                    ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->

                        overview_app = result

                        console.log 'RESULT_APP_LIST'

                        should_update_overview = true

                        model.getItemList 'app', current_region, overview_app

                        null

                    ide_event.onLongListen 'RESULT_STACK_LIST', ( result ) ->

                        overview_stack = result

                        console.log 'RESULT_STACK_LIST'

                        model.getItemList 'stack', current_region, overview_stack

                        null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule