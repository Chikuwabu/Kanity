module kanity.events.render;

import kanity.imports;
import kanity.render;
import kanity.sprite;
import kanity.bg;
import kanity.text;

class RenderEventInterface{
  import std.container;
  private RenderEvent renderEvent;
  private Renderer renderer;
  private Queue!(DList!(EventData*)) tempQueue; //まとめて送る前に貯めておく
public:
  this(RenderEvent re, Renderer r){
    renderEvent = re;
    renderer = r;
    tempQueue.init;
  }
  void send(EventData* e){
    synchronized renderEvent.eventQueue.enqueue(*e);
  }
  void flush(){
    "flush".log;
    //実際は作業が完了するのを待つだけ
    bool flag = false;
    event_flush((){flag = true;});
    while(!flag){}
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
  //メッセージ送信するまでもないイベント
  void event_log(string s){
    s.trace;
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

  void event_object_show(int id){
    renderer.objectID.get(id).show;
  }
  void event_object_hide(int id){
    renderer.objectID.get(id).hide;
  }
  bool event_object_isVisible(int id){
    return renderer.objectID.get(id).isVisible;
  }
  void event_object_moveRelative(int id, int x, int y){
    renderer.objectID.get(id).moveRelative(x, y);
  }
  void event_object_setPos(int id, int x, int y){
    auto o = renderer.objectID.get(id);
    o.posX = x; o.posY = y;
  }
  auto event_object_getPos(int id){
    auto o = renderer.objectID.get(id);
    return tuple(o.posX, o.posY);
  }
  void event_object_setHome(int id, int x, int y){
    renderer.objectID.get(id).setHome(x, y);
  }
  auto event_object_getHome(int id){
    auto o = renderer.objectID.get(id);
    return tuple(o.homeX, o.homeY);
  }
  void event_object_setScale(int id, real scale){
    renderer.objectID.get(id).scale = scale;
  }
  auto event_object_getScale(int id){
    return renderer.objectID.get(id).scale;
  }
  void event_object_setAngleDeg(int id, real deg){
    renderer.objectID.get(id).angleDeg = deg;
  }
  auto event_object_getAngleDeg(int id){
    return renderer.objectID.get(id).angleDeg;
  }
  void event_object_setAngleRad(int id, real rad){
    renderer.objectID.get(id).angleRad = rad;
  }
  auto event_object_getAngleRad(int id){
    return renderer.objectID.get(id).angleRad;
  }
  void event_object_setPriority(int id, int p){
    renderer.objectID.get(id).priority = p;
  }
  auto event_object_getPriority(int id){
    return renderer.objectID.get(id).priority;
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

  void event_text_setText(int id, string text){
    auto t = cast(Text)(renderer.objectID.get(id));
    t.text = text;
  }
}

enum ObjectType{Sprite, BG, Text, }
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
    return new RenderEventInterface(this, renderer);
  }
  void event_flush(void delegate() callback){
    callback();
  }

  void event_surface_load(string name){
    import derelict.sdl2.image, derelict.sdl2.sdl;
    renderer.surfaceData.add(name, IMG_Load_RW(FileSystem.loadRW(name), 1));
  }
  void event_surface_unload(string name){
    renderer.surfaceData.remove(name);
  }

  void event_font_load(string name, int size){
    import derelict.sdl2.sdl, derelict.sdl2.ttf;
    renderer.fontData.add(name, TTF_OpenFontRW(FileSystem.loadRW(name), 1, size));
  }
  void event_font_unload(string name){
    renderer.fontData.remove(name);
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
  void event_object_new(ObjectType type, string data, void delegate(int) callback){
    DrawableObject obj;
    switch(type){
      case ObjectType.Text:
        obj = new Text(renderer.fontData.get(data), data);
        break;
      default:
        break;
    }
    renderer.addObject(obj);
    auto id = renderer.objectID.add(obj);
    callback(id);
  }

}
