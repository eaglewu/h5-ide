#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', 'text!./template/app.html', 'i18n!nls/lang.js' ], ( PropertyView, template, lang )->

    template = Handlebars.compile template

    InstanceAppView = PropertyView.extend {
        events   :
            "click #property-app-keypair" : "downloadKeypair"
            "click #property-app-ami" : "openAmiPanel"
            "click .icon-syslog" : "openSysLogModal"

        kpModalClosed : false

        render : () ->
            @$el.html template @model.attributes
            @model.attributes.name

        downloadKeypair : ( event ) ->
            keypair = $( event.currentTarget ).html()
            @model.downloadKP(keypair)

            modal MC.template.modalDownloadKP { name  : keypair }

            me = this
            $('#modal-wrap').on "closed", ()->
                me.kpModalClosed = true
                null

            $(".modal-body").on "click", ".click-select", ( event )->
                if event.currentTarget.select
                    event.currentTarget.select()
                event.stopPropagation()


            $("#keypair-show").on "click", ()->
                $("#keypair-pwd").attr("type", "string")
                null


            this.kpModalClosed = false

            false

        updateKPModal : ( data, option ) ->
            if not data
                modal.close()
                return

            if this.kpModalClosed
                return

            if option.passwd
                $("#keypair-pwd").val( option.passwd )
            else
                $("#keypair-login").hide()
                $("#keypair-no-pwd").text lang.ide.POP_DOWNLOAD_KP_NOT_AVAILABLE

            if option.cmd_line
                $("#keypair-cmd").val( option.cmd_line )
            else
                $("#keypair-remote").hide()

            if option.public_dns
                $("#keypair-dns").val( option.public_dns )
            else
                $("#keypair-public").hide()

            if option.rdp
                $("#keypair-rdp")
                    .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent( option.rdp ) )
                    .attr("download", $("#keypair-name").text() + ".rdp" )
            else
                $("#keypair-rdp").hide()


            $("#keypair-kp-" + option.type )
                .attr("href", "data://text/plain;charset=utf8," + encodeURIComponent(data) )
                .attr("download", $("#keypair-name").text() + ".pem" )

            $("#keypair-private-key").val( data )

            $("#keypair-loading").hide()
            $("#keypair-body-" + option.type ).show()

            modal.position()
            null

        openAmiPanel : ( event ) ->
            this.trigger "OPEN_AMI", $( event.target ).data("uid")
            false

        changeIPAddBtnState : () ->

            disabledBtn = false
            instanceUID = @model.get 'id'

            maxIPNum = MC.aws.eni.getENIMaxIPNum(instanceUID)
            currentENIComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
            if !currentENIComp
                disabledBtn = true
                return

            currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
            if maxIPNum is currentIPNum
                disabledBtn = true

            instanceType = Design.instance().component( instanceUID ).get 'instanceType'

            if disabledBtn
                tooltipStr = sprintf(lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instanceType, maxIPNum)
                $('#instance-ip-add').addClass('disabled').attr('data-tooltip', tooltipStr).data('tooltip', tooltipStr)
            else
                $('#instance-ip-add').removeClass('disabled').attr('data-tooltip', 'Add IP Address').data('tooltip', 'Add IP Address')

            null

        openSysLogModal : () ->

            instanceId = @model.get('instanceId')
            @model.loadSysLogData(instanceId)

            modal MC.template.modalInstanceSysLog {
                instance_id: instanceId,
                log_content: ''
            }, true

            return false

        refreshSysLog : (result) ->

            $('#modal-instance-sys-log .instance-sys-log-loading').hide()

            if result and result.output

                logContent = MC.base64Decode(result.output)
                $contentElem = $('#modal-instance-sys-log .instance-sys-log-content')

                logContentTpl = Handlebars.compile('{{nl2br content}}')
                logContentHTML = logContentTpl({
                    content: logContent
                })
                $contentElem.html(logContentHTML)
                $contentElem.show()

            else

                $('#modal-instance-sys-log .instance-sys-log-info').show()
                
            modal.position()

    }

    new InstanceAppView()
