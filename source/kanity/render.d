module kanity.render;

import kanity.object;
import kanity.sprite;
import kanity.bg;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import std.experimental.logger;
import std.string;

class Renderer{
  //フィールド
private:
  SDL_Window* window_;
  SDL_Renderer* renderer;
  SDL_GLContext context;
  Sprite[] spriteList;
  BG[] bgList;
  bool drawFlag;
  //もろもろの情報
  float renderScale = 1.0f; //拡大率
  uint bgChipSize = 16; //BG1チップの大きさ(幅、高さ共通)
  uint bgSizeWidth = 64; //横方向に配置するチップの数
  uint bgSizeHeight = 64; //縦方向に配置するチップの数

public:
  this(){
  } 
  SDL_Renderer* SDLRenderer()
  {
      return renderer;
  }
  void setSprite(Sprite sprite, int number)
  {
      spriteList[number] = sprite;
  }
  Sprite getSprite(int number)
  {
      return spriteList[number];
  }
  this(float scale){
    renderScale = scale;
  }
  ~this(){
    window_.SDL_DestroyWindow;
    context = SDL_GL_DeleteContext;
    renderer.SDL_DestroyRenderer;
  }

  @property{
    public SDL_Window* window(){ return window_;}
  }
  void init(string title, int width, int height){
    SDL_GL_DEPTH_SIZE.SDL_GL_SetAttribute(16);
    SDL_GL_DOUBLEBUFFER.SDL_GL_SetAttribute(1);

    window_ = createWindow(title, width, height);
    if(window_ == null) logf(LogLevel.fatal, "Failed to create window.\n%s", SDL_GetError());
    info("Success to create window.");
    //ウインドウに情報を埋めこむ
    window_.SDL_SetWindowData("renderScale", &renderScale);
    window_.SDL_SetWindowData("bgChipSize", &bgChipSize);
    window_.SDL_SetWindowData("bgSizeWidth", &bgSizeWidth);
    window_.SDL_SetWindowData("bgSizeHeight", &bgSizeHeight);

    renderer = window_.SDL_CreateRenderer(-1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_TARGETTEXTURE);
    window_.SDL_ShowWindow;

    SDL_Surface* mapchip = IMG_Load("BGTest2.png");

    auto bg1 = new BG(0, 0, mapchip);
    version(none) bg1.renderScale = 1.0f;
    bg1.scroll(100, 100, 120);

    bgList = new BG[1];
    bgList[0] = bg1;
    spriteList = new Sprite[100];
    auto spchip = IMG_Load("SPTest.png");
    auto testtex = renderer.SDL_CreateTextureFromSurface(spchip);
    auto toriniku = new Character(20, 16, testtex);
    spriteList[0] = new Sprite(toriniku);
    spriteList[0].move(13, 12);
    spriteList[0].move(130, 120, 120);
    spriteList[0].setCharacterNumber(23, 230);

    drawFlag = true;
    SDL_Delay(100);
    glInit;
  }
  void render(){
    if(drawFlag){
      glEnable(GL_DEPTH_TEST);
      glEnable(GL_TEXTURE_2D);
      glAlphaFunc(GL_GEQUAL, 0.1f);
      glEnable(GL_ALPHA_TEST);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      //test.draw;

      foreach(s; spriteList)
      {
          if(s)
              s.draw();
      }
      foreach(b; bgList)
      {
        b.draw();
      }
      glFinish();
      renderer.SDL_RenderPresent;
      //window_.SDL_GL_SwapWindow;
      //drawFlag = false;
    }
  }

  void draw(){
    drawFlag = true;
  }
  //Utils
private:
  SDL_Window* createWindow(string title, int width, int height){
    return SDL_CreateWindow(title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                              width, height, SDL_WINDOW_OPENGL | SDL_WINDOW_HIDDEN);
  }

  //OpenGL関連初期化
  void glInit(){
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-1, 1, -1, 1, -1, 4);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  }
}