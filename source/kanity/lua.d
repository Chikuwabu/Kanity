module kanity.lua;
import luad.all;
import kanity.core;
import kanity.render;
import kanity.event;
import kanity.object;
import kanity.sprite;
import kanity.utils;
import kanity.type;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
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
        event.leftButtonDownEvent();
    }
    /*DrawableObject spriteToDrawableObject(Sprite sp)
    {
        return sp;
    }*/
    Renderer renderer;
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
        doString("print('Hello Lua World')");

        //lua["test"] = &test;
        lua["log"] = &lua_log;
        lua["sleep"] = &lua_sleep;

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
}
