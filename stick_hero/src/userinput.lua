local widget = require( "widget" )
local json = require "json"
User={
    effect = true
}

local UserLayer =nil
local usernameField = nil

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.actualContentWidth
local _H = display.actualContentHeight

local button_sound = audio.loadSound( "res/button.ogg" )

local function playsound()
    if(User.effect) then
         audio.play(button_sound)
    end
end

local function openfile()
    local path = system.pathForFile( "data.txt", system.DocumentsDirectory )
    local fh = io.open(path,"r")
    local name,last_score,best
    if(fh)then
       name=fh:read( "*l" )
       last_score=fh:read( "*l" )
       best=fh:read( "*l" )
       
    else
        print("readfile error")
    end
    if(fh~=nil) then
         io.close(fh)
    end
    return name,last_score,best
end

local function save_name(newname,lscore,best)
    local path = system.pathForFile( "data.txt", system.DocumentsDirectory )
    local fh = io.open(path,"w")
    --local name,last_score,best = openfile()
    if(fh)then
       fh:write(tostring(newname).."\n")
       fh:write(tostring(lscore).."\n")
       fh:write(tostring(best))
    else
        print("file error!!!")
    end
    if fh ~= nil then
        io.close(fh)
        fh=nil
    end
end

local function rn_network(newname,oldname,lscore,best)
    local parms = "newName="..tostring(newname).."&oldName="..tostring(oldname)

    local function netComplete( event )
       if event.action == "clicked" then
        end
    end

    local function failureComplete( event )
       if event.action == "clicked" then
        end
    end

    local function successComplete( event )
       if event.action == "clicked" then
             local i = event.index
             if i == 1 then
            -- Do nothing; dialog will simply dismiss
             end
        end
    end
   

    local function networkListener( event )
       if ( event.isError ) then
        local errornet = native.showAlert( "Tap", "网络错误！", { "OK"}, netComplete )
        print( "Network error!" )
       else
           local data = json.decode(event.response)
           if(data['mesg'] == "error" or data['mesg'] == "the name exsits!") then
                local failure = native.showAlert( "Tap", "名字已拥有，请用其他名字！", { "OK"}, failureComplete )
            elseif(data['mesg'] == "ok") then
                local sucess = native.showAlert( "Tap", "名字修改成功！", { "OK"}, successComplete )
                print(newname)
                save_name(newname,lscore,best)
            else
                local failure = native.showAlert( "Tap", "名字已拥有，请用其他名字！", { "OK"}, failureComplete )
            end
 
       end
    end
	network.request("http://119.29.4.130/game/updateName.php?"..parms, "GET", networkListener )
end

local function submit_name(oldname,lscore,best)
	print(usernameField.text)
	local newname =  usernameField.text
	local state= nil

    local function onComplete( event )
       if event.action == "clicked" then
             local i = event.index
             if i == 1 then
            -- Do nothing; dialog will simply dismiss
             end
        end
    end

    local function alterComplete( event )
       if event.action == "clicked" then
             local i = event.index
             if i == 1 then
            -- Do nothing; dialog will simply dismiss
             end
        end
    end

	if(string.len(newname)>10) then
		 local alert = native.showAlert( "Tap", "名字太长！请重新输入", { "OK"}, onComplete )
    else
        rn_network(newname,oldname,lscore,best)
	end
   
end

local function Rminput(oldname,parent)
     usernameField = native.newTextField( 280, 400, 220, 40 )
     parent:insert(usernameField)

     usernameField.font = native.newFont( native.systemFontBold, 24 )
     usernameField.text = oldname
     usernameField:setTextColor( 0.4, 0.4, 0.8 )


    local function onUsername( event )
      if ( "began" == event.phase ) then
        -- This is the "keyboard appearing" event.
        -- In some cases you may want to adjust the interface while the keyboard is open.

      elseif ( "submitted" == event.phase or "ended" == event.phase) then
        -- Automatically tab to password field if user clicks "Return" on virtual keyboard.
        native.setKeyboardFocus(nil)
        elseif("editing" == event.phase )then
            if(string.len(event.target.text)>16) then
                event.target.text = string.sub(event.target.text,1,string.len(event.target.text)-1)
            end
      end
    end
     usernameField:addEventListener( "userInput", onUsername )
end

local function drawInput(oldname,parent,lscore,best)
	local mask = display.newImageRect(parent,"res/mask.png",_W,_H)
	mask.x,mask.y = centerX,centerY

	local function RmTouchListener(event)
		if(event.phase == "began" or event.phase == "ended") then
		print("nothing")
		     -----nothing happen ------
	    end
	    return true
	end
	mask:addEventListener( "touch", RmTouchListener )

    local bg = display.newImage(parent,"res/userBg.png",centerX,centerY)
    bg.xScale = 0.8
    bg.yScale = 0.8
    
    local title = display.newText(parent,"修改名字",centerX,centerY-80,"",40)
    title:setFillColor(1,1,1)

    local text = display.newText(parent,"Modify:",centerX-120,centerY,"Marker Felt.ttf",30)
    text:setFillColor(1,1,1)
   

    local function closeEvent(event)
        if "began"==event.phase then
             playsound()
    	elseif(event.phase == "ended") then
            display.remove(UserLayer)
            UserLayer = nil
            usernameField:removeSelf()
            usernameField = nil
        end
        return true
    end

    local button = widget.newButton
    {
    width = 60,
    height = 40,
    defaultFile = "res/small_close.png",
    overFile = "res/small_close2.png",
    onEvent = closeEvent
    }
    button.x = centerX+160
    button.y = centerY-115
    parent:insert(button) 
    
    local function submitEvent(event)
        if("began" == event.phase) then
            playsound()
    	elseif(event.phase == "ended") then
             submit_name(oldname,lscore,best)
        end
        return true
    end

    local submit = widget.newButton
    {
    width = 160,
    height = 60,
    defaultFile = "res/rname.png",
    overFile = "res/rname.png",
    onEvent = submitEvent
    }
    submit.x = centerX
    submit.y = centerY+80
    parent:insert(submit) 
end

function User:init(oldname,lscore,best,parent)
	UserLayer= display.newGroup()
    parent:insert(UserLayer)
	drawInput(oldname,UserLayer,lscore,best)
	Rminput(oldname,parent)
end