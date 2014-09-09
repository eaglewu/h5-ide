
define [
    'backbone'
    'constant'
    'Design'
    '../../property/OsPropertyView'
    '../../property/OsPropertyBundle'
    'selectize'
], ( Backbone, constant, Design, OsPropertyView, OsPropertyBundle )->

  Backbone.View.extend

    events:

        null

    initialize: ( options ) ->

        @options = options
        @mode = Design.instance().mode()
        @uid  = options.uid
        @type = options.type

        @model      = Design.instance().component @uid
        @viewClass  = OsPropertyView.getClass @mode, @type


    render: () ->

        that = @
        @$el.html new @viewClass( model: @model ).render().el

        @$el.find('select.value').each ->
            that.bindSelection($(@))

        @

    bindSelection: ($valueDom) ->

        return if (not $valueDom or not $valueDom.length)

        if not $valueDom.hasClass('selectized')

            mutil = false
            maxItems = undefined
            if $valueDom.hasClass('mutil')
                mutil = true
                maxItems = null

            if $valueDom.hasClass('bool')

                $valueDom.selectize({
                    multi: mutil,
                    maxItems: maxItems,
                    persist: false,
                    valueField: 'value',
                    labelField: 'text',
                    searchField: ['text'],
                    create: false,
                    openOnFocus: false,
                    plugins: ['custom_selection'],
                    onInitialize: () ->
                        @setValue(@$input.attr('value').split(','), true)
                    options: [
                        {text: 'True', value: 'true'},
                        {text: 'False', value: 'false'}
                    ],
                    render: {
                        option: (item) ->
                            return '<div>O ' + item.text + '</div>'
                        item: (item) ->
                            return '<div>O ' + item.text + '</div>'
                    }
                })

            if $valueDom.hasClass('option')

                $valueDom.selectize({
                    multi: mutil,
                    maxItems: maxItems,
                    persist: false,
                    create: false,
                    openOnFocus: false,
                    plugins: ['custom_selection']
                    onInitialize: () ->
                        @setValue(@$input.attr('value').split(','), true)
                    ,
                    render: {
                        option: (item) ->
                            return '<div>' + item.text + '</div>'
                        item: (item) ->
                            return '<div>' + item.text + '</div>'
                    }
                })