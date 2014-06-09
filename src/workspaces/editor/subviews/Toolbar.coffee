
define [
  "OpsModel"
  "../template/TplOpsEditor"
  "component/exporter/Thumbnail"
  "component/exporter/JsonExporter"
  "ApiRequest"
  "i18n!nls/lang.js"
  "UI.modalplus"
  "UI.notification"
  "backbone"
], ( OpsModel, OpsEditorTpl, Thumbnail, JsonExporter, ApiRequest, lang, Modal )->

  Backbone.View.extend {

    events :
      "click .icon-save"                   : "saveStack"
      "click .icon-delete"                 : "deleteStack"
      "click .icon-duplicate"              : "duplicateStack"
      "click .icon-new-stack"              : "createStack"
      "click .icon-zoom-in"                : "zoomIn"
      "click .icon-zoom-out"               : "zoomOut"
      "click .icon-export-png"             : "exportPNG"
      "click .icon-export-json"            : "exportJson"
      "click .icon-toolbar-cloudformation" : "exportCF"
      "OPTION_CHANGE .toolbar-line-style"  : "setTbLineStyle"

    render : ()->
      opsModel = @workspace.opsModel

      # Toolbar
      if opsModel.isImported()
        btns = ["BtnActionPng", "BtnZoom", "BtnLinestyle"]
      else if opsModel.isStack()
        btns = ["BtnRunStack", "BtnStackOps", "BtnZoom", "BtnExport", "BtnLinestyle"]
      else
        if @__editMode
          btns = ["BtnApply", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]
        else
          btns = ["BtnEditApp", "BtnAppOps", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]

      tpl = ""
      for btn in btns
        tpl += OpsEditorTpl.toolbar[ btn ]()

      @setElement $("#OEPanelTop").html( tpl )

      @updateTbBtns()
      @updateZoomButtons()
      return

    clearDom : ()->
      @$el = null
      return

    updateTbBtns : ()->
      opsModel = @workspace.opsModel

      # LineStyle Btn
      @$el.children(".toolbar-line-style").children(".dropdown").children().eq(parseInt(localStorage.getItem("canvas/lineStyle"),10) || 2).click()

      # App Run & Stop
      if opsModel.isApp()
        $stopBtn = @$el.children(".icon-stop")
        if opsModel.get("stoppable") or not opsModel.testState( OpsModel.State.Running )
          $stopBtn.hide()
        else
          $stopBtn.show()

        @$el.children(".icon-play").toggle( not opsModel.testState( OpsModel.State.Stopped ) )

      if @__saving
        @$el.children(".icon-save").attr("disabled", "disabled")
      else
        @$el.children(".icon-save").removeAttr("disabled")

      @updateZoomButtons()
      return

    setTbLineStyle : ( ls )->
      localStorage.setItem("canvas/lineStyle", ls)
      $canvas.updateLineStyle( ls )

    saveStack : ( evt )->
      $( evt.currentTarget ).attr("disabled", "disabled")

      self = @
      @__saving = true

      newJson = @workspace.design.serialize()

      Thumbnail.generate( $("#svg_canvas") ).catch( ()->
        return null
      ).then ( thumbnail )->
        self.workspace.opsModel.save( newJson, thumbnail ).then ()->
          self.__saving = false
          $( evt.currentTarget ).removeAttr("disabled")
          notification "info", sprintf(lang.ide.TOOL_MSG_ERR_SAVE_SUCCESS, newJson.name)
        , ( err )->
          self.__saving = false
          $( evt.currentTarget ).removeAttr("disabled")
          notification "error", sprintf(lang.ide.TOOL_MSG_ERR_SAVE_FAILED, newJson.name)
        return

    deleteStack    : ()-> App.deleteStack( @workspace.opsModel.cid, @workspace.design.get("name") )
    createStack    : ()-> App.createOps( @workspace.opsModel.get("region") )
    duplicateStack : ()->
      newOps = App.model.createStackByJson( @workspace.design.serialize() )
      App.openOps newOps
      return

    zoomIn  : ()-> MC.canvas.zoomIn();  @updateZoomButtons()
    zoomOut : ()-> MC.canvas.zoomOut(); @updateZoomButtons()
    updateZoomButtons : ()->
      scale = $canvas.scale()
      if scale <= 1
        @$el.find(".icon-zoom-in").attr("disabled", "disabled")
      else
        @$el.find(".icon-zoom-in").removeAttr("disabled")

      if scale >= 1.6
        @$el.find(".icon-zoom-out").attr("disabled", "disabled")
      else
        @$el.find(".icon-zoom-out").removeAttr("disabled")
      return

    exportPNG : ()->
      modal = new Modal {
        title         : "Export PNG"
        template      : OpsEditorTpl.export.PNG()
        width         : "470"
        disableFooter : true
        compact       : true
        onClose : ()-> modal = null; return
      }

      design = @workspace.design
      name   = design.get("name")
      Thumbnail.exportPNG $("#svg_canvas"), {
          isExport   : true
          createBlob : true
          name       : name
          id         : design.get("id")
          onFinish   : ( data ) ->
            if not modal then return
            modal.tpl.find(".loading-spinner").remove()
            modal.tpl.find("section").show().prepend("<img style='max-height:100%;display:inline-block;' src='#{data.image}' />")
            btn = modal.tpl.find("a.btn-blue")
            if data.blob
              btn.click ()-> JsonExporter.download( data.blob, "#{name}.png" ); false
            else
              btn.attr {
                href     : data.image
                download : "#{name}.png"
              }
            modal.resize()
            return
      }
      return

    exportJson : ()->
      design   = @workspace.design
      username = App.user.get('username')
      date     = MC.dateFormat(new Date(), "yyyy-MM-dd")
      name     = [design.get("name"), username, date].join("-")

      data = JsonExporter.exportJson design.serialize(), "#{name}.json"
      if data
        # The browser doesn't support Blob. Fallback to show a dialog to
        # allow user to download the file.
        new Modal {
          title         : lang.ide.TOOL_EXPORT_AS_JSON
          template      : OpsEditorTpl.export.JSON( data )
          width         : "470"
          disableFooter : true
          compact       : true
        }

    exportCF : ()->
      modal = new Modal {
        title         : lang.ide.TOOL_POP_EXPORT_CF
        template      : OpsEditorTpl.export.CF()
        width         : "470"
        disableFooter : true
      }

      design = @workspace.design
      name   = design.get("name")

      ApiRequest("stack_export_cloudformation", {
        region : design.get("region")
        stack  : design.serialize()
      }).then ( data )->
        btn = modal.tpl.find("a.btn-blue").text(lang.ide.HEAD_INFO_LOADING).removeClass("disabled")
        JsonExporter.genericExport btn, data, "#{name}.json"
        return
      , ( err )->
        modal.tpl.find("a.btn-blue").text("Fail to export...")
        notification "error", "Fail to export to AWS CloudFormation Template, Error code:#{err.error}"
        return
  }
