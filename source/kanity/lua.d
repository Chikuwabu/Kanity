module kanity.lua;
import luad.all;
import kanity.core;
import kanity.bg;
import kanity.sprite;
import kanity.render;
import kanity.event;
import kanity.character;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.string;

class LuaLibrary
{
    Sprite newSprite(int no, string texturefile, int width, int height)
    {
        auto spchip = IMG_Load(texturefile.toStringz);
        auto testtex = SDL_CreateTextureFromSurface(renderer.SDLRenderer, spchip);
        auto toriniku = new Character(spchip, width, height, CHARACTER_SCANAXIS.X);
        auto s = new Sprite(toriniku, 0, 0, 0);
        //renderer.setSprite(s, no);
        return s;
    }
    void moveSprite(int no, int x, int y)
    {
        //engine.renderer.getSprite(no).move(x, y);
    }
    void moveSpriteAnimation(int no, int x, int y, int frame)
    {
        //engine.renderer.getSprite(no).move(x, y, frame);
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

        event.leftButtonDownEvent.addEventHandler(ev);
    }
    void test()
    {
        event.leftButtonDownEvent();
    }
    Renderer renderer;
    Event event;
    LowLayer lLayer;
    LuaState lua;
    this(Renderer renderer_, Event event_, LowLayer lLayer_)
    {
        renderer = renderer_; event = event_; lLayer = lLayer_;
        lua = new LuaState;
        lua.openLibs();
        lua.registerType!Sprite();

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
