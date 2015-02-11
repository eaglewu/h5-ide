# Combo Dropdown
# Return Backbone.View object

# Usage:
# 1. import this component
# 2. new toolbar_modal()
# 3. bind `slideup`, `slidedown`, `refresh` event
# 4. fill the content and selection

### Example:
Refer to kpView.coffee

###

define [ 'component/common/toolbarModalTpl', 'backbone', 'jquery', 'UI.modalplus', 'UI.notification' ], ( template, Backbone, $, modalplus ) ->


    Backbone.View.extend

        tagName: 'section'

        __slide: null

        __modalplus: null

        events:
            'change #t-m-select-all'        : '__checkAll'
            'change .one-cb'                : '__checkOne'

            'click .t-m-btn'                : '__handleSlide'
            'click tr .show-detail'         : '__handleDetail'
            'click .cancel'                 : 'cancel'

            'click .do-action'              : '__doAction'
            'click [data-btn=refresh]'      : '__refresh'

            'click .table-head .sortable'   : '__sort'
            'click .show-credential'        : '__showCredential'

        initialize: ( options ) ->
            @options = options or {}
            @options.title = 'Default Title' if not @options.title
            if options.context
                @options.context.modal = @
                @options.context.M$ = _.bind @$, @
            null

        __showCredential: ->
            Design.instance()?.project().showCredential()

        __sort: ->
            # detail tr will disturb the sort, so details must be removed when sort trigger
            @$( '.tr-detail' ).remove()

        __doAction: ( event ) ->
            @error()
            action = $( event.currentTarget ).data 'action'
            @trigger 'action', action, @getChecked()


        getChecked: () ->
            allChecked = @$('.one-cb:checked')
            checkedInfo = []
            allChecked.each () ->
                checkedInfo.push id: @id, value: @value, data: $(@).data()

            checkedInfo

        __slideReject: ->
            _.isFunction( @options.slideable ) and not @options.slideable()

        __handleSlide: ( event ) ->

            $button = $ event.currentTarget
            button = $button.data 'btn'

            # refresh has no slide
            if button is 'refresh'
                return @

            if @__slideReject()
                return @

            $activeButton = @$( '.toolbar .active' )
            activeButton = $activeButton and $activeButton.data 'btn'


            # has active button
            if $activeButton.length
                # slide up
                if $activeButton.get( 0 ) is $button.get( 0 )
                    if @options.longtermActive then return
                    $button.removeClass 'active'
                    @toggleSlide false
                    @__slide = null
                    @trigger 'slideup', button, @getChecked()
                #slide down
                else
                    $activeButton.removeClass 'active'
                    $button.addClass 'active'
                    @toggleSlide true
                    @__slide = button
                    @trigger 'slidedown', button, @getChecked()

            else
                $button.addClass 'active'
                @toggleSlide true
                @__slide = button
                @trigger 'slidedown', button, @getChecked()

            null


        __handleDetail: ( event ) ->
            $target = $ event.currentTarget
            $tr = $target.closest 'tr'
            if $tr.hasClass 'detailed'
                $tr.removeClass 'detailed'
                $tr.next('.tr-detail').remove()
            else
                $tr
                    .addClass( 'detailed' )
                    .after template.tr_detail columnCount: @options.columns.length + 1
                @trigger 'detail', event, $tr.data(), $tr


        __refresh: ->
            if @__slideReject()
                return @
            @renderLoading()
            @trigger 'refresh'

        __close: ( event ) ->
            #$( '#modal-wrap' ).off 'click', @__stopPropagation
            @trigger 'close'
            @remove()
            false

        __checkOne: ( event ) ->
            $target = $ event.currentTarget
            @__processDelBtn()
            cbAll = @$ '#t-m-select-all'
            cbAmount = @$('.one-cb').length
            checkedAmount = @$('.one-cb:checked').length
            $target.closest('tr').toggleClass 'selected'

            if checkedAmount is cbAmount
                cbAll.prop 'checked', true
            else if cbAmount - checkedAmount is 1
                cbAll.prop 'checked', false

            @__triggerChecked event

        __checkAll: ( event ) ->
            @__processDelBtn()
            if event.currentTarget.checked
                @$('input[type="checkbox"]:not(:disabled)').prop 'checked', true
                .parents('tr.item').addClass 'selected'
            else
                @$('input[type="checkbox"]').prop 'checked', false
                @$('tr.item').removeClass 'selected'

            @__triggerChecked event

        __triggerChecked: ( param ) ->
            @trigger 'checked', param, @getChecked()

        __processDelBtn: ( enable ) ->
            if arguments.length is 1
                @$('[data-btn=delete]').prop 'disabled', not enable
            else
                that = @
                _.defer () ->
                    if that.$('.one-cb:checked').length
                        that.$('[data-btn=delete]').prop 'disabled', false
                    else
                        that.$('[data-btn=delete]').prop 'disabled', true

        __stopPropagation: ( event ) ->
            exception = '.sortable, #download-kp, .selection, .item'
            if not $(event.target).is( exception )
                event.stopPropagation()

        __open: () ->
            options =
                template        : @el
                title           : @options.title
                disableFooter   : true
                disableClose    : true
                width           : '855px'
                height          : '473px'
                compact         : true
                hasScroll       : true
                mode            : "panel"

            @__modalplus = new modalplus options
            @__modalplus.on 'closed', @__close, @
            @__modalplus.on "resize", @__resizeModal.bind @
            @

        __getHeightOfContent: ->
          windowHeight = $(window).height()
          $modal= @__modalplus.tpl
          headerHeight= $modal.find(".modal-header").outerHeight()
          footerHeight = $modal.find('.modal-footer').height() || 0
          windowHeight - headerHeight - footerHeight - 75 # 75 for toolbarHeight + Table HeaderBar Height

        __resizeModal: ->
          that = @
          @__modalplus.tpl.find(".scrollbar-veritical-thumb").removeAttr("style")
          scroll = @__modalplus.tpl.find(".table-head-fix.will-be-covered .scroll-wrap")
          scroll = if scroll.size() > 0 then scroll else @__modalplus.find('.will-be-covered>div')
          if scroll.size() then scroll.height(that.__getHeightOfContent())


        __renderToolbarSlide: ()->
            that = @
            $contentWrap = @$ '.content-wrap'
            if not $contentWrap.find( '.toolbar' ).size()
                data = @options

                data.hasButton = !!data.buttons?.length
                data.buttons = _.reject data.buttons, ( btn ) ->
                    if btn.type is 'create'
                        data.btnValueCreate = btn.name
                        true

                data.height = that.__getHeightOfContent()
                @$( '.content-wrap' ).html template.toolbar_slide data
                @


        # ------ INTERFACE ------ #

        render: ( refresh ) ->
            @$el.html template.frame @options

            if _.isString refresh
                tpl = refresh

                @$( '.content-wrap' ).html template[ tpl ] and template[ tpl ](@options) or tpl
            else
                @renderLoading()

            if not refresh
                @__open()
            @

        renderLoading: ->
            @$( '.content-wrap' ).html template.loading
            @

        renderListLoading: ->
            @$( '.list-content' ).html template.loading
            @

        setContent: ( dom, noTable ) ->
            @tempDom = dom
            @__renderToolbarSlide()

            if noTable
                @$( '.list-content' ).html dom
            else
                @$( '.list-content' ).html template.table @options
                @$( '.t-m-content' ).html dom


            @__triggerChecked null
            @trigger "rendered", @
            @

        setSlide: ( dom ) ->
            @$( '.slidebox .content' ).html dom
            @error()
            @

        setDetail: ( $tr, dom ) ->
            $trDetail = $tr.next( '.tr-detail' )
            $trDetail.find( 'td' ).html dom
            $trDetail

        triggerSlide: ( which ) ->
            @$( "[data-btn=#{which}]" ).click()

        cancel: () ->
            if @__slideReject()
                return @

            $activeButton = @$( '.toolbar .active' )

            @trigger 'slideup', $activeButton.data('btn'), @getChecked()
            $activeButton.removeClass 'active' unless @options.longtermActive
            @toggleSlide false
            @

        unCheckSelectAll: ->
            @$( '#t-m-select-all' )
                .get( 0 )
                .checked = false
            @__processDelBtn false

        delegate: ( events, context ) ->
            if not events or not _.isObject(events) then return @
            context = context or @

            for key, method of events
                if (!_.isFunction(method)) then method = context[events[key]];
                if not method then continue

                match = key.match /^(\S+)\s*(.*)$/
                eventName = match[1]
                selector = match[2]
                method = _.bind method, context
                eventName += '.delegateEvents' + @cid
                if selector is ''
                  @$el.on eventName, method
                else
                  @$el.on eventName, selector, method

            @

        error: (msg) ->
            $error = @$( '.error' )
            if msg
                $error.text( msg ).show()
            else
                $error.hide()


        getSlide: ->
            @__slide

        toggleSlide: ( display ) ->
            $slidebox = @$( '.slidebox' )
            @setSlide template.loading if display
            $slidebox.toggleClass 'show', display or false

            @




