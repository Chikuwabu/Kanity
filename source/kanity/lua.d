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
        auto ev = (()
        {
            (*temp)();
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
        lua["Character_ScanAxis"] = lua.registerType!Character_ScanAxis();
        lua["log"] = &lua_log;
        lua["sleep"] = &lua_sleep;
        lua["flush"] = &lua_flush;

        lua["loadImg"] = &lua_loadImg;
        lua["unloadImg"] = &lua_unloadImg;

        lua["loadFont"] = &lua_loadFont;
        lua["unloadFont"] = &lua_unloadFont;

        lua["Character"] = lua.registerType!Lua_Character();
        lua["newCharacter"] = &lua_newCharacter;

        lua["Sprite"] = lua.registerType!Lua_Sprite();
        lua["newSprite"] = &lua_newSprite;

        lua["BG"] = lua.registerType!Lua_BG();
        lua["newBG"] = &lua_newBG;

        lua["Text"] = lua.registerType!Lua_Text();
        lua["newText"] = &lua_newText;

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
        import std.string;
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

    string lua_loadFont(string name, int size){
      renderEvent.event_font_load(name, size);
      return name;
    }
    void lua_unloadFont(string name){
      renderEvent.event_font_unload(name);
    }

    Lua_Character lua_newCharacter(string surface){
      return new Lua_Character(renderEvent, surface);
    }
    Lua_Sprite lua_newSprite(Lua_Character c){
      return new Lua_Sprite(renderEvent, c);
    }
    Lua_BG lua_newBG(Lua_Character c){
      return new Lua_BG(renderEvent, c);
    }
    Lua_Text lua_newText(string font){
      return new Lua_Text(renderEvent, font);
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
  void setCutAxis(Character_ScanAxis scan){
    exec((){renderEvent.event_character_set_scanAxis(id, scan);});
  }
  void cut(){
    exec((){renderEvent.event_character_cut(id);});
  }
  void add(LuaObject[] params...){
    switch(Pattern(params)){
      case Pattern(LuaType.Number, LuaType.Number, LuaType.Number):
        exec((){renderEvent.event_character_add(
          id, params[0].to!int, params[1].to!int, params[2].to!int);
        });
        break;
      case Pattern(LuaType.Number, LuaType.Number, LuaType.Number, LuaType.Number, LuaType.Number):
        exec((){renderEvent.event_character_add(
          id, params[0].to!int, params[1].to!int, params[2].to!int, params[3].to!int, params[4].to!int);
        });
        break;
      case Pattern(LuaType.String, LuaType.Number, LuaType.Number):
        exec((){renderEvent.event_character_add(
          id, params[0].to!string, params[1].to!int, params[2].to!int);
        });
        break;
      case Pattern(LuaType.String, LuaType.Number, LuaType.Number, LuaType.Number, LuaType.Number):
        exec((){renderEvent.event_character_add(
          id, params[0].to!string, params[1].to!int, params[2].to!int, params[3].to!int, params[4].to!int);
        });
        break;
      default:
        error("[Lua][Character.add]Invalid Arguments.");
        enforce(0);
        break;
    }
  }
}
class Lua_Sprite : Lua_RenderObject{
public:
  this(RenderEventInterface renderEventInterface, Lua_Character character){
    super(renderEventInterface);
    create(ObjectType.Sprite, character);
  }
  mixin Lua_DrawableObject;

  void setCharacterNum(int chara){
    exec((){renderEvent.event_sprite_setCharacterNum(id, chara);});
  }
  void setCharacterStr(string chara){
    exec((){renderEvent.event_sprite_setCharacterStr(id, chara);});
  }
}
class Lua_BG : Lua_RenderObject{
public:
  this(RenderEventInterface renderEventInterface, Lua_Character character){
    super(renderEventInterface);
    create(ObjectType.BG, character);
  }
  mixin Lua_DrawableObject;

  void setMapData(int[][] data){
    exec((){renderEvent.event_bg_setMapData(id, data);});
  }
}

class Lua_Text : Lua_RenderObject{
public:
  this(RenderEventInterface renderEventInterface, string font){
    super(renderEventInterface);
    renderEvent.event_object_new(ObjectType.Text, font, this.setId);
  }
  mixin Lua_DrawableObject;

  void setText(string text){
    exec((){renderEvent.event_text_setText(id, text);});
  }
}
template Lua_DrawableObject(){
  void create(ObjectType type, Lua_Character character){
    renderEvent.event_object_new(type, character.id, super.setId);
  }
  void create(ObjectType type, string data){
    renderEvent.event_object_new(type, data, super.setId);
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
        renderEvent.flush;
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
      queue[].each!((a){
        a();
      });
    }
  }
}

static string Pattern(LuaObject[] params){
  import std.array;
  return params.map!(a => a.type).array.Pattern;
}
static string Pattern(LuaType[] params...){
  return params.Pattern;
}
static string Pattern(LuaType[] params){
  import std.string;
  return params.map!((a){
      switch(a){
        case LuaType.String:
          return "string";
        case LuaType.Number:
          return "number";
        case LuaType.Nil:
          return "nil";
        case LuaType.Boolean:
          return "boolean";
        case LuaType.Function:
          return "function";
        case LuaType.Userdata:
        case LuaType.LightUserdata:
          return "userdata";
        default:
          return "";
      }
    }).join(",");
}
