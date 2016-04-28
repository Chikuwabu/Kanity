module kanity.utils;
import std.container;
import std.exception;

//勝手に管理してID振ってくれるやつ
struct IDTable(T){
  private T[] data_;
  private uint count = 0;
  private SList!uint unused;
  public void delegate(T) deleteFunc = (T a) => (delete a);
public:
  this(uint n = 1){
    data_.length = n;
  }
  uint add(T data){
    if(unused.walkLength > 0){
      //すき間があるならそちらに入れる
      auto a = unused.removeAny;
    }else{
      //ないなら領域を増やす
      auto a = count++;
      if(count >= data_.length){
        //メモリが足りなくなったら多めに確保する
        data_.length = data_.length * 2;
      }
    }
    data_[a] = data;
    return a;
  }
  void remove(uint a){
    data_[a].deleteFunc;
    unused.insertFront(a);
  }
  void set(uint a, T data){ data_[a] = data; }
  T get(uint a){ return data_[a]; }
}
//参照カウントして開放
struct DataTable(TKey, TData){
  private TData[TKey] data;
  private uint[TKey] count;
  public void delegate(TData) deleteFunc = (TData a) => (delete a);

  public void add(TKey key, TData data_){
    if(data !in key) data[key] = data_;
    count[key]++;
  }
  public void remove(TKey key){
    enforce(data in key);
    data[key].count--;
    if(data[key].count <= 0){
      data[key].data.deleteFunc;
      data[key].remove;
    }
  }
  alias get = this;
  @property auto get = (() => (data));
}
//イベントキュー
import std.variant;
enum EVENT_DATA{ NONE, NUMBER, STRING, FLOATER, POS, VECTOR}
struct EventQueue(TEvent){
  struct Pos{int x; int y;}
  struct Vector{float x; float y;}
  struct EventX(T){
    T event;
    alias event = this;
    private EVENT_DATA type_ = EVENT_DATA.NONE;
    private union{
      int number_;
      string str_;
      float floater_;
      Pos pos_;
      Vector vector_;
    }
  public:
    @property{
      auto type = () => (type_);
      auto type(auto t){
        enforce(type_ == EVENT_DATA.NONE);
        type_ = t;
      }
      mixin(property("number", "number_", "number"));
      mixin(property("str", "str_", "string"));
      mixin(property("floater", "floater_", "floater"));
      mixin(property("posX", "pos_.x", "Pos"));
      mixin(property("posY", "pos_.y", "Pos"));
      mixin(property("vectorX", "vector_.x", "Vector"));
      mixin(property("vectorY", "vector_.y", "Vector"));
    }
    private string property(string method, string target, string type){
      import std.string;
      return "auto "~method~"(){enforce(type_ == EVENT_DATA."~type.toupper~"); return "~target~";}\n"
            ~"auto "~method~"(auto a){enforce(type_ == EVENT_DATA."~type.toupper~"); "~target~" = a;}";
    }
  }
  alias Event = EventX!TEvent;
  private Queue!(DList!Event) queue;
  public void delegate(Variant) callback = null;
  public Event dequeue(){return queue.dequeue;}
  alias init = clear;
  public void clear(){queue.clear;}

  public void enqueue(EVENT_DATA e){
    Event ev = e;
    ev.type = EVENT_DATA.NONE;
    queue.enqueue(ev);
  }
  public void enqueue(EVENT_DATA e, int n){
    Event ev = e;
    ev.type = EVENT_DATA.NUMBER;
    ev.number = n;
    queue.enqueue(ev);
  }
  public void enqueue(EVENT_DATA e, string s){
    Event ev = e;
    ev.type = EVENT_DATA.STRING;
    ev.str = s;
    queue.enqueue(ev);
  }
  public void enqueue(EVENT_DATA e, float f){
    Event ev = e;
    ev.type = EVENT_DATA.FLOATER;
    ev.floater = f;
    queue.enqueue(ev);
  }
  public void enqueue(EVENT_DATA e, int x, int y){
    Event ev = e;
    ev.type = EVENT_DATA.POS;
    ev.posX = x; ev.posY = y;
    queue.enqueue(ev);
  }
  public void enqueue(EVENT_DATA e, float x, float y){
    Event ev = e;
    ev.type = EVENT_DATA.VECTOR;
    ev.vectorX = x; ev.vectorY = y;
    queue.enqueue(ev);
  }
}
//Adapters
import std.range;
struct Queue(T){
  static if(__traits(compiles, {T a; a.insertFront(1); auto b = a.back; a.removeBack;}) == false) static assert(0);

  private T queue;
  private uint count = 0;

  alias S = ElementType!T;
  public void enqueue(S a){
    queue.insertFront(a);
    count++;
  }
  public S dequeue(){
    enforce(count != 0);
    auto a = queue.back;
    queue.removeBack;
    count--;
    return a;
  }
  public void clear(){
    queue.clear;
    count = 0;
  }
  @property public uint length = () => count;
}
struct Stack(T){
  static if(__traits(compiles, {T a; a.insertFront(1); auto b = a.front; a.removeFront;}) == false) static assert(0);

  private T queue;
  private uint count = 0;

  alias S = ElementType!T;
  public void push(S a){
    queue.insertFront(a);
    count++;
  }
  public S pop(){
    enforce(count != 0);
    auto a = queue.front;
    queue.removeFront;
    count--;
    return a;
  }
  public void clear(){
    queue.clear;
    count = 0;
  }
  @property public uint length = () => count;
}
