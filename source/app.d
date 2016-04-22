import std.stdio;
import kanity.core;
import kanity.mapeditor.editor;

void main(){
    auto editor = new Editor();
    editor.run();
	auto engine = new Engine();
	engine.run("Name of game", 640, 480);
	return;
}
