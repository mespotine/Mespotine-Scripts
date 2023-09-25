-- Meo-Ada Mespotine 25th of September 2023 - licensed under MIT-license
-- snap RazorEdit-end to editcursor at mouse position

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

reaper.Undo_BeginBlock()

MediaTrack = reaper.GetTrackFromPoint(reaper.GetMousePosition())
Envelope = ultraschall.GetTrackEnvelopeFromPoint(reaper.GetMousePosition())

x,y=reaper.GetMousePosition()

razor_edit_index, start_position, end_position, track, envelope = ultraschall.RazorEdit_GetFromPoint(reaper.GetMousePosition())
editcursor=reaper.GetCursorPosition()
dif=editcursor-end_position
--print2(editcursor-start_position)

if Envelope==nil then
  --altered_razor_edit_string = ultraschall.RazorEdit_Add_Track(MediaTrack, start, stop) 
  retval = ultraschall.RazorEdit_Set_Track(MediaTrack, razor_edit_index, start_position+dif, end_position+dif)
else
  --altered_razor_edit_string = ultraschall.RazorEdit_Add_Envelope(Envelope, start, stop)
  retval = ultraschall.RazorEdit_Set_Envelope(Envelope, razor_edit_index, start_position+dif, end_position+dif)
end


reaper.Undo_EndBlock("Snap right edge of RazorArea To Edit Cursor", -1)
