--
-- A convenience script, that kills a server
--

-- require gfx client
gfx = require 'gfx.js'

-- env port?
port = os.getenv('PORT')

-- initialize context / server
gfx.killserver(port)

-- exit
os.exit()
