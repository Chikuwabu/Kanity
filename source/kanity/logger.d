//The logger of the kanity, for the kanity, by the kanity.
module kanity.logger;
import kanity.imports;
import std.experimental.logger;
import std.stdio : File;
import std.concurrency : Tid;
import std.datetime : SysTime;

class KaniLogger : FileLogger{
public:
  this(File file, const LogLevel lv = LogLevel.all) @safe{
    super(file, lv);
  }
  override protected void beginLogMsg(string file, int line, string funcName, string prettyFuncName, string moduleName,
                                      LogLevel logLevel, Tid threadId, SysTime timestamp, Logger logger) @safe{
    auto lt = this.file.lockingTextWriter();
    switch(logLevel){
      case LogLevel.info:
        lt.put("[INFO]");
        break;
      case LogLevel.trace:
        break;
      case LogLevel.fatal:
        lt.put("[FATAL]");
        break;
      case LogLevel.error:
        lt.put("[ERROR]");
        break;
      case LogLevel.warning:
        lt.put("[WARNING]");
        break;
      default:
        super.beginLogMsg(file, line, funcName, prettyFuncName, moduleName, logLevel, threadId, timestamp, logger);
        break;
    }
  }
}
