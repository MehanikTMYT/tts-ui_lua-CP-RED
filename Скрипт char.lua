--Скрипт char

firstStart = true

skillColors = {
    int  = "#1E8CFF", -- Интеллект
    rea  = "#F670CD", -- Реакция
    dex  = "#30B22A", -- Ловкость
    tech = "#F4641C", -- Техника
    cha  = "#9F1FD6", -- Харизма
    will = "#404040", -- Воля
    luck = "#21B19A", -- Удача
    move = "#713B17", -- Перемещение
    body = "#CC804D", -- Тело
    emp  = "#808080", -- Эмпатия
}
--Функция для получения цвета по характеристике 
function getColorForStat(statName)
    return skillColors[statName] or "#FFFFFF" -- default белый, если не найдено
end

statMap = {
    ["int"] = "int_counter_value",
    ["rea"] = "rea_counter_value",
    ["dex"] = "dex_counter_value",
    ["tech"] = "tech_counter_value",
    ["cha"] = "cha_counter_value",
    ["will"] = "will_counter_value",
    ["emp"] = "emp_counter_value",
    ["MOVE"] = "move_counter_value",
    ["BODY"] = "body_counter_value",
    ["LUCK"] = "luck_counter_value"
}

-- ==== Маппинг характеристик для навыков ====
STAT_MAP_SHORT = {
    int  = "int",
    rea  = "rea",
    dex  = "dex",
    tech = "tech",
    cha  = "cha",
    will = "will",
    emp  = "emp"
}

-- ==== Сопоставление ID счётчиков ====
COUNTER_MAP = {
    health       = "health_counter_value",
    health_max   = "health_max_counter_value",
    body         = "body_counter_value",
    move         = "move_counter_value",
    will         = "will_counter_value",
    cha          = "cha_counter_value",
    rea          = "rea_counter_value",
    tec         = "tech_counter_value",
    dex          = "dex_counter_value",
    int          = "int_counter_value",
    luck         = "luck_counter_value",
    emp          = "emp_counter_value",
    max_luck     = "luck_max_counter_value",
    max_emp      = "emp_max_counter_value"
}

-- ==== Маппинг счётчиков к характеристикам ====
COUNTER_STAT_MAP = {
    int_counter         = "int",
    rea_counter         = "rea",
    dex_counter         = "dex",
    tech_counter        = "tech",
    cha_counter         = "cha",
    will_counter        = "will",
    luck_counter        = "luck",
    luck_max_counter    = "luck",
    move_counter        = "move",
    body_counter        = "body",
    emp_counter         = "emp",
    emp_max_counter     = "emp"
}

-- ==== Глобальная таблица для хранения данных о навыках ====
SKILL_DATA = {}


-- ==== Обновление всех навыков по характеристике с передачей значения напрямую ====
function updateSkillsByStatDirect(statName, statValue)
    for skillId, skillData in pairs(SKILL_DATA) do
        if skillData.stat == statName then
            self.UI.setAttribute(skillId, "text", tostring(statValue))
            self.UI.setAttribute(skillData.sum_field_id, "text", tostring(statValue + skillData.mod_value))
            
        end
    end
end

-- ==== Функция добавления/удаления значения к счётчику ====
function updateCounter(counterId, delta)
    local cleanId = counterId:match("^(.+)_counter$")
    local inputId = COUNTER_MAP[cleanId]
    if not inputId then
        print("Неизвестный счётчик: " .. tostring(counterId))
        return
    end
    local currentValue = tonumber(self.UI.getAttribute(inputId, "text")) or 0
    local newValue = currentValue + delta
    self.UI.setAttribute(inputId, "text", tostring(newValue))
    -- Если это характеристика — обновляем все связанные поля
    local statToUpdate = STAT_MAP_SHORT[cleanId]
    if statToUpdate then
        updateSkillsByStatDirect(statToUpdate, newValue)
    end
end

-- ==== Функции изменения счётчиков ====
-- Интеллект
function counterIntAdd() updateCounter("int_counter", 1) end
function counterIntSub() updateCounter("int_counter", -1) end

-- Реакция
function counterReaAdd() updateCounter("rea_counter", 1) end
function counterReaSub() updateCounter("rea_counter", -1) end

-- Ловкость
function counterDexAdd() updateCounter("dex_counter", 1) end
function counterDexSub() updateCounter("dex_counter", -1) end

-- Технические навыки
function counterTechAdd() updateCounter("tech_counter", 1) end
function counterTechSub() updateCounter("tech_counter", -1) end

-- Харизма
function counterChaAdd() updateCounter("cha_counter", 1) end
function counterChaSub() updateCounter("cha_counter", -1) end

-- Воля
function counterWillAdd() updateCounter("will_counter", 1) end
function counterWillSub() updateCounter("will_counter", -1) end

-- Удача (текущая)
function counterLuckAdd() updateCounter("luck_counter", 1) end
function counterLuckSub() updateCounter("luck_counter", -1) end

-- Удача (макс)
function counterLuckMaxAdd() updateCounter("max_luck", 1) end
function counterLuckMaxSub() updateCounter("max_luck", -1) end

-- Перемещение (MOVE / СКО)
function counterMoveAdd() updateCounter("move_counter", 1) end
function counterMoveSub() updateCounter("move_counter", -1) end

-- Тело
function counterBodyAdd() updateCounter("body_counter", 1) end
function counterBodySub() updateCounter("body_counter", -1) end

-- Эмпатия (текущая)
function counterEmpAdd() updateCounter("emp_counter", 1) end
function counterEmpSub() updateCounter("emp_counter", -1) end

-- Эмпатия (макс)
function counterEmpMaxAdd() updateCounter("max_emp", 1) end
function counterEmpMaxSub() updateCounter("max_emp", -1) end

function string.trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

char_name = ""

function changeName(_, name) 
    char_name = name
end

-- ==== Обновление модификатора навыка ====
function change_mod(_, value, modId)
    local skillModId = modId:match("^(.+)_mod$").."_stat"

    for skillId, skillData in pairs(SKILL_DATA) do
        if skillModId == skillId then
            SKILL_DATA[skillId].mod_value = value
            local statValue = get_stat_value(skillData.stat)
            self.UI.setAttribute(skillData.sum_field_id, "text", tostring(statValue + value))
        end
    end
end

--Обновление вычисляемых полей
function updateAllFields()
    for skillId, skillData in pairs(SKILL_DATA) do
        local statValue = get_stat_value(skillData.stat)
        local modStr = self.UI.getAttribute(skillId .. "_mod", "text")
        local modifier = tonumber(modStr) or 0
        local sumField = skillId:match("^(.-)_stat").."_sum_stat"
        skillData.mod_value = modifier
        self.UI.setAttribute(sumField, "text", tostring(statValue + modifier))
    end
end

-- ==== Бросок кубика с обработкой критов ====
function rollD10WithCrit()
    local d10 = math.random(1, 10)
    local sd10 = 0
    local isCritical = (d10 == 10 or d10 == 1)

    if isCritical then
        sd10 = math.random(1, 10)
    end

    return d10, sd10, isCritical and d10 == 10, isCritical and d10 == 1
end

-- ==== Бросок проверки навыка с детальным выводом ====
function skill_roll(player, _, skillId)
    --print("Вызван skill_roll для skillId: " .. tostring(skillId))

    math.randomseed(os.time())

    local skillData = SKILL_DATA[skillId] or {}
    local statName = skillData.stat or "N/A"
    local statValue = get_stat_value(statName)

    -- Получаем модификатор из данных или 0
    local modifier = skillData.mod_value or 0

    -- Бросок кубика
    local d10, sd10, isCritSuccess, isCritFail = rollD10WithCrit()

    -- Подсчёт результата
    local result = d10 + modifier + statValue
    if isCritSuccess then
        result = result + sd10
    elseif isCritFail then
        result = result - sd10
    end

    -- Цвет сообщения
    local messageTint ="#FFFFFF"
    if isCritSuccess then messageTint = "#00FF00"
    elseif isCritFail then messageTint = "#FF0000" end

    -- Определяем имя игрока
    local playerName = char_name or ""  -- на случай, если char_name == nil
    if playerName:trim() == "" then
        playerName = player.steam_name
    end
    local skillLabel = self.UI.getAttribute(skillId, "text")

    -- Формирование сообщения
    local message
    if isCritSuccess then
        message = string.format(
            "%s получает КРИТ УСПЕХ: %d (d10) + %d (mod) + %d (stat) + %d (sd10) = %d при проверке навыка «%s»",
            playerName, d10, modifier, statValue, sd10, result, skillLabel
        )
    elseif isCritFail then
        message = string.format(
            "%s получает КРИТ ПРОВАЛ: %d (d10) - %d (sd10) + %d (mod) + %d (stat) = %d при проверке навыка «%s»",
            playerName, d10, sd10, modifier, statValue, result, skillLabel
        )
    else
        message = string.format(
            "%s получает: %d (d10) + %d (mod) + %d (stat) = %d при проверке навыка «%s»",
            playerName, d10, modifier, statValue, result, skillLabel
        )
    end

    -- Отправляем всем
    broadcastToAll(message, hexToColor(messageTint))
end

-- ==== Получение значения характеристики из UI ====
function get_stat_value(statName)
    local counterId = statMap[statName]
    if not counterId then return 0 end

    local valueStr = self.UI.getAttribute(counterId, "text")
    return tonumber(valueStr) or 0
end


-- ==== HEX -> RGB ====
function hexToColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return {r, g, b}
end

-- ==== Обновление текста кнопки навыка по имени поля ====
function update_skill_label(_, newLabel, inputId)
    local skillPrefix = inputId:match("^(.+)_name$")

    if not skillPrefix then
        print("Ошибка: не удалось извлечь префикс из ID: " .. inputId)
        return
    end

    local buttonId = skillPrefix .. "_button"
    local originalLabel = self.UI.getAttribute(buttonId, "tooltip") or ""

    -- Если новое имя пустое — восстанавливаем оригинальное
    if not newLabel or newLabel:trim() == "" then
        self.UI.setAttribute(buttonId, "text", originalLabel)
        --print("Восстановлено оригинальное имя кнопки: " .. buttonId .. " -> " .. originalLabel)
        return
    end

    -- Формируем новый текст кнопки с сохранением статистики (в скобках)
    local baseText = originalLabel:match("([^%(]+)")

    if baseText then
        baseText = baseText:trim()
        local statPart = originalLabel:match("%s*%([^%)]+%)") or ""
        local updatedLabel = newLabel .. " " .. statPart

        self.UI.setAttribute(buttonId, "text", updatedLabel)
        --print("Обновлено имя кнопки: " .. buttonId .. " -> " .. updatedLabel)
    else
        print("Не удалось разобрать базовое имя кнопки для " .. buttonId)
    end
end

-- ==== onLoad() — загрузка данных и отправка запроса на сервер ====
function onLoad()
    local data = self.getData()

    if type(data.XmlUI) ~= "string" then
        print("Ошибка: XmlUI не найден или не является строкой")
        return
    end

    local payload = JSON.encode({ xml = data.XmlUI })
    local API_URL = "http://147.45.184.36:3000/api/parse"

    WebRequest.post(API_URL, payload, function(request)
        if request.is_error then
            print("Ошибка при отправке запроса: " .. request.error)
            return
        end

        local response = JSON.decode(request.text)
        if not response or next(response) == nil then
            print("Сервер вернул пустой ответ")
            return
        end

        -- ====== Цвета для счётчиков =======================
        for counterId, statName in pairs(COUNTER_STAT_MAP) do
            local color = getColorForStat(statName)
            print(statName)
            local labelField   = counterId .. "_label"
            local valueField   = counterId .. "_value"
            local addButton    = counterId .. "_add"
            local subtractButton = counterId .. "_sub"

            self.UI.setAttribute(labelField, "color", color)
            self.UI.setAttribute(labelField, "font_color", "#FFFFFF")

            self.UI.setAttribute(valueField, "color", color)
            self.UI.setAttribute(valueField, "font_color", "#FFFFFF")

            self.UI.setAttribute(addButton, "color", color)
            self.UI.setAttribute(addButton, "font_color", "#FFFFFF")

            self.UI.setAttribute(subtractButton, "color", color)
            self.UI.setAttribute(subtractButton, "font_color", "#FFFFFF")
        end

        -- ====== Цвета и параметры для навыков ========================
        for skillId, statName in pairs(response) do
            local Field = skillId:match("^(.-)_stat")
            if Field then
                local buttonField = Field.."_button"
                local sumField = Field.."_sum_stat"
                local modField = Field.."_mod"
                local modStr = self.UI.getAttribute(skillId .. "_mod", "text")
                local modifier = tonumber(modStr) or 0
                local color = getColorForStat(statName)

                self.UI.setAttribute(buttonField, "font_color", "#FFFFFF")
                self.UI.setAttribute(buttonField, "color", color)
                self.UI.setAttribute(sumField, "color", color)
                self.UI.setAttribute(skillId, "color", color)
                local sumStat
                if firstStart then 
                    -- Проставляем значения
                    saved_data = ""
                    self.UI.setAttribute(modField, "text", modifier)
                    self.UI.setAttribute(skillId, "text", modifier)
                    self.UI.setAttribute(sumField, "text", modifier)
                    sumStat = 0
                else
                    updateAllFields()
                end
                -- Сохраняем данные о навыке
                SKILL_DATA[skillId] = {        
                stat = statName,
                mod_value = modifier,
                sum = sumStat,
                sum_field_id = sumField
            }
            end
        end
        print("Цвета успешно применены к счётчикам и навыкам")
    end)
    
end