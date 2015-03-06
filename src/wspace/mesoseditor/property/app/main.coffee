
define [ "Design"
         "../base/main"
         "./view"
         "constant"
         "CloudResources"
         "event"
], ( Design, PropertyModule, view, constant, CloudResources ) ->

    PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.MRTHAPP ]

        initStack : ( uid )->
            @view = view
            @model = Design.instance().component uid
            @view.isAppEdit = false
            null

        afterLoadStack : ()->

        initApp : ( uid ) ->
            @view = view
            @view.model = Design.instance().component uid
            @view.appData = null
            @view.isAppEdit = false

        initAppEdit : ( uid ) ->

    }
