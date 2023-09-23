-- marker selector by Meo-Ada Mespotine
-- This sets up the Marker Selector Feature
-- 23rd of September 2023
-- licensed under MIT-license

state=reaper.MB("Meo-Ada Mespotine - Marker Selector 23rd of September 2023\n\nThis will install the Marker Selector. This will allow you to quickly type the number of a marker and Reaper will automatically jump to it.\n\nShall we continue with the setup?", "Setup Marker Selector", 4)

if state==7 then return end

function WriteValueToFile(filename_with_path, value, binarymode, append)
  -- Writes value to filename_with_path
  -- Keep in mind, that you need to escape \ by writing \\, or it will not work
  -- binarymode
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>WriteValueToFile</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer retval = ultraschall.WriteValueToFile(string filename_with_path, string value, optional boolean binarymode, optional boolean append)</functioncall>
  <description>
    Writes value to filename_with_path. Will replace any previous content of the file if append is set to false. Returns -1 in case of failure, 1 in case of success.
    
    returns -1 in case of an error
  </description>
  <retvals>
    integer retval  - -1 in case of failure, 1 in case of success
  </retvals>
  <parameters>
    string filename_with_path - the filename with it's path
    string value - the value to export, can be a long string that includes newlines and stuff. nil is not allowed!
    boolean binarymode - true or nil, it will store the value as binary-file; false, will store it as textstring
    boolean append - true, add the value to the end of the file; false or nil, write value to file and erase all previous data in the file
  </parameters>
  <chapter_context>
    File Management
    Write Files
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_FileManagement_Module.lua</source_document>
  <tags>filemanagement,export,write,file,textfile,binary</tags>
</US_DocBloc>
--]]
  -- check parameters
  if type(filename_with_path)~="string" then return -1 end
  --if type(value)~="string" then ultraschall.AddErrorMessage("WriteValueToFile","value", "must be string; convert with tostring(value), if necessary.", -2) return -1 end
  value=tostring(value)
  
  -- prepare variables
  local binary, appendix, file
  if binarymode==nil or binarymode==true then binary="b" else binary="" end
  if append==nil or append==false then appendix="w" else appendix="a" end
  
  -- write file
  file=io.open(filename_with_path,appendix..binary)
  if file==nil then return -1 end
  file:write(value)
  file:close()
  return 1
end

NumberScripts0=[[
-- marker selector-script for the ]]
NumberScripts1=[[-key by Meo-Ada Mespotine
-- 23rd of September 2023
-- licensed under MIT-license

if reaper.GetExtState("Mespotine", "Marker Selector")=="" then
  retval, filename = reaper.get_action_context()
  path=string.gsub(filename, "\\", "/")
  path=path:match("(.*)/")
  id=reaper.AddRemoveReaScript(true, 0, path.."/Mespotine_Marker_Selector_Backgroundscript.lua", true)
  reaper.Main_OnCommand(id, 0)
end

reaper.SetExtState("mespotine_marker_selector", "number", "]] 
NumberScripts2=
[[", false)
]]


for i=0, 9 do
  reaper.RecursiveCreateDirectory(reaper.GetResourcePath().."/Scripts/Mespotine_Scripts/", 0)
  WriteValueToFile(reaper.GetResourcePath().."/Scripts/Mespotine_Scripts/Mespotine_Marker_Selector_"..i..".lua", NumberScripts0..i..NumberScripts1..i..NumberScripts2)
end

WriteValueToFile(reaper.GetResourcePath().."/Scripts/Mespotine_Scripts/Mespotine_Marker_Selector_Backgroundscript.lua", 
[[-- marker selector background-script by Meo-Ada Mespotine
-- 23rd of September 2023
-- licensed under MIT-license



function GetWaitTime()
  local length=15 -- 33 = 1 sec; set it to lower if the waittime shall be shorter
  local state=reaper.GetExtState("Mespotine", "Marker Selector Waittime")
  if state~="" then length=tonumber(state) end
  return length
end



--- keep the following lines untouched

reaper.SetExtState("Mespotine", "Marker Selector", "running", false)

count=0
marker_nr=""

function atexit()
  reaper.DeleteExtState("Mespotine", "Marker Selector", false)
end

reaper.atexit(atexit)

function FindMyMarker(number)
  for i=0, reaper.CountProjectMarkers(0)-1 do
    retval, _, _, _, _, markerid = reaper.EnumProjectMarkers3(0, i)
    if markerid==number then return i+1 end
  end
  return -1
end

function main()
  state=reaper.GetExtState("mespotine_marker_selector", "number")
  reaper.SetExtState("mespotine_marker_selector", "number", "", false)
  if state~="" then
    marker_nr=marker_nr..state
    count=0
  end
  count=count+1
  if count>GetWaitTime() then
    if marker_nr~="" then
      num=FindMyMarker(tonumber(marker_nr))
      if num>-1 then
        reaper.GoToMarker(0, FindMyMarker(tonumber(marker_nr)), true)
      end
    end
    marker_nr=""
    count=0
  end
  reaper.defer(main)
end

main()
]])

WriteValueToFile(reaper.GetResourcePath().."/Scripts/Mespotine_Scripts/Mespotine_Marker_Selector_SetWaitTime.lua", 
[[
-- marker selector wait time-setup by Meo-Ada Mespotine
-- 23rd of September 2023
-- licensed under MIT-license

length=15 -- 33 = 1 sec; set it to lower if the waittime shall be shorter
state=reaper.GetExtState("Mespotine", "Marker Selector Waittime")
if state~="" then length=tonumber(state) end
retval, length = reaper.GetUserInputs("Set the waiting-time for commit(33 for one second)", 1, "15=half a second; 1=a second", length)

if tonumber(length)==nil then 
  reaper.MB("Must be a number!", "Error", 0) 
else
  reaper.SetExtState("Mespotine", "Marker Selector Waittime", length, true)
end

]])


retval, filename = reaper.get_action_context()
path=reaper.GetResourcePath().."/Scripts/Mespotine_Scripts/"

id=reaper.AddRemoveReaScript(true, 0, path.."/Mespotine_Marker_Selector_Backgroundscript.lua", true)
id=reaper.AddRemoveReaScript(true, 0, path.."/Mespotine_Marker_Selector_SetWaitTime.lua", true)

reaper.MB("Now we will set up some shortcuts. Just follow the instructions of the next message boxes and you'll be fine.", "Halfway through", 0)

for i=0, 9 do
  id=reaper.AddRemoveReaScript(true, 0, path.."/Mespotine_Marker_Selector_"..i..".lua", true)
  reaper.MB("Type the "..i.."-key in the next dialog and hit ok","",0)
  count=reaper.CountActionShortcuts(0, id)
  reaper.DoActionShortcutDialog(reaper.GetMainHwnd(), 0, id, count+1)
end


reaper.MB("If you set everything correctly, you can now type the numbers of the markers to jump to them.\n\nIf a key isn't recognizing the right number, run this script again.", "Finished", 0)
--]]
