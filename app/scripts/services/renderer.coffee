'use strict'

###*
 # @ngdoc service
 # @name webvisApp.Renderer
 # @description
 # # Renderer
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')

webvisApp.service 'Renderer', ->
    ###
     # Renderer::AssetManager
     # Maintains the collection of textures and sprite sheets to be
     # referenced during draw calls.
     # INVARIANT: Imported textures never change their name during runtime.
    ###
    @AssetManager = {}
    @AssetManager.textures = {}
    @AssetManager.sheetData = {}

    # Renderer::AssetManager::loadTexture(fileName)
    # param filename (String) - name of the asset to search for on the server
    @AssetManager.loadTexture = (fileName) ->
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

    # Renderer::AssetManager::loadTextures(fileNames)
    # param filename (Array[String]) - array of asset names to search for on
    #   the server
    @AssetManager.loadTextures = (fileNames) ->
            for filename in fileNames
                @loadTexture filename

    # Renderer::AssetManager::getTexture(fileName)
    # param fileName (String) - name of the asset to retrieve from cache
    @AssetManager.getTexture = (fileName) ->
            return @textures[fileName]

    # Renderer::AssetManager::getSheetData(fileName)
    # param fileName (String) - name of the meta data object for a
    #   corresponding sprite shee of the same name in the cache
    @AssetManager.getSheetData = (fileName) ->
            return @sheetData[fileName]

    ###
     # Renderer::Point
     # represents a single 3D point. The z parameter can be
     # ignored for use as a 2D point.
    ###
    @Point = class Point
        constructor: (x, y, z) ->
            if x? then @x = x else @x = 0.0
            if y? then @y = y else @y = 0.0
            if z? then @z = z else @z = 0.0
            @w = 1


    ###
     # Renderer::Matrix3x3
     # A matrix with 3 rows and 3 columns, sometimes used for
     # 2D projections and transformations.
    ###
    @Matrix3x3 = class Matrix3x3
        constructor: () ->
            @elements = []
            for index in [0..8]
                @elements[index] = 0.0
            for index in [0..2]
                @elements[index*4+index] = 1.0

        #Matrix3x3::get(x , y)
        #param x (integer) - the column you wish to access at
        #param y (integer) - the row you wish to access at
        #return (real) - the value at the row and column specified
        get: (x, y) ->
            if x < 0 or x > 2 or y < 0 or y > 2
                throw {errorStr: "Matrix out of bounds"}
            @elements[y*3 + x]

        #Matrix3x3::set(x, y, val)
        #param x (integer) - the column you wish to access at
        #param y (integer) - the row you wish to access at
        #param val (real) - the value you will set the variable to at the
        #   specified row and column
        set: (x, y, val) ->
            if x < 0 or x > 2 or y < 0 or y > 2
                throw {errorStr: "Matrix out of bounds"}
            @elements[y*3 + x] = val

    ###
     # Renderer::Matrix4x4
     # A Matrix with 4 rows and 4 columns. Used for transform matrices.
    ###
    @Matrix4x4 = class Matrix4x4
        constructor: () ->
            @elements = []
            for index in [0..15]
                @elements[index] = 0.0
            for index in [0..3]
                @elements[index*4+index] = 1.0

        #Matrix4x4::get(x, y)
        #param x (integer) - the column you wish to access at
        #param y (integer) - the row you wish to access at
        #return (real) - the value at the row and column specified
        get: (x, y) ->
            if x < 0 or x > 3 or y < 0 or y > 3
                throw {errorStr: "Matrix out of bounds"}
            @elements[y*4 + x]

        #Matrix4x4::set(x, y, val)
        #param x (integer) - the column you wish to access at
        #param y (integer) - the row you wish to access at
        #param val (real) - the value you will set the variable to at the
        #   specified row and column
        set: (x, y, val) ->
            if x < 0 or x > 3 or y < 0 or y > 3
                throw {errorStr: "Matrix out of bounds"}
            @elements[y*4 + x] = val


    ###
     # Renderer::Line
     # A line. (duh)
    ###
    @Line = class Line
        constructor: (p1, p2) ->
            if p1? then @p1 = p1 else @p1 = new Point
            if p2? then @p2 = p2 else @p2 = new Point

    ###
     # Renderer::Color
     # represents a color with normalized RGBA value
     # where 0.0 is none of that color and 1.0 is
     # the max value for that color.
     # Ex. Color(1.0, 1.0, 0.0, 1.0) is yellow
    ###
    @Color = class Color
        constructor: (r, g, b, a) ->
            if r? then @r = r else @r = 1.0
            if g? then @g = g else @g = 1.0
            if b? then @b = b else @b = 1.0
            if a? then @a = a else @a = 1.0

        # returns a string with the CSS color value.
        # Ex. Color(1.0, 1.0, 0.0, 1.0) will return "#FFFF00"
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

    ###
     # Renderer::Sprite
     # Represents a sprite image to be rendered to the screen.
     # @Texture is a string which is used to retrieve the texture from @AssetManager
    ###
    @Sprite = class Sprite
        constructor: () ->
            @texture = null
            @frame = 0
            @position = new Point(0, 0, 0)
            @anchor = new Point(0, 0, 0)
            @width = 0.0
            @height = 0.0
            @texCoords = new Point(0, 0, 0)
            @texWidth = 1.0
            @texHeight = 1.0
            @color = new Color(0, 0, 0, 0)

    ###
     # Renderer::Rect
     # Represents a rectangle to be rendered to the screen.
    ###
    @Rect = class Rect
        constructor: () ->
            @position = new Point(0, 0, 0)
            @width = 0.0
            @height = 0.0
            @depth = 0.0
            @strokeColor = new Color(0, 0, 0, 0)
            @fillColor = new Color(0, 0, 0, 0)

    ###
     # Renderer::Path
     # Represents a path, (a sequence of interconnected lines), to be rendered
     #  to the screen
    ###
    @Path = class Path
        constructor: () ->
            @curPos = new Point(0, 0, 0)
            @points = []
            @strokeColor = new Color(0, 0, 0, 0)
            @fillColor = new Color(0, 0, 0, 0)

        # Path::moveTo(x, y)
        # Moves to the point specified without drawing.
        # param x (real) - the x value of the next point to move to
        # param y (real) - the y value of the next point to move to
        moveTo: (x, y) ->
            @curPos.x = x
            @curPos.y = y

        # Path::lineTo(x, y)
        # Moves to the point and draw a line to it from the last point. If this
        #   is the first point, the it only moves to the point specified.
        # param x (real) - the x value of the point to draw a line to
        # param y (real) - the y value of the point to draw a line to
        lineTo: (x, y) ->
            @points.push(new Line(@curPos, new Point(x, y)))
            moveTo(x, y)

    ###
     # Renderer::BaseRenderer
     # This is the interface that all renderers must adhere to.
    ###
    @BaseRenderer = class BaseRenderer
        constructor: (canvas, worldWidth, worldHeight) ->

        # BaseRenderer::resizeWorld(worldWidth, worldHeight)
        # Resizes the coordinate system scale within the view.
        # Ex. if you call resizeWorld(20, 40) a point at the middle of the
        #   screen is located at Point(10, 20).
        # param worldWidth (real) - the width bound of the coordinate system
        # param worldHeight (real) - the height bound of the coordinate system
        resizeWorld: (worldWidth, worldHeight) ->
            throw {errorStr: "Function not implemented"}

         # BaseRenderer:setClearColor(color)
         # Sets the color that the background is cleared to on resizes.
         # param color (Renderer::Color) - The color that the drawing area
         # will be cleared to on begin and resize calls.
        setClearColor: (color) ->
            throw {errorStr: "Function not implemented"}

         # BaseRenderer::begin(color)
         # Clears the drawing area to the color specified.
         # param color (Renderer::Color) - The color that the drawing area
         #   will be cleared to.
        begin: (color) ->
            throw {errorStr: "Function not implemented"}

        # BaseRenderer::drawLine(line, color)
        # Draws the line object to the screen.
        # param line (Renderer::Line) - The line to be drawn
        # param color (Renderer::Color) - the color the drawn line will be.
        drawLine: (line, color) ->
            throw {errorStr: "Function not implemented"}

        # BaseRenderer::drawSprite(sprite)
        # Draws the sprite object to the screen.
        # param line (Renderer::Sprite) - the sprite to be drawn
        drawSprite: (sprite) ->
            throw {errorStr: "Function not implemented"}

        # BaseRenderer::drawSprite(sprite)
        # Draws the path object to the screen.
        # param line (Renderer::Path) - the path to be drawn
        drawPath: (path) ->
            throw {errorStr: "Function not implemented"}

        # BaseRenderer::drawRect(sprite)
        # Draws the Rectangle to the screen.
        # param line (Renderer::Rect) - the rectangle to be drawn.
        drawRect: (rect) ->
            throw {errorStr: "Function not implemented"}

    ###
     # Renderer::CanvasRenderer
     # This is an implementation of the Renderer::BaseRenderer interface that
     # utilizes the HTML5 Canvas drawing API for rendering.
    ###
    @CanvasRenderer = class CanvasRenderer extends @BaseRenderer
        constructor: (@canvas, @worldWidth, @worldHeight, @clearColor) ->
            @context = @canvas.getContext("2d")
            if !@context?
                throw {errorStr: "Could not get a 2d render context"}
            @Projection = new Matrix3x3
            @Projection.set(0, 0, 1/@worldWidth)
            @Projection.set(1, 1, 1/@worldHeight)
            @Projection.set(0, 0, 1/@worldWidth)
            @Projection.set(1, 1, 1/@worldHeight)

        # CanvasRenderer::resizeWorld(worldWidth, worldHeight)
        # See doc for BaseRenderer::resizeWorld(worldWidth, worldHeight)
        resizeWorld: (@worldWidth, @worldHeight) ->

        # CanvasRenderer::begin(color)
        # See doc for BaseRenderer::begin(color)
        begin: () ->
            @canvas.width = @canvas.width
            @context.beginPath()
            @context.fillStyle = @clearColor.toCSS()
            @context.strokeStyle = @clearColor.toCSS()
            @context.lineWidth = "1"

            x = 0
            y = 0
            w = @canvas.width
            h = @canvas.height

            @context.rect x, y, w, h
            @context.stroke()
            @context.fill()
            console.log

        # CanvasRenderer::setClearColor(color)
        # See doc for BaseRenderer::setClearColor(color)
        setClearColor: (color) ->
            @clearColor = color

        # CanvasRenderer::drawSprite(sprite)
        # See doc for BaseRenderer::drawSprite(sprite)
        drawSprite: (sprite) ->
            t = null
            if sprite.texture != null
                t = Renderer.AssetManager.getTexture sprite.texture

            if t?
                sheetData = Renderer.AssetManager.getSheetData sprite.texture
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

        # CanvasRenderer::drawLine(line)
        # See doc for BaseRenderer::drawLine(line)
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

        # CanvasRenderer::drawPath(path)
        # See doc for BaseRenderer::drawPath(path)
        drawPath: (path) ->
            throw {errorStr: "CanvasRenderer::drawPath(path) not yet
                implemented!"}

        # CanvasRenderer::drawRect(rect)
        # See doc for BaseRenderer::drawRect(rect)
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


    @WebGLRenderer = class WebGLRenderer extends @BaseRenderer
        constructor: (@canvas, @worldWidth, @worldHeight, experimental) ->
            throw {errorStr: "WebGLRenderer not yet implemented"}

    @autoDetectRenderer = (canvas, worldWidth, worldHeight) ->
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
                console.error "WebGLRenderer not yet implemented. Returning
                    CanvasRenderer instead."
        else
            console.error "WebGLRenderer not yet implemented. Returning
                CanvasRenderer instead."

    return this
