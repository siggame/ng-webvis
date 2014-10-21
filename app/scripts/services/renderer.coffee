'use strict'

###*
 # @ngdoc service
 # @name webvisApp.Renderer
 # @description
 # # Renderer
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')

Renderer = {}
Renderer.AssetManager = class AssetManager
    constructor: () ->
        @textures = {}
        
    loadTexture: (fileName) ->
        # if the texture doesn't exist in @textures then load it
        # and then return the texture
        # else just return the texture

Renderer.Point = class Point
    constructor: (x, y, z) ->
        if x? then @x = x else @x = 0.0
        if y? then @y = y else @y = 0.0
        if z? then @z = z else @z = 0.0
        @w = 1

Renderer.Matrix3x3 = class Matrix3x3
    constructor: () ->
        @elements = []
        for index in [0..8]
            @elements[index] = 0.0
        for index in [0..2]
            @elements[index*4+index] = 1.0

    get: (x, y) ->
        if x < 0 or x > 2 or y < 0 or y > 2
            throw {errorStr: "Matrix out of bounds"}
        @elements[y*3 + x]
        
    set: (x, y, val) ->
        if x < 0 or x > 2 or y < 0 or y > 2
            throw {errorStr: "Matrix out of bounds"}
        @elements[y*3 + x] = val
                
Renderer.Matrix4x4 = class Matrix4x4
    constructor: () ->
        @elements = []
        for index in [0..15]
            @elements[index] = 0.0
        for index in [0..3]
            @elements[index*4+index] = 1.0
            
    get: (x, y) ->
        if x < 0 or x > 3 or y < 0 or y > 3
            throw {errorStr: "Matrix out of bounds"}
        @elements[y*4 + x] 
        
    set: (x, y, val) ->
        if x < 0 or x > 3 or y < 0 or y > 3
            throw {errorStr: "Matrix out of bounds"}
        @elements[y*4 + x] = val


Renderer.Line = class Line
    constructor: (p1, p2) ->
        if p1? then @p1 = p1 else @p1 = new Point
        if p2? then @p2 = p2 else @p2 = new Point

Renderer.Color = class Color
    constructor: (r, g, b, a) ->
        if r? then @r = r else @r = 1.0
        if g? then @g = g else @g = 1.0
        if b? then @b = b else @b = 1.0
        if a? then @a = a else @a = 1.0
        
    toCSS: ()->
        r = parseInt(@r * 255)
        r = r.toString(16)
        if r.length == 1 then r = "0"+r
        g = parseInt(@g * 255)
        g = g.toString(16)
        if g.length == 1 then g = "0"+g
        b = parseInt(@b * 255)
        b = b.toString(16)
        if b.length == 1 then b = "0"+b
        a = parseInt(@a * 255)
        a = a.toString(16)
        if a.length == 1 then a = "0"+a
        return "#" + r + g + b

Renderer.Sprite = class Sprite
    constructor: () ->
        @texture = null
        @position = new Point
        @anchor = new Point
        @width = 0.0
        @height = 0.0
        @texCoords = new Point
        @texWidth = 1.0
        @texHeight = 1.0
        @color = new Color
        
Renderer.Rect = class Rect
    constructor: () ->
        @position = new Point
        @width = 0.0
        @height = 0.0
        @depth = 0.0
        @strokeColor = new Color
        @fillColor = new Color
        
Renderer.Path = class Path
    constructor: () ->
        @curPos = new Point
        @points = []
        @strokeColor = new Color
        @fillColor = new Color
    
    moveTo: (x, y) ->
        @curPos.x = x
        @curPos.y = y
        
    lineTo: (x, y) ->
        @points.push(new Line(curPos, new Point(x, y)))
        moveTo(x, y)
    
Renderer.BaseRenderer = class BaseRenderer
    constructor: (canvas, worldWidth, worldHeight) ->
    
    resizeWorld: (worldWidth, worldHeight) ->
        throw {errorStr: "Function not implemented"}
 
    setColor: (color) ->
        throw {errorStr: "Function not implemented"}
    
    drawSprite: (sprite) ->
        throw {errorStr: "Function not implemented"}
    
    drawPath: (path) ->
        throw {errorStr: "Function not implemented"}
    
    drawRect: (rect) ->
        throw {errorStr: "Function not implemented"}
    
Renderer.CanvasRenderer = class CanvasRenderer extends 
    Renderer.BaseRenderer
        constructor: (@canvas, @worldWidth, @worldHeight) ->
            @context = @canvas.getContext("2d")
            if !@context?
                throw {errorStr: "Could not get a 2d render context"}
            @Projection = new Matrix3x3
            @Projection.set(0, 0, 1/@worldWidth)
            @Projection.set(1, 1, 1/@worldHeight)
            @Projection.set(0, 0, 1/@worldWidth)
            @Projection.set(1, 1, 1/@worldHeight)
            
        resizeWorld: (@worldWidth, @worldHeight) ->
           
        setColor: (color) ->   
            
        drawSprite: (sprite) ->

        drawPath: (path) ->
        
        drawRect: (rect) ->
            @context.beginPath()
            @context.fillStyle = rect.fillColor.toCSS()
            @context.strokeStyle = rect.strokeColor.toCSS()
            @context.lineWidth = "1"
            
            x = @Projection.get(0, 0) * rect.position.x +
                @Projection.get(1, 0) * rect.position.y +
                @Projection.get(2, 0) * rect.position.z
                
            y = @Projection.get(0, 1) * rect.position.x +
                @Projection.get(1, 1) * rect.position.y +
                @Projection.get(2, 1) * rect.position.z
            
            w = @Projection.get(0,0) * rect.width +
                @Projection.get(1, 0) * rect.height +
                @Projection.get(2, 0) * 0
                
            h = @Projection.get(0, 1) * rect.width +
                @Projection.get(1, 1) * rect.height +
                @Projection.get(2, 1) * 0
            
            x *= @canvas.width
            y *= @canvas.height
            w *= @canvas.width
            h *= @canvas.height
            
            @context.rect x, y, w, h
            @context.stroke()
            @context.fill()
                
        draw: () ->
            

Renderer.WebGLRenderer = class WebGLRenderer extends 
    Renderer.BaseRenderer
        constructor: (@canvas, @worldWidth, @worldHeight, experimental) ->
            @Projection = new Matrix4x4
            @Projection.set(0,0, 2/@width)
            @Projection.set(1,1, 2/@height)
            @Projection.set(2,2, 2/100)
            @Projection.set(3,0, -1)
            @Projection.set(3,1, -1)
            @Projection.set(3,2, -1)
            
            @View = new Matrix4x4
            
Renderer.autoDetectRenderer = (canvas, worldWidth, worldHeight) ->
    context = canvas.getContext "webgl"
    if !context?
        context = canvas.getContext "experimental-webgl"
        if !context?
            context = canvas.getContext "2d"
            if !context?
                throw {errorStr: "Failed to initialize renderer"}
            else
                return new Renderer.CanvasRenderer(canvas, worldWidth, 
                    worldHeight)
        else
            return new Renderer.WebGLRenderer(canvas, worldWidth, 
                worldHeight, true)
    else
        return new Renderer.WebGLRenderer(canvas, worldWidth, 
            worldHeight, false)
        
            
            
            
webvisApp.service 'Renderer', ->            
    return Renderer
