require 'sys'
require 'gfx.go'

points = {}

for i = 1,100 do
   table.insert(points, {
      x = i,
      y = torch.normal(),
   })
   win = gfx.chart({values=points}, {chart='line', win=win})
   sys.sleep(1)
end

