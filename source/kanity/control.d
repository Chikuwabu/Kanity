module kanity.control;

import kanity.render;
import kanity.event;
import kanity.core;
import kanity.lua;

class Control{
private:
    Renderer renderer;
    Event event;
    LowLayer lLayer;
    LuaLibrary lua;

public:
    void run(Renderer renderer_, Event event_, LowLayer lLayer_){
        renderer = renderer_; event = event_; lLayer = lLayer_;
        lua = new LuaLibrary(renderer_, event_, lLayer_);
        lua.doFile("test.lua");
    }
}
