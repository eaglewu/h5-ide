
define [ "./ResourceModel", "Design", "CanvasManager" ], ( ResourceModel, Design, CanvasManager )->

  ###
    -------------------------------
     ConnectionModel is the base class to implment a connection between two resources
    -------------------------------

    ++ Object Method ++

    setDestroyAfterInit()
      description : calling this method will cause the line to be removed after initialize()

    port1()
    port2()
      description : returns the name of the port, port1() is always smaller than port2()

    port1Comp()
    port2Comp()
      description : returns the component of each port

    getTarget : ( type )
      description : returns a component of a specific type

    getOtherTarget : ( theType )
      description : returns a component that its type is not of theType

    connectsTo : ( id )
      description : returns true if this connection connects to resource of id

    remove( option )
      description : remove the connection from two resources. Optional parameter `option` will be passed.
      `option.reason` will provided when the connection is removed due to one of its target is being removed.



    ++ Class Attributes ++

    type :
      description : A string to identify the Class

    portDefs :
      description : Ports defination for a visual line

    oneToMany :
      description : A type string.
      When C ( connection ) between A ( TYPEA ) and B ( TYPEB ) is created. If oneToMany is TYPEA, then previous B <=> TYPEA connection will be removed.



    ++ Class Method ++

    isConnectable( comp1, comp2 )
      description : This method is used to determine if user can create a line between two resources.
  ###

  connectionDraw = ()->
    if Design.instance().shouldDraw()
      CanvasManager.drawLine( @ )
    null

  ConnectionModel = ResourceModel.extend {

    node_line : true
    type      : "Framework_CN"

    constructor : ( p1Comp, p2Comp, attr, option ) ->

      if not option or option.detectDuplicate isnt false
        # Detect if we have already created the same connection between p1Comp, p2Comp
        cns = Design.modelClassForType( @type ).allObjects()
        cn = Design.modelClassForType( @type ).findExisting( p1Comp, p2Comp )
        if cn
          console.info "Found existing connection #{@type} of ", [p1Comp, p2Comp]
          return cn

      if @portDefs

        for def in @portDefs
          if def.port1.type is p1Comp.type and def.port2.type is p2Comp.type
            @__portDef   = def
            @__port1Comp = p1Comp
            @__port2Comp = p2Comp
            break
          else if def.port1.type is p2Comp.type and def.port2.type is p1Comp.type
            @__portDef   = def
            @__port1Comp = p2Comp
            @__port2Comp = p1Comp
            break

        console.assert( @__portDef, "Cannot create connection!" )

      else
        # If there's no portDefs, we directly assign the parameter to this
        @__port1Comp = p1Comp
        @__port2Comp = p2Comp


      # Call super constructor
      ResourceModel.call(this, attr, option)


      # The line wants to destroy itslef after init
      if @__destroyAfterInit
        @remove( this )
        return this


      # If oneToMany is defined. Then one of the component of this connection should be
      # checked.
      if @oneToMany
        console.assert( @oneToMany is @port1Comp().type or @oneToMany is @port2Comp().type, "Invalid oneToMany parameter" )
        comp = @getOtherTarget( @oneToMany )
        for cn in comp.connections( @type )
          cn.remove()


      @__port1Comp.connect_base this
      if @__port1Comp isnt @__port2Comp
        @__port2Comp.connect_base this


      # Draw in the end
      if @draw then @draw()

      this

    setDestroyAfterInit : ()->
      @__destroyAfterInit = true
      null

    port : ( id, attr )->
      if not @__portDef then return ""

      if @__port1Comp is id or @__port1Comp.id is id
        return @__portDef.port1[ attr ]

      if @__port2Comp is id or @__port2Comp.id is id
        return @__portDef.port2[ attr ]

      return ""

    port1 : ( attr )->
      if @__portDef then @__portDef.port1[ attr ] else ""
    port2 : ( attr )->
      if @__portDef then @__portDef.port2[ attr ] else ""

    connectsTo : ( id )->
      ( @__port1Comp && @__port1Comp.id is id ) or ( @__port2Comp && @__port2Comp.id is id )

    port1Comp : ()-> @__port1Comp
    port2Comp : ()-> @__port2Comp

    getOtherTarget : ( type )->
      if not _.isString type
        if @__port1Comp is type
          return @__port2Comp
        else
          return @__port1Comp

      else
        if @__port1Comp.type is type
          return @__port2Comp
        else
          return @__port1Comp

    getTarget : ( type )->
      if @__port1Comp.type is type
        return @__port1Comp

      if @__port2Comp.type is type
        return @__port2Comp

      null

    remove : ( option )->

      if @isRemoved() then return

      reason = if option then option.reason
      reason = reason or null

      # If the connection is removed because a resource is removed, that resource's disconnect will not be called
      if @__port1Comp isnt reason
        @__port1Comp.disconnect_base( this, reason )
      if @__port1Comp isnt @__port2Comp and @__port2Comp isnt reason
        @__port2Comp.disconnect_base( this, reason )

      # Remove element in SVG, if the line implements draw
      if @draw
        CanvasManager.remove( document.getElementById( @id ) )
      null

    serialize : ()->
      # Most of the connection don't have to implement serialize()
      null

  }, {

    findExisting : ( p1Comp, p2Comp )->
      for cn in @allObjects()
        if cn.port1Comp() is p1Comp and cn.port2Comp() is p2Comp
          return cn
        if cn.port2Comp() is p1Comp and cn.port1Comp() is p2Comp
          return cn
      null

    extend : ( protoProps, staticProps )->

      tags = []

      if protoProps.portDefs
        if not _.isArray( protoProps.portDefs )
          protoProps.portDefs = [ protoProps.portDefs ]

        # Ensure port1 is always smaller than port2
        for def in protoProps.portDefs
          if def.port1.name > def.port2.name
            tmp = def.port1
            def.port1 = def.port2
            def.port2 = tmp

          tags.push def.port1.name + ">" + def.port2.name

        if not protoProps.type then protoProps.type = tags[0]

      # If we have portDefs, then it's considered to be visual line
      # But the subclass can also set visual to false,
      # to indicate this is not a visual line.
      # If it's visual, insert a draw() into it.
      if protoProps.portDefs and protoProps.defaults
        ### env:dev ###
        if protoProps.draw and protoProps.draw.toString().indexOf(".shouldDraw") is -1
            console.error "Subclass of connection's draw() method does not check Design.instance().shouldDraw()"
        ### env:dev:end ###

        if _.result( protoProps, "defaults" ).visual is false
          delete protoProps.draw
        else if not protoProps.draw
          protoProps.draw = connectionDraw


      child = ResourceModel.extend.call( this, protoProps, staticProps )

      for t in tags
        Design.registerModelClass t, child

      Design.registerModelClass protoProps.type, child

      child

    isConnectable : ( comp1, comp2 )-> true
  }

  ConnectionModel

