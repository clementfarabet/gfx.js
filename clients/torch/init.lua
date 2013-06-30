--
-- A client to tty.js
--

require 'image'
require 'pl'
local json = require 'cjson'
local Template = require('pl.text').Template
text.format_operator()

local ttyjs = {}

ttyjs.static = os.getenv('HOME') .. '/.tty.js/static/data/'
ttyjs.template = os.getenv('HOME') .. '/.tty.js/templates/'
ttyjs.prefix = '/data/'

os.execute('rm -rf "' .. ttyjs.static .. '"')
os.execute('mkdir -p "' .. ttyjs.static .. '"')

ttyjs.templates = {}

local t = ttyjs.templates

for file in paths.files(ttyjs.template) do
   if file:find('html$') then
      local f = io.open(paths.concat(ttyjs.template,file))
      local template = f:read('*all')
      t[file:gsub('%.html$','')] = template
   end
end

local function uid()
   return 'dom_' .. (os.time() .. math.random()):gsub('%.','')
end

function ttyjs.image(img, opts)
   -- options:
   opts = opts or {}
   local zoom = opts.zoom or 1

   -- rescale image:
   img = img:clone():add(-img:min()):mul(1/img:max())

   -- img is a collection?
   if img:nDimension() == 4 or (img:nDimension() == 3 and img:size(1) > 3) then
      local images = {}
      for i = 1,img:size(1) do
         images[i] = img[i]
      end
      ttyjs.images(images, opts)
      return
   end

   -- dump image:
   local uid = uid()
   local filename = uid .. '.jpg'
   image.save(ttyjs.static..filename, img)

   -- zoom
   local zoom = zoom or 1
   local width
   if img:nDimension() == 2 then
      width = img:size(2) * zoom
   elseif img:nDimension() == 3 then
      width = img:size(3) * zoom
   else
      error('image must have two or three dimensions')
   end

   -- render template:
   local html = t.image % {width=width, filename=ttyjs.prefix..filename}
   local f = io.open(ttyjs.static..uid..'.html','w')
   f:write(html)
   f:close()
end

function ttyjs.images(images, opts)
   -- options:
   opts = opts or {}
   local nperrow = opts.nperrow or math.floor(math.sqrt(#images))
   local zoom = opts.zoom or 1
   local width = opts.width or 1200
   local height = opts.height or 800

   -- do all images:
   local templates = {}
   local maxwidth,maxheight = 0,0
   for _,img in ipairs(images) do
      -- rescale image:
      img = img:clone():add(-img:min()):mul(1/img:max())

      -- dump image:
      local uid = uid()
      local filename = uid .. '.jpg'
      image.save(ttyjs.static..filename, img)

      -- zoom
      local zoom = zoom or 1
      local width
      if img:nDimension() == 2 then
         width = img:size(2) * zoom
      elseif img:nDimension() == 3 then
         width = img:size(3) * zoom
      else
         error('image must have two or three dimensions')
      end

      -- max geometry
      maxwidth = math.max(maxwidth, width)
      maxheight = math.max(maxheight, width)

      -- render template:
      local html = t.image % {width=width, filename=ttyjs.prefix..filename}
      table.insert(templates, html)
   end

   -- generate container:
   local width = math.min(width, (maxwidth+4)*math.min(#images,nperrow))
   local height = math.min(height, math.ceil(#images / nperrow) * (maxheight+4))
   local html = t.window % {
      width = width, 
      height = height, 
      content = table.concat(templates, '\n')
   }
   local f = io.open(ttyjs.static..uid()..'.html','w')
   f:write(html)
   f:close()
end

-- chart?
local charts = {
   line = 'lineChart',
   bar = 'discreteBarChart',
   stacked = 'stackedAreaChart',
   multibar = 'multiBarChart',
   scatter = 'scatterChart',
}
function ttyjs.chart(data, opts)
   -- args:
   opts = opts or {}
   local width = opts.width or 600
   local height = opts.height or 450
   local background = opts.background or '#fff'
   local win = opts.win or uid()
   local chart = opts.chart or 'line'

   -- chart
   chart = charts[chart]
   if not chart then
      print('unknown chart, must be one of:')
      for c in pairs(charts) do
         io.write(c .. ', ')
      end
      print('')
   end

   -- default data (for examples)
   if not data then
      local values1,values2,rand = {},{}
      if chart == 'scatterChart' then
         N = 200
         rand = torch.FloatTensor(2,N)
         rand:normal()
      else
         N = 30
         rand = torch.FloatTensor(2,N)
         rand:uniform(0,100)
      end
      for j = 1,N do
         values1[j] = {
            y = rand[1][j],
            x = j,
            size = rand[1][j],
         }
         values2[j] = {
            y = rand[2][j],
            x = j,
            size = rand[2][j],
         }
      end
      data = {
         {
            key = 'His Stuff',
            values = values1,
         },
         {
            key = 'My Stuff',
            values = values2,
         }
      }
   end

   -- export data:
   local data_json = json.encode(data)

   -- generate html:
   local html = t.chart % {
      width = width,
      height = height,
      data = data_json,
      id = win,
      background = background,
      chart = chart,
   }
   local f = io.open(ttyjs.static..win..'.html','w')
   f:write(html)
   f:close()

   -- return win handle
   return win
end

return ttyjs

