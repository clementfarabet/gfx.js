
path = arg[1] or error('test-video.lua /path/to/video.mov')

require 'ffmpeg'
require 'gfx.go'

torch.setdefaulttensortype('torch.FloatTensor')

vid = ffmpeg.Video{path=path, width=640, height=480, fps=20, length=20, encoding='jpg', delete=false}

i = vid:forward()
refresh = gfx.image(i, {refresh=50})

while true do
   i = vid:forward()
   refresh(i)
   collectgarbage()
end

