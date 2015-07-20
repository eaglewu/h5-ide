####################################
#  pop-up for component/trustedadvisor module
####################################

define [ 'jquery', 'event', 'component/trustedadvisor/gui/view', 'component/trustedadvisor/gui/model' ], ( $, ide_event, View, Model ) ->

    #private
    loadModule = ( type, status, differ ) ->

        #
        view  = new View()
        model = new Model()

        #view
        view.model    = model
        #
        view.on 'CLOSE_POPUP', () ->
            unLoadModule view, model

        processBar = ->
            ide_event.onLongListen ide_event.UPDATE_TA_MODAL, () ->
                console.log 'UPDATE_TA_MODAL'
            model.createList()
            view.render type, status

        processRun = (differ) ->
            deferred = Q.defer()
            ide_event.onListen ide_event.TA_SYNC_FINISH, () ->
                console.log 'TA_SYNC_FINISH'
                model.createList()
                view.render type, status
                if model.get('error_list').length is 0
                    deferred.resolve(model)
                else
                    deferred.reject(model)

            MC.ta.validRun( differ )

            deferred.promise

        ide_event.onLongListen ide_event.UNLOAD_TA_MODAL, () ->
            console.log 'UNLOAD_TA_MODAL'
            unLoadModule view, model

        if type is 'stack'
            view.closedPopup()
            return processRun( differ )
        else
            processBar()

    unLoadModule = ( view, model ) ->
        console.log 'trusted advisor run unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        #
        view  = null
        model = null
        #
        ide_event.offListen ide_event.UPDATE_TA_MODAL
        ide_event.offListen ide_event.UNLOAD_TA_MODAL
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
