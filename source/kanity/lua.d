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
      synchronized renderEvent.send(new EventData(RENDER_EVENT.LOG, s));
    }
    void lua_sleep(uint n){
      import std.datetime;
      T.sleep(dur!"msecs"(n));
    }
    string lua_loadImg(string name){
      synchronized renderEvent.send(new EventData(RENDER_EVENT.SURFACE_LOAD, name));
      return name;
    }
    void lua_unloadImg(string name){
      synchronized renderEvent.send(new EventData(RENDER_EVENT.SURFACE_UNLOAD, name));
    }
    int lua_newCharacter(string surface){
      synchronized{
        renderEvent.send(new EventData(RENDER_EVENT.CHARACTER_NEW, surface));
        bool flag = true;
        renderEvent.callback = (){flag=false;};
        while(flag){}
        renderEvent.callback = null;
      }
      auto n = renderEvent.data;
      return n;
    }
    void lua_deleteCharacter(int chara){
      synchronized renderEvent.send(new EventData(RENDER_EVENT.CHARACTER_DELETE, chara));
    }
    void lua_character_set_rect(int chara, int w, int h){
      synchronized{
        renderEvent.send(new EventData(RENDER_EVENT.CHARACTER_SET_RECT, chara));
        renderEvent.send(new EventData(RENDER_EVENT.CHARACTER_SET_RECT, w, h));
      }
    }
    void lua_character_set_scanAxis(int chara, CHARACTER_SCANAXIS scan){
      synchronized{
        renderEvent.send(new EventData(RENDER_EVENT.CHARACTER_SET_SCANAXIS, chara));
        renderEvent.send(new EventData(RENDER_EVENT.CHARACTER_SET_SCANAXIS, scan));
      }
    }
    void lua_character_cut(int chara){
      synchronized renderEvent.send(new EventData(RENDER_EVENT.CHARACTER_CUT, chara));
    }
    int lua_sprite_new(int chara){
      synchronized{
        renderEvent.send(new EventData(RENDER_EVENT.OBJECT_NEW, OBJECTTYPE.SPRITE));
        renderEvent.send(new EventData(RENDER_EVENT.OBJECT_NEW, chara));
        bool flag = true;
        renderEvent.callback = (){flag = false;};
        while(flag){}
        renderEvent.callback = null;
      }
      return renderEvent.data;
    }
}
