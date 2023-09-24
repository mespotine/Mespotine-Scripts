-- Meo-Ada Mespotine 24th of September 2023
-- Quickzoom - toggles between two zoom-factors: one close in the project, the other the last used
-- licensed under MIT-license

zoomfactor=reaper.GetHZoomLevel() -- get current zoom-level
ZoomedInLevelDef=400              -- set this to the "zoom in"-level, you want to have
                                  -- 0.007(max zoom out) to 1000000(max zoom in) is valid,
                                  -- 400 is recommended
Zoomstate=reaper.GetExtState("Mespotine_QuickZoom","zoom_toggle_state")
ZoomedInLevel=reaper.GetExtState("Mespotine_QuickZoom","zoomin_level")
ZoomedInLevel=tonumber(ZoomedInLevel)
if ZoomedInLevel==-1 or ZoomedInLevel==nil then
  ZoomedInLevel=ZoomedInLevelDef
end

if Zoomstate=="false" or zoomfactor~=ZoomedInLevel then
   reaper.SetExtState("Mespotine_QuickZoom", "zoom_toggle_state", "true", false)
   reaper.SetExtState("Mespotine_QuickZoom", "old_zoomfactor", zoomfactor, false)
   reaper.adjustZoom(ZoomedInLevel, 1, true, 0)
else
  reaper.SetExtState("Mespotine_QuickZoom", "zoom_toggle_state", "false", false)
  oldzoomfactor=reaper.GetExtState("Mespotine_QuickZoom","old_zoomfactor")
  reaper.adjustZoom(tonumber(oldzoomfactor), 1, true, 0)
end