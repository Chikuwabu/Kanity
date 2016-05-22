module kanity.object;

import kanity.imports;
import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import std.stdio;
import std.math;

abstract class DrawableObject{
private:
  double x, y; float w, h;//座標
  double z;//Z座標(描画優先度)
  float u1,v1,u2,v2; //(u1,v1)-(u2,v2)までの範囲
  protected real hx = 0.0, hy = 0.0; //描画時用の原点
  real scale_ = 1.0f, scaleOrigin;//拡大倍率
  real angle_ = 0; //なぜかOpenGLの仕様により度数法
  real aspect;//アスペクト比
  bool m_hide;//描画するかどうか
  SDL_Color color_;//描画色
  SDL_Texture* texture_;
  float gltexWidth = 1.0f, gltexHeight = 1.0f;
  SDL_Rect drawRect_, texRect_; //誤差対策
  int homeX_ = 0, homeY_ = 0;//処理用の原点(誤差対策)
  double[16] matrix;//変換行列
  float[4 * 2] vertex;//頂点配列
  float[4 * 2] coords;//テクスチャ座標配列
  MultiCastableDelegate!(void delegate()) preDraw;
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
    if(!texture){
      error("Failed to create texture.");
    }
    aspect = (cast(real)drawWidth / cast(real)drawHeight);

    color_ = SDL_Color(255, 255, 255, 255);

    this.priority = 0;
    m_hide = !true;
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    updateMatrix();
    updateVertex();
    updateTexCoord();
  }
  ~this(){
    if (texture)
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
    preDraw();
    preDraw.clear;
    glColor4ub(color_.r, color_.g, color_.b, color_.a);

    glMatrixMode(GL_MODELVIEW);
    glLoadMatrixd(matrix.ptr);

    texture_.SDL_GL_BindTexture(&gltexWidth, &gltexHeight);
    glVertexPointer(2, GL_FLOAT, 0, vertex.ptr);
    glTexCoordPointer(2, GL_FLOAT, 0, coords.ptr);
    glDrawArrays(GL_QUADS, 0, 4);
    texture_.SDL_GL_UnbindTexture();
    //glFlush();
  }
  private void updateMatrix(){
    preDraw += (){
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity();
      glTranslated(x * scaleOrigin - 1 , 1 - y * scaleOrigin, z); //5.描画先座標へ移動
      glScaled(1, aspect, 1);                                     //4.アスペクト比を調節
      glScaled(scale_ * scaleOrigin, scale_ * scaleOrigin, 1);    //3.拡大
      glRotated(angle_, 0, 0, 1);                                 //2.回転
      glTranslated(-hx, -hy, 0);                                  //1.原点を移動
      glGetDoublev(GL_MODELVIEW_MATRIX, matrix.ptr);
    };
  }
  private void updateVertex(){
    preDraw += (){
      vertex[0] = 0; vertex[1] = 0;
      vertex[2] = 0; vertex[3] = h;
      vertex[4] = w; vertex[5] = h;
      vertex[6] = w; vertex[7] = 0;
    };
  }
  private void updateTexCoord(){
    preDraw += (){
      coords[0] = u1; coords[1] = v1;
      coords[2] = u1; coords[3] = v2;
      coords[4] = u2; coords[5] = v2;
      coords[6] = u2; coords[7] = v1;
    };
  }

  void moveRelative(int x, int y){
    auto rect = drawRect;
    rect.x += x; rect.y += y;
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
    hx = +(cast(real)homeX / drawWidth * 2);
    hy = -(cast(real)homeY / drawWidth * 2);
    updateMatrix();
  }
  public:
  @property{
    //描画優先度
    int priority(){return cast(int)(z * 256);} //描画優先度のZ座標に対する倍率は暫定
    void priority(int p_){
      z = cast(real)p_ / 256.0;
      updateMatrix();
    }
    //見えているか
    bool isVisible(){
      return !m_hide;
    }

    //描画される大きさ(倍率)
    float scale(){return scale_;}
    void scale(float s){
      scale_ = s;
      updateMatrix();
    }
    //描画角度
    real angleDeg(){return angle;}
    void angleDeg(real deg){
      angle = deg % 360;
    }
    real angleRad(){
      return angle * 180 / PI;
    }
    void angleRad(real rad){
      angle = rad / 180 * PI;
    }
    private real angle(){return angle_;}
    private void angle(real a){
      angle_ = a;
      updateMatrix();
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
    //描画領域の大きさ?
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
      updateMatrix();
      updateVertex();
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
      updateTexCoord();
    }
    void surface(SDL_Surface* surface){
      auto tRect = texRect; auto dRect = drawRect;
      texture.SDL_DestroyTexture;
      texture = renderer.SDL_CreateTextureFromSurface(surface);
      texWidth = surface.w; texHeight = surface.h;
      texRect = tRect; drawRect = dRect;
    }
    SDL_Texture* texture(){return texture_;}
    void texture(SDL_Texture* tex){
      uint f; int a;
      tex.SDL_QueryTexture(&f, &a, &texWidth, &texHeight);
      texture_ = tex;
    }
  }
}

class Surface : DrawableObject{
  this(SDL_Surface* sf){
    super();
    this.surface = sf;
    SDL_Rect rect;
    with(rect){
      x = 0; y = 0;
      w = sf.w; h = sf.h;
    }
    this.drawRect = rect;
    this.texRect = rect;
  }
}
