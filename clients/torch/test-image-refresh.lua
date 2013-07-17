require 'sys'
require 'gfx.go'

sys.sleep(3)
win = gfx.image(image.lena())
sys.sleep(3)
win = gfx.image(image.lena()*-1+1, {win=win})
sys.sleep(3)
win = gfx.image({
   image.lena()*-1+1,
   image.lena(),
   image.lena()*-1+1,
   image.lena(),
}, {win=win})

