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
        lua["flush"] = &lua_flush;
        lua["Character"] = lua.registerType!Lua_Character();
        lua["newCharacter"] = &lua_newCharacter;

        lua["loadImg"] = &lua_loadImg;
        lua["unloadImg"] = &lua_unloadImg;

        lua["Sprite"] = lua.registerType!Lua_Sprite();
        lua["newSprite"] = &lua_newSprite;

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
    void lua_flush(){
      renderEvent.flush;
    }
    string lua_loadImg(string name){
      renderEvent.event_surface_load(name);
      return name;
    }
    void lua_unloadImg(string name){
      renderEvent.event_surface_unload(name);
    }
    Lua_Character lua_newCharacter(string surface){
      return new Lua_Character(renderEvent, surface);
    }
    Lua_Sprite lua_newSprite(Lua_Character c){
      return new Lua_Sprite(renderEvent, c);
    }
}
class Lua_Character : Lua_RenderObject{
public:
  this(RenderEventInterface renderEvent_, string surface){
    super(renderEvent_);
    renderEvent.event_character_new(surface, super.setId);
  }
  void free(){
    renderEvent.event_character_delete(id);
  }
  void setCutRect(int w, int h){
    renderEvent.event_character_set_cutRect(id, w, h);
  }
  void setCutAxis(CHARACTER_SCANAXIS scan){
    renderEvent.event_character_set_scanAxis(id, scan);
  }
  void cut(){
    renderEvent.event_character_cut(id);
  }
}
class Lua_Sprite : Lua_DrawableObject{
public:
  this(RenderEventInterface renderEventInterface, Lua_Character character){
    super(renderEventInterface, OBJECTTYPE.SPRITE, character);
  }
}
abstract class Lua_DrawableObject : Lua_RenderObject{
protected{
  this(RenderEventInterface renderEventInterface, OBJECTTYPE type, Lua_Character character){
    super(renderEventInterface);
    renderEvent.event_object_new(type, character.id, super.setId);
  }
}
}
abstract class Lua_RenderObject{
  private int id_;
  private bool isAvailable = false;
  protected RenderEventInterface renderEvent;
protected:
  this(RenderEventInterface renderEventInterface){
    renderEvent = renderEventInterface;
  }
  @property{
    public int id(){
      if(isAvailable){
        return id_;
      }else{
        error("[Lua]Not initialized");
        return -1;
      }
    }
    void delegate(int) setId(){
      return (int a){id_ = a; isAvailable = true;};
    }
  }
}
