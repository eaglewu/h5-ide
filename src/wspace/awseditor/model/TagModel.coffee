
define [ "constant", "ComplexResModel", "GroupModel", "Design", "./connection/TagUsage"  ], ( constant, ComplexResModel, GroupModel, Design, TagUsage )->

  RetainTagKeys   = [ 'visualops', 'Name' ]

  TagItem = ComplexResModel.extend {
    type : "TagItem"

    isVisual: -> false

    initialize: ( attributes ) ->
      if attributes and attributes.inherit is undefined
        @unset 'inherit'

    serialize: ->
      _.extend {
        Key   : @get 'key'
        Value : @get 'value'
        ResourceIds: @genResourceIds()
      }, if @has('inherit') then { PropagateAtLaunch: @get('inherit') } else null

    genResourceIds: ->
      _.map @connectionTargets(), (resource) ->
        if resource.type is constant.RESTYPE.ASG
          refName = 'AutoScalingGroupName'
        else
          refName = constant.AWS_RESOURCE_KEY[ resource.type ]

        resource.createRef refName

    update: ( resources, key, value, inherit ) ->
      if key is @get 'key'
        @parent().removeTag resources, @
        @parent().addTag resources, key, value, inherit
      else
        result = @parent().addTag resources, key, value, inherit
        result or @parent().removeTag resources, @

  }, {
    deserialize: ( data, parent, resolve ) ->
      attr = key: data.Key, value: data.Value, inherit: data.PropagateAtLaunch

      if parent.get( 'name' ) isnt parent.constructor.customTagName then attr.retain = true
      tagItem = new TagItem attr

      parent.addChild tagItem

      for id in data.ResourceIds
        resource = resolve MC.extractID id
        continue unless resource

        new TagUsage resource, tagItem

      tagItem
  }




  # AsgTagModel will inherit TagModel, so method in TagModel must consider situation of AsgTagModel
  TagModel = GroupModel.extend {
    type: constant.RESTYPE.TAG

    isVisual: -> false

    serialize : ->
      resource = _.invoke (_.filter @all(), (item) -> !!item.connections().length), 'serialize'

      unless resource.length then return

      component :
        name    : @get("name")
        type    : @type
        uid     : @id
        resource: resource

    addTag: (resources, tagKey, tagValue = "", inherit) ->
      resources = [ resources ] unless _.isArray resources

      if @tagKeyExist(resources, tagKey)
        return error: "A tag with key '#{tagKey}' already exists"

      inherit = true if @type is constant.RESTYPE.ASGTAG and inherit is undefined
      inherit = undefined if @type is constant.RESTYPE.TAG

      tagItem = @find tagKey, tagValue, inherit
      tagItem = new TagItem( { key: tagKey, value: tagValue, inherit: inherit, __parent: @ } ) unless tagItem

      for resource in resources
        new TagUsage resource, tagItem

      null

    tagKeyExist: ( resources, tagKey ) ->
      if tagKey in RetainTagKeys then return true
      _.some resources, (resource) ->
        _.some resource.connectionTargets('TagUsage'), (tag) -> tag.get( 'key' ) is tagKey

    find: ( key, value, inherit ) ->
      prop = key: key
      prop.value = value if arguments.length > 1
      prop.inherit = inherit if arguments.length > 2 and inherit isnt undefined

      _.find @all(), (item) -> _.isEqual( item.pick( _.keys(prop) ), prop )

    removeTag: ( resources, tagItem ) ->
      resources = [ resources ] unless _.isArray resources

      for resource in resources
        (new TagUsage resource, tagItem).remove()

    all: -> _.filter @children(), ( tag ) -> !!tag.connections().length


  }, {
    handleTypes : [ constant.RESTYPE.TAG ]
    customTagName: 'EC2CustomTags'
    all: ->
      allTags = []
      AsgTagModel = Design.modelClassForType(constant.RESTYPE.ASGTAG)

      AsgTagModel.each ( model ) -> allTags = allTags.concat model.all()
      TagModel.each ( model ) -> allTags = allTags.concat model.all()

      allTags

    getCustom: ->
      customTag = @find (tag) => tag.get('name') is @customTagName
      customTag or new @ name: @customTagName

    deserialize : ( data, layout_data, resolve )->
      attr = {
        id    : data.uid
        name  : data.name
      }

      tagModel = new @( attr )

      for r in data.resource
        item = TagItem.deserialize r, tagModel, resolve

      null
  }

  TagModel
