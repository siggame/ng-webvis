'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the webvisApp
###
webvisApp = angular.module('webvisApp')

webvisApp.controller 'MainCtrl', ($rootScope, $scope, FileLoader, Options) ->
    getUrlParams = () ->
        params = {}
        query = window.location.hash.split("?")[1]
        if query?
            pairs = query.split("&")
            for st in pairs
                pair = st.split("=")
                if !params[pair[0]]?
                    params[pair[0]] = pair[1]
                else if typeof params[pair[0]] is 'string'
                    arr = [params[pair[0]], pair[1]]
                    params[pair[0]] = arr
                else
                    params[pair[0]].push pair[1]
        return params

    params = getUrlParams()

    if params.arena? and params.arena == "true"
        option = Options.get 'Webvis', 'Mode'
        option.currentValue = 'arena'

        option = Options.get 'Webvis', 'Arena Url'

        FileLoader.loadFromUrl(option.text + "/api/next_game/")

    else if params.logUrl?
        FileLoader.loadFromUrl decodeURIComponent(params.logUrl)


    return this
