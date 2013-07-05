--
-- A client to gfx.js
--

require 'image'
require 'pl'
local json = require 'cjson'
local Template = require('pl.text').Template
text.format_operator()

js = {}

js.static = os.getenv('HOME') .. '/.gfx.js/static/data/'
js.template = os.getenv('HOME') .. '/.gfx.js/templates/'
js.prefix = '/data/'

os.execute('mkdir -p "' .. js.static .. '"')

js.templates = {}

local t = js.templates

for file in paths.files(js.template) do
   if file:find('html$') then
      local f = io.open(paths.concat(js.template,file))
      local template = f:read('*all')
      t[file:gsub('%.html$','')] = template
   end
end

local function log(id)
   print('[gfx.js] rendering cell <' .. id .. '>')
end

local function uid()
   return 'dom_' .. (os.time() .. math.random()):gsub('%.','')
end

function js.image(img, opts)
   -- options:
   opts = opts or {}
   local zoom = opts.zoom or 1
   local refresh = opts.refresh or false

   -- img is a table?
   if type(img) == 'table' then
      js.images(img, opts)
      return
   end

   -- rescale image:
   img = img:clone():add(-img:min()):mul(1/img:max())

   -- img is a collection?
   if img:nDimension() == 4 or (img:nDimension() == 3 and img:size(1) > 3) then
      local images = {}
      for i = 1,img:size(1) do
         images[i] = img[i]
      end
      js.images(images, opts)
      return
   end

   -- dump image:
   local uid = uid()
   local filename = uid .. '.jpg'
   image.save(js.static .. filename, img)

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
   local html = t.image % {
      width = width, 
      filename = js.prefix .. filename,
      id = uid,
      refresh = tostring(refresh),
   }
   local f = io.open(js.static..uid..'.html','w')
   f:write(html)
   f:close()
   log(uid)

   -- refresh?
   if refresh then
      return function(newimage)
         local tmpfile = '/tmp/buffer.jpg'
         image.save(tmpfile, newimage)
         os.execute('mv "'..tmpfile..'" "'..js.static..filename..'"')
      end
   end

   -- id
   return uid
end

function js.images(images, opts)
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
      image.save(js.static..filename, img)

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
      local html = t.image % {width=width, filename=js.prefix..filename}
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
   local uid = uid()
   local f = io.open(js.static..uid..'.html','w')
   f:write(html)
   f:close()
   log(uid)

   -- id
   return uid
end

-- format datasets:
local function format(data, chart)
   -- format datasets:
   if data then
      -- data is a straight tensor?
      if torch.typename(data) then
         data = {
            values = data
         }
      end
      
      -- one dataset only?
      if #data == 0 then
         data = {data}
      end

      -- format values:
      for i,dataset in ipairs(data) do
         -- legend:
         dataset.key = dataset.key or ('Data #'..i)

         -- values:
         local values = dataset.values
         if type(values) == 'table' then
            -- remap values:
            if not values[1].x or not values[1].y then
               for i,value in ipairs(values) do
                  value.x = value[1]
                  value.y = value[2]
                  value.size = value[3]
               end
            end

         elseif torch.typename(values) then
            -- remap values:
            if values:nDimension() == 1 then
               local vals = {}
               for i = 1,values:size(1) do
                  vals[i] = {
                     x = i-1,
                     y = values[i],
                  }
               end
               dataset.values = vals

            elseif values:nDimension() == 2 and values:size(2) == 2 then
               local vals = {}
               for i = 1,values:size(1) do
                  vals[i] = {
                     x = values[i][1],
                     y = values[i][2]
                  }
               end
               dataset.values = vals

            elseif values:nDimension() == 2 and values:size(2) == 3 then
               local vals = {}
               for i = 1,values:size(1) do
                  vals[i] = {
                     x = values[i][1],
                     y = values[i][2],
                     size = values[i][3]
                  }
               end
               dataset.values = vals

            else
               error('dataset.values could not be parsed')
            end
         else
            error('dataset.values must be a tensor or a table')
         end
      end

   else
      -- Example dataset:
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

   -- return formatted data:
   return data
end

-- chart?
local charts = {
   line = 'lineChart',
   bar = 'discreteBarChart',
   stacked = 'stackedAreaChart',
   multibar = 'multiBarChart',
   scatter = 'scatterChart',
}
function js.chart(data, opts)
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

   -- format data
   data = format(data,chart)

   -- export data:
   local data_json = json.encode(data)

   -- button style:
   local button = table.concat({
      'background:rgba(0,0,0,0.7);',
      'color:#ccc;',
      'margin-left:2px;',
      'margin-right:2px;', 
      'padding:3px;', 
      'font-family:helvetica;',
      'font-size:10px;',
      'cursor:pointer;'
   },'')

   -- generate html:
   local html = t.chart % {
      width = width,
      height = height,
      data = data_json,
      id = win,
      chart = chart,
      background = background,
      button = button,
   }
   local f = io.open(js.static..win..'.html','w')
   f:write(html)
   f:close()
   log(win)

   -- return win handle
   return win
end

function js.redraw(id)
   -- new uid
   local uid = uid()

   -- reload
   local f = io.open(js.static..id..'.html','r')
   local s = f:read('*all')
   s = s:gsub(id,uid)
   f:close()

   -- rewrite
   local f = io.open(js.static..uid..'.html','w')
   f:write(s)
   f:close()
   log(uid)

   -- return new uid
   return uid
end

return js
