module kanity.object;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import std.experimental.logger;
import std.stdio;
import std.math;

abstract class DrawableObject{
private:
  real x, y, w, h;//座標
  real z;//Z座標(描画優先度)
  real u1,v1,u2,v2; //(u1,v1)-(u2,v2)までの範囲
  real hx = 0.0, hy = 0.0; //描画時用の原点
  real scale_ = 1.0f, scaleOrigin;//拡大倍率
  real angle_ = 0; //なぜかOpenGLの仕様により度数法
  real aspect;//アスペクト比
  bool m_hide;//描画するかどうか
  SDL_Color color_;//描画色
  SDL_Texture* texture_;
  float gltexWidth, gltexHeight;
  SDL_Rect drawRect_, texRect_; //誤差対策
  int homeX_ = 0, homeY_ = 0;//処理用の原点(誤差対策)
protected:
  SDL_Window* window; //描画先のウインドウ
  SDL_Renderer* renderer; //描画に用いるレンダラ
  int drawWidth, drawHeight; //描画領域の幅、高さ
  int texWidth, texHeight; //テクスチャの幅、高さ

public:
  this(){
    window = SDL_GL_GetCurrentWindow();

    static import kanity.render;
    drawWidth = kanity.render.Renderer.getData("windowWidth").get!uint;
    drawHeight = kanity.render.Renderer.getData("windowHeight").get!uint;
    scaleOrigin = kanity.render.Renderer.getData("renderScale").get!real;

    renderer = window.SDL_GetRenderer();
    texture = renderer.SDL_CreateTexture(SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_STATIC, 1, 1);
    aspect = (cast(real)drawWidth / cast(real)drawHeight);

    color_ = SDL_Color(255, 255, 255, 255);

    this.priority = 0;
    m_hide = true;
  }
  ~this(){
    texture.SDL_DestroyTexture;
  }

  void draw(SDL_Rect drawrect, SDL_Rect texrect){
      if (m_hide) return;
      SDL_Rect drawBak, texBak;
      drawBak = drawRect; texBak = texRect;
      drawRect = drawrect; texRect = texrect;
      draw();
      drawRect = drawBak; texRect = texBak;
  }
  void draw(){
    if (m_hide) return;
    glColor4ub(color_.r, color_.g, color_.b, color_.a);

    real l_scale = scale_ * scaleOrigin;
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslated(x * scaleOrigin - 1 , 1 - y * scaleOrigin, 0); //5.描画先座標へ移動
    glScaled(1, aspect, 1);                                     //4.アスペクト比を調節
    glScaled(l_scale, l_scale, 1);                              //3.拡大
    glRotated(angle_, 0, 0, 1);                                 //2.回転
    glTranslated(-hx, -hy, 0);                                  //1.原点を移動

    texture_.SDL_GL_BindTexture(&gltexWidth, &gltexHeight);
    glBegin(GL_QUADS);
      glTexCoord2f(u1 * gltexWidth, v1 * gltexHeight); glVertex3f(0, 0, z);
      glTexCoord2f(u1 * gltexWidth, v2 * gltexHeight); glVertex3f(0, h, z);
      glTexCoord2f(u2 * gltexWidth, v2 * gltexHeight); glVertex3f(w, h, z);
      glTexCoord2f(u2 * gltexWidth, v1 * gltexHeight); glVertex3f(w, 0, z);
    glEnd();
    texture_.SDL_GL_UnbindTexture();
    glFlush();
  }

  void move(int x, int y){
    auto rect = drawRect;
    rect.x = x; rect.y = y;
    drawRect = rect;
  }
  void setHome(int x, int y){
    homeX_ = x; homeY_ = y;
    reloadHome;
  }
  void show(){
    m_hide = false;
  }
  void hide(){
    m_hide = true;
  }
  protected void reloadHome(){
    hx = +(cast(float)homeX / drawWidth * 2);
    hy = -(cast(float)homeY / drawWidth * 2);
  }
  public:
  @property{
    //描画優先度
    int priority(){return cast(int)((1.0 - z) * 256);} //描画優先度のZ座標に対する倍率は暫定
    float priority(int p_){return z = 1.0 - (cast(real)p_ / 256.0);}
    //見えているか
    bool isVisible(){
      return !m_hide;
    }

    //描画される大きさ(倍率)
    float scale(){return scale_;}
    void scale(float s){
      scale_ = s;
    }
    //描画角度
    real angleDeg(){return angle_;}
    void angleDeg(real deg){
      angle_ = deg % 360;
    }
    real angleRad(){
      return angle_ * 180 / PI;
    }
    void angleRad(real rad){
      angle_ = rad / 180 * PI;
    }
    //描画色
    void color(SDL_Color c){ color_ = c; }
    SDL_Color color(){ return color_; }
    //描画先座標
    int posX(){ return drawRect.x; }
    int posY(){ return drawRect.y; }
    void posX(int n){ auto rect = drawRect; rect.x = n; drawRect = rect; }
    void posY(int n){ auto rect = drawRect; rect.y = n; drawRect = rect; }
    //描画原点
    int homeX(){ return homeX_; }
    int homeY(){ return homeY_; }
    void homeX(int n){ homeX_ = n; reloadHome; }
    void homeY(int n){ homeY_ = n; reloadHome; }
    //描画領域の大きさ
    int width(){ return drawWidth; }
    int height(){ return drawHeight; }
    void width(int a){
        auto rect = drawRect;
        rect.w = a;
        drawRect = rect;
        auto trect = texRect;
        trect.w = a;
        texRect = trect;
        reloadHome();
        aspect = cast(real)drawWidth / cast(real)drawHeight;
    }
    void height(int a){
        auto rect = drawRect;
        rect.h = a;
        drawRect = rect;
        auto trect = texRect;
        trect.h = a;
        texRect = trect;
        reloadHome();
        aspect = cast(real)drawWidth / cast(real)drawHeight;
    }
  }

  protected:
  @property{
    //描画先領域
    SDL_Rect drawRect(){ return drawRect_; }
    void drawRect(SDL_Rect rect){
      drawRect_ = rect;
      x = (cast(real)rect.x / drawWidth * 2);
      y = (cast(real)rect.y / drawHeight * 2);
      w = +(cast(real)rect.w / drawWidth * 2);
      h = -(cast(real)rect.h / drawWidth * 2);
    }

    //サーフェスの描画に使う領域
    SDL_Rect texRect(){ return texRect_; }
    void texRect(SDL_Rect rect){
      texRect_ = rect;
      with(rect){
        u1 = cast(real)x / texWidth;
        v1 = cast(real)y / texHeight;
        u2 = cast(real)(x + w) / texWidth;
        v2 = cast(real)(y + h) / texHeight;
      }
    }
    SDL_Surface* surface(SDL_Surface* surface){
      texture.SDL_DestroyTexture;
      texture = renderer.SDL_CreateTextureFromSurface(surface);
      texWidth = surface.w; texHeight = surface.h;
      return surface;
    }
    SDL_Texture* texture(){return texture_;}
    SDL_Texture* texture(SDL_Texture* tex){
      uint f; int a;
      tex.SDL_QueryTexture(&f, &a, &texWidth, &texHeight);
      texture_ = tex;
      return tex;
    }
  }
}
