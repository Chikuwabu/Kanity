module kanity.utils;
import std.container;
import std.exception;
import std.range;
import std.experimental.logger;
import core.thread;

//勝手に管理してID振ってくれるやつ
class IDTable(T){
  private T[] data_;
  private uint count = 0;
  private SList!(uint) unused;
  private uint unusedCount = 0;
  public void delegate(T) deleteFunc;
public:
  this(){
    data_.length = 1;
    deleteFunc = (T a) => (delete a);
  }
  uint add(T data){
    int a;
    if(unusedCount > 0){
      //すき間があるならそちらに入れる
      a = unused.removeAny;
      unusedCount--;
    }else{
      //ないなら領域を増やす
      a = count++;
      if(count >= data_.length){
        //メモリが足りなくなったら多めに確保する
        data_.length = data_.length * 2;
      }
    }
    data_[a] = data;
    return a;
  }
  void remove(uint a){
    deleteFunc(data_[a]);
    unused.insertFront(a);
    unusedCount++;
  }
  void set(uint a, T data){ data_[a] = data; }
  T get(uint a){ return data_[a]; }
}
//参照カウントして開放
class DataTable(TKey, TData){
  private TData[TKey] data;
  private uint[TKey] count;
  public void delegate(TData) deleteFunc;

  this(){
    deleteFunc = (TData a) => (delete a);
  }
  public void add(TKey key, TData data_){
    if(key !in data) data[key] = data_;
    count[key]++;
  }
  public void remove(TKey key){
    enforce(key in data);
    count[key]--;
    if(count[key] <= 0){
      deleteFunc(data[key]);
      data.remove(key);
    }
  }
  //getして使用が終わったらremoveする
  public TData get(TKey key){
    enforce(key in data);
    count[key]++;
    return data[key];
  }

  alias this get;
}
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
    @property public bool empty(){return q.count==0;}
    @property public E front(){
      while(!this.mutex.tryLock){}
      auto a = q.queue.back;
      mutex.unlock;
      return a;
    }
    public void popFront(){
      while(!mutex.tryLock){}
      q.queue.removeBack;
      q.count--;
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
//Adapters
import std.range;
struct Queue(T){
  static if(__traits(compiles, {T a; auto b = a.front; b = a.back; a.removeBack;}) == false) static assert(0);

  private T queue;
  private uint count = 0;

  alias S = ElementType!T;
  public void enqueue(S a){
    queue.insertFront(a);
    count++;
  }
  public S dequeue(){
    enforce(count > 0);
    count--;
    queue.removeBack;
    auto a = queue.back;
    return a;
  }
  alias init = clear;
  public void clear(){
    queue.clear;
    count = 0;
  }
  Range opSlice(){
    return Range(&this);
  }
  @property public uint length(){return count;}
  struct Range{
    this(Queue* queue){
      q = queue;
    }
    private Queue* q;
    @property public bool empty(){return q.count==0;}
    @property public S front(){return q.queue.back;}
    public void popFront(){
      q.queue.removeBack;
      q.count--;
    }
  }
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
  @property public uint length(){return count;}
}
