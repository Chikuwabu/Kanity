module kanity.map;

import kanity.imports;
import kanity.character;
import kanity.bg;
import std.stdio;
import std.string;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

class Map
{
    BG[] bgList;
    MapChip mapChip;
    string mapChipFileName;
    this(BG[] bg, MapChip mapChip)
    {
        bgList = bg;
        this.mapChip = mapChip;
    }

    this()
    {
    }


    void load(string filename)
    {
        File file = File(filename ~ ".kanitymap", "rb");
        file.readf("KANITYMAP");
        //BG
        int[1] bgCount;
        file.rawRead(bgCount);
        bgList = new BG[bgCount[0]];
        struct BGList
        {
            int i, w, h, priority;
            int[][] map;
        }
        BGList[] bl = new BGList[bgList.length];
        for (int i = 0; i < bgList.length; i++)
        {
            int[4] data;
            file.rawRead(data);
            int j = data[0];
            int w = data[1], h = data[2], priority = data[3];
            int[][] map = new int[][](w, h);
            file.rawRead(map);
            bl[j] = BGList(j, w, h, priority, map);

        }
        //character
        int[1] chrdata;
        file.rawRead(chrdata);
        char[] chipFileName = new char[chrdata[0]];
        file.rawRead(chipFileName);

        mapChip = new MapChip();
        import std.conv;
        mapChipFileName = chipFileName.to!string;
        mapChip.load(mapChipFileName);
        for (int i = 0; i < bgList.length; i++)
        {
            auto bg = new BG(mapChip.character);
            bg.sizeWidth = bl[i].w;
            bg.sizeHeight = bl[i].h;
            bg.priority = bl[i].priority;
            bg.rawMapData = bl[i].map;
            bgList[bl[i].i] = bg;
        }
    }
    void save(string mapChipFileName, string filename)
    {
        File file = File(filename ~ ".kanitymap", "wb");
        file.write("KANITYMAP");
        //BG
        int[1] bgCount = [bgList.length.to!int];
        file.rawWrite(bgCount);
        foreach(i, b; bgList){
            int[4] data = [i, b.sizeWidth, b.sizeHeight, b.priority].to!(int[]);
            file.rawWrite(data);
            file.rawWrite(b.rawMapData);
        }
        int[] chrdata = [mapChipFileName.length.to!int];
        file.rawWrite(chrdata);
        file.rawWrite(mapChipFileName);

    }
}

class MapChip
{
    Character character;
    bool[] colList;
    this(Character c, bool[] colLIst)
    {
        character = c;
        colList = colLIst;
    }

    this()
    {
    }

    void load(string filename)
    {
        File file = File(filename ~ ".kanitychip", "rb");
        file.readf("KANITYCHIP");
        //character
        int[1] chrdata;
        int[1] chrlen;
        file.rawRead(chrdata);
        file.rawRead(chrlen);
        char[] characterFileName = new char[chrdata[0]];
        file.rawRead(characterFileName);
        SDL_Rect[] characters_ = new SDL_Rect[chrlen[0]];
        SDL_Rect[int] characters;
        file.rawRead(characters_);
        foreach(int i, a; characters_){
          characters[i] = a;
        }
        characters.rehash;
        character = new Character(IMG_Load(characterFileName.toStringz), "hage");
        character.characters = characters;
        //当たり判定
        colList = new bool[characters.length];
        file.rawRead(colList);
    }

    void save(string filename, string characterFileName)
    {
        File file = File(filename ~ ".kanitychip", "wb");
        file.write("KANITYCHIP");
        //character
        auto characters = character.characters;
        SDL_Rect[] characters_ = new SDL_Rect[](characters.keys.minCount!"a>b"()[0]);
        characters.keys.each!((int i){
          characters_[i] = characters[i];
        });

        int[] chrdata = [cast(int)characterFileName.length];
        int[] chrlen = [cast(int)characters.length];
        file.rawWrite(chrdata);
        file.rawWrite(chrlen);
        file.rawWrite(characterFileName);
        file.rawWrite(characters_);
        //当たり判定
        file.rawWrite(colList);
    }
}
