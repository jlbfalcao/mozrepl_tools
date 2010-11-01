
require 'socket'
require 'cgi'

s = TCPSocket.open('localhost', 4242)

script = DATA.read

filepath = ENV["TM_FILEPATH"] || ARGV[0]
file =  File.basename filepath
ext = File.extname filepath
filename = File.expand_path filepath

s.puts(script)

if ext == ".css" || ext == ".scss"
  file = file.split(".")[0] + ".css"
  s.puts("reload.css('#{file}')")
  puts "reloaded #{file}"
elsif ext == ".js"
  s.puts("reload.js('#{filename}')")
  puts "reloaded #{filename}"
end

# workaround
sleep 1

s.close

__END__


var reload = (function(content, window) {
  var window = (function() {
    for ( var i = 0; i < window.length; i++ ) {
        if ( content.location == window[i].location ) {
          return window[i];
        }
    }
  })();
  
  // TODO: refactory
  function found_script(a,s) {
    var t = s.split("?");
    var pu = t[0].split("/").reverse();
    var pc = a.split("/").reverse();
    var c = 0;
    for ( var i = 0; i < pu.length; i++ ) {
      if ( pu[i] == pc [i] ) {
        c++;
      } else {
        break;
      }
    }
    repl.print(c)
    if ( c > 0 ) {
      return s + ((t[1])?"&":"?") + Math.random();
    }
  }

  var document = doc = window.document;
  var Ext = window.Ext;
  
  // firebug
  var console = window.console || {debug:function(){}};

  console.debug("loading...");

  var head = document.getElementsByTagName("head")[0];

  return {
    css:function(file) {
      var l = doc.getElementsByTagName('link');
      for ( var i = 0; i < l.length; i++ ) {
        var ss = l[i];
        console.debug("reloading:", ss);
        if ( ss.href && ss.href.indexOf(file) != -1 ) {
          try {
            ss.href = (ss.href.split("?")[0]) + "?" + Math.random();
          } catch (e) {
            repl.print(e);
          }
        }
      }
    },
    jsEval:function(text) {
      var script  = document.createElement('script');
      script.type = "text/javascript";
      script.textContent = text;
      repl.print(text);
      head.appendChild(script);
    },
    js:function(filename) {
      var scripts = document.getElementsByTagName("script");
      for (var i = 0; i < scripts.length; i++ ) {
        repl.print(scripts[i].src);
        if ( scripts[i].src ) {
          var s = found_script(filename, scripts[i].src)
          repl.print(filename);
          repl.print("s:", s);
          if ( s ) {
            var script  = document.createElement('script');
            script.type = "text/javascript";
            script.src  = s;
            repl.print(filename);
            head.appendChild(script);
            return;
            
          }
        }
      }
      
    }
  };
})(content, window);
// reload.js('assets/application/application.js');
