module kanity.mapeditor.editor;

import kanity.core;
import kanity.render;
import kanity.character;
import kanity.bg;
import kanity.sprite;
import kanity.event;
import kanity.lua;
import kanity.object;
import kanity.map;
import kanity.text;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;
import core.thread;
import std.string;
import std.conv;
import std.range;
import std.algorithm;

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

class FilledBox : DrawableObject
{
}

class Button : DrawableObject
{
    DrawableObject background;
    DrawableObject foreground;
    void delegate() onClick;
    Event event;
    float __foggaf__;
    this(Event event, Text text, void delegate() onClick)
    {
        foreground = text;
        background = new FilledBox();
        background.color = SDL_Color(192, 192, 192, 255);
        super();
        event.eventHandler.addEventHandler(&checkEvent);
        this.event = event;
        this.onClick = onClick;
        __foggaf__ = kanity.render.Renderer.getData("renderScale").get!float;
    }
    override void draw()
    {
        foreground.draw();
        background.draw();
    }
    override void posX(int p)
    {
        super.posX(p);
        foreground.posX = p;
        background.posX = p;
    }
    override void posY(int p)
    {
        super.posY(p);
        foreground.posY = p;
        background.posY = p;
    }
    override void width(int p)
    {
        super.width(p);
        foreground.width = p;
        background.width = p;
    }
    override void height(int p)
    {
        super.height(p);
        foreground.height = p;
        background.height = p;
    }
    ~this()
    {
        if (event && event.eventHandler)
        {
            event.eventHandler.removeEventHandler(&checkEvent);
        }
    }
    void checkEvent(SDL_Event event)
    {
        switch(event.type)
        {
            case SDL_MOUSEBUTTONDOWN:
                auto button = event.button;
                auto x = button.x * __foggaf__;
                auto y = button.y * __foggaf__;
                if (button.x >= background.posX && button.x <= background.posX + background.width)
                {
                    if (button.y >= background.posY && button.y <= background.posY + background.height)
                    {
                        if (onClick)
                            onClick();
                    }
                }
                break;
            default:
                break;
        }
    }
}

class EditorLowLayer : LowLayer
{
    this(Renderer renderer, Event event)
    {
        super(renderer, event);
    }

    int width, height;
    int bgwidth, bgheight;
    BG chipList;
    BG map;
    BG[] layer;
    Sprite chipCursor;
    Sprite mapCursor;
    Sprite currentCursor;
    int mapCX;
    int mapCY;
    int mapHeight;
    Character character;
    string chraracterFile = "BGTest2.png";
    Button[] buttons;

    override void init()
    {
        super.init();
        renderer.clear();
        width = cast(int)(renderer.windowWidth / renderer.renderScale);
        height = cast(int)(renderer.windowHeight / renderer.renderScale);
        bgheight = height/ 16;
        bgwidth = width / 16;
        character = new Character(IMG_Load(chraracterFile.toStringz), 16, 16, CHARACTER_SCANAXIS.X);
        int listheight = 3;
        int[] m = new int[listheight * bgwidth];
        auto bg = new BG(character, m);
        bg.sizeWidth = bgwidth;
        bg.sizeHeight = listheight;
        renderer.addObject(bg);
        chipList = bg;
        //TODO:初期値おかしい?
        chipList.width = width;
        chipList.height = chipList.chipSize * listheight;
        scrollChipList(0);
        chipList.priority = 0;
        map = newMapBG();
        initMapBG(map);
        renderer.addObject(map);
        auto cursor = new Character(IMG_Load("SPTest.png"), 20, 16, CHARACTER_SCANAXIS.X);
        chipCursor = new Sprite(cursor, 0, 0, 0);
        chipCursor.homeX = 2;
        renderer.addObject(chipCursor);
        mapCursor = new Sprite(cursor, 0, 0, 1);
        mapCursor.homeX = 2;
        mapCursor.homeY = -16 * 3 - 16;//map.posY;
        this.mapHeight = height - 16 * 3 - 16;
        //map.height = this.mapHeight;
        renderer.addObject(mapCursor);

        layer = new BG[1];
        layer[0] = map;

        currentCursor = chipCursor;
        mapCursor.hide;

        auto box = new FilledBox();
        box.width = width;
        box.height = -(-16 * 3 - 16);
        box.priority = map.priority - 1;
        renderer.addObject(box);

        initFont();

        registerEvent();
    }
    Font font;
    void addLayerEvent()
    {
        auto bg = newMapBG();
        initMapBG(bg);
        layer ~= bg;
        renderer.addObject(bg);
        chLayer(layer.length - 1);
    }
    Text layerText;
    void initFont()
    {
        import std.stdio;
        auto font_datfile = File("mplus_j10r.dat.txt", "r");
        dstring[] font_dat = font_datfile.byLine.map!(x => x.to!dstring).array;
        auto mplus10font = new Font(font_dat,  new Character(IMG_Load("mplus_j10r.png"), 10, 11, CHARACTER_SCANAXIS.X));
        auto text = new Text(mplus10font);
        text.posY = 16 * 3;
        text.text = "現在のレイヤ：０";
        text.color = SDL_Color(0, 0, 0, 255);
        layerText = text;
        renderer.addObject(text);
        font = mplus10font;
        auto t2 = new Text(font);
        t2.text = "Ａｄｄ　Ｌａｙｅｒ";
        auto btn = new Button(event, t2, &addLayerEvent);
        buttons = [btn];
        btn.posY = 16 * 3;
        btn.posX = 90;
        btn.width = 100;
        btn.height = 12;
        renderer.addObject(btn);
    }
    void chLayer(int num)
    {
        map = layer[num];
        auto table = ['０', '１', '２', '３','４','５','６','７','８','９'];
        layerText.text = ("現在のレイヤ：" ~ /*goriosi*/num.to!wstring.map!(x => (x >= '0' && x <= '9' ? cast(wchar)table[x - '0'] : cast(wchar)x)).array.to!string);
    }
    BG newMapBG()
    {
        int mapWidth = 256, mapHeight = 256;
        int[] mapdata = new int[mapWidth *  mapHeight];
        mapdata[] = -1;

        auto map = new BG(character, mapdata);
        map.sizeWidth = mapWidth;
        map.sizeHeight = mapHeight;
        map.height = mapHeight * map.chipSize;
        map.priority = 2;
        return map;
    }
    void initMapBG(BG map)
    {
        map.move(0, -16 * 3 - 16);// map.posY = -16 * 3 - 16;
    }
    void layerMove(int mx, int my)
    {
        foreach (i; layer)
        {
            i.move(mx, my);
        }
    }
    void rightButton(bool repeat)
    {
        if (currentCursor == chipCursor)
        {
            selectedChip++;
            if (chipCursor.posX + map.chipSize >= chipList.width)
            {
                downButton(repeat);
                chipCursor.posX = 0;
                selectedChip -= bgwidth;
            }
            else
            {
                chipCursor.move(map.chipSize, 0);
            }
        }
        else if (currentCursor == mapCursor)
        {
            mapCX++;
            if (mapCursor.posX + cast(int)map.chipSize >= width)
            {
                layerMove(map.chipSize, 0);
            }
            else
            {
                mapCursor.move(map.chipSize, 0);
            }
        }
    }
    void leftButton(bool repeat)
    {
        if (currentCursor == chipCursor)
        {
            selectedChip--;
            if (chipCursor.posX - cast(int)map.chipSize < 0)
            {
                upButton(repeat);
                chipCursor.posX = chipList.width - map.chipSize;
                selectedChip += bgwidth;
            }
            else
            {
                chipCursor.move(-map.chipSize, 0);
            }
        }
        else if (currentCursor == mapCursor)
        {
            if (mapCursor.posX - cast(int)map.chipSize < 0)
            {
                layerMove(-map.chipSize, 0);
            }
            else
            {
                mapCursor.move(-map.chipSize, 0);
            }
            mapCX--;
        }
    }
    void upButton(bool repeat)
    {
        if (currentCursor == chipCursor)
        {
            selectedChip -= bgwidth;
            if (chipCursor.posY <= 0)
            {
                scrollChipList(-1);
                return;
            }
            chipCursor.move(0, -map.chipSize);
        }
        else if (currentCursor == mapCursor)
        {
            if (mapCursor.posY - cast(int)map.chipSize < 0)
            {
                layerMove(0, -map.chipSize);
            }
            else
            {
                mapCursor.move(0, -map.chipSize);
            }
            mapCY--;
        }
    }
    int  chipListChip;
    void scrollChipList(int my)
    {
       chipListChip += my * bgwidth;
       int chip  = chipListChip;
       for (int y = 0; y < chipList.sizeHeight; y++)
       {
           for (int x = 0; x < bgwidth; x++)
           {
               chipList.set(x, y, chip++);
           }
       }
    }
    void downButton(bool repeat)
    {
        if (currentCursor == chipCursor)
        {
            selectedChip += bgwidth;
            if (chipCursor.posY >= chipList.height - chipList.chipSize)
            {
                scrollChipList(1);
                return;
            }
            chipCursor.move(0, map.chipSize);
        }
        else if (currentCursor == mapCursor)
        {
            if (mapCursor.posY + cast(int)map.chipSize >= mapHeight)
            {
                layerMove(0, map.chipSize);
            }
            else
            {
                mapCursor.move(0, map.chipSize);
            }
            mapCY++;
        }
    }
    int selectedChip;
    void keyDownEvent(SDL_KeyboardEvent event)
    {
        if (currentCursor == mapCursor && event.keysym.sym == SDLK_RETURN)
        {
            map.set(mapCX, mapCY, selectedChip);
            return;
        }
        if (event.keysym.sym == SDLK_TAB || event.keysym.sym == SDLK_n || event.keysym.sym == SDLK_BACKSPACE || event.keysym.sym == SDLK_RETURN)
        {
            currentCursor.hide;
            if (currentCursor == chipCursor)
            {
                currentCursor = mapCursor;
            }
            else if (currentCursor == mapCursor)
            {
                currentCursor = chipCursor;
            }
            currentCursor.show;
        }
        if (event.keysym.sym == SDLK_s && (event.keysym.mod & KMOD_CTRL))
        {
            save();
        }
        if (event.keysym.sym == SDLK_o && (event.keysym.mod & KMOD_CTRL))
        {
            load();
        }
        if (event.keysym.sym >= '0' && event.keysym.sym <= '9')
        {
            chLayer(event.keysym.sym - '0');
        }
    }

    void load()
    {
        auto map = new Map();
        map.load("test");
        renderer.removeObject(this.map);
        this.layer = map.bgList;
        foreach (i; map.bgList)
        {
            initMapBG(i);
            renderer.addObject(i);
        }
        chLayer(0);
        mapCX = 0;
        mapCY = 0;
        mapCursor.posX = 0;
        mapCursor.posY = 0;
        std.experimental.logger.info("Success to load");
    }

    void save()
    {
        auto map = new Map(layer, character);
        map.save(chraracterFile, "test");
        std.experimental.logger.info("Success to save");
    }

    void registerEvent()
    {
        event.rightButtonDownEvent.addEventHandler(&rightButton);
        event.leftButtonDownEvent.addEventHandler(&leftButton);
        event.upButtonDownEvent.addEventHandler(&upButton);
        event.downButtonDownEvent.addEventHandler(&downButton);

        event.keyDownEvent.addEventHandler(&keyDownEvent);
    }

    override void run()
    {
        super.run();
    }
}
