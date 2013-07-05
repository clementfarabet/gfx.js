--
-- A convenience script, that automatically stars up a server, and
-- opens up a browser window
--

-- require gfx client
gfx = require 'gfx.js'

-- initialize context / server
local status = io.popen('curl -s http://localhost:8000'):read('*all'):gsub('%s*','')
if status == '' then
   -- start up server:
   os.execute('node "' .. os.getenv('HOME') .. '/.gfx.js/server.js" > "' .. os.getenv('HOME') .. '/.gfx.js/server.log" &')
   print('[gfx.js] server started on port 8000, graphics will be rendered into http://localhost:8000')
else
   print('[gfx.js] server already running on port 8000, graphics will be rendered into http://localhost:8000')
end

-- open up browser:
if jit.os == 'OSX' then
   sys.sleep(0.1)
   os.execute('open http://localhost:8000/')
end
