
define [ "../CrModel", "CloudResources", "constant" ], ( CrModel, CloudResources, constant )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrRdsParameterGroup"
    ### env:dev:end ###

    # defaults:
    #   "Description"            : ""
    #   "DBParameterGroupFamily" : ""
    #   "DBParameterGroupName"   : ""

    taggable : false

    isDefault : ()-> (@get("DBParameterGroupName") || "").indexOf("default.") is 0

    getParameters : ()-> CloudResources( @collection.credential(), constant.RESTYPE.DBPARAM, @id ).init( @ )

    doCreate : ()->
      self = @
      @sendRequest("rds_pg_CreateDBParameterGroup", {
        param_group        : @get("DBParameterGroupName")
        param_group_family : @get("DBParameterGroupFamily")
        description        : @get("Description")
      }).then ( res )->
        self.set( "id" , self.get("DBParameterGroupName") )
        self

    doDestroy : ()->
      @sendRequest("rds_pg_DeleteDBParameterGroup", {param_group : @id})

    resetParams : ()->
      self = @
      @sendRequest("rds_pg_ResetDBParameterGroup", {
        param_group : @id
        reset_all   : true
      }).then ()-> self.getParameters().fetchForce()

    modifyParams : ( paramNewValueMap )->
      ###
      paramNewValueMap = {
        "allow-suspicious-udfs" : 0
        "log_output" : "TABLE"
      }
      ###
      pArray = []
      for name, value of paramNewValueMap
        pArray.push {
          ParameterName  : name
          ParameterValue : value
          ApplyMethod    : @getParameters().get( name ).applyMethod()
        }

      requests = []
      params = {
        param_group : @id
        parameters  : []
      }
      i = 0
      while i < pArray.length
        params.parameters = pArray.slice(i, i+20)
        requests.push @sendRequest("rds_pg_ModifyDBParameterGroup", params)
        i+=20

      self = @
      parameters = self.getParameters()
      Q.all( requests ).then ()->
        for n, v of paramNewValueMap
          parameters.get(n).set("ParameterValue", v)
        return
  }
