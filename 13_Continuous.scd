// "continuous" controllers include things like Sliders/Faders, Knobs, Joystick axes, and so on.
// The controllers output a range of values based on the position they are in.

// For MIDI controllers these are usually CC - continuous control - messages.
// Continuous however in the MIDI world means that the controller can have 127 values.

// On Game devices the resolution of continuous controls may vary, they can be 8 bit, 10 bit or even higher.
// Usually advanced game controllers, give you higher accuracy (with increasing cost).


MIDIIn.connectAll;
s.boot;

/*
MIDIFunc.trace( true );
MIDIFunc.trace( false );
*/

// -------- mapping ranges -----------

// between 0 and 127
MIDIdef.cc( \fader1, { |val| val.postln; }, 13, 0 );

// linear, scaling to a range between 0 and 1
MIDIdef.cc( \fader1, { |val| (val/127).postln; }, 13, 0 );

// or:
Spec.add( \midicc, [0,127,\linear].asSpec )

MIDIdef.cc( \fader1, { |val| \midicc.asSpec.unmap( val ).postln; }, 13, 0 );

// or (slightly more efficient)
~midicc = [0,127,\linear].asSpec;

MIDIdef.cc( \fader1, { |val| ~midicc.unmap( val ).postln; }, 13, 0 );


// scaling to an output range:
~outRange = [0,2,\linear].asSpec;
MIDIdef.cc( \fader1, { |val| ~outRange.map( ~midicc.unmap( val ) ).postln; }, 13, 0 );

// exponential - dbamp

~outRange = [0.001,100,\exponential].asSpec;
MIDIdef.cc( \fader1, { |val| ~outRange.map( ~midicc.unmap( val ) ).postln; }, 13, 0 );

// default specs:
Spec.specs.keys.postcs;

MIDIdef.cc( \fader1, { |val| \freq.asSpec.map( ~midicc.unmap( val ) ).postln; }, 13, 0 );

MIDIdef.cc( \fader1, { |val| \db.asSpec.map( ~midicc.unmap( val ) ).postln; }, 13, 0 );

// plotting a spec:

( (0..127).collect{ |i| \freq.asSpec.map( i / 127 ) } ).plot;
( (0..127).collect{ |i| \midfreq.asSpec.map( i / 127 ) } ).plot;


SynthDef( \testSynth, { |out=0, freq=440, amp=0.1| Out.ar( out, SinOsc.ar( freq, 0, amp ) ) } ).add;

x = Synth.new( \testSynth );

MIDIdef.cc( \fader1, { |val| x.set( \freq, \freq.asSpec.map( ~midicc.unmap( val ) ).postln ) }, 13, 0 );

x.free;

// add some smoothing
SynthDef( \testSynth, { |out=0, freq=440, amp=0.1| Out.ar( out, SinOsc.ar( freq.lag(0.1), 0, amp.lag(0.1) ) ) } ).add;

x = Synth.new( \testSynth );

// use value as midi note number:
MIDIdef.cc( \fader1, { |val| x.set( \freq, val.midicps.postln ) }, 13, 0 );

// also change the amplitude, higher and louder!
MIDIdef.cc( \fader1, { |val| x.set( \freq, val.midicps, \amp, \db.asSpec.map( ~midicc.unmap( val ) ).dbamp; ) }, 13, 0 );

x.free;

// -------- using a function ---------

( (0..127).collect{ |i| (i*pi/127).sin } ).plot;

x = Synth.new( \testSynth );

MIDIdef.cc( \fader1, { |val| x.set( \freq, val.midicps, \amp, \db.asSpec.map( (val*pi/127).sin ).dbamp / 4 + 0.1 ) }, 13, 0 );

x.free;

// -------- behaviour changes in different regions of the controller ---------

// on the lower end of the slider it controls the frequency of the synth, in the upper end it changes the amplitude based on the sine function we used above.
MIDIdef.cc( \fader1, { |val| if ( val < 64 ){ x.set(\freq, (val+40).midicps ); }{ x.set( \amp, \db.asSpec.map( (val-64 * pi / 64).sin ).dbamp / 4 + 0.1 ) } }, 13, 0 );
x = Synth.new( \testSynth );

// my slider sometimes misses some midi cc values, creating different tones, depending on how fast I move the slider...


// table lookup

a = Array.fill( 128, { 1.0.rand } );

MIDIdef.cc( \fader1, { |val| x.set( \freq, \midfreq.asSpec.map( a[val] ) ) }, 13, 0 );

a = Array.geom( 128, 10, 1.05 );

MIDIdef.cc( \fader1, { |val| x.set( \freq, a[val] + 100 ) }, 13, 0 );

a = Array.series( 128, 20, 0.5 );

MIDIdef.cc( \fader1, { |val| x.set( \freq, a[val].midicps ) }, 13, 0 );

a = Array.fill( 128, { 1.0.rand } );
32.do{ |it| a.put( it, (it*pi/127).sin ) };
32.do{ |it| a.put( it + 45, (it+45*pi/127).sin ) };
32.do{ |it| a.put( it + 90, (it+90*pi/127).sin ) };
a.plot

MIDIdef.cc( \fader1, { |val| x.set( \freq, \midfreq.asSpec.map( a[val] ) ) }, 13, 0 );

// the "wslib" quark provides a nice way of defining different specs/warps... SegWarp

// fold in the center:
	a = SegWarp([0,1,0]);
	a.map( 0.5 ); // -> 1
	a.map( [0,1] ); // -> [0,0]
	a.map( 0.25 ); // -> 0.5

	// format of input array:
	// [ [ value, position (0-1), warp to next ], ... ]


	// frequency with fixed center (440)
	a = SegWarp([[20,0.5,\exp], [440,0,\exp], [22050,1]]);
   a.map( 0.5 ); // -> 440
	a.map( [0,1] ); // -> [20,22050]
	a.map( 0.25 ); // -> 0.5
	a.unmap( 220 ); // -> 0.38787808789121
	a.unmap( 880 ); // -> 0.58854052996238
	a.env.plot;

	// use an Env
	a = SegWarp( Env([0,1,1,0], [0.3,0.4,0.3]) );
	a.map( 0.5 );

a = SegWarp([[100,0.5,\exp], [440, 0.3,\exp], [3000,1,\exp]]);
a.env.plot;

MIDIdef.cc( \fader1, { |val| x.set( \freq, a.map( val/127 ) ) }, 13, 0 );

x.free;

// -------- rate of change -------------

a = IdentityDictionary.new;
a.put( \newTime, Process.elapsedTime );
a.put( \newValue, 0 );

x = Synth.new( \testSynth );

MIDIdef.cc( \fader1, { |val| a[\lastValue] = a[\newValue]; a[\newValue] = val; a[\lastTime] = a[\newTime]; a[\newTime] = Process.elapsedTime; a[\rateOfChange] = ( a[\newValue] - a[\lastValue] )/(a[\newTime] - a[\lastTime] ); a[\rateOfChange].postln; x.set( \amp, a[\rateOfChange].abs / 1000 ) }, 13, 0 );

x.free;

// -------- statistics -------------

// using statistics methods from the MathLib quark:

a = Array.fill( 100, 0 );


x = Synth.new( \testSynth );

MIDIdef.cc( \fader1, { |val| var b; a = a.addFirst( val ).keep( 100 ); b = a.mean.postln; x.set( \freq, \midfreq.asSpec.map( b/127 ) ) }, 13, 0 );

MIDIdef.cc( \fader1, { |val| var b;  a = a.addFirst( val ).keep( 100 ); b = a.stdDev.postln; x.set( \amp, b/127 ) }, 13, 0 );

// time based:

Tdef( \mean, { |ev| loop{ ev.myList = ev.myList.addFirst( ev.newValue ).keep( ev.length ); ev.myMean = ev.myList.mean; ev.myMean.postln; x.set( \freq, ev.myMean.midicps.postln ); ev.updateTime.wait; } } ).set( \length, 20, \updateTime, 0.1, \newValue, 0, \myList, Array.fill( 20, 0 ) );
MIDIdef.cc( \fader1, { |val| Tdef(\mean ).set( \newValue, val ); }, 13, 0 );
Tdef( \mean ).play;

Tdef( \std, { |ev| loop{ ev.myList = ev.myList.addFirst( ev.newValue ).keep( ev.length ); ev.std = ev.myList.stdDev; x.set( \amp, (ev.std/ 127) ); ev.updateTime.wait; } } ).set( \length, 20, \updateTime, 0.1, \newValue, 0, \myList, Array.fill( 20, 0 ) );
MIDIdef.cc( \fader1, { |val| Tdef(\std ).set( \newValue, val ); }, 13, 0 );
Tdef( \std ).play;

// combined:
MIDIdef.cc( \fader1, { |val| Tdef(\std ).set( \newValue, val ); Tdef(\mean ).set( \newValue, val ); }, 13, 0 );

Tdef(\std).stop; Tdef(\mean).stop;

x.free;

// -------- soft set -------------------

// if a controller is dynamically assigned to a parameter, or the parameter can also be changed by other means (e.g. code),
// then it can be useful to "soft set" the parameter, meaning the controller will only really start changing the value, once
// you moved the controller close to its current setting.

x = Synth.new( \testSynth );
~synthSettings = IdentityDictionary.new;
~synthSettings.set( \freq, 440 );

MIDIdef.cc( \fader1, { |val| ~synthSettings.softSet( \freq, val.midicps, 0.05  ); x.set(\freq, ~synthSettings[\freq] ) }, 13, 0 );

MIDIdef.cc( \fader2, { |val| ~synthSettings.softSet( \freq, val.midicps, 0.05 ); x.set(\freq, ~synthSettings[\freq] ) }, 13, 1 );

x.free;


// other ideas:

// - only use the value, when going upwards or downwards
// - use the difference between two values
// - use difference between two sliders as a control
// - use one control for rough tuning, a second for fine-tuning


// ----------- default states ----------

// Some continuous controllers have a default state, a joystick will always return to the center if you don't touch it. When mapping it is important to keep the default state in mind...