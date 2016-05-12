local widget = require( "widget" )
local json = require "json"

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.actualContentWidth
local _H = display.actualContentHeight

Rank={}

local function openfile()
	local path = system.pathForFile( "data.txt", system.DocumentsDirectory )
	local fh,reason = io.open(path,"r")
	local name,last_score,best
	if(fh)then
	   name=fh:read( "*l" )
	   last_score=fh:read( "*l" )
	   best=fh:read( "*l" )
	   io.close(fh)
    else
    	print(reason)
    end
    return name
end

local function draw_text(parent,table)
	local hostname = openfile()
	for index,value in pairs(table) do

		local str1 = display.newText(tostring(index),30,index*35-10,"",30)
		local str2 = display.newText(value['name'],160,index*35-10,"",30)
		local str3 = display.newText(value['score'],280,index*35-10,"",30)
      
		parent:insert(str1)
		parent:insert(str2)
		parent:insert(str3)
		if hostname == value['name'] then
           str1:setFillColor(0,1,1)
           str2:setFillColor(0,1,1)
           str3:setFillColor(0,1,1)
		else
		   str1:setFillColor(0,0,0)
		   str2:setFillColor(0,0,0)
		   str3:setFillColor(0,0,0)
	    end
	end
end

local function rank_network(scrollView)

    local function networkListener( event )
       if ( event.isError ) then
        print( "Network error!" )
       else
         local data = json.decode(event.response)
         draw_text(scrollView,data['users'])
       end
    end
    
	network.request("http://119.29.4.130/game/select.php", "GET", networkListener )
end

local function score(ranklayer)

	local function scrollListener( event )
      local phase = event.phase
      if ( phase == "began" ) then print( "Scroll view was touched" )
      elseif ( phase == "moved" ) then print( "Scroll view was moved" )
      elseif ( phase == "ended" ) then print( "Scroll view was released" )
       end
       return true
    end

     local scrollView = widget.newScrollView
    {
      width = 320,
      height = 240,
      hideBackground = false,
      --friction = 0.972,
      horizontalScrollDisabled = true,
      --scrollWidth = 600,
      --scrollHeight = 800,
      listener = scrollListener
   }
   scrollView.x = centerX
   scrollView.y = centerY + 36
   --scrollView.anchorX = 0
   --scrollView.anchorY = 0
   ranklayer:insert(scrollView) 
   rank_network(scrollView)
end 

local function bg_label(ranklayer,rank_button)
	  local function rankEvent(event)
         return true
	  end
	  
      local rank_bg = display.newImageRect(ranklayer,"res/rank_bg.png",_W*0.8,_H/2)
      rank_bg.x = centerX
      rank_bg.y = centerY
      rank_bg:addEventListener( "touch", rankEvent )
      local top = display.newText(ranklayer,"TOP",centerX,centerY-rank_bg.contentHeight*0.37,"Marker Felt.ttf",40)
      local tap = display.newText(ranklayer,"排名        姓名        分数",centerX,centerY-rank_bg.contentHeight*0.26,"Marker Felt.ttf",30)

    local function handleButtonEvent( event )
      if ( "began" == event.phase ) then
      	  display.getCurrentStage():setFocus(event.target)     
	   elseif(event.phase == "ended") then
	      rank_button:setEnabled(true)
	      display.remove(ranklayer)
	  	  ranklayer = nil
          display.getCurrentStage():setFocus(nil)
       end
       return true
    end

    local button = widget.newButton
   { 
    width = 60,
    height = 40,
    defaultFile = "res/small_close.png",
    overFile = "res/small_close2.png",
    onEvent = handleButtonEvent
   }
   button.x = centerX + rank_bg.contentWidth*0.36
   button.y = centerY - rank_bg.contentHeight*0.373
   ranklayer:insert(button)
   
end

function Rank:init(parent,rank_button)
   local ranklayer = display.newGroup()
   parent:insert(ranklayer)
   
   bg_label(ranklayer,rank_button)
   score(ranklayer)
end