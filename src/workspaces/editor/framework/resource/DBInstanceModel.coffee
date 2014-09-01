
define [
  '../ComplexResModel'
  '../ConnectionModel'
  './DBOgModel'
  'Design'
  'constant'
  'i18n!/nls/lang.js'
  'CloudResources'

], ( ComplexResModel, ConnectionModel, DBOgModel, Design, constant, lang, CloudResources )->

  OgUsage = ConnectionModel.extend
    type : "OgUsage"
    oneToMany: constant.RESTYPE.DBOG

  Model = ComplexResModel.extend {
    defaults :
      newInstanceId : ''
      instanceId    : ''
      snapshotId    : ''
      createdBy : ""
      accessible: false
      username: 'root'
      password: '12345678'
      multiAz: true
      iops: 0
      autoMinorVersionUpgrade: true
      allowMajorVersionUpgrade: ''
      backupRetentionPeriod: 1
      allocatedStorage: 10
      backupWindow: ''
      maintenanceWindow: ''
      characterSetName: ''
      dbName: ''
      port: ''
      pending: ''
      az: ''
      ogName: ''
      pgName: ''
      applyImmediately: false
      dbRestoreTime: ''
      isRestored: false

    type : constant.RESTYPE.DBINSTANCE
    newNameTmpl : "db"

    __cachedSpecifications: null

    # Source of Snapshot Instance
    source: -> CloudResources(constant.RESTYPE.DBSNAP, @design().region()).get( @get('snapshotId') )

    # -------- Master and Slave -------- #
    slaveIndependentAttr: "id|appId|x|y|width|height|name|\
        accessible|createdBy|instanceId|instanceClass|autoMinorVersionUpgrade|\
        accessible|backupRetentionPeriod|multiAz|password|__connections|__parent"

    sourceDbIndependentAttrForRestore: "id|appId|x|y|width|height|name|\
        accessible|createdBy|instanceId|instanceClass|autoMinorVersionUpgrade|\
        multiAz|__connections|__parent|license|iops|port|ogName|pgName|az"

    slaves: () ->

      that = @

      if @master() and @master().master()
        return []

      # return @connectionTargets("DbReplication")

      _.filter @connectionTargets("DbReplication"), (dbModel) ->

        if dbModel.category() is 'instance' and dbModel.get('appId')
          return false
        if that.category() is 'replica' and not that.get('appId')
          return false
        return true

    getAllRestoreDB: ->

      srcDb = @getSourceDBForRestore()
      return [] if srcDb

      that = @
      dbModels = Design.modelClassForType(constant.RESTYPE.DBINSTANCE).allObjects()
      return _.filter dbModels, (dbModel) ->
        if dbModel.getSourceDBForRestore() is that
          return true
        return false

    master: ->
      m =  @connections( 'DbReplication' )[0]
      if m and m.master() isnt @
        return m.master()
      null

    copyMaster: ( master ) ->
      @clone master

      unless @get 'appId'
        @set backupRetentionPeriod: 0, multiAz: false, instanceId: '', snapshotId: '', password: '****'

    setMaster : ( master ) ->
      # @connections("DbReplication")[0]?.remove()
      @unsetMaster()
      Replication = Design.modelClassForType("DbReplication")
      new Replication( master, @ )

      @listenTo master, 'change', @syncMasterAttr
      null

    unsetMaster : () ->

      that = @
      _.each @connections("DbReplication"), (connection) ->
        if connection.slave() is that
          connection.remove()

    setSourceDBForRestore : ( sourceDb ) ->

      @sourceDBForRestore = sourceDb
      @setDefaultParameterGroup()
      # DefaultSg
      defaultSg = Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg()
      SgAsso = Design.modelClassForType( "SgAsso" )
      new SgAsso( defaultSg, this )
      @listenTo sourceDb, 'change', @syncAttrSourceDBForRestore

    getSourceDBForRestore: ->
      
      @sourceDBForRestore

    syncMasterAttr: ( master ) ->

      if @get 'appId'
        return false

      needSync = {}

      for k, v of master.changedAttributes()
        if @slaveIndependentAttr.indexOf( k ) < 0
          needSync[ k ] = v

      delete needSync['iops'] if needSync['iops']

      @set needSync

    syncAttrSourceDBForRestore: ( sourceDb ) ->

      needSync = {}

      for k, v of sourceDb.changedAttributes()
        if @sourceDbIndependentAttrForRestore.indexOf( k ) < 0
          needSync[ k ] = v

      @set needSync

    needSyncMasterConn: ( cnn ) ->
      if @master() then return false

      if @get 'appId'
        connTypesToCopy = []
      else
        connTypesToCopy = [ 'SgAsso', 'OgUsage' ]

      if cnn.type not in connTypesToCopy then return false

      true

    connect : ( cnn )->
      if not @needSyncMasterConn( cnn ) then return

      # Update slaves' SgAsso
      otherTarget = cnn.getOtherTarget( @ )
      connectionModel = Design.modelClassForType cnn.type

      new connectionModel( slave, otherTarget ) for slave in @slaves()
      return

    disconnect : ( cnn )->
      if not @needSyncMasterConn( cnn ) then return
      if cnn.oneToMany then return

      otherTarget = cnn.getOtherTarget( @ )
      connectionModel = Design.modelClassForType cnn.type

      new connectionModel( slave, otherTarget ).remove() for slave in @slaves()

      return

    # -------- Master and Slave -------- #

    # -------- Restore to Point In Time -------- #
    restoreMaster: ( master ) ->
      @clone master
      @set "snapshotId", master.get("snapshotId")
      null

    # -------- Restore to Point In Time -------- #

    constructor : ( attr, option )->
      if option and not option.master and option.createByUser

      # Initialize Snapshot
        if attr.snapshotId
          snapshotModel = @getSnapshotModel attr.snapshotId
          _.extend attr, {
            "engine": snapshotModel.get('Engine'),
            "engineVersion": snapshotModel.get('EngineVersion'),
            "snapshotId": snapshotModel.get('DBSnapshotIdentifier'),
            "allocatedStorage": snapshotModel.get('AllocatedStorage'),
            "port": snapshotModel.get('Port'),
            "iops": snapshotModel.get('Iops') or 0,
            "multiAz": snapshotModel.get('MultiAZ'),
            "ogName": snapshotModel.get('OptionGroupName'),
            "license": snapshotModel.get('LicenseModel'),
            "az": snapshotModel.get('AvailabilityZone'),
            "username": snapshotModel.get('MasterUsername')
          }

      ComplexResModel.call @, attr, option

    initialize : ( attr, option ) ->
      option = option || {}

      if option.cloneSource
        @clone( option.cloneSource )
        return

      if option.master

        if not option.isRestore
          @copyMaster option.master
          @setMaster option.master
        else
          @cloneForRestore option.master
          @setSourceDBForRestore option.master

      else if option.createByUser
        # Default Sg
        SgAsso = Design.modelClassForType "SgAsso"
        defaultSg = Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg()
        new SgAsso defaultSg, @

        # Set Complex Default Values
        @set _.defaults attr, {
          license         : @getDefaultLicense()
          engineVersion   : @getDefaultVersion()
          instanceClass   : @getDefaultInstanceClass()
          port            : @getDefaultPort()
          dbName          : @getDefaultDBName()
          characterSetName: @getDefaultCharSet()
          allocatedStorage: @getDefaultAllocatedStorage()
          snapshotId      : ""
          multiAz         : !!attr.multiAz
        }

        #set default optiongroup and parametergroup
        @setDefaultOptionGroup()
        @setDefaultParameterGroup()
      return

    clone : ( srcTarget )->

      @cloneAttributes srcTarget, {
        reserve : "newInstanceId|instanceId|createdBy"
        copyConnection : [ "SgAsso", "OgUsage" ]
      }

      @set 'snapshotId', ''
      if @get('password') is '****'
        @set 'password', '12345678'

      return

    cloneForRestore : ( srcTarget ) ->

      @cloneAttributes srcTarget, {
        reserve : "newInstanceId|instanceId|createdBy|pgName"
        copyConnection : [ "OgUsage" ]
      }

      @set 'snapshotId', ''
      if @get('password') is '****'
        @set 'password', '12345678'

      return

    setDefaultOptionGroup: ( origEngineVersion ) ->
      # set default option group
      regionName  = Design.instance().region()
      engineCol   = CloudResources(constant.RESTYPE.DBENGINE, regionName)
      defaultInfo = engineCol.getDefaultByNameVersion regionName, @get('engine'), @get('engineVersion')
      if origEngineVersion
        origDefaultInfo = engineCol.getDefaultByNameVersion regionName, @get('engine'), origEngineVersion

      if origDefaultInfo and origDefaultInfo.family and defaultInfo and defaultInfo.family
        if origDefaultInfo.family is defaultInfo.family
          #family no changed, then no need change OptionGroup
          return null

      if defaultInfo and defaultInfo.defaultOGName
        defaultOG = defaultInfo.defaultOGName
      else
        defaultOG = "default:" + @get('engine') + "-" + @getMajorVersion().replace(".","-")
        console.warn "can not get default optiongroup for #{@get 'engine'} #{@getMajorVersion()}"

      new OgUsage @, @getDefaultOgInstance defaultOG
      null

    getDefaultOgInstance: ( name ) ->
      DBOgModel.findWhere( name: name, default: true ) or new DBOgModel name: name, default: true

    setDefaultParameterGroup:( origEngineVersion ) ->
      #set default parameter group
      regionName = Design.instance().region()
      engineCol = CloudResources(constant.RESTYPE.DBENGINE, regionName)
      defaultInfo = engineCol.getDefaultByNameVersion regionName, @get('engine'), @get('engineVersion')

      if defaultInfo and defaultInfo.defaultPGName
        defaultPG = defaultInfo.defaultPGName
      else
        defaultPG = "default." + @get('engine') + @getMajorVersion()
        console.warn "can not get default parametergroup for #{ @get 'engine' } #{ @getMajorVersion() }"
      @set 'pgName', defaultPG || ""
      defaultPG


    getAllocatedRange: ->
      engine = @get('engine')
      if @isMysql()
          obj = { min: 5, max: 3072 }

      if @isPostgresql()
          obj = { min: 5, max: 3072 }

      if @isOracle()
          obj = { min: 10, max: 3072 }

      if @isSqlserver()
          engine = @get('engine')
          if engine in ['sqlserver-ee', 'sqlserver-se']
              obj = { min: 200, max: 1024 }
          if engine in ['sqlserver-ex', 'sqlserver-web']
              obj = { min: 30, max: 1024 }

      # classInfo = @getInstanceClassDict()
      # defaultStorage = constant.DB_DEFAULTSETTING[@get('engine')].allocatedStorage
      # if classInfo and classInfo['ebs']
      #   if defaultStorage < 100
      #     obj.min = 100

      return obj

    getLicenseObj: ( getDefault ) ->
      currentLicense = @get 'license'

      if currentLicense then obj = _.findWhere @getSpecifications(), license: currentLicense
      if not obj and getDefault then obj = @getSpecifications()[0]

      obj

    getVersionObj: ( getDefault ) ->
      versions = @getLicenseObj(true).versions
      currentVersion = @get 'engineVersion'

      if currentVersion then obj = _.findWhere versions, version: currentVersion
      if not obj and getDefault then obj = versions[0]

      obj

    getInstanceClassObj: ( getDefault ) ->
      instanceClasses = @getVersionObj(true).instanceClasses
      currentClass = @get 'instanceClass'

      if currentClass then obj = _.findWhere instanceClasses, instanceClass: currentClass
      if not obj and getDefault
        consoleDefault = 'db.t1.micro'
        obj = _.find instanceClasses, (i) -> i.instanceClass is consoleDefault
        if not obj then obj = instanceClasses[0]

      obj

    setIops: ( iops ) -> @set('iops', iops)
    getIops: () -> @get('iops')

    getDefaultLicense: -> @getLicenseObj(true).license
    getDefaultVersion: -> @getVersionObj(true).version
    getDefaultInstanceClass: -> @getInstanceClassObj(true).instanceClass
    getMajorVersion: -> @get('engineVersion')?.split('.').slice(0,2).join('.')
    getMinorVersion: -> @get('engineVersion')?.split('.').slice(2).join('.')

    getRdsInstances: -> App.model.getRdsData(@design().region())?.instance[@get 'engine']
    getDefaultPort: -> constant.DB_DEFAULTSETTING[@get('engine')].port
    getDefaultDBName: -> constant.DB_DEFAULTSETTING[@get('engine')].dbname
    getDefaultCharSet: -> constant.DB_DEFAULTSETTING[@get('engine')].charset
    getInstanceClassDict: -> _.find constant.DB_INSTANCECLASS, ( claDict ) => claDict.instanceClass is @get 'instanceClass'
    getDefaultAllocatedStorage: ->
      # classInfo = @getInstanceClassDict()
      defaultStorage = constant.DB_DEFAULTSETTING[@get('engine')].allocatedStorage
      # if classInfo and classInfo['ebs']
      #   if defaultStorage < 100
      #     return 100
      return defaultStorage

    getOptionGroup: -> @connectionTargets('OgUsage')[0]
    getOptionGroupName: -> @getOptionGroup()?.get 'name'
    setOptionGroup: ( name ) ->
      ogComp = DBOgModel.findWhere(name: name) or new DBOgModel(name: name, default: true)

      new OgUsage @, ogComp

    isMysql      : -> @engineType() is 'mysql'
    isOracle     : -> @engineType() is 'oracle'
    isSqlserver  : -> @engineType() is 'sqlserver'
    isPostgresql : -> @engineType() is 'postgresql'
    engineType: ->
      engine = @get('engine')
      constant.DB_ENGINTYPE[ engine ] || engine

    getSpecifications: ->
      if @__cachedSpecifications then return @__cachedSpecifications

      that = @
      instances = @getRdsInstances()

      if not instances then return null

      spec = {}
      specArr = []

      for i in instances
        spec[i.LicenseModel] = {} if not spec[i.LicenseModel]
        spec[i.LicenseModel][i.EngineVersion] = {} if not spec[i.LicenseModel][i.EngineVersion]
        spec[i.LicenseModel][i.EngineVersion][i.DBInstanceClass] = {
          multiAZCapable: i.MultiAZCapable,
          availabilityZones: i.AvailabilityZones
        }

      for license, versions of spec
        lObj = license: license, versions: []
        for version, classes of versions
          vObj = version: version, instanceClasses: []
          instanceClassDict = {}
          for cla, az of classes
            instanceClassDict[ cla ] = multiAZCapable: az.multiAZCapable, availabilityZones: az.availabilityZones

          # Sorting and filling parameters.
          for claDict in constant.DB_INSTANCECLASS
            if _.has instanceClassDict, claDict.instanceClass
              vObj.instanceClasses.push _.extend instanceClassDict[claDict.instanceClass], claDict

          lObj.versions.push vObj

        lObj.versions.sort (a, b) -> MC.versionCompare b.version, a.version
        specArr.push lObj

      @__cachedSpecifications = specArr

      specArr

    # Get and Process License, EngineVersion, InstanceClass and multiAz
    getLVIA: (spec) ->
      if not spec then return []

      currentLicense = @get 'license'
      currentVersion = @get 'engineVersion'
      currentClass   = @get 'instanceClass'

      license = _.first _.filter spec, (s) ->
        if s.license is currentLicense
          s.selected = true
          true
        else
          delete s.selected
          false

      version = _.first _.filter license.versions, (v) ->
        if v.version is currentVersion
          v.selected = true
          true
        else
          delete v.selected
          false

      if not version
        version = @getVersionObj true
        @set 'engineVersion', version.version
        _.findWhere(license.versions, {version: version.version})?.selected = true

      instanceClass = _.first _.filter version.instanceClasses, (i) ->
        if i.instanceClass is currentClass
          i.selected = true
          true
        else
          delete i.selected
          false

      if not instanceClass
        instanceClass = @getInstanceClassObj true
        @set 'instanceClass', instanceClass.instanceClass
        _.where(version.instanceClasses, {instanceClass: instanceClass.instanceClass})?.selected = true

      multiAZCapable = instanceClass.multiAZCapable
      # Unset multiAz must before sqlserver engine judge.
      if not multiAZCapable
        @set 'multiAz', ''

      engine = @get('engine')
      multiAZCapable = true if (engine in ['sqlserver-ee', 'sqlserver-se'])


      [spec, license.versions, version.instanceClasses, multiAZCapable, instanceClass.availabilityZones]

    getCost : ( priceMap, currency )->
      if not priceMap.database then return null

      engine = @engineType()

      if engine is 'sqlserver'
        sufix = @get('engine').split('-')[1]

      dbInstanceType = @attributes.instanceClass.split('.')
      deploy = if @attributes.multiAz then 'multiAZ' else 'standard'

      if not engine or not deploy then return null

      unit = priceMap.database.rds.unit
      try
        fee = priceMap.database.rds[ engine ][ dbInstanceType[0] ][ dbInstanceType[1] ][ dbInstanceType[2] ]

        license = null
        if @attributes.license is 'license-included'
          license = 'li'
        else if @attributes.license is 'bring-your-own-license'
          license = 'byol'

        if license == 'li' and engine == 'sqlserver'
          license = license + '-' + sufix

        for p in fee
          if p.deploy != deploy
            continue
          if license and license != p.license
            continue

          fee = p[ currency ]
          break

        if not fee or typeof(fee) isnt 'number' then return null

        if unit is "pricePerHour"
          formatedFee = fee + "/hr"
          fee *= 24 * 30
        else
          formatedFee = fee + "/mo"

        priceObj =
            resource    : @attributes.name
            type        : @attributes.instanceClass
            fee         : fee
            formatedFee : formatedFee

        return priceObj

      catch err
        # console.error "Error while get database instance price", err
      finally

    category: (type) ->
      switch type
        when 'instance' then return !(@get('snapshotId') or @master())
        when 'replica' then return !!@master()
        when 'snapshot' then return !!@get('snapshotId')

      if @get 'snapshotId' then return 'snapshot'

      if @master() then 'replica' else 'instance'

    getSnapshotModel: ( snapshotId ) ->
      CloudResources(constant.RESTYPE.DBSNAP, Design.instance().region()).findWhere {
        id: snapshotId or @get( 'snapshotId' )
      }

    autobackup: ( value )->
      if value isnt undefined
        @set 'backupRetentionPeriod', value
        return

      return @get('backupRetentionPeriod') || 0

    getNewName : ()->
      args = [].slice.call arguments, 0
      args[0] = Model.getInstances().length
      ComplexResModel.prototype.getNewName.apply this, args

    isRemovable :()->
      if @slaves(true).length > 0
        if not @get("appId")
          # Return a warning, delete DBInstance will remove all ReadReplica together when DBInstance hasn't existed
          result = sprintf lang.ide.CVS_CFM_DEL_NONEXISTENT_DBINSTANCE, @get("name")
          result = "<div class='modal-text-major'>#{result}</div>"
        else
          # Return a warning, delete DBInstance will remove nonexistent ReadReplica together when DBInstance has existed
          result = sprintf lang.ide.CVS_CFM_DEL_EXISTENT_DBINSTANCE, @get("name")
          result = "<div class='modal-text-major'>#{result}</div>"
        return result
      allRestoreDB = @getAllRestoreDB()
      if allRestoreDB.length > 0
        dbNameAry = []
        _.each allRestoreDB, (dbModel) ->
          dbNameAry.push("<span class='resource-tag'>#{dbModel.get('name')}</span>")
        result = sprintf lang.ide.CVS_CFM_DEL_RELATED_RESTORE_DBINSTANCE, @get("name"), dbNameAry.join(', ')
        result = "<div class='modal-text-major'>#{result}</div>"
        return result
      true

    remove :()->
      #remove readReplica related to current DBInstance
      for slave in @slaves()
        if not slave.get("appId")
          #remove nonexistent replica
          slave.remove() if slave isnt @

      for restore in @getAllRestoreDB()
        restore.remove()

      #remove current node
      ComplexResModel.prototype.remove.call(this)
      null

    isReparentable : ( newParent )->
      if @master() and newParent.get("id") isnt @get("id")
        notification "error", "Cannot move read replica to another DBSubnetGroup."
        return false
      true

    serialize : () ->
      
      master = @master()

      useLatestRestorableTime = ''
      if @getSourceDBForRestore()
        useLatestRestorableTime = if @get('dbRestoreTime') then false else true

      restoreTime = ''
      restoreTime = @get('dbRestoreTime') if @get('dbRestoreTime')

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CreatedBy                             : @get 'createdBy'
          DBInstanceIdentifier                  : @get 'instanceId'
          NewDBInstanceIdentifier               : @get 'newInstanceId'
          DBSnapshotIdentifier                  : @get 'snapshotId'
          AllocatedStorage                      : @get 'allocatedStorage'
          AutoMinorVersionUpgrade               : @get 'autoMinorVersionUpgrade'
          AllowMajorVersionUpgrade              : @get 'allowMajorVersionUpgrade'
          AvailabilityZone                      : @get 'az'
          MultiAZ                               : @get 'multiAz'
          Iops                                  : @getIops() or 0
          BackupRetentionPeriod                 : @get 'backupRetentionPeriod'
          CharacterSetName                      : @get 'characterSetName'
          DBInstanceClass                       : @get 'instanceClass'
          DBName                                : if (@isMysql() and @get('snapshotId')) then '' else @get('dbName')
          Endpoint:
            Port   : @get 'port'
          Engine                                : @get 'engine'
          EngineVersion                         : @get 'engineVersion'
          LicenseModel                          : @get 'license'
          MasterUsername                        : @get 'username'
          MasterUserPassword                    : @get 'password'
          OptionGroupMembership:
            OptionGroupName: @connectionTargets( 'OgUsage' )[ 0 ]?.createRef 'OptionGroupName' || ""
          DBParameterGroups:
            DBParameterGroupName                : @get 'pgName'
          ApplyImmediately                      : @get 'applyImmediately'
          PendingModifiedValues                 : @get 'pending'
          PreferredBackupWindow                 : @get 'backupWindow'
          PreferredMaintenanceWindow            : @get 'maintenanceWindow'
          PubliclyAccessible                    : @get 'accessible'
          DBSubnetGroup:
            DBSubnetGroupName                   : @parent().createRef 'DBSubnetGroupName'
          VpcSecurityGroupIds                   : _.map @connectionTargets( "SgAsso" ), ( sg )-> sg.createRef 'GroupId'
          ReadReplicaSourceDBInstanceIdentifier : master?.createRef('DBInstanceIdentifier') or ''
          SourceDBInstanceIdentifierForPoint    : @getSourceDBForRestore()?.createRef('DBInstanceIdentifier') or ''
          UseLatestRestorableTime               : useLatestRestorableTime
          RestoreTime                           : restoreTime

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes: constant.RESTYPE.DBINSTANCE

    oracleCharset: ["AL32UTF8", "JA16EUC", "JA16EUCTILDE", "JA16SJIS", "JA16SJISTILDE", "KO16MSWIN949", "TH8TISASCII", "VN8MSWIN1258", "ZHS16GBK", "ZHT16HKSCS", "ZHT16MSWIN950", "ZHT32EUC", "BLT8ISO8859P13", "BLT8MSWIN1257", "CL8ISO8859P5", "CL8MSWIN1251", "EE8ISO8859P2", "EL8ISO8859P7", "EL8MSWIN1253", "EE8MSWIN1250", "NE8ISO8859P10", "NEE8ISO8859P4", "WE8ISO8859P15", "WE8MSWIN1252", "AR8ISO8859P6", "AR8MSWIN1256", "IW8ISO8859P8", "IW8MSWIN1255", "TR8MSWIN1254", "WE8ISO8859P9", "US7ASCII", "UTF8", "WE8ISO8859P1"]

    getInstances: -> @reject (obj) -> obj.master() or obj.get('snapshotId')
    getReplicas: -> @filter (obj) -> !!obj.master()
    getSnapShots: -> @filter (obj) -> !!obj.get('snapshotId')
    getDefaultOgInstance: ( name ) -> DBOgModel.findWhere( name: name, default: true ) or new DBOgModel name: name, default: true

    deserialize : ( data, layout_data, resolve ) ->
      that = @
      resource = data.resource

      model = new Model({
        id     : data.uid
        name   : data.name

        createdBy                 : resource.CreatedBy
        appId                     : resource.DBInstanceIdentifier
        instanceId                : resource.DBInstanceIdentifier
        newInstanceId             : resource.NewDBInstanceIdentifier
        snapshotId                : resource.DBSnapshotIdentifier
        allocatedStorage          : resource.AllocatedStorage
        autoMinorVersionUpgrade   : resource.AutoMinorVersionUpgrade
        allowMajorVersionUpgrade  : resource.AllowMajorVersionUpgrade
        az                        : resource.AvailabilityZone
        multiAz                   : resource.MultiAZ
        iops                      : resource.Iops
        backupRetentionPeriod     : resource.BackupRetentionPeriod
        characterSetName          : resource.CharacterSetName
        dbName                    : resource.DBName
        port                      : resource.Endpoint?.Port
        engine                    : resource.Engine
        license                   : resource.LicenseModel
        engineVersion             : resource.EngineVersion
        instanceClass             : resource.DBInstanceClass
        username                  : resource.MasterUsername
        password                  : resource.MasterUserPassword
        pending                   : resource.PendingModifiedValues
        backupWindow              : resource.PreferredBackupWindow
        maintenanceWindow         : resource.PreferredMaintenanceWindow
        accessible                : resource.PubliclyAccessible
        pgName                    : resource.DBParameterGroups?.DBParameterGroupName
        applyImmediately          : resource.ApplyImmediately

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]

        parent : resolve( layout_data.groupUId )
      })

      # Set master if model is replica
      if data.resource.ReadReplicaSourceDBInstanceIdentifier
        model.setMaster resolve MC.extractID data.resource.ReadReplicaSourceDBInstanceIdentifier

      # Asso SG
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sg in data.resource.VpcSecurityGroupIds || []
        new SgAsso( model, resolve( MC.extractID(sg) ) )

      # Asso OptionGroup
      ogName = data.resource.OptionGroupMembership?.OptionGroupName
      if ogName
        ogUid = MC.extractID(ogName)
        if ogUid and ogUid isnt ogName
          ogComp = resolve(ogUid)

        new OgUsage( model, ogComp or model.getDefaultOgInstance(ogName) )
  }

  Model
