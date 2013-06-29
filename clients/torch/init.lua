--
-- A client to tty.js
--

require 'image'
require('pl')
local Template = require('pl.text').Template
text.format_operator()

local ttyjs = {}

ttyjs.static = os.getenv('HOME') .. '/.tty.js/static/data/'

os.execute('rm -rf "' .. ttyjs.static .. '"')
os.execute('mkdir -p "' .. ttyjs.static .. '"')

ttyjs.templates = {
   image = [[
      <a href="/data/${filename}" target="_blank"" style="text-decoration:none;">
         <img src="/data/${filename}" width=${width}/>
      </a>
   ]],
   window = [[
      <div style="width:${width}px; height:${height}px; overflow-y:scroll; background:#444;">
         ${content}
      </div>
   ]],
}

local t = ttyjs.templates

local function uid()
   return (os.time() .. math.random()):gsub('%.','')
end

function ttyjs.image(img, zoom)
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
   local html = t.image % {width=width, filename=filename}
   local f = io.open(ttyjs.static..uid..'.html','w')
   f:write(html)
   f:close()
end

function ttyjs.images(images, zoom, nperrow)
   -- templates
   local templates = {}
   local nperrow = nperrow or 4

   -- do all images:
   local maxwidth,maxheight = 0,0
   for _,img in ipairs(images) do
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
      local html = t.image % {width=width, filename=filename}
      table.insert(templates, html)
   end

   -- generate container:
   local width = math.min(1200, (maxwidth+4)*nperrow)
   local height = math.min(800, math.ceil(#images / nperrow) * (maxheight+4))
   local html = t.window % {width=width, height=height, content=table.concat(templates, '\n')}
   local f = io.open(ttyjs.static..uid()..'.html','w')
   f:write(html)
   f:close()
end

return ttyjs

