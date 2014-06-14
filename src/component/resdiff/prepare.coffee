define [ 'constant' ], ( constant ) ->

    helper = ( options ) ->
        getNodeMap: ( path ) ->
            path = path.split('.') if _.isString(path)

            oldComp = options.oldAppJSON.component
            newComp = options.newAppJSON.component

            oldCompAttr = _.extend(oldComp, {})
            newCompAttr = _.extend(newComp, {})

            _.each path, (attr) ->

                if oldCompAttr

                    if _.isUndefined(oldCompAttr[attr])
                        oldCompAttr = undefined
                    else
                        oldCompAttr = oldCompAttr[attr]

                if newCompAttr

                    if _.isUndefined(newCompAttr[attr])
                        newCompAttr = undefined
                    else
                        newCompAttr = newCompAttr[attr]


            retVal =  {
                oldAttr: oldCompAttr
                newAttr: newCompAttr
            }

        getNodeData: ( path ) ->
            @getNewest @getNodeMap path

        getNewest: ( attrMap ) ->
            attrMap.newAttr or attrMap.oldAttr

        replaceArrayIndex: ( path, data ) ->
            componentMap = @getNodeMap path[0]
            component = @getNewest componentMap

            type = component.type
            parentKey = path[ path.length - 2 ]
            childNode = @getNodeData path

            # Replace according to type
            switch type
                when constant.RESTYPE.INSTANCE
                    if parentKey is 'BlockDeviceMapping'
                        data.key = childNode.DeviceName if childNode and childNode.DeviceName

                when constant.RESTYPE.ENI
                    if parentKey is 'PrivateIpAddressSet'
                        data.key = 'PrivateIpAddress'
                    else if parentKey is 'GroupSet'
                        data.key = 'SecurityGroup'

                when constant.RESTYPE.SG
                    if parentKey in [ 'IpPermissions', 'IpPermissionsEgress' ]
                        data.key = 'Rule'


            # Replace first level node
            if path.length is 1
                data.key = constant.RESNAME[ data.key ] or data.key


            data






    prepareNode = ( path, data ) ->
        _genValue = (oldValue, newValue) ->

            result = ''

            if oldValue
                result = oldValue
                if newValue and oldValue isnt newValue
                    result += (' -> ' + newValue)
            else
                result = newValue

            return result

        _getRef = (value) ->

            if _.isString(value) and value.indexOf('@{') is 0

                refRegex = /@\{.*\}/g
                refMatchAry = value.match(refRegex)
                if refMatchAry and refMatchAry.length
                    refName = value.slice(2, value.length - 1)
                    refUID = refName.split('.')[0]
                    return "#{refUID}.name" if refUID

            return null

        if _.isObject(data.value) # process end node

            # default
            newValue = data.value
            oldRef = _getRef(newValue.__old__)
            newRef = _getRef(newValue.__new__)

            newValue.__old__ = @h.getNodeMap(oldRef).oldAttr if oldRef
            newValue.__new__ = @h.getNodeMap(newRef).newAttr if newRef

            data.value = _genValue(newValue.__old__, newValue.__new__)

        else

            compAttrObj = @h.getNodeMap(path)
            oldAttr = compAttrObj.oldAttr
            newAttr = compAttrObj.newAttr

            valueRef = _getRef(data.value)
            data.value = @h.getNodeMap(valueRef).oldAttr if valueRef

            if path.length is 1

                compUID = path[0]
                oldCompName = (oldAttr.name if oldAttr) or ''
                newCompName = (newAttr.name if newAttr) or ''

                if oldAttr
                    data.key = oldAttr.type
                else
                    data.key = newAttr.type

                data.value = _genValue(oldCompName, newCompName)

            data = @h.replaceArrayIndex path, data

        if path.length is 2

            if path[1] in ['type', 'uid', 'name']
                delete data.key
            else if path[1] is 'resource'
                data.skip = true

        return data

    Prepare = ( options ) ->
        _.extend @, options
        @h = helper( options )
        @

    Prepare.prototype.node = prepareNode

    Prepare



