module kanity.lua;
import luad.all;
import kanity.core;
import kanity.render;
import kanity.character;
import kanity.event;
import kanity.object;
import kanity.sprite;
import kanity.utils;
import kanity.type;
import std.experimental.logger;
import std.string;
import core.thread;

class LuaThread{
    /*void setLeftButtonEvent(LuaFunction luafunc)
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
    }*/
    void test()
    {
        //event.leftButtonDownEvent();
    }
    /*DrawableObject spriteToDrawableObject(Sprite sp)
    {
        return sp;
    }*/
    Event event;
    LuaState lua;
    Thread T;
    RenderEventInterface renderEvent;
    immutable string script;

    this(RenderEventInterface renderEvent_, string script_){
        renderEvent = renderEvent_;
        script = script_;
        lua = new LuaState;
        lua.openLibs();
        //e.event = RENDER_EVENT.NEWOBJECT;
        //e.type = EVENT_DATA.NUMBER;
        //e.number

        //lua["test"] = &test;
        lua["CHARACTER_SCANAXIS"] = lua.registerType!CHARACTER_SCANAXIS();
        lua["log"] = &lua_log;
        lua["sleep"] = &lua_sleep;

        lua["loadImg"] = &lua_loadImg;
        lua["unloadImg"] = &lua_unloadImg;

        lua["newCharacter"] = &lua_newCharacter;
        lua["deleteCharacter"] = &lua_deleteCharacter;
        lua["setCutRect"] = &lua_character_set_rect;
        lua["setScanAxis"] = &lua_character_set_scanAxis;
        lua["cut"] = &lua_character_cut;
        lua["newSprite"] = &lua_sprite_new;

        T = new Thread(() => doString(script));
        T.start;
    }
    void stop(){
    }
    void doFile(string name){
      import std.file;
      doString(name.readText);
    }

    void doString(string s){
        lua.doString(s);
    }
    void lua_log(string s){
      EventData e;
      e.type = EVENT_DATA.STRING;
      e.event = RENDER_EVENT.LOG;
      e.str = s;
      renderEvent.send(e);
    }
    void lua_sleep(uint n){
      import std.datetime;
      T.sleep(dur!"msecs"(n));
    }
    string lua_loadImg(string name){
      EventData e;
      e.event = RENDER_EVENT.SURFACE_LOAD;
      e.type = EVENT_DATA.STRING;
      e.str = name;
      renderEvent.send(e);
      return name;
    }
    void lua_unloadImg(string name){
      EventData e;
      e.event = RENDER_EVENT.SURFACE_UNLOAD;
      e.type = EVENT_DATA.STRING;
      e.str = name;
      renderEvent.send(e);
    }
    int lua_newCharacter(string surface){
      EventData e;
      e.event = RENDER_EVENT.CHARACTER_NEW;
      e.type = EVENT_DATA.STRING;
      e.str = surface;
      renderEvent.send(e);
      bool flag = true;
      renderEvent.callback = (){flag=false;};
      while(flag){}
      auto n = renderEvent.data;
      renderEvent.callback = null;
      return n;
    }
    void lua_deleteCharacter(int chara){
      EventData e;
      e.event = RENDER_EVENT.CHARACTER_DELETE;
      e.type = EVENT_DATA.NUMBER;
      e.number = chara;
      renderEvent.send(e);
    }
    void lua_character_set_rect(int chara, int w, int h){
      EventData e;
      e.event = RENDER_EVENT.CHARACTER_SET_RECT;
      e.type = EVENT_DATA.NUMBER;
      e.number = chara;
      renderEvent.send(e);
      e.clear;
      e.type = EVENT_DATA.POS;
      e.posX = w; e.posY = h;
      renderEvent.send(e);
    }
    void lua_character_set_scanAxis(int chara, CHARACTER_SCANAXIS scan){
      EventData e;
      e.event = RENDER_EVENT.CHARACTER_SET_SCANAXIS;
      e.type = EVENT_DATA.NUMBER;
      e.number = chara;
      renderEvent.send(e);
      e.clear;
      e.type = EVENT_DATA.NUMBER;
      e.number = scan;
      renderEvent.send(e);
    }
    void lua_character_cut(int chara){
      EventData e;
      e.event = RENDER_EVENT.CHARACTER_CUT;
      e.type = EVENT_DATA.NUMBER;
      e.number = chara;
      renderEvent.send(e);
    }
    int lua_sprite_new(int chara){
      EventData e;
      e.event = RENDER_EVENT.OBJECT_NEW;
      e.type = EVENT_DATA.NUMBER;
      e.number = OBJECTTYPE.SPRITE;
      renderEvent.send(e);
      e.clear;
      e.type = EVENT_DATA.NUMBER;
      e.number = chara;
      renderEvent.send(e);
      bool flag = true;
      renderEvent.callback = (){flag = false;};
      while(flag){}
      renderEvent.callback = null;
      return renderEvent.data;
    }
}
