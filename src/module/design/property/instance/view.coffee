#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars',
        'UI.fixedaccordion',
        'UI.secondarypanel',
        'UI.selectbox',
        'UI.tooltip',
        'UI.notification',
        'UI.toggleicon' ], ( ide_event, MC ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-instance-tmpl' ).html()

        events   :
            'change .instance-name' : 'instanceNameChange'
            'change .instance-type-select' : 'instanceTypeSelect'
            'change #property-instance-ebs-optimized' : 'ebsOptimizedSelect'
            'OPTION_CHANGE #instance-type-select' : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select' : "tenancySelect"
            'EDIT_EMPTY #property-instance-keypairs' : "addEmptyKP"
            'OPTION_CHANGE #security-group-select' : "addSGtoList"
            'click #sg-info-list .sg-remove-item-icon' : "removeSGfromList"
            'click #instance-ip-add' : "addIPtoList"
            'click #property-network-list .network-remove-icon' : "removeIPfromList"

        render     : ( attributes ) ->
            console.log 'property:instance render'
            $( '.property-details' ).html this.template attributes
            fixedaccordion.resize()

        instanceNameChange : ( event ) ->
            console.log 'instanceNameChange'
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setHost cid, event.target.value

        instanceTypeSelect : ( event, value )->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setInstanceType cid, value

        ebsOptimizedSelect : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setEbsOptimized cid, event.target.checked

        tenancySelect : ( event, value ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setTenancy cid, value

        addEmptyKP : ( event ) ->
            notification('error', 'KeyPair Empty', false)

        securityGroupAddSelect: (event) ->
            event.stopPropagation()
            fixedaccordion.show.call $(this).parent().find '.fixedaccordion-head'

        addSGtoList: (event, id) ->
            if(id.length != 0)
                $('#sg-info-list').append MC.template.sgListItem({name: id})

        addIPtoList: (event) ->
            $('#property-network-list').append MC.template.networkListItem()
            false

        removeSGfromList: (event, id) ->
            event.stopPropagation()
            $(this).parent().remove()
            notification 'info', 'SG is deleted', false

        removeIPfromList: (event, id) ->
            event.stopPropagation()
            $(this).parent().remove()

    }

    view = new InstanceView()

    return view