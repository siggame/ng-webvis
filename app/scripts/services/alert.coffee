'use strict'

###*
 # @ngdoc factory
 # @name webvisApp.alert
 # @description
 # # alert
 # Factory in the webvisApp.
###
app = angular.module('webvisApp')

app.factory 'alert', ($timeout, $log, config) ->

    class Alert
        constructor: (message, type) ->
            @message = message
            @type = type
            do @show

        toString: () ->
            "(#{@type}) #{@message}"

        isVisible: () -> @visible

        hide: () ->
            $log.debug "Hiding #{@toString()}"
            @visible = false

        show: () ->
            $log.debug "Showing #{@toString()}"
            @visible = true

        hideAfter: (timeout) ->
            $timeout (() => do @hide), timeout

    # The object we're creating with the factory
    exports = {}

    # The list of alerts
    exports.alerts = []

    # Lists all the alerts
    exports.getAlerts = () ->
        exports.alerts

    # Shows an alert of type 'type'
    exports.alert = (message, type) ->
        a = new Alert(message, type)
        a.hideAfter(config.alert.timeoutAfter)
        exports.alerts.push a
        return a

    # Shows an alert of type 'success'
    exports.success = (message) ->
        exports.alert(message, 'success')

    # Shows an alert of type 'info'
    exports.info = (message) ->
        exports.alert(message, 'info')

    # Shows an alert of type 'warning'
    exports.warning = (message) ->
        exports.alert(message, 'warning')

    # Shows an alert of type 'error'
    exports.error = (message) ->
        exports.alert(message, 'danger')

    # return the created object
    return exports