-- OBS Studio Mixer-Sync Script für feste Quellen
obs = obslua

-- Feste Quellenbezüge definieren
local ref_source_name = "[A] Digital-In"
local target_source_names = { "Aver 1600x1200", "Aver FS 1920x1440", "AverMedia USB FS" }
local last_vol = nil

-- Beschreibung des Skripts, wie es in OBS angezeigt wird
function script_description()
    return "Dieses Skript synchronisiert die Lautstärke der Mixerquelle '[A] Digital-In' für die Zielquellen 'Aver 1600x1200' und 'Aver FS 1920x1440'."
end

-- Diese Funktion wird periodisch aufgerufen (alle 50 ms)
function sync_volume()
    local ref_source = obs.obs_get_source_by_name(ref_source_name)
    if ref_source then
        local vol = obs.obs_source_get_volume(ref_source)
        -- Nur wenn sich der Pegel geändert hat, wird synchronisiert
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
        obs.obs_source_release(ref_source)
    end
end

-- Diese Funktion wird beim Laden des Skripts aufgerufen
function script_load(settings)
    obs.timer_add(sync_volume, 50)  -- Timer, der alle 50 ms die Funktion sync_volume() aufruft
end

-- Aufräumarbeiten beim Entladen des Skripts
function script_unload()
    obs.timer_remove(sync_volume)
end