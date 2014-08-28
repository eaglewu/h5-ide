
define [
  "./OpsEditorBase"
  "Design"
  "CloudResources"
  "constant"
], ( OpsEditorBase, Design, CloudResources, constant )->

  ###
    StackEditor is mainly for editing a stack
  ###
  class StackEditor extends OpsEditorBase

    title : ()-> (@design || @opsModel).get("name") + " - stack"

    isReady : ()->
      if @__hasAdditionalData then return true
      if not @opsModel.hasJsonData() or not @opsModel.isPersisted() then return false

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      CloudResources( constant.RESTYPE.AZ, region ).isReady()   &&
      CloudResources( constant.RESTYPE.SNAP, region ).isReady() &&
      CloudResources( constant.RESTYPE.DBENGINE, region ).isReady() &&
      CloudResources( constant.RESTYPE.DBOG, region ).isReady() &&
      CloudResources( constant.RESTYPE.DBSNAP,   region ).isReady() &&
      CloudResources( "QuickStartAmi",       region ).isReady() &&
      CloudResources( "MyAmi",               region ).isReady() &&
      CloudResources( "FavoriteAmi",         region ).isReady() &&
      !!App.model.getStateModule( stateModule.repo, stateModule.tag ) &&
      @hasAmiData()

    fetchAdditionalData : ()->
      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      jobs = [
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( constant.RESTYPE.AZ,   region ).fetch()
        CloudResources( constant.RESTYPE.SNAP, region ).fetch()
        CloudResources( "QuickStartAmi",       region ).fetch()
        CloudResources( "MyAmi",               region ).fetch()
        CloudResources( "FavoriteAmi",         region ).fetch()
        @fetchAmiData()
        @fetchRdsData()
      ]

      if not @opsModel.isPersisted() then jobs.unshift( @opsModel.save() )

      Q.all(jobs)

    hasAmiData : ()->
      json = @opsModel.getJsonData()
      cln  = CloudResources( constant.RESTYPE.AMI, @opsModel.get("region") )

      for uid, comp of json.component
        if comp.type is constant.RESTYPE.INSTANCE or comp.type is constant.RESTYPE.LC
          imageId = comp.resource.ImageId
          if imageId and not cln.get( imageId ) and not cln.isInvalidAmiId( imageId )
            return false

      true

    fetchAmiData : ()->
      json = @opsModel.getJsonData()
      toFetch = {}
      for uid, comp of json.component
        if comp.type is constant.RESTYPE.INSTANCE or comp.type is constant.RESTYPE.LC
          imageId = comp.resource.ImageId
          if imageId then toFetch[ imageId ] = true

      CloudResources( constant.RESTYPE.AMI, @opsModel.get("region") ).fetchAmis( _.keys toFetch )

    isRdsDisabled : ()-> !!@__disableRds
    fetchRdsData : ()->
      self   = @
      region = @opsModel.get("region")

      Q.all([
        CloudResources( constant.RESTYPE.DBENGINE, region ).fetchForce()
        CloudResources( constant.RESTYPE.DBOG,     region ).fetchForce()
        CloudResources( constant.RESTYPE.DBSNAP,   region ).fetchForce()
      ]).then ()->
        if self.__disableRds isnt false
          self.__disableRds = false
          self.trigger "toggleRdsFeature", true
      , ( error )->
        if error.awsErrorCode
          console.error "No authority to load rds data. Rds feature will be disabled.", error
          # Ignore rds api auth failure.
          self.__disableRds = true
          self.trigger "toggleRdsFeature", false
          return

        # Other reasons will consider as network error,
        # And will ask user to load ide again.
        throw error

    cleanup : ()->
      # Ask parent to cleanup first, so that removing opsModel won't trigger change event.
      OpsEditorBase.prototype.cleanup.call this

      # If the OpsModel doesn't exist in server, we would destroy it when the editor is closed.
      if not @opsModel.isPersisted()
        @opsModel.remove()
      return

    isModified : ()->
      if not @opsModel.isPersisted() then return true
      @design && @design.isModified()

  StackEditor
