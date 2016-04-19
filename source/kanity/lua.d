module kanity.lua;
import luad.all;
import kanity.core;
import kanity.bg;
import kanity.sprite;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

class LuaLibrary
{
    void newsprite(int no, string texturefile, int width, int height)
    {
        auto spchip = IMG_Load(texturefile.toStringz);
        auto testtex = SDL_CreateTextureFromSurface(engine.renderer.SDLRenderer, spchip);
        auto toriniku = new Character(width, height, testtex);
        engine.renderer.setSprite(new Sprite(toriniku), no);
    }
    Engine engine;
    LuaState lua;
    this(Engine engine)
    {
        this.engine = engine;
        lua = new LuaState;
        lua.openLibs();

        lua["newsprite"] = &newsprite;


    }
    void doString(string s)
    {
        lua.doString(s);
    }
}
