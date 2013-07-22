--
-- A convenience script, that starts up a server
--

-- require gfx client
gfx = require 'gfx.js'

-- env port?
port = os.getenv('PORT')

-- initialize context / server
gfx.startserver(port)

-- exit
os.exit()
