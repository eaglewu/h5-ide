
define [ "constant", "../ConnectionModel", "i18n!/nls/lang.js" ], ( constant, ConnectionModel, lang )->

  C = ConnectionModel.extend {

    type : "EniAttachment"

    defaults :
      index : 1

    initialize : ( attributes )->
      ami = @getTarget constant.RESTYPE.INSTANCE

      # Calc the new index of this EniAttachment.
      if attributes and attributes.index
        # The EniAttachment has a specified index ( This happens when the Eni is deserializing )
        @ensureAttachmentOrder()
      else
        # Newly created EniAttachment has the last index.
        @attributes.index = ami.connectionTargets( "EniAttachment" ).length + 1
      null

    ensureAttachmentOrder : ()->
      ami = @getTarget( constant.RESTYPE.INSTANCE )
      attachments = ami.connections( "EniAttachment" )

      for attach in attachments
        # If we found duplicated index, we just reassign all attachement index.
        if attach isnt this and attach.attributes.index is this.attributes.index
          for attach, idx in attachments
            attach.attributes.index = idx + 1
            attach.getOtherTarget( ami ).updateName()
          return

      newArray = attachments.sort (a, b)-> a.attributes.index - b.attributes.index
      if attachments.indexOf( this ) isnt newArray.indexOf( this )
        # The index of this line has changed. Modified ami's connection array.
        # So that ami.connections("EniAttachment") will always return an sorted EniAttachments.
        amiConnections = []
        for cnn in ami.get("__connections")
          if cnn.type isnt "EniAttachment"
            amiConnections.push cnn

        ami.attributes.__connections = amiConnections.concat newArray

      null

    remove : ()->
      ConnectionModel.prototype.remove.apply this, arguments

      ami = @getTarget constant.RESTYPE.INSTANCE
      eni = @getTarget constant.RESTYPE.ENI

      if not ami.isRemoved()
        # When this EniAttachment is removed, we need to update all the Eni's name.
        attachments = ami.connections("EniAttachment")
        startIdx = 1

        while startIdx <= attachments.length
          attach = attachments[ startIdx - 1 ]
          if attach.attributes.index isnt startIdx
            attach.attributes.index = startIdx
            attach.getTarget( constant.RESTYPE.ENI ).updateName()
          ++startIdx

      if not ami.isRemoved() and not eni.isRemoved()
        # If both resource still exists, it means the line is delected by user
        # Then we should update try to connect sgline between eni and ami
        SgModel = Design.modelClassForType( constant.RESTYPE.SG )
        SgModel.tryDrawLine( ami, eni )
      null

    portDefs :
      port1 :
        name : "instance-attach"
        type : constant.RESTYPE.INSTANCE

      port2 :
        name : "eni-attach"
        type : constant.RESTYPE.ENI

  }, {
    isConnectable : ( p1Comp, p2Comp )->
      p1p = p1Comp.parent()
      p2p = p2Comp.parent()

      if not p1p or not p2p then return false

      if p1p.type is constant.RESTYPE.SUBNET
        p1p = p1p.parent()
        p2p = p2p.parent()

      # Instance and Eni should be in the same az
      if p1p isnt p2p then return false

      # If instance has automaticAssignPublicIp. Then ask the user to comfirm
      if p1Comp.type is constant.RESTYPE.INSTANCE
        instance = p1Comp
        eni      = p2Comp
      else
        instance = p2Comp
        eni      = p1Comp


      # Eni can only be attached to an instance.
      if eni.connections("EniAttachment").length > 0 then return false


      maxEniCount = instance.getMaxEniCount()
      # Instance have an embed eni
      if instance.connections( "EniAttachment" ).length + 1 >= maxEniCount
        return sprintf lang.IDE.CVS_WARN_EXCEED_ENI_LIMIT, instance.get("name"), instance.get("instanceType"), maxEniCount


      if instance.getEmbedEni().get("assoPublicIp") is true
        return {
          confirm  : true
          title    : lang.CANVAS.ATTACH_NETWORK_INTERFACE_TO_INTERFACE
          action   : lang.CANVAS.ATTACH_AND_REMOVE_PUBLIC_IP
          template : MC.template.modalAttachingEni({
            host : instance.get("name")
            eni  : eni.get("name")
          })
        }

      true
  }

  C
