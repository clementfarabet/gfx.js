--
-- A client to gfx.js
--

require 'image'
require 'pl'
local json = require 'cjson'
local Template = require('pl.text').Template
local gm = require 'graphicsmagick'
text.format_operator()

local js = {}

js.static = os.getenv('HOME') .. '/.gfx.js/static/data/'
js.template = os.getenv('HOME') .. '/.gfx.js/templates/'
js.prefix = '/data/'

js.verbose = true

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
   if js.verbose then
      print('[gfx.js] rendering cell <' .. id .. '>')
   end
end

local function uid()
   return 'dom_' .. (os.time() .. math.random()):gsub('%.','')
end

function js.image(img, opts)
   -- options:
   opts = opts or {}
   local zoom = opts.zoom or 1
   local refresh = opts.refresh or false
   local win = opts.win or uid()
   local legend = opts.legend

   -- img is a table?
   if type(img) == 'table' then
      win = js.images(img, opts)
      return win
   end

   -- rescale image:
   img = torch.FloatTensor(img:size()):copy(img)
   img:add(-img:min()):mul(1/img:max())

   -- img is a collection?
   if img:nDimension() == 4 or (img:nDimension() == 3 and img:size(1) > 3) then
      local images = {}
      for i = 1,img:size(1) do
         images[i] = img[i]
      end
      return js.images(images, opts)
   end

   -- force image into RGB:
   if img:nDimension() == 2 then
      img = img:reshape(1,img:size(1),img:size(2))
   end

   if img:size(1) == 1 then
      img = img:expand(3,img:size(2),img:size(3))
   end

   -- dump image:
   local filename = win .. '.png'
   gm.save(js.static .. filename, img)

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
      id = win,
      legend = legend or '',
      refresh = tostring(refresh),
   }
   local f = io.open(js.static..win..'.html','w')
   f:write(html)
   f:close()
   log(win)

   -- refresh?
   if refresh then
      return function(newimage)
         -- dump image:
         local tmpfile = '/tmp/buffer.jpg'
         gm.save(tmpfile, newimage)
         os.execute('mv "'..tmpfile..'" "'..js.static..filename..'"')
      end
   end

   -- id
   return win
end

function js.images(images, opts)
   -- options:
   opts = opts or {}
   local nperrow = opts.nperrow or math.floor(math.sqrt(#images))
   local zoom = opts.zoom or 1
   local width = opts.width or 1200
   local height = opts.height or 800
   local legends = opts.legends or {}
   local legend = opts.legend
   local win = opts.win or uid()

   -- do all images:
   local templates = {}
   local maxwidth,maxheight = 0,0
   for i,img in ipairs(images) do
      -- rescale image:
      img = torch.FloatTensor(img:size()):copy(img)
      img:add(-img:min()):mul(1/img:max())

      -- dump image:
      local uid = uid()
      local filename = uid .. '.png'
      gm.save(js.static .. filename, img)

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
      local html = t.image % {
         width = width, 
         filename = js.prefix..filename, 
         legend = legends[i] or (i==1 and legend) or (not legend and ('Image #'..i)) or '',
         refresh = false
      }
      table.insert(templates, html)
   end

   -- generate container:
   local width = math.min(width, (maxwidth+4)*math.min(#images,nperrow))
   local height = math.min(height, math.ceil(#images / nperrow) * (maxheight+4))
   local html = t.window % {
      width = width, 
      height = height, 
      id = win,
      content = table.concat(templates, '\n')
   }
   local f = io.open(js.static..win..'.html','w')
   f:write(html)
   f:close()
   log(win)

   -- id
   return win
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
         -- straight data?
         if torch.typename(dataset) or not dataset.values then
            dataset = {
               values = dataset
            }
            data[i] = dataset
         end
         
         -- legend:
         dataset.key = dataset.key or ('Data #'..i)

         -- values:
         local values = dataset.values
         if type(values) == 'table' then
            -- remap values:
            if type(values[1]) == 'number' then
               for i,value in ipairs(values) do
                  local val = {}
                  val.x = i
                  val.y = value
                  values[i] = val
               end
            elseif not values[1].x or not values[1].y then
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
   local xFormat = opts.xFormat or '.02e'
   local yFormat = opts.yFormat or '.02e'

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
      xFormat = xFormat,
      yFormat = yFormat,
   }
   local f = io.open(js.static..win..'.html','w')
   f:write(html)
   f:close()
   log(win)

   -- return win handle
   return win
end

function js.redraw(id)
   -- id: if number then it means redraw last N elements
   -- if string, then it's an actual id
   if type(id) == 'number' then
      -- list last elements, and redraw them:
      local ids = js.list(id)
      for i = #ids,1,-1 do
         js.redraw(ids[i])
      end
   else
      -- ext?
      if not id:find('html$') then
         id = id .. '.html'
      end
      -- touch the resource will force a redraw (or a new draw if window was closed)
      os.execute('touch "'..js.static..id..'"')
   end
end

function js.list(N)
   -- default max
   N = N or 10
   -- list last N elements
   local pipe = io.popen('ls -t "'..js.static..'"dom_*.html')
   local ids = {}
   for i = 1,N do
      local line = pipe:read('*line')
      if line then
         local _,_,id = line:find('(dom_%d*)%.html$')
         table.insert(ids,id)
      else
         break
      end
   end
   return ids
end

function js.startserver(port)
   -- port:
   port = port or 8000

   -- running?
   local status = io.popen('curl -s https://localhost:'..port..'/'):read('*all'):gsub('%s*','')
   if status == '' then
      -- start up server:
      os.execute('node "' .. os.getenv('HOME') .. '/.gfx.js/server.js" --port '..port..' > "' .. os.getenv('HOME') .. '/.gfx.js/server.log" &')
      print('[gfx.js] server started on port '..port..', graphics will be rendered into https://localhost:'..port)
   else
      print('[gfx.js] server already running on port '..port..', graphics will be rendered into https://localhost:'..port)
   end
end

function js.listservers()
   -- find job
   local pipe = io.popen('ps -ef | grep -v grep | grep "server.js --port"')
   local servers = {}
   while true do
      local line = pipe:read('*line')
      if line then
         local splits = stringx.split(line)
         local pid = splits[2]
         local port = splits[#splits]
         table.insert(servers, {
            pid = pid,
            port = port
         })
      else
         break
      end
   end

   -- report:
   if #servers > 0 then
      print('[gfx.js] found ' .. #servers .. ' server(s): ')
      for _,server in ipairs(servers) do
         print('+ server running on port ' .. server.port .. ', with pid = ' .. server.pid)
      end
   else
      print('[gfx.js] no server running')
   end
   return servers
end

function js.killserver(port)
   -- port:
   port = port or 8000

   -- find job
   local line = io.popen('ps -ef | grep -v grep | grep "server.js --port ' .. port .. '"'):read('*line')
   local uid
   if line then
      local splits = stringx.split(line)
      uid = splits[2]
   end

   -- kill job
   if uid then
      local res = io.popen('kill ' .. uid):read('*all')
      print('[gfx.js] server stopped on port ' .. port)
   else
      print('[gfx.js] server not found on port ' .. port)
   end
end

function js.show(port)
   -- port:
   port = port or 8000

   -- browse:
   if jit.os == 'OSX' then
      sys.sleep(0.1)
      os.execute('open https://localhost:'..port)
   elseif jit.os == 'Linux' then
      sys.sleep(0.1)
      os.execute('xdg-open https://localhost:'..port)
   else
      print('[gfx.js] show() is only supported on Mac OS/Linux - other OSes: navigate to https://localhost:PORT by hand')
   end
end

gfx = js

return js
