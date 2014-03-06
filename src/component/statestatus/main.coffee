####################################
#  pop-up for component/statestatus module
####################################

define [ 'jquery', 'event', './component/statestatus/view', './component/statestatus/model' ], ( $, ide_event, View, Model ) ->

    model = null
    view = null

    # Private
    loadModule = ->

        model = new Model()
        view  = new View model: model

        view.on 'CLOSE_POPUP', @unLoadModule, @

        ide_event.onLongListen ide_event.UPDATE_STATE_STATUS_DATA, model.listenStateStatusUpdate, model
        ide_event.onLongListen 'STATE_EDITOR_DATA_UPDATE', model.listenStateEditorUpdate, model
        ide_event.onLongListen ide_event.UPDATE_APP_STATE, model.listenUpdateAppState, model

        view.render()
        # test
        window.ide_event = ide_event

    unLoadModule = ->

        view.remove()
        model.destroy()
        ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA, model.listenStateStatusUpdate
        ide_event.offListen 'STATE_EDITOR_DATA_UPDATE'
        ide_event.onLongListen ide_event.UPDATE_APP_STATE, model.listenUpdateAppState


    # Public
    loadModule   : loadModule
    unLoadModule : unLoadModule

