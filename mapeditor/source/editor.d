module kanity.mapeditor.editor;

import kanity.imports;
import kanity.core;
import kanity.render;
import kanity.character;
import kanity.bg;
import kanity.sprite;
import kanity.text;
import kanity.event;
import kanity.lua;
import kanity.object;
import kanity.map;
import kanity.text;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import derelict.opengl3.gl;
import core.thread;
import std.string;
import std.range;
import std.algorithm;
import std.experimental.logger;

class FilledBox : DrawableObject
{
}

class Box : DrawableObject
{
    override void draw()
    {
        SDL_Rect dRect;
        dRect.x = 0;
        dRect.y = 0;
        dRect.w = 1;
        dRect.h = height;
        super.draw(dRect, texRect);
        dRect.x = 0;
        dRect.y = 0;
        dRect.w = width;
        dRect.h = 1;
        super.draw(dRect, texRect);
        dRect.x = width - 1;
        dRect.y = 0;
        dRect.w = 1;
        dRect.h = height;
        super.draw(dRect, texRect);
        dRect.x = 0;
        dRect.y = height - 1;
        dRect.w = width;
        dRect.h = 1;
        super.draw(dRect, texRect);
    }
}

class TextBox : DrawableObject
{
    Text text;
    float __foggaf__;
    this(Event event, Text text)
    {
        this.text = text;
        __foggaf__ = kanity.render.Renderer.getData("renderScale").get!float;
        event.eventHandler.addEventHandler(&eventHandler);
    }

    override void draw()
    {
        with(text)
        {
            posX = this.posX;
            posY = this.posY;
            width = this.width;
            height = this.height;
            draw();
        }
        super.draw();
    }

    bool isActive;

    void eventHandler(SDL_Event event)
    {
        switch(event.type)
        {
            case SDL_MOUSEBUTTONDOWN:
                auto button = event.button;
                auto x = button.x * __foggaf__;
                auto y = button.y * __foggaf__;
                if (button.x >= posX && button.x <= posX + width)
                {
                    if (button.y >= posY && button.y <= posY + height)
                    {
                        isActive = true;
                        return;
                    }
                }
                isActive = !true;
                break;
            case SDL_TEXTINPUT:
                if (!isActive)
                {
                    return;
                }
                auto len = event.text.text.indexOf('\0');
                auto text = event.text.text[0..len].to!string;
                text.trace;
                this.text.text = this.text.text ~ text;
                break;
            default:
        }
    }

}

class Button : DrawableObject
{
    DrawableObject background;
    DrawableObject foreground;
    void delegate() onClick;
    Event event;
    real __foggaf__;
    this(Event event, Text text, void delegate() onClick)
    {
        foreground = text;
        background = new FilledBox();
        background.color = SDL_Color(192, 192, 192, 255);
        super();
        event.eventHandler.addEventHandler(&checkEvent);
        this.event = event;
        this.onClick = onClick;
        __foggaf__ = kanity.render.Renderer.getData("renderScale").get!real;
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


class Editor : Engine
{
    public this(string s, string s2)
    {
        super(s, s2);
    }
    abstract class Operation
    {
        abstract void undo();
        abstract void redo();
    }

    class MapOperation : Operation
    {
        this(int x, int y, int chip, int layer, BG bg)
        {
            this.x = x;
            this.y = y;
            this.chip = chip;
            this.layer = layer;
            this.bg = bg;
            this.oldchip = bg.get(x, y);
        }
        private int x;
        private int y;
        private int chip;
        private int oldchip;
        private BG bg;
        private int layer;
        override void undo()
        {
            setMapCursor(x, y);
            chLayer(layer);
            bg.set(x, y, oldchip);
        }
        override void redo()
        {
            setMapCursor(x, y);
            chLayer(layer);
            bg.set(x, y, chip);
        }
    }

    class SelectMapOperation : Operation
    {
        this(int cx, int cy, int x1, int y1, int x2, int y2, int chip, int layer, BG bg)
        {
            this.cx = cx;
            this.cy = cy;
            this.x1 = x1;
            this.y1 = y1;
            this.x2 = x2;
            this.y2 = y2;
            this.chip = chip;
            this.layer = layer;
            this.bg = bg;
            oldchip = new int[(x2 - x1 + 1) * (y2 - y1 + 1)];
            int i;
            for (int y = y1; y <= y2; y++)
            {
                for (int x = x1; x <= x2; x++)
                {
                    oldchip[i++] = map.get(x, y);
                }
            }
        }
        private int cx;
        private int cy;
        private int x1;
        private int y1;
        private int x2;
        private int y2;
        private int chip;
        private int[] oldchip;
        private BG bg;
        private int layer;
        override void undo()
        {
            setMapCursor(cx, cy);
            chLayer(layer);
            int i;
            for (int y = y1; y <= y2; y++)
            {
                for (int x = x1; x <= x2; x++)
                {
                    map.set(x, y, oldchip[i++]);
                }
            }
        }
        override void redo()
        {
            setMapCursor(cx, cy);
            chLayer(layer);
            for (int y = y1; y <= y2; y++)
            {
                for (int x = x1; x <= x2; x++)
                {
                    map.set(x, y, chip);
                }
            }
        }
    }

    void setMapCursor(int x, int y)
    {
        //画面範囲内か
        int mx = cast(int)map.posX / cast(int)map.chipSize;
        int my = (cast(int)map.posY - cast(int)mapCursor.homeY) / cast(int)map.chipSize;
        if (mx <= x && mx + bgwidth > x)
        {
            mapCursor.posX = (x - mx) * cast(int)map.chipSize;
        }
        else
        {
            layerMove(x * map.chipSize - map.posX, 0);
            mapCursor.posX = 0;
        }
        if (my <= y && my + mapHeight / cast(int)map.chipSize > y)
        {
            mapCursor.posY = (y - my) * cast(int)map.chipSize;
        }
        else
        {
            layerMove(0, y * map.chipSize + cast(int)mapCursor.homeY - map.posY);
            mapCursor.posY = 0;
        }
        mapCX = x;
        mapCY = y;
    }
    /**
    lawyerMoveTo("Tokyo");
    */
    void lawyerMoveTo(string place)
    {
    }
    Operation[] operationList;
    int operationIndex;
    void addOperation(Operation op)
    {
        operationList.length = ++operationIndex;
        operationList[operationIndex - 1] = op;
    }
    void undo()
    {
        if (!operationIndex)
        {
            info("Could not undo");
            return;
        }
        operationList[operationIndex - 1].undo();
        operationIndex--;
    }
    void redo()
    {
        if (operationIndex >= operationList.length)
        {
            info("Could not redo");
            return;
        }
        operationIndex++;
        operationList[operationIndex - 1].redo();
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

    protected override void init()
    {
        super.init();
        renderer.clear();
        width = cast(int)(renderer.windowWidth / renderer.renderScale);
        height = cast(int)(renderer.windowHeight / renderer.renderScale);
        bgheight = height/ 16;
        bgwidth = width / 16;
        character = new Character(IMG_Load(chraracterFile.toStringz));
        character.cut(16, 16, Character_ScanAxis.X);
        int listheight = 3;
        int[][] m = new int[][](bgwidth, listheight);
        auto bg = new BG(character);
        bg.mapData = m;
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
        auto cursor = new Character(IMG_Load_RW(FileSystem.loadRW("SPTest.png"), 1));
        cursor.cut(20, 16, Character_ScanAxis.X);
        chipCursor = new Sprite(cursor);
        chipCursor.homeX = 2;
        renderer.addObject(chipCursor);
        mapCursor = new Sprite(cursor);
        mapCursor.character = 1;
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

        initCol();

        //initFileTextBox();

        selectBox = new Box();
        selectBox.hide();
        renderer.addObject(selectBox);

        operationList = new Operation[0];
        registerEvent();
    }
    TTF_Font* font;
    Box selectBox;
    void addLayerEvent()
    {
        auto bg = newMapBG();
        initMapBG(bg);
        layer ~= bg;
        renderer.addObject(bg);
        chLayer(layer.length.to!int - 1);
    }
    Text layerText;
    void initFont()
    {
        auto mplus10font = TTF_OpenFontRW(FileSystem.loadRW("PixelMplus10-Regular.ttf"), 1, 10);//new Font(font_dat, hage);
        auto text = new Text(mplus10font);
        text.posY = 16 * 3;
        text.text = "現在のレイヤ：０";
        //text.color = SDL_Color(0, 0, 0, 255);
        layerText = text;
        renderer.addObject(text);
        font = mplus10font;
        auto t2 = new Text(font);
        t2.text = "レイヤを追加";
        auto btn = new Button(event, t2, &addLayerEvent);
        buttons = [btn];
        btn.posY = 16 * 3;
        btn.posX = 90;
        btn.width = 100;
        btn.height = 12;
        renderer.addObject(btn);
    }

    void initFileTextBox()
    {
        auto textBoxText = new Text(font);
        //textBoxText.color = SDL_Color(0, 0, 0, 255);
        auto label = new Text(font);
        //label.color = SDL_Color(0, 0, 0, 255);
        label.text = "マップのファイル名";
        label.posY = 16 * 3 + 1;
        label.posX = 300;
        label.width = 100;
        label.height = 12;
        renderer.addObject(label);

        auto textboxBox = new Box();
        auto filenameTextbox = new TextBox(event, textBoxText);
        filenameTextbox.posY = 16 * 3 + 1;
        filenameTextbox.posX = 400;
        filenameTextbox.width = 100;
        filenameTextbox.height = 12;
        textboxBox.posY = 16 * 3;
        textboxBox.posX = 400;
        textboxBox.width = 100;
        textboxBox.height = 14;
        textboxBox.color = SDL_Color(0, 0, 0, 255);

        renderer.addObject(filenameTextbox);
        renderer.addObject(textboxBox);
    }

    void showFileDialog()
    {
        int padding = 32;
        auto back = new FilledBox();
        back.color = SDL_Color(152, 152, 152, 255);
        back.posX = padding;
        back.posY = padding;
        back.width = width - padding;
        back.height = height - padding;
    }

    BG colBG;
    bool[] colList;
    void initCol()
    {
        auto t3 = new Text(font);
        t3.text = "当たり判定設定";
        auto btn2 = new Button(event, t3, &settingColEvent);
        btn2.posY = 16 * 3;
        btn2.posX = 90 + 104;
        btn2.width = 100;
        btn2.height = 12;
        renderer.addObject(btn2);
        auto colChar = new Character(IMG_Load("mapeditor.png"));
        colChar.cut(16, 16, Character_ScanAxis.X);
        colBG = new BG(colChar);
        colBG.posX = chipList.posX;
        colBG.posY = chipList.posY;
        colBG.priority = chipList.priority;
        colBG.hide();
        renderer.addObject(colBG);
        colList = new bool[character.characters.length];
    }
    bool isSettingColMode;
    void settingColEvent()
    {
        isSettingColMode = !isSettingColMode;
        if (isSettingColMode)
        {
            scrollChipList(0);
            colBG.show();
        }
        else
        {
            colBG.hide();
        }
    }
    int layerNumber;
    void chLayer(int num)
    {
        map = layer[num];
        layerNumber = num;
        auto table = ['０', '１', '２', '３','４','５','６','７','８','９'];
        layerText.text = ("現在のレイヤ：" ~ /*goriosi*/num.to!wstring.map!(x => (x >= '0' && x <= '9' ? cast(wchar)table[x - '0'] : cast(wchar)x)).array.to!string);
    }
    BG newMapBG()
    {
        int mapWidth = 256, mapHeight = 256;
        int[][] mapdata = new int[][](mapWidth, mapHeight);
        for(int i = 0; i < mapWidth; i++){
          mapdata[i][] = -1;
        }

        auto map = new BG(character);
        map.mapData = mapdata;
        map.sizeWidth = mapWidth;
        map.sizeHeight = mapHeight;
        map.height = mapHeight * map.chipSize;
        map.priority = 2;
        return map;
    }
    void initMapBG(BG map)
    {
        map.moveRelative(0, -16 * 3 - 16);// map.posY = -16 * 3 - 16;
    }
    void layerMove(int mx, int my)
    {
        foreach (i; layer)
        {
            i.moveRelative(mx, my);
        }
        updateSelectBox();
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
                chipCursor.moveRelative(map.chipSize, 0);
            }
        }
        else if (currentCursor == mapCursor)
        {
            if (SDL_GetModState() & KMOD_SHIFT)
            {
                startSelectMap();
            }
            mapCX++;
            if (mapCursor.posX + cast(int)map.chipSize >= width)
            {
                layerMove(map.chipSize, 0);
            }
            else
            {
                mapCursor.moveRelative(map.chipSize, 0);
            }
            if (SDL_GetModState() & KMOD_SHIFT)
            {
                selectMap();
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
                chipCursor.moveRelative(-map.chipSize, 0);
            }
        }
        else if (currentCursor == mapCursor)
        {
            if (SDL_GetModState() & KMOD_SHIFT)
            {
                startSelectMap();
            }
            if (mapCursor.posX - cast(int)map.chipSize < 0)
            {
                layerMove(-map.chipSize, 0);
            }
            else
            {
                mapCursor.moveRelative(-map.chipSize, 0);
            }
            mapCX--;
            if (SDL_GetModState() & KMOD_SHIFT)
            {
                selectMap();
            }
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
            chipCursor.moveRelative(0, -map.chipSize);
        }
        else if (currentCursor == mapCursor)
        {
            if (SDL_GetModState() & KMOD_SHIFT)
            {
                startSelectMap();
            }
            if (mapCursor.posY - cast(int)map.chipSize < 0)
            {
                layerMove(0, -map.chipSize);
            }
            else
            {
                mapCursor.moveRelative(0, -map.chipSize);
            }
            mapCY--;
            if (SDL_GetModState() & KMOD_SHIFT)
            {
                selectMap();
            }
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
               if (isSettingColMode)
               {
                   colBG.set(x, y, colList.length <= chip ? 0 : colList[chip]);
               }
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
            chipCursor.moveRelative(0, map.chipSize);
        }
        else if (currentCursor == mapCursor)
        {
            if (SDL_GetModState() & KMOD_SHIFT)
            {
                startSelectMap();
            }
            if (mapCursor.posY + cast(int)map.chipSize >= mapHeight)
            {
                layerMove(0, map.chipSize);
            }
            else
            {
                mapCursor.moveRelative(0, map.chipSize);
            }
            mapCY++;
            if (SDL_GetModState() & KMOD_SHIFT)
            {
                selectMap();
            }
        }
    }
    bool isSelectMode;
    SDL_Point selectStart;
    SDL_Point selectEnd;
    void startSelectMap()
    {
        if (!isSelectMode)
        {
            selectBox.show();
            selectStart.x = mapCX;
            selectStart.y = mapCY;
            selectEnd.x = mapCX;
            selectEnd.y = mapCY;
            isSelectMode = true;
            updateSelectBox();
        }
    }
    void selectMap()
    {
        if (isSelectMode)
        {
            selectEnd.x = mapCX;
            selectEnd.y = mapCY;
            updateSelectBox();
        }
    }
    void updateSelectBox()
    {
        if (!isSelectMode)
        {
            return;
        }
        selectBox.posX = selectStart.x.min(selectEnd.x) * map.chipSize - map.posX;
        selectBox.posY = selectStart.y.min(selectEnd.y) * map.chipSize - map.posY;
        if (selectStart.x < selectEnd.x + 1)
        {
            selectBox.width = (selectStart.x.max(selectEnd.x + 1) - selectStart.x.min(selectEnd.x + 1)) * map.chipSize;
        }
        else
        {
            selectBox.width = (selectStart.x.max(selectEnd.x + 1) - selectStart.x.min(selectEnd.x - 1)) * map.chipSize;
        }
        if (selectStart.y < selectEnd.y + 1)
        {
            selectBox.height = (selectStart.y.max(selectEnd.y + 1) - selectStart.y.min(selectEnd.y + 1)) * map.chipSize;
        }
        else
        {
            selectBox.height = (selectStart.y.max(selectEnd.y + 1) - selectStart.y.min(selectEnd.y - 1)) * map.chipSize;
        }
    }
    void unselect()
    {
        isSelectMode = false;
        selectBox.hide();
    }
    int selectedChip;
    bool isPressedEnter;
    void keyUpEvent(SDL_KeyboardEvent event)
    {
        if (event.keysym.sym == SDLK_RETURN)
        {
            isPressedEnter = false;
        }
    }
    void setMapChip(int chip)
    {
        if (isSelectMode)
        {
            int x1 = selectStart.x.min(selectEnd.x);
            int x2 = selectStart.x.max(selectEnd.x);
            int y1 = selectStart.y.min(selectEnd.y);
            int y2 = selectStart.y.max(selectEnd.y);
            auto op = new SelectMapOperation(mapCX, mapCY, x1, y1, x2, y2, chip ,layerNumber, map);
            addOperation(op);
            op.redo();
        }
        else
        {
            auto op = new MapOperation(mapCX, mapCY, chip, layerNumber, map);
            addOperation(op);
            op.redo();
        }
    }
    void keyDownEvent(SDL_KeyboardEvent event)
    {
        if (event.keysym.sym == SDLK_DELETE)
        {
            if (currentCursor == mapCursor)
            {
                setMapChip(-1);
                return;
            }
        }
        if (event.keysym.sym == SDLK_RETURN || isPressedEnter)
        {
            isPressedEnter = true;
            if (currentCursor == mapCursor)
            {
                setMapChip(selectedChip);
                return;
            }
            if (isSettingColMode)
            {
                colList[selectedChip] = !colList[selectedChip];
                scrollChipList(0);
                return;
            }
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
        if (event.keysym.sym == SDLK_ESCAPE)
        {
            unselect();
        }
        if (event.keysym.sym == SDLK_s && (event.keysym.mod & KMOD_CTRL))
        {
            save();
        }
        if (event.keysym.sym == SDLK_o && (event.keysym.mod & KMOD_CTRL))
        {
            load();
        }
        if (event.keysym.sym == SDLK_z && (event.keysym.mod & KMOD_CTRL))
        {
            undo();
        }
        if (event.keysym.sym == SDLK_y && (event.keysym.mod & KMOD_CTRL))
        {
            redo();
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
        this.colList = map.mapChip.colList;
        renderer.removeObject(this.map);
        this.layer = map.bgList;
        selectedChip = 0;
        scrollChipList(0);
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
        info("Success to load");
    }

    void save()
    {
        auto map = new Map(layer, new MapChip(character, colList));
        map.save("test", "test");
        map.mapChip.save("test", chraracterFile);
        std.experimental.logger.info("Success to save");
    }

    void registerEvent()
    {
        event.rightButtonDownEvent.addEventHandler(&rightButton);
        event.leftButtonDownEvent.addEventHandler(&leftButton);
        event.upButtonDownEvent.addEventHandler(&upButton);
        event.downButtonDownEvent.addEventHandler(&downButton);

        event.keyDownEvent.addEventHandler(&keyDownEvent);
        event.keyUpEvent.addEventHandler(&keyUpEvent);
    }

}
