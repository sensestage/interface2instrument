// Accessing HID devices from the language:

// doesn't work on Windows :(

// on Mac OSX: use SuperCollider 3.4.5 :),
//             unfortunately, it got broken in later versions while migrating to 64bit and an updated OSX HID framework. :(

// on Linux: it should be fine, but do check [Linux_udev_setup] :)

// using the GeneralHID class
// two stages:
//   - exploring the device, and learning its capabilities (done once, when you first get the device)
//   - initialising the device for use in performance interfaces (basic setup code you should keep around for each time you want to use the device in a project)


// build the device list:
GeneralHID.buildDeviceList;
// start the event loop:
GeneralHID.startEventLoop; // actually only needed on OSX

// ------- first time use of a device - exploring --------

// check which devices are attached:
GeneralHID.postDevices;
// the number in front of each line indicates its place in the deviceList

// open the device of interest
a = GeneralHID.open( GeneralHID.deviceList[12] );

// get information about the device:
a.info;

// if you want to automatically find the device when you restart you can use the GeneralHID.findBy method. To get the arguments you should use for this function, you can use:
a.info.findArgs;

// this outputs for my Thrustmaster Run'N' Drive gamepad
[ 1103, 53251, usb-0000:00:1a.0-1.1/input0, 256 ] // vendorID, productID, locationID (where is it connected), versionID

// close the device for now:
a.close;

// find the right device in the list:
b = GeneralHID.findBy( 1103, 53251 );
// and open it:
a = GeneralHID.open( b );


// basic debugging to see whether data comes in:

a.debug_( true );

// this prints an array with:
// [ slot type, slot id, value, label ]

// Alternatively, you can create a simple (not yet perfect) GUI to see the data:
a.makeGui;

// some devices (like my gamepad) have several modes, between which you can change, and will output different data based on that, just go through the different modes and see what happens when you move different controllers.

// having played around a little, we can now start labelling the controls, using the method .add

// left joystick x-axis
a.add( \lx, [3,0] );
// move it and now you see the label printed too

// now turn debugging of for that axis:
a[\lx].debug_( false );

a.add( \ly, [3,1] );
// now turn debugging of for that axis:
a[\ly].debug_( false );


a.add( \rx, [3,2] );
a.add( \ry, [3,5] );

a.add( \lthrottle, [3,3] );
a.add( \rthrottle, [3,4] );

a.add( \wheel, [3,6] );
a.add( \compassX, [3,16] );
a.add( \compassY, [3,17] );

// the buttons (ok, using a shortcut code here)
(1..12).do{ |it,i| a.add( ("b"++it).asSymbol, [1,304+i] ) };

// .. and so on

// save the spec for future use:
a.spec.save( "ThrustMaster_test" );

// this saves the spec in the folder:
(Platform.userAppSupportDir +/+ "GeneralHIDSpecs")

// find a spec defined previously for this device (this is what we'll use in our basic setup file for the device)
c = a.findSpec;
// set it:
a.setSpec( c[0] );

// stop debugging:
a.debug_( false )


// check which controls actually have a label:
a.spec.map


/// To simplify the process, I have made two template files:
// 1. for getting to know a device you are using for the first time (explore_template)
// 2. to fill in the details obtained from the exploration to use in your code (deviceuse_template)

/// ------ using the data: ----------

// access the control on the device:
a.at( \lx )
// is the same as:
a[\lx]

// get the current value:
a[\lx].value

// perform an action when a value comes in:
a[\lx].action = { |slot| slot.value.postln; };

// assign an empty function to remove the action:
a[\lx].action = {};

// s.boot;
// create a control bus on the server, and write the controller value to the bus, each time the value is updated:
a[\lx].createBus( s );

// access the bus:
a[\lx].bus;

// example:

(
SynthDef( \hidexample, { |out=0,freqadd=0,amp=0|
	Out.ar( out,
		SinOsc.ar(
			300 + (freqadd.lag(0.2,1)*300), // frequency of 300 with an addition of up to 300 hertz, with a lag of 0.2 when going up, and a lag of 1 when going down
			0,
			0.2*amp.lag(0.01,0.99) // amplitude of 0.2 * amp, with a lag up of 0.01, and a lag down of 0.99
		)
	);
}).add;
)


x = Synth.new( \hidexample );
x.map( \freqadd, a[\lx].bus );
a[\b1].action = { |slot| x.set( \amp, slot.value ) };

// check which controls actually have a label:
a.spec.map;

// free the synth again
x.free;


// ------- using the explored device in your patches - basic setup --------

// build the device list:
GeneralHID.buildDeviceList;
// start the event loop:
GeneralHID.startEventLoop;

// find the right device in the list:
b = GeneralHID.findBy( 1103, 53251 )
// and open it:
a= GeneralHID.open( b );
// find a suitable spec
c = a.findSpec;
// set it (to the first one found)
a.setSpec( c[0] );



// a few notes:

// On OSX, you need version 3.4 for now to make HID work (it is unfortunately broken in 3.5).
// Also on OSX, there seems to be an issue accessing the internal keyboard and trackpad on certain MacBook models,
// - Wacom tablets are also a special case on OSX (TabletView or TabletSlider2D)


// On Linux, sometimes you get a message:
ERROR: LID (1): Permission denied

// You can fix this as follows:
// go to the terminal:
// $ cd /dev/input/
// $ sudo chmod 766 event*
// (you'll be asked for your password)
// there is a more definate way of configuring this, by setting up udev-rules accordingly (see the helpfile [Linux_udev_setup])
