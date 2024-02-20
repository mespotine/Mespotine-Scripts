-- Meo-Ada Mespotine 19th of February 2024 - licensed under MIT-license
-- Choose Sound that is played when render finishes

ultraschall={}

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

retval, filename = reaper.GetUserFileNameForRead(reaper.GetExtState("Mespotine", "SoundWhenRenderIsFinished_OldFolder") , "Select Sound", "*.mp3;*.wav;*.flac;*.mp4;*.aif")

if retval==true then 
  reaper.SetExtState("Mespotine", "SoundWhenRenderIsFinished_OldFolder", string.gsub(filename,"\\","/"):match(".*/"), true) 
  reaper.SetExtState("Mespotine", "SoundWhenRenderIsFinished", filename, true) 
  
  PreviewMediaFile(reaper.GetExtState("Mespotine", "SoundWhenRenderIsFinished"))
end