
//reload if xtype is registered again, by watching Ext.reg

Ext.reg = Ext.reg.createSequence(function(xtype) {
    console.log("Attempting to reload xtype", xtype);

    //find all current instances of this type
    Ext.ComponentMgr.all.filterBy(function(e) {return e.getXType() == xtype; })
        .each(function(item) {

            //recreate and read
            var ic = item.initialConfig;
            var o = item.ownerCt;

            if(ic && o) {
                console.log("Reloading component instance", item, ic, o);

                //remove
                o.remove(item);

                //add it again
                var it = o.add(Ext.apply({xtype: xtype}, ic));

                //TODO: test if it was indeed active
                if ( it && o.getLayout().setActiveItem ) {
                    o.getLayout().setActiveItem(it);
                };
                o.doLayout();
            }
        });
});