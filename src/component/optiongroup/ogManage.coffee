define [ 'constant', 'CloudResources', 'toolbar_modal', './component/optiongroup/ogTpl', 'i18n!/nls/lang.js', 'event', 'UI.modalplus' ], ( constant, CloudResources, toolbar_modal, template, lang, ide_event, modalplus ) ->

    Backbone.View.extend

        events:

            'click .option-item .switcher': 'optionChanged'

        getModalOptions: ->
            title: "Edit Option Group"
            classList: 'option-group-manage'
            context: that

        initModal: (tpl) ->
            options =
                template        : tpl
                title           : "Edit Option Group"
                disableFooter   : true
                disableClose    : true
                width           : '855px'
                height          : '473px'
                compact         : true

            @__modalplus = new modalplus options
            @__modalplus.on 'closed', @close, @

        initialize: (option) ->

            optionCol = CloudResources(constant.RESTYPE.DBENGINE, Design.instance().region())
            engineOptions = optionCol.getEngineOptions(option.engine)
            @ogOptions = engineOptions[option.version] if engineOptions

            # option group data ready for engine and version
            if @ogOptions
                null

        render: ->
            @$el.html template.og_modal {}
            @renderModal()
            @

        renderModal: ->
            @initModal @el
            @


        processCol: () ->
            @renderList({})

        renderList: ( data ) ->
            @modal.setContent( template.modal_list data )

        renderNoCredential: () ->
            @modal.render('nocredential').toggleControls false

        renderSlides: ( which, checked ) ->
            tpl = template[ "slide_#{which}" ]
            slides = @getSlides()
            slides[ which ]?.call @, tpl, checked

        close: -> @remove()

        quickCreate: ->

        optionChanged: (event) ->

            $switcher = $(event.currentTarget)
            $switcher.toggleClass('on')