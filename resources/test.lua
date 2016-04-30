--local toriniku = newCharacter(IMG_Load("SPTest.png"), 20, 16, CHARACTER_SCANAXIS.X)
--local testsp = Sprite(toriniku, 0, 0, 0);
--local renderer = control:renderer()
--renderer:clear()
--renderer:addObject(spriteToDrawableObject(testsp))
--function yopi()
    --print("left")
	--if testsp:isXAnimationStarted() then
		--return
    --end
	--testsp:move(10, 10, 16)
--end
--setLeftButtonEvent(yopi)
--ゆうアシ五段活用
log("Yuuashi is hage.")
log("Yuuashi must be hage.")
log("Yuuashi can be hage.")
log("Yuuashi may be hage.")
log("Yuuashi might be hage.")
sleep(1000);
local spimg = loadImg("SPTest.png")
local toriniku = newCharacter(spimg)
setCutRect(toriniku, 20, 16)
setScanAxis(toriniku, CHARACTER_SCANAXIS.X)
cut(toriniku)
sp = newSprite(toriniku)

log("hage");
unloadImg(spimg)
--print('test')
