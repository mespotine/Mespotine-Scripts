-- Meo-Ada Mespotine 2nd of October 2023 - licensed under MIT-license
-- Render to File that opens a menu to select the used render-preset

retval, filename = reaper.GetUserFileNameForRead("", "Select Sound", "*.mp3;*.wav;*.flac;*.mp4;*.aif")
if retval==true then reaper.SetExtState("Mespotine", "SoundWhenRenderIsFinished", filename, true) end
