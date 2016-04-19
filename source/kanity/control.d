module kanity.control;

import kanity.render;
import kanity.event;
import kanity.core;

class Control{
private:
  Renderer renderer;
  Event event;
  UnderLayer uLayer;

public:
  void run(Renderer renderer_, Event event_, UnderLayer uLayer_){
    renderer = renderer_; event = event_; uLayer = uLayer_;
  }
}
