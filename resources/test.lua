
local toriniku = newCharacter(IMG_Load("SPTest.png"), 20, 16, CHARACTER_SCANAXIS.X)
local testsp = Sprite(toriniku, 0, 0, 0);
local renderer = control:renderer()
--renderer:clear()
renderer:addObject(spriteToDrawableObject(testsp))
function yopi()
    print("left")
	if testsp:isXAnimationStarted() then
		return
    end
	testsp:move(10, 10, 16)
end
setLeftButtonEvent(yopi)
