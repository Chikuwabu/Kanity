
module kanity.render;

import kanity.imports;
import kanity.bg;
import kanity.sprite;

public import kanity.events.render;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import derelict.sdl2.ttf;

import std.string;
import std.variant;
import std.container;

class Renderer{
  //フィールド
private:
  SDL_Window* window_;
  SDL_Renderer* renderer;
  SDL_GLContext context;

  bool drawFlag;
  static Variant[string] data;
  SList!(DrawableObject) object;
public:
  //もろもろの情報
  uint windowWidth = 640; //ウインドウのサイズ
  uint windowHeight = 480;
  string title = "Kanity"; //ウインドウタイトル
  bool isFullScreen = false; //フルスクリーンにするかどうか
  real renderScale = 1.0; //拡大率
  uint bgChipSize = 16; //BG1チップの大きさ(幅、高さ共通)
  uint bgSizeWidth = 64; //横方向に配置するチップの数
  uint bgSizeHeight = 64; //縦方向に配置するチップの数

public:
  static Variant getData(string s){
    return data[s];
  }

  void addObject(DrawableObject obj){
      object.insertFront(obj);
  }
  void removeObject(DrawableObject obj){
    import std.algorithm;
    import std.range;
    this.object.linearRemove(find(this.object[], obj).take(1));
    return;
  }
  void clear(){
      object.clear();
  }

  this(){
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
  void init(){
      object = make!(typeof(object));
    initRenderEvent;

    SDL_GL_DEPTH_SIZE.SDL_GL_SetAttribute(16);
    SDL_GL_DOUBLEBUFFER.SDL_GL_SetAttribute(true);

    window_ = createWindow(title, windowWidth, windowHeight, isFullScreen);
    if(window_ == null) logf(LogLevel.fatal, "Failed to create window.\n%s", SDL_GetError());
    info("Success to create window.");

    data["windowWidth"] = windowWidth;
    data["windowHeight"] = windowHeight;
    data["renderScale"] = renderScale;
    data["bgChipSize"] = bgChipSize;
    data["bgSizeWidth"] = bgSizeWidth;
    data["bgSizeHeight"] = bgSizeHeight;
    data.rehash;

    renderer = window_.SDL_CreateRenderer(-1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_TARGETTEXTURE);
    if(renderer == null) logf(LogLevel.fatal, "Failed to create renderer.");
    info("Success to create renderer.");
    window_.SDL_ShowWindow;

    //SDLを起動させるためのダミーの描画
    renderer.SDL_CreateTexture(SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_STATIC, 1, 1).SDL_DestroyTexture;

    drawFlag = true;
    glInit;
  }
  void render(){
    if(drawFlag){
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      foreach(DrawableObject obj; object){
        obj.draw;
      }
      glFlush();
      renderer.SDL_RenderPresent;
      window_.SDL_GL_SwapWindow;
    }
    renderEvent.event;
  }

  void draw(){
    drawFlag = true;
  }
  //Utils
private:
  SDL_Window* createWindow(string title, int width, int height, bool fullScreen){
    uint windowFlags = SDL_WINDOW_HIDDEN | SDL_WINDOW_OPENGL | (fullScreen ? SDL_WINDOW_FULLSCREEN : 0);
    return SDL_CreateWindow(title.toStringz, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                              width, height, windowFlags);
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
  public IDTable!DrawableObject objectID;
  public IDTable!Character charaID;
  public DataTable!(string, SDL_Surface*) surfaceData;
  public DataTable!(string, TTF_Font*) fontData;
  public RenderEvent renderEvent;

  void initRenderEvent(){
    objectID = new IDTable!DrawableObject();
    charaID = new IDTable!Character();
    surfaceData = new DataTable!(string, SDL_Surface*)();
    fontData = new DataTable!(string, TTF_Font*)();
    surfaceData.deleteFunc = (SDL_Surface* a) => (a.SDL_FreeSurface());
    fontData.deleteFunc = (TTF_Font* a) => (a.TTF_CloseFont());
    renderEvent = new RenderEvent(this);
  }
}
