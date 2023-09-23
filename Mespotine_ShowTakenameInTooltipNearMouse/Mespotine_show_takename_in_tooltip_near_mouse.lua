-- Show Item-Take-Name as tooltip, when mouse hovering above an item-take
-- Meo Mespotine, 7th of April 2020 - licensed under MIT-license

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
    filenamebuf = reaper.GetMediaSourceFileName(PCM_Source, "")
    filenamebuf=string.gsub(filenamebuf, "\\", "/")
    filenamebuf=filenamebuf:match(".*/(.*)")
    reaper.TrackCtl_SetToolTip(filenamebuf, X+10, Y+10, false)
  end
  OldTake=MediaItem_Take
  reaper.defer(main)
end

main()
