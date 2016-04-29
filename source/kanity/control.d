module kanity.control;

import kanity.render;
import kanity.event;
import kanity.core;
import kanity.lua;

class Control{
private:
    Renderer m_renderer;
    Event m_event;
    LuaLibrary m_lua;
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
        m_lua = new LuaLibrary(m_renderer.renderEvent.getInterface);
        //m_lua.doFile(startScript);
    }
}
