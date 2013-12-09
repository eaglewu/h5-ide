#############################
#  View Mode for header module
#############################

define [ 'aws_model', 'ami_model'
         'event', 'constant',
         'text!./module/process/appview.json'
         'backbone', 'jquery', 'underscore'
], ( aws_model, ami_model, ide_event, constant, appview_json ) ->

    ProcessModel = Backbone.Model.extend {

        defaults:

            #flag_list = {'is_pending':true|false, 'is_inprocess':true|false, 'is_done':true|false, 'is_failed':true|false, 'steps':0, 'dones':0, 'rate':0}
            'flag_list'         : null
            'current_tab_id'    : null

        initialize  : ->
            me = this

            # test json object
            appview_json = JSON.parse appview_json
            console.log 'appview json is ', appview_json

            # set init flag_list
            me.set 'flag_list', { 'is_pending' : true }

            @on 'AWS_VPC__RESOURCE_RETURN', ( result ) ->
                console.log 'AWS_VPC__RESOURCE_RETURN', result

                if result and not result.is_error and result.resolved_data and result.resolved_data.length > 0

                    # set result.resolved_data
                    #result.resolved_data = []
                    #result.resolved_data.push appview_json

                    # set cacheMap data
                    obj = MC.forge.other.setCacheMap result.param[4], result, null

                    # set current tab id
                    @set 'current_tab_id', obj.id

                    # set ami_ids
                    ami_ids = MC.forge.app.getAmis result.resolved_data[0]

                    # call api
                    @getDescribeImages result.param[3], ami_ids

                    null

            @on 'EC2_AMI_DESC_IMAGES_RETURN', ( result ) ->
                console.log 'EC2_AMI_DESC_IMAGES_RETURN', result

                if result and not result.is_error and result.resolved_data and result.resolved_data.length > 0

                    # set cache resource
                    amis = {
                        "DescribeImages" : []
                    }
                    for ami in result.resolved_data

                        amis.DescribeImages.push ami

                    MC.aws.aws.cacheResource amis, result.param[3], false

                    MC.aws.ami.setLayout(MC.canvas_data)

                    # get call service current tab id
                    current_tab_id = result.param[0].src.sender.get 'current_tab_id'

                    # get origin_id
                    origin_obj = MC.forge.other.getCacheMap current_tab_id

                    # set cacheMap data
                    obj = MC.forge.other.setCacheMap origin_obj.origin_id, null, 'FINISH'

                    if MC.forge.other.isCurrentTab current_tab_id

                        # reload app view
                        @reloadAppView obj

        getProcess  : (tab_name) ->
            me = this

            if MC.process[tab_name]

                # get the data
                flag_list = MC.process[tab_name].flag_list

                console.log 'tab name:' + tab_name
                console.log 'flag_list:' + flag_list

                last_flag = me.get 'flag_list'

                me.set 'flag_list', flag_list

                if 'is_done' of flag_list and flag_list.is_done     # completed

                    # complete the progress
                    $('#progress_bar').css('width', "100%" )
                    $('#progress_num').text last_flag.steps
                    $('#progress_total').text last_flag.steps

                    ide_event.trigger ide_event.SWITCH_WAITING_BAR

                    # hold on 1 second
                    setTimeout () ->

                        app_id = flag_list.app_id
                        region = MC.process[tab_name].region

                        # save png
                        app_name = MC.process[tab_name].name

                        # not current tab return
                        if MC.data.current_tab_id isnt 'process-' + region + '-' + app_name
                            return

                        # hold on two seconds
                        setTimeout () ->

                            # update tab
                            ide_event.trigger ide_event.UPDATE_DESIGN_TAB, app_id, app_name + ' - app'

                            # reload app
                            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'RELOAD_APP', app_name, region, app_id

                            #ide_event.trigger ide_event.PROCESS_RUN_SUCCESS, app_id, region
                            #ide_event.trigger ide_event.DELETE_TAB_DATA, tab_name
                            #ide_event.trigger ide_event.UPDATE_APP_LIST, null

                        , 800

                    , 1000

                else if 'is_inprocess' of flag_list and flag_list.is_inprocess # in progress

                    if flag_list.dones > 0 and 'steps' of flag_list and flag_list.steps > 0
                        $('#progress_bar').css('width', Math.round( flag_list.dones/flag_list.steps*100 ) + "%" )
                        $('#progress_num').text flag_list.dones

                    else
                        $('#progress_bar').css('width', "0" )
                        $('#progress_num').text '0'

                    $('#progress_total').text flag_list.steps

                else

                    me.set 'flag_list', flag_list

            null

        getVpcResourceService : ( region, vpc_id, state )  ->
            console.log 'getVpcResourceService', region, vpc_id, state

            if state is 'OPEN_PROCESS'

                # call api
                aws_model.vpc_resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, vpc_id

                # set state 'OLD'
                MC.forge.other.setCacheMap vpc_id, null, 'OLD'

            else if state is 'OLD_PROCESS'

                # get obj
                obj = MC.forge.other.searchCacheMap { key : 'origin_id', value : vpc_id }

                if obj and obj.data and obj.state is 'FINISH'

                    # reload app view
                    @reloadAppView obj

                else

                    console.log 'not found process'

            null

        getDescribeImages : ( region, ami_ids ) ->
            console.log 'getDescribeImages', region, ami_ids

            ami_model.DescribeImages { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, ami_ids

            null

        reloadAppView : ( obj ) ->
            console.log 'reloadAppView', obj

            # set appview id
            appview_id = 'appview-' + obj.uid

            # update tab
            ide_event.trigger ide_event.UPDATE_DESIGN_TAB, appview_id, obj.origin_id + ' - app'

            # reload app
            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'RELOAD_APPVIEW', obj.origin_id, obj.region, appview_id

            null
    }

    model = new ProcessModel()
    return model
