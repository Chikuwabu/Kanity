module kanity.events.render;

import kanity.imports;
import kanity.render;
import kanity.sprite;

class RenderEventInterface{
  import std.container;
  private RenderEvent renderEvent;
  private Queue!(DList!(EventData*)) tempQueue; //まとめて送る前に貯めておく
public:
  this(RenderEvent r){
    renderEvent = r;
    tempQueue.init;
  }
  void add(EventData* e){
    tempQueue.enqueue(e);
  }
  void send(EventData* e){
    synchronized renderEvent.eventQueue.enqueue(*e);
  }
  void send(EventData e){
    send(&e);
  }
  auto data(){
    auto a = renderEvent.eventQueue.data;
    return a;
  }
  void send(){
    synchronized{
      foreach(EventData* e; tempQueue){
        renderEvent.eventQueue.enqueue(*e);
      }
    }
  }
  void flush(){
    //実際は作業が完了するのを待つだけ
    synchronized{
      bool flag = true;
      renderEvent.eventQueue.callback = (){flag = false;};
      while(flag){}
      renderEvent.eventQueue.callback = null;
    }
  }
  void event_log(string s){
    EventData e;
    e.func = (){renderEvent.event_log(s);};
    send(e);
  }
}

enum OBJECTTYPE{SPRITE, BG}
class RenderEvent{
  import core.sync.mutex;
  private Renderer renderer;
  private int callbackData;
  private void delegate(EventData)[int] funcs;
  public EventQueue!int eventQueue;
public:
  this(Renderer r){
    renderer = r;
    /*funcs[RENDER_EVENT.LOG] = &event_log;

    funcs[RENDER_EVENT.SURFACE_LOAD] = &event_loadSurface;
    funcs[RENDER_EVENT.SURFACE_UNLOAD] = &event_unloadSurface;

    funcs[RENDER_EVENT.CHARACTER_NEW] = &event_newCharacter;
    funcs[RENDER_EVENT.CHARACTER_DELETE] = &event_deleteCharacter;
    funcs[RENDER_EVENT.CHARACTER_SET_CUTRECT] = &event_character_set_cutrect;
    funcs[RENDER_EVENT.CHARACTER_SET_SCANAXIS] = &event_character_set_scanAxis;
    funcs[RENDER_EVENT.CHARACTER_CUT] = &event_character_cut;

    funcs[RENDER_EVENT.OBJECT_NEW] = &event_object_new;*/

    funcs.rehash;
    eventQueue.init;
  }
  void event(){
    if(eventQueue.length == 0) return;
    foreach(EventData e; eventQueue[]){
      enforce(e.event <= RENDER_EVENT.max);
      //funcs[e.event](e);
      e.func();
      if(e.callback != null){
        e.callback(callbackData);
      }
    }
    if(eventQueue.callback != null) eventQueue.callback();
    return;
  }
  @property auto getInterface(){
    return new RenderEventInterface(this);
  }
private:
  void callbackData()
  void event_log(string s){
    s.log;
  }
  /*void event_log(EventData e){
    enforce(e.type == EVENT_DATA.STRING);
    e.str.log;
  }
  void event_loadSurface(EventData e){
    enforce(e.type == EVENT_DATA.STRING);
    auto name = e.str;
    import std.string;
    import derelict.sdl2.image;
    renderer.surfaceData.add(name, IMG_Load(name.toStringz));
  }
  void event_unloadSurface(EventData e){
    enforce(e.type == EVENT_DATA.STRING);
    renderer.surfaceData.remove(e.str);
  }
  void event_newCharacter(EventData e){
    enforce(e.type == EVENT_DATA.STRING);
    auto n = renderer.charaID.add(new Character(renderer.surfaceData.get(e.str), e.str));
    eventQueue.data = n;
  }
  void event_deleteCharacter(EventData e){
    enforce(e.type == EVENT_DATA.NUMBER);
    auto c = renderer.charaID.get(e.number);
    renderer.surfaceData.remove(c.surfaceName);
    renderer.charaID.remove(e.number);
  }
  void event_character_set_cutrect(EventData e){
    enforce(e.type == EVENT_DATA.NUMBER);
    auto c = renderer.charaID.get(e.number);
    e.clear;
    e = eventQueue.dequeue;
    enforce(e.type == EVENT_DATA.POS);
    c.chipWidth = e.posX; c.chipHeight = e.posY;
  }
  void event_character_set_scanAxis(EventData e){
    enforce(e.type == EVENT_DATA.NUMBER);
    auto c = renderer.charaID.get(e.number);
    e.clear;
    e = eventQueue.dequeue;
    enforce(e.type == EVENT_DATA.NUMBER);
    c.scanAxis = cast(CHARACTER_SCANAXIS)e.number;
  }
  void event_character_cut(EventData e){
    enforce(e.type == EVENT_DATA.NUMBER);
    auto c = renderer.charaID.get(e.number);
    c.cut;
  }
  void event_object_new(EventData e){
    enforce(e.type == EVENT_DATA.NUMBER);
    DrawableObject obj;
    switch(e.number){
      case OBJECTTYPE.SPRITE:
        "Create Sprite".log;
        e.clear;
        e = eventQueue.dequeue;
        enforce(e.type == EVENT_DATA.NUMBER);
        auto chara = renderer.charaID.get(e.number);
        auto sp = new Sprite(chara);
        renderer.addObject(sp);
        auto id = renderer.objectID.add(sp);
        eventQueue.data = id;
        break;
      case OBJECTTYPE.BG:
        "Create BG".log;
        break;
      default:
        enforce(0);
        break;
    }
  }*/
  void doCallback(){
    if(eventQueue.callback != null){
      eventQueue.callback();
    }
  }
}
