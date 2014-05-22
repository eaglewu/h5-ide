
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrSnapshotModel"
    ### env:dev:end ###

    defaults :
      volumeId    : ""
      status      : "pending"
      startTime   : ""
      progress    : 0
      ownerId     : ""
      volumeSize  : 1
      description : ""
      name        : ""

    isComplete : ()-> @attributes.status is "completed"
    isPending  : ()-> @attributes.status is "pending"

    doCreate : ()->
      self = @
      ApiRequest("ebs_CreateSnapshot", {
        region_name  : @getCollection().region()
        volume_id    : @get("volumeId")
        description  : @get("description")
      }).then ( res )->
        try
          id = res.CreateSnapshotResponse.snapshotId
          delete res.requestId
          delete res["@attributes"]
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Snapshot created but aws returns invalid ata." )

        self.set res
        console.log "Created Snapshot resource", self

        self

    set : ( key, value )->
      if key.progress
        key.progress = parseInt( key.progress, 10 ) || 0
      if key.volumeSize
        key.volumeSize = parseInt( key.volumeSize, 10 ) || 1

      Backbone.Model.prototype.set.apply this, arguments
      return

    doDestroy : ()->
      ApiRequest("ebs_DeleteSnapshot", {
        region_name : @getCollection().region()
        dhcp_id : @get("id")
      })

    # Tags this resource. It should only called right after the resource is created.
    tagResource : ()->
      self = @
      ApiRequest("ec2_CreateTags", {
        region_name  : @getCollection().region()
        resource_ids : [@get("id")]
        tags         : [
          {Name:"Created by", Value:App.user.get("username")}
          {Name:"Name",       Value:@get("name")}
        ]
      }).then ()->
        console.log "Success to tag resource", self.get("id")
        return

  }
