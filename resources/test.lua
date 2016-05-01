--function yopi()
    --print("left")
	--if testsp:isXAnimationStarted() then
		--return
    --end
	--testsp:move(10, 10, 16)
--end
--setLeftButtonEvent(yopi)
log("ゆうアシ五段活用")
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
local sp = newSprite(toriniku)

unloadImg(spimg)
