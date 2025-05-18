Scene:reset()

Scene:set_gravity(vec2(0, 0))

local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")

local block = Scene:add_box{
    position = vec2(-10, 0),
    size = vec2(1, 10),
    body_type = BodyType.Static,
    color = Color:rgb(0.1, 0.1, 0.1), -- grey
}

local fan = Scene:add_box{
    position = vec2(0, 0),
    size = vec2(0.1, 1), -- meters
    body_type = BodyType.Dynamic,
    color = Color:rgb(1, 0.1, 0.1), -- red
}

local fan_component = Scene:add_component_def{
    name = "fan",
    id = "@interrobang/fans/fan",
    version = "0.2.0",

    code = require("./packages/@interrobang/fans/components/fan/src/main.lua", "string"),
}

-- local component = Scene:add_component_def({
--     name = "Player",
--     id = "@amytimed/test/player",
--     version = "0.2.0",

--     -- Lua/Luau code to make box "jump" when we press W key
--     script = {
--         lang = "lua",
--         code = [[
--             local host = Scene:get_player(0);

--             function on_update()
--                 if host:key_just_pressed("W") then
--                     self:apply_linear_impulse_to_center(vec2(0, 1));
--                 end;
--             end;
--         ]],
--     },
-- });

fan:add_component({hash = fan_component})
