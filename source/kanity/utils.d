module kanity.utils;
import kanity.imports;
import std.container;
import std.range;

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
  alias LoadFunc = TData delegate();
  public void add(TKey key, lazy TData load){
    if(key !in data) data[key] = load;
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
