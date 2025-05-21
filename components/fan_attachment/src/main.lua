--[[
Component for fan attachments (the blades that spin around)
--]]

function on_update()
    local images = self:get_images()
    local color = self_component:get_property("color").value
    images[1].color = color
    images[2].color = color
    self:set_images(images)
end
