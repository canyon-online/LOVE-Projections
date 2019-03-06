function love.load()
    io.stdout:setvbuf("no")

    require("vector")
    matrix = require("matrix")
    objLoader = require("loader")

    shading = false
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    scale, time = 10, 0
    camera = Vector3.new()
    light = Vector3.new(0, -10, 20)
    o = Vector3.new()
    e = Vector3.new()

    utah = objLoader.load("utah.obj")
    translateObject(utah, Vector3.new(0, -1.4, 0))
    scaleObject(utah, 5)

    cube = objLoader.load("cube.obj")
    translateObject(cube, Vector3.new(-.5, -.5, -.5))
    scaleObject(cube, 10)

    diamond = objLoader.load("diamond.obj")
    scaleObject(diamond, 1/10)

    icosahedron = objLoader.load("icosahedron.obj")
    scaleObject(icosahedron, 4)
    
    mangolia = objLoader.load("mangolia.obj")
    scaleObject(mangolia, 1/4)

    love.graphics.setBackgroundColor(.2, .2, .2)
    love.graphics.setLineJoin("none")

    drawTable = {utah, cube, diamond, icosahedron, mangolia}
    drawTableIndex = 1
    objectToBeDrawn = drawTable[drawTableIndex]
end

-- Moves the model from the .obj file by a vector3 value.
function translateObject(obj, vec3)
    for i, vert in ipairs(obj.v) do
        obj.v[i].x = obj.v[i].x + vec3.x
        obj.v[i].y = obj.v[i].y + vec3.y
        obj.v[i].z = obj.v[i].z + vec3.z
    end
end

-- Scale the model from the .obj file by a real numbered value.
function scaleObject(obj, n)
    for i, vert in ipairs(obj.v) do
        obj.v[i].x = obj.v[i].x * n
        obj.v[i].y = obj.v[i].y * n
        obj.v[i].z = obj.v[i].z * n
    end
end

-- https://en.wikipedia.org/wiki/3D_projection#Perspective_projection
function computePixelCoordinates(a)
    temp = matrix{{a.x - camera.x}, {a.y - camera.y}, {a.z - camera.z}}
    m5 = m4 * temp
    d = Vector3.new(m5[1][1], m5[2][1], m5[3][1]) -- post camera transform
    return Vector2.new(e.z / d.z * d.x + e.x, e.z / d.z * d.y + e.y)
end

-- Calculate all the 2D points of a 3D object and store them in obj.points.
function updateObject(obj)
    mid = Vector2.new(width / 2, height / 2)
    obj.points = {}
    obj.mesh = nil

    for i, k in ipairs(obj.f) do
        p1Index = obj.v[k[1].v]
        p2Index = obj.v[k[2].v]
        p3Index = obj.v[k[3].v]

        if not obj.points[p1Index] then
            obj.points[p1Index] = computePixelCoordinates(p1Index) + mid
        end
        p1 = obj.points[p1Index]

        if not obj.points[p2Index] then
            obj.points[p2Index] = computePixelCoordinates(p2Index) + mid
        end
        p2 = obj.points[p2Index]

        if not obj.points[p3Index] then
            obj.points[p3Index] = computePixelCoordinates(p3Index) + mid
        end
        p3 = obj.points[p3Index]

        table.insert(obj.points, {p1, p2, p3})
    end
end

function drawObject(obj)
    mid = Vector2.new(width / 2, height / 2)
    -- For every face object, plot the corresponding vertices and calculate
    -- shading if needed.
    for i, k in ipairs(obj.f) do
        p1Index = obj.v[k[1].v]
        p2Index = obj.v[k[2].v]
        p3Index = obj.v[k[3].v]

        if shading then
            -- Shaders are calculated by taking the normal vector of a face
            -- and performing a dot product on the normal vector to the light
            -- source. Not very great with no z-buffering.

            v1 = Vector3.new(p1Index.x, p1Index.y, p1Index.z)
            v2 = Vector3.new(p2Index.x, p2Index.y, p2Index.z)
            v3 = Vector3.new(p3Index.x, p3Index.y, p3Index.z)
            cr = Vector3.cross(v2 - v1, v3 - v1)
            d = Vector3.dot(cr, (v1 + v2 + v3) / 3 - light)
            d = -d
            d = 2 * math.atan(d) / math.pi -- smooth lighting
            love.graphics.setColor(d, d, d)
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.polygon(shading and "fill" or "line",
            obj.points[i][1].x, obj.points[i][1].y, 
            obj.points[i][2].x, obj.points[i][2].y,
            obj.points[i][3].x, obj.points[i][3].y
        )
    end
end

-- Toggle shading.
function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        shading = not shading
    elseif key == "backspace" then
        drawTableIndex = ((drawTableIndex-2) % #drawTable) + 1
        objectToBeDrawn = drawTable[drawTableIndex]
    elseif key == "return" then
        drawTableIndex = (drawTableIndex % #drawTable) + 1
        objectToBeDrawn = drawTable[drawTableIndex]
    elseif key == "q" then
        love.window.close()
    end
end

function love.update(dt)
    time = time + dt

    -- Perform transformation to rotate camera around origin.
    camera = Vector3.new(50 * math.sin(time), 50 * math.sin(time), 50 * math.cos(time))
    -- Adjust what the camera is pointing to, accounting for pinhole.
    o = Vector3.new(
        math.pi  * (camera.z >= 0 and 0 or 1) 
            + math.asin(camera.y / camera:getMagnitude()) * (camera.z >= 0 and -1 or 1),
        math.atan(camera.x / camera.z),
        0
    )
    -- Adjust display surface.
    e = Vector3.new(0, 0, 800  * (camera.z >= 0 and 1 or -1))

    -- Set sin and cos values to be used for computation.
    s = Vector3.new(math.sin(o.x), math.sin(o.y), math.sin(o.z))
    c = Vector3.new(math.cos(o.x), math.cos(o.y), math.cos(o.z))
    -- More values to be used for computation.
    m1 = matrix{{1, 0, 0}, {0, c.x, s.x}, {0, -s.x, c.x}}
    m2 = matrix{{c.y, 0, -s.y}, {0, 1, 0}, {s.y, 0, c.y}}
    m3 = matrix{{c.z, s.z, 0}, {-s.z, c.z, 0}, {0, 0, 1}}
    m4 = m1 * m2 * m3

    updateObject(objectToBeDrawn)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Press enter to switch to the next mode, and return to visit the previous.\nPress space to toggle primitive shaders.\nPress q to exit.", 5, 5)
    drawObject(objectToBeDrawn)
end
