
# This file is used to place handlebar helpers. All handlebar helpers should be placed here.
# Any helper that is not in this file might lead to compile error.

define ["handlebars", "i18n!nls/lang.js"], ( Handlebars, lang )->

  #i18n
  Handlebars.registerHelper 'i18n', ( text ) ->
    new Handlebars.SafeString lang.ide[ text ]

  Handlebars.registerHelper 'tolower', ( result ) ->
    return new Handlebars.SafeString result.toLowerCase()

  Handlebars.registerHelper 'emptyStr', ( v1 ) ->
    if v1 in [ '', undefined, null ]
        '-'
    else
        new Handlebars.SafeString v1

  Handlebars.registerHelper 'UTC', ( text ) ->
    new Handlebars.SafeString new Date( text ).toUTCString()

  Handlebars.registerHelper 'breaklines', (text) ->
    text = Handlebars.Utils.escapeExpression(text)
    text = text.replace(/(\r\n|\n|\r)/gm, '<br>')
    return new Handlebars.SafeString(text)

  # nl2br
  Handlebars.registerHelper 'nl2br', (text) ->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    return new Handlebars.SafeString(nl2br)

  # if equal
  Handlebars.registerHelper 'ifCond', ( v1, v2, options ) ->
    return options.fn this if v1 is v2
    return options.inverse this


  Handlebars.registerHelper 'timeStr', ( v1 ) ->
      d = new Date( v1 )

      if isNaN( Date.parse( v1 ) ) or not d.toLocaleDateString or not d.toTimeString
          if v1
              return new Handlebars.SafeString v1
          else
              return '-'

      d = new Date( v1 )
      d.toLocaleDateString() + " " + d.toTimeString()

  Handlebars.registerHelper "plusone", ( v1 ) ->
      v1 = parseInt( v1, 10 )
      if isNaN( v1 )
          return v1
      else
          return '' + (v1 + 1)
  null
