####################################
#  Controller for base_main
####################################

define [ 'jquery', 'underscore', 'UI.notification' ], ( $, _ ) ->

    #error_repeat = 0
    error_repeat = {}
    error_repeat.header     = 0
    error_repeat.tabbar     = 0
    error_repeat.navigation = 0
    ###
    count = 0
    count = {}
    count.header     = 0
    count.tabbar     = 0
    count.navigation = 0
    ###

    #private
    loadSuperModule = ( target, type, View, callback ) ->

        console.log 'loadSuperModule, type = ' + type

        try
            ###
            TureView   = if count[ type ] is 0 then undefined else View
            count.header = 1
            count.tabbar = 0
            count.navigation = 1
            return new TureView()
            ###
            return new View()
        catch error
            console.log error
            error_repeat[ type ] = error_repeat[ type ] + 1
            if error_repeat[ type ] < 4
                notification 'warning', "Load #{ type } module failed, reload after 5 seconds.", true
                _.delay () ->
                    target()
                , 5 * 1000
            else
                notification 'error', "Network problems have happened, #{ type } module Load failed.", true
            return null

        null

    #public
    loadSuperModule   : loadSuperModule