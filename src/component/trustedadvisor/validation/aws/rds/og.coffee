define [ 'constant', 'MC', 'Design', 'TaHelper', 'CloudResources' ], ( constant, MC, Design, Helper, CloudResources ) ->
    i18n = Helper.i18n.short()


    unusedOgWontCreate = ( callback ) ->

        ogUnused = Design.modelClassForType(constant.RESTYPE.DBOG).filter (og) ->
            not (og.isDefault() or og.connections().length)

        if not ogUnused.length
            callback null
            return null

        taId = ''
        nameStr = ''

        for og in ogUnused
            nameStr += "<span class='validation-tag'>#{og.get('name')}</span>, "
            taId += og.id

        nameStr = nameStr.slice 0, -2
        callback Helper.message.warning taId, i18n.WARNING_RDS_UNUSED_OG_NOT_CREATE, nameStr

        null

    isOGExeedCountLimit = ( callback ) ->

        try

            if not callback
                callback = () ->

            existOGModels = Design.modelClassForType(constant.RESTYPE.DBOG).allObjects()
            customOGModels = _.filter existOGModels, (model) ->
                return true if (not model.get('default') and not model.get('createdBy'))

            if customOGModels.length

                region = Design.instance().get('region')
                regionName = constant.REGION_SHORT_LABEL[region]

                ogModels = CloudResources Design.instance().credentialId(), constant.RESTYPE.DBOG, region
                ogModels.fetchForce().then (ogCol) ->
                    customOgAry = ogCol.filter (model) -> model.get('id').indexOf('default:') isnt 0
                    if customOgAry.length + customOGModels.length > 20
                        callback Helper.message.error '', i18n.ERROR_RDS_OG_EXCEED_20_LIMIT, regionName
                    else
                        callback(null)
                , (err) ->
                    callback(null)

            else

                callback(null)

        catch err

            callback(null)

    # unusedOgWontCreate: unusedOgWontCreate
    isOGExeedCountLimit: isOGExeedCountLimit