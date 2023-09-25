-- Meo-Ada Mespotine 25th of September 2023 - licensed under MIT-license
-- enhance a RazorEdit to the item's previous transient at mouse position

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
reaper.PreventUIRefresh(1)
x,y=reaper.GetMousePosition()
MediaTrack = reaper.GetTrackFromPoint(reaper.GetMousePosition())
item = reaper.GetItemFromPoint(x, y, true)
razor_edit_index, start_position, end_position, track, envelope = ultraschall.RazorEdit_GetFromPoint(reaper.GetMousePosition())

if item~=nil and razor_edit_index>-1 then
  MediaItemArray={}
  for i=reaper.CountSelectedMediaItems(0)-1, 0, -1 do
    local item2 = reaper.GetSelectedMediaItem(0, i)
    MediaItemArray[i+1]=item2
    reaper.SetMediaItemSelected(item2, false)
  end
  
  local editcursor_old=reaper.GetCursorPosition()
  reaper.SetMediaItemSelected(item, true)
  reaper.SetEditCurPos(start_position, false, false)
  reaper.Main_OnCommand(40376, 0)
  local editcursor_new=reaper.GetCursorPosition()
  retval = ultraschall.RazorEdit_Set_Track(MediaTrack, razor_edit_index, editcursor_new, end_position)
  
  reaper.SetMediaItemSelected(item, false)
  
  for i=1, #MediaItemArray do
    reaper.SetMediaItemSelected(MediaItemArray[i], true)
  end
  
  reaper.SetEditCurPos(editcursor_old, false, false)
  reaper.UpdateArrange()
end  
reaper.PreventUIRefresh(1)
reaper.Undo_EndBlock("Enhance RazorEdit to previous transient", -1)
