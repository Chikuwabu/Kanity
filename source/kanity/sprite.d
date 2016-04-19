module kanity.sprite;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

class Sprite
{
    public int x;
    public int y;

    public int textureX;
    public int textureY;
    public int width;
    public int height;

    private SDL_Texture* texture;

    public this(SDL_Texture* texture)
    {
        this.texture = texture;
    }

    public void move(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    public void draw(SDL_Window* window, SDL_Renderer* renderer)
    {
        SDL_Rect rectS, rectD;
        rectS.x = textureX;
        rectS.y = textureY;
        rectS.w = width;
        rectS.h = height;
        rectD.x = x;
        rectD.y = y;
        rectD.w = width;
        rectD.h = height;

        renderer.SDL_RenderCopy(texture, &rectS, &rectD);
    }
}