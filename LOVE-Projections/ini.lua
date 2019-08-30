-- ini.lua
objectNames = {"utah", "cube", "diamond", "icosahedron", "magnolia"}
objects = {}

for i, v in ipairs(objectNames) do
    objects[v] = objLoader.load(v .. ".obj")
end

translateObject(objects.utah, Vector3.new(0, -1.4, 0))
scaleObject(objects.utah, 5)
translateObject(objects.cube, Vector3.new(-.5, -.5, -.5))
scaleObject(objects.cube, 10)
scaleObject(objects.diamond, 1/10)
scaleObject(objects.icosahedron, 4)
scaleObject(objects.magnolia, 1/4)

for i, v in ipairs(objects) do
    createMesh(v)
end