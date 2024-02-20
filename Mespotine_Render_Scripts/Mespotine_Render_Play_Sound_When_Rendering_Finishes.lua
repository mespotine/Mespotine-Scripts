-- Meo-Ada Mespotine 19th of February 2024 - licensed under MIT-license
-- Plays sound when render finishes/is aborted

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

state=CheckForDependencies(false, true, false, false, false)

if state==false then return end

ultraschall={}

function IsReaperRendering()
  local A,B=reaper.EnumProjects(0x40000000,"")  
  if A~=nil then 
    return true, reaper.GetPlayPositionEx(A), reaper.GetProjectLength(A), A
  else return false 
  end
end

function PreviewMediaFile(filename_with_path, gain, loop, outputChannel)
  if type(filename_with_path)~="string" then return false end
  if reaper.file_exists(filename_with_path)== false then return false end

  if type(loop)~="boolean" then loop=false end
  if type(gain)~="number" then gain=1 end
  if outputChannel~=nil and math.type(outputChannel)~="integer" then return false end
  if outputChannel==nil then outputChannel=0 end

  reaper.Xen_StopSourcePreview(-1)
  
  ultraschall.PreviewPCMSource=reaper.PCM_Source_CreateFromFile(filename_with_path)
  
  local retval=reaper.Xen_StartSourcePreview(ultraschall.PreviewPCMSource, gain, loop, outputChannel)
  return retval
end

function main()
  if IsReaperRendering()==false and oldrender==true then
    PreviewMediaFile(reaper.GetExtState("Mespotine", "SoundWhenRenderIsFinished"))
  end
  oldrender=IsReaperRendering()
  reaper.defer(main)
end

--reaper.SetExtState("Mespotine", "SoundWhenRenderIsFinished", "", true)

if reaper.GetExtState("Mespotine", "SoundWhenRenderIsFinished")=="" then
  A=reaper.MB("No sound yet selected, do you want to choose one?", "No sound yet", 4)
  if A==6 then
    retval, filename = reaper.GetUserFileNameForRead("", "Select Sound", "*.mp3;*.wav;*.flac;*.mp4;*.aif")
    if retval==true then 
      reaper.SetExtState("Mespotine", "SoundWhenRenderIsFinished", filename, true) 
    else 
      return 
    end
    PreviewMediaFile(reaper.GetExtState("Mespotine", "SoundWhenRenderIsFinished"))
  end
end

main()

function atexit()
  reaper.Xen_StopSourcePreview(-1)
end

reaper.atexit(atexit)