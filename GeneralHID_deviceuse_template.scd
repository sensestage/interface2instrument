//// ---- GeneralHID - template for setting up a device ---

// startup:
(
// build the device list:
GeneralHID.buildDeviceList;
// start the event loop:
GeneralHID.startEventLoop; // actually only needed on OSX
);


// open your device:
a = GeneralHID.open( GeneralHID.findBy( 1103, 53251 ) ); /// 1. FILL IN THE NUMBERS YOU GET WITH findArgs WHEN EXPLORING THE DEVICE

// give it the spec that you have defined:
a.setSpec( a.findSpec.first );

// now you can access the device with the labels that you defined

// check which controls actually have a label:
a.spec.map;