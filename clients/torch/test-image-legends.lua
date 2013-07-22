require 'sys'
require 'gfx.go'

sys.sleep(1)

i = image.lena()
i = image.scale(i, '^512')

images = {}
for t = 1,16 do
   local i = i:clone()
   for c = 1,3 do
      i[c]:mul(torch.normal(1,0.5))
   end
   table.insert(images, i)
end

gfx.image(images, {zoom=1/2, legend='One legend for lots of images!'})
gfx.image(images[1], {zoom=1/2, legend='One legend, one image!'})
gfx.image(images, {zoom=1/2}) -- no legend, lots of images
gfx.image(images[1], {zoom=1/2}) -- no legend, one image
gfx.image(images, {zoom=1/2, legends={'One legend for one image', nil,nil, 'Another legend'}})
