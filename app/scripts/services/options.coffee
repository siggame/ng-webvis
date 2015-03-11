'use strict'

###*
 # @ngdoc service
 # @name webvisApp.options
 # @description
 # # options
 # Service in the webvisApp.
###
angular.module('webvisApp').service 'Options', ($rootScope, alert) ->
    # Option classes
    @CheckBox = class CheckBox
        constructor: (@type, @isChecked) ->     
        
    @Slider = class Slider
        constructor: (@type, @minimum, @maximum, @current) ->
        
    @Textbox = class Textbox
        constructor: (@type, @text) ->
            
    @Dropdown = class Dropdown
        constructor: (@type, @options, initialValue) ->
            @currentValue = initialValue
            
    # Members    
    @_options = {}    
        
    # this option page is always present for non-plugin specific options
    @_webvisOptions = [
        [   "textbox",
            "Arena Url",
            ""
        ],
        [ 
            "dropdown",
            "Mode",
            ["normal","arena"],
            "normal"
        ],
        [
            "dropdown",
            "Renderer",
            ["canvas"],
            "canvas"
        ]
    ]
    
    
    # private
    @_createOption = (init) ->
        option = null
        switch init[0]
            when "checkbox"
                option = new @CheckBox(init[0], init[2])
            when "slider"
                option = new @Slider(init[0], init[2], init[3], init[4])
            when "textbox"
                option = new @Textbox(init[0], init[2])
            when "dropdown"
                option = new @Dropdown(init[0], init[2], init[3])
        return option

    @_parsePageConstructor = (options) ->
        page = {}
        for option in options
            page[option[1]] = @_createOption(option)
        return page
    
    # public
    @addPage = (name, options) ->
        if !@_options[name]?
            if options?
                @_options[name] = @_parsePageConstructor(options)
            else
                @_options[name] = {}
            $rootScope.$broadcast('Options:pageAdded')
        else
            throw {message: "Page already exists"}
            
    @add = (page, initData) ->
        if @_options[page]?
            @_options[page] = @_createOption(initData)
        
    @get = (page, name) ->
        if @_options[page]? and @_options[page][name]?
            return @_options[page][name]
        else
            return null
    
    @getOptions = () -> @_options
    
    # constructor
    # during construction add the webvis option page
    @_options["Webvis"] = @_parsePageConstructor(@_webvisOptions)    
    
    return this