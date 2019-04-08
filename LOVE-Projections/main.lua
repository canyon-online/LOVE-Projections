function love.load()
    io.stdout:setvbuf("no")

    require("vector")
    matrix = require("matrix")
    objLoader = require("loader")

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    scale, time = 10, 0
    light = Vector3.new(0, -10, 20 * math.cos(time / 4))
        camera = Vector3.new(50 * math.sin(time), 50 * math.sin(time), 50 * math.cos(time))
    -- Adjust what the camera is pointing to, accounting for pinhole.
    o = Vector3.new(
        math.pi  * (camera.z >= 0 and 0 or 1) 
            + math.asin(camera.y / camera:getMagnitude()) * (camera.z >= 0 and -1 or 1),
        math.atan(camera.x / camera.z),
        0
    )
    e = Vector3.new(0, 0, 800  * (camera.z >= 0 and 1 or -1))
    s = Vector3.new(math.sin(o.x), math.sin(o.y), math.sin(o.z))
    c = Vector3.new(math.cos(o.x), math.cos(o.y), math.cos(o.z))
    m1 = matrix{{1, 0, 0}, {0, c.x, s.x}, {0, -s.x, c.x}}
    m2 = matrix{{c.y, 0, -s.y}, {0, 1, 0}, {s.y, 0, c.y}}
    m3 = matrix{{c.z, s.z, 0}, {-s.z, c.z, 0}, {0, 0, 1}}
    m4 = m1 * m2 * m3


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
    
    magnolia = objLoader.load("magnolia.obj")
    scaleObject(magnolia, 1/4)

    scene = objLoader.load("scene.obj")
    translateObject(scene, Vector3.new(0, -.5, 0))
    scaleObject(scene, 2)

    love.graphics.setMeshCullMode("front")
    cullMode = true
    love.graphics.setBackgroundColor(.01, .01, .01)
    love.graphics.setLineJoin("none")
    
    drawTable = {utah, cube, diamond, icosahedron, magnolia, scene}
    drawTableIndex = 1
    objectToBeDrawn = drawTable[drawTableIndex]

    createMesh(utah)
    createMesh(magnolia)
    createMesh(icosahedron)
    createMesh(diamond)
    createMesh(cube)
    createMesh(scene)
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

function updateVertices(obj)
    mid = Vector2.new(width / 2, height / 2)
    obj.points = {}
    vertices = {}

    for i, k in ipairs(obj.f) do
        vertex1, vertex2, vertex3 = {}, {}, {}
        p1Index = obj.v[k[1].v]
        p2Index = obj.v[k[2].v]
        p3Index = obj.v[k[3].v]

        if not obj.points[p1Index] then
            obj.points[p1Index] = computePixelCoordinates(p1Index) + mid
        end
        p1 = obj.points[p1Index]
        table.insert(vertex1, p1.x)
        table.insert(vertex1, p1.y)
        table.insert(vertex1, 0)
        table.insert(vertex1, 0)

        if not obj.points[p2Index] then
            obj.points[p2Index] = computePixelCoordinates(p2Index) + mid
        end
        p2 = obj.points[p2Index]
        table.insert(vertex2, p2.x)
        table.insert(vertex2, p2.y)
        table.insert(vertex2, 0)
        table.insert(vertex2, 0)

        if not obj.points[p3Index] then
            obj.points[p3Index] = computePixelCoordinates(p3Index) + mid
        end
        p3 = obj.points[p3Index]
        table.insert(vertex3, p3.x)
        table.insert(vertex3, p3.y)
        table.insert(vertex3, 0)
        table.insert(vertex3, 0)

        table.insert(obj.points, {p1, p2, p3})

        v1 = Vector3.new(p1Index.x, p1Index.y, p1Index.z)
        v2 = Vector3.new(p2Index.x, p2Index.y, p2Index.z)
        v3 = Vector3.new(p3Index.x, p3Index.y, p3Index.z)
        cr = Vector3.cross(v2 - v1, v3 - v1)
        d = Vector3.dot(cr, (v1 + v2 + v3) / 3 - light)
        d = (2 * math.atan(d / 3) / math.pi) -- smooth lighting
        d = -d
        d = d >= .1 and d or .1

        red = 1 * d
        green = .6 * d
        blue = .6 * d

        table.insert(vertex1, red)
        table.insert(vertex1, green)
        table.insert(vertex1, blue)

        table.insert(vertex2, red)
        table.insert(vertex2, green)
        table.insert(vertex2, blue)

        table.insert(vertex3, red)
        table.insert(vertex3, green)
        table.insert(vertex3, blue)

        table.insert(vertices, vertex1)
        table.insert(vertices, vertex2)
        table.insert(vertices, vertex3)
    end

    obj.mesh:setVertices(vertices)
end

function createMesh(obj)
    obj.mesh = love.graphics.newMesh(#obj.f * 3, "triangles")
    updateVertices(obj)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "backspace" then
        drawTableIndex = ((drawTableIndex-2) % #drawTable) + 1
        objectToBeDrawn = drawTable[drawTableIndex]
    elseif key == "return" then
        drawTableIndex = (drawTableIndex % #drawTable) + 1
        objectToBeDrawn = drawTable[drawTableIndex]
    elseif key == "q" then
        love.window.close()
    elseif key == "space" then
        cullMode = not cullMode
        love.graphics.setMeshCullMode(cullMode == true and "front" or "back")
    end
end

function love.update(dt)
    time = time + dt
    -- Perform transformation to rotate camera around origin.
    light = Vector3.new(20 * math.cos(time), -10, 20 * math.sin(time))
    camera = Vector3.new(50 * math.sin(time / 3), 30 * math.sin(time / 5), 50 * math.cos(time / 3))
    -- Adjust what the camera is pointing to, accounting for pinhole.
    o = Vector3.new(
        math.pi  * (camera.z >= 0 and 0 or 1) 
            + math.asin(camera.y / camera:getMagnitude()) * (camera.z >= 0 and -1 or 1),
        math.atan(camera.x / camera.z),
        0
    )

    e = Vector3.new(0, 0, 1000  * (camera.z >= 0 and 1 or -1))
    s = Vector3.new(math.sin(o.x), math.sin(o.y), math.sin(o.z))
    c = Vector3.new(math.cos(o.x), math.cos(o.y), math.cos(o.z))
    m1 = matrix{{1, 0, 0}, {0, c.x, s.x}, {0, -s.x, c.x}}
    m2 = matrix{{c.y, 0, -s.y}, {0, 1, 0}, {s.y, 0, c.y}}
    m3 = matrix{{c.z, s.z, 0}, {-s.z, c.z, 0}, {0, 0, 1}}
    m4 = m1 * m2 * m3

    updateVertices(objectToBeDrawn)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Press enter to switch to the next model, and return to visit the previous.\nPress space to toggle culling face.\nPress q to exit.", 5, 5)
    love.graphics.draw(objectToBeDrawn.mesh, 0, 0)
end
