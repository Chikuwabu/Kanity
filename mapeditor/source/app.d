import std.stdio;
import kanity.core;
import kanity.mapeditor.editor;

void main(){
    auto editor = new Editor("editorconfig.json", "kanitylog.log");
    editor.run();
    return;
}

