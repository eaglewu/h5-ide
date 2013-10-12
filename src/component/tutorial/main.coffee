####################################
#  pop-up for component/tutorial module
####################################

define [ 'jquery', 'event',
         'text!./template.html'
], ( $, ide_event, template ) ->

    #private
    loadModule = () ->

        #
        require [ './component/tutorial/view', './component/tutorial/model' ], ( View, Model ) ->

            #
            view  = new View()
            model = new Model()

            #view
            view.model    = model
            #
            view.on 'CLOSE_POPUP', () ->
                unLoadModule view, model

            #render
            view.render template

            #
            model.updateAccountService()  if MC.forge.cookie.getCookieByName( 'state' ) is '3'

    unLoadModule = ( view, model ) ->
        console.log 'stack run unLoadModule'
        view.off()
        model.off()
        view.undelegateEvents()
        #
        view  = null
        model = null
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule