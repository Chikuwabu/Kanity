module kanity.input;

import kanity.imports;
import derelict.sdl2.sdl;

class Input{
  import std.container;
  //private InputEvent inputEvent;
  private SDL_Joystick* joystick;

  private MultiCastableDelegate!Button[int] keyButton;
  private MultiCastableDelegate!Button[int] controllerButton;
  private MultiCastableDelegate!Stick stick;
  private MultiCastableDelegate!Keyboard keyboard;
  private MultiCastableDelegate!Controller joyButton, joyAxis;

  this(){
    //inputEvent = new InputEvent();
    hatInit();
    if(SDL_NumJoysticks() > 0){
      joystick = SDL_JoystickOpen(0);
      enforce(joystick !is null);
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

    import std.array;
    //auto buttons = ["up", "down", "right", "left"].map!(a => new Button(a)).array;
    auto buttons = [-1, -2, -3, -4].map!(a => new Button(a)).array;
    buttons.each!(a => bind(a));
    auto kelp = new CombindButton(buttons);
    kelp.event += (a, b){
      (["up", "down", "right", "left"][a] ~ " " ~ (b ? "press" : "release")).log;
    };

    auto c = new Controller(Controller.Type.Axis);
    c.event += (a){
      //a.log;
    };
    bind(c);

    auto b = new Button(0);
    b.event += (a){
      (a ? "press" : "release").log;
    };
    bind(b);

    auto s = new Stick(0, 1);
    s.event += (a, b){
      (a.to!string ~","~b.to!string).log;
    };
    bind(s);
  }

  void end(){
    stick[].filter!(a => a.update).each!((f){
      f();
    });
  }
  void key(SDL_KeyboardEvent e){
    if(e.type == SDL_KEYDOWN){
      keyboard(SDL_GetKeyName(e.keysym.sym).to!string);
    }
    if(e.repeat) return;
    if(e.keysym.sym !in keyButton) return;

    keyButton[e.keysym.sym](e.state == SDL_PRESSED);

  }
  void button(SDL_JoyButtonEvent e){
    if(e.state == SDL_PRESSED){
      joyButton(e.button);
    }
    if(e.button !in controllerButton) return;

    controllerButton[e.button](e.state == SDL_PRESSED);
  }
  private bool[4] hatStateOld;
  private bool[4][int] hatStateList;
  void hat(SDL_JoyHatEvent e){
    bool[4] state = hatStateList[e.value];
    auto r = zip(state[], hatStateOld[]).enumerate(1).filter!(a => a.value[0] != a.value[1]).map!(a => tuple(-a.index, a.value[0]));

    //押された時のみjoyButton
    r.filter!(a => a[1]).each!((a){
      joyButton(a[0]);
    });

    //変化したらButton
    r.each!((a){
      controllerButton[a[0]](a[1]);
    });

    hatStateOld = state;
  }
  void hatInit(){
    //Up, Down, Right, Leftの順
    hatStateList[SDL_HAT_LEFTUP] = [1, 0, 0, 1];
    hatStateList[SDL_HAT_UP] = [1, 0, 0, 0];
    hatStateList[SDL_HAT_RIGHTUP] = [1, 0, 1, 0];
    hatStateList[SDL_HAT_LEFT] = [0, 0, 0, 1];
    hatStateList[SDL_HAT_CENTERED] = [0, 0, 0, 0];
    hatStateList[SDL_HAT_RIGHT] = [0, 0, 1, 0];
    hatStateList[SDL_HAT_LEFTDOWN] = [0, 1, 0, 1];
    hatStateList[SDL_HAT_DOWN] = [0, 1, 0, 0];
    hatStateList[SDL_HAT_RIGHTDOWN] = [0, 1, 1, 0];
    hatStateList.rehash;
  }
  void stickAxis(SDL_JoyAxisEvent e){
    if(e.axis >= 4) return; //5軸以上は処理しない
    joyAxis(e.axis);

    auto r = stick[];
    //TODO:こういう操作よくない
    r.filter!(a => a.xAxis == e.axis).each!((f){
      f.setX(e.value.to!real / 32768);
      f.update = true;
    });
    r.filter!(a => a.yAxis == e.axis).each!((f){
      f.setY(e.value.to!real / 32768);
      f.update = true;
    });
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
      case Button.Type.Controller:
        if(bt.buttonId !in controllerButton){
          MultiCastableDelegate!Button a;
          controllerButton[bt.buttonId] = a;
          controllerButton.rehash;
        }
        controllerButton[bt.buttonId] += bt;
        break;
      default:
    }
  }
  public void unbind(Button bt){
    switch(bt.type){
      case Button.Type.Key:
        keyButton[bt.keycode] -= bt;
        break;
      case Button.Type.Controller:
        controllerButton[bt.buttonId] -= bt;
        break;
      default:
    }
  }
  public void bind(Stick st){
    switch(st.type){
      case Stick.Type.Real:
        stick += st;
        break;
      default:
    }
  }
  public void unbind(Stick st){
    switch(st.type){
      case Stick.Type.Real:
        stick -= st;
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
  public void bind(Controller c){
    switch(c.type){
      case Controller.Type.Button:
        joyButton += c;
        break;
      case Controller.Type.Axis:
        joyAxis += c;
        break;
      default:
    }
  }
  public void unbind(Controller c){
    switch(c.type){
      case Controller.Type.Button:
        joyButton -= c;
        break;
      case Controller.Type.Axis:
        joyAxis -= c;
        break;
      default:
    }
  }

}

class Button{
  alias EventFunc = void delegate(bool); //押されているか
  alias Event = MultiCastableDelegate!EventFunc;
  enum Type{Key, Controller};

  private Type type_;
  @property auto type(){return type_;}
  union{
    SDL_Keycode keycode;
    int buttonId;
  }
  public Event event;

  this(string keyName){
    type_ = Type.Key;
    import std.string: toStringz;
    keycode = SDL_GetKeyFromName(keyName.toStringz);
    errorf(keycode == SDLK_UNKNOWN, "KeyName '%s' is not available.", keyName);
  }
  this(int buttonId_){
    type_ = Type.Controller;
    buttonId = buttonId_;
  }

  void opCall(bool state){
    event(state);
  }
}
class CombindButton{
  alias EventFunc = void delegate(int, bool); //何番の変化か、状態
  alias Event = MultiCastableDelegate!EventFunc;

  public Event event;
  alias ButtonTuple = Tuple!(Button, "value", Button.EventFunc, "dg");
  private ButtonTuple[int] button;

  this(Button[] btn...){
    btn.enumerate(0).each!((a){
      this.bind(a.value, a.index);
    });
  }

  void bind(Button bt, int num){
    ButtonTuple a;
    auto dg = (bool b) => opCall(num, b);
    bt.event += dg;
    a.dg = dg;
    a.value = bt;
    button[num] = a;
    button.rehash;
  }

  void unbind(int num){
    if(num !in button) return;

    auto a = button[num];
    a.value.event -= a.dg;
    button.remove(num);
    button.rehash;
  }

  void unbind(Button bt){
    auto n = button.byKeyValue.filter!(a => a.value.value == bt).map!(a => a.key);
    n.each!(a => unbind(a));
  }

  void opCall(int num, bool state){
    event(num, state);
  }
}
class Stick{
  alias EventFunc = void delegate(real, real); //x, y軸
  alias Event = MultiCastableDelegate!EventFunc;
  enum Type{Real, Virtual}; //物理スティックか、CombinedButtonをバインドするか

  public Event event;
  private Type type_;
  @property auto type(){return type_;}
  union{
    struct{
      int xAxis, yAxis;
      real xPos = 0.0, yPos = 0.0;
      bool update;
    }
  }

  this(int x, int y){ //軸番号指定
    xAxis = x; yAxis = y;
  }

  void opCall(real x, real y){
    event(x, y);
    update = false;
  }
  void opCall(){
    event(xPos, yPos);
    update = false;
  }

  void setX(real x){
    xPos = x;
  }
  void setY(real y){
    yPos = y;
  }
}
class Keyboard{
  alias EventFunc = void delegate(string); //押されている文字
  alias Event = MultiCastableDelegate!EventFunc;

  public Event event;

  void opCall(string input){
    event(input);
  }
}
class Controller{
  alias EventFunc = void delegate(int); //データ
  alias Event = MultiCastableDelegate!EventFunc;
  enum Type{Button, Axis};

  public Event event;
  private Type type_;
  @property auto type(){return type_;}

  this(Type t = Type.Button){
    type_ = t;
  }

  void opCall(int data){
    event(data);
  }
}
