module kanity.mapeditor.editor;

import kanity.core;
import kanity.render;
import kanity.character;
import kanity.bg;
import kanity.sprite;
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

    int width, height;
    int bgwidth, bgheight;
    BG chipList;
    BG map;
    Sprite chipCursor;
    Sprite mapCursor;
    Sprite currentCursor;
    int mapCX;
    int mapCY;
    int mapHeight;
    override void init()
    {
        super.init();
        renderer.clear();
        width = cast(int)(renderer.windowWidth / renderer.renderScale);
        height = cast(int)(renderer.windowHeight / renderer.renderScale);
        bgheight = height/ 16;
        bgwidth = width / 16;
        auto chara = new Character(IMG_Load("BGTest2.png"), 16, 16, CHARACTER_SCANAXIS.X);
        int listheight = 3;
        int[] m = new int[listheight * bgwidth];
        auto bg = new BG(chara, m);
        bg.sizeWidth = bgwidth;
        bg.sizeHeight = listheight;
        renderer.addObject(bg);
        chipList = bg;
        //TODO:初期値おかしい?
        chipList.width = width;
        chipList.height = chipList.chipSize * listheight;
        scrollChipList(0);
        int mapWidth = 256, mapHeight = 256;
        int[] mapdata = new int[mapWidth *  mapHeight];

        map = new BG(chara, mapdata);
        map.move(0, -16 * 3 - 16);// map.posY = -16 * 3 - 16;
        renderer.addObject(map);
        auto cursor = new Character(IMG_Load("SPTest.png"), 20, 16, CHARACTER_SCANAXIS.X);
        chipCursor = new Sprite(cursor, 0, 0, 0);
        chipCursor.homeX = 2;
        renderer.addObject(chipCursor);
        mapCursor = new Sprite(cursor, 0, 0, 1);
        mapCursor.homeX = 2;
        mapCursor.homeY = -16 * 3 - 16;//map.posY;
        this.mapHeight = height - 16 * 3 - 16;
        map.height = this.mapHeight;
        renderer.addObject(mapCursor);

        currentCursor = chipCursor;
        mapCursor.hide;
        registerEvent();
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
                map.move(map.chipSize, 0);
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
                if (chipCursor.posX - cast(int)map.chipSize < 0)
                {
                    chipCursor.move(-map.chipSize, 0);
                }
            }
        }
        else if (currentCursor == mapCursor)
        {
            if (mapCursor.posX - cast(int)map.chipSize < 0)
            {
                map.move(-map.chipSize, 0);
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
                map.move(0, -map.chipSize);
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
                map.move(0, map.chipSize);
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
