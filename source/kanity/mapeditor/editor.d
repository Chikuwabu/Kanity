module kanity.mapeditor.editor;

import kanity.core;
import kanity.render;
import kanity.event;
import kanity.lua;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;
import core.thread;

class Editor : Engine
{
    public this(string s)
    {
        super(s);
    }
    public override int run()
    {
        return super.run();
    }
    protected override LowLayer createLowLayer(Renderer renderer, Event event)
    {
        return new EditorLowLayer(renderer, event);
    }
}
class EditorLowLayer : LowLayer
{
    this(Renderer renderer, Event event)
    {
        super(renderer, event);
    }

    override void init()
    {
        super.init();
        renderer.clear();
    }

    override void run()
    {
        super.run();
    }
}
