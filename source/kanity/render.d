module kanity.render;

import kanity.bg;
import kanity.sprite;
import kanity.character;
import kanity.object;
import kanity.type;
import kanity.utils;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import std.experimental.logger;
import std.string;
import std.variant;
import std.container;
import std.exception;

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
  float renderScale = 1.0f; //拡大率
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
    import std.range;
    loop: for(auto r = object[]; !r.empty;){
            if(r.front == obj){
              r = object.linearRemove(r.take(1));
              break loop;
            }else{
              r.popFront;
            }
          }
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

    renderer = window_.SDL_CreateRenderer(-1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_TARGETTEXTURE);
    if(renderer == null) logf(LogLevel.fatal, "Failed to create renderer.");
    info("Success to create renderer.");
    window_.SDL_ShowWindow;

    SDL_Rect[] rect; rect.length = 1;
    with(rect[0]){
      x = 64; y = 0;
      w = 16; h = 16;
    }
    auto chara = new Character(IMG_Load("BGTest2.png"),rect);
    auto a = chara.add(64, 0);
    int[64*64] map;
    map[] = a;
    auto bg1 = new BG(chara, map);
    bg1.priority = 256;
    //bg1.scroll(-50, -50);
    addObject(bg1);

    //spriteList = new Sprite[100];
    auto spchip = new Character(IMG_Load("SPTest.png"),20, 16, CHARACTER_SCANAXIS.Y);
    auto sp = new Sprite(spchip, 0, 0, 0);
    sp.setHome(10, 8);
    sp.priority = 0;
    sp.character = 0;
    sp.move(50, 50);
    sp.scale = 1.0;
    sp.scaleAnimation(2.0,60);
    addObject(sp);

    import kanity.text;
    import std.stdio;
    import std.conv;
    auto font_datfile = File("mplus_j10r.dat.txt", "r");
    dstring[] font_dat = new dstring[0];
    while(!font_datfile.eof)
    {
        auto line = font_datfile.readln();
        font_dat ~=line.to!dstring;
    }
    auto mplus10font = new Font(font_dat,  new Character(IMG_Load("mplus_j10r.png"), 10, 11, CHARACTER_SCANAXIS.X));
    auto text = new Text(mplus10font);
    text.posX = 20;
    text.text = "こんにちは、世界";
    addObject(text);
    drawFlag = true;
    SDL_Delay(100);
    glInit;
  }
  void render(){
    if(drawFlag){
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      foreach(DrawableObject obj; object){
        obj.draw;
      }
      glFinish();
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
  public DataTable!(string, Character) charaData;
  public DataTable!(string, SDL_Surface*) surfaceData;
  public RenderEvent renderEvent;

  void initRenderEvent(){
    objectID = new IDTable!DrawableObject();
    charaData = new DataTable!(string, Character)();
    surfaceData = new DataTable!(string, SDL_Surface*)();
    renderEvent = new RenderEvent(this);
  }
}

class RenderEvent{
  private Renderer rendrerer;
  EventQueue!int eventQueue;
public:
  this(Renderer r){
    rendrerer = r;
  }
  void event(){
    if(eventQueue.length > 0){
      auto e = eventQueue.dequeue;
      switch(e.event){
        case RENDER_EVENT.TEST:
          enforce(e.type == EVENT_DATA.STRING);
          e.str.log;
          break;
        default:
          break;
      }
    }
    return;
  }
  @property auto getInterface(){
    return new RenderEventInterface(this);
  }
}
class RenderEventInterface{
  private RenderEvent renderEvent;
  public this(RenderEvent r){
    renderEvent = r;
  }
  public void send(EventData e){
    renderEvent.eventQueue.enqueue(e);
  }
  public int data(){
    return renderEvent.eventQueue.data;
  }
}
