
require 'socket'
require 'cgi'

s = TCPSocket.open('localhost', 4242)

script = DATA.read


# print "asdad'asdasda"
# print "aa\"aa"
# print "aa\"aa".gsub(/["]/, '\"')

filepath = ENV["TM_FILEPATH"] || ARGV[0]
file =  File.basename filepath
ext = File.extname filepath
filename = File.expand_path filepath
# p ext
s.puts(script)

if ext == ".css"
  s.puts("reload.css('#{file}')")
  puts "reloaded #{file}"
elsif ext == ".js"
  # content = (IO.readlines(filename).map do |l|
  #   "\"" + l.gsub(/[']/, '\\\\\'').gsub(/["]/, '\"').chop() +  " \\n \"" + " + \n"
  # end).join("")
  # content += '""'
  # puts contenttoutf8 → string
  
  # puts content
  s.puts("reload.js('#{filename}')")
  puts "reloaded #{filename}"
end

# puts script

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
  
  // add development Ext.reg
  if ( ! Ext._reg ) {
    console.debug('saving original Ext.reg');
    Ext._reg = Ext.reg;
  }  

  Ext.reg = function(xtype) {
    console.debug("Ext.reg:", arguments);
    // calling old Ext.reg
    Ext._reg.apply(Ext, arguments);
    
    // reinstance all xtypes
    var items = Ext.ComponentMgr.all.filterBy(function(e) { return e.getXType() == xtype }).each(function(item) {
        repl.print(item)
        var ic = item.initialConfig;
        var o = item.ownerCt;
        o.remove(item);
        var it = o.add(ic)
        if ( o.getLayout().setActiveItem ) {
          o.getLayout().setActiveItem(it);
        };
        o.doLayout();
    });
  };

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
