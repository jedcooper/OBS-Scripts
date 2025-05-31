-- OBS Studio Mixer-Sync Script inkl. Mute-Synchronisation für feste Quellen
obs = obslua

local ref_source_name = "[A] Digital-In"
local target_source_names = { "Aver 1600x1200", "Aver FS 1920x1440", "AverMedia USB FS" }
local last_vol = nil
local last_muted = nil

function script_description()
    return "Dieses Skript synchronisiert die Lautstärke und den Mute-Zustand der Mixerquelle '[A] Digital-In' mit den Zielquellen 'Aver 1600x1200' und 'Aver FS 1920x1440'. Die Überprüfung erfolgt alle 2000 Millisekunden (2 Sekunden)."
end

function sync_volume_and_mute()
    local ref_source = obs.obs_get_source_by_name(ref_source_name)
    if ref_source then
        local vol = obs.obs_source_get_volume(ref_source)
        local is_muted = obs.obs_source_muted(ref_source)
        
        -- Aktualisiere die Lautstärke der Zielquellen, wenn sie sich geändert hat
        if vol ~= last_vol then
            last_vol = vol
            for _, target in ipairs(target_source_names) do
                local target_source = obs.obs_get_source_by_name(target)
                if target_source then
                    obs.obs_source_set_volume(target_source, vol)
                    obs.obs_source_release(target_source)
                end
            end
        end
        
        -- Aktualisiere den Mute-Zustand der Zielquellen, wenn er sich geändert hat
        if last_muted == nil or is_muted ~= last_muted then
            last_muted = is_muted
            for _, target in ipairs(target_source_names) do
                local target_source = obs.obs_get_source_by_name(target)
                if target_source then
                    obs.obs_source_set_muted(target_source, is_muted)
                    obs.obs_source_release(target_source)
                end
            end
        end
        
        obs.obs_source_release(ref_source)
    end
end

function script_load(settings)
    obs.timer_add(sync_volume_and_mute, 1000)  -- überprüft alle xx ms 
end

function script_unload()
    obs.timer_remove(sync_volume_and_mute)
end