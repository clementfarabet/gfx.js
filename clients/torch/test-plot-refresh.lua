require 'sys'
require 'gfx.go'

points = {}

for i = 1,100 do
   table.insert(points, {
      x = i,
      y = math.sin(i/10),
   })
   win = gfx.chart({values=points}, {chart='line', win=win, width=1024, height=768})
   sys.sleep(0.1)
end

