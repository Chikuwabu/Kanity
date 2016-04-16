import std.stdio;
import RPGEngine.core;

void main(){
	//writeln("Edit source/app.d to start your project.");
	auto engine = new engine();
	engine.run("闇の裏", 640, 480);
	return;
}
