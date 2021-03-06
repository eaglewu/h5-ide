
define [ "../CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrDhcpModel"
    ### env:dev:end ###

    defaults : ()->
      "domain-name"          : []
      "domain-name-servers"  : []
      "ntp-servers"          : []
      "netbios-name-servers" : []
      "netbios-node-type"    : []

    constructor : ( attr, options )->
      attr = @tryParseDhcpAttr( attr )
      CrModel.call this, attr, options

    tryParseDhcpAttr : ( attr )->
      if attr.dhcpConfigurationSet
        # This is something that's returned from AWS
        try
          for item in attr.dhcpConfigurationSet.item
            attr[ item.key ] = item.valueSet
          delete attr.dhcpConfigurationSet
        catch e

      attr

    toAwsAttr : ()->
      awsAttr = []
      for key, value of @attributes
        if key isnt "id" and key isnt "tagSet" and (value.length > 0)
          awsAttr.push {
            Name  : key
            Value : value
          }
      awsAttr

    doCreate : ()->
      self = @
      @sendRequest("dhcp_CreateDhcpOptions", {dhcp_configs:@toAwsAttr()}).then ( res )->
        try
          id = res.CreateDhcpOptionsResponse.dhcpOptions.dhcpOptionsId
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Dhcp created but aws returns invalid ata." )

        self.set( "id", id )
        console.log "Created dhcp resource", self

        self

    doDestroy : ()-> @sendRequest("dhcp_DeleteDhcpOptions", {dhcp_id : @get("id")})

  }
