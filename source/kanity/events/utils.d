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
struct EventData{
public:
  void delegate(int) callback = null;
  void delegate() func = null;
  this(void delegate() func_){
    func = func_;
  }
  this(void delegate() func_, void delegate(int) callback_){
    func = func_;
    callback = callback_;
  }
}
