####################################
#  Controller for design/property/dbinstance module
####################################

define [
         "Design"
         "CloudResources"
         "../base/main"
         "./model"
         "./view"
         "./app_view"
         "../sglist/main"
         "constant"
         "event"
], ( Design,
     CloudResources,
     PropertyModule,
     model,
     view,
     app_view,
     sglist_main, constant ) ->

    DBInstanceModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.DBINSTANCE ]

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        setupStack : () ->
            null

        initStack : ( uid )->

            @view = view
            @model = model
            @view.resModel = Design.instance().component uid
            @view.isAppEdit = false
            null

        afterLoadStack : ()->
            sglist_main.loadModule @model
            null

        setupApp : () ->
            null

        initApp : ( uid ) ->

            resModel = Design.instance().component uid

            if resModel.serialize().component.resource.ReadReplicaSourceDBInstanceIdentifier
              uid = resModel.serialize().component.resource.ReadReplicaSourceDBInstanceIdentifier.split(".")[0].split('{').pop()

            @model = (CloudResources(Design.instance().credentialId(), constant.RESTYPE.DBINSTANCE, Design.instance().region()).get resModel.get('appId')) || (CloudResources(Design.instance().credentialId(), constant.RESTYPE.DBSNAP, Design.instance().region()).get resModel.get('snapshotId')) || resModel
            @view = app_view
            @view.model = @model
            @view.resModel = resModel
            @view.isAppEdit = false
            null

        initAppEdit : ( uid ) ->

            resModel = Design.instance().component uid
            @view = view
            @model = model
            @view.resModel = resModel

            originJson = Design.instance().__opsModel.getJsonData()
            view.originComp = originJson.component[resModel.id]

            if resModel.get('appId')
                @view.isAppEdit = true
                @view.appModel = CloudResources(Design.instance().credentialId(), constant.RESTYPE.DBINSTANCE, Design.instance().region()).get resModel.get('appId')
            else
                @view.isAppEdit = false
            null

        afterLoadAppEdit : ()->
            sglist_main.loadModule @view.resModel
            null

        afterLoadApp : () ->
            sglist_main.loadModule @view.resModel
            null
    }
    null

    DBInstanceModule
