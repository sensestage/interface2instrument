/// MIDI syncing:

MIDIIn.connectAll;

// MIDI Time Code messages can be received with the smtpe method:
// the format is a bit complicated, so I've made class to use it:

// create an instance of MTC player:
~mtc = MTC.new;

// listen to incoming messages:
~mtc.listen;

// set the framerate (should match what the sender is using):
~mtc.fps = 25;
~mtc.fps;

// check what's coming in:
~mtc.debug = true;

// stop debugging:
~mtc.debug = false;


// or listen only to a specific source:
~mtc = MTC.new( 8454144 );

// or set it later:
//~mtc.mtcsrc = 8454144;

// action to execute on each frame (passes the frame as an argument)
~mtc.frameAction = { |fr| "received a new frame with id: ".post; fr.postln; };

// action to execute on each frame (passes the time in seconds as an argument)
~mtc.action = { arg time; "received a new frame on time:: ".post; time.postln; };

// stop listening:
~mtc.stop;


// MIDI Clock
~sysrt = MIDIFunc.new( { arg ...args; args.postln }, msgType: \sysrt );

