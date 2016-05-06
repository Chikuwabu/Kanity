--function yopi()
    --print("left")
	--if testsp:isXAnimationStarted() then
		--return
    --end
	--testsp:move(10, 10, 16)
--end
--setLeftButtonEvent(yopi)

function init()
  log("ゆうアシ五段活用")
  log("Yuuashi is hage.")
  log("Yuuashi must be hage.")
  log("Yuuashi can be hage.")
  log("Yuuashi may be hage.")
  log("Yuuashi might be hage.")
  --sleep(1000);
  local spimg = loadImg("SPTest.png")
  log("load img:",spimg)
  local tori = newCharacter(spimg)
  tori:setCutRect(20, 16)
  tori:setCutAxis(CHARACTER_SCANAXIS.Y)
  tori:cut()
  local sp = newSprite(tori)
  sp:setCharacterNum(1)
  sp:move(50, 50);
  sp:setHome(10, 8)
  sp:setScale(4.0)
  sp:setAngleDeg(60)
  sp:show()
  --deleteCharacter(toriniku)

  unloadImg(spimg)
  log("Unload img:", spimg)
  return 1
end
