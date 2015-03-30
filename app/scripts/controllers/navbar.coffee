'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.controller 'NavbarCtrl', ($window, $scope, config, PluginManager) ->
    @version = config.version
    @gameName = PluginManager.getName()
    
    $scope.$on 'currentPlugin:updated', (event, data) =>
        if !$scope.$$phase
            @gameName = PluginManager.getName()
            $scope.$apply()
    
    resizeTabWindow = () ->
        window = $($window)
        $("#left-panel").height window.height()
        $("#tab-panel").height($("#left-panel").height() - $("#game-info").outerHeight(true) - 70)

    do resizeTabWindow
    
    angular.element($window).on 'resize', () ->
        do resizeTabWindow
    
    return this
