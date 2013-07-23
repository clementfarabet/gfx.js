require 'sys'
require 'gfx.go'

sys.sleep(1)

N = 1000

n = torch.Tensor(N,2):normal(0,1)
u = torch.Tensor(N,2):uniform(-1,1)

gfx.chart({
   {values=n, key='Normal'},
   {values=u, key='Uniform'},
}, {
   width = 1024,
   height = 768,
   chart = 'scatter',
})

