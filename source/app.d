import std.stdio;
import kanity.core;
import std.json;

void main(){
	auto configFileName = "kanityconfig.json";
	auto logFileName = "kanitylog.log";
	JSONValue root = parseJSON(import("kanitybuild.json"));
	if("configFileName" in root.object){
		auto obj = root.object["configFileName"];
		configFileName = obj.str;
	}
	if("logFileName" in root.object){
		auto obj = root.object["logFileName"];
		logFileName = obj.str;
	}
	auto engine = new Engine(configFileName, logFileName);
	engine.run();
	return;
}
