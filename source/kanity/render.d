module kanity.render;

import kanity.bg;
import kanity.sprite;
import kanity.character;

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
    public SDL_Renderer* SDLRenderer(){return renderer;}
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
    if(renderer == null) logf(LogLevel.fatal, "Failed to create renderer.\n%s", SDL_GetError());
    info("Success to create renderer.");
    window_.SDL_ShowWindow;

    auto mapchip = IMG_Load("BGTest2.png");
    SDL_Rect[] rect; rect.length = 1;
    with(rect[0]){
      x = 32; y = 0;
      w = 16; h = 16;
    }
    auto chara = new Character(mapchip,rect);

    auto bg1 = new BG(chara);
    bg1.priority = 256;
    bgList = new BG[1];
    bgList[0] = bg1;
    //Rbg1.scroll(100, 100, 120);

    //spriteList = new Sprite[100];
    auto spchip = new Character(IMG_Load("SPTest.png"),20, 16, CHARACTER_SCANAXIS.Y);
    spriteList = new Sprite[1];
    spriteList[0] = new Sprite(spchip, 0, 0, 0);
    spriteList[0].priority = 0;
    spriteList[0].characterNum = 1;
    spriteList[0].move(13, 12);
    //spriteList[0].move(130, 120, 120);

    drawFlag = true;
    SDL_Delay(100);
    glInit;
  }
  void render(){
    if(drawFlag){
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
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
      window_.SDL_GL_SwapWindow;
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

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);
    glAlphaFunc(GL_GEQUAL, 0.1f);
    glEnable(GL_ALPHA_TEST);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  }
}
