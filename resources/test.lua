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
  local bgimg = loadImg("BGTest2.png")
  local font = loadFont("PixelMplus10-Regular.ttf", 10)

  local tori = newCharacter(spimg)
  tori:setCutRect(20, 16)
  tori:setCutAxis(Character_ScanAxis.Y)
  tori:cut()
  local kusa = newCharacter(bgimg)
  kusa:add(0, 0, 0)
  local sp = newSprite(tori)
  sp:setCharacterNum(1)
  sp:move(50, 50);
  sp:setHome(10, 8)
  sp:setScale(2.0)
  sp:setAngleDeg(60)

  local bg = newBG(kusa)
  local map = {}
  for x = 1, 64 do
    map[x]={}
    for y = 1, 64 do
      map[x][y] = 0
    end
  end
  bg:setMapData(map)
  bg:move(-50, -50)
  bg:setAngleDeg(30)
  bg:setPriority(-1)

  local text = newText(font)
  text:setText("こんにちは、世界\nゆうあしは、ハゲ")
  text:show()

  unloadImg(spimg)
  unloadImg(bgimg)
  log("Unload img:", spimg)
  sp:show()
  bg:show()
  return 1
end
