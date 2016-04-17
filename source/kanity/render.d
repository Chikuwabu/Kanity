module kanity.render;

import kanity.bg;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;
import derelict.opengl3.gl;
import std.experimental.logger;
import std.string;

class Renderer{
  //フィールド
private:
  SDL_Window* window_;
  SDL_Renderer* renderer;
  SDL_GLContext context;
  BG[] bgList;
  bool drawFlag;

public:
  this(){
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
    window_ = createWindow(title, width, height);
    if(window_ == null) logf(LogLevel.fatal, "Failed to create window.\n%s", SDL_GetError());
    info("Success to create window.");

    context = window.SDL_GL_CreateContext;

    /*renderer = window_.SDL_CreateRenderer( -1, 0 );
    if(renderer == null) logf(LogLevel.fatal, "Failed to create renderer.\n%s", SDL_GetError());
    info("Success to create renderer.");*/
    //renderer.SDL_SetRenderDrawColor(255, 255, 255, 255);

    //auto mapchip = IMG_Load("BGTest2.png");
    //auto tex = renderer.SDL_CreateTextureFromSurface(window_.SDL_GetWindowSurface);
    //renderer.SDL_RenderCopy(tex, null, null);
    window_.SDL_ShowWindow;

    //auto bg1 = new BG(window_, 0, 0, mapchip);
    bgList = new BG[1];
    //bgList[0] = bg1;

    drawFlag = true;
  }
  void render(){
    if(drawFlag){
      //renderer.SDL_RenderClear;
      //glClearColor(255,255,255,1);
      glClear(GL_COLOR_BUFFER_BIT);

      glBegin(GL_TRIANGLES);
        glVertex2f(0 , 0);
        glVertex2f(-1 , 1);
        glVertex2f(1 , 1);

        glVertex2f(0 , 0);
        glVertex2f(-1 , -1);
        glVertex2f(1 , -1);
      glEnd();
      glFinish();
      /+foreach(b; bgList)
      {
        //b.draw();
      }+/
      //renderer.SDL_RenderPresent;
      window_.SDL_GL_SwapWindow;
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
}
