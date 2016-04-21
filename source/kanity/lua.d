module kanity.lua;
import luad.all;
import kanity.core;
import kanity.bg;
import kanity.sprite;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

class LuaLibrary
{
    void newSprite(int no, string texturefile, int width, int height)
    {
        auto spchip = IMG_Load(texturefile.toStringz);
        auto testtex = SDL_CreateTextureFromSurface(engine.renderer.SDLRenderer, spchip);
        auto toriniku = new Character(width, height, testtex);
        engine.renderer.setSprite(new Sprite(toriniku), no);
    }
    void moveSprite(int no, int x, int y)
    {
        engine.renderer.getSprite(no).move(x, y);
    }
    void moveSpriteAnimation(int no, int x, int y, int frame)
    {
        engine.renderer.getSprite(no).move(x, y, frame);
    }
    void setLeftButtonEvent(LuaFunction luafunc)
    {
        //kattenikopi-sitekurenai
        import std.algorithm.mutation;
        LuaFunction *temp = new LuaFunction();
        move(luafunc, *temp);
        auto ev = (()
        {
            (*temp)();
        });

        engine.event.leftButtonDownEvent.addEventHandler(ev);
    }
    void test()
    {
        engine.event.leftButtonDownEvent();
    }
    Engine engine;
    LuaState lua;
    this(Engine engine)
    {
        this.engine = engine;
        lua = new LuaState;
        lua.openLibs();

        lua["newSprite"] = &newSprite;
        lua["moveSprite"] = &moveSprite;
        lua["moveSpriteAnimation"] = &moveSpriteAnimation;
        lua["setLeftButtonEvent"] = &setLeftButtonEvent;

        lua["test"] = &test;
        
    }
    void doFile(string name)
    {
        lua.doFile(name);
    }

    void doString(string s)
    {
        lua.doString(s);
    }
}
