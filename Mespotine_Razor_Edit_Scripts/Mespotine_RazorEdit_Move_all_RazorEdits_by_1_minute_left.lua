-- Meo-Ada Mespotine 26th of September 2023 - licensed under MIT-license
-- Move all RazorEdit-areas by 1 minute left

function CheckForDependencies(ReaImGui, js_ReaScript, US_API, SWS, Osara)
  if US_API==true or js_ReaScript==true or ReaImGui==true or SWS==true or Osara==true then
    if US_API==true and reaper.file_exists(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")==false then
      US_API="Ultraschall API" -- "Ultraschall API" or ""
    else
      US_API=""
    end
    
    if reaper.JS_ReaScriptAPI_Version==nil and js_ReaScript==true then
      js_ReaScript="js_ReaScript" -- "js_ReaScript" or ""
    else
      js_ReaScript=""
    end
    
    if reaper.ImGui_GetVersion==nil and ReaImGui==true then
      ReaImGui="ReaImGui" -- "ReaImGui" or ""
    else
      ReaImGui=""
    end
    
    if reaper.CF_GetSWSVersion==nil and SWS==true then
      SWS="SWS" -- "ReaImGui" or ""
    else
      SWS=""
    end
    
    if reaper.osara_outputMessage==nil and Osara==true then
      Osara="Osara" -- "ReaImGui" or ""
    else
      Osara=""
    end
    
    if Osara=="" and SWS=="" and js_ReaScript=="" and ReaImGui=="" and US_API=="" then return true end
    local state=reaper.MB("This script needs additionally \n\n"..ReaImGui.."\n"..js_ReaScript.."\n"..US_API.."\n"..SWS.."\n"..Osara.."\n\ninstalled to work. Do you want to install them?", "Dependencies required", 4) 
    if state==7 then return false end
    if SWS~="" then
      reaper.MB("SWS can be downloaded from sws-extension.org/download/pre-release/", "SWS missing", 0)
    end
    
    if Osara~="" then
      reaper.MB("Osara can be downloaded from https://osara.reaperaccessibility.com/", "Osara missing", 0)
    end
    
    if reaper.ReaPack_BrowsePackages==nil and (US_API~="" or ReaImGui~="" or js_ReaScript~="") then
      reaper.MB("Some uninstalled dependencies need ReaPack to be installed. Can be downloaded from https://reapack.com/", "ReaPack missing", 0)
      return false
    else
      
      if US_API=="Ultraschall API" then
        reaper.ReaPack_AddSetRepository("Ultraschall API", "https://github.com/Ultraschall/ultraschall-lua-api-for-reaper/raw/master/ultraschall_api_index.xml", true, 2)
        reaper.ReaPack_ProcessQueue(true)
      end
      
      if US_API~="" or ReaImGui~="" or js_ReaScript~="" then 
        reaper.ReaPack_BrowsePackages(js_ReaScript.." OR "..ReaImGui.." OR "..US_API)
      end
    end
  end
  return true
end

state=CheckForDependencies(false, true, true, true, false)

if state==false then return end

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

delta = -60

reaper.Undo_BeginBlock()
for i=0, reaper.CountTracks(0)-1 do
  local track=reaper.GetTrack(0, i)
   retval = ultraschall.RazorEdit_Nudge_Track(track, delta)
  for i2=0, reaper.CountTrackEnvelopes(track) do
    TrackEnvelope = reaper.GetTrackEnvelope(track, i2)
    retval = ultraschall.RazorEdit_Nudge_Envelope(TrackEnvelope, delta)
  end
end
reaper.Undo_EndBlock("Move all RazorEdits 1 minute to the left", -1)
