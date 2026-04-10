-- core/localization.lua
-- Localized strings for Murderers VS Sheriffs

if not Mega then Mega = {} end

Mega.Localization = {
    CurrentLanguage = "ru",
    Strings = {
        ["notify_enabled"] = { ru = "ВКЛЮЧЕНО", en = "ENABLED" },
        ["notify_disabled"] = { ru = "ВЫКЛЮЧЕНО", en = "DISABLED" },
        ["slider_label"] = { ru = "%s: %s", en = "%s: %s" },
        ["dropdown_label"] = { ru = " %s:", en = " %s:" },
        ["keybind_none"] = { ru = "Нет", en = "None" },
        ["keybind_listening"] = { ru = "Нажми клавишу...", en = "Press a key..." },
        ["notify_keybind_set"] = { ru = "%s привязана к %s", en = "%s bound to %s" },
        ["notify_keybind_removed"] = { ru = "Бинд для %s удален", en = "Keybind for %s removed" },
        
        -- MVS Specific
        ["tab_mvs"] = { ru = "MVS", en = "MVS" },
        ["tab_player"] = { ru = "ИГРОК", en = "PLAYER" },
        ["tab_settings"] = { ru = "НАСТРОЙКИ", en = "SETTINGS" },
        
        ["section_mvs_main"] = { ru = "🔪 MURDERERS VS SHERIFFS", en = "🔪 MURDERERS VS SHERIFFS" },
        ["toggle_mvs_esp"] = { ru = "Включить ESP", en = "Enable ESP" },
        ["toggle_mvs_silent_aim"] = { ru = "Silent Aim (Тихий Aim)", en = "Silent Aim" },
        ["toggle_mvs_autostab"] = { ru = "Auto-Stab (Авто-удар)", en = "Auto-Stab" },
        
        ["section_mvs_esp_settings"] = { ru = "⚙️ НАСТРОЙКИ ESP", en = "⚙️ ESP SETTINGS" },
        ["toggle_mvs_show_murderer"] = { ru = "Показывать Убийцу", en = "Show Murderer" },
        ["toggle_mvs_show_sheriff"] = { ru = "Показывать Шерифа", en = "Show Sheriff" },
        ["toggle_mvs_show_innocent"] = { ru = "Показывать Мирных", en = "Show Innocents" },
        
        ["section_player_movement"] = { ru = "⚡ ДВИЖЕНИЕ", en = "⚡ MOVEMENT" },
        ["toggle_speed"] = { ru = "Спидхак", en = "Speedhack" },
        ["slider_speed"] = { ru = "Скорость", en = "Speed" },
        ["toggle_inf_jump"] = { ru = "Бесконечный прыжок", en = "Infinite Jump" },
        
        ["section_settings_menu"] = { ru = "🎨 НАСТРОЙКИ МЕНЮ", en = "🎨 MENU SETTINGS" },
        ["keybind_menu"] = { ru = "Клавиша меню", en = "Menu Key" }
    }
}

function Mega.GetText(key, ...)
    local lang = Mega.Localization.CurrentLanguage
    local str = Mega.Localization.Strings[key]
    if str and str[lang] then
        local text = str[lang]
        if select("#", ...) > 0 then
            return string.format(text, ...)
        end
        return text
    end
    return key
end
