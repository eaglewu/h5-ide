
define [ "jquery" ], ()->

  ###
  # Every key that are used to do analytics should be defined here.
  ###

  IntercomKeys =
    import_json    : true
    import_cf      : true
    export_json    : true
    visualize_vpc  : true
    sg_line_style  : true
    export_png     : true
    export_vis_png : true
    cloudformation : true
    use_visualops  : true
    app_to_stack   : true
    version        : true
    timezone       : true
    lastlogin      : true
    drs            : true
    dru            : true

  IntercomAnalytics = {
    increase : ( key )->
      if not IntercomKeys[ key ]
        console.error "The key `#{key}` is not enabled for analytics"
        return

      o = {}
      o[ key ] = 1

      window.Intercom && window.Intercom 'update', {increments:o}

    update : ( key, value )->
      o = {}
      if key and value
        if not IntercomKeys[ key ]
          console.error "The key `#{key}` is not enabled for analytics"
          return

        o[ key ] = value
      else if key
        for k, v of key
          if IntercomKeys[ k ]
            o[ k ] = v
          else
            console.error "The key `#{key}` is not enabled for analytics"

      window.Intercom && window.Intercom "update", o
  }

  $(document.body).on "click", "[data-analytics-plus]", ()->
    key = $(this).attr("data-analytics-plus")
    if key
      IntercomAnalytics.increase key
    return

  IntercomAnalytics
