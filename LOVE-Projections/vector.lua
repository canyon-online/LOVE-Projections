-- vector.lua
-- adrian alberto
-- https://adrian-alberto.github.io/

local getMagnitude = function(x, y, z)
    return math.sqrt((x or 0)^2 + (y or 0)^2 + (z or 0)^2)
end

Vector2 = {}
Vector2.__index = function(t, k) return Vector2[k] or rawget(t,"readonly")[k] end
Vector2.__newindex = function() error("Attempt to modify Vector2 value.") end
Vector2.__metatable = false

Vector2.new = function(inX, inY)
    local values = {x = inX or 0, y = inY or 0, magnitude = getMagnitude(inX, inY)}
    return setmetatable({readonly = values}, Vector2)
end

Vector2.fromAngle = function(a)
    return Vector2.new(math.cos(a), math.sin(a))
end

Vector2.getMagnitude = function(self)
    return math.sqrt(self.x^2 + self.y^2)
end

Vector2.unit = function(self)
    if self.magnitude == 0 then
        return Vector2.new()
    end
    return self / self:getMagnitude()
end

Vector2.dot = function(self, other)
    return self.x*other.x + self.y*other.y
end

Vector2.cross = function(self, other)
    --this too
end

Vector2.lerp = function(self, other, alpha)
    return (self * (1 - alpha)) + (other * alpha)
end

Vector2.reflect = function(self, normal)
    return (self - (normal:unit())*self:dot(normal:unit())*2)
end

Vector2.__tostring = function(v)
    return v.x..", "..v.y
end

Vector2.__add = function(v, v2)
    return Vector2.new(v.x + v2.x, v.y + v2.y)
end

Vector2.__mul = function(v, v2)
    if type(v2) == "table" then
        return Vector2.new(v.x * v2.x, v.y * v2.y)
    elseif type(v2) == "number" then
        return Vector2.new(v.x * v2, v.y * v2)
    end
end

Vector2.__sub = function(v, v2)
    return Vector2.new(v.x - v2.x, v.y - v2.y)
end

Vector2.__div = function(v, v2)
    if type(v2) == "table" then
        return Vector2.new(v.x / v2.x, v.y / v2.y)
    elseif type(v2) == "number" then
        return Vector2.new(v.x / v2, v.y / v2)
    end
end

Vector2.__unm = function(v)
    return Vector2.new(-v.x, -v.y)
end

Vector2.accelBy = function(self, vec, a, maxSpeed)
    local out = self + (vec:unit() * a)
    local outSpeed = math.min(maxSpeed or vec.magnitude, out.magnitude)
    return out:unit() * outSpeed
end

Vector2.accelTo = function(self, goal, a)
    local dir = goal - self
    return self:accelBy(dir, a)
end

Vector2.__eq = function(v, v2)
    return v.x == v2.x and v.y == v2.y
end

function Vector2:v3()
    return Vector3.new(self.x, self.y, 0)
end

function Vector2:components()
    return self.x, self.y
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Vector3 = {}
Vector3.__index = function(t, k) return Vector3[k] or rawget(t,"readonly")[k] end
Vector3.__newindex = function() error("Attempt to modify Vector3 value.") end
Vector3.__metatable = false

Vector3.new = function(inX, inY, inZ)
    local values = {x = inX or 0, y = inY or 0, z = inZ or 0, magnitude = getMagnitude(inX, inY, inZ)}
    return setmetatable({readonly = values}, Vector3)
end

Vector3.getMagnitude = function(self)
    return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

Vector3.unit = function(self)
    if self.magnitude == 0 then
        return Vector3.new()
    end
    return self / self:getMagnitude()
end

Vector3.dot = function(self, other)
    return self.x*other.x + self.y*other.y + self.z*other.z
end

Vector3.cross = function(self, other)
    return Vector3.new(
        self.y * other.z - self.z * other.y,
        self.z * other.x - self.x * other.z,
        self.x * other.y - self.y * other.x
    )
end

Vector3.lerp = function(self, other, alpha)
    return self * (1 - alpha) + other * alpha
end

Vector3.__tostring = function(v)
    return v.x..", "..v.y..", "..v.z
end

Vector3.__add = function(v, v2)
    return Vector3.new(v.x + v2.x, v.y + v2.y, v.z + v2.z)
end

Vector3.__mul = function(v, v2)
    if type(v2) == "table" then
        return Vector3.new(v.x * v2.x, v.y * v2.y, v.z * v2.z)
    elseif type(v2) == "number" then
        return Vector3.new(v.x * v2, v.y * v2, v.z * v2)
    end
end

Vector3.__sub = function(v, v2)
    return Vector3.new(v.x - v2.x, v.y - v2.y, v.z - v2.z)
end

Vector3.__div = function(v, v2)
    if type(v2) == "table" then
        return Vector3.new(v.x / v2.x, v.y / v2.y, v.z / v2.z)
    elseif type(v2) == "number" then
        return Vector3.new(v.x / v2, v.y / v2, v.z / v2)
    end
end

Vector3.__unm = function(v)
    return Vector3.new(-v.x, -v.y, -v.z)
end

Vector3.__eq = function(v, v2)
    return v.x == v2.x and v.y == v2.y and v.z == v2.z
end

function Vector3:components()
    return self.x, self.y, self.z
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Segment = {}
Segment.__index = Segment

Segment.new = function(v1, v2)
    local seg = {}
    seg.m = v2.x ~= v1.x and (v2.y - v1.y)/(v2.x - v1.x) or nil
    seg.b = seg.m and seg.m * -v1.x + v1.y or nil
    seg.pointA = v1
    seg.pointB = v2
    return setmetatable(seg, Segment)
end

Segment.solveForY = function(self, x)

    return self.m * x + self.b
end

Segment.solveForX = function(self, y)
    if not self.m then
        return self.pointA.x
    end
    return (y - self.b)/self.m
end

Segment.intersects = function(self, seg2)
    if seg2.m == self.m then
        return nil
    elseif self.m and seg2.m then
        local intX = (seg2.b - self.b) / (self.m - seg2.m)
        if ((seg2.pointA.x >= intX and intX >= seg2.pointB.x) or (seg2.pointA.x <= intX and intX <= seg2.pointB.x))
        and ((self.pointA.x >= intX and intX >= self.pointB.x) or (self.pointA.x <= intX and intX <= self.pointB.x)) then
            return Vector2.new(intX, self:solveForY(intX))
        end
    elseif not self.m then
        intX = self.pointA.x
        intY = seg2:solveForY(intX)
        if ((seg2.pointA.x >= intX and intX >= seg2.pointB.x) or (seg2.pointA.x <= intX and intX <= seg2.pointB.x))
        and ((self.pointA.y >= intY and intY >= self.pointB.y) or (self.pointA.y <= intY and intY <= self.pointB.y)) then
            return Vector2.new(intX, intY)
        end
    elseif not seg2.m then
        intX = seg2.pointA.x
        intY = self:solveForY(intX)
        if ((seg2.pointA.y >= intY and intY >= seg2.pointB.y) or (seg2.pointA.y <= intY and intY <= seg2.pointB.y))
        and ((self.pointA.x >= intX and intX >= self.pointB.x) or (self.pointA.x <= intX and intX <= self.pointB.x)) then
            return Vector2.new(intX, intY)
        end
    end
end

Segment.closestPoint = function(self, vec, maxRange)
    --local nVec = Vector2.new(1, self.m and self.m ~= 0 and -1/self.m or 0):unit() * (maxRange or 500)
    if vec.z then
        vec = Vector2.new(vec.x, vec.y)
    end
    local nVec = Vector2.new(self.m or 1, self.m and -1 or 0):unit() * (maxRange or 500)
    local closestP = self:intersects(Segment.new(vec + nVec, vec - nVec))
    if closestP then
        return closestP, (vec - closestP)
    end
end
