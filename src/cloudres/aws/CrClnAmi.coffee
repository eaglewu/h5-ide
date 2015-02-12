
define ["ApiRequest", "../CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  OS_TYPE_LIST = ['centos','redhat','rhel','ubuntu','debian','fedora','gentoo','opensuse','suse','amazon','amzn']
  SQL_WEB_PATTERN      = /sql.*?web.*?/i
  SQL_STANDARD_PATTERN = /sql.*?standard.*?/i

  INVALID_AMI_ID = /\[(.+?)\]/
  MALFORM_AMI_ID = /\s["|'](.+?)["|']/

  ### Helpers ###
  getOSType = ( ami ) ->
    #return osType by ami.name | ami.description | ami.imageLocation
    if ami.osType then return ami.osType

    if ami.platform is "windows" then return "windows"

    name   = (ami.name || "").toLowerCase()
    desc   = (ami.description || "").toLowerCase()
    imgloc = (ami.imageLocation || "").toLowerCase()

    for word in OS_TYPE_LIST
      if name.indexOf( word ) >= 0
        osType = word
        break

      if desc.indexOf( word ) >= 0
        osTypeGuess1 = word
      if imgloc.indexOf( word ) >= 0
        osTypeGuess2 = word

    osType = osType || osTypeGuess1 || osTypeGuess2 || "linux-other"

    if osType is "rhel" then return "redhat"
    if osType is "amzn" then return "amazon"

    osType

  getOSFamily = ( ami ) ->
    if not ami.osType then return "linux"

    osType = ami.osType

    if osType is "windows" or osType is "win"

      if SQL_WEB_PATTERN.exec(ami.name || "") or SQL_WEB_PATTERN.exec(ami.description || "") or SQL_WEB_PATTERN.exec(ami.imageLocation || "")
        return "mswinSQLWeb"

      if SQL_STANDARD_PATTERN.exec(ami.name || "") or SQL_STANDARD_PATTERN.exec(ami.description || "") or SQL_STANDARD_PATTERN.exec(ami.imageLocation || "")
        return "mswinSQL"

      return "mswin"

    constant.OS_TYPE_MAPPING[ osType ] || "linux"

  fixDescribeImages = ( amiArray )->
    ms = []
    for ami in amiArray
      ami.id = ami.imageId
      delete ami.imageId

      bdm = {}
      for item in ami.blockDeviceMapping?.item || []
        if item.ebs and not ami.imageSize and ami.rootDeviceName.indexOf(item.deviceName) isnt -1
          ami.imageSize = Number(item.ebs.volumeSize)
        bdm[ item.deviceName ] = item.ebs || {}

      ami.osType   = getOSType( ami )
      ami.osFamily = getOSFamily( ami )
      ami.blockDeviceMapping = bdm
      ami.isPublic = ami.isPublic.toString()

      ms.push ami.id
    ms

  ### This Collection is used to fetch generic ami ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrAmiCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.AMI

    __selfParseData : true

    localStorageKey : ()-> "ivla/" + @credential() + "_" + @region()

    initialize : ()-> @__markedIds = {}; return

    doFetch : ()->
      # This method is used for CloudResources to invalid the cache.
      if localStorage.getItem( @localStorageKey() )
        localStorage.setItem( @localStorageKey(), "")

      @__markedIds = {}
      d = Q.defer()
      d.resolve([])
      @trigger "update"
      return d.promise

    initWithCache : ()->
      if @__markedIdInited then return

      @__markedIdInited = true
      for id in (localStorage.getItem( @localStorageKey() )||"").split(",")
        @__markedIds[ id ] = true

    markId     : ( amiId, invalid )-> @__markedIds[ amiId ] = invalid; return
    isIdMarked : ( amiId )-> @initWithCache(); @__markedIds.hasOwnProperty( amiId )

    isInvalidAmiId : ( amiId )-> @initWithCache(); @__markedIds[ amiId ]

    getOSFamily : ( amiId )-> getOSFamily( @get( amiId ) )

    saveInvalidAmiId : ()->
      amis = []
      for amiId, value of @__markedIds
        if value then amis.push amiId

      if amis.length
        localStorage.setItem( @localStorageKey(), amis.join(",") )
      return

    fetchAmi : ( ami )->
      if not ami then return

      console.assert not _.isArray( ami ), "CrClnAmi.fetchAmi() do not accept array param."

      if @__toFetch
        @__toFetch.push ami
        return

      @__toFetch = [ ami ]

      self = @
      setTimeout ()->
        f = self.__toFetch
        self.__toFetch = null
        self.fetchAmis( f )
      , 0
      return

    fetchAmis : ( amis )->
      if not amis then return

      if _.isString(amis)
        console.warn "Are you sure you want to call CrClnAmi.fetchAmis() with only one ami?"
        amis = [amis]

      # See if we ha
      toFetch = []
      for amiId in amis
        if @get( amiId ) then continue
        if @isIdMarked( amiId )
          if @__markedIds[ amiId ]
            console.info "Ami '#{amiId}' is invalid. Ignore fetching info."
          else
            console.log "Ami `#{amiId}` is duplicated. Ignore fetching info."
          continue

        @markId( amiId, false )

        toFetch.push( amiId )

      if toFetch.length is 0
        d = Q.defer()
        d.resolve()
        return d.promise

      self = @

      # Do fetch.
      @sendRequest( "ami_DescribeImages", {
        ami_ids : toFetch
      }).then ( res )->
        res = res.DescribeImagesResponse.imagesSet?.item
        if res
          fixDescribeImages( res )
          self.add res, {add: true, merge: true, remove: false}
        else
          self.trigger "update"

        self.saveInvalidAmiId()

      , ( err )->
        if err.awsErrorCode is "InvalidAMIID.NotFound"
          # The image id '[ami-00000123]' does not exist
          invalidId = INVALID_AMI_ID.exec err.awsResult
        else if err.awsErrorCode is "InvalidAMIID.Malformed"
          # Invalid id: "ami-"
          invalidId = MALFORM_AMI_ID.exec err.awsResult

        if not invalidId
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Can't describe AMIs and AWS returns invalid data. Please contact us when you encouter this issue.", toFetch )

        invalidId = invalidId[1]

        console.info "The requested Ami '#{invalidId}' is invalid, retrying to fetch"

        toFetch.splice( toFetch.indexOf(invalidId), 1 )
        self.markId( invalidId, true )
        __markedIds = self.__markedIds
        self.__markedIds = {}
        p = self.fetchAmis( toFetch )
        self.__markedIds = __markedIds
        return p
  }


  SpecificAmiCollection = CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSpecificAmiCollection"
    ### env:dev:end ###

    type : "SpecificAmiCollection"

    initialize : ()-> @__models = []; return

    getModels : ()->
      ms = []
      col = CloudResources( @credential(), constant.RESTYPE.AMI, @region() )
      for id in @__models
        ms.push col.get( id )
      ms

    fetchForce : ()->
      @__models = []
      CrCollection.prototype.fetchForce.call this
  }

  ### This Collection is used to fetch quickstart ami ###
  SpecificAmiCollection.extend {
    ### env:dev ###
    ClassName : "CrQuickstartAmiCollection"
    ### env:dev:end ###

    type  : "QuickStartAmi"

    doFetch : ()-> @sendRequest("aws_quickstart")

    parseFetchData : ( data )->
      # OpsResource doesn't return anything, Instead, it injects the data to other collection.
      savedAmis = []
      amiIds  = []
      for id, ami of data
        #if ami.architecture is 'i386' or ( ami.name.indexOf('by VisualOps') is -1 and (ami.osType not in ['windows','suse']) )
        #  continue
        ami.id = id
        savedAmis.push ami
        amiIds.push id

      CloudResources( @credential(), constant.RESTYPE.AMI, @region() ).add savedAmis
      @__models = amiIds
      return
  }




  ### This Collection is used to fetch my ami ###
  SpecificAmiCollection.extend {
    ### env:dev ###
    ClassName : "CrMyAmiCollection"
    ### env:dev:end ###

    type  : "MyAmi"

    doFetch : ()->
      selfParam1 =
        executable_by : ["self"]
        filters       : [{ Name : "is-public", Value : false }]
      selfParam2 =
        owners        : ["self"]

      self = @

      Q.allSettled([
        @sendRequest( "ami_DescribeImages", selfParam1 )
        @sendRequest( "ami_DescribeImages", selfParam2 )
      ]).spread ( d1, d2 )->
        d1 = d1.value.DescribeImagesResponse.imagesSet?.item || []
        d2 = d2.value.DescribeImagesResponse.imagesSet?.item || []
        self.onFetch( d1.concat(d2) )
      , ( r1, r2 )->
        d1 = r1.value.DescribeImagesResponse.imagesSet?.item if r1.state is "fulfilled"
        d2 = r2.value.DescribeImagesResponse.imagesSet?.item if r2.state is "fulfilled"
        if d1 || d2
          self.onFetch( [].concat(d1||[], d2||[]) )

        throw d1 if d1.state is "rejected"
        throw d2 if d2.state is "rejected"

    onFetch : ( amiArray )->
      @__models = fixDescribeImages( amiArray )
      CloudResources( @credential(), constant.RESTYPE.AMI, @region() ).add amiArray
      return

    parseFetchData : ( data )->
      # OpsResource doesn't return anything, Instead, it injects the data to other collection.
      savedAmis = []
      amiIds  = []
      for ami in data
        try
          ami.id = ami.imageId
          delete ami.imageId
          savedAmis.push ami
          amiIds.push ami.id
        catch e

      CloudResources( @credential(), constant.RESTYPE.AMI, @region() ).add savedAmis
      @__models = amiIds
      return
  }


  UserFavAmis = {}
  ### This Collection is used to fetch favorite ami ###
  SpecificAmiCollection.extend {
    ### env:dev ###
    ClassName : "CrFavAmiCollection"
    ### env:dev:end ###

    type  : "FavoriteAmi"

    doFetch : ()->
      region = @region()

      if UserFavAmis[ region ]
        d = Q.defer()
        d.resolve()
        p = d.promise()
      else
        p = ApiRequest("favorite_info", {
          region_name : region
          provider    : "AWS"
          service     : "EC2"
          resource    : "AMI"
        }).then ( res )-> UserFavAmis[ region ] = res || []; return

      self = @
      p.then ()->
        CloudResources( self.credential(), constant.RESTYPE.AMI, self.region() ).fetchAmis( UserFavAmis[ region ] )

    parseFetchData : ( data )-> return

    getModels : ()->
      ms = []
      col = CloudResources( @credential(), constant.RESTYPE.AMI, @region() )
      for id in UserFavAmis[ @region() ] || []
        m = col.get( id )
        if m then ms.push m
      ms

    unfav : ( id )->
      self = @
      idx = (UserFavAmis[@region()]||[]).indexOf id
      if idx is -1
        d = Q.defer()
        d.resolve()
        return d.promise

      ApiRequest("favorite_remove", {
        region_name  : @region()
        resource_ids : [id]
      }).then ()->
        ms = UserFavAmis[self.region()]
        ms.splice ms.indexOf(id), 1
        self.trigger "update"
        self

    fav   : ( ami )->
      if not ami.id then return null

      imageId = ami.id

      self = @
      ApiRequest("favorite_add", {
        region_name : @region()
        resource    : { id: ami.id, provider: 'AWS', 'resource': 'AMI', service: 'EC2' }
      }).then ()->
        ms = UserFavAmis[ self.region() ] || (UserFavAmis[ self.region() ] = [])
        ms.push ami.id

        CloudResources( self.credential(), constant.RESTYPE.AMI, self.region() ).add ami, {add: true, merge: true, remove: false}

        self.trigger "update"
        self
  }
