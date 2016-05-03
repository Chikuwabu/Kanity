module kanity.lua;
import kanity.imports;
import kanity.core;
import kanity.render;
import kanity.character;
import kanity.event;
import kanity.object;
import kanity.sprite;
import core.thread;

import luad.all;

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
        lua.setPanicHandler(&panic);
        //lua["test"] = &test;
        lua["CHARACTER_SCANAXIS"] = lua.registerType!CHARACTER_SCANAXIS();
        lua["log"] = &lua_log;
        lua["sleep"] = &lua_sleep;

        lua["loadImg"] = &lua_loadImg;
        lua["unloadImg"] = &lua_unloadImg;

        lua["newCharacter"] = &lua_newCharacter;
        lua["deleteCharacter"] = &lua_deleteCharacter;
        lua["setCutRect"] = &lua_character_set_cutRect;
        lua["setScanAxis"] = &lua_character_set_scanAxis;
        lua["cut"] = &lua_character_cut;
        lua["newSprite"] = &lua_sprite_new;

        T = new Thread(() => run(script));
        T.start;
    }
    static void panic(LuaState ls, in char[] error){
      import std.conv;
      log(LogLevel.error, "[Lua]"~(error.to!string));
    }
    void run(string script){
      lua.doString(script);
      auto init = lua.get!LuaFunction("init");
      auto initResult = init.call!int(0);
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
    void lua_log(LuaObject[] params...){
      if(params.length > 0){
        import std.algorithm, std.string;
        string s = "[Lua]"~params.map!((LuaObject a) => (a.toString())).join("");
        renderEvent.event_log(s);
      }
    }
    void lua_sleep(uint n){
      import std.datetime;
      T.sleep(dur!"msecs"(n));
    }
    string lua_loadImg(string name){
      renderEvent.event_surface_load(name);
      return name;
    }
    void lua_unloadImg(string name){
      renderEvent.event_surface_unload(name);
    }
    int lua_newCharacter(string surface){
      int id;
      renderEvent.event_character_new(surface, (int a){id = a;});
      renderEvent.flush;
      return id;
    }
    void lua_deleteCharacter(int chara){
      renderEvent.event_character_delete(chara);
    }
    void lua_character_set_cutRect(int chara, int w, int h){
      renderEvent.event_character_set_cutRect(chara, w, h);
    }
    void lua_character_set_scanAxis(int chara, CHARACTER_SCANAXIS scan){
      renderEvent.event_character_set_scanAxis(chara, scan);
    }
    void lua_character_cut(int chara){
      renderEvent.event_character_cut(chara);
    }
    int lua_sprite_new(int chara){
      int id;
      renderEvent.event_object_new(OBJECTTYPE.SPRITE, chara, (int a){id = a;});
      renderEvent.flush;
      return id;
    }
}
