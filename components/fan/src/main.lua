--[[
Component for fans
--]]

        local line = require("@interrobang/iblib/lib/line.lua")
local lines = {}

local function get_range(rpm)
    return rpm * 10
end

local function get_force(rpm)
    return rpm * 10
end

local function get_bounding_box_dimensions(range)
    local shape = self:get_shape()
    local x = shape.size.x
    local y = shape.size.y
    local dimensions = shape.size
    if shape.size.x > shape.size.y then
        local corner = self:get_world_point(vec2(-x/2, y/2))
        local perpendicular_wind_direction = self:get_world_point(vec2(x/2, y/2)) - corner
        local wind_direction = self:get_world_point(vec2(0, range + y/2)) - self:get_world_point(vec2(0, y/2))
        return corner, perpendicular_wind_direction, wind_direction
    else
        local corner = self:get_world_point(vec2(x/2, -y/2))
        local perpendicular_wind_direction = self:get_world_point(vec2(x/2, y/2)) - corner
        local wind_direction = self:get_world_point(vec2(range + x/2, 0)) - self:get_world_point(vec2(x/2, 0))
        return corner, perpendicular_wind_direction, wind_direction
    end
end

local function get_ray_hits(ray_start, ray_gap, total_rays, wind_direction)
    local hitlist = {}
    for i = 0, total_rays do
        local ray_origin = ray_start + ray_gap * i
        local hits = Scene:raycast{
            origin = ray_origin, -- where to start the ray
            direction = wind_direction, -- direction of the ray, itll be normalized probably
            distance = wind_direction:magnitude(), -- how long before it gives up on everything in life
            closest_only = true, -- if false it should get the everything along the way (nothing is tested in this insane game)
        }
        local args = line(ray_origin, ray_origin + wind_direction, 0.01)
        args.color = Color:rgb(0.1, 0.4, 0.1)
        args.body_type = BodyType.Static
        local line_obj = Scene:add_box(args)
        line_obj:set_angle(args.rotation)
        line_obj:set_collision_layers({})
        table.insert(lines, line_obj)
        if hits then
            for i = 1, #hits do
                local hit = hits[i]
                if hit then
                    table.insert(hitlist, hit)
                end
            end
        end
    end
    return hitlist
end

local function apply_force_to_hits(hits, force_vector)
    for i = 1, #hits do
        local hit = hits[i]
        if hit then
            local deflected_force_vector = -hit.normal * (force_vector.x*-hit.normal.x + force_vector.y*-hit.normal.y) -- TODO MAKE THIS ACCURATE
            print(deflected_force_vector)
            hit.object:apply_force(deflected_force_vector, hit.point)

            local sphere = Scene:add_circle{
                position = hit.point,
                radius = 0.1,
                body_type = BodyType.Static,
                color = Color:rgb(0.1, 0.1, 0.1),
            }
            sphere:set_collision_layers({})
            table.insert(lines, sphere)
        end
    end
end

function on_step()

    for i = 1, #lines do
        local line = lines[i]
        if line then
            line:destroy()
        end
    end
    lines = {}



    local rpm = 10--self_component:get_property("rpm").value

    local range = get_range(rpm)
    local force = get_force(rpm)

    local ray_start, perpendicular_wind_direction, wind_direction = get_bounding_box_dimensions(range)

    local rays_per_meter = 10
    local total_rays = perpendicular_wind_direction:magnitude() * rays_per_meter
    local ray_gap = perpendicular_wind_direction / rays_per_meter

    local hits = get_ray_hits(ray_start, ray_gap, total_rays, wind_direction)

    print(#hits)

    local force_vector = wind_direction:normalize() * (force / total_rays) -- arbitrary force value

    local force_vector_line_args = line(ray_start, ray_start + force_vector, 0.01)
    force_vector_line_args.color = Color:rgb(0.1, 0.1, 0.8)
    force_vector_line_args.body_type = BodyType.Static
    local force_vector_line = Scene:add_box(force_vector_line_args)
    force_vector_line:set_angle(force_vector_line_args.rotation)
    force_vector_line:set_collision_layers({})
    table.insert(lines, force_vector_line)

    apply_force_to_hits(hits, force_vector)

    self:apply_force_to_center(-force_vector)
end
