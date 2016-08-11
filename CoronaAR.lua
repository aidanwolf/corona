-- Corona SDK Augmented Reality in less than 100 lines of code
-- Aidan Wolf
-- MIT License

system.setAccelerometerInterval( 100 ) -- 100hz for best effect, higher battery drain

local ar = {degrees = 0,height = 0,startDegrees = 0,startHeight = 0}
-- degrees comes from the compass (for x AR movement)
-- height comes from the accelerometer (for y AR movement)
-- startDegrees is an offset for x AR movement (default is 0)
-- startHeight is an offset for y AR movement (default is 0)

-- AR camera
local background = display.newRect(display.contentWidth*.5,display.contentHeight*.5,display.contentWidth,display.contentHeight)
background.fill = {type = "camera"} -- gives you a fullscreen camera view
background.width = display.contentHeight*(3/4) -- get proper aspect ratio for camera

--1: Augmented Reality tracking
local track_degrees = nil
local track_degrees_last = nil

local track_group = display.newGroup() -- group that moves with device orientation changes

local test = display.newRect(track_group,display.contentWidth*.5,display.contentHeight*.5,64,64)

track = function (event)
  if not track_degrees then
    track_degrees = ar.degrees
    track_degrees_last = ar.degrees
  end

  -- flip tracking for full 360 deg rotation
  if ar.degrees-track_degrees_last >= 180 then
    track_degrees_last = track_degrees_last + 360
  elseif ar.degrees-track_degrees_last <= -180 then
    track_degrees_last = track_degrees_last - 360
  end
  
  track_degrees = track_degrees + (ar.degrees-track_degrees_last)
  track_degrees_last = ar.degrees
  
  local easex = 0
  local easey = ar.height*display.contentHeight

  if ar.startDegrees then
    easex = -(vt.track_degrees-ar.startDegrees)*16-(display.contentWidth*.5)
  end

  if ar.startHeight then
    easey = (ar.height*display.contentHeight)-(ar.startHeight*display.contentHeight)-display.contentHeight*.5
  end

  local track_speed = 3 -- lower value = faster tracking, more jittery

  track_group:translate(((easex-track_group.x)/track_speed),((easey-track_group.y)/track_speed))

end

Runtime:addEventListener("enterFrame",track)

--2: Get ar.degrees
local compass = function( event )
    if _G.device == "Android" or event.geographic == nil then
        ar.degrees = event.magnetic
    else
        ar.degrees = event.geographic
    end
    
     if ar.degrees < 0 then
        ar.degrees = ar.degrees + 360
    elseif ar.degrees >= 360 then
        ar.degrees = ar.degrees - 360
    end

end

Runtime:addEventListener( "heading", compass )

--3: Get ar.height
accelerometer = function ( event )
  ar.height = event.zGravity
end

Runtime:addEventListener( "accelerometer", accelerometer )

--4: insert AR object
local create_AR_object = function (obj)
     local xc,yc = obj:localToContent(0,0 )
     track_group:insert(obj)
    
     obj.x = -track_group.x+(xc-W*.5)
     obj.y = -track_group.y+(yc-H*.5)
end

local myObject = display.newCircle(0,0,64)
create_AR_object(myObject)
