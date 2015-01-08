#############################
#  View(UI logic) for component/amis
#############################

define ['../template/TplAmiBrowser', 'i18n!/nls/lang.js', 'UI.modalplus', "ApiRequest", 'CloudResources', 'backbone', 'jqpagination'], ( TplAmiBrowser, lang, Modal, ApiRequest, CloudResources ) ->

    Backbone.View.extend {
        events   :
            'click .ami-option-group .ami-option-wrap .btn' : 'clickOptionBtn'
            'keypress #community-ami-input'                 : "search"
            'click    #btn-search-ami'                      : "search"
            'click    .toggle-fav'                          : "toggleFav"

        initialize : ( attr ) ->

            $.extend this, attr

            modal = new Modal
              title: lang.IDE.AMI_LBL_COMMUNITY_AMIS
              width: "855px"
              template: TplAmiBrowser.dialog()
              disableFooter: true
              compact: true

            self = @
            modal.on "close", ()-> if self.onClose then self.onClose(); return

            @setElement modal.tpl
            @doSearch()
            return

        clickOptionBtn : (event) ->
            if $(event.target).hasClass('active')
                active_btns = $(event.target).parent().find('.active')
                if active_btns.length is 1 and active_btns[0] == event.target   # click the only one active button not reply
                    return
                else
                    $(event.target).removeClass('active')
            else
                $(event.target).addClass('active')

            null

        toggleFav: (event)->
          amiElem = $(event.target)
          that = this
          favAmis = CloudResources "FavoriteAmi", @region
          promise = null
          id = amiElem.closest("tr").attr("data-id")
          if amiElem.hasClass('fav')
            promise = favAmis.unfav id
          else
            data    = $.extend { id : id }, @communityAmiData[id]
            promise = favAmis.fav( data )

          promise.then -> amiElem.toggleClass('fav')

        doSearch : (pageNum, perPage)->
          pageNum = pageNum || 1
          @renderAmiLoading()
          name = $("#community-ami-input").val()
          platform = $('#selectbox-ami-platform').find('.selected').data('id')

          isPublic       = null
          architecture   = null
          rootDeviceType = null

          $buttonGroup = $("#filter-ami-type").find(".active")
          if $buttonGroup.length is 1
            isPublic = $buttonGroup.attr("data-value")

          $buttonGroup = $('#filter-ami-32bit-64bit').find('.active')
          if $buttonGroup.length is 1
            architecture = $buttonGroup.attr("data-value")

          $buttonGroup = $('#filter-ami-EBS-Instance').find('.active')
          if $buttonGroup.length is 1
            rootDeviceType = $buttonGroup.attr("data-value")

          perPageNum = parseInt(perPage||50, 10)
          returnPage = parseInt(pageNum, 10)

          self = @
          reg_ami = /ami-[a-zA-Z0-9]{8}$/
          amiId = name.trim()
          if amiId and reg_ami.test(amiId)
            #search by ami id
            amiRes = CloudResources( "AWS.EC2.AMI", self.region )
            amiRes.fetchAmis( [amiId] ).then ->
              amiData = amiRes.where({id:amiId})
              result =
                "ami":
                  "curPageNum" : 1
                  "result": {}
                  "totalNum": 0
                  "totalPageNum": 1
              if amiData.length > 0
                result.ami.result[amiId] = amiData[0].toJSON()
                result.ami.totalNum = 1
              result = self.addFavStar(result)
              self.communityAmiData = result.ami?.result || {}
              self.communityAmiRender(result)
          else
            #search public ami
            ApiRequest("aws_public",
              region_name: @region
              filters:
                ami: {name, platform, isPublic, architecture, rootDeviceType, perPageNum, returnPage}
            ).then (result)->
              result = self.addFavStar(result)
              self.communityAmiData = result.ami?.result || {}
              self.communityAmiRender(result)
            , (result)->
              notification 'error', lang.NOTIFY.UNABLE_TO_LOAD_COMMUNITY_AMIS
              self.communityAmiRender({ami:[]})

        searchPrev: ->
          page = parseInt( $("#community_ami_page_current").attr("page"), 10)
          @doSearch(page+1)

        searchNext: ->
          page = parseInt( $("#community_ami_page_current").attr("page"), 10)
          @doSearch(page-1)

        search: (event)->
          if event.keyCode and event.keyCode isnt 13 then return
          @doSearch()

        addFavStar: (result)->
          favAmis = CloudResources("FavoriteAmi",@region).getModels() || []
          dumpObj = _.clone result.ami.result
          favIds = _.pluck (_.pluck favAmis, "attributes"), "id"
          _.each dumpObj, (e,k)->
            if k in favIds
              e.faved = true
          result.ami.result = dumpObj
          result

        communityAmiRender: (data)->
          @communityShowContent()
          totalNum = 0
          if not data.ami then return

          data = data.ami

          $("#community_ami_table").html TplAmiBrowser.amiItem( data.result )
          @communityPagerRender data.curPageNum, data.totalPageNum, data.totalNum

        communityPagerRender: ( current_page, max_page, total ) ->
          resourceView = @
          pageSize = if total > 50 then 50 else total

          itemBegin = ( current_page - 1 ) * 50 + 1
          itemEnd = itemBegin + pageSize - 1
          itemEnd = total if itemEnd > total
          itemBegin = 0 if itemEnd is 0

          $( '.page-tip' ).text sprintf lang.IDE.AMI_LBL_PAGEINFO, itemBegin, itemEnd, total

          pagination = $ '.pagination'

          if max_page is 0
            pagination.hide()
          else
            pagination.show()

          if pagination.data 'jqPagination'
            pagination.jqPagination 'destroy'
            # init page num
            pagination.find( 'input' ).data('current-page', current_page)

          pagination.jqPagination({
            current_page: current_page,
            max_page: max_page,
            page_string: "{current_page} / {max_page}"
            paged: ((current_page, max_page) ->
              (page) ->
                if page isnt current_page and max_page >= page > 0
                  resourceView.doSearch page
            )(current_page, max_page)

          })

        communityShowContent: () ->
          $( ".show-loading" ).hide()
          $( "#ami-table-wrap .scroll-content" ).show()
          $( "#btn-search-ami" ).text( lang.IDE.AMI_LBL_SEARCH ).removeAttr( "disabled" )
          $( "#community-ami-page>div" ).show()

        renderAmiLoading: () ->
          $( "#ami-table-wrap .scroll-content" ).hide()
          $( ".show-loading" ).show()
          $( "#btn-search-ami" ).text( lang.IDE.AMI_LBL_SEARCHING ).attr( "disabled", "" )
          $( "#community-ami-page>div" ).hide()
    }
