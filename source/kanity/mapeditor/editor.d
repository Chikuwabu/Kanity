module kanity.mapeditor.editor;

import kanity.core;
import kanity.render;
import kanity.character;
import kanity.bg;
import kanity.sprite;
import kanity.event;
import kanity.lua;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;
import core.thread;

class Editor : Engine
{
    public this(string s)
    {
        super(s);
    }
    public override int run()
    {
        return super.run();
    }
    protected override LowLayer createLowLayer(Renderer renderer, Event event)
    {
        return new EditorLowLayer(renderer, event);
    }
}
class EditorLowLayer : LowLayer
{
    this(Renderer renderer, Event event)
    {
        super(renderer, event);
    }

    int width, height;
    int bgwidth, bgheight;
    BG chipList;
    BG map;
    Sprite chipCursor;
    Sprite mapCursor;
    override void init()
    {
        super.init();
        renderer.clear();
        width = cast(int)(renderer.windowWidth / renderer.renderScale);
        height = cast(int)(renderer.windowHeight / renderer.renderScale);
        bgheight = height/ 16;
        bgwidth = width / 16;
        auto chara = new Character(IMG_Load("BGTest2.png"), 16, 16, CHARACTER_SCANAXIS.X);
        int[] m = new int[chara.characters.length + bgwidth];
        auto bg = new BG(chara, m);
        bg.sizeWidth = bgwidth;
        bg.sizeHeight = chara.characters.length / bgwidth;
        bg.width = width;
        bg.height = 16 * 3;
        int chip;
        for (int y = 0;; y++)
        {
            if (chip >= chara.characters.length) break;
            for (int x = 0; x < bgwidth; x++)
            {
                if (chip >= chara.characters.length) break;
                bg.set(x, y, chip++);
            }
        }
        renderer.addObject(bg);
        chipList = bg;
        int mapWidth = 256, mapHeight = 256;
        int[] mapdata = new int[mapWidth *  mapHeight];

        map = new BG(chara, mapdata);
        map.posY = -16 * 3;
        renderer.addObject(map);
        auto cursor = new Character(IMG_Load("SPTest.png"), 20, 16, CHARACTER_SCANAXIS.X);
        chipCursor = new Sprite(cursor, 0, 0, 0);
        chipCursor.homeX = 2;
        renderer.addObject(chipCursor);
        mapCursor = new Sprite(cursor, 0, 0, 1);
        mapCursor.homeX = 2;
        mapCursor.homeY = -16 * 3;
        renderer.addObject(mapCursor);
    }

    override void run()
    {
        super.run();
    }
}
