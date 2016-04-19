module kanity.sprite;
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
class Sprite
{
    public int x;
    private AnimationData!int xAnim;
    public int y;
    private AnimationData!int yAnim;

    private AnimationData!int characterAnim;
    public int textureX;
    public int textureY;
    public int width;
    public int height;

    private SDL_Texture* texture;

    public this(SDL_Texture* texture)
    {
        this.texture = texture;
        xAnim.ptr = &x;
        yAnim.ptr = &y;
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

    public void draw(SDL_Window* window, SDL_Renderer* renderer)
    {
        SDL_Rect rectS, rectD;
        rectS.x = textureX;
        rectS.y = textureY;
        rectS.w = width - 1;
        rectS.h = height - 1;
        rectD.x = x;
        rectD.y = y;
        rectD.w = width - 1;
        rectD.h = height - 1;

        renderer.SDL_RenderCopy(texture, &rectS, &rectD);

        animation();
    }

    void animation()
    {
        xAnim.animation();
        yAnim.animation();
    }
}