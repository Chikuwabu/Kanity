module kanity.control;

import kanity.render;
import kanity.event;
import kanity.core;

class Control{
private:
  Renderer renderer;
  Event event;
  LowLayer lLayer;

public:
  void run(Renderer renderer_, Event event_, LowLayer lLayer_){
    renderer = renderer_; event = event_; lLayer = lLayer_;
  }
}
