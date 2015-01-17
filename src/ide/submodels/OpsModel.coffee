
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["ApiRequest", "constant", "CloudResources", "ThumbnailUtil", "backbone"], ( ApiRequest, constant, CloudResources, ThumbUtil )->

  KnownOpsModelClass = {}

  OpsModelType =
    OpenStack : "OpenstackOps"
    Amazon    : "AwsOps"

  OpsModelState =
    UnRun        : 0
    Running      : 1
    Stopped      : 2
    Initializing : 3
    Starting     : 4
    Updating     : 5
    Stopping     : 6
    Terminating  : 7
    Destroyed    : 8 # When OpsModel changes to this State, it doesn't trigger "change:state" event, instead, it triggers "destroy" event and its collection will trigger "update" event.
    Saving       : 9

  OpsModelStateDesc = ["", "Running", "Stopped", "Starting", "Starting", "Updating", "Stopping", "Terminating", "", "Saving"]

  OpsModelLastestVersion = "2014-11-11"

  OpsModel = Backbone.Model.extend {

    type : "GenericOps"

    defaults : ()->
      updateTime : +(new Date())
      region     : ""
      state      : OpsModelState.UnRun
      stoppable  : true # If the app has instance_store_ami, stoppable is false
      name       : ""
      version    : OpsModelLastestVersion
      provider   : ""

      # usage          : ""
      # terminateFail  : false
      # progress       : 0
      # opsActionError : ""
      # importMsrId    : ""
      # requestId      : ""

    constructor : ( attr, opts )->
      attr = attr || {}
      opts = opts || {}

      if this.type is "GenericOps"
        if opts.jsonData
          provider = opts.jsonData.provider

        attr.provider = provider || attr.provider || "aws::global" # Set default provider

        console.assert( KnownOpsModelClass[attr.provider], "Cannot find specific OpsModel for provider '#{attr.provider}'" )

        Model = KnownOpsModelClass[ attr.provider ]
        if Model
          return new Model( attr, opts )

      Backbone.Model.apply this, arguments

    initialize : ( attr, options )->
      if options
        if options.initJsonData
          @__initJsonData()
        if options.jsonData
          @__setJsonData options.jsonData

      ### env:dev ###
      @listenTo @, "change:state", ()-> console.log "OpsModel's state changed", @, MC.prettyStackTrace()
      ### env:dev:end ###
      ### env:debug ###
      @listenTo @, "change:state", ()-> console.log "OpsModel's state changed", @, MC.prettyStackTrace()
      ### env:debug:end ###
      return

    # Returns the project to which this opsmodel belongs.
    project : ()->
      for p in App.model.get("projects")
        ops = p.stacks().get( @ ) or p.apps().get( @ )
        if ops then return p
      return null

    url : ()->
      p = @project() || ""
      if p then p = p.get("id")

      if @get("id")
        "project/#{p}/ops/#{@get('id')}"
      else
        "project/#{p}/unsaved/#{@cid}"

    isStack    : ()-> @attributes.state is   OpsModelState.UnRun || @attributes.state is OpsModelState.Saving
    isApp      : ()-> !@isStack()
    isImported : ()-> !!@attributes.importMsrId

    # Payment restricted
    isPMRestricted : ()-> @get("version") >= "2014-11-11" and @isApp()

    testState : ( state )-> @attributes.state is state
    getStateDesc : ()-> OpsModelStateDesc[ @attributes.state ]

    # Returns a plain object to represent this model.
    # If you want to access the JSON of the stack/app, use getJsonData() instead.
    toJSON : ( options )->
      o = Backbone.Model.prototype.toJSON.call( this )
      o.stateDesc  = OpsModelStateDesc[ o.state ]
      o.regionName = constant.REGION_SHORT_LABEL[ o.region ]
      if @isProcessing() then o.progressing = true

      if options
        if options.thumbnail
          o.thumbnail = ThumbUtil.fetch(o.id)
      o

    # Return true if the stack is saved in the server.
    isPersisted : ()-> !!@get("id")
    # Return true if the stack/app should be show to the user.
    isExisting : ()->
      state = @get("state")
      if state is OpsModelState.Destroyed
        console.warn "There's probably a bug existing that the destroyed opsmodel is still be using by someone."

      !!(@get("id") && state isnt OpsModelState.Destroyed)

    # Get the Most Significant Resource id.
    getMsrId : ()-> @get("importMsrId") || undefined

    getThumbnail  : ()-> ThumbUtil.fetch(@get("id"))
    saveThumbnail : ( thumb )->
      if thumb
        ThumbUtil.save( @get("id"), thumb )
        @trigger "change"
      else
        ThumbUtil.save( @get("id"), "" )
      return

    hasJsonData : ()-> !!@__jsonData
    getJsonData : ()-> @__jsonData
    fetchJsonData : ()->
      if @__jsonData
        d = Q.defer()
        d.resolve @
        return d.promise

      @__fjdImport( @ ) || @__fjdStack( @ ) || @__fjdApp( @ )

    __fjdImport : ( self )->
      if not @isImported() then return

      CloudResources( "OpsResource", @getMsrId() ).init( @get("region"), @get("provider") ).fetchForceDedup().then ()-> self.__onFjdImported()

    generateJsonFromRes : ()->
      json = CloudResources( 'OpsResource', @getMsrId() ).generatedJson
      if not json.agent.module.repo
        json.agent.module =
          repo : App.user.get("repo")
          tag  : App.user.get("tag")
      json

    __onFjdImported : ()->
      json = @generateJsonFromRes()
      @__setJsonData json
      @attributes.name = json.name
      @

    __fjdStack : ( self )->
      if not @isStack() then return
      ApiRequest("stack_info", {
        region_name : @get("region")
        stack_ids   : [@get("id")]
      }).then (ds)-> self.__setJsonData( ds[0] )

    __fjdApp : ( self )->
      if not @isApp() then return
      ApiRequest("app_info", {
        region_name : @get("region")
        app_ids     : [@get("id")]
      }).then (ds)-> self.__setJsonData( ds[0] )

    __setJsonData : ( json )->

      if not json
        @__destroy()
        throw new McError( ApiRequest.Errors.MissingDataInServer, "Stack/App doesn't exist." )

      if not json.agent
        json.agent = {
          enabled : false
          module  : {
            repo : App.user.get("repo")
            tag  : App.user.get("tag")
          }
        }
      if not json.property
        json.property = { stoppable : true }

      ###
      Old JSON will have structure like :
      layout : {
        component : { node : {}, group : {} }
        size : []
      }
      New JSON will have structure like :
      layout : {
        xxx  : {}
        size : []
      }
      ###
      if json.layout and json.layout.component
        newLayout      = $.extend {}, json.layout.component.node, json.layout.component.group
        newLayout.size = json.layout.size
        json.layout    = newLayout

      if json.layout and not json.layout.size
        json.layout.size = [240, 240]

      # Normalize stack version in case some old stack is not using date as the version
      # The version will be updated after serialize
      if (json.version or "").split("-").length < 3 then json.version = OpsModelLastestVersion

      if not json.provider and @get("provider")
        json.provider = @get("provider")

      @__jsonData = json

      if @attributes.name isnt json.name
        @set "name", json.name

      @

    # Save the stack in server, returns a promise
    save : ( newJson, thumbnail )->
      if @isApp() or @testState( OpsModelState.Saving ) then return @__returnErrorPromise()

      if not newJson then newJson = @__jsonData

      @set "state", OpsModelState.Saving

      nameClash = @collection.where({name:newJson.name}) || []
      if nameClash.length > 1 or (nameClash[0] and nameClash[0] isnt @)
        d = Q.defer()
        d.reject(McError( ApiRequest.Errors.StackRepeatedStack, "Stack name has already been used." ))
        return d.promise

      api = if @get("id") then "stack_save" else "stack_create"

      if newJson.state isnt "Enabled"
        console.warn "The json's state isnt `Enabled` when saving the stack", @, newJson
        newJson.state = "Enabled"

      newJson.id = @get("id")

      self = @
      ApiRequest(api, {
        region_name : @get("region")
        spec        : newJson
      }).then ( res )->

        attr = {
          name       : newJson.name
          version    : newJson.version
          updateTime : +(new Date())
          stoppable  : res.property.stoppable
          state      : OpsModelState.UnRun
        }

        if not self.get("id")
          attr.id = res.id

        if thumbnail then ThumbUtil.save( self.get("id") || attr.id, thumbnail )

        self.set attr
        self.__jsonData = res
        self.trigger "jsonDataSaved", self

        # The stack is a newly created stack. We would like to trigger "update" in the collection
        # So that other's can update their view.
        if attr.id then self.collection.__triggerUpdate self

        return self
      , ( err )->
        self.set "state", OpsModelState.UnRun
        throw err

    # Delete the stack in server, returns a promise
    remove : ()->
      if @isPersisted() and @isApp() then return @__returnErrorPromise()

      @__destroy()

      if not @get("id")
        d = Q.defer()
        d.resolve()
        return d.promise

      self = @
      ApiRequest("stack_remove",{
        region_name : @get("region")
        stack_id    : @get("id")
      }).fail ()->
        @set "state", OpsModelState.UnRun
        # If we cannot delete the stack, we just add it back to the stackList.
        App.model.stackList().add self

    # Runs a stack into app, returns a promise that will fullfiled with a new OpsModel.
    run : ( toRunJson, appName )->
      region = @get("region")

      # Ensure the json has correct id.
      toRunJson.id = @get("id") || ""

      ApiRequest("stack_run_v2",{
        region_name : region
        stack       : toRunJson
        app_name    : appName
      }).then ( res )->
        m = new OpsModel({
          name          : appName
          requestId     : res[0]
          state         : OpsModelState.Initializing
          progress      : 0
          region        : region
          provider      : toRunJson.provider
          usage         : toRunJson.usage
          version       : toRunJson.version
          updateTime    : +(new Date())
          stoppable     : toRunJson.property.stoppable
          resource_diff : false
        })
        App.model.appList().add m
        m

    # Duplicate the stack
    duplicate : ( name )->
      if @isApp() then return

      thumbnail  = ThumbUtil.fetch(@get("id"))
      attr       = $.extend true, {}, @attributes, {
        name       : name
        updateTime : +(new Date())
        provider   : @get("provider")
      }
      collection = @collection

      ApiRequest("stack_save_as",{
        region_name : @get("region")
        stack_id    : @get("id")
        new_name    : name || @collection.getNewName()
      }).then ( id )->
        if thumbnail then ThumbUtil.save id, thumbnail
        attr.id = id
        collection.add( new OpsModel(attr) )

    # Stop the app, returns a promise
    stop : ()->
      if not @isApp() or @get("state") isnt OpsModelState.Running then return @__returnErrorPromise()

      self = @
      @set "state", OpsModelState.Stopping
      @attributes.progress = 0
      ApiRequest("app_stop",{
        region_name : @get("region")
        app_id      : @get("id")
        app_name    : @get("name")
      }).fail ( err )->
        self.set "state", OpsModelState.Running
        throw err

    start : ()->
      if not @isApp() or @get("state") isnt OpsModelState.Stopped then return @__returnErrorPromise()
      self = @
      @set "state", OpsModelState.Starting
      @attributes.progress = 0
      ApiRequest("app_start",{
        region_name : @get("region")
        app_id      : @get("id")
        app_name    : @get("name")
      }).fail ( err )->
        self.set "state", OpsModelState.Stopped
        throw err

    # Terminate the app, returns a promise
    terminate : ( force = false , extraOption )->
      if not @isApp() then return @__returnErrorPromise()
      oldState = @get("state")
      @set("state", OpsModelState.Terminating)
      @attributes.progress = 0
      @attributes.terminateFail = false
      self = @

      options = $.extend {
        region_name     : @get("region")
        app_id          : @get("id")
        app_name        : @get("name")
        flag            : force
      }, ( extraOption || {} )

      ApiRequest("app_terminate", options).then ()->
        # Force Termination will immediately returns sucess / failure.
        # Normal Termination will returns its status by Websockt.
        if force then self.__destroy()
        return
      , ( err )->
        if err.error < 0
          throw err

        self.set {
          state         : oldState
          terminateFail : true
        }
        throw err

    # Update the app, returns a promise
    update : ( newJson, fastUpdate )->
      if not @isApp() then return @__returnErrorPromise()
      if @__updateAppDefer
        console.error "The app is already updating!"
        return @__updateAppDefer.promise

      oldState = @get("state")
      @set("state", OpsModelState.Updating)
      @attributes.progress = 0

      @__updateAppDefer = Q.defer()

      self = @

      # Send Request
      ApiRequest("app_update", {
        region_name : @get("region")
        spec        : newJson
        app_id      : @get("id")
        fast_update : fastUpdate
      }).fail ( error )-> self.__updateAppDefer.reject( error )

      errorHandler = ( error )->
        self.__updateAppDefer = null
        self.attributes.progress = 0
        self.set { state : oldState }
        throw error

      # The real promise
      @__updateAppDefer.promise.then ()->
        self.__jsonData = null
        self.fetchJsonData().then ()->
          self.__updateAppDefer = null
          self.importMsrId = undefined # Mark as not imported once we've finish saving.
          self.set {
            name  : newJson.name
            state : OpsModelState.Running
          }
        , errorHandler
      , errorHandler

    # Replace the data in mongo with new data. This method doesn't trigger an app update.
    saveApp : ( newJson )->
      if not @isApp() then return @__returnErrorPromise()
      if @__saveAppDefer
        console.error "The app is already saving!"
        return @__saveAppDefer.promise

      newJson.changed = false

      if newJson.state isnt @getStateDesc()
        console.warn "The new app json's state isnt the same as the app", @, newJson
        newJson.state = @getStateDesc()

      # Ensure we have correct id in the json.
      console.assert ((newJson.id || "").indexOf("stack-") is -1), "The newJson has wrong appid, in saveApp()"
      if newJson.id
        if newJson.id isnt @get("id")
          console.warn "The newJson has different id, in saveApp()"
        newJson.id = @get("id")
      else
        newJson.id = ""

      oldState = @get("state")
      @set("state", OpsModelState.Saving)
      @attributes.progress = 0

      @__saveAppDefer = Q.defer()

      self = @

      # Send Request
      ApiRequest("app_save_info", {spec:newJson}).then (res)->
        if not self.id
          self.attributes.requestId = res[0]
        self.attributes.importMsrId = undefined
        return
      , ( error )->
        self.__saveAppDefer.reject( error )

      # The real promise
      @__saveAppDefer.promise.then ()->
        self.__jsonData = newJson
        self.attributes.requestId = undefined
        self.__saveAppDefer = null

        self.set {
          name  : newJson.name
          state : oldState
          usage : newJson.usage
        }
        return
      , ( error )->
        self.__saveAppDefer = null
        self.attributes.requestId = undefined
        self.attributes.progress = 0
        self.set { state : oldState }
        throw error


    setStatusProgress : ( steps, totalSteps )->
      progress = parseInt( steps * 100.0 / totalSteps )
      if @.attributes.progress != progress
        # Disable Backbone's auto triggering change event. Because I don't wan't that changing progress will trigger `change:progress` and `change`
        @attributes.progress = progress
        @trigger "change:progress", @, progress
      return

    isProcessing : ()->
      state = @attributes.state
      state is OpsModelState.Initializing || state is OpsModelState.Stopping || state is OpsModelState.Updating || state is OpsModelState.Terminating || state is OpsModelState.Starting || state is OpsModelState.Saving

    setStatusWithWSEvent : ( operation, state, error )->
      console.info "OpsModel's state changes due to WS event:", operation, state, error, @
      # operation can be ["launch", "stop", "start", "update", "terminate"]
      # state can have "completed", "failed", "progressing", "pending"
      switch operation
        when "launch"
          if state.completed
            toState = OpsModelState.Running
          else if state.failed
            toState = OpsModelState.Destroyed
        when "stop"
          if state.completed
            toState = OpsModelState.Stopped
          else if state.failed
            toState = OpsModelState.Running
        when "update"
          if not @__updateAppDefer
            console.warn "UpdateAppDefer is null when setStatusWithWSEvent with `update` event."
            return

          if not state.completed
            d = @__updateAppDefer
            @__updateAppDefer = null
            d.reject McError( ApiRequest.Errors.OperationFailure, error )
          else
            # Grab new json from server after app update succeeded.
            @__jsonData = null
            self = @
            @fetchJsonData().then ()->
              d = self.__updateAppDefer
              self.__updateAppDefer = null
              d.resolve()
          return

        when "save" # This is saving app.
          if not @__saveAppDefer
            console.warn "SaveAppDefer is null when setStatusWithWSEvent with `save` event."
            return

          d = @__saveAppDefer
          @__saveAppDefer = null

          if state.completed
            d.resolve()
          else
            d.reject McError( ApiRequest.Errors.OperationFailure, error )
          return

        when "terminate"
          if state.completed
            toState = OpsModelState.Destroyed
          else
            toState = OpsModelState.Stopped
            @attributes.terminateFail = false
            @set "terminateFail", true
        when "start"
          if state.completed
            toState = OpsModelState.Running
          else
            toState = OpsModelState.Stopped

      if error
        @attributes.opsActionError = error

      if toState is OpsModelState.Destroyed
        @__destroy()

      else if toState
        @attributes.progress = 0
        @set "state", toState
      return


    ###
     Internal Methods
    ###
    # Overriden model methods so that user won't call it acidentally
    destroy : ()->
      console.info "OpsModel's destroy() doesn't do anything. You probably want to call remove(), stop() or terminate()"

    __destroy : ()->
      if @attributes.state is OpsModelState.Destroyed
        return

      # Remove thumbnail
      ThumbUtil.remove( @get("id") )

      # Cleanup CloudResources if we are an app
      msrId = @getMsrId()
      if msrId
        CloudResources( "OpsResource", msrId )?.destroy()

      # Directly modify the attr to avoid sending an event, becase destroy would trigger an update event
      @attributes.state = OpsModelState.Destroyed
      @trigger 'destroy', @, @collection

    __returnErrorPromise : ()->
      d = Q.defer()
      d.resolve McError( ApiRequest.Errors.InvalidMethodCall, "The method is not supported by this model." )
      d.promise

    # This method init a json for a newly created stack.
    __createRawJson : ()->
      id          : @get("id") or ""
      name        : @get("name")
      description : ""
      region      : @get("region")
      platform    : "ec2-vpc"
      state       : "Enabled"
      version     : @get("version")
      resource_diff: true
      component   : {}
      provider    : @get("provider")
      layout      : { size : [240, 240] }
      agent       :
        enabled : true
        module  :
          repo : App.user.get("repo")
          tag  : App.user.get("tag")
      property :
        stoppable : true

    __initJsonData : ()-> @__jsonData = @__createRawJson(); return
  }, {
    extend : ( protoProps, staticProps ) ->

      # Create subclass
      subClass = (window.__detailExtend || Backbone.Model.extend).call( this, protoProps, staticProps )

      for provider in staticProps.supportedProviders
        KnownOpsModelClass[ provider ] = subClass

      subClass
  }

  OpsModel.Type  = OpsModelType
  OpsModel.State = OpsModelState
  OpsModel.LatestVersion = OpsModelLastestVersion

  OpsModel
