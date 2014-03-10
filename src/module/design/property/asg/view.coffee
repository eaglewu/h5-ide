#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/policy.html',
         'text!./template/term.html',
         'i18n!nls/lang.js'
], ( PropertyView, template, policy_template, term_template, lang ) ->

    template        = Handlebars.compile template
    policy_template = Handlebars.compile policy_template
    term_template   = Handlebars.compile term_template

    metricMap =
        "CPUUtilization"             : "CPU Utilization"
        "DiskReadBytes"              : "Disk Reads"
        "DiskReadOps"                : "Disk Read Operations"
        "DiskWriteBytes"             : "Disk Writes"
        "DiskWriteOps"               : "Disk Write Operations"
        "NetworkIn"                  : "Network In"
        "NetworkOut"                 : "Network Out"
        "StatusCheckFailed"          : "Status Check Failed (Any)"
        "StatusCheckFailed_Instance" : "Status Check Failed (Instance)"
        "StatusCheckFailed_System"   : "Status Check Failed (System)"

    adjustMap =
        "ChangeInCapacity"        : "Change in Capacity"
        "ExactCapacity"           : "Exact Capacity"
        "PercentChangeInCapacity" : "Percent Change in Capacity"

    adjustdefault =
        "ChangeInCapacity"        : "eg. -1"
        "ExactCapacity"           : "eg. 5"
        "PercentChangeInCapacity" : "eg. -30"

    adjustTooltip =
        "ChangeInCapacity"        : "Increase or decrease existing capacity by integer you input here. A positive value adds to the current capacity and a negative value removes from the current capacity."
        "ExactCapacity"           : "Change the current capacity of your Auto Scaling group to the exact value specified."
        "PercentChangeInCapacity" : "Increase or decrease the desired capacity by a percentage of the desired capacity. A positive value adds to the current capacity and a negative value removes from the current capacity"

    unitMap =
        CPUUtilization : "%"
        DiskReadBytes  : "B"
        DiskWriteBytes : "B"
        NetworkIn      : "B"
        NetworkOut     : "B"

    InstanceView = PropertyView.extend {

        events   :
            "click #property-asg-term-edit"                : "showTermPolicy"
            "click #property-asg-sns input[type=checkbox]" : "setNotification"
            "change #property-asg-elb"                     : "setHealthyCheckELBType"
            "change #property-asg-ec2"                     : "setHealthyCheckEC2Type"
            "change #property-asg-name"                    : "setASGName"
            "change #property-asg-min"                     : "setSizeGroup"
            "change #property-asg-max"                     : "setSizeGroup"
            "change #property-asg-capacity"                : "setSizeGroup"
            "change #property-asg-cooldown"                : "setASGCoolDown"
            "change #property-asg-healthcheck"             : "setHealthCheckGrace"
            "click #property-asg-policy-add"               : "addScalingPolicy"
            "click #property-asg-policies .icon-edit"      : "editScalingPolicy"
            "click #property-asg-policies .icon-del"       : "delScalingPolicy"


        render     : () ->
            data = @model.toJSON()

            for p in data.policies
                p.unit   = unitMap[ p.alarmData.metricName ]
                p.alarmData.metricName = metricMap[ p.alarmData.metricName ]
                p.adjustmentType = adjustMap[ p.adjustmentType ]

            data.term_policy_brief = data.terminationPolicies.join(" > ")

            data.can_add_policy = data.policies.length < 25

            @$el.html template data

            data.name

        setASGCoolDown : ( event ) ->
            $target = $ event.target

            $target.parsley 'custom', ( val ) ->
                if _.isNumber( +val ) and +val > 86400
                    return 'Max value: 86400'
                null

            if $target.parsley 'validate'
                @model.setASGCoolDown $target.val()

        setASGName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if @checkResName( target, "ASG" )
                @model.setName name
                @setTitle name

        setSizeGroup: ( event ) ->
            $min        = @$el.find '#property-asg-min'
            $max        = @$el.find '#property-asg-max'
            $capacity   = @$el.find '#property-asg-capacity'

            $min.parsley 'custom', ( val ) ->
                if + val < 1
                    return 'ASG size must be equal or greater than 1'
                if + val > + $max.val()
                    return 'Minimum Size must be <= Maximum Size.'

            $max.parsley 'custom', ( val ) ->
                if + val < 1
                    return 'ASG size must be equal or greater than 1'
                if + val < + $min.val()
                    return 'Minimum Size must be <= Maximum Size'

            $capacity.parsley 'custom', ( val ) ->
                if + val < 1
                    return 'Desired Capacity must be equal or greater than 1'
                if + val < + $min.val() or + val > + $max.val()
                    return 'Desired Capacity must be >= Minimal Size and <= Maximum Size'

            if $( event.currentTarget ).parsley 'validateForm'
                @model.setASGMin $min.val()
                @model.setASGMax $max.val()
                @model.setASGDesireCapacity $capacity.val()

        setHealthCheckGrace : ( event ) ->
            @model.setHealthCheckGrace event.target.value

        showTermPolicy : () ->
            data    = []
            checked = {}

            for policy in @model.get("terminationPolicies")
                if policy is "Default"
                    data.useDefault = true
                else
                    data.push { name : policy, checked : true }
                    checked[ policy ] = true

            for p in [lang.ide.PROP_ASG_TERMINATION_POLICY_OLDEST, lang.ide.PROP_ASG_TERMINATION_POLICY_NEWEST, lang.ide.PROP_ASG_TERMINATION_POLICY_OLDEST_LAUNCH, lang.ide.PROP_ASG_TERMINATION_POLICY_CLOSEST]
                if not checked[ p ]
                    data.push { name : p, checked : false }

            modal term_template(data), true

            self = this

            # Bind event to the popup
            $("#property-asg-term").on "click", "input", ()->
                $checked = $("#property-asg-term").find("input:checked")
                if $checked.length is 0
                    return false

                $this = $(this)
                checked = $this.is(":checked")
                $this.closest("li").toggleClass("enabled", checked)

            $("#property-asg-term-done").on "click", ()->
                self.onEditTermPolicy()
                modal.close()

            $("#property-asg-term").on "mousedown", ".drag-handle", ()->
                $(this).trigger("mouseleave")

            # Init drag drop list
            $("#property-term-list").sortable({ handle : '.drag-handle' })

        onEditTermPolicy : () ->
            data = []

            $("#property-term-list .list-name").each ()->
                $this = $(this)
                if $this.closest("li").hasClass("enabled")
                    data.push $this.text()
                null

            if $("#property-asg-term-def").is(":checked")
                data.push "Default"

            $(".termination-policy-brief").text( data.join(" > ") )

            @model.setTerminatePolicy data

        delScalingPolicy  : ( event ) ->
            $li = $( event.currentTarget ).closest("li")
            uid = $li.data("uid")
            $li.remove()

            $("#property-asg-policy-add").removeClass("tooltip disabled")

            @model.delPolicy uid

        updateScalingPolicy : ( data ) ->
            # Add or update the policy
            metric     = metricMap[ data.alarmData.metricName ]
            adjusttype = adjustMap[ data.adjustmentType ]
            unit       = unitMap[ data.alarmData.metricName ] || ""

            if not data.uid
                console.error "Cannot find scaling policy uid"
                return

            $policies = $("#property-asg-policies")
            $li = $policies.children("[data-uid='#{data.uid}']")
            if $li.length is 0
                # Create a scaling policy
                $li = $policies.children(".hide").clone().attr("data-uid", data.uid).removeClass("hide").appendTo $policies

                # Check if we have 25 policy already.
                # There's a template item inside the ul, so the length shoud be 26
                $("#property-asg-policy-add").toggleClass("tooltip disabled", $("#property-asg-policies").children().length >= 26)


            $li.find(".name").html data.name
            $li.find(".asg-p-metric").html  metric
            $li.find(".asg-p-eval").html    data.alarmData.comparisonOperator + " " + data.alarmData.threshold + unit
            $li.find(".asg-p-periods").html data.alarmData.evaluationPeriods + "x" + Math.round( data.alarmData.period / 60 ) + "m"
            $li.find(".asg-p-trigger").html( data.state ).attr("class", "asg-p-trigger asg-p-tag asg-p-trigger-" + data.state )
            $li.find(".asg-p-adjust").html  data.adjustment + " " + data.adjustmentType

        editScalingPolicy : ( event ) ->

            uid = $( event.currentTarget ).closest("li").data("uid")

            data = @model.getPolicy(uid)

            data.uid   = uid
            data.title = lang.ide.PROP_ASG_ADD_POLICY_TITLE_EDIT

            @showScalingPolicy( data )

            selectMap =
                metric        : data.alarmData.metricName
                eval          : data.alarmData.comparisonOperator
                trigger       : data.state
                "adjust-type" : data.adjustmentType
                statistics    : data.alarmData.statistic

            for key, value of selectMap
                $selectbox = $("#asg-policy-#{key}")
                $selected  = null

                for item in $selectbox.find(".item")
                    $item = $(item)
                    if $item.data("id") is value
                        $selected = $item
                        break

                if $selected
                    $selectbox.find(".selected").removeClass "selected"
                    $selectbox.find(".selection").html $selected.addClass("selected").html()

            $(".pecentcapcity").toggle( $("#asg-policy-adjust-type").find(".selected").data("id") == "PercentChangeInCapacity" )

        addScalingPolicy : ( event ) ->
            if $( event.currentTarget ).hasClass "disabled"
                return false

            @showScalingPolicy()
            false


        showScalingPolicy : ( data ) ->
            if !data
                data =
                    title   : lang.ide.PROP_ASG_ADD_POLICY_TITLE_ADD
                    name    : @model.defaultScalingPolicyName()
                    minAdjustStep : 1
                    alarmData : {
                        evaluationPeriods : 2
                        period : 5
                    }

            if data.alarmData and data.alarmData.metricName
                data.unit = unitMap[ data.alarmData.metricName ]
            else
                data.unit = '%'

            data.noSNS = not this.model.attributes.has_sns_sub
            data.detail_monitor = this.model.attributes.detail_monitor

            modal policy_template(data), true

            self = this
            $("#property-asg-policy-done").on "click", ()->
                result = $("#asg-termination-policy").parsley("validate")
                if result is false
                    return false
                self.onPolicyDone()
                modal.close()

            $("#asg-policy-name").parsley 'custom', ( name ) ->
                uid  = $("#property-asg-policy").data("uid")

                if self.model.isDupPolicyName uid, name
                    return "Duplicated policy name in this autoscaling group"


            $("#asg-policy-periods, #asg-policy-second").on "change", ()->
                val = parseInt $(this).val(), 10
                if not val or val < 1
                    $(this).val( "1" ).parsley("validate")

            $("#asg-policy-adjust-type").on "OPTION_CHANGE", ()->
                type = $(this).find(".selected").data("id")
                $(".pecentcapcity").toggle( type == "PercentChangeInCapacity" )
                $("#asg-policy-adjust").attr("placeholder", adjustdefault[type] ).data("tooltip", adjustTooltip[ type ] ).trigger("change")

            $("#asg-policy-adjust").on "change", ()->
                type = $("#asg-policy-adjust-type").find(".selected").data("id")
                val  = parseInt $(this).val(), 10

                if type is "ExactCapacity"
                    if not val or val < 1
                        $(this).val( "1" )
                else if type is "PercentChangeInCapacity"
                    if not val
                        $(this).val( "0" )
                    else if val < -100
                        $(this).val( "-100" )
                    # else if val > 100
                    #     $(this).val( "100" )

                $("#").data("tooltip", adjustTooltip[ type ] ).trigger("change")


            $("#asg-policy-cooldown").on "change", ()->
                $this = $("#asg-policy-cooldown")

                val   = parseInt $this.val(), 10
                if isNaN( val )
                    return

                if val < 0
                    val = 0
                else if val > 86400
                    val = 86400

                $this.val( val )


            $("#asg-policy-step").on "change", ()->
                $this = $("#asg-policy-step")

                val   = parseInt $this.val(), 10
                if isNaN( val )
                    return

                if val < 0
                    val = 0
                else if val > 65534
                    val = 65534

                $this.val( val )

            $("#asg-policy-threshold").on "change", ()->
                metric = $("#asg-policy-metric .selected").data("id")
                val    = parseInt $(this).val(), 10
                if metric is "CPUUtilization"
                    if isNaN( val ) or val < 1
                        $(this).val( "1" )
                    else if val > 100
                        $(this).val( "100" )


            $("#asg-policy-notify").on "click", ( evt )->
                $("#asg-policy-no-sns").toggle( $("#asg-policy-notify").is(":checked") )
                evt.stopPropagation()
                null

            $("#asg-policy-metric").on "OPTION_CHANGE", ()->
                $("#asg-policy-unit").html( unitMap[$(this).find(".selected").data("id")] || "" )
                $( '#asg-policy-threshold' ).val ''

            null

        onPolicyDone : () ->

            data =
                uid              : $("#property-asg-policy").data("uid")
                name             : $("#asg-policy-name").val()
                cooldown         : $("#asg-policy-cooldown").val() * 60
                minAdjustStep    : $("#asg-policy-step").val()
                adjustment       : $("#asg-policy-adjust").val()
                adjustmentType   : $("#asg-policy-adjust-type .selected").data("id")
                state            : $("#asg-policy-trigger .selected").data("id")
                sendNotification : $("#asg-policy-notify").is(":checked")

                alarmData : {
                    metricName         : $("#asg-policy-metric .selected").data("id")
                    comparisonOperator : $("#asg-policy-eval .selected").data("id")
                    period             : $("#asg-policy-second").val() * 60
                    evaluationPeriods  : $("#asg-policy-periods").val()
                    statistic          : $("#asg-policy-statistics .selected").data("id")
                    threshold          : $("#asg-policy-threshold").val()
                }

            @model.setPolicy data
            @updateScalingPolicy data
            null

        setNotification : () ->
            checkMap = {}
            hasChecked = false
            $("#property-asg-sns input[type = checkbox]").each ()->
                checked = $(this).is(":checked")
                checkMap[ $(this).attr("data-key") ] = checked

                if checked then hasChecked = true

                null

            if hasChecked
                $("#property-asg-sns-info").show()
            else
                $("#property-asg-sns-info").hide()

            @model.setNotification checkMap

        setHealthyCheckELBType :( event ) ->
            @model.setHealthCheckType 'ELB'

        setHealthyCheckEC2Type :( event ) ->
            @model.setHealthCheckType 'EC2'

    }

    new InstanceView()
