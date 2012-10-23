// Some controllers are physically dependent on each other, that is you cannot move one, without changing the value of the other.

// For example, when you move the x-axis of a joystick, you will usually also cause (small) changes in the y-axis.
// So in the design of the instrument, you need to keep this in mind; the axes will need to be used together.
// For example, rather than using x and y, you could use them with polar coordinates, and use the radius (how far out the joystick is moved) and the angle as controls.

// find the right device in the list:
a = GeneralHID.open( GeneralHID.findBy( 1103, 53251 ); );


// find a spec defined previously for this device (this is what we'll use in our basic setup file for the device)
c = a.findSpec;
// set it:
a.setSpec( c[0] );

b = IdentityDictionary.new;

b.put( \midvalue, 0.50196078431373 );
b.put( \dx, a[\lx].value - b[\midvalue] );
b.put( \dy, a[\ly].value - b[\midvalue] );
b.put( \angleSpec,    [-pi,pi,\linear].asSpec );



a[\lx].action = { |slot| b.put( \dx, slot.value - b[\midvalue] ); b.put( \r, (b[\dy].pow(2) + b[\dx].pow(2) ).sqrt ); b.put( \angle, b[\dy].atan2(b[\dx] ) ); [ b[\r], b[\angle] ].postln; };
a[\ly].action = { |slot| b.put( \dy, slot.value - b[\midvalue] ); b.put( \r, (b[\dy].pow(2) + b[\dx].pow(2) ).sqrt ); b.put( \angle, b[\dy].atan2(b[\dx] ) ); [ b[\r], b[\angle] ].postln; };

SynthDef( \testSynth, { |out=0, amp=0.1, freq=500| Out.ar( out, SinOsc.ar( freq.lag(0.1), 0, amp.lag(0.1) ) ) } ).add;

x = Synth.new( \testSynth );

a[\lx].action = { |slot| b.put( \dx, slot.value - b[\midvalue] ); b.put( \r, (b[\dy].pow(2) + b[\dx].pow(2) ).sqrt ); b.put( \angle, b[\dy].atan2(b[\dx] ) ); x.set( \amp, b[\r]/3, \freq, 2* \midfreq.asSpec.map( sin( b[\angle] / 2 ).abs ).postln ) };

a[\ly].action = { |slot| b.put( \dy, slot.value - b[\midvalue] ); b.put( \r, (b[\dy].pow(2) + b[\dx].pow(2) ).sqrt ); b.put( \angle, b[\dy].atan2(b[\dx] ) ); x.set( \amp, b[\r] /3, \freq, 2 *\midfreq.asSpec.map( sin( b[\angle] / 2 ).abs; ).postln; )};


x.free;

// A similar case is a triple-axis accelerometer, with x, y, z axes...


