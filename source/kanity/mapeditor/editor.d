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
        SDL_Rect rect;
        rect.w = width;
        rect.h = 16 * 3;
        //bg.drawRect = rect;
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
    }

    override void run()
    {
        super.run();
    }
}
