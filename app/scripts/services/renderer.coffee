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
    @AssetManager = class AssetManager
        constructor: ->
            @loaded = false
            @textures = {}
            @sheetData = {}

        # Renderer::AssetManager::loadTexture(fileName)
        # param filename (String) - name of the asset to search for on the server
        loadTextures: (pluginName, onloadCallback) ->
            @loaded = false
            @textures = {}
            @sheetData = {}
            u = "/plugins/" + pluginName + "/resources.json"
            $.ajax
                dataType: "json",
                url: u,
                data: null,
                complete: (jqxhr, textStatus) =>
                    console.log textStatus
                success: (data) =>
                    console.log "recieved"
                    numPictures = data.resources.length
                    for resource in data.resources
                        img = document.createElement 'img'
                        img.src = "/plugins/" + pluginName + "/images/" + resource.image
                        @textures[resource.id] = img

                        img.onload = () =>
                            numPictures--;
                            if numPictures == 0
                                @loaded = true
                                onloadCallback()

                        if resource.spriteSheet != (null)
                            u = "/plugins/" + pluginName + "/images/" + resource.spriteSheet
                            $.ajax
                                dataType: "json",
                                url: u,
                                data: null,
                                success: (data) =>
                                    @sheetData[resource.id] = data
                 error: (jqxhr, textStatus, errorThrown)->
                    console.log textStatus + " " + errorThrown

        isLoaded: () -> @loaded

        # Renderer::AssetManager::getTexture(fileName)
        # param fileName (String) - name of the asset to retrieve from cache
        getTexture: (fileName) ->
            return @textures[fileName]

        # Renderer::AssetManager::getSheetData(fileName)
        # param fileName (String) - name of the meta data object for a
        # corresponding sprite shee of the same name in the cache
        getSheetData: (fileName) ->
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
        constructor: (param) ->
            @elements = []
            if !param?
                for index in [0..8]
                    @elements[index] = 0.0
                for index in [0..2]
                    @elements[index*3+index] = 1.0
            else
                for i in [0..8]
                    @elements[i] = param.elements[i]

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

        copy: (mat) ->
            for i in [0..8]
                @elements[i] = mat.elements[i]

        mul: (point, param2) ->
            if !param2?
                # called as mul : (Point point) ->
                x = (@elements[0] * point.x) + (@elements[1] * point.y) + @elements[2]
                y = (@elements[3] * point.x) + (@elements[4] * point.y) + @elements[5]
            else
                # called as mul : (x, y) ->
                xt = point
                yt = param2
                x = (@elements[0] * xt) + (@elements[1] * yt) + @elements[2]
                y = (@elements[3] * xt) + (@elements[4] * yt) + @elements[5]
            return [x, y]

        mulMat: (mat) ->
            m = new Matrix3x3()
            m.elements[0] = (@elements[0] * mat.elements[0]) +
                            (@elements[1] * mat.elements[3]) +
                            (@elements[2] * mat.elements[6])

            m.elements[1] = (@elements[0] * mat.elements[1]) +
                            (@elements[1] * mat.elements[4]) +
                            (@elements[2] * mat.elements[7]) +

            m.elements[2] = (@elements[0] * mat.elements[2]) +
                            (@elements[1] * mat.elements[5]) +
                            (@elements[2] * mat.elements[8])

            m.elements[3] = (@elements[3] * mat.elements[0]) +
                            (@elements[4] * mat.elements[3]) +
                            (@elements[5] * mat.elements[6])

            m.elements[4] = (@elements[3] * mat.elements[1]) +
                            (@elements[4] * mat.elements[4]) +
                            (@elements[5] * mat.elements[7])

            m.elements[5] = (@elements[3] * mat.elements[2]) +
                            (@elements[4] * mat.elements[5]) +
                            (@elements[5] * mat.elements[8])

            m.elements[6] = (@elements[6] * mat.elements[0]) +
                            (@elements[7] * mat.elements[3]) +
                            (@elements[8] * mat.elements[6])

            m.elements[7] = (@elements[6] * mat.elements[1]) +
                            (@elements[7] * mat.elements[4]) +
                            (@elements[8] * mat.elements[7])

            m.elements[8] = (@elements[6] * mat.elements[2]) +
                            (@elements[7] * mat.elements[5]) +
                            (@elements[8] * mat.elements[8])
            return m


        translate: (x, y) ->
            @elements[2] = (x * @elements[0]) + (y * @elements[1]) + @elements[2]
            @elements[5] = (x * @elements[3]) + (y * @elements[4]) + @elements[5]

        rotate: (radians) ->
            temp = []
            temp[0] = Math::cos(radians)
            temp[1] = -Math::sin(radians)
            temp[2] = Math::sin(radians)
            temp[3] = Math::cos(radians)

            @elements[0] = (temp[0] * @elements[0]) + (temp[1] * @elements[3])
            @elements[1] = (temp[0] * @elements[1]) + (temp[1] * @elements[4])
            @elements[2] = (temp[2] * @elements[0]) + (temp[3] * @elements[3])
            @elements[3] = (temp[2] * @elements[1]) + (temp[3] * @elements[4])

        scale: (x, y) ->
            @elements[0] = x * @elements[0]
            @elements[1] = y * @elements[1]
            @elements[3] = x * @elements[3]
            @elements[4] = y * @elements[4]


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
        constructor: (@x1, @y1, @x2, @y2) ->
            @transform = null
            @color = new Color
            @z1 = 0.0
            @z2 = 0.0


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

        setColor: (r, g, b, a) ->
            @r = r
            @g = g
            @b = b
            @a = a

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
            @transform = null
            @texture = null
            @frame = 0
            @position = new Point(0, 0, 0)
            @anchor = new Point(0, 0, 0)
            @width = 0.0
            @height = 0.0
            @u1 = 0.0
            @v1 = 0.0
            @u2 = 1.0
            @v2 = 1.0
            @texWidth = 1.0
            @texHeight = 1.0
            @tiling = false
            @tileWidth = 0.0
            @tileHeight = 0.0
            @tileOffsetX = 0.0
            @tileOffsetY = 0.0
            @color = new Color(0, 0, 0, 0)

    ###
     # Renderer::Rect
     # Represents a rectangle to be rendered to the screen.
    ###
    @Rect = class Rect
        constructor: () ->
            @transform = null
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
            @transform = null
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

        getProjection: () ->
            throw {errorStr: "Function not implemented"}

        getWorldSize: () ->
            throw {errorStr: "Function not implemented"}

        getScreenSize: () ->
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
        constructor: (@canvas, @worldWidth, @worldHeight) ->
            @assetManager = new AssetManager
            @context = @canvas.getContext("2d")
            @clearColor = new Color(1,1,1)
            if !@context?
                throw {errorStr: "Could not get a 2d render context"}
            @Projection = new Matrix3x3
            @resizeWorld(@worldWidth, @worldHeight)

        # CanvasRenderer::resizeWorld(worldWidth, worldHeight)
        # See doc for BaseRenderer::resizeWorld(worldWidth, worldHeight)
        resizeWorld: (@worldWidth, @worldHeight) ->
            @Projection.set(0, 0, 1/@worldWidth)
            @Projection.set(1, 1, 1/@worldHeight)

        getProjection: () -> @Projection

        getWorldSize: () -> [@worldWidth, @worldHeight]

        getScreenSize: () -> [@canvas.width, @canvas.height]

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

        # CanvasRenderer::setClearColor(color)
        # See doc for BaseRenderer::setClearColor(color)
        setClearColor: (color) ->
            @clearColor = color

        # CanvasRenderer::drawSprite(sprite)
        # See doc for BaseRenderer::drawSprite(sprite)
        drawSprite: (sprite) ->
            t = null
            if sprite.texture != null
                t = @assetManager.getTexture sprite.texture
            else
                console.info "cannot draw a null or undefined texture"

            if t?
                sheetData = @assetManager.getSheetData sprite.texture
                if !sheetData?
                    u = sprite.u1 * t.width
                    v = sprite.v1 * t.height
                    u2 = sprite.u2 * t.width
                    v2 = sprite.v2 * t.height
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

                if uWidth == 0 then uWidth = 1
                if vHeight == 0 then vHeight = 1

                if sprite.transform != null
                    [x, y] = sprite.transform.mul(sprite.position)
                    temptx = sprite.transform.elements[2]
                    tempty = sprite.transform.elements[5]
                    sprite.transform.elements[2] = 0
                    sprite.transform.elements[5] = 0
                    [w, h] = sprite.transform.mul(sprite.width, sprite.height)
                    sprite.transform.elements[2] = temptx
                    sprite.transform.elements[5] = tempty
                else
                    [x, y] = @Projection.mul(sprite.position)
                    [w, h] = @Projection.mul(sprite.width, sprite.height)

                x = Math.round(x * @canvas.width)
                y = Math.round(y * @canvas.height)
                w = Math.round(w * @canvas.width)
                h = Math.round(h * @canvas.height)

                if !sprite.tiling
                    # draw the correct looking canvas onto the main canvas
                    @context.translate x, y
                    @context.drawImage t, u, v, u2 - u, v2 - v, 0, 0, w, h
                else
                    # determine the width and height of each tile with respect
                    # to the current transform matrix
                    if sprite.transform != null
                        temptx = sprite.transform.elements[2]
                        tempty = sprite.transform.elements[5]
                        sprite.transform.elements[2] = 0
                        sprite.transform.elements[5] = 0
                        [tw, th] = sprite.transform.mul(sprite.tileWidth, sprite.tileHeight)
                        sprite.transform.elements[2] = temptx
                        sprite.transform.elements[5] = tempty
                    else
                        [tw, th] = @Projection.mul(sprite.tileWidth, sprite.tileHeight)

                    tw = Math.round(tw * @canvas.width)
                    th = Math.round(th * @canvas.height)

                    # put texture on a canvas to use as a pattern
                    if !sprite._patternCanvas?
                        sprite._patternCanvas = document.createElement 'canvas'
                        sprite._patternCanvas.width = tw
                        sprite._patternCanvas.height = th

                    patternCtx = sprite._patternCanvas.getContext '2d'
                    #console.log u + " " + v + " " + u2 + " " + v2 + " " + tw + " " + th
                    patternCtx.drawImage t, u, v, u2 - u, v2 - v, 0, 0, tw, th
                    pattern = @context.createPattern(sprite._patternCanvas,
                        "repeat")

                    # draw pattern on a canvas a given offset for tex coords
                    offsetX = Math.round(sprite.tileOffsetX * tw)
                    offsetY = Math.round(sprite.tileOffsetY * th)

                    # draw the correct looking canvas on the main canvas
                    @context.save()
                    @context.translate(offsetX + x, offsetY + y)
                    #console.log offsetX + " " + offsetY + " " + x + " " + y  + " " + w + " " + h
                    @context.fillStyle = pattern
                    @context.fillRect(-offsetX, -offsetY, w, h)
                    @context.restore()
            else
                console.info "texture not found: " + sprite.texture

        # CanvasRenderer::drawLine(line)
        # See doc for BaseRenderer::drawLine(line)
        drawLine: (line) ->
            @context.beginPath()
            @context.strokeStyle = line.color.toCSS()
            @context.lineWidth = "1"

            if line.transform != null
                #console.log "here"
                [x1, y1] = line.transform.mul(line.x1, line.y1)
                [x2, y2] = line.transform.mul(line.x2, line.y2)
            else
                #console.log "nullhere"
                [x1, y1] = @Projection.mul(line.x1, line.y1)
                [x2, y2] = @Projection.mul(line.x2, line.y2)

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

            if rect.transform != null
                [x, y] = rect.transform.mul(rect.position)
                temptx = rect.transform.elements[2]
                tempty = rect.transform.elements[5]
                rect.transform.elements[2] = 0
                rect.transform.elements[5] = 0
                [w, h] = rect.transform.mul(rect.width, rect.height)
                rect.transform.elements[2] = temptx
                rect.transform.elements[5] = tempty
            else
                [x, y] = @Projection.mul(rect.position)
                [w, h] = @Projection.mul(rect.width, rect.height)

            x = parseInt(x * @canvas.width)
            y = parseInt(y * @canvas.height)
            w = parseInt(w * @canvas.width)
            h = parseInt(h * @canvas.height)

            #console.log x + " " + y + " " + w + " " + h
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
