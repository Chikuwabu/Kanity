module kanity.control;

import kanity.render;
import kanity.event;
import kanity.core;
import kanity.lua;

class Control{
private:
    Renderer m_renderer;
    Event m_event;
    //LuaLibrary m_lua;
public:
    string startScript;

public:

    Renderer renderer()
    {
        return m_renderer;
    }

    Event event()
    {
        return m_event;
    }

    void run(Renderer renderer_, Event event_){
        m_renderer = renderer_; m_event = event_;
        import std.file;
        if (!startScript)
        {
            return;
        }
        auto lua = new LuaThread(m_renderer.renderEvent.getInterface, startScript.readText);
        //lua.stop;
    }
}
