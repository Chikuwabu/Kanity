module kanity.lua;

import kanity.imports;
import kanity.core;
import kanity.render;
import kanity.character;
import kanity.event;
import kanity.object;
import kanity.sprite;
import core.thread;
import std.container;

import luad.all;
import luad.c.all;

class LuaThread{
    /*void setLeftButtonEvent(LuaFunction luafunc)
    {
        //kattenikopi-sitekurenai
        import std.algorithm.mutation;
        LuaFunction *temp = new LuaFunction();
        move(luafunc, *temp);
        auto ev = ((bool repeat)
        {
            (*temp)(repeat);
        });

        event.leftButtonDownEvent.addEventHandler(ev);
    }*/
    Event event;
    LuaState lua;
    Thread T;
    RenderEventInterface renderEvent;
    immutable string script;

    this(RenderEventInterface renderEvent_, string script_){
        renderEvent = renderEvent_;
        script = script_;
        lua = new LuaState();
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
    exec((){renderEvent.event_character_delete(id);});
  }
  void setCutRect(int w, int h){
    exec((){renderEvent.event_character_set_cutRect(id, w, h);});
  }
  void setCutAxis(CHARACTER_SCANAXIS scan){
    exec((){renderEvent.event_character_set_scanAxis(id, scan);});
  }
  void cut(){
    exec((){renderEvent.event_character_cut(id);});
  }
}
class Lua_Sprite : Lua_RenderObject{
public:
  this(RenderEventInterface renderEventInterface, Lua_Character character){
    super(renderEventInterface);
    create(OBJECTTYPE.SPRITE, character);
  }
  mixin Lua_DrawableObject;

  void setCharacterNum(int chara){
    exec((){renderEvent.event_sprite_setCharacterNum(id, chara);});
  }
  void setCharacterStr(string chara){
    exec((){renderEvent.event_sprite_setCharacterStr(id, chara);});
  }
}
template Lua_DrawableObject(){
  void create(OBJECTTYPE type, Lua_Character character){
    renderEvent.event_object_new(type, character.id, super.setId);
  }
  void show(){
    exec((){renderEvent.event_object_show(id);});
  }
  void hide(){
    exec((){renderEvent.event_object_hide(id);});
  }
  void move(int x, int y){
    exec((){renderEvent.event_object_move(id, x, y);});
  }
  void setHome(int x, int y){
    exec((){renderEvent.event_object_setHome(id, x, y);});
  }
  void setScale(real scale){
    exec((){renderEvent.event_object_setScale(id, scale);});
  }
  void setAngleDeg(real deg){
    exec((){renderEvent.event_object_setAngleDeg(id, deg);});
  }
  void setAngleRad(real rad){
    exec((){renderEvent.event_object_setAngleRad(id, rad);});
  }
  void setPriority(int p){
    exec((){renderEvent.event_object_setPriority(id, p);});
  }
}
abstract class Lua_RenderObject{
  private int id_;
  private bool isAvailable = false;
  protected RenderEventInterface renderEvent;
  private Queue!(DList!(void delegate())) queue;
protected:
  this(RenderEventInterface renderEventInterface){
    renderEvent = renderEventInterface;
  }
  @property{
    public int id(){
      if(isAvailable){
        return id_;
      }else{
        //どうしても必要なら強制的に取得する
        "flush".log;
        while(!isAvailable){}
        return id_;
      }
    }
    void delegate(int) setId(){
      return (int a){
        id_ = a;
        isAvailable = true;
        synchronized execQueue();
      };
    }
    void exec(void delegate() f){
      if(isAvailable){
        f();
      }else{
        queue.enqueue(f);
      }
    }
    private void execQueue(){
      foreach(a; queue[]){
        a();
      }
    }
  }
}
