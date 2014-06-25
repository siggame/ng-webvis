'use strict'

###*
 # @ngdoc factory
 # @name webvisApp.alert
 # @description
 # # alert
 # Factory in the webvisApp.
###
app = angular.module('webvisApp')

class Alert
    constructor: (message, type) ->
        @message = message
        @type = type
        @visible = true

    isVisible: () -> @visible

    hide: () -> @visible = false

    show: () -> @visible = true


app.factory 'alert', ($timeout) ->
    console.log "Created alert factory"

    # The object we're creating with the factory
    exports = {}

    # The list of alerts
    exports.alerts = []

    # Lists all the alerts
    exports.getAlerts = () ->
        exports.alerts

    # Shows an alert of type 'type'
    exports.alert = (message, type) ->
        console.log "Add alert (#{type}) #{message}"
        a = new Alert(message, type)
        $timeout (() -> do a.hide), 2000
        exports.alerts.push a

    # Shows in alert of type 'info'
    exports.info = (message) ->
        exports.alert(message, 'info')

    # return the created object
    return exports
