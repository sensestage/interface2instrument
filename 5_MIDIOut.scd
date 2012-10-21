/// sending MIDI output

// sometimes you want to send MIDI out to another device or program to control it.

// initialise the MIDIClient:

MIDIClient.init;

// there are a couple of destinations the MIDI can go out to:
MIDIClient.destinations.do{ |it,i| [i,it].postln; };



// on OSX/Windows:
// to create an instance of MIDIOut, you have to specify the index into the destinations array to select where you will send your MIDI to:
m = MIDIOut(0); // will connect to the first element in the destinations array.

// or if you want to select by name:
m = MIDIOut.newByName("RemoteSL IN","Port 1");

//--- end OSX/Windows only

// on Linux, SuperCollider creates a couple of output ports (equal to the amount of available destinations), but they don't automatically connect to all of the available destinations. Rather, you can connect them from SC, or use the ALSA patchbay in e.g. QJackCtl to connect them. The MIDI data will be send to anything that is connected to the MIDI output port of SC.

// create a reference to SC's first MIDIOutput port:
m = MIDIOut(0);
// connect it to the 12th element in the destinations array:
m.connect( 12 );

// connect to a specific port by name
m.connect( MIDIOut.findPort( "ZynAddSubFX-ZynAddSubFX", "ZynAddSubFX-ZynAddSubFX" ); );

//---end LINUX only


// sending data out:
m.noteOn( 0, 60, 30 );

m.noteOff( 0, 60 );

// similar methods for:
m.allNotesOff
m.bend
m.control
m.polyTouch
m.touch
m.program
m.sysex // system exclusive


// using patterns to send midi events:
a = Pbind(\degree, Prand([1, 2, 3, [0, 5]], inf), \bend, Pwhite(0, 76, inf));

// chain a midi event into the pattern and play it (see Pchain)
(a <> (type: \midi, midiout: m)).trace.play;

m.allNotesOff(0);

// on Linux, disconnect again:
m.disconnect( 12 );

// latency:
// for the MIDIOut port you can set a latency, by default this is 0.2, just like the Server's default latency.
// you can change it with:
m.latency = 1;

m.noteOn( 0, 64, 127 );
m.noteOff( 0, 64 );

m.latency = 0.2;

