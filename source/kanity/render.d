module kanity.render;

import kanity.object;
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
      glEnable(GL_DEPTH_TEST);
      //glClear(GL_COLOR_BUFFER_BIT);
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity();
      glOrtho(-1, 1, -1, 1, 0, 4);


      glBegin(GL_TRIANGLES);
        glVertex3f(0, 0, 0);
        glVertex3f(-1, 1, 0);
        glVertex3f(1, 1, 0);

        glVertex3f(0, 0, -3);
        glVertex3f(-1, -1, -3);
        glVertex3f(1, -1, -3);
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

  void glSetup(){

  }
}
