####################################
#  Controller for design/resource module
####################################

define [ 'jquery',
         'text!/module/design/resource/template.html',
         'text!/module/design/resource/template_data.html',
         'event',
         'MC.ide.template'
], ( $, template, template_data, ide_event ) ->

    #private
    loadModule = () ->

        #compile partial template
        MC.IDEcompile 'design-resource', template_data, { '.availability-zone-data' : 'availability-zone-tmpl', '.resoruce-snapshot-data' : 'resoruce-snapshot-tmpl', '.quickstart-ami-data' : 'quickstart-ami-tmpl', '.my-ami-data' : 'my-ami-tmpl', '.favorite-ami-data' : 'favorite-ami-tmpl', '.community-ami-btn':'community-ami-tmpl', '.resource-vpc-select-list' : 'resource-vpc-tmpl' }

        #
        require [ './module/design/resource/view', './module/design/resource/model', 'UI.bubble' ], ( View, model ) ->

            #view
            view       = new View()
            view.render template
            view.listen model
            view.model = model

            #listen RELOAD_RESOURCE
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name, type, current_platform ) ->
                console.log 'resource:RELOAD_RESOURCE'
                #
                #check re-render
                view.reRender template
                #
                model.service_count = 0
                #
                model.set 'check_required_service_count', -1
                #
                model.quickstartService             region_name

                view.region = region_name
                view.resourceVpcRender( current_platform, type )
                view.communityAmiBtnRender()

                ide_event.onListen ide_event.RESOURCE_QUICKSTART_READY, (region_name) ->
                    console.log 'resource:RESOURCE_QUICKSTART_READY'

                    model.describeAvailableZonesService region_name
                    model.describeSnapshotsService      region_name

                null

            ide_event.onLongListen ide_event.ENABLE_RESOURCE_ITEM, ( type, filter ) ->
                view.enableItem type, filter

            ide_event.onLongListen ide_event.DISABLE_RESOURCE_ITEM, ( type, filter ) ->
                view.disableItem type, filter

            view.on 'LOADING_COMMUNITY_AMI', ( region_name, pageNum ) ->
                name = $('#community-ami-input').val()
                platform = $('#selectbox-ami-platform').find('.selected').data('id')
                architecture = radiobuttons.data($('#filter-ami-32bit-64bit'))
                rootDeviceType = radiobuttons.data($('#filter-ami-EBS-Instance'))
                page = parseInt $('#community_ami_page_current').attr("page"), 10
                totalPage = parseInt $('#community_ami_page_current').attr("totalPage"), 10

                model.describeCommunityAmiService region_name, name, platform, architecture, rootDeviceType, null, pageNum

            view.on 'TOGGLE_FAV', ( region_name, action, amiId ) ->
                if action is 'add'
                    model.addFav region_name, amiId
                else if action is 'remove'
                    model.removeFav region_name, amiId

            model.on 'change:availability_zone', () ->
                console.log 'resource availability_zone change'
                ide_event.trigger ide_event.RELOAD_AZ, model.get 'availability_zone'

            model.on 'change:check_required_service_count', () ->
                console.log 'check_required_service_count, count = ' + model.get 'check_required_service_count'

                return if model.get( 'check_required_service_count' ) is -1

                if $.cookie('has_cred') is 'false' and model.get( 'check_required_service_count' ) is 1    # not set credential then use quickstart data
                    console.log 'not set credential and described quickstart service'
                    ide_event.trigger ide_event.SWITCH_MAIN
                    model.service_count = 0

                else if model.get( 'check_required_service_count' ) is 3      # has setted credential
                    console.log 'set credential and described require service'
                    ide_event.trigger ide_event.SWITCH_MAIN
                    model.service_count = 0

                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
