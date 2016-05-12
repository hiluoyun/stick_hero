local widget = require( "widget" )


local button_effect = audio.loadSound( "res/button.ogg" )

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.actualContentWidth
local _H = display.actualContentHeight

local helplayer = nil
local helpkey = true

Inter={
    effect = true
}

local function open_close_sound()
	if(Inter.effect) then
		Inter.effect = false
		Game.effect = false
		End.effect = false
    User.effect = false
	else
		Inter.effect = true
		Game.effect = true
		End.effect = true
    User.effect =true
	end
end

local function playeffect()
	  if(Inter.effect) then
      audio.play(button_effect)
      end
end

local function background(displaylayer)
      local bg = display.newImageRect(displaylayer,"res/bgg2.png",_W,_H)
      bg.x = centerX
      bg.y = centerY
      --local name = display.newImage(displaylayer,"res/name.png",centerX,centerY-170)

end

local function start_game(displaylayer)
	  -- Function to handle button events
      local function handleButtonEvent( event )
      	  if(event.phase == "began") then
      	  	playeffect()
      	  end
          if ( "ended" == event.phase ) then
           displaylayer.isVisible = false
           
           local function gameback(event)
           	  Game:init(displaylayer.parent)
           end
           timer.performWithDelay(60,gameback,1)
          end
          return true
      end

	  local start_button = widget.newButton
      {
        width = 160,
        height = 160,
        defaultFile = "res/start_normal.png",
        overFile = "res/start_select.png",
        --label = "button",
        onEvent = handleButtonEvent
      }
      displaylayer:insert(start_button)

     start_button.x = centerX
     start_button.y = centerY-80

end

local function platform(displaylayer)
	local myRectangle = display.newRect(displaylayer,centerX, _H-130, 160, 260 )
    myRectangle:setFillColor( 0,0,0 )
end

local function person(displaylayer)
	local person_option={
        width =50.2,
        height = 62,
        numFrames = 9
    }
    local  person_sheet= graphics.newImageSheet( "res/yao.png", person_option )

    local person_sequences = 
    {
        name = "fastRun",
        start = 1,
        count = 9,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    }
    local game_person = display.newSprite(person_sheet,person_sequences)
    displaylayer:insert(game_person)
    game_person.x = centerX
    game_person.y = _H - 260 - game_person.contentHeight/2
    game_person:play()

end

local function rank(displaylayer)
	local rank_button = nil
     local function rankevent( event )
     	  if(event.phase == "began") then
      	  	playeffect()
      	  end
          if ( "ended" == event.phase ) then
              rank_button:setEnabled(false) 
              Rank:init(displaylayer,rank_button)
          end
      end

	  rank_button = widget.newButton
      {
        width = 80,
        height = 80,
        defaultFile = "res/rank.png",
        overFile = "res/rank.png",
        onEvent = rankevent
      }
      displaylayer:insert(rank_button)

     rank_button.x = _W - rank_button.contentWidth
     rank_button.y = _H - 260 + rank_button.contentHeight/2
end

local function control_music(displaylayer)

	 local function musicEvent( event )
	 	  if(event.phase == "began") then
	 	  	if(not event.target.isOn) then
      	  	    audio.play(button_effect)  
      	  	end
      	  	open_close_sound()
      	  end
      end
    
    local options = {
    width = 130,
    height = 129,
    numFrames = 2,
    }
    local checkboxSheet = graphics.newImageSheet( "res/button_sheet.png", options )

    local sound_off = widget.newSwitch
    {
        --left = 40,
        --top =  700,
        style = "checkbox",
        id = "Checkbox",
        width = 80,
        height = 80,
        onEvent = musicEvent,
        sheet = checkboxSheet,
        frameOff = 1,
        frameOn = 2
    }
    sound_off.x = sound_off.contentWidth
    sound_off.y = _H - sound_off.contentWidth*1.2
    displaylayer:insert(sound_off)
end

local function draw_help(displaylayer)
	helplayer = display.newGroup()
	displaylayer:insert(helplayer)
	local function touchListener(event)
		if(event.phase == "ended") then
		helpkey = true
		display.remove(helplayer)
		helplayer = nil
	    end
		return true
	end
	local help_bg = display.newImage(helplayer,"res/overSoreBg.png",centerX,centerY-60)
    help_bg.xScale = 0.6
    help_bg.yScale = 0.8
    help_bg:addEventListener( "touch", touchListener);

    local composer = display.newText(helplayer,"制作者",centerX,centerY-130,"Marker Felt.ttf",40)
    composer:setFillColor(0,0,0)
    local name1 = display.newText(helplayer,"罗辉",centerX,centerY-70,"Marker Felt.ttf",30)
    name1:setFillColor(0,0,0)
    local name2 = display.newText(helplayer,"杨启华",centerX,centerY-20,"Marker Felt.ttf",30)
    name2:setFillColor(0,0,0)
    --local name3 = display.newText(helplayer,"Chenyi",centerX,centerY+20,"Marker Felt.ttf",30)
    --name3:setFillColor(0,0,0)
end

local function help(displaylayer)
	 local function helpevent( event )
	 	  if(event.phase == "began") then
      	  	playeffect()
      	  end
      	  if(helpkey) then
              if ( "ended" == event.phase ) then
                 helpkey = false
                 draw_help(displaylayer)
              end
          end
      end

	  local help_button = widget.newButton
      {
        width = 80,
        height = 80,
        defaultFile = "res/help.png",
        overFile = "res/help.png",
        onEvent = helpevent
      }
      displaylayer:insert(help_button)

     help_button.x = help_button.contentWidth
     help_button.y = _H - 260 +help_button.contentWidth/2
end

local function exit(displaylayer)
	local exit_button = nil
	local function exitEvent( event )
            if (event.phase == "began") then
            	display.getCurrentStage():setFocus(event.target)
            	--exit_button.alpha=0.5
            
            elseif ( "ended" == event.phase ) then
                 display.getCurrentStage():setFocus(nil)
                 native.requestExit()
            end
          return true
      end

	  exit_button = widget.newButton
      {
        width = 120,
        height = 50,
        defaultFile = "res/exit.png",
        overFile = "res/exit.png",
        onEvent = exitEvent
      }
      displaylayer:insert(exit_button)

     exit_button.x = _W - exit_button.contentWidth*0.7
     exit_button.y = _H -exit_button.contentHeight*1.8
end

local function display_panel(displaylayer)
	 background(displaylayer) --background
	 start_game(displaylayer) --start button
	 platform(displaylayer)   --black rect
	 person(displaylayer)     --game person
	 rank(displaylayer)       --score rank 
	 control_music(displaylayer)
	 help(displaylayer)
	 exit(displaylayer)
end

-----------------------------------------------------------begin here-------------------------------------------------
function Inter:init(baselayer)
    display.setStatusBar( display.HiddenStatusBar ) --隐藏状态栏--实现全屏

	local displaylayer = display.newGroup()
	baselayer:insert(displaylayer)
    display_panel(displaylayer)
end



