-- // boui moment!!!
-- // inspired by splix

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local plrs = game:GetService("Players")
local stats = game:GetService("Stats")

local lplr = plrs.LocalPlayer

-- // some locals!!

-- / vector 2

local v2new = Vector2.new
local v2zero = Vector2.zero

-- / color3

local c3rgb = Color3.fromRGB

-- // library!!!

local library = {
    drawings = {{}, {}},
    preloaded_images = {},
    connections = {},
    flags = {},
    pointers = {},
    loaded = false,
}

-- // utility

local utility = {}

-- // esp stuff

local esp_stuff = {}

-- // utility coding

do
    -- // utility:Draw is super pasted and skidded and shitcoded even i cant read it even tho i coded it
    -- // xyl pls dont ban me for this code 😭😢

    function utility:Draw(class, offset, properties, t)
        t = t or false

        local draw = Drawing.new(class)
        local fakeDraw = {}
        rawset(fakeDraw, "__OBJECT_EXIST", true)
        setmetatable(fakeDraw, {
            __index = function(self, key)
                if rawget(fakeDraw, "__OBJECT_EXIST") then
                    return draw[key]
                end
            end,
            __newindex = function(self, key, value)
                if rawget(fakeDraw, "__OBJECT_EXIST") then
                    draw[key] = value
                    if key == "Position" then
                        for _, v in pairs(rawget(fakeDraw, "children")) do
                            v.Position = fakeDraw.Position + v.GetOffset()
                        end
                    end
                end
            end
        })
        rawset(fakeDraw, "Remove", function()
            if rawget(fakeDraw, "__OBJECT_EXIST") then
                draw:Remove()
                rawset(fakeDraw, "__OBJECT_EXIST", false)
            end
        end)
        rawset(fakeDraw, "GetType", function()
            return class
        end)
        rawset(fakeDraw, "GetOffset", function()
            return offset or v2new()
        end)
        rawset(fakeDraw, "SetOffset", function(noffset)
            offset = noffset or v2new()

            fakeDraw.Position = properties.Parent.Position + fakeDraw.GetOffset()
        end)
        rawset(fakeDraw, "__properties", properties)
        rawset(fakeDraw, "children", {})
        rawset(fakeDraw, "Lerp", function(instanceTo, instanceTime)
            if not rawget(fakeDraw, "__OBJECT_EXIST") then return end

            -- // i skidded lerp cause i was bad coder and im lazy to rewrite utility:Draw

            local currentTime = 0
            local currentIndex = {}
            local connection
            
            for i,v in pairs(instanceTo) do
                currentIndex[i] = fakeDraw[i]
            end
            
            local function lerp()
                for i,v in pairs(instanceTo) do
                    fakeDraw[i] = ((v - currentIndex[i]) * currentTime / instanceTime) + currentIndex[i]
                end
            end
            
            connection = rs.RenderStepped:Connect(function(delta)
                if currentTime < instanceTime then
                    currentTime = currentTime + delta
                    lerp()
                else
                    connection:Disconnect()
                end
            end)

            table.insert(library.connections, connection)
        end)

        local customProperties = {
            ["Parent"] = function(object)
                table.insert(rawget(object, "children"), fakeDraw)
            end
        }

        if class == "Square" or class == "Circle" or class == "Line" then
            fakeDraw.Thickness = 1
            if class == "Square" then
                fakeDraw.Filled = true
                fakeDraw.Thickness = 1
            end
        end

        if class ~= "Image" then
            fakeDraw.Color = Color3.new(0, 0, 0)
        end

        fakeDraw.Visible = library.loaded
        if properties ~= nil then
            for key, value in pairs(properties) do
                if customProperties[key] == nil then
                    fakeDraw[key] = value
                else
                    customProperties[key](value)
                end
            end
            if properties.Parent then
                fakeDraw.Position = properties.Parent.Position + fakeDraw.GetOffset()
            end
            if properties.Parent and properties.From then
                fakeDraw.From = properties.Parent.Position + fakeDraw.GetOffset()
            end
            if properties.Parent and properties.To then
                fakeDraw.To = properties.Parent.Position + fakeDraw.GetOffset()
            end
        end

        if not library.loaded and not t then
            fakeDraw.Transparency = 0
        end

        properties = properties or {}

        if not t then
            table.insert(library.drawings[1], {fakeDraw, properties["Transparency"] or 1, class})
        else
            table.insert(library.drawings[2], {fakeDraw, properties["Transparency"] or 1, class})
        end

        return fakeDraw
    end

    function utility:ScreenSize()
        return workspace.CurrentCamera.ViewportSize
    end

    function utility:RoundVector(vector)
        return v2new(math.floor(vector.X), math.floor(vector.Y))
    end

    function utility:MouseOverDrawing(object)
        local values = {object.Position, object.Position + object.Size}
        local mouseLocation = uis:GetMouseLocation()
        return mouseLocation.X >= values[1].X and mouseLocation.Y >= values[1].Y and mouseLocation.X <= values[2].X and mouseLocation.Y <= values[2].Y
    end

    function utility:MouseOverPosition(values)
        local mouseLocation = uis:GetMouseLocation()
        return mouseLocation.X >= values[1].X and mouseLocation.Y >= values[1].Y and mouseLocation.X <= values[2].X and mouseLocation.Y <= values[2].Y
    end

    function utility:PreloadImage(link)
        local data = library.preloaded_images[link] or game:HttpGet(link)
        if library.preloaded_images[link] == nil then
            library.preloaded_images[link] = data
        end
        return data
    end

    function utility:Image(object, link)
        local data = library.preloaded_images[link] or game:HttpGet(link)
        if library.preloaded_images[link] == nil then
            library.preloaded_images[link] = data
        end
        object.Data = data
    end

    function utility:Connect(connection, func)
        local con = connection:Connect(func)
        table.insert(library.connections, con)
        return con
    end

    function utility:BindToRenderStep(name, priority, func)
        local fake_connection = {}

        function fake_connection:Disconnect()
            rs:UnbindFromRenderStep(name)
        end

        rs:BindToRenderStep(name, priority, func)

        return fake_connection
    end

    function utility:Combine(t1, t2)
        local t3 = {}
        for i, v in pairs(t1) do
            table.insert(t3, v)
        end
        for i, v in pairs(t2) do
            table.insert(t3, v)
        end
        return t3
    end

    -- // xyl thanks for the method cause im npc

    function utility:GetPlexSize(text)
        return #text * 7
    end

    function utility:CopyTable(tbl)
        local newtbl = {}
        for i, v in pairs(tbl) do
            newtbl[i] = v
        end
        return newtbl
    end

    -- // function i will never use?

    function utility:ShiftKey(key)
        if string.byte(key) >= 65 and string.byte(key) <= 122 then
            return key:upper()
        else
            local shiftKeybinds = {["-"] = "_", ["="] = "+", ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$", ["5"] = "%", ["6"] = "^", ["7"] = "&", ["8"] = "*", ["9"] = "(", ["0"] = ")", [";"] = ":", ["'"] = "\"", ["\\"] = "|", ["/"] = "?"}
            return shiftKeybinds[key] or key
        end
    end
end

-- // esp coding

do
    function esp_stuff.Add(plr)
        esp_stuff[plr] = {
            BoxOutline = utility:Draw("Square", v2new(), {Visible = false, Filled = false, Thickness = 3}, true),
            Box = utility:Draw("Square", v2new(), {Visible = false, Filled = false, ZIndex}, true),
            HealthOutline = utility:Draw("Square", v2new(), {Visible = false}, true),
            Health = utility:Draw("Square", v2new(), {Visible = false}, true),
            Name = utility:Draw("Text", v2new(), {Size = 13, Font = 2, Text = plr.Name, Outline = true, Center = true, Visible = false}, true),
            Weapon = utility:Draw("Text", v2new(), {Size = 13, Font = 2, Outline = true, Center = true, Visible = false}, true),
        }
    end

    function esp_stuff.Remove(plr)
        if esp_stuff[plr] then
            for i, v in pairs(esp_stuff[plr]) do
                v.Remove()
            end
            esp_stuff[plr] = nil
        end
    end
end

function library:Window(info)

    local name = info.name or "worst ui library ever"

    local window = {shit = {}, wm = {}, kb = {}, nt = {}, sshit = nil, tabs = {}, accent = c3rgb(174, 16, 16), _last = {0, 0}, start = v2zero, dragging = false}

    local main_frame = utility:Draw("Square", nil, {
        Size = v2new(500, 600),
        Color = c3rgb(35, 35, 35),
        Position = utility:RoundVector(utility:ScreenSize() / 2 - v2new(250, 300))
    })

    window.frame = main_frame

    utility:Connect(uis.InputBegan, function(input)
        if main_frame.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 and utility:MouseOverPosition({main_frame.Position, main_frame.Position + v2new(main_frame.Size.X, 20)}) then
            window.start = uis:GetMouseLocation() - main_frame.Position
            window.dragging = true
        end
    end)

    utility:Connect(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.dragging = false
        end
    end)

    utility:Connect(uis.InputChanged, function(input)
        if main_frame.Visible and input.UserInputType == Enum.UserInputType.MouseMovement and window.dragging then
            main_frame.Position = uis:GetMouseLocation() - window.start
        end
    end)

    utility:Draw("Square", v2new(-1, -1), {
        Size = main_frame.Size + v2new(2, 2),
        Color = c3rgb(20, 20, 20),
        Filled = false,
        Parent = main_frame
    })

    utility:Draw("Square", v2new(-2, -2), {
        Size = main_frame.Size + v2new(4, 4),
        Color = window.accent,
        Filled = false,
        Parent = main_frame
    })

    local main_frame_title = utility:Draw("Text", v2new(3, 2), {
        Font = 2,
        Size = 13,
        Outline = true,
        Color = Color3.new(1, 1, 1),
        Text = name,
        Parent = main_frame
    })

    local pretab_frame = utility:Draw("Square", v2new(6, 20), {
        Size = v2new(488, 574),
        Color = c3rgb(25, 25, 25),
        Parent = main_frame
    })

    utility:Draw("Square", v2new(-1, -1), {
        Size = pretab_frame.Size + v2new(2, 2),
        Color = c3rgb(20, 20, 20),
        Filled = false,
        Parent = pretab_frame
    })

    utility:Draw("Square", v2new(-2, -2), {
        Size = pretab_frame.Size + v2new(4, 4),
        Color = Color3.new(),
        Filled = false,
        Parent = pretab_frame
    })

    local tabs_frame = utility:Draw("Square", v2new(6, 23), {
        Size = v2new(476, 545),
        Color = c3rgb(35, 35, 35),
        Parent = pretab_frame
    })

    utility:Draw("Square", v2new(-1, -1), {
        Size = tabs_frame.Size + v2new(2, 2),
        Color = c3rgb(45, 45, 45),
        Filled = false,
        Parent = tabs_frame
    })

    function window.Tab(self, info)

        local name = info.name or "tab"

        local offset = v2new(0, -19)

        local tab = {instances = {}, sections = {}, sides = {{}, {}}, on = false}

        if #self.tabs > 0 then
            offset = self.tabs[#self.tabs].instances[1].GetOffset() + v2new(self.tabs[#self.tabs].instances[1].Size.X + 1, 0)
        end

        local tab_frame = utility:Draw("Square", offset, {
            Size = v2new(utility:GetPlexSize(name) + 12, 18),
            Color = c3rgb(35, 35, 35),
            Parent = tabs_frame
        })

        local tab_frame_outline = utility:Draw("Square", v2new(-1, -1), {
            Size = tab_frame.Size + v2new(2, 2),
            Color = c3rgb(45, 45, 45),
            Filled = false,
            Parent = tab_frame
        })

        local tab_frame_text = utility:Draw("Text", v2new(tab_frame.Size.X / 2, 3), {
            Font = 2,
            Size = 13,
            Text = name,
            Color = Color3.new(1, 1, 1),
            Outline = true,
            Center = true,
            Parent = tab_frame
        })

        local tab_frame_hider = utility:Draw("Square", v2new(0, tab_frame.Size.Y), {
            Size = v2new(tab_frame.Size.X, 1),
            Color = c3rgb(35, 35, 35),
            Parent = tab_frame
        })

        local tab_frame_accent = utility:Draw("Square", v2new(0, 0), {
            Size = v2new(tab_frame.Size.X, 1),
            Color = self.accent,
            Parent = tab_frame
        })

        tab.instances = {tab_frame, tab_frame_outline, tab_frame_text, tab_frame_hider, tab_frame_accent}

        table.insert(self.tabs, tab)

        function tab.Show(self)
            tab_frame.Color = c3rgb(35, 35, 35)
            tab_frame_hider.Visible = true
            tab_frame_accent.Visible = true

            for i, v in pairs(self.sections) do
                v:Show()
            end

            self.on = true
        end

        function tab.Hide(self)
            tab_frame.Color = c3rgb(25, 25, 25)
            tab_frame_hider.Visible = false
            tab_frame_accent.Visible = false

            for i, v in pairs(self.sections) do
                v:Hide()
            end

            self.on = false
        end

        function tab.Update(self)

            -- // loop for every side (left, right)

            for sn, side in pairs(self.sides) do

                -- // every section in it

                for i, v in pairs(side) do

                    -- // update it's size

                    v:Update()

                    -- // count y offset

                    local offset = 12

                    -- // if its not first section

                    if i > 1 then

                        -- // last section_frame instance

                        local last_sframe = side[i - 1].instances[1]

                        -- // set new section_frame instance offset with counting last section_frame offset (y) + size (y) + 16 (default offset)

                        offset = offset + last_sframe.GetOffset().Y + last_sframe.Size.Y

                    end

                    -- // set offset

                    v.instances[1].SetOffset(v2new(sn == 1 and 6 or tabs_frame.Size.X - 234, offset))
                end
            end
        end

        function tab.Section(self, info)
            local name = info.name or "section"
            local side = info.side or "left" side = tostring(side):lower()

            -- // side check

            if side ~= "left" and side ~= "right" then
                side = "left"
            end

            -- // section

            local section = {instances = {}, scale = 0}

            local section_frame = utility:Draw("Square", v2new(side == "left" and 6 or tabs_frame.Size.X - 234, 16), {
                Size = v2new(228, section.scale),
                Color = c3rgb(30, 30, 30),
                Parent = tabs_frame
            })

            local section_inline = utility:Draw("Square", v2new(-1, -1), {
                Size = section_frame.Size + v2new(2, 2),
                Color = c3rgb(),
                Filled = false,
                Parent = section_frame
            })

            local section_outline = utility:Draw("Square", v2new(-2, -2), {
                Size = section_frame.Size + v2new(4, 4),
                Color = c3rgb(40, 40, 40),
                Filled = false,
                Parent = section_frame
            })

            local section_accent = utility:Draw("Square", v2new(0, 0), {
                Size = v2new(8, 2),
                Color = window.accent,
                Parent = section_frame
            })

            local section_title = utility:Draw("Text", v2new(9, -7), {
                Font = 2,
                Size = 13,
                Color = Color3.new(1, 1, 1),
                Outline = true,
                Text = name,
                Parent = section_frame
            })

            local section_accent2 = utility:Draw("Square", v2new(11 + (#name * 7), 0), {
                Size = v2new(228 - (11 + (#name * 7)), 2),
                Color = window.accent,
                Parent = section_frame
            })

            function section.Show(self)
                for i, v in pairs(self.instances) do
                    v.Visible = true
                end
            end

            function section.Hide(self)
                for i, v in pairs(self.instances) do
                    v.Visible = false
                end
            end

            function section.NextObjectPosition(self)
                return self.scale > 0 and self.scale or 10
            end

            function section.UpdateScale(self, number)
                if self.scale == 0 then
                    self.scale = 10
                end

                self.scale = self.scale + number + 5
            end

            function section.Update(self)
                section_frame.Size = v2new(228, self.scale > 0 and self.scale or 10)
                section_inline.Size = section_frame.Size + v2new(2, 2)
                section_outline.Size = section_inline.Size + v2new(2, 2)
            end

            function section.Button(self, info)

                local name = info.name or "Button"
                local callback = info.callback or function() end
                
                local button = {name = name, callback = callback}

                local button_frame = utility:Draw("Square", v2new(6, self:NextObjectPosition()), {
                    Size = v2new(216, 18),
                    Color = c3rgb(40, 40, 40),
                    Parent = section_frame
                })

                local button_outline = utility:Draw("Square", v2new(-1, -1), {
                    Size = button_frame.Size + v2new(2, 2),
                    Color = c3rgb(),
                    Filled = false,
                    Parent = button_frame
                })

                local button_gradient = utility:Draw("Image", v2zero, {
                    Size = button_frame.Size,
                    Transparency = 0.5,
                    Parent = button_frame
                })

                local button_title = utility:Draw("Text", v2new(button_frame.Size.X / 2, 2), {
                    Font = 2,
                    Size = 13,
                    Color = Color3.new(1, 1, 1),
                    Outline = true,
                    Center = true,
                    Text = name,
                    Parent = button_frame
                })

                utility:Image(button_gradient, "https://s3.us-east-1.wasabisys.com/e-zimagehosting/7832f20c-64f3-46ac-bbdc-24b47117be2a/o8z9utc4.png")

                utility:Connect(uis.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and main_frame.Visible and tab.on and utility:MouseOverPosition({section_frame.Position + v2new(0, button_frame.GetOffset().Y), section_frame.Position + v2new(section_frame.Size.X, button_frame.GetOffset().Y + 18)}) then
                        button.callback()
                    end
                end)

                self.instances = utility:Combine(self.instances, {button_frame, button_outline, button_title, button_gradient})

                self:UpdateScale(18)

            end

            function section.Toggle(self, info)
                
                local name = info.name or "toggle"
                local default = info.default or info.def or false
                local callback = info.callback or function() end
                local flag = info.flag

                local toggle = {name = name, flag = flag, state = default, callback = callback}

                local toggle_frame = utility:Draw("Square", v2new(6, self:NextObjectPosition() + 3), {
                    Size = v2new(8, 8),
                    Parent = section_frame
                })

                local toggle_outline = utility:Draw("Square", v2new(-1, -1), {
                    Size = toggle_frame.Size + v2new(2, 2),
                    Color = c3rgb(),
                    Filled = false,
                    Parent = toggle_frame
                })

                local toggle_gradient = utility:Draw("Image", v2zero, {
                    Size = toggle_frame.Size,
                    Transparency = 0.5,
                    Parent = toggle_frame
                })

                local toggle_title = utility:Draw("Text", v2new(13, -3), {
                    Font = 2,
                    Size = 13,
                    Color = Color3.new(1, 1, 1),
                    Outline = true,
                    Text = name,
                    Parent = toggle_frame
                })

                utility:Image(toggle_gradient, "https://s3.us-east-1.wasabisys.com/e-zimagehosting/7832f20c-64f3-46ac-bbdc-24b47117be2a/o8z9utc4.png")

                function toggle.UpdateColor(self)
                    toggle_frame.Color = self.state and window.accent or c3rgb(40, 40, 40)
                end

                function toggle.UpdateFlag(self, state)
                    if self.flag then
                        library.flags[self.flag] = state
                    end
                end

                function toggle.SetState(self, state)
                    self.state = state

                    self:UpdateColor()
                    self:UpdateFlag(self.state)

                    self.callback(self.state)
                end

                toggle:SetState(default)

                utility:Connect(uis.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and main_frame.Visible and tab.on and utility:MouseOverPosition({section_frame.Position + v2new(0, toggle_frame.GetOffset().Y), section_frame.Position + v2new(section_frame.Size.X, toggle_frame.GetOffset().Y + 18)}) then
                        toggle:SetState(not toggle.state)
                    end
                end)

                self.instances = utility:Combine(self.instances, {toggle_frame, toggle_outline, toggle_title, toggle_gradient})

                self:UpdateScale(11)

            end

            function section.Slider(self, info)
                info = info or {}

                local name = info.name or "slider"
                local min = info.min or 1
                local max = info.max or 100
                local def = info.def or min
                local dec = info.dec or 1
                local suf = info.suf or ""
                local flag = info.flag or ""
                local callback = info.callback or function() end

                local slider = {name = name, flag = flag, value = def, min = min, max = max, suf = suf, holding = false, callback = callback}

                local slider_title = utility:Draw("Text", v2new(6, self:NextObjectPosition() + 3), {
                    Color = c3rgb(255, 255, 255),
                    Outline = true,
                    Size = 13,
                    Font = 2,
                    Text = name,
                    Parent = section_frame
                })

                local slider_frame = utility:Draw("Square", v2new(0, 16), {
                    Size = v2new(216, 8),
                    Color = c3rgb(40, 40, 40),
                    Parent = slider_title
                })

                local slider_outline = utility:Draw("Square", v2new(-1, -1), {
                    Size = slider_frame.Size + v2new(2, 2),
                    Color = c3rgb(),
                    Filled = false,
                    Parent = slider_frame
                })

                local slider_bar = utility:Draw("Square", v2new(), {
                    Color = window.accent,
                    Size = v2new(0, slider_frame.Size.Y),
                    Parent = slider_frame
                })

                local slider_gradient = utility:Draw("Image", v2new(), {
                    Size = slider_frame.Size,
                    Transparency = .5,
                    Parent = slider_frame
                })

                local slider_value = utility:Draw("Text", v2new(slider_frame.Size.X / 2, -2), {
                    Color = c3rgb(255, 255, 255),
                    Outline = true,
                    Size = 13,
                    Font = 2,
                    Text = tostring(def) .. "/" .. tostring(max) .. suf,
                    Center = true,
                    Parent = slider_frame
                })

                utility:Image(slider_gradient, "https://s3.us-east-1.wasabisys.com/e-zimagehosting/7832f20c-64f3-46ac-bbdc-24b47117be2a/o8z9utc4.png")

                function slider.UpdateValue(self)
                    slider_value.Text = tostring(self.value) .. "/" .. tostring(max) .. self.suf

                    local percent = 1 - (self.max - self.value) / (self.max - self.min)

                    slider_bar.Size = Vector2.new(percent * slider_frame.Size.X, slider_frame.Size.Y)
                end

                function slider.UpdateFlag(self)
                    if self.flag then
                        library.flags[self.flag] = self.value
                    end
                end

                function slider.SetValue(self, value)
                    self.value = value

                    self:UpdateValue()
                    self:UpdateFlag()

                    callback(self.value)
                end

                slider:SetValue(slider.value)

                utility:Connect(uis.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and main_frame.Visible and tab.on and utility:MouseOverPosition({section_frame.Position + v2new(0, slider_title.GetOffset().Y), section_frame.Position + v2new(section_frame.Size.X, slider_title.GetOffset().Y + 29)}) then
                        slider.holding = true
                        local percent = math.clamp(uis:GetMouseLocation().X - slider_bar.Position.X, 0, slider_frame.Size.X) / slider_frame.Size.X
                        local value = math.floor((min + (max - min) * percent) * dec) / dec
                        value = math.clamp(value, min, max)
                        slider:SetValue(value)
                    end
                end)

                utility:Connect(uis.InputChanged, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement and slider.holding then
                        local percent = math.clamp(uis:GetMouseLocation().X - slider_bar.Position.X, 0, slider_frame.Size.X) / slider_frame.Size.X
                        local value = math.floor((min + (max - min) * percent) * dec) / dec
                        value = math.clamp(value, min, max)
                        slider:SetValue(value)
                    end
                end)

                utility:Connect(uis.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and slider.holding then
                        slider.holding = false
                        local percent = math.clamp(uis:GetMouseLocation().X - slider_bar.Position.X, 0, slider_frame.Size.X) / slider_frame.Size.X
                        local value = math.floor((min + (max - min) * percent) * dec) / dec
                        value = math.clamp(value, min, max)
                        slider:SetValue(value)
                    end
                end)

                self.instances = utility:Combine(self.instances, {slider_title, slider_frame, slider_outline, slider_bar, slider_gradient, slider_value})

                self:UpdateScale(26)

            end

            section.instances = {section_frame, section_inline, section_outline, section_title, section_accent, section_accent2}

            table.insert(self.sections, section)
            table.insert(self.sides[side == "left" and 1 or 2], section)

            return section
        end

        if self.sshit == nil then
            self:SelectTab(name)
        end

        utility:Connect(uis.InputBegan, function(input)
            if main_frame.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 and utility:MouseOverDrawing(tab_frame) then
                self:SelectTab(name)
            end
        end)

        return tab

    end

    function window.NewAccent(self, new_accent)
        for i, v in pairs(utility:Combine(library.drawings[1], library.drawings[2])) do
            if v[3] ~= "Image" and v[3] ~= "Text" and v[1].Color == self.accent then
                v[1].Color = new_accent
            end
        end

        self.accent = new_accent
    end

    function window.SelectTab(self, name)
        self.sshit = name

        for i, v in pairs(self.tabs) do
            if v.instances[3].Text == window.sshit then
                v:Show()
            else
                v:Hide()
            end
        end
    end

    function window.Fade(self)
        if self.fading then return end

        if main_frame.Visible then
            self.fading = true

            for i, v in pairs(library.drawings[1]) do
                v[1].Lerp({Transparency = 0}, 0.2)

                task.delay(0.2, function()
                    v[1].Visible = false

                    self.fading = false
                end)
            end
        else
            self.fading = true

            for i, v in pairs(library.drawings[1]) do
                v[1].Visible = true
                v[1].Transparency = 0
    
                v[1].Lerp({Transparency = v[2]}, 0.2)
            end

            task.delay(0.2, function()
                self.fading = false
            end)

            local from = tick()

            while tick()-from < 0.2 and task.wait() do
                self:SelectTab(self.sshit)
            end
        end
    end

    function window.Watermark(self)

        local watermark_frame = utility:Draw("Square", v2zero, {

        })

    end

    function window.Init(self)

        for _, tab in pairs(self.tabs) do
            tab:Update()
        end

        self:Fade()

        task.wait(0.2)

        self:SelectTab(self.sshit)

        library.loaded = true

        function self.Unload(self)
            for i, v in pairs(utility:Combine(library.drawings[1], library.drawings[2])) do
                v[1]:Remove()
            end

            for i, v in pairs(library.connections) do
                v:Disconnect()
            end
        end
    end

    return window
end