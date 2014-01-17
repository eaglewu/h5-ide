#############################
#  View Mode for design/property/subnet
#############################

define [ '../base/model', 'constant', "Design" ], ( PropertyModel, constant, Design ) ->

  SubnetModel = PropertyModel.extend {

    init : ( uid ) ->

      subnet_component = Design.instance().component( uid )

      if !subnet_component then return false

      ACLModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )

      subnet_acl = subnet_component.connectionTargets( "AclAsso" )[0]

      defaultACL  = null
      networkACLs = []
      _.each ACLModel.allObjects(), ( acl )->
        aclObj = {
          uid         : acl.id
          name        : acl.get("name")
          isUsed      : acl is subnet_acl
          rule        : acl.getRuleCount()
          association : acl.getAssoCount()
        }

        if acl.isDefault()
          defaultACL = aclObj
          aclObj.isDefault = true
        else
          networkACLs.splice( _.sortedIndex( networkACLs, aclObj, "name" ), 0, aclObj )

        null

      if defaultACL
        networkACLs.splice( 0, 0, defaultACL )

      @set {
        uid        : uid
        name       : subnet_component.get("name")
        networkACL : networkACLs
      }

      @getCidr()
      null

    getCidr : ()->
      subnet = Design.instance().component( @get("uid") )
      subnetCidr = subnet.get("cidr")

      # Split CIDR into two parts
      cidrDivAry = @genCIDRDivAry( subnet.parent().parent().get("cidr"), subnetCidr )
      @set "CIDRPrefix", cidrDivAry[0]
      @set "CIDR", if subnetCidr then cidrDivAry[1] else ""
      null


    genCIDRDivAry : (vpcCIDR, subnetCIDR) ->
      if not subnetCIDR then subnetCIDR = vpcCIDR

      vpcSuffix = Number(vpcCIDR.split('/')[1])

      subnetIPAry = subnetCIDR.split('/')
      subnetSuffix = Number(subnetIPAry[1])

      subnetAddrAry = subnetIPAry[0].split('.')

      if vpcSuffix > 23
        resultPrefix = subnetAddrAry[0] + '.' + subnetAddrAry[1] + '.' + subnetAddrAry[2] + '.'
        resultSuffix = subnetAddrAry[3] + '/' + subnetSuffix
      else
        resultPrefix = subnetAddrAry[0] + '.' + subnetAddrAry[1] + '.'
        resultSuffix = subnetAddrAry[2] + '.' + subnetAddrAry[3] + '/' + subnetSuffix

      return [resultPrefix, resultSuffix]


    createAcl : ()->
      ACLModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )
      acl = new ACLModel()
      # Assign acl to the newly created acl
      @setACL( acl.id )
      acl.id

    removeAcl : ( acl_uid )->
      Design.instance().component( acl_uid ).remove()
      null

    setCidr : ( cidr ) ->
      Design.instance().component( @get("uid") ).setCidr( cidr )

    setACL : ( acl_uid ) ->
      Design.instance().component( @get("uid") ).setAcl( acl_uid )
      null

    isValidCidr : ( cidr )->
      Design.instance().component( @get("uid") ).isValidCidr( cidr )

  }

  new SubnetModel()
