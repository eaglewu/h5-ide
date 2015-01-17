

define [ "ApiRequest", "Scene", "i18n!/nls/lang.js", "backbone", "UI.notification" ], ( ApiRequest, Scene, lang )->

  SSView = Backbone.View.extend {
    initialize : ()-> @setElement $("<div class='global-loading'></div>").appendTo("#scenes")
  }



  class StackStore extends Scene

    ###
      Methods that should be override
    ###
    # Override this method to perform custom initialization
    initialize : ( attributes )->
      @id = attributes.id
      @view = new SSView()

      @activate()
      @setTitle "Fetching Sample Stack"

      self = @
      ApiRequest('stackstore_fetch_stackstore', { sub_path: "master/stack/#{@id}/#{@id}.json" }).then ( res ) ->
        try
          j = JSON.parse( res )
          delete j.id
          delete j.signature
        catch e
          j = null
          self.onParseError()

        if j then self.onParseSuccess( j )
      , ()->
        self.onLoadError()

    url : ()-> "store/#{@id}"
    isWorkingOn : ( info )-> info is @id

    onParseSuccess : ( j )->
      App.loadUrl( App.model.getPrivateProject().createStackByJson( j ).url() )

    onLoadError : ()->
      notification "error", lang.NOTIFY.LOAD_SAMPLE_FAIL
      @remove()

    onParseError : ()->
      notification "error", lang.NOTIFY.PARSE_SAMPLE_FAIL
      @remove()
