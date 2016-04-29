module kanity.lua;
import luad.all;
import kanity.core;
import kanity.bg;
import kanity.sprite;
import kanity.render;
import kanity.event;
import kanity.character;
import kanity.object;
import kanity.control;
import kanity.utils;
import kanity.type;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.string;

class LuaLibrary
{
    SDL_Surface* IMG_Load(string file)
    {
        return derelict.sdl2.image.IMG_Load(file.toStringz);
    }

    Character newCharacter(SDL_Surface* sf, uint chipWidth, uint chipHeight, CHARACTER_SCANAXIS scan)
    {
        return new Character(sf, chipWidth, chipHeight, scan);
    }
    Sprite newSprite(Character chara, int x, int y, uint charaNum)
    {
        auto s = new Sprite(chara, x, y, charaNum);
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
    Control acontrol()
    {
        return null;
    }
    void test()
    {
        event.leftButtonDownEvent();
    }
    DrawableObject spriteToDrawableObject(Sprite sp)
    {
        return sp;
    }
    Renderer renderer;
    Event event;
    LuaState lua;
    this(RenderEventInterface renderEvent)
    {
        lua = new LuaState;
        lua.openLibs();
        //lua["Character"] = lua.registerType!Character();
        lua["Sprite"] = lua.registerType!Sprite();
        //lua["Control"] = lua.registerType!Control();
        lua["CHARACTER_SCANAXIS"] = lua.registerType!CHARACTER_SCANAXIS();
        lua["IMG_Load"] = &IMG_Load;
        lua["newCharacter"] = &newCharacter;
        lua["newSprite"] = &newSprite;
        lua["moveSprite"] = &moveSprite;
        lua["moveSpriteAnimation"] = &moveSpriteAnimation;
        lua["setLeftButtonEvent"] = &setLeftButtonEvent;

        lua["test"] = &test;
        //lua["control"] = control;
        lua["spriteToDrawableObject"] = &spriteToDrawableObject;
        EventData e;
        e.type = EVENT_DATA.STRING;
        e.event = RENDER_EVENT.TEST;
        e.str = "Yuuashi is hage";
        renderEvent.send(e);

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
