module kanity.sprite;

import derelict.sdl2.sdl;
import kanity.object;
import kanity.character;

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
class Sprite : DrawableObject{
private:
  Character character_;
  uint charaNum_;
  string charaString_;

public:
  this(Character chara, int x, int y, uint charaNum){
    super();
    character_ = chara;
    this.surface = character_.surface;
    this.characterNum = charaNum;
    this.move(x, y);
  }
  void move(int x, int y){
    SDL_Rect rect;
    rect.x = x; rect.y = y;
    rect.w = texRect.w; rect.h = texRect.h;
    this.drawRect = rect;
  }
  @property{
    void characterNum(uint a){this.texRect = character_.getWithNum(a);}
    void characterString(string s){this.texRect = character_.getWithString(s);}
  }
}
