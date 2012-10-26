// This only works with version 0.2 of the HIDserver by Ixi, with adaptations by nescivi


IxiHID.path = "/home/nescivi/Downloads/HIDServer_0.3.1/";

OSCFunc.trace( true );
// set the scheme for GeneralHID:
GeneralHID.fromID( \ixi_hid );

// build the device list:
GeneralHID.buildDeviceList; // this is asynchronous

GeneralHID.postDevices;

// get the device list:
d = GeneralHID.deviceList;

// open the first device:
a = GeneralHID.open( d[0] );

// get info:
a.info;

// access the slots:
a.slots

// post a readable list:
a.caps;

// debug: check incoming data:
a.debug_(true);

// stop debugging:
a.debug_(false);

// per slot:
a.slots[3][1].debug_(true);
a.slots[3][1].value;
a.slots[3][1].action_( {|v| v.value.postln; } );
a.slots[3][1].action_( { } );

// for further info: see the GeneralHID helpfile!

OSCFunc.trace( true );

OSCFunc.trace( false );

a.makeGui