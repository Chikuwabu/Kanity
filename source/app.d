import std.stdio;
import kanity.core;

void main(){
	auto engine = new Engine("kanityconfig.json");
	engine.run();
	return;
}
