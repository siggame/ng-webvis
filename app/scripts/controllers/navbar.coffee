'use strict'

NavbarCtrl = ($window, $scope, config, PluginManager) ->
    $scope.version = config.version
    $scope.gameName = PluginManager.getName()

    $scope.$on 'currentPlugin:updated', (event, data) =>
        if !$scope.$$phase
            @gameName = PluginManager.getName()
            $scope.$apply()

    resizeTabWindow = () ->
        panel = $("#tab-panel")
        parentHeight = panel.parent().height();

        adjust = parseInt(panel.css('margin-top'), 10) +
            parseInt(panel.css('margin-bottom'), 10) +
            parseInt(panel.css('border-top'), 10) +
            parseInt(panel.css('border-bottom'), 10) +
            parseInt(panel.css('padding-top'), 10) +
            parseInt(panel.css('padding-bottom'), 10)

        panel.parent().children().not(panel).each ()->
            adjust += $(this).height()

        panel.height(parentHeight - adjust)

    do resizeTabWindow

    angular.element($window).on 'resize', () ->
        do resizeTabWindow

NavbarCtrl.$inject = ['$window', '$scope', 'config', 'PluginManager']
webvisApp = angular.module 'webvisApp'
webvisApp.controller 'NavbarCtrl', NavbarCtrl