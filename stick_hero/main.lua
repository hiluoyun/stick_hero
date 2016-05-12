-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
require("src.person")
require("src.gameover")
require("src.userinput")
require( "src.playgame")
require("src.rank")
require "src.interface"




local baselayer = display.newGroup()

function main( ... )
	Inter:init(baselayer)
end
main()