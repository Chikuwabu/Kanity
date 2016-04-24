module kanity.core;

import kanity.render;
import kanity.event;
import kanity.lua;
import kanity.control;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;
import std.experimental.logger;
import core.thread;

class Engine{
  //フィールド
private:
 public Renderer renderer;
 public Event event;

public:
  //コンストラクタとデコンストラクタ
  this(string config){
    info("Load a library \"SDL2\"."); DerelictSDL2.load;
    info("Load a library \"SDL_Image\"."); DerelictSDL2Image.load;

    DerelictGL.load;
    DerelictGL3.load;

    if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0) logf(LogLevel.fatal,"Failed initalization of \"SDL2\".\n%s", SDL_GetError());
    info("Success initalization of \"SDL2\".");
    if(IMG_Init(IMG_INIT_PNG) != IMG_INIT_PNG) logf(LogLevel.fatal,"Failed initalization of \"SDL_Image\".\n%s", IMG_GetError());
    info("Success initalization of \"SDL_Image\"");

    SDL_HINT_RENDER_DRIVER.SDL_SetHint("opengl");
    //初期化
    renderer = new Renderer();
    event = new Event();

    import std.file;
    try{
      loadConfig(config.readText);
    }catch{
      fatal("Failed to configuration");
    }
    info("Success to configuration");

    return;
  }
  ~this(){
    SDL_Quit();
    IMG_Quit();
  }

  int run(){
    auto TrenderAndEvent = new LowLayer(renderer, event);
    TrenderAndEvent.start;

    TrenderAndEvent.join;
    return 0;
  }
  private void loadConfig(string jsonText){
    //jsonText.log;
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
  }
}

//低レイヤ処理を行うスレッド
class LowLayer : Thread {
  private bool running;

  this(Renderer renderer, Event event){
    running = true;
    super(() => run(renderer, event));
  }

  void run(Renderer renderer, Event event){
    renderer.init();
    event.init();
    Control control = new Control();
    control.run(renderer, event, this);
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
  }

  void stop(){
    running = false;
  }
}
