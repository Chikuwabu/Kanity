module kanity.core;

import kanity.imports;
import kanity.render;
import kanity.event;
import kanity.lua;
import kanity.control;
import kanity.file;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import derelict.opengl3.gl;
import std.stdio;
import std.file;
import kanity.logger;

class Engine{
  //フィールド
protected:
 Renderer renderer;
 Event event;
 Control control;
 MultiLogger logger;

public:
  //コンストラクタとデコンストラクタ
  this(string config, string logfile){
    //Loggerの初期化
    logger = new MultiLogger();
    sharedLog = logger;
    //デバッグモードならば標準エラー出力にログを出力する
    debug{
      logger.insertLogger("debug", new KaniLogger(stderr));
    }
    if(logfile != ""){
      auto f = File(logfile, "w");
      logger.insertLogger("log", new KaniLogger(f, LogLevel.trace));
    }
    //ファイルシステムの初期化
    FileSystem = new FileFileObject("resources");

    //初期化
    renderer = new Renderer();
    event = new Event();
    control = new Control();

    try{
      loadConfig(FileSystem.loadString(config));
    }catch{
      fatal("Failed to configuration");
    }
    info("Success to configuration");

    info("Load the library \"SDL2\"."); DerelictSDL2.load;
    info("Load the library \"SDL_Image\"."); DerelictSDL2Image.load;
    info("Load the library \"SDL_ttf\"."); DerelictSDL2ttf.load;

    info("Load the library \"OpenGL\"."); DerelictGL.load;
    info("Load the library \"OpenGL3\"."); DerelictGL3.load;

    const int sdlInitFlag = SDL_INIT_VIDEO | SDL_INIT_EVENTS;
    const int sdlImageInitFlag = IMG_INIT_PNG | IMG_INIT_JPG;
    if(SDL_Init(sdlInitFlag) != 0) logf(LogLevel.fatal,"Failed initalization of \"SDL2\".\n%.*s", SDL_GetError());
    info("Success initalization of \"SDL2\".");
    if(IMG_Init(sdlImageInitFlag) != sdlImageInitFlag) logf(LogLevel.fatal,"Failed initalization of \"SDL_Image\".\n%.*s", IMG_GetError());
    info("Success initalization of \"SDL_Image\"");
    if(TTF_Init() != 0) logf(LogLevel.fatal, "Failed initalization of \"SDL_ttf\".\n%.*s", TTF_GetError());
    info("Success initalization of \"SDL_ttf\"");

    SDL_HINT_RENDER_DRIVER.SDL_SetHint("opengl");

    return;
  }
  ~this(){
    SDL_Quit();
    IMG_Quit();
  }

  protected void init()
  {
    renderer.init();
    event.init();
  }

  int run(){
      init();
      control.run(renderer, event);
      auto frame1 = 1000 / 60;
      do
      {
          auto start = cast(long)SDL_GetTicks;
          renderer.render();
          event.process();

          auto end = cast(long)SDL_GetTicks;
          if (end - start < frame1)
          {
              SDL_Delay(cast(uint)(frame1 - end + start));
          }
      } while(event.isRunning);
      return 0;
  }
  private void loadConfig(string jsonText){
    import std.json;
    import std.exception;
    JSONValue root = parseJSON(jsonText);
    //ウインドウ関係
    if("window" in root.object){
      JSONValue window = root["window"];
      //幅:整数;
      if("width" in window.object){
        enforce(window.object["width"].type == JSON_TYPE.INTEGER);
        renderer.windowWidth = cast(uint)window.object["width"].integer;
      }
      //高さ:整数
      if("height" in window.object){
        enforce(window.object["height"].type == JSON_TYPE.INTEGER);
        renderer.windowHeight = cast(uint)window.object["height"].integer;
      }
      //タイトル:文字列
      if("title" in window.object){
        enforce(window.object["title"].type == JSON_TYPE.STRING);
        renderer.title = window.object["title"].str;
      }
      //フルスクリーンフラグ:BOOL
      if("fullscreen" in window.object){
        enforce(window.object["fullscreen"].type == JSON_TYPE.TRUE || window.object["fullscreen"].type == JSON_TYPE.FALSE);
        renderer.isFullScreen = window.object["fullscreen"].type == JSON_TYPE.TRUE ? true : false;
      }
    }
    //BG関係
    if("BG" in root.object){
      JSONValue bg = root.object["BG"];
      //幅:整数
      if("width" in bg.object){
        enforce(bg.object["width"].type == JSON_TYPE.INTEGER);
        renderer.bgSizeWidth = cast(uint)bg.object["width"].integer;
      }
      //高さ:整数
      if("height" in bg.object){
        enforce(bg.object["height"].type == JSON_TYPE.INTEGER);
        renderer.bgSizeHeight = cast(uint)bg.object["height"].integer;
      }
      //チップの大きさ:整数
      if("chipSize" in bg.object){
        enforce(bg.object["chipSize"].type == JSON_TYPE.INTEGER);
        renderer.bgChipSize = cast(uint)bg.object["chipSize"].integer;
      }
    }
    //その他
    //拡大率:整数,実数
    if("renderScale" in root.object){
      switch(root.object["renderScale"].type){
        case JSON_TYPE.INTEGER:
          renderer.renderScale = cast(float)root.object["renderScale"].integer;
          break;
        case JSON_TYPE.FLOAT:
          renderer.renderScale = cast(float)root.object["renderScale"].floating;
          break;
        default:
          enforce(0);
          break;
      }
    }
    //起動時に呼ばれるスクリプト:文字列
    if("startScript" in root.object){
      enforce(root.object["startScript"].type == JSON_TYPE.STRING);
      control.startScript = root.object["startScript"].str;
    }
    //デバッグモード:BOOL
    if("debugMode" in root.object){
      enforce(root.object["debugMode"].type == JSON_TYPE.TRUE || root.object["debugMode"].type == JSON_TYPE.FALSE);
      if(root.object["debugMode"].type == JSON_TYPE.TRUE){
        bool flag = true;
        debug{flag = false;}
        if(flag){
          import std.stdio;
          logger.insertLogger("debug", new KaniLogger(stderr, LogLevel.trace));
        }
      }
    }
  }
}
