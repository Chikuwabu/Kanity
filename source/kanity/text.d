module kanity.text;

import kanity.object;
import kanity.character;
import std.conv;
import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;

class Font
{
    private Character fontCharacter;
    protected int[dchar] fontTable;
    //fontTable...フォントの並び方
    //fontTable[42] = "abcdefg"の時、Character42番がabcdefgに割り当てられる
    this(dstring[] fontTable, Character fc)
    {
        fontCharacter = fc;
        foreach(i, c; fontTable)
        {
            foreach(d; c)
            {
                this.fontTable[d] = i;
            }
        }
    }
    Character character()
    {
        return fontCharacter;
    }
    int getCharacterNumber(dchar i)
    {
        return fontTable[i];
    }
}

class Text : DrawableObject
{
    Font font;
    protected dstring dtext;
    void text(string t)
    {
        dtext = t.to!dstring;
    }

    string text()
    {
        return dtext.to!string;
    }

    this(Font f)
    {
        super();
        font = f;
        this.posX = 0; this.posY = 0;
        surface = font.character.surface;
    }

    override void draw()
    {
        auto chr = font.character;
        SDL_Rect drawRect, texRect = void;
        int x, y;
        foreach(c; dtext)
        {
            auto num = font.getCharacterNumber(c);
            texRect = chr.get(num);
            drawRect.x = x;
            drawRect.y = y;
            drawRect.w = texRect.w;
            drawRect.h = texRect.h;
            x += texRect.w;
            super.draw(drawRect, texRect);
        }
    }
}
