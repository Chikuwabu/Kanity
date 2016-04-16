import std.stdio;
import rpgengine.core;

void main(){
	//writeln("Edit source/app.d to start your project.");
	auto engine = new Engine();
	engine.run("闇の裏", 640, 480);
	return;
}
