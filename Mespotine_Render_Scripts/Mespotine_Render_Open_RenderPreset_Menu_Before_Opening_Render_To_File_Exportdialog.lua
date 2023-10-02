-- Meo-Ada Mespotine 2nd of October 2023 - licensed under MIT-license
-- Render to File that opens a menu to select the used render-preset

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

menu={}
menu[#menu+1]={"Render using last used settings", ""}
--menu[#menu+1]={"Render as MP3", "MP3"}
--if reaper.GetOS():match("OS")~=nil then menu[#menu+1]={"Render as M4A", "m4a_Mac"}
--elseif reaper.GetOS():match("Win") then menu[#menu+1]={"Render as M4A", "m4a_Windows"}
--end
--menu[#menu+1]={"Render as Auphonic Multichannel", "Auphonic Multichannel"}

menu_entries=""

bounds_presets, bounds_names, options_format_presets, options_format_names, both_presets, both_names = ultraschall.GetRenderPreset_Names()

for i=1, #both_names do
  menu[#menu+1]={both_names[i], both_names[i]}
end

for i=1, #menu do
  if i==1 then insert="#Render using preset|" else insert="" end
  menu_entries=menu_entries..menu[i][1].."|"..insert
end


menu_entries=menu_entries:sub(1,-2)
X,Y=reaper.GetMousePosition()
_,_,X2,Y2=reaper.my_getViewport(0,0,0,0,0,0,0,0,true)
if Y>Y2-150 then Y=Y2-150 end
retval = ultraschall.ShowMenu("Render to File", menu_entries, X+15, Y)


if retval==-1 then return end

if retval>1 then
  RenderTable = ultraschall.GetRenderPreset_RenderTable(menu[retval-1][2], menu[retval-1][2])
  if RenderTable==nil then return end
  ultraschall.ApplyRenderTable_Project(RenderTable)
end

--SLEM()
reaper.Main_OnCommand(40015, 0)

