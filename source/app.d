import std.stdio;
import kanity.core;
import kanity.mapeditor.editor;

void main(){
    auto editor = new Editor("kanityconfig.json");
    editor.run();
	auto engine = new Engine("kanityconfig.json");
	engine.run();
	return;
}
