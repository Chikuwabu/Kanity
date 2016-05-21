module kanity.file;

import kanity.imports;
import derelict.sdl2.sdl;

struct FileSystem{
static:
  alias rootObject this;
  public FileObject rootObject;
}

enum FileType{
  Directry, File
}
abstract class FileObject{
  protected FileObject parent_;
  protected FileObject[string] children;
  protected FileType type;

  this(FileObject parent = null, FileType ft = FileType.Directry){
    parent_ = parent;
    type = ft;
  }
  final string loadString(string path){
    auto fileObject = this.get(path);
    return fileObject.loadString;
  }
  final ubyte[] loadBinary(string path){
    auto fileObject = this.get(path);
    return fileObject.loadBinary;
  }
  alias loadRW = loadRWops;
  static shared extern(C) int function(SDL_RWops*) mem_close;
  import core.memory;
  final SDL_RWops* loadRWops(string path){
    auto data = loadBinary(path);
      GC.addRoot(cast(void*)(data.ptr));
      GC.setAttr(cast(void*)data.ptr, GC.BlkAttr.NO_MOVE);
      auto rwops = SDL_RWFromMem(cast(void*)(data.ptr), data.length.to!int);
      if (!mem_close)
      {
          mem_close = rwops.close;
      }
      
      rwops.close = cast(typeof(rwops.close))&fileSystemMemClose;
    return rwops;
  }
  static extern(C) int fileSystemMemClose(SDL_RWops* context)
  {
      GC.removeRoot(context.hidden.mem.base);
      GC.clrAttr(context.hidden.mem.base, GC.BlkAttr.NO_MOVE);
      return mem_close(context);
  }
  final public FileObject get(string path){
    return get(Path(path));
  }

  final public FileObject get(Path path){
    if(path.length == 0){
      return this;
    }else{
      auto obj = path.get;
      switch(obj){
        case "..":
          if(parent_ is null){
            error("Parent directry is not found.");
            enforce(0);
          }
          return parent_.get(path);
        case ".":
          return this.get(path);
        default:
          if(obj !in children){
            errorf("\'%s\' is not found.", obj);
            enforce(0);
          }
          return children[obj].get(path);
      }
    }
  }
  protected abstract string loadString();
  protected abstract ubyte[] loadBinary();
}
class FileFileObject : FileObject{ //OSのファイルシステムを使用するファイルオブジェクト
  import std.file, std.path;
  private string path;

  this(string path_, FileObject parent = null, FileType ft = FileType.Directry){
    super(parent, ft);
    path = path_.absolutePath.buildNormalizedPath;

    if(type != FileType.Directry) return;
    import std.algorithm;
    path.dirEntries(SpanMode.shallow).each!((DirEntry a){
      auto name = a.name.relativePath(path);
      auto fileType = a.isDir ? FileType.Directry : FileType.File;
      children[name] = new FileFileObject(a.name, this, fileType);
    });
    children.rehash;
    path.log;
  }
  override string loadString(){
    errorf(type != FileType.File, "\'%s\' is not a file.", path);
    try{
      return path.readText;
    }catch(Exception e){
      errorf("Failed to load \'%s\'.", path);
      throw(e);
    }
  }
  override ubyte[] loadBinary(){
    errorf(type != FileType.File, "\'%s\' is not a file.", path);
    try{
      return cast(ubyte[])(path.read);
    }catch(Exception e){
      errorf("Failed to load \'%s\'.", path);
      throw(e);
    }
  }

}

private struct Path{
  private string[] path;
  private int length_;
  @property public int length(){return length_;}

  this(string path_){
    import std.string;
    path = path_.split("/");
    length_ = path.length.to!int;
  }
  string get(){
    enforce(length != 0);
    return path[path.length - length_--];
  }
}
