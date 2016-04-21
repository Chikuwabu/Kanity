module kanity.sprite;
import kanity.object;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

//なんかとりあえず実装
struct AnimationData(T)
{
    public bool isStarted()
    {
        return m_isStarted;
    }
    private bool m_isStarted;
    private T* ptr;
    private int frame;
    private int elapse;
    private T start;
    private T end;
    //なんかいろいろ
    //とりあえず線形補完
    public void animation()
    {
        if (m_isStarted)
        {
            *ptr = cast(int)(start + ((end - start) / cast(double)frame) * elapse);
            elapse++;
            if (elapse >= frame)
            {
                *ptr = end;
                m_isStarted = false;
            }
        }
    }
    public void setAnimation(int end, int frame)
    {
        this.start = *ptr;
        this.end = end;
        this.frame = frame;
        this.elapse = 0;
        this.m_isStarted = true;
    }

}
class Sprite : DrawableObject
{
    public int x;
    private AnimationData!int xAnim;
    public int y;
    private AnimationData!int yAnim;

    private AnimationData!int characterAnim;
    public int characterNumber;
    private Character m_character;
    public Character character()
    {
        return m_character;
    }
    public void character(Character c)
    {
        m_character = c;
    }


    public this(Character c)
    {
        super();
        texture = c.m_texture;
        this.m_character = c;
        xAnim.ptr = &x;
        yAnim.ptr = &y;
        characterAnim.ptr = &characterNumber;
    }

    public void move(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    public void move(int ax, int ay, int frame)
    {
        xAnim.setAnimation(ax, frame);
        yAnim.setAnimation(ay, frame);
    }

    public void setCharacterNumber(int num)
    {
        characterNumber = num;
    }

    public void setCharacterNumber(int num, int frame)
    {
        characterAnim.setAnimation(num, frame);
    }

    public override void draw()
    {
        SDL_Rect rectS, rectD;
        rectS = character.definition[characterNumber].rect;
        rectD.x = x;
        rectD.y = y;
        rectD.w = rectS.w;
        rectD.h = rectS.h;

        this.texRect = rectS;
        this.drawRect = rectD;
        super.draw();

        animation();
    }

    void animation()
    {
        xAnim.animation();
        yAnim.animation();
        characterAnim.animation();
    }
}

struct CharacterData
{
    SDL_Rect rect;
    int rotation;
    double scaleX;
    double scaleY;
}

class Character
{
    public CharacterData[] definition;
    private SDL_Texture* m_texture;
    public SDL_Texture* texture()
    {
        return m_texture;
    }
    //自動分割
    public this(int width, int height, SDL_Texture* tex)
    {
        int textureWidth;
        int textureHeight;
        uint f;
        int a;
        SDL_QueryTexture(tex, &f, &a, &textureWidth, &textureHeight);
        int widthcount = textureWidth / width;
        int heightcount = textureHeight / height;
        int chrcount = widthcount * heightcount;
        definition = new CharacterData[chrcount];
        CharacterData initialdata = CharacterData();
        initialdata.rect.w = width;
        initialdata.rect.h = height;
        initialdata.rotation = 0;
        initialdata.scaleX = 1;
        initialdata.scaleY = 1;
        definition[] = initialdata;
        int i;
        for (int y = 0; y < heightcount; y++)
        {
            for (int x = 0; x < widthcount; x++)
            {
                definition[i].rect.x = x * width;
                definition[i].rect.y = y * height;
                i++;
            }
        }
        m_texture = tex;
    }
}
