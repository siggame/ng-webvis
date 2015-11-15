'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the webvisApp
###

webvisApp = angular.module 'webvisApp', [
    'ngCookies'
    'ngSanitize'
    'ngRoute'
    'ui.bootstrap'
]

requirejs.config {
    enforceDefine: true
}

# configure routing for angularjs and attach lazy load providers
webvisApp.config ($routeProvider, $provide, $compileProvider,
    $controllerProvider) ->
    webvisApp.provide = $provide
    webvisApp.compileProvider = $compileProvider
    webvisApp.controllerProvider = $controllerProvider

    $routeProvider.when '/',
        templateUrl: 'views/main.html'

    $routeProvider.otherwise
        redirectTo: '/'

webvisApp.run ($injector) ->
    webvisApp.injector = $injector

    startup = (FileLoader, Options) ->
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

                $.ajax
                    dataType: "text",
                    url: "http://" + option.text + "/api/next_game/"
                    data: null,
                    success: (data) ->
                        FileLoader.loadFromUrl decodeURIComponent(data)

            else if params.logUrl?
                FileLoader.loadFromUrl decodeURIComponent(params.logUrl)

    startup.$inject = ['FileLoader', 'Options']
    webvisApp.injector.invoke(startup)







