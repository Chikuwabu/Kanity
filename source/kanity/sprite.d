module kanity.sprite;

import derelict.sdl2.sdl;
import kanity.object;
import kanity.character;
import std.experimental.logger;

class Sprite : DrawableObject{
private:
    Character character_;
    uint charaNum_;
    string charaString_;
    //AnimationData!int xAnim;
    //AnimationData!int yAnim;

    //AnimationData!int characterAnim;
    int characterNumber;

  public:
    this(Character chara, int x, int y, uint charaNum){
      super();
      character_ = chara;
      this.surface = character_.surface;
      this.posX = x; this.posY = y;
      this.characterNum = charaNum;
    }
    /*void move(int ax, int ay, int frame){
        xAnim.setAnimation(ax, frame);
        yAnim.setAnimation(ay, frame);
    }*/

    @property{
      void characterNum(uint a){
        this.texRect = character_.getWithNum(a);
        auto rect = this.drawRect;
        rect.w = this.texRect.w; rect.h = this.texRect.h;
        this.drawRect = rect;
      }
      void characterString(string s){this.texRect = character_.getWithString(s);}
    }

    public override void draw(){
        super.draw();
        animation();
    }

    private void animation()
    {
        //xAnim.animation();
        //yAnim.animation();
        //characterAnim.animation();
    }
}
