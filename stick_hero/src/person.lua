Person = {
     person={},
     imagepath={
         "res/yao.png","res/shake.png","res/walk.png",
     },
     options = {
        {
           width =50.2,
           height = 62,
           numFrames = 9
        },
        {
           width =49.1,
           height = 62,
           numFrames = 9
        },
        {
           width =50.2,
           height = 64,
           numFrames = 9
        }
     },
     sheet = {},
     sequences = {
        name = "fastRun",
        start = 1,
        count = 9,
        time = 1000,
        loopCount = 0,
        loopDirection = "forward"
     }
	
}


function Person:draw_person(parent,index,x,y)
      self.sheet[index]= graphics.newImageSheet( self.imagepath[index], self.options[index] )
      self.person[index] = display.newSprite(self.sheet[index],self.sequences)
      parent:insert(self.person[index])
      
      self.person[index].x = x
      self.person[index].y = y
      self.person[index]:play()
      return self.person[index]
end