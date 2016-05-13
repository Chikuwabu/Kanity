module kanity.events.render;

import kanity.imports;
import kanity.render;
import kanity.sprite;
import kanity.bg;
import kanity.text;

class RenderEventInterface{
  import std.container;
  private RenderEvent renderEvent;
  private Queue!(DList!(EventData*)) tempQueue; //まとめて送る前に貯めておく
public:
  this(RenderEvent r){
    renderEvent = r;
    tempQueue.init;
  }
  void send(EventData* e){
    synchronized renderEvent.eventQueue.enqueue(*e);
  }
  void flush(){
    //実際は作業が完了するのを待つだけ
    bool flag = true;
    this.event_flush((){flag = false;});
    while(flag){}
  }
  //ラッパー関数を自動で生成する
  mixin(wrapperGenerator!RenderEvent());

  private static string wrapperGenerator(T)(){
    import std.string;
    string o;
    foreach(i; __traits(allMembers, T)){
      if(i.indexOf("event_") == 0){
        o ~= "void "~i~"(Args...)(Args args){
          send(new EventData((){renderEvent."~i~"(args);}));
          }";
      }
    }
    return o;
  }
}

enum ObjectType{Sprite, BG, }
class RenderEvent{
  import core.sync.mutex;
  private Renderer renderer;
  public EventQueue!int eventQueue;
public:
  this(Renderer r){
    renderer = r;
    eventQueue.init;
  }
  void event(){
    if(eventQueue.length == 0) return;
    foreach(EventData e; eventQueue[]){
      enforce(e.func != null);
      e.func();
    }
    if(eventQueue.callback != null) eventQueue.callback();
    return;
  }
  @property auto getInterface(){
    return new RenderEventInterface(this);
  }
  void event_flush(void delegate() callback){
    callback();
  }
  void event_log(string s){
    s.trace;
  }
  void event_surface_load(string name){
    import derelict.sdl2.image, derelict.sdl2.sdl;
    renderer.surfaceData.add(name, IMG_Load_RW(FileSystem.loadRW(name), 1));
  }
  void event_surface_unload(string name){
    renderer.surfaceData.remove(name);
  }

  void event_character_new(string surface, void delegate(int) callback){
    auto n = renderer.charaID.add(new Character(renderer.surfaceData.get(surface), surface));
    callback(n);
  }
  void event_character_delete(int id){
    auto c = renderer.charaID.get(id);
    renderer.surfaceData.remove(c.surfaceName);
    renderer.charaID.remove(id);
  }
  void event_character_set_cutRect(int id, int w, int h){
    auto c = renderer.charaID.get(id);
    c.chipWidth = w; c.chipHeight = h;
  }
  void event_character_set_scanAxis(int id, Character_ScanAxis scan){
    auto c = renderer.charaID.get(id);
    c.scanAxis = scan;
  }
  void event_character_cut(int id){
    renderer.charaID.get(id).cut;
  }
  void event_character_add(int id, int num, int x, int y, int w, int h){
    renderer.charaID.get(id).add(num, x, y, w, h);
  }
  void event_character_add(int id, int num, int x, int y){
    renderer.charaID.get(id).add(num, x, y);
  }
  void event_character_add(int id, string s, int x, int y, int w, int h){
    renderer.charaID.get(id).add(s, x, y, w, h);
  }
  void event_character_add(int id, string s, int x, int y){
    renderer.charaID.get(id).add(s, x, y);
  }

  void event_object_new(ObjectType type, int characterID, void delegate(int) callback){
    auto character = renderer.charaID.get(characterID);
    DrawableObject obj;
    switch(type){
      case ObjectType.Sprite:
        obj = new Sprite(character);
        break;
      case ObjectType.BG:
        obj = new BG(character);
        break;
      default:
        break;
    }
    renderer.addObject(obj);
    auto id = renderer.objectID.add(obj);
    callback(id);
  }
  void event_object_show(int id){
    renderer.objectID.get(id).show;
  }
  void event_object_hide(int id){
    renderer.objectID.get(id).hide;
  }
  void event_object_move(int id, int x, int y){
    renderer.objectID.get(id).move(x, y);
  }
  void event_object_setHome(int id, int x, int y){
    renderer.objectID.get(id).setHome(x, y);
  }
  void event_object_setScale(int id, real scale){
    renderer.objectID.get(id).scale = scale;
  }
  void event_object_setAngleDeg(int id, real deg){
    renderer.objectID.get(id).angleDeg = deg;
  }
  void event_object_setAngleRad(int id, real rad){
    renderer.objectID.get(id).angleRad = rad;
  }
  void event_object_setPriority(int id, int p){
    renderer.objectID.get(id).priority = p;
  }

  void event_sprite_setCharacterNum(int id, int chara){
    auto s = cast(Sprite)(renderer.objectID.get(id));
    s.character = chara;
  }
  void event_sprite_setCharacterStr(int id, string chara){
    auto s = cast(Sprite)(renderer.objectID.get(id));
    s.character = chara;
  }

  void event_bg_setMapData(int id, int[][] data){
    auto b = cast(BG)(renderer.objectID.get(id));
    b.mapData = data;
  }

}
