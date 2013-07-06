#############################
#  View(UI logic) for design/property
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars'
         'UI.fixedaccordion'
], ( event ) ->

    PropertyView = Backbone.View.extend {

        el                  : $ '#property-panel'
        accordion_item_tmpl : Handlebars.compile $( '#accordion-item-tmpl' ).html()

        initialize : ->
            #listen
            $( document ).delegate '#hide-property-panel', 'click', this.togglePropertyPanel
            #listen
            $( window   ).on 'resize', fixedaccordion.resize
            #
            this.listenTo this.model, 'change:content', this.addAccordionItem

        render     : ( template ) ->
            console.log 'property render'
            $( this.el ).html template

        togglePropertyPanel : ( event ) ->
            console.log 'togglePropertyPanel'
            $( '#property-panel' ).toggleClass 'hiden'
            $( event ).children().first().toggleClass('icon-double-angle-left').toggleClass('icon-double-angle-right')
            $( '#canvas-panel' ).toggleClass 'right-hiden'

        addAccordionItem : () ->
            console.log 'addAccordionItem'
            $( '.property-panel-tmp' ).append this.accordion_item_tmpl this.model.attributes

    }

    return PropertyView