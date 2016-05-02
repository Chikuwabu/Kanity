module kanity.events.utils;

import kanity.imports;
import std.container;

//イベントキュー
import std.variant;
enum EVENT_DATA{ NONE, NUMBER, STRING, FLOATER, POS, VECTOR}
struct EventQueue(T){
  import core.sync.mutex;
  alias E = EventData;
  private Queue!(DList!E) queue;
  public T data; //適当に情報つっこむ
  public void delegate() callback = null;
  public Mutex mutex; //スレッドを越えた処理のための排他制御

  public void enqueue(E a){
    while(!mutex.tryLock){}
    synchronized(mutex) queue.enqueue(a);
    mutex.unlock;
  }
  public E dequeue(){
    while(!mutex.tryLock){}
    auto a = queue.dequeue;
    mutex.unlock;
    return a;
  }
  public void init(){
    mutex = new Mutex();
    this.clear;
  }
  public void clear(){queue.clear;}
  @property public uint length(){return queue.length;}
  auto opSlice(){
    return Range(&queue, mutex);
  }
  struct Range{
    this(Queue!(DList!E)* queue, Mutex m){
      q = queue;
      mutex = m;
    }
    private Queue!(DList!E)* q;
    private Mutex mutex;
    @property public bool empty(){return (*q)[].empty;}
    @property public E front(){
      while(!this.mutex.tryLock){}
      auto a = (*q)[].front;
      mutex.unlock;
      return a;
    }
    public void popFront(){
      while(!mutex.tryLock){}
      (*q)[].popFront;
      mutex.unlock;
    }
  }
}
struct Pos{int x; int y;}
struct Vector{float x; float y;}
struct EventData{
  int event;
  //alias this event;
  private EVENT_DATA type_ = EVENT_DATA.NONE;
  private union{
    int number_;
    string str_;
    float floater_;
    Pos pos_;
    Vector vector_;
  }
public:
  this(int e){
    event = e;
  }
  this(int e, int n){
    this(e);
    type = EVENT_DATA.NUMBER;
    number = n;
  }
  this(int e, string s){
    this(e);
    type = EVENT_DATA.STRING;
    str = s;
  }
  this(int e, float f){
    this(e);
    type = EVENT_DATA.FLOATER;
    floater = f;
  }
  this(int e, int x, int y){
    this(e);
    type = EVENT_DATA.POS;
    posX = x; posY = y;
  }
  this(int e, float x, float y){
    this(e);
    type = EVENT_DATA.VECTOR;
    vectorX = x; vectorY = y;
  }
  @property{
    auto type(){return type_;};
    auto type(EVENT_DATA t){
      enforce(type_ == EVENT_DATA.NONE);
      type_ = t;
    }
    auto number(){ enforce(type_ == EVENT_DATA.NUMBER); return number_;}
    auto str(){ enforce(type_ == EVENT_DATA.STRING); return str_;}
    auto floater(){ enforce(type_ == EVENT_DATA.FLOATER); return floater_;}
    auto posX(){ enforce(type_ == EVENT_DATA.POS); return pos_.x;}
    auto posY(){ enforce(type_ == EVENT_DATA.POS); return pos_.y;}
    auto vectorX(){ enforce(type_ == EVENT_DATA.VECTOR); return vector_.x;}
    auto vectorY(){ enforce(type_ == EVENT_DATA.VECTOR); return vector_.y;}

    void number(int a){enforce(type_ == EVENT_DATA.NUMBER); number_ = a;}
    void str(string a){enforce(type_ == EVENT_DATA.STRING); str_ = a;}
    void floater(float a){enforce(type_ == EVENT_DATA.FLOATER); floater_ = a;}
    void posX(int a){enforce(type_ == EVENT_DATA.POS); pos_.x = a;}
    void posY(int a){enforce(type_ == EVENT_DATA.POS); pos_.y = a;}
    void vectorX(float a){enforce(type_ == EVENT_DATA.VECTOR); vector_.x = a;}
    void vectorY(float a){enforce(type_ == EVENT_DATA.VECTOR); vector_.y = a;}
  }
  void clear(){
    type_ = EVENT_DATA.NONE;
  }
}
