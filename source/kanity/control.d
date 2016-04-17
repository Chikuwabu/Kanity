module rpgengine.control;

import rpgengine.render;
import rpgengine.event;
import rpgengine.core;

class control{
private:
  Renderer renderer;
  Event event;
  UnderLayer uLayer;

public:
  void run(Renderer renderer_, Event event_, UnderLayer uLayer_){
    renderer = renderer_; event = event_; uLayer = uLayer_;
  }
}
