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
  sleep(1000);
  local spimg = loadImg("SPTest.png")
  log("load img:",spimg)
  local tori = newCharacter(spimg)
  flush()
  tori:setCutRect(20, 16)
  tori:setCutAxis(CHARACTER_SCANAXIS.X)
  tori:cut()
  local sp = newSprite(tori)
  log("Sprite's ID:", sp)
  --deleteCharacter(toriniku)

  unloadImg(spimg)
  log("Unload img:", spimg)
  return 1
end
