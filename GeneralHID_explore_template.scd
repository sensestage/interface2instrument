////--- GeneralHID - template for exploring a device ----

// build the device list:
GeneralHID.buildDeviceList;
// start the event loop:
GeneralHID.startEventLoop; // actually only needed on OSX

// ------- first time use of a device - exploring --------

// check which devices are attached:
GeneralHID.postDevices;
// the number in front of each line indicates its place in the deviceList, in my case "9"

// open the device of interest
a = GeneralHID.open( GeneralHID.deviceList[9] );

// get information about the device:
a.info;

// if you want to automatically find the device when you restart you can use the GeneralHID.findBy method. To get the arguments you should use for this function, you can use:
a.info.findArgs;

// use the first two arguments in your device startup routine (AT COMMENT /// 1. FILL IN THE NUMBERS YOU GET WITH findArgs WHEN EXPLORING THE DEVICE )
// e.g. for my Thrustmaster Run'n'Drive Gamepad the line above returns:
// [ 1103, 53251, usb-0000:00:1a.0-1.1/input0, 256 ] // vendorID, productID, locationID (where is it connected), versionID
// so I use in my device startup:
// a = GeneralHID.open( GeneralHID.findBy( 1103, 53251 ) ); /// 1. FILL IN THE NUMBERS YOU GET WITH findArgs WHEN EXPLORING THE DEVICE


/// --- exploring the capabilities ---

// basic debugging to see whether data comes in:

a.debug_( true );

// this prints an array with:
// [ slot type, slot id, value, label ]

// Alternatively, you can create a simple (not yet perfect) GUI to see the data:
a.makeGui;


// some devices (like my gamepad) have several modes, between which you can change, and will output different data based on that, just go through the different modes and see what happens when you move different controllers.

// having played around a little, we can now start labelling the controls, using the method .add


// REPEAT UNTIL YOU HAVE ALL CONTROLS ON THE DEVICE LABELED:

// [3,0] appears to be my left joystick x-axis
a.add( \lx, [3,0] );
// move it and now you see the label printed too

// now turn debugging of for that axis:
a[\lx].debug_( false );

/// END REPEAT

// then save the labels you just made:

a.spec.save( "ThrustMaster_test" ); // give it a meaningful name!

// this saves the spec in the folder, be sure to back it up when moving to a new machine
(Platform.userAppSupportDir +/+ "GeneralHIDSpecs")

// then in your device startup code:
// set it:
a.setSpec( a.findSpec.first );