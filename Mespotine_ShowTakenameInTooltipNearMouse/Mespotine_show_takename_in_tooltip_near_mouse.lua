-- Show Item-Take-Name as tooltip, when mouse hovering above an item-take
-- Meo Mespotine, 24th of September 2023 - licensed under MIT-license

if reaper.BR_Win32_GetWindowText==nil then
  reaper.MB("This needs latest SWS installed to work. \n\nPlease install it from sws-extension.org/download/pre-release/", "SWS missing", 0)
  return
end

function main()
  X,Y=reaper.GetMousePosition()
  MediaItem, MediaItem_Take = reaper.GetItemFromPoint(X, Y, true)
  A=reaper.GetTooltipWindow()
  retval, A2 = reaper.BR_Win32_GetWindowText(A)
  if MediaItem_Take~=nil and (OldTake==nil or A2=="") then
    PCM_Source=reaper.GetMediaItemTake_Source(MediaItem_Take)
    takename = reaper.GetTakeName(MediaItem_Take)
    filenamebuf = reaper.GetMediaSourceFileName(PCM_Source, "")
    filenamebuf=string.gsub(filenamebuf, "\\", "/")
    filenamebuf=filenamebuf:match(".*/(.*)")
    if filenamebuf==nil then filenamebuf="" end
    if takename==nil then takename="" end
    if filenamebuf~="" then filenamebuf="\nSource: "..filenamebuf end
    reaper.TrackCtl_SetToolTip("Name:  "..takename..filenamebuf, X+10, Y+10, false)
  end
  OldTake=MediaItem_Take
  reaper.defer(main)
end

main()
