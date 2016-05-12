local widget = require( "widget" )

local json = require "json"

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.actualContentWidth
local _H = display.actualContentHeight

local horizontal = 240
local stoodx = 40
local vertical = 100
local pCount = 1 ------平台计数--------
local playgamelayer = nil

----------funish-------------
local touch_key = true
local end_stick = false
local touch_start = false
local bg_move_start = nil
local alive = nil
--------------------------person--------------
local person1 = nil
local person2 = nil
local person3 = nil
--------------------------stick---------------
local stick_length = nil
local stick_group = nil
local stick_count = nil
local obj_stick = nil
local stick = {}
--------------------------platform------------
local platform0 = nil
local pf0_x = 50
local pf0_w = 100
local platform={}
local px={}
local pw={}
------------------------
local score = nil
local tPrevious = system.getTimer()

local soundTable ={
	stick_longSound = audio.loadSound( "res/stick_long.ogg" ),
	stick_fallSound = audio.loadSound( "res/fall.ogg" ),
    scoreSound = audio.loadSound( "res/score.ogg" ),
    deathSound = audio.loadSound( "res/death.ogg" ),
}
local playstick = nil

Game=
{
	effect = true
}

local function playmusic(params)
	if(Game.effect) then
		if(params == 1) then
            playstick = audio.play(soundTable['stick_longSound'],{loops = -1,})
         elseif(params == 2) then
         	audio.play(soundTable['stick_fallSound'])
         	elseif(params == 3) then
         		audio.play(soundTable['scoreSound'])
             else
                audio.play(soundTable['deathSound'])
             end
	end
end

local function random()
	local px = nil
	local pw = nil
	math.randomseed( os.time() )
	if(pCount<7) then
      px = math.random(200,380)
      pw = math.random(30,160)
	elseif(pCount>=7) then
		pw = math.random(30,120)
		px = math.random(200,380)
		elseif(pCount>=12)then
			pw = math.random(30,80)
			px = math.random(260,400)
			elseif(pCount>=16)then
				pw = math.random(26,80)
				px = math.random(320,440)
			end
	return px,pw
end


local function draw_platform(playgamelayer,x,width,params)
	local plat = display.newRect(playgamelayer,x,_H-horizontal/2,width,horizontal)
	plat:setFillColor( 0,0,0 )
	return plat
end

local function scene_move()
	local function nextplatform()
		touch_key = true
		pCount = pCount + 1
		person3.isVisible = false
        person1.isVisible = true
	end

	local function rm_platform()
		if (platform0~=nil) then 
		   display.remove(platform0)
		   platform0 = nil
		else
			display.remove(platform[pCount-1])
			platform[pCount-1] = nil
		end
	end
	transition.to(person3,{time = 1000,x = 70,transition=easing.outQuad})
	transition.to(platform[pCount+1],{time = 1000,x = px[pCount+1],transition=easing.outQuad})
	transition.to(platform[pCount],{time = 1000,x = vertical-pw[pCount]/2,transition=easing.outQuad,onComplete = nextplatform})
	if(platform0 == nil) then
	   transition.to(platform[pCount-1],{time = 500,x = -pw[pCount-1],onComplete = rm_platform})
    else
    	transition.to(platform0,{time = 500,x = -200,onComplete = rm_platform})
    end
end

local function new_platform()
	  local newpx = nil
	  local newpw = nil
	  newpx,newpw = random()
      px[pCount+1] = newpx
      pw[pCount+1] = newpw
      platform[pCount+1] = draw_platform(playgamelayer,newpx+px[pCount]+pw[pCount]/2-vertical ,newpw)
      
end


local function draw_person(playgamelayer,index,x,y)
    return Person:draw_person(playgamelayer,index,x,y)
end

local function update_score()
    score:setLabel(tostring(pCount))
end

local function remove_stick()
	 display.remove(obj_stick)
     obj_stick = nil
     display.remove(stick_group)
     stick_group = nil
     if (stick[stick_count] ~= nil) then
     	display.remove(stick[stick_count])
     	stick[stick_count] = nil
     end
     stick ={}
     stick_count = nil
     stick_length = nil
end

local function remove_data()
	pCount = 1
	display.remove(playgamelayer)
	playgamelayer = nil
	display.remove(score)
	score = nil
    display.remove(person1)
    person1 = nil
    display.remove(person2)
    person2 = nil
    display.remove(person3)
    person3 = nil
    display.remove(platform0)
    platform0 = nil
    platform={}
    px = {}
    pw = {}

    touch_key = true
    end_stick = false
    touch_start = false
end

local function mynetwork(hostname,score,best)
     
    local function update_s(hostname,score,best)
    	local path = system.pathForFile( "data.txt", system.DocumentsDirectory )
    	local fh = nil
       	fh = io.open(path,"w+")
	    if fh then
           if score>=tonumber(best) then 
              fh:write(tostring(hostname).."\n")
       	      fh:write(tostring(score).."\n")
       	      fh:write(tostring(score))
       	   else
              fh:write(tostring(hostname).."\n")
       	      fh:write(tostring(score).."\n")
       	      fh:write(tostring(best))
           end
        end
	    if fh ~= nil then
	       io.close( fh )
        end

    end
    
    ---
    if(tonumber(best)>score) then
        score = tonumber(best)
    end
    ----

	local params = "name="..tostring(hostname).."&score="..tostring(score)

	local function networkListener( event )
        if ( event.isError ) then
          print( "Network error!" )
        else
            local data = json.decode(event.response)
            if data['mesg'] == "ok" then
            	update_s(data['name'],score,best)
            else
                update_s(data['name'],score,best)
            	print("get name fail!")
            end
        end
    end
    local url =  "http://119.29.4.130/game/insert.php?"..params
	network.request( url, "GET", networkListener )
end

local function save_score(score)
    local path = system.pathForFile( "data.txt", system.DocumentsDirectory )
	local hostname = nil
	local last_score = 0
	local best = nil
    
    local fh2 = nil
	local fh = io.open( path, "r" )
	if fh then
       hostname = fh:read( "*l" )
       last_score = fh:read( "*l" )
       best = fh:read( "*l" )

	else
		fh2 = io.open( path, "w" )
		fh2:write("hostname".."\n")
		fh2:write(tostring(score).."\n")
		fh2:write(tostring(score))
		best = 0
	    hostname = "hostname"
	end
    if(fh ~= nil) then
        io.close( fh )
    end
    
    if(fh2 ~= nil) then
        io.close(fh2)
    end
    fh = io.open(path,"w+")
    if(best==nil) then
        print("best ==",best)
       best = 0 
    end
    if(fh)then
    	if score>tonumber(best) then 
              fh:write(tostring(hostname).."\n")
       	      fh:write(tostring(score).."\n")
       	      fh:write(tostring(score))
       	   else
              fh:write(tostring(hostname).."\n")
       	      fh:write(tostring(score).."\n")
       	      fh:write(tostring(best))
           end
    end
    if (fh~=nil) then
    	io.close( fh )
    end
    mynetwork(hostname,score,tonumber(best))

end

local function person_move()
     bg_move_start = true -------屏幕开始移动---
     local move_time = nil
     if vertical+stick_length > _W then
          move_time = 1800
      else
      	  move_time = (vertical+stick_length)/_W*1800
      end

     person2.isVisible = false
     if(person3.isPlaying == false)then
    	person3:play()
    end
     person3.isVisible =  true

     local function move_completeListener(obj)
     	  playmusic(3) ------------------------------------------3------------------------------
     	  person3:pause()
     	  bg_move_start = false
     	  update_score()
     	  remove_stick()
     	  new_platform()
     	  scene_move()
     end
     local function gameover()
     	----------gameover------
     	playmusic(4) -------------------------------------------4------------------------------
     	print("gameover")
     	save_score(pCount-1)
     	bg_move_start = false
     	End:init(playgamelayer,playgamelayer.parent,pCount-1)
     	remove_data()   
     end
     local function move_complete()
     transition.to(person3,{ time = 500,y =_H-50,rotation=360,transition=easing.linear,onComplete = gameover})
     end
     if(alive) then
         transition.to(person3,{ time = move_time,x = px[pCount] + pw[pCount]/2-40,onComplete = move_completeListener} )
     elseif(vertical+stick_length-2<px[pCount] - pw[pCount]/2 or vertical+stick_length-2>px[pCount] + pw[pCount]/2) then
     	local tem = nil
     	tem = vertical+stick_length
     	 if(vertical+stick_length>_W) then
              tem = _W
     	 end

         transition.to(person3,{ time = move_time,x = tem,onComplete = move_complete})
     else
         transition.to(person3,{ time = move_time,x = px[pCount] + pw[pCount]/2,onComplete = move_complete})
     end     
end


local function stick_transition()
	local function trans_completeListener(obj)
		 playmusic(2)-----------------------------------2------
		 if (vertical+stick_length-2>=px[pCount] - pw[pCount]/2 and vertical+stick_length-2<=px[pCount] + pw[pCount]/2 ) then
             alive = true
             person_move()
         else
            alive = false
         	person_move()
         end
	end
    --stick[stick_count].anchorY=0
	--transition.to(stick[stick_count], { time=300, rotation = 90,transition=easing.linear,onComplete=trans_completeListener } )
    transition.to(obj_stick, { time=300, rotation = 90,transition=easing.linear,onComplete=trans_completeListener } )
end

local function draw_stick(playgamelayer,count)
	stick_group = display.newGroup()
	playgamelayer:insert(stick_group)
	stick_count = count

    stick[count] = display.newLine(pf0_w-2,_H-horizontal , pf0_w-2,_H-horizontal-count*10)
    stick_length = count*10
    
    stick[count]:setStrokeColor( 0, 0, 0, 1 )
    stick[count].strokeWidth = 4
    stick_group:insert(stick[count])
    if(count>1) then
    display.remove(stick[count-1])
    stick[count-1] = nil
    end
    return stick[count]
end

local function stick_timer(playgamelayer)

	----------------------------------------------------
	playmusic(1)

    person1.isVisible = false
	person2.isVisible = true
	local function callback(event)
		if(end_stick) then
            timer.cancel( event.source)
            audio.stop(playstick) ---------------------------------stop------------
            stick_transition()
	    else
            obj_stick = draw_stick(playgamelayer,event.count)
	    end
	end
    timer.performWithDelay(0.5,callback,0)
end

local function bare_bg(playgamelayer)

	local function myTouchListener( event )

		if(touch_key) then
			
		     if ( event.phase == "began" ) then
		     	 display.getCurrentStage():setFocus( event.target )
		     	 touch_start = true
                 end_stick = false
                 stick_timer(playgamelayer)
		     elseif(event.phase == "ended" or event.phase == "cancelled") then
		         display.getCurrentStage():setFocus( nil )
		         if(touch_start) then  -----------防止直接进入触摸--------
		             end_stick = true
		             touch_key = false
		             touch_start = false
		         end
		     end
		end
        return true  --prevents touch propagation to underlying objects
    end

	local bare_bg = display.newImageRect(playgamelayer,"res/bare_bg.jpg",_W,_H)
	bare_bg:addEventListener( "touch", myTouchListener )

	bare_bg.x = centerX
	bare_bg.y = centerY
end


local function arrangement(playgamelayer)

	platform0 = draw_platform(playgamelayer,pf0_x,pf0_w)
	px[pCount],pw[pCount] = random()
    platform[pCount] = draw_platform(playgamelayer,px[pCount],pw[pCount])

    person1 = draw_person(playgamelayer,1,pf0_w-30,_H-horizontal-30)
    person2 = draw_person(playgamelayer,2,pf0_w-30,_H-horizontal-30)
    person2.isVisible = false
    person3 = draw_person(playgamelayer,3,pf0_w-30,_H-horizontal-30)
    person3.isVisible = false
end

local function lablescore(playgamelayer)
	--local lable = display.newText(playgamelayer,"分数",centerX,centerY - 200,native.systemFont,30)
	--lable:setFillColor( 1, 0, 0 )
        local blank = display.newImage(playgamelayer,"res/scoreBg.png",centerX,65)
        blank.xScale = 0.6
        blank.yScale = 0.6

	    score = widget.newButton
        {
        left = centerX-5,
        top = 50,
        id = "score1",
        label = "0",
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
        font = "Marker Felt.ttf",
        fontSize = 30,
        isEnabled = false,
        textOnly = true,
        }
        playgamelayer:insert(score)
end

local bg1,bg2,moon
local function ar_move_bg(playgamelayer)
	bg1 = display.newImageRect(playgamelayer,"res/bg3.jpg",_W,_H)
	bg1.x = centerX
	bg1.y = centerY
	bg2 = display.newImageRect(playgamelayer,"res/bg3.jpg",_W,_H)
	bg2.x = centerX+_W
	bg2.y = centerY

	moon = display.newImage(playgamelayer,"res/moon.png")
	moon.xScale = 0.1
	moon.yScale = 0.1
	moon.x = _W-0.3*moon.contentWidth
	moon.y = _H*0.3

end

local function bg_move(event)
	local tDelta = event.time - tPrevious
	tPrevious = event.time
	--print(tDelta)
	local xOffset = ( 0.05 * tDelta )
    if(bg_move_start) then
    	bg1.x = bg1.x - xOffset
    	bg2.x = bg2.x - xOffset
        moon.x  = moon.x - 0.1*xOffset
    	if(bg1.x+_W/2<0)then
    		bg1:translate(2*_W,0)
    	end
    	if(bg2.x+_W/2<0)then
    		bg2:translate(2*_W,0)
    	end
    end
end

local function show_game(playgamelayer)
	bare_bg(playgamelayer)
	--------背景------
    ar_move_bg(playgamelayer)
    arrangement(playgamelayer)

	lablescore(playgamelayer)
	
end


function Game:init(baselayer)
    if(playgamelayer == nil) then
    playgamelayer = display.newGroup()
    baselayer:insert(playgamelayer)
    end
    show_game(playgamelayer)
end

Runtime:addEventListener( "enterFrame", bg_move )