/// Mapping data

/// What is mapping?

/// the relationship between incoming data and resulting sound of the parameters

/// most simple mapping:

MIDIIn.connectAll;
s.boot;

SynthDef( \testSynth, { |out=0,on=0| Out.ar( out, SinOsc.ar( 440, 0, on * 0.1 ) ) } ).add;
x = Synth.new( \testSynth );

~akaiNoteOn1resp = NoteOnResponder( { arg src, chan, num, val; x.set( \on, 1 ) }, 1310720, 0, 36 ).add;
~akaiNoteOff1resp = NoteOffResponder( { arg src, chan, num, val; x.set( \on, 0 ) }, 1310720, 0, 36 ).add;

// button press turns the sound on
// button release turns sound off

(
~akaiNoteOn1resp.remove;
~akaiNoteOff1resp.remove;
x.free;
);

// slightly more complex:

SynthDef( \testSynth2, { |out=0,on=0,amp=0| Out.ar( out, SinOsc.ar( 440, 0, on * amp ) ) } ).add;
x = Synth.new( \testSynth2 );

~akaiNoteOn1resp = NoteOnResponder( { arg src, chan, num, val; x.set( \on, 1, \amp, val/127 ) }, 1310720, 0, 36 ).add;
~akaiNoteOff1resp = NoteOffResponder( { arg src, chan, num, val; x.set( \on, 0 ) }, 1310720, 0, 36 ).add;

// button press turns the sound on, velocity determines amplitude
// button release turns sound off

(
~akaiNoteOn1resp.remove;
~akaiNoteOff1resp.remove;
x.free;
);

/// mapping the range of data coming in

/// usually useful to map the incoming data to a range between 0 and 1, and then map it again to a range that is suitable for the parameter you want to control

~midiSpec = [0, 127, \linear, 1].asSpec; // returns a control spec that ranges between 0 and 127 in a linear fashion

// lowest value:
~midiSpec.map( 0 );

// highest value:
~midiSpec.map( 1 );

// mid value:
~midiSpec.map( 0.5 );

// mapping from the midi input to 0-1:
~midiSpec.unmap( 80 );

~midiSpec.unmap( 127 );


x = Synth.new( \testSynth2 );

MIDIdef.noteOn( \akaiPad1On, { arg val; x.set( \on, 1, \amp, ~midiSpec.unmap( val ) ) }, 36, 0, 1310720 ); // listen to note on message of pad 1
MIDIdef.noteOff( \akaiPad1Off, { arg val; x.set( \on, 0 ) }, 36, 0, 1310720 ); // listen to note off message of pad 1

// now 1 is quite loud for a sinewave, rather we would like the range to be between 0.001 and 0.5 and exponential

~ampSpec = [0.01, 0.5, \exponential ].asSpec;

~ampSpec.map( (0..100)/100 ).plot;

MIDIdef.noteOn( \akaiPad1On, { arg val; x.set( \on, 1, \amp, ~ampSpec.map( ~midiSpec.unmap( val ) ) ) }, 36, 0, 1310720 ); // listen to note on message of


/// but basically mapping can refer to any kind of relationship, there can be quite complex algorithms in between the input data and the output data

// a mapping is always arbitrary!

MIDIdef.freeAll;
x.free;