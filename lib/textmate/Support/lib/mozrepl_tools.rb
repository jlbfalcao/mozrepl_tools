
require 'socket'

s = TCPSocket.open('localhost', 4242)

script = DATA.read

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
    js:function(filename) {
      var script  = document.createElement('script');
      script.type = "text/javascript";
      script.src  = filename;
      repl.print(filename);
      head.appendChild(script);
    }
  };
})(content, window);
