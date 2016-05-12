
--require("src.interface")
--require("src.playgame")
local widget = require( "widget" )

End={
	effect = true
}
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.actualContentWidth
local _H = display.actualContentHeight

local gameoverlayer = nil
local button_sound = audio.loadSound( "res/button.ogg" )

local function playsound()
	if(End.effect) then
         audio.play(button_sound)
	end
end

local function over_backgroung(gameoverlayer)
	local bg = display.newImageRect(gameoverlayer,"res/bg4.jpg",_W,_H)
	bg.x = centerX
	bg.y = centerY
end

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
    return name,last_score,best
end

local function alter_name(parent)
    local modification = nil
    local name,lscore,best = openfile()
    print("test",name,lscore,best)
    local function modifyEvent(event)
        if (event.phase == "began") then
            playsound()
        end
        if(event.phase == "ended") then
            User:init(name,lscore,best,parent)
        end
        return true
    end

    modification= widget.newButton
    {
    width = 50,
    height = 60,
    defaultFile = "res/xiugai.png",
    overFile = "res/xiugai.png",
    onEvent = modifyEvent
    }
    modification.x =  centerX + 155
    modification.y = centerY - 225
    parent:insert(modification)
end


local function over_label(gameoverlayer,score)
	local overtext = display.newText(gameoverlayer,"game over!",centerX,80,"Marker Felt.ttf",60)

	local score_bg = display.newImage(gameoverlayer,"res/overSoreBg.png",centerX,centerY-105)
    score_bg.xScale = 1
    score_bg.yScale = 1.2

    local score_label = display.newText(gameoverlayer,"Score",centerX,centerY-160,"Marker Felt.ttf",40)
    score_label:setFillColor(0,0,0)

    local best_label = display.newText(gameoverlayer,"Best",centerX,centerY-50,"Marker Felt.ttf",40)
    best_label:setFillColor(0,0,0)

    local score = display.newText(gameoverlayer,tostring(score),centerX,centerY-100,"Marker Felt.ttf",40)
    score:setFillColor(0,0,0)

    local name,lscore,best = openfile()
     local best_letter = display.newText(gameoverlayer,tostring(best),centerX,centerY+10,"Marker Felt.ttf",40)
    best_letter:setFillColor(0,0,0)

    local yourname = display.newText(gameoverlayer,tostring(name),centerX-20,centerY-220,"Marker Felt.ttf",40)
    yourname:setFillColor(0,0,0)

    alter_name(gameoverlayer)

end

local function backhome(gameoverlayer,parent)
    local function backhomeEvent(event)
    	if (event.phase == "began") then
    		playsound()
    	end
    	if(event.phase == "ended") then
    	display.remove(gameoverlayer)
        gameoverlayer = nil
        parent[1].isVisible = true
        end
    end

	local back = widget.newButton
	{
        width = 80,
        height = 80,
        defaultFile = "res/home.png",
        overFile = "res/home.png",
        onEvent = backhomeEvent
    }
    back.x = centerX-120
    back.y = centerY+160
    gameoverlayer:insert(back)
end

local function restart(gameoverlayer,parent)
	local function restartEvent(event)
		 if (event.phase == "began") then
    		playsound()
    	 end
         if(event.phase == "ended") then
         
         local function restartback(event)
         	   display.remove(gameoverlayer)
               gameoverlayer = nil
               Game:init(parent)
         end
         timer.performWithDelay(100,restartback,1)
         end
	end
	local restart = widget.newButton
    {
    width = 80,
    height = 80,
    defaultFile = "res/restart.png",
    overFile = "res/restart.png",
    onEvent = restartEvent
    }
    restart.x = centerX+120
    restart.y = centerY+160
    gameoverlayer:insert(restart)
end


local function rank(gameoverlayer)
	local rank = nil
	local function rankEvent(event)
		if (event.phase == "began") then
    		playsound()
    	end
    	if (event.phase == "ended") then
    	rank:setEnabled(false)
    	Rank:init(gameoverlayer,rank)
        end
		return true
	end
	rank = widget.newButton
    {
    width = 80,
    height = 80,
    defaultFile = "res/rank.png",
    overFile = "res/rank.png",
    onEvent = rankEvent
    }
    rank.x = centerX
    rank.y = centerY+160
    gameoverlayer:insert(rank)
end

function End:init(playgamelayer,parent,score)

    gameoverlayer = display.newGroup()
    parent:insert(gameoverlayer)

    over_backgroung(gameoverlayer)
    over_label(gameoverlayer,score)
    restart(gameoverlayer,parent)
    backhome(gameoverlayer,parent)
    rank(gameoverlayer)
end