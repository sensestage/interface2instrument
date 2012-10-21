/// MIDI

// MIDI is a protocol that was invented in the 1980's to allow hardware synthesizer and controllers to talk to each other.
// It is still quite popular as a protocol, despite its limitations.

// MIDI device can send a number of different messages, such as "note on", "note off", "control change", etc.

// MIDI startup:
// to connect to all the midi devices
MIDIIn.connectAll;

// Between SuperCollider version 3.4 and 3.5 a new method to interface with MIDI was introduced. In this tutorial, we will show both next to each other.

// in version 3.4 the MIDIResponder methods are used
// in version 3.5 and up, you can also use MIDIFunc and MIDIdef instead


// If you have a new device, you first want to know what kind of messages it produces; in 3.5 you need to create a MIDIFunc for each type of message:

~testCC = MIDIFunc.cc( { arg ...args; "cc\t".post; args.postln; } ); // listen to any control message
~testNote = MIDIFunc.noteOn( { arg ...args; "noteon\t".post; args.postln; } ); // listen to any note on message
~testNoteOff = MIDIFunc.noteOff( { arg ...args; "noteoff\t".post; args.postln; } ); // listen to any note off message
~testPolyTouch = MIDIFunc.polytouch( { arg ...args; "polytouch\t".post; args.postln; } ); // listen to any polytouch message
~testTouch = MIDIFunc.touch( { arg ...args; "touch\t".post; args.postln; } ); // listen to any touch message
~testBend = MIDIFunc.bend( { arg ...args; "bend\t".post; args.postln; } ); // listen to any touch message
~testProgram = MIDIFunc.program( { arg ...args; "program\t".post; args.postln; } ); // listen to any touch message

// In 3.6 (master) we have created a shortcut for this:
MIDIFunc.trace;
// to turn tracing off:
MIDIFunc.trace( false );


// to remove all MIDIFunc's:
MIDIFunc.allFuncProxies.do{ |it| it.do{ |jt| if ( jt.isKindOf( MIDIFunc ) ){ jt.free } } };
// or press CmdPeriod

// you can also use named midi funcs, using MIDIdef (in the JITlib style of Ndef, Tdef, Pdef, etc)
// the advantage is that the OSCdef is replaced, if you change the function for an OSCdef with the same name.
MIDIdef.cc( \testerCC, { arg ...args; args.postln; } );
MIDIdef(\testerCC).free;


// In 3.4 you use MIDIResponders, which come in all types:

~testCC = CCResponder.new( { arg ...args; "cc\t".post; args.postln; } );
~testNote = NoteOnResponder.new( { arg ...args; "noteon\t".post; args.postln; } ); // listen to any note on message
~testNoteOff = NoteOffResponder.new( { arg ...args; "noteoff\t".post; args.postln; } ); // listen to any note off message
~testTouch = TouchResponder.new( { arg ...args; "touch\t".post; args.postln; } ); // listen to any touch message
~testBend = BendResponder.new( { arg ...args; "bend\t".post; args.postln; } ); // listen to any touch message
~testProgram = ProgramChangeResponder.new( { arg ...args; "program\t".post; args.postln; } ); // listen to any touch message

// polytouch responder was forgotten in the main library of 3.4... but the Quark JITMIDIKtl provides it:
~testPolyTouch = PolyTouchResponder.new( { arg ...args; "polytouch\t".post; args.postln; } ); // listen to any polytouch message


// remove all responders
MIDIResponder.removeAll;


/// example 1

/// --- example for a knob and a pad on my Akai LPD8 (in "pad" mode)

// connect to all midi ports
MIDIIn.connectAll;
MIDIFunc.trace;

// tapping the first pad gives me:
MIDI Message Received:
	type: noteOn
	src: 1572864
	chan: 0
	num: 36
	val: 4

MIDI Message Received:
	type: noteOff
	src: 1572864
	chan: 0
	num: 36
	val: 127

// so it sends a noteOn message when I press it, and a note off message when I release it.
// the "src" indicates the device
// the "chan" is the midi channel (between 0 and 15)
// the "num" is the note number
// the "val" is the velocity of the note

// so to attach functions to it, I could do:

~akaiPad1On = MIDIFunc.noteOn( { arg ...args; "noteon pad 1\t".post; args.postln; }, 36, 0, 1310720 ); // listen to note on message of pad 1
~akaiPad1Off = MIDIFunc.noteOff( { arg ...args; "noteoff pad 1\t".post; args.postln; }, 36, 0, 1310720 ); // listen to note off message of pad 1

MIDIFunc.trace;

// for knob 1, I get:
MIDI Message Received:
	type: control
	src: 1572864
	chan: 0
	num: 1
	val: 45

// so to attach it to its own function I coud do:
~akaiKnob1 = MIDIFunc.cc( { arg ...args; "control knob 1\t".post; args.postln; }, 1, 0, 1310720 ); // listen to knob 1

MIDIFunc.trace( false );


// remove the functions again:
~akaiPad1On.free;
~akaiPad1Off.free;
~akaiKnob1.free;

// now for some sound:
(
SynthDef( \sinePad, { |freq=500, gate=0, velocity=1, out=0, amp=1|
   Out.ar( out, EnvGen.kr( Env.adsr, gate, velocity ) * SinOsc.ar( freq, 0, amp ) );
}).add;
);

x = Synth.new( \sinePad );

~akaiPad1On = MIDIFunc.noteOn( { arg val; x.set( \gate, 1, \velocity, val/127 ) }, 36, 0, 1310720 ); // listen to note on message of pad 1
~akaiPad1Off = MIDIFunc.noteOff( { arg val; x.set( \gate, 0 ) }, 36, 0, 1310720 ); // listen to note off message of pad 1
~akaiKnob1 = MIDIFunc.cc( { arg val; x.set( \freq, val.midicps ) }, 1, 0, 1310720 ); // listen to any note on message


( // smoothing the midi
SynthDef( \sinePadLag, { |freq=500, gate=0, velocity=1, out=0, amp=1|
   Out.ar( out, EnvGen.kr( Env.adsr, gate, velocity ) * SinOsc.ar( freq.lag(0.1,0.5), 0, amp ) );
}).add;
);
x = Synth.new( \sinePadLag );


// remove the functions again:
~akaiPad1On.free;
~akaiPad1Off.free;
~akaiKnob1.free;

// the same with MIDIdef's:

MIDIdef.noteOn( \akaiPad1On, { arg val; x.set( \gate, 1, \velocity, val/127 ) }, 36, 0, 1310720 ); // listen to note on message of pad 1
MIDIdef.noteOff( \akaiPad1Off, { arg val; x.set( \gate, 0 ) }, 36, 0, 1310720 ); // listen to note off message of pad 1
MIDIdef.cc( \akaiKnob1 , { arg val; x.set( \freq, val.midicps ) }, 1, 0, 1310720 ); // listen to any note on message

// show all MIDIdefs that you made:
MIDIdef.all

// free all MIDIdef's
MIDIdef.freeAll;


// the same with MIDIResponders (for 3.4)
// note that the order of arguments into the function is different from MIDIFunc/MIDIdef:
~akaiKnob1resp = CCResponder( { arg src, chan, num, val; x.set( \freq, val.midicps ) }, 1572864, 0, 1 );
~akaiNoteOn1resp = NoteOnResponder( { arg src, chan, num, val; x.set( \gate, 1, \velocity, val/127 ) }, 1572864, 0, 36 );
~akaiNoteOff1resp = NoteOffResponder( { arg src, chan, num, val; x.set( \gate, 0 ) }, 1572864, 0, 36 );


// remove the responders
~akaiKnob1resp.remove;
~akaiNoteOn1resp.remove;
~akaiNoteOff1resp.remove;

// free the synth:
x.free


/// example 2 - different pads create different notes:

// check what each pad produces:
MIDIFunc.trace;

// pad 1:
MIDI Message Received:
	type: noteOn
	src: 1572864
	chan: 0
	num: 36
	val: 100

MIDI Message Received:
	type: noteOff
	src: 1572864
	chan: 0
	num: 36
	val: 127

// pad 2:
MIDI Message Received:
	type: noteOn
	src: 1572864
	chan: 0
	num: 37
	val: 30

MIDI Message Received:
	type: noteOff
	src: 1572864
	chan: 0
	num: 37
	val: 127

// pad 3 - 8:
// notes 38 - 43

// so we have the notes: 36 - 43

(
SynthDef( \sinePad, { |freq=500, gate=0, velocity=1, out=0, amp=1|
   Out.ar( out, EnvGen.kr( Env.adsr, gate, velocity ) * SinOsc.ar( freq, 0, amp ) );
}).add;
);

x = Synth.new( \sinePad );

// create a noteOn MIDIdef that reacts to a range of note numbers:
MIDIdef.noteOn( \akaiPad1On, { arg val, num; x.set( \gate, 1, \velocity, val/127, \freq, (num + 24).midicps ) }, (36..43), 0, 1310720 ); // listen to note on message of all pads
MIDIdef.noteOff( \akaiPad1Off, { arg val; x.set( \gate, 0 ) }, (36..43), 0, 1310720 ); // listen to note off message of all pads

// remove them again
MIDIdef.freeAll;

// the same with MIDIResponders
~akaiNoteOnresp = NoteOnResponder( { arg src, chan, num, val; x.set( \gate, 1, \velocity, val/127, \freq, (num + 24).midicps ) }, 1572864, 0, (36..43) );
~akaiNoteOffresp = NoteOffResponder( { arg src, chan, num, val; x.set( \gate, 0 ) }, 1572864, 0, (36..43) );

// remove them again:
~akaiNoteOnresp.remove;
~akaiNoteOffresp.remove;

// free the synth:
x.free


// however this is monophonic....

/// example 3

// to make it polyphonic, we need to do a little bit of bookkeeping and change the synth

(
SynthDef( \sinePadOnce, { |freq=500, gate=0, velocity=1, out=0, amp=1|
   Out.ar( out, EnvGen.kr( Env.adsr, gate, velocity, doneAction: 2 ) * SinOsc.ar( freq, 0, amp ) );
}).add;
);

// a dictionary to hold the different synths:
~padSynths = IdentityDictionary.new;

// create a noteOn MIDIdef that reacts to a range of note numbers, generates a synth for each note, and puts them in our dictionary
MIDIdef.noteOn( \akaiPad1On, { arg val, num; ~padSynths.put( num, Synth.new( \sinePadOnce , [\gate, 1, \velocity, val/127, \freq, (num + 24).midicps ] ) ) }, (36..43), 0, 1310720 ); // listen to note on message of all pads
MIDIdef.noteOff( \akaiPad1Off, { arg val, num; ~padSynths.at( num ).set( \gate, 0 ) }, (36..43), 0, 1310720 ); // listen to note off message of all pads

~padSynths;

// remove them again
MIDIdef.freeAll;


// the same with MIDIResponders
~akaiNoteOnresp = NoteOnResponder( { arg src, chan, num, val; ~padSynths.put( num, Synth.new( \sinePadOnce , [\gate, 1, \velocity, val/127, \freq, (num + 24).midicps ] ) ) }, 1572864, 0, (36..43) );
~akaiNoteOffresp = NoteOffResponder( { arg src, chan, num, val; ~padSynths.at( num ).set( \gate, 0 ) }, 1572864, 0, (36..43) );

// remove them again:
~akaiNoteOnresp.remove;
~akaiNoteOffresp.remove;
