local NAME = "Vehicle Master Pro"
local VERSION = "1.7.0"

pcall(function() ClickGUI.RemoveTab(NAME) end)

local states = {
    hood = false,
    trunk = false,
    stance = false
}

-- Функция получения авто через внутренние объекты Cherax
local function GetCurrentVehicle()
    -- 1. Получаем локального игрока как объект класса CPed
    local localPlayer = Player.GetLocal():GetPed()
    if not localPlayer then return nil end

    -- 2. Используем встроенный метод класса CPed для получения машины
    -- В Cherax API это обычно CurrentVehicle или метод GetVehicle()
    local veh = localPlayer.CurrentVehicle
    
    -- Если объект существует и это машина
    if veh and veh.IsVehicle then
        return veh
    end
    return nil
end

Script.RegisterLooped(function()
    local veh = GetCurrentVehicle()
    
    if veh then
        -- В Cherax объекты имеют методы, которые работают напрямую
        -- Но мы также можем использовать нативы через их хэндл (Address/ID)
        local vehHandle = veh:GetAddress() 

        if states.hood then
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehHandle, 4, false, false)
        end
        
        if states.trunk then
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehHandle, 5, false, false)
        end

        if states.stance then
            VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehHandle, false)
            for i = 0, 7 do
                VEHICLE.SET_VEHICLE_WHEEL_HEALTH(vehHandle, i, 800.0)
            end
        end
    end
    Script.Yield(500)
end)

ClickGUI.AddTab(NAME, function()
    ImGui.TextColored(0.0, 1.0, 1.0, 1.0, "Vehicle Master: " .. VERSION)
    ImGui.Separator()

    local veh = GetCurrentVehicle()
    
    if not veh then
        ImGui.TextColored(1.0, 0.0, 0.0, 1.0, "Статус: Машина не найдена")
        ImGui.Text("Сядьте за руль, чтобы активировать меню.")
    else
        ImGui.TextColored(0.0, 1.0, 0.0, 1.0, "Статус: Машина захвачена")
        -- Выведем имя модели для проверки
        local model = veh.ModelInfo
        if model then
            ImGui.Text("Модель: " .. tostring(model.Model))
        end
    end

    ImGui.Separator()

    states.hood = ImGui.Checkbox("Открыть капот", states.hood)
    states.trunk = ImGui.Checkbox("Открыть багажник", states.trunk)
    states.stance = ImGui.Checkbox("Стенс занижение", states.stance)

    ImGui.Spacing()

    if ImGui.Button("Полная починка", 160, 25) then
        if veh then
            VEHICLE.SET_VEHICLE_FIXED(veh:GetAddress())
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh:GetAddress(), 0.0)
        end
    end
end)
