/// Methods for mapping on the server:

MIDIIn.connectAll;
s.boot;

// we use Ndef in this example, to allow for a flexible redefining of the sound on the server

Ndef( \testSynth, { arg freq=440, amp=0.1, t_trig=1, dur=1; SinOsc.ar( freq, 0, amp ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );
Ndef( \testSynth ).play;

MIDIdef.noteOn( \akaiPad1On, { arg val; Ndef( \testSynth ).set( \t_trig, 1, \amp, val/127 ) }, 36, 0, 1310720 ); // listen to note on


//// mapping ranges:

/// linlin:
Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, ampin.linlin( 0, 127, 0, 0.2 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );

MIDIdef.noteOn( \akaiPad1On, { arg val; Ndef( \testSynth ).set( \t_trig, 1, \ampin, val ) }, 36, 0, 1310720 ); // listen to note on


// linexp
Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, ampin.linexp( 0, 127, 0.0001, 0.2 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );

// explin
Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, ampin.explin( 1, 127, 0.0001, 0.2 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );

// expexp
Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, ampin.expexp( 1, 127, 0.0001, 0.2 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );

// lincurve
Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, ampin.lincurve( 0, 127, 0, 0.2, -4 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );

// curvelin
Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, ampin.curvelin( 0, 127, 0, 0.2, -4 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );


/// range:
Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, (ampin/127).range( 0, 0.2 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );

/// exprange:
Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, (ampin/127).range( 0.001, 0.2 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );


/// clipping, folding, wrapping

Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, (ampin/127).clip( 0, 0.06 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );

Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, (ampin/127).fold( 0, 0.1 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );

Ndef( \testSynth, { arg freq=440, ampin=64, t_trig=1, dur=1; SinOsc.ar( freq, 0, (ampin/127).wrap( 0, 0.1 ) ) * EnvGen.kr( Env.perc, t_trig, timeScale: dur ) } );


/// these are all direct... more interesting is also the behaviour over time:

MIDIdef.noteOn( \akaiPad1On, { arg val; Ndef( \testSynth ).set(  \amp, val/255 ) }, 36, 0, 1310720 ); // listen to note on
MIDIdef.noteOff( \akaiPad1Off, { arg val; Ndef( \testSynth ).set( \amp, 0 ) }, 36, 0, 1310720 ); // listen to note on

// lag
Ndef( \testSynth, { arg freq=440, amp=0, t_trig=1, dur=1; SinOsc.ar( freq, 0, amp.lag( 0.5 ) ) } );

// lag up down
Ndef( \testSynth, { arg freq=440, amp=0, t_trig=1, dur=1; SinOsc.ar( freq, 0, amp.lag( 0.1, 2 ) ) } );


// different curve
Ndef( \testSynth, { arg freq=440, amp=0, t_trig=1, dur=1; SinOsc.ar( freq, 0, amp.lag2( 0.1, 2 ) ) } );


// different curve...
Ndef( \testSynth, { arg freq=440, amp=0, t_trig=1, dur=1; SinOsc.ar( freq, 0, amp.lag3( 0.1, 2 ) ) } );


// variable curve
Ndef( \testSynth, { arg freq=440, amp=0, t_trig=1, dur=1; SinOsc.ar( freq, 0, amp.varlag( 0.1, -4, 4 ) ) } ); // [VarLag] ugen

// limit the slope
Ndef( \testSynth, { arg freq=440, amp=0, t_trig=1, dur=1; SinOsc.ar( freq, 0, amp.slew( 0.1, 0.2 ) ) } ); // [Slew] ugen

// Also: [Ramp]


// useful conversions for frequencies:

// midicps
// cpsmidi


Ndef( \testSynth ).clear;
MIDIdef.freeAll;
