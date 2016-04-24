module kanity.control;

import kanity.render;
import kanity.event;
import kanity.core;
import kanity.lua;

class Control{
private:
    Renderer m_renderer;
    Event m_event;
    LowLayer m_lLayer;
    LuaLibrary m_lua;

public:
    Renderer renderer()
    {
        return m_renderer;
    }

    Event event()
    {
        return m_event;
    }

    LowLayer lowLayer()
    {
        return m_lLayer;
    }

    void run(Renderer renderer_, Event event_, LowLayer lLayer_){
        m_renderer = renderer_; m_event = event_; m_lLayer = lLayer_;
        m_lua = new LuaLibrary(this, renderer_, event_, lLayer_);
        m_lua.doFile("test.lua");
    }
}
