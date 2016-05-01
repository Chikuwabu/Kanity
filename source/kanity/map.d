module kanity.map;

import kanity.character;
import kanity.bg;
import std.stdio;
import std.string;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

class Map
{
    BG[] bgList;
    Character character;
    bool[] colList;
    this(BG[] bg, Character c, bool[] colLIst)
    {
        bgList = bg;
        character = c;
        colList = colLIst;
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
            int[] map;
        }
        BGList[] bl = new BGList[bgList.length];
        for (int i = 0; i < bgList.length; i++)
        {
            int[4] data;
            file.rawRead(data);
            int j = data[0];
            int w = data[1], h = data[2], priority = data[3];
            int[] map = new int[w * h];
            file.rawRead(map);
            writeln(w, ',', h);
            bl[j] = BGList(j, w, h, priority, map);

        }
        //character
        int[1] chrdata;
        int[1] chrlen;
        file.rawRead(chrdata);
        file.rawRead(chrlen);
        char[] characterFileName = new char[chrdata[0]];
        file.rawRead(characterFileName);
        SDL_Rect[] characters = new SDL_Rect[chrlen[0]];
        file.rawRead(characters);
        character = new Character(IMG_Load(characterFileName.toStringz), characters);
        //当たり判定
        colList = new bool[characters.length];
        file.rawRead(colList);
        for (int i = 0; i < bgList.length; i++)
        {
            auto bg = new BG(character);
            bg.sizeWidth = bl[i].w;
            bg.sizeHeight = bl[i].h;
            bg.priority = bl[i].priority;
            bg.rawMapData = bl[i].map;
            bgList[bl[i].i] = bg;
        }
    }
    void save(string characterFileName, string filename)
    {
        File file = File(filename ~ ".kanitymap", "wb");
        file.write("KANITYMAP");
        //BG
        int[1] bgCount = [cast(int)bgList.length];
        file.rawWrite(bgCount);
        foreach(i, b; bgList)
        {
            int[4] data = [i, b.sizeWidth, b.sizeHeight, b.priority];
            file.rawWrite(data);
            file.rawWrite(b.rawMapData);
        }
        //character
        auto characters = character.characters;
        int[] chrdata = [cast(int)characterFileName.length];
        int[] chrlen = [cast(int)characters.length];
        file.rawWrite(chrdata);
        file.rawWrite(chrlen);
        file.rawWrite(characterFileName);
        file.rawWrite(characters);
        //当たり判定
        file.rawWrite(colList);
        
    }
}
