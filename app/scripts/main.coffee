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
    baseUrl: 'scripts',
    enforceDefine: true
}

define [
    'services/fileLoader'
    'services/Options'
    'controllers/alert'
    'controllers/navbar'
    'controllers/playback'
    'controllers/stageCtrl'
    'controllers/tabmenu'
    'directives/dropzone'
    'directives/fileDialog'
    'directives/game-option'
    'directives/slider'
    'directives/stage'
], ()->
    console.log("starting main.coffee");
    injector = angular.injector(['ng', 'webvisApp'])
    injector.invoke(['FileLoader', 'Options',
        (FileLoader, Options) ->
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
    ])

    webvisApp.config ($routeProvider, $provide, $compileProvider,
        $controllerProvider) ->
        webvisApp.provide = $provide
        webvisApp.compileProvider = $compileProvider
        webvisApp.controllerProvider = $controllerProvider

        $routeProvider.when '/',
            templateUrl: 'views/main.html'

        $routeProvider.otherwise
            redirectTo: '/'

    angular.bootstrap document, ['webvisApp']
