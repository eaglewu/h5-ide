
define ["ApiRequest", "./CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  ### This Connection is used to fetch all the resource of an vpc ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOpsCollection"
    ### env:dev:end ###

    type  : "OpsResource"

    init : ( region )-> @__region = region; @

    # Fetches
    fetchForceDedup : ()->
      @__forceDedup = false
      p = @fetchForce()
      @__forceDedup = true
      p

    fetchForce : ()->
      if @__forceDedup
        @__forceDedup = false
        d = Q.defer()
        d.resolve()
        return d.promise

      @generatedJson = null
      CrCollection.prototype.fetchForce.call this

    doFetch : ()->
      # Before we do the fetch, we would want to clear everything in the CloudResources cache.
      self = @
      CloudResources.clearWhere ((m)-> m.RES_TAG is self.category), @__region

      console.assert( @__region, "CrOpsCollection's region is not set before fetching data. Need to call init() first" )
      ApiRequest("resource_vpc_resource", {
        region_name : @__region
        vpc_id      : @category
      })

    parseFetchData : ( data )->
      # OpsResource doesn't return anything, Instead, it injects the data to other collection.
      delete data.vpc

      # Parse aws resource data with other collection
      extraAttr = { RES_TAG : @category }
      for type, d of data
        cln = CloudResources( type, @__region )
        if not cln
          console.warn "Cannot find cloud resource collection for type:", type
          continue
        cln.__parseExternalData d, extraAttr, @__region

      if data.app_json
        @generatedJson = data.app_json
        delete data.app_json
        console.log "Generated Json from backend:", $.extend true, {}, @generatedJson
      else
        ### env:dev ###
        @generatedJson = @__generateJsonFromRes()
        console.log "Generated Json from frontend:", $.extend true, {}, @generatedJson
        ### env:dev:end ###

      return

    ### env:dev ###
    __generateJsonFromRes : ()->
      res = CloudResources.getAllResourcesForVpc( @__region, @category )
      json = {
        id          : ""
        name        : @category
        description : ""
        region      : @__region
        platform    : "ec2-vpc"
        state       : "Enabled"
        version     : "2014-02-17"
        component   : {}
        layout      : { size : [240, 240] }
        agent :
          enabled : true
          module  :
            repo : App.user.get("repo")
            tag  : App.user.get("tag")
        property :
          stoppable : true
      }
      json.component = res.component
      json.layout    = res.layout
      json.name      = "imported-" + @category
      return json
    ### env:dev:end ###

  }
