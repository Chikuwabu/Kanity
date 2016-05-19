module kanity.input;

import kanity.imports;
import derelict.sdl2.sdl;

class Input{
  import std.container;
  //private InputEvent inputEvent;
  private SDL_Joystick* controller;

  private MultiCastableDelegate!Button[int] keyButton;
  private MultiCastableDelegate!Keyboard keyboard;

  this(){
    //inputEvent = new InputEvent();
    if(SDL_NumJoysticks() > 0){
      controller = SDL_JoystickOpen(0);
      enforce(controller !is null);
    }
    auto test = new Button("a");
    test.event += (a){
      (a ? "press" : "release").log;
    };
    bind(test);

    auto key = new Keyboard();
    key.event += (a){
      a.log;
    };
    bind(key);
  }

  void key(SDL_KeyboardEvent e){
    if(e.type == SDL_KEYDOWN){
      keyboard(SDL_GetKeyName(e.keysym.sym).to!string);
    }
    if(e.repeat) return;
    if(e.keysym.sym !in keyButton) return;

    keyButton[e.keysym.sym](e.state == SDL_PRESSED);

  }
  void button(SDL_Event e){
    "button".log;
  }
  void stickAxis(SDL_Event e){

  }

  public void bind(Button bt){
    switch(bt.type){
      case Button.Type.Key:
        if(bt.keycode !in keyButton){
          MultiCastableDelegate!Button a;
          keyButton[bt.keycode] = a;
          keyButton.rehash;
        }
        keyButton[bt.keycode] += bt;
        break;
      default:
    }
  }
  public void unbind(Button bt){
    switch(bt.type){
      case Button.Type.Key:
        keyButton[bt.keycode] -= bt;
        break;
      default:
    }
  }
  public void bind(Keyboard kb){
    keyboard += kb;
  }
  public void unbind(Keyboard kb){
    keyboard -= kb;
  }

}
alias ButtonEventFunc = void delegate(bool); //押されているか
alias ButtonEvent = MultiCastableDelegate!(ButtonEventFunc);
class Button{
  enum Type{Key, Controller};

  private Type type_;
  @property auto type(){return type_;}
  union{
    SDL_Keycode keycode;
  }
  public ButtonEvent event;

  this(string keyName){
    type_ = Type.Key;
    import std.string: toStringz;
    keycode = SDL_GetKeyFromName(keyName.toStringz);
    errorf(keycode == SDLK_UNKNOWN, "KeyName '%s' is not available.", keyName);
  }

  void opCall(bool state){
    event(state);
  }
}
alias KeyboardEventFunc = void delegate(string); //押されている文字
alias KeyboardEvent = MultiCastableDelegate!KeyboardEventFunc;
class Keyboard{
  public KeyboardEvent event;

  void opCall(string input){
    event(input);
  }
}
