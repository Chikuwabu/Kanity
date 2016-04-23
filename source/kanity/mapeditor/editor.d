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
    public this()
    {
        super();
    }
    public void run()
    {
        super.run("Map editor", 640, 480);
    }
    protected override UnderLayer createUnderLayer(string title, int width, int height, Renderer renderer, Event event)
    {
        return new EditorUnderLayer(title, width, height, renderer, event);
    }
}
class EditorUnderLayer : UnderLayer
{
    this(string title, int width, int height, Renderer renderer, Event event)
    {
        super(title, width, height, renderer, event);
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
