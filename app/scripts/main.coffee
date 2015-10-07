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

define [
    # controllers
    'scripts/controllers/alert'
    'scripts/controllers/navbar'
    'scripts/controllers/playback'
    'scripts/controllers/stageCtrl'
    'scripts/controllers/tabmenu'

    # services
    'scripts/services/alert'
    'scripts/services/config'
    'scripts/services/fileLoader'
    'scripts/services/game'
    'scripts/services/options'
    'scripts/services/parser'
    'scripts/services/pluginmanager'
    'scripts/services/renderer'

    #directives
    'scripts/directives/dropzone'
    'scripts/directives/fileDialog'
    'scripts/directives/game-option'
    'scripts/directives/slider'
    'scripts/directives/stage'
], (AlertCtrl, NavbarCtrl, PlaybackCtrl, StageCtrl, TabmenuCtrl, alert,
     config, fileLoader, game, options, parser, pluginmanager,
    renderer, dropzone, fileDialog, gameOption, slider, stage)->

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

        # create all angular apparatus (yay alliteration!)
        webvisApp.controller 'AlertCtrl', AlertCtrl
        webvisApp.controller 'NavbarCtrl', NavbarCtrl
        webvisApp.controller 'PlaybackCtrl', PlaybackCtrl
        webvisApp.controller 'StageCtrl', StageCtrl
        webvisApp.controller 'TabmenuCtrl', TabmenuCtrl

        webvisApp.factory 'alert', alert
        webvisApp.factory 'config', config
        webvisApp.service 'FileLoader', fileLoader
        webvisApp.service 'Game', game
        webvisApp.service 'Options', options
        webvisApp.factory 'Parser', parser
        webvisApp.service 'PluginManager', pluginmanager
        webvisApp.service 'Renderer', renderer

        webvisApp.directive 'dropzone', dropzone
        webvisApp.directive 'fileDialog', fileDialog
        webvisApp.directive 'gameOption', gameOption
        webvisApp.directive 'slider', slider
        webvisApp.directive 'stage', stage

        angular.bootstrap document, ['webvisApp']
        # check for URI and decide whether to load from URL, start the arena,
        # or await input

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

                    FileLoader.loadFromUrl(option.text + "/api/next_game/")

                else if params.logUrl?
                    FileLoader.loadFromUrl decodeURIComponent(params.logUrl)

        startup.$inject = ['FileLoader', 'Options']
        webvisApp.injector.invoke(startup)




