#############################
#  View(UI logic) for design/property/volume
#############################

define [ '../base/view',
         './template/stack',
         'event',
         'i18n!/nls/lang.js'
], ( PropertyView, template, ide_event, lang ) ->

    VolumeView = PropertyView.extend {

        events   :
            'click #volume-type-radios input' : 'volumeTypeChecked'
            'change #volume-device' : 'deviceNameChanged'
            'keyup #volume-size-ranged' : 'sizeChanged'
            'keyup  #volume-size-ranged' : 'processIops'
            'keyup #iops-ranged' : 'sizeChanged'
            'click #snapshot-info-group' : 'showSnapshotDetail'
            'change #volume-property-encrypted-check' : 'encryptedCheck'

        render     : () ->
            @$el.html template _.extend isAppEdit:@model.isAppEdit, @model.toJSON()

            $( '#volume-size-ranged' ).parsley 'custom', ( val ) ->
                val = + val
                if not val || val > 1024 || val < 1
                    return lang.PARSLEY.VOLUME_SIZE_MUST_IN_1_1024

            $( '#iops-ranged' ).parsley 'custom', ( val ) ->
                val = + val
                volume_size = parseInt( $( '#volume-size-ranged' ).val(), 10 )
                if val > 4000 || val < 100
                    return lang.PARSLEY.IOPS_MUST_BETWEEN_100_4000
                else if( val > 10 * volume_size)
                    return lang.PARSLEY.IOPS_MUST_BE_LESS_THAN_10_TIMES_OF_VOLUME_SIZE

            @model.attributes.volume_detail.name

        volumeTypeChecked : ( event ) ->
            @processIops()

            type = $('#volume-type-radios input:checked').val()
            # Get iops range when type is 'io1'(IOPS)
            iops = if type is 'io1' then $( '#iops-ranged' ).val() else ''

            if( type isnt 'io1') #IOPS
                $( '#iops-group' ).hide()
            else
                $( '#iops-group' ).show()

            @model.setVolumeType type, iops

            @sizeChanged()

        deviceNameChanged : ( event ) ->
            target       = $ event.currentTarget
            owner        = @model.get( 'volume_detail' ).owner
            name         = target.val()

            devicePrefix = target.prev( 'label' ).text()
            ami = owner.getAmi()
            # follow aws console device name is different from different platform
            # but follow the aws document device named rule is only determined by Virtualization Type
            # so we recommend device name as aws console does and allow device name as aws document
            type = if ami.osType is 'windows' then 'windows' else 'linux'
            virtualizationType = ami.virtualizationType
            self = this

            target.parsley 'custom', ( val ) ->
                if not MC.validate.deviceName val, virtualizationType
                    if virtualizationType is 'hvm'
                        return lang.PARSLEY.DEVICENAME_HVM
                    else
                        return lang.PARSLEY.DEVICENAME_PARAVIRTUAL

                if self.model.isDuplicate val
                    sprintf lang.PARSLEY.VOLUME_NAME_INUSE, val

            if target.parsley 'validate'
                @model.setDeviceName name
                @setTitle @model.attributes.volume_detail.name

        processIops: ( event ) ->
            size = parseInt $( '#volume-size-ranged' ).val(), 10
            opsCheck = $( '#radio-io1' ).is ':checked'

            if size >= 10
                @enableIops()
            else if not opsCheck
                @disableIops()

            null

        enableIops: ->
            $( '#volume-type-radios > div' )
                .last()
                .data( 'tooltip', '' )
                .find( 'input' )
                .removeAttr( 'disabled' )

        disableIops: ->
            $( '#volume-type-radios > div' )
                .last()
                .data( 'tooltip', lang.PROP.VOLUME_DISABLE_IOPS_TOOLTIP )
                .find( 'input' )
                .attr( 'disabled', '' )


        sizeChanged : ( event ) ->
            volumeSize = parseInt $( '#volume-size-ranged' ).val(), 10
            iopsValidate = true
            volumeValidate = $( '#volume-size-ranged' ).parsley 'validate'
            iopsEnabled = $( '#radio-io1' ).is ':checked'

            if iopsEnabled
                iopsValidate = $( '#iops-ranged' ).parsley 'validate'
            if volumeValidate and iopsValidate
                @model.setVolumeSize volumeSize
                if iopsEnabled
                    @model.setVolumeType 'io1', $( '#iops-ranged' ).val()
            null


        showSnapshotDetail : ( event ) ->
            @trigger "OPEN_SNAPSHOT", $("#snapshot-info-group").data("uid")
            null

        encryptedCheck : ( event ) ->
            @model.setEncrypted event.target.checked
            null
    }

    new VolumeView()
