'use strict'

###*
 # @ngdoc service
 # @name webvisApp.Renderer
 # @description
 # # Renderer
 # Service in the webvisApp.
###

define ()->
    Renderer = () ->
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
                @elements = new Float32Array(9)
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
                @elements[y + x*3]

            #Matrix3x3::set(x, y, val)
            #param x (integer) - the column you wish to access at
            #param y (integer) - the row you wish to access at
            #param val (real) - the value you will set the variable to at the
            #   specified row and column
            set: (x, y, val) ->
                if x < 0 or x > 2 or y < 0 or y > 2
                    throw {errorStr: "Matrix out of bounds"}
                @elements[y + x*3] = val

            copy: (mat) ->
                for i in [0..8]
                    @elements[i] = mat.elements[i]

            mul: (point, param2) ->
                if !param2?
                    # called as mul : (Point point) ->
                    x = ((@elements[0] * point.x) + (@elements[3] * point.y) +
                    @elements[6])
                    y = ((@elements[1] * point.x) + (@elements[4] * point.y) +
                    @elements[7])
                else
                    # called as mul : (x, y) ->
                    xt = point
                    yt = param2
                    x = (@elements[0] * xt) + (@elements[3] * yt) + @elements[6]
                    y = (@elements[1] * xt) + (@elements[4] * yt) + @elements[7]
                return [x, y]

            invert: () ->
                m = new Matrix3x3(this)

                d = 0
                for i in [0..2]
                    elem = 1
                    str = ""
                    for j in [0..2]
                        str += @get((j+i)%3, j) + " * "
                        elem *= @get((j+i)%3, j)
                    d += elem

                for i in [0..2]
                    elem = 1
                    k = -1
                    str = ""
                    for j in [2..0] by -1
                        k++
                        str += @get((i + k) %3, j) + " * "
                        elem *= @get((i + k)%3, j)
                    d -= elem

                m.elements[0] = (1/d *((@get(1, 1) * @get(2,2)) - (@get(2,1) *
                @get(1, 2))))
                m.elements[1] = (-1/d *((@get(0, 1) * @get(2,2)) - (@get(2, 1) *
                @get(0, 2))))
                m.elements[2] = (1/d *((@get(0, 1) * @get(1, 2))- (@get(1,1) *
                @get(0, 2))))

                m.elements[3] = (-1/d * ((@get(1, 0) * @get(2, 2)) - (@get(2, 0) *
                @get(1, 2))))
                m.elements[4] = (1/d * ((@get(0, 0) * @get(2, 2)) - (@get(2, 0) *
                @get(0, 2))))
                m.elements[5] = (-1/d * ((@get(0, 0) * @get(1, 2)) - (@get(1, 0) *
                @get(0, 2))))

                m.elements[6] = (1/d * ((@get(1, 0) * @get(2, 1)) - (@get(2, 0) *
                @get(1, 1))))
                m.elements[7] = (-1/d * ((@get(0, 0) * @get(2, 1)) - (@get(2, 0) *
                @get(0, 1))))
                m.elements[8] = (1/d * ((@get(0, 0) * @get(1, 1)) - (@get(1, 0) *
                @get(0, 1))))

                return m


            translate: (x, y) ->
                @elements[6] =(x * @elements[0]) + (y * @elements[3]) + @elements[6]
                @elements[7] =(x * @elements[1]) + (y * @elements[4]) + @elements[7]

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
                @elements[3] = y * @elements[3]
                @elements[1] = x * @elements[1]
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

            translate: (x, y, z) ->
                @elements[3] = ((x * @elements[0]) + (y * @elements[1]) +
                (z * @elements[2]) + @elements[3])
                @elements[7] = ((x * @elements[4]) + (y * @elements[5]) +
                (z * @elements[6]) + @elements[7])
                @elements[11] = ((x * @elements[8]) + (y * @elements[9]) +
                (z * @elements[10]) + @elements[11])

            scale: (x, y, z) ->
                @elements[0] = @elements[0] * x
                @elements[1] = @elements[1] * y
                @elements[2] = @elements[2] * z

                @elements[4] = @elements[4] * x
                @elements[5] = @elements[5] * y
                @elements[6] = @elements[6] * z

                @elements[8] = @elements[8] * x
                @elements[9] = @elements[9] * y
                @elements[10] = @elements[10] * z

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
         # @Texture is a string which is used to retrieve the texture from
         # @AssetManager
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
                @color = new Color(1.0, 1.0, 1.0, 1.0)

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

        @Text = class Text
            constructor: () ->
                @transform = null
                @text = ""
                @alignment = "left"
                @position = new Point(0, 0, 0)
                @width = 0.0
                @size = 0
                @color = new Color(0, 0, 0, 0)

        @Camera = class Camera
            constructor: () ->
                @transform = new Matrix3x3()
                @transform.set(0, 0, 2)
                @transform.set(1, 1, -2)
                @transform.set(2, 0, -1)
                @transform.set(2, 1, 1)
                @zoom = 1
                @transX = 0
                @transY = 0

            setZoomFactor: (factor) ->
                @zoom = factor
                @transform.set(0, 0, 2 * @zoom)
                @transform.set(1, 1, -2 * @zoom)
                @transform.set(2, 0, -@zoom - (@transX * @zoom))
                @transform.set(2, 1, @zoom - (@transY * @zoom))

            setTransX: (x) ->
                @transX = x
                @transform.set(2, 0, -@zoom - (@transX * @zoom))

            setTransY: (y) ->
                @transY = y
                @transform.set(2, 1, @zoom - (@transY  * @zoom))

            getZoomFactor: () -> @zoom
            getTransX: () -> @transX
            getTransY: () -> @transY

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

            setCamera: (camera) ->
                throw {errorStr: "Function not implemented"}

            resetCamera: () ->
                throw {errorStr: "Function not implemented"}

            getScreenSize: () ->
                throw {errorStr: "Function not implemented"}

            loadTextures: (pluginName, onloadCallback) ->
                throw {errorStr: "Function not implemented"}

            texturesLoaded: () ->
                throw {errorStr: "Function not implemented"}

            _getTexture: (filename) ->
                throw {errorStr: "Function not implemented"}

            _getSheetData: (filename) ->
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

            end: () ->
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

            # BaseRenderer::drawText(text)
            # Draw the Text object to the screen.
            # param text (Renderer::Text) - the text to be drawn.
            drawText: (text) ->
                throw {errorStr: "Function not implemented"}

        ###
         # Renderer::CanvasRenderer
         # This is an implementation of the Renderer::BaseRenderer interface that
         # utilizes the HTML5 Canvas drawing API for rendering.
        ###
        @CanvasRenderer = class CanvasRenderer extends @BaseRenderer
            constructor: (@canvas, @worldWidth, @worldHeight) ->
                @drawBuffer = document.createElement 'canvas'
                @drawBuffer.width = @canvas.width
                @drawBuffer.height = @canvas.height
                @context = @drawBuffer.getContext("2d")

                @clearColor = new Color(1,1,1)
                if !@context?
                    throw {errorStr: "Could not get a 2d render context"}
                @Projection = new Matrix3x3
                @resizeWorld(@worldWidth, @worldHeight)

                @_texturesLoaded = false
                @textures = {}
                @sheetData = {}

            # CanvasRenderer::resizeWorld(worldWidth, worldHeight)
            # See doc for BaseRenderer::resizeWorld(worldWidth, worldHeight)
            resizeWorld: (@worldWidth, @worldHeight) ->
                @drawBuffer.width = @canvas.width
                @drawBuffer.height = @canvas.height
                @Projection.set(0, 0, 1/@worldWidth)
                @Projection.set(1, 1, 1/@worldHeight)

            getProjection: () -> @Projection

            getWorldSize: () -> [@worldWidth, @worldHeight]

            getScreenSize: () -> [@canvas.width, @canvas.height]

            loadTextures: (pluginName, onloadCallback) ->
                @_texturesLoaded= false
                @textures = {}
                @sheetData = {}
                u = "/plugins/" + pluginName + "/resources.json"
                $.ajax
                    dataType: "json",
                    url: u,
                    data: null,
                    complete: (jqxhr, textStatus) ->
                        console.log textStatus
                    success: (data) =>
                        console.log "recieved"
                        numPictures = data.resources.length
                        for resource in data.resources
                            img = document.createElement 'img'
                            img.src = ("/plugins/" + pluginName + "/images/" +
                            resource.image)
                            @textures[resource.id] = img

                            img.onload = () =>
                                numPictures--
                                if numPictures == 0
                                    @_texturesLoaded = true
                                    onloadCallback()

                            if resource.spriteSheet != (null)
                                u = ("/plugins/" + pluginName + "/images/" +
                                resource.spriteSheet)
                                $.ajax
                                    dataType: "json",
                                    url: u,
                                    data: null,
                                    success: (data) =>
                                        @sheetData[resource.id] = data
                     error: (jqxhr, textStatus, errorThrown)->
                        console.log textStatus + " " + errorThrown

            texturesLoaded: () -> @_texturesLoaded

            _getTexture: (filename) -> @textures[filename]

            _getSheetData: (filename) -> return @sheetData[filename]

            # CanvasRenderer::begin(color)
            # See doc for BaseRenderer::begin(color)
            begin: () ->
                @canvas.width = @canvas.width
                if @canvas.width != @drawBuffer.width
                    @drawBuffer.width = @canvas.width
                if @canvas.height != @drawBuffer.height
                    @drawBuffer.height = @canvas.height
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

            end: () ->
                frontBuffer = @canvas.getContext "2d"
                frontBuffer.drawImage @drawBuffer,0,0, @canvas.width, @canvas.height

            # CanvasRenderer::setClearColor(color)
            # See doc for BaseRenderer::setClearColor(color)
            setClearColor: (color) ->
                @clearColor = color

            # CanvasRenderer::drawSprite(sprite)
            # See doc for BaseRenderer::drawSprite(sprite)
            drawSprite: (sprite) ->
                t = null
                if sprite.texture != null
                    t = @_getTexture sprite.texture
                else
                    console.info "cannot draw a null or undefined texture"

                if t?
                    sheetData = @_getSheetData sprite.texture
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
                        temptx = sprite.transform.elements[6]
                        tempty = sprite.transform.elements[7]
                        sprite.transform.elements[6] = 0
                        sprite.transform.elements[7] = 0
                        [w, h] = sprite.transform.mul(sprite.width, sprite.height)
                        sprite.transform.elements[6] = temptx
                        sprite.transform.elements[7] = tempty
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
                            temptx = sprite.transform.elements[6]
                            tempty = sprite.transform.elements[7]
                            sprite.transform.elements[6] = 0
                            sprite.transform.elements[7] = 0
                            [tw, th] = sprite.transform.mul(sprite.tileWidth,
                            sprite.tileHeight)
                            sprite.transform.elements[6] = temptx
                            sprite.transform.elements[7] = tempty
                        else
                            [tw, th] = @Projection.mul(sprite.tileWidth,
                            sprite.tileHeight)

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
                    temptx = rect.transform.elements[6]
                    tempty = rect.transform.elements[7]
                    rect.transform.elements[6] = 0
                    rect.transform.elements[7] = 0
                    [w, h] = rect.transform.mul(rect.width, rect.height)
                    rect.transform.elements[6] = temptx
                    rect.transform.elements[7] = tempty
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

            drawText: (text) ->
                @context.textAlign = "left"
                @context.font = "Bold " + text.size + "px Verdana"
                @context.fillStyle = text.color.toCSS()

                if text.alignment == "right"
                    @context.textAlign = "right"
                else
                    @context.textAlign = "left"

                @context.textBaseline = 'top'
                if text.transform != null
                    [x, y] = text.transform.mul(rect.position)
                    temptx = text.transform.elements[6]
                    tempty = text.transform.elements[7]
                    text.transform.elements[6] = 0
                    text.transform.elements[7] = 0
                    [w, h] = text.transform.mul(text.width, text,size)
                else
                    [x, y] = @Projection.mul(text.position)
                    [w, h] = @Projection.mul(text.width, text.size)

                x = parseInt(x * @canvas.width)
                y = parseInt(y * @canvas.height)
                w = parseInt(w * @canvas.width)

                if text.alignment == "right"
                    @context.fillText(text.text, x+w, y, w)
                else
                    @context.fillText(text.text, x, y, w)

        @WebGLRenderer = class WebGLRenderer extends @BaseRenderer
            constructor: (@canvas, @worldWidth, @worldHeight) ->
                @gl = @canvas.getContext "webgl", {antialias : false, depth: false}
                if !context?
                    @gl = @canvas.getContext "experimental-webgl"

                @gl.enable(@gl.BLEND)
                @gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA)

                @gl.clearColor(1.0, 1.0, 1.0, 1.0)
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

                @Projection = new Matrix3x3()
                @Projection.set(0, 0, 2)
                @Projection.set(2, 0, -1)
                @Projection.set(2, 1, 1)
                @Projection.set(1, 1, -2)
                @currentCamera = null

                @resizeWorld(@worldWidth, @worldHeight)

                @_texturesLoaded = false
                @textures = {}
                @sheetData = {}

                lineVerts = [
                  0.0, 0.0
                  0.0, 1.0
                ]

                rectVerts = [
                  0.0, 0.0,
                  1.0, 0.0,
                  0.0, 1.0,
                  1.0, 1.0,
                ]

                @baseLine = @gl.createBuffer()
                @gl.bindBuffer(@gl.ARRAY_BUFFER, @baseLine)
                @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(lineVerts), @gl.DYNAMIC_DRAW)
                @baseLine.itemSize = 2
                @baseLine.numItems = 2

                @baseRect = @gl.createBuffer()
                @gl.bindBuffer(@gl.ARRAY_BUFFER, @baseRect)
                @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(rectVerts), @gl.STATIC_DRAW)
                @baseRect.itemSize = 2
                @baseRect.numItems = 4

                @texCoords = @gl.createBuffer()
                @gl.bindBuffer(@gl.ARRAY_BUFFER, @texCoords)
                @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(rectVerts), @gl.DYNAMIC_DRAW)
                @texCoords.itemSize = 2
                @texCoords.numItems = 4

                colorVShaderSource = "
                    attribute vec2 aVertexPosition;

                    uniform mat3 uMVMatrix;
                    uniform mat3 uPMatrix;

                    void main(void) {
                        vec3 pos = uMVMatrix * vec3(aVertexPosition, 1.0);
                        pos = uPMatrix * pos;
                        gl_Position = vec4(pos.xy, 0.0, 1.0);
                    }
                "

                colorFShaderSource = "
                    precision mediump float;

                    uniform vec4 uColor;

                    void main(void) {
                        gl_FragColor = uColor;
                    }
                "

                colorVShader = @gl.createShader(@gl.VERTEX_SHADER)
                @gl.shaderSource(colorVShader, colorVShaderSource)
                @gl.compileShader(colorVShader)
                if !@gl.getShaderParameter(colorVShader, @gl.COMPILE_STATUS)
                    console.error @gl.getShaderInfoLog(colorVShader)
                    throw msg: "vertex shader did not compile correctly"

                colorFShader = @gl.createShader(@gl.FRAGMENT_SHADER)
                @gl.shaderSource(colorFShader, colorFShaderSource)
                @gl.compileShader(colorFShader)
                if !@gl.getShaderParameter(colorFShader, @gl.COMPILE_STATUS)
                    throw msg: "fragment shader did not compile correctly"

                @colorProg = @gl.createProgram()
                @gl.attachShader(@colorProg, colorVShader)
                @gl.attachShader(@colorProg, colorFShader)
                @gl.linkProgram(@colorProg)
                if !@gl.getProgramParameter(@colorProg, @gl.LINK_STATUS)
                    throw msg: "shader program could not be linked"
                @gl.useProgram(@colorProg)

                @colorProg.vertexPositionAttribute = @gl.getAttribLocation(@colorProg, "aVertexPosition")
                @gl.enableVertexAttribArray(@colorProg.vertexPositionAttribute)
                @colorProg.pMatrixUniform = @gl.getUniformLocation(@colorProg, "uPMatrix");
                @colorProg.mvMatrixUniform = @gl.getUniformLocation(@colorProg, "uMVMatrix");
                @colorProg.color = @gl.getUniformLocation(@colorProg, "uColor");

                texVShaderSource = "
                    attribute vec2 vertPos;
                    attribute vec2 texCoord;

                    uniform mat3 uMVMatrix;
                    uniform mat3 uPMatrix;

                    varying vec2 vTexCoord;

                    void main(void) {
                        vec3 pos = uMVMatrix * vec3(vertPos, 1.0);
                        pos = uPMatrix * pos;
                        gl_Position = vec4(pos.xy, 0.0, 1.0);
                        vTexCoord = texCoord;
                    }
                "

                texFShaderSource = "
                    precision mediump float;

                    varying vec2 vTexCoord;

                    uniform sampler2D uSampler;
                    uniform vec4 tint;

                    void main(void) {
                        gl_FragColor = texture2D(uSampler, vec2(vTexCoord.s, vTexCoord.t)) * tint;
                    }
                "

                texVShader = @gl.createShader(@gl.VERTEX_SHADER)
                @gl.shaderSource(texVShader, texVShaderSource)
                @gl.compileShader(texVShader)
                if !@gl.getShaderParameter(texVShader, @gl.COMPILE_STATUS)
                    console.error @gl.getShaderInfoLog(texVShader)
                    throw msg: "vertex shader did not compile correctly"

                texFShader = @gl.createShader(@gl.FRAGMENT_SHADER)
                @gl.shaderSource(texFShader, texFShaderSource)
                @gl.compileShader(texFShader)
                if !@gl.getShaderParameter(texFShader, @gl.COMPILE_STATUS)
                    console.error @gl.getShaderInfoLog(texFShader)
                    throw msg: "fragment shader did not compile correctly"

                @texProg = @gl.createProgram()
                @gl.attachShader(@texProg, texVShader)
                @gl.attachShader(@texProg, texFShader)
                @gl.linkProgram(@texProg)
                if !@gl.getProgramParameter(@texProg, @gl.LINK_STATUS)
                    throw msg: "shader program could not be linked"
                @gl.useProgram(@texProg)

                @texProg.vertexPositionAttribute = @gl.getAttribLocation(@texProg, "vertPos")
                @gl.enableVertexAttribArray(@texProg.vertexPositionAttribute)

                @texProg.texCoordAttribute = @gl.getAttribLocation(@texProg, "texCoord")
                @gl.enableVertexAttribArray(@texProg.texCoordAttribute)

                @texProg.pMatrixUniform = @gl.getUniformLocation(@texProg, "uPMatrix")
                @texProg.mvMatrixUniform = @gl.getUniformLocation(@texProg, "uMVMatrix")
                @texProg.samplerUniform = @gl.getUniformLocation(@texProg, "uSampler")
                @texProg.tintUniform = @gl.getUniformLocation(@texProg, "tint");

                @begin()

            # BaseRenderer::resizeWorld(worldWidth, worldHeight)
            # Resizes the coordinate system scale within the view.
            # Ex. if you call resizeWorld(20, 40) a point at the middle of the
            #   screen is located at Point(10, 20).
            # param worldWidth (real) - the width bound of the coordinate system
            # param worldHeight (real) - the height bound of the coordinate system
            resizeWorld: (@worldWidth, @worldHeight) ->
                @gl.viewport( 0, 0, @canvas.width, @canvas.height)

            getProjection: () -> @Projection

            getWorldSize: () -> [@worldWidth, @worldHeight]

            getScreenSize: () -> [@canvas.clientWidth, @canvas.clientHeight]

            setCamera: (camera) ->
                @currentCamera = camera

            resetCamera: () ->
                @currentCamera = null

            loadTextures: (pluginName, onloadCallback) ->
                @_texturesLoaded= false
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
                        if data.resources.length == 0
                            @_texturesLoaded = true

                        numPictures = data.resources.length
                        for resource in data.resources
                            tex = @gl.createTexture()
                            tex.img = document.createElement 'img'
                            tex.img.src = "/plugins/" + pluginName + "/images/" + resource.image
                            @textures[resource.id] = tex

                            func = (t) => () =>
                                @gl.bindTexture(@gl.TEXTURE_2D, t)
                                @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, t.img)
                                @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR)
                                @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR)
                                @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.REPEAT)
                                @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.REPEAT)
                                @gl.bindTexture(@gl.TEXTURE_2D, null)

                                numPictures--;
                                if numPictures == 0
                                    @_texturesLoaded = true
                                    onloadCallback()

                            tex.img.onload = func(tex)

                            spriteLoad = (id) => (data) =>
                                @sheetData[id] = data

                            if resource.spriteSheet != (null)
                                u = "/plugins/" + pluginName + "/images/" + resource.spriteSheet
                                $.ajax
                                    dataType: "json",
                                    url: u,
                                    data: null,
                                    success: spriteLoad(resource.id)
                     error: (jqxhr, textStatus, errorThrown)->
                        console.log textStatus + " " + errorThrown

            texturesLoaded: () -> @_texturesLoaded

            _getTexture: (filename) -> @textures[filename]

            _getSheetData: (filename) -> return @sheetData[filename]

             # BaseRenderer:setClearColor(color)
             # Sets the color that the background is cleared to on resizes.
             # param color (Renderer::Color) - The color that the drawing area
             # will be cleared to on begin and resize calls.
            setClearColor: (color) ->
                @gl.clearColor(color.r, color.g, color.b, color.a)

             # BaseRenderer::begin(color)
             # Clears the drawing area to the color specified.
             # param color (Renderer::Color) - The color that the drawing area
             #   will be cleared to.
            begin: (color) ->
                @gl.viewport( 0, 0, @canvas.width, @canvas.height)
                @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

            end: () ->

            # BaseRenderer::drawLine(line, color)
            # Draws the line object to the screen.
            # param line (Renderer::Line) - The line to be drawn
            # param color (Renderer::Color) - the color the drawn line will be.
            drawLine: (line) ->
                @gl.useProgram(@colorProg)
                @gl.disableVertexAttribArray(1)

                mvmat = new Matrix3x3(line.transform)
                colArray = new Float32Array(4)
                colArray[0] = line.color.r
                colArray[1] = line.color.g
                colArray[2] = line.color.b
                colArray[3] = line.color.a

                @gl.bindBuffer(@gl.ARRAY_BUFFER, @baseLine)
                @gl.bufferSubData(@gl.ARRAY_BUFFER, 0, new Float32Array([
                    line.x1, line.y1,
                    line.x2, line.y2
                ]))

                @gl.bindBuffer(@gl.ARRAY_BUFFER, @baseLine)
                @gl.vertexAttribPointer(@colorProg.vertexPositionAttribute,
                    @baseLine.itemSize, @gl.FLOAT, false, 0, 0)

                if @currentCamera == null
                    @gl.uniformMatrix3fv(@colorProg.pMatrixUniform, false, @Projection.elements)
                else
                    @gl.uniformMatrix3fv(@colorProg.pMatrixUniform, false, @currentCamera.transform.elements)

                @gl.uniformMatrix3fv(@colorProg.mvMatrixUniform, false, mvmat.elements)
                @gl.uniform4fv(@colorProg.color, colArray)
                @gl.drawArrays(@gl.LINES, 0, @baseLine.numItems)


            # BaseRenderer::drawSprite(sprite)
            # Draws the sprite object to the screen.
            # param line (Renderer::Sprite) - the sprite to be drawn
            drawSprite: (sprite) ->
                t = null
                if sprite.texture != null
                    t = @_getTexture sprite.texture
                else
                    return

                if t?
                    sheetData = @_getSheetData sprite.texture
                    @gl.bindBuffer(@gl.ARRAY_BUFFER, @texCoords)
                    if !sheetData?
                        if !sprite.tiling
                            @gl.bufferSubData(@gl.ARRAY_BUFFER, 0, new Float32Array([
                                sprite.u1, sprite.v1
                                sprite.u2, sprite.v1
                                sprite.u1, sprite.v2
                                sprite.u2, sprite.v2
                            ]))
                        else
                            u1 = 0 + sprite.tileOffsetX
                            u2 = (sprite.width / sprite.tileWidth) + sprite.tileOffsetX
                            v1 = 0 + sprite.tileOffsetY
                            v2 = (sprite.height / sprite.tileHeight) + sprite.tileOffsetY
                            @gl.bufferSubData(@gl.ARRAY_BUFFER, 0, new Float32Array([
                                u1, v1,
                                u2, v1,
                                u1, v2,
                                u2, v2
                            ]))
                    else
                        useg = 1/sheetData.width
                        vseg = 1/sheetData.height
                        row = parseInt(sprite.frame / sheetData.width)
                        column = sprite.frame % sheetData.width
                        u1 = column * useg
                        v1 = row * vseg
                        u2 = u1 + useg
                        v2 = v1 + vseg

                        @gl.bufferSubData(@gl.ARRAY_BUFFER, 0, new Float32Array([
                            u1, v1,
                            u2, v1,
                            u1, v2,
                            u2, v2
                        ]))

                    mvmat = new Matrix3x3(sprite.transform)
                    mvmat.translate(sprite.position.x, sprite.position.y)
                    mvmat.scale(sprite.width, sprite.height)

                    colArray = new Float32Array(4)
                    colArray[0] = sprite.color.r
                    colArray[1] = sprite.color.g
                    colArray[2] = sprite.color.b
                    colArray[3] = sprite.color.a

                    @gl.useProgram(@texProg)
                    @gl.enableVertexAttribArray(1)

                    @gl.bindBuffer(@gl.ARRAY_BUFFER, @baseRect)
                    @gl.vertexAttribPointer(@texProg.vertexPositionAttribute,
                        @baseRect.itemSize, @gl.FLOAT, false, 0, 0)

                    @gl.bindBuffer(@gl.ARRAY_BUFFER, @texCoords)
                    @gl.vertexAttribPointer(@texProg.texCoordAttribute,
                        @texCoords.itemSize, @gl.FLOAT, false, 0, 0)

                    @gl.activeTexture(@gl.TEXTURE0)
                    @gl.bindTexture(@gl.TEXTURE_2D, t)
                    @gl.uniform1i(@texProg.samplerUniform, 0)
                    @gl.uniform4fv(@texProg.tintUniform, colArray)

                    if @currentCamera == null
                        @gl.uniformMatrix3fv(@texProg.pMatrixUniform, false, @Projection.elements)
                    else
                        @gl.uniformMatrix3fv(@texProg.pMatrixUniform, false, @currentCamera.transform.elements)

                    @gl.uniformMatrix3fv(@texProg.mvMatrixUniform, false, mvmat.elements)
                    @gl.drawArrays(@gl.TRIANGLE_STRIP, 0, @baseRect.numItems)
                    @gl.bindTexture(@gl.TEXTURE_2D, null)

            # BaseRenderer::drawSprite(sprite)
            # Draws the path object to the screen.
            # param line (Renderer::Path) - the path to be drawn
            drawPath: (path) ->

            # BaseRenderer::drawRect(sprite)
            # Draws the Rectangle to the screen.
            # param line (Renderer::Rect) - the rectangle to be drawn.
            drawRect: (rect) ->
                @gl.useProgram(@colorProg)
                @gl.disableVertexAttribArray(1)

                mvmat = new Matrix3x3(rect.transform)
                mvmat.translate(rect.position.x, rect.position.y)
                mvmat.scale(rect.width, rect.height)

                colArray = new Float32Array(4)
                colArray[0] = rect.fillColor.r
                colArray[1] = rect.fillColor.g
                colArray[2] = rect.fillColor.b
                colArray[3] = rect.fillColor.a

                @gl.bindBuffer(@gl.ARRAY_BUFFER, @baseRect)
                @gl.vertexAttribPointer(@colorProg.vertexPositionAttribute,
                    @baseRect.itemSize, @gl.FLOAT, false, 0, 0)

                if @currentCamera == null
                    @gl.uniformMatrix3fv(@colorProg.pMatrixUniform, false, @Projection.elements)
                else
                    @gl.uniformMatrix3fv(@colorProg.pMatrixUniform, false, @currentCamera.transform.elements)

                @gl.uniformMatrix3fv(@colorProg.mvMatrixUniform, false, mvmat.elements)
                @gl.uniform4fv(@colorProg.color, colArray)
                @gl.drawArrays(@gl.TRIANGLE_STRIP, 0, @baseRect.numItems)

            drawText: (text) ->
                textCanvas = document.createElement 'canvas'
                ctx = textCanvas.getContext '2d'

                `var getPowerOfTwo = function(value){
                    var p = 1
                  	while(p<value) {
                  		  p *= 2;
                    }
                  	return p;
                }`

                ctx.font = "bold " + text.size + "px Verdana"
                metrics = ctx.measureText(text.text)
                textCanvas.width = getPowerOfTwo(metrics.width)
                textCanvas.height = getPowerOfTwo(text.size)

                ctx.font = "bold " + text.size + "px Verdana"
                ctx.fillStyle = "#000000"
                ctx.textBaseline = 'top'
                ctx.fillText(text.text, 0, 0, textCanvas.width)

                @gl.bindBuffer(@gl.ARRAY_BUFFER, @texCoords)
                @gl.bufferSubData(@gl.ARRAY_BUFFER, 0, new Float32Array([
                    0.0, 0.0,
                    1.0, 0.0,
                    0.0, 1.0,
                    1.0, 1.0
                    ]))

                mvmat = new Matrix3x3(text.transform)

                wtos = @worldWidth/@canvas.width
                w = if (textCanvas.width*wtos < text.width)
                    textCanvas.width*wtos
                else
                    text.width

                if text.alignment == "right"
                    if (metrics.width*wtos) - text.width > 0
                        wnew = text.position.x
                    else
                        wnew = text.position.x + text.width - metrics.width*wtos
                    mvmat.translate(wnew, text.position.y)
                else if text.alignment == "center"
                    if(metrics.width*wtos) - text.width > 0
                        wnew = text.position.x
                    else
                        wnew = text.position.x + (text.width/2) - ((metrics.width*wtos)/2)
                    mvmat.translate(wnew, text.position.y)
                else
                    mvmat.translate(text.position.x, text.position.y)
                mvmat.scale(w, textCanvas.height * (@worldHeight/@canvas.height))

                @gl.useProgram(@texProg)
                @gl.enableVertexAttribArray(1)

                @gl.bindBuffer(@gl.ARRAY_BUFFER, @baseRect)
                @gl.vertexAttribPointer(@texProg.vertexPositionAttribute,
                    @baseRect.itemSize, @gl.FLOAT, false, 0, 0)

                @gl.bindBuffer(@gl.ARRAY_BUFFER, @texCoords)
                @gl.vertexAttribPointer(@texProg.texCoordAttribute,
                    @texCoords.itemSize, @gl.FLOAT, false, 0, 0)

                textTexture = @gl.createTexture()
                @gl.bindTexture(@gl.TEXTURE_2D, textTexture)
                @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, textCanvas)
                @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR)
                @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR)
                @gl.activeTexture(@gl.TEXTURE0)
                @gl.bindTexture(@gl.TEXTURE_2D, textTexture)
                @gl.uniform1i(@texProg.samplerUniform, 0)

                if @currentCamera == null
                    @gl.uniformMatrix3fv(@texProg.pMatrixUniform, false, @Projection.elements)
                else
                    @gl.uniformMatrix3fv(@texProg.pMatrixUniform, false, @currentCamera.transform.elements)

                @gl.uniformMatrix3fv(@texProg.mvMatrixUniform, false, mvmat.elements)
                @gl.drawArrays(@gl.TRIANGLE_STRIP, 0, @baseRect.numItems)
                @gl.deleteTexture(textTexture)
                @gl.bindTexture(@gl.TEXTURE_2D, null)

        @autoDetectRenderer = (canvas, worldWidth, worldHeight) ->
            context = canvas.getContext "webgl"
            if !context?
                context = canvas.getContext "experimental-webgl"
                if !context?
                    context = canvas.getContext "2d"
                    if !context?
                        throw {errorStr: "Failed to initialize renderer"}
                    else
                        return new @CanvasRenderer(canvas, worldWidth,
                            worldHeight)
                else
                    return new @WebGLRenderer(canvas, worldWidth, worldHeight)
            else
                return new @WebGLRenderer(canvas, worldWidth, worldHeight)

        return this

    return Renderer
