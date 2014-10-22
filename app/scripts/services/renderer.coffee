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
        @sheetData = {}
        
    loadTexture: (fileName) ->
        img = document.createElement 'img'
        img.src = fileName
        @textures[fileName] = img
        baseUrl = window.location.href.replace("/#/", "/")
        u = baseUrl + fileName.replace(".png", ".json")
        $.ajax({
            dataType: "json"
            url: u,
            data: null,
            success: (data) =>
                @sheetData[fileName] = data
            })
            
    loadTextures: (fileNames) ->
        for filename in fileNames
            @loadTexture filename
            
    getTexture: (fileName) ->
        return @textures[fileName]
    
    getSheetData: (fileName) ->
        return @sheetData[fileName]

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
        @frame = 0
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
 
    begin: (color) ->
        throw {errorStr: "Function not implemented"}
    
    drawLine: (line, color) ->
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
            @AssetManager = new Renderer.AssetManager
            
        resizeWorld: (@worldWidth, @worldHeight) ->
            
        begin: (color) ->
            @canvas.width = @canvas.width
            
        drawSprite: (sprite) ->
            t = null
            if sprite.texture != null
                t = @AssetManager.getTexture sprite.texture
                
            if t?
                sheetData = @AssetManager.getSheetData sprite.texture
                if !sheetData?
                    u = sprite.texCoords.x * t.width
                    v = sprite.texCoords.y * t.height
                    uWidth = sprite.texWidth * t.width
                    vHeight = sprite.texHeight * t.height
                else
                    spriteResX = t.width / sheetData.width
                    spriteResY = t.height / sheetData.height
                    row = parseInt(sprite.frame / sheetData.width)
                    column = sprite.frame % sheetData.width
                    u = (column * spriteResX) + 
                        (sprite.texCoords.x * spriteResX)
                    v = (row * spriteResY) + 
                        (sprite.texCoords.y * spriteResY)
                    uWidth = (spriteResX * sprite.texWidth) - 1
                    vHeight = (spriteResY * sprite.texHeight) - 1
                
                x = @Projection.get(0, 0) * sprite.position.x +
                    @Projection.get(1, 0) * sprite.position.y +
                    @Projection.get(2, 0) * sprite.position.z
                
                y = @Projection.get(0, 1) * sprite.position.x +
                    @Projection.get(1, 1) * sprite.position.y +
                    @Projection.get(2, 1) * sprite.position.z
                
                w = @Projection.get(0, 0) * sprite.width +
                    @Projection.get(1, 0) * sprite.height +
                    @Projection.get(2, 0) * 0
                    
                h = @Projection.get(0, 1) * sprite.width +
                    @Projection.get(1, 1) * sprite.height +
                    @Projection.get(2, 1) * 0
                    
                x = Math.round(x * @canvas.width)
                y = Math.round(y * @canvas.height)
                w = Math.round(w * @canvas.width)
                h = Math.round(h * @canvas.height)
                    
                @context.drawImage t, u, v, uWidth, vHeight,
                    x, y, w, h

        drawLine: (line) ->
            @context.beginPath()
            @context.strokeStyle = "#000000"
            @context.lineWidth = "1"
            
            x1 = @Projection.get(0, 0) * line.p1.x +
                @Projection.get(1, 0) * line.p1.y +
                @Projection.get(2, 0) * line.p1.z 
                
            y1 = @Projection.get(0, 1) * line.p1.x +
                @Projection.get(1, 1) * line.p1.y +
                @Projection.get(2, 1) * line.p1.z
                
            x2 = @Projection.get(0, 0) * line.p2.x +
                @Projection.get(1, 0) * line.p2.y +
                @Projection.get(2, 0) * line.p2.z 
                
            y2 = @Projection.get(0, 1) * line.p2.x +
                @Projection.get(1, 1) * line.p2.y +
                @Projection.get(2, 1) * line.p2.z
            
            x1 = parseInt(x1 * @canvas.width) + 0.5
            y1 = parseInt(y1 * @canvas.height) + 0.5
            x2 = parseInt(x2 * @canvas.width) + 0.5
            y2 = parseInt(y2 * @canvas.height) + 0.5
            
            @context.moveTo x1, y1 
            @context.lineTo x2, y2
            @context.stroke()

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
            
            w = @Projection.get(0, 0) * rect.width +
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
            @AssetManager = new Renderer.AssetManager
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
