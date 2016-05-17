module kanity.input;

import kanity.imports;

class Input{

}
class InputEventInterface{
  private EventQueue!int queue;
  private Input input;
  
  public void delegate(EventData*) getSender(){
    return (EventData* e){
      queue.enqueue(*e);
    };
  }
}
alias ButtonEvent = void delegate(bool); //押されているか
alias StickEvent = void delegate(real, real); //x, y
