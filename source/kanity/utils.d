module kanity.utils;
import kanity.imports;
import std.container;
import std.range;
import core.sync.mutex;

//勝手に管理してID振ってくれるやつ
class IDTable(T){
  private T[] data_;
  private uint count = 0;
  private SList!(uint) unused;
  private uint unusedCount = 0;
  private Mutex mutex;
  public void delegate(T) deleteFunc;
public:
  this(){
    data_.length = 1;
    deleteFunc = (T a) => (delete a);
    mutex = new Mutex();
  }
  uint add(T data){
    synchronized(mutex){
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
  }
  void remove(uint a){
    synchronized(mutex){
      deleteFunc(data_[a]);
      unused.insertFront(a);
      unusedCount++;
    }
  }
  void set(uint a, T data){
    synchronized(mutex){
      data_[a] = data;
    }
  }
  T get(uint a){
    synchronized(mutex){
      return data_[a];
    }
  }
}
//参照カウントして開放
class DataTable(TKey, TData){
  private TData[TKey] data;
  private uint[TKey] count;
  private Mutex mutex;
  public void delegate(TData) deleteFunc;

  this(){
    deleteFunc = (TData a) => (delete a);
    mutex = new Mutex();
  }
  public void add(TKey key, lazy TData load){
    synchronized(mutex){
      if(key !in data) data[key] = load;
      count[key]++;
    }
  }
  public void remove(TKey key){
    synchronized(mutex){
      enforce(key in data);
      count[key]--;
      if(count[key] <= 0){
        deleteFunc(data[key]);
        data.remove(key);
      }
    }
  }
  //getして使用が終わったらremoveする
  public TData get(TKey key){
    synchronized(mutex){
      enforce(key in data);
      count[key]++;
      return data[key];
    }
  }

  alias this get;
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
//マルチキャストなデリゲート
import std.traits;
struct MultiCastableDelegate(T) if(isCallable!T){
  import std.container;
  private DList!T funcs;
  alias S = ReturnType!T;

  public S opCall(ParameterTypeTuple!T args...){
    static if(__traits(compiles, {S x;})){
      S a;
      funcs.each!((func){
          a = func(args);
      });
      return a;
    }else{
      funcs.each!((func){
        func(args);
      });
    }
  }
  public auto opBinary(string op)(T arg){
    static if(op == "+"){
      auto a = this;
      a += arg;
      return a;
    }else static if(op == "-"){
      auto a = this;
      a -= arg;
      return a;
    }
  }
  public auto opOpAssign(string op)(T arg){
    static if(op == "+"){
      this.addFunc(arg);
    }else static if(op == "-"){
      this.removeFunc(arg);
    }
  }
  public auto opSlice(){
    return funcs[];
  }
  public void clear(){
    funcs.clear;
  }
  private void addFunc(T arg){
    funcs.insertBack(arg);
  }
  private void removeFunc(T arg){
    import std.algorithm, std.range;
    funcs.linearRemove(find(funcs[], arg).take(1));
  }
}
unittest{
  import std.array, std.functional;
  "雲丹おいしい".log;
  MultiCastableDelegate!(string delegate(string, string)) d;
  auto a = delegate (string a, string b){a.log; b.log; return "ゆうあし";};
  d += a;
  d = d + (&test).toDelegate;
  d("hoge", "hage");
  d[].map!((f) => f("hoge", "hage")).array.each!((a){a.log;});
  //rtn.log;
}

string test(string a, string b){
  a.log;
  b.log;
  return "ハゲ";
}
