MIDIIn.connectAll;
s.boot;

//MIDIFunc.trace( true );
//MIDIFunc.trace( false );

s.doWhenBooted( {
(
~curProg = 0;
~noteOn = IdentityDictionary.new;
~noteOff = IdentityDictionary.new;

      SynthDef( \pad, { |out=0, freq=500, dur=1, amp=0.5, pan=0, gate=0| Out.ar( out, Pan2.ar( SinOsc.ar( freq * LFNoise1.ar( 400, 0.05, 1 ), 0, amp * LFNoise1.kr( 200, 0.7, 1 ) ) * EnvGen.kr( Env.adsr, gate, timeScale: dur, doneAction: 2 ), pan ) * AmpComp.kr( freq ) ) } ).add;

SynthDef( \note, { |out=0, freq=500, dur=1, amp=0.5, pan=0, gate=0| Out.ar( out, Pan2.ar( SinOsc.ar( freq * [3/4,1,4/3], 0, amp/3 ).sum * EnvGen.kr( Env.sine, timeScale: dur, doneAction: 2 ), pan ) * AmpComp.kr( freq ) ) } ).add;

SynthDef( \note2, { |out=0, freq=500, dur=1, amp=0.5, pan=0, rq=0.05, gate=0| Out.ar( out, Pan2.ar( BPF.ar( WhiteNoise.ar, freq * [3/4,1,4/3], rq, amp * 40 ).sum * EnvGen.kr( Env.sine, timeScale: dur, doneAction: 2 ), pan ) * AmpComp.kr( freq, 50 ) ) } ).add;

SynthDef( \note3, { |out=0, freq=500, dur=1, amp=0.5, pan=0, rq=0.002, gate=0, dens=500, decay=0.8| Out.ar( out, Pan2.ar( CombL.ar( Resonz.ar( Dust.ar( dens ), freq * [3/4,1,4/3], rq, amp * 40 ), 0.2, Array.fill( 3, {Rand(0.05, 0.2 )} ), decay ).sum * EnvGen.kr( Env.sine, timeScale: dur, doneAction: 2 ), pan ) * AmpComp.kr( freq )  ) } ).add;

SynthDef( \note4, { |out=0, freq=500, dur=1, amp=0.5, pan=0, rq=0.2, gate=0| Out.ar( out, Pan2.ar( RHPF.ar( WhiteNoise.ar, freq * [3/4,1,4/3], rq, amp/2 ).sum  * AmpComp.kr( freq ) * EnvGen.kr( Env.perc, timeScale: dur, doneAction: 2 ), pan )  ) } ).add;

~synths = IdentityDictionary.new;

~notes = IdentityDictionary.new;
~notes2 = IdentityDictionary.new;
~notes3 = IdentityDictionary.new;
~notes4 = IdentityDictionary.new;


~sequence = List.new;
~sequence2 = List.new;
~sequence3 = List.new;
~sequence4 = List.new;

      ~padout = 0;
);


(
// layer 1, just play note
~noteOn.put( 4, { |note,val|
   ~synths.put( note, Synth.new( \pad, [ \out, ~padout, \freq, (note%12 * 2.5 + 72).midicps, \amp, val.linlin( 0,127, 0,0.2), \dur, val.linexp( 0, 127, 0.01, 1 ), \gate, 1 ]) );
   ~sequence = ~sequence.drop(-1);
  // ~sequence.postln;
} );

~noteOff.put( 4, { |note,val| ~synths.at( note ).set( \gate, 0 ) } );
);

(
// layer 1, just play note
~noteOn.put( 5, { |note,val|
   ~synths.put( note, Synth.new( \pad, [ \out,  ~padout, \freq, (note%12 * 2.5 + 72).midicps, \amp, val.linlin( 0,127, 0,0.2), \dur, val.linexp( 0, 127, 0.01, 1 ), \gate, 1 ]) );
   ~sequence2 = ~sequence2.drop(-1);
} );

~noteOff.put( 5, { |note,val| ~synths.at( note ).set( \gate, 0 ) } );
);

(
// layer 1, just play note
~noteOn.put( 6, { |note,val|
   ~synths.put( note, Synth.new( \pad, [ \out,  ~padout, \freq, (note%12 * 2.5 + 72).midicps, \amp, val.linlin( 0,127, 0,0.2), \dur, val.linexp( 0, 127, 0.01, 1 ), \gate, 1 ]) );
   ~sequence3 = ~sequence3.drop(-1);
} );

~noteOff.put( 6, { |note,val| ~synths.at( note ).set( \gate, 0 ) } );
);

(
// layer 1, just play note
~noteOn.put( 7, { |note,val|
   ~synths.put( note, Synth.new( \pad, [  \out,  ~padout, \freq, (note%12 * 2.5 + 72).midicps, \amp, val.linlin( 0,127, 0,0.2), \dur, val.linexp( 0, 127, 0.01, 1 ), \gate, 1 ]) );
   ~sequence4 = ~sequence4.drop(-1);
} );

~noteOff.put( 7, { |note,val| ~synths.at( note ).set( \gate, 0 ) } );
);



(
// layer 2, play note, record duration
~noteOn.put( 0, { |note,val|
   ~synths.put( note, Synth.new( \pad, [  \out, ~padout, \freq, (note%12 * 2.5 + 64).midicps, \amp, val.linlin( 0,127, 0,0.2), \dur, val.linexp( 0, 127, 0.01, 1 ), \gate, 1 ] ) );
   ~notes.put( note, ( timeOn: Process.elapsedTime, velocity: val, note: note ) );
   ~sequence = ~sequence.addFirst( note ).keep( 8 );
} );

~noteOff.put( 0, { |note,val| ~synths.at( note ).set( \gate, 0 ); ~notes.at( note ).put( \timeOff, Process.elapsedTime ); } );
);

(
// layer 2, play note, record duration
~noteOn.put( 1, { |note,val|
   ~synths.put( note, Synth.new( \pad, [  \out, ~padout, \freq, (note%12 * 2.5 + 64).midicps, \amp, val.linlin( 0,127, 0,0.2), \dur, val.linexp( 0, 127, 0.01, 1 ), \gate, 1 ] ) );
   ~notes2.put( note, ( timeOn: Process.elapsedTime, velocity: val, note: note ) );
   ~sequence2 = ~sequence2.addFirst( note ).keep( 8 );
} );

~noteOff.put( 1, { |note,val| ~synths.at( note ).set( \gate, 0 ); ~notes2.at( note ).put( \timeOff, Process.elapsedTime ); } );
);

(
// layer 2, play note, record duration
~noteOn.put( 2, { |note,val|
   ~synths.put( note, Synth.new( \pad, [  \out, ~padout, \freq, (note%12 * 2.5 + 64).midicps, \amp, val.linlin( 0,127, 0,0.2), \dur, val.linexp( 0, 127, 0.01, 1 ), \gate, 1 ] ) );
   ~notes3.put( note, ( timeOn: Process.elapsedTime, velocity: val, note: note ) );
   ~sequence3 = ~sequence3.addFirst( note ).keep( 8 );
} );

~noteOff.put( 2, { |note,val| ~synths.at( note ).set( \gate, 0 ); ~notes3.at( note ).put( \timeOff, Process.elapsedTime ); } );
);

(
// layer 4, play note, record duration
~noteOn.put( 3, { |note,val|
   ~synths.put( note, Synth.new( \pad, [  \out, ~padout, \freq, (note%12 * 2.5 + 64).midicps, \amp, val.linlin( 0,127, 0,0.2), \dur, val.linexp( 0, 127, 0.01, 1 ), \gate, 1 ] ) );
   ~notes4.put( note, ( timeOn: Process.elapsedTime, velocity: val, note: note ) );
   ~sequence4 = ~sequence4.addFirst( note ).keep( 8 );
} );

~noteOff.put( 3, { |note,val| ~synths.at( note ).set( \gate, 0 ); ~notes4.at( note ).put( \timeOff, Process.elapsedTime ); } );
);


(
MIDIdef.noteOn( \akaiPadsOn, { arg val, note; ["on", ~curProg, val,note].postln; ~noteOn[ ~curProg ].value( note, val ) }, (36..43), 0 ); // listen to note on
MIDIdef.noteOff( \akaiPadsOff, { arg val, note; ["off",~curProg, val,note].postln; ~noteOff[ ~curProg ].value( note )}, (36..43), 0 ); // listen to note off

MIDIdef.program( \akaiProg, { arg val; ~curProg = val; } );

MIDIdef.cc( \speed, { |val,cc| ~speeds.put( cc, val ) }, (1..4) );
MIDIdef.cc( \pitch, { |val,cc| ~pitches.put( cc, val ) }, (5..8) );
);

~speeds = IdentityDictionary.new;
~pitches = IdentityDictionary.new;

   (1..4).do{ |it| ~speeds.put( it, 64 ); ~pitches.put( it+4, 64 ) };

~midiMap = [0,127, \linear, 1].asSpec;
~speedMap = [0.1,10,\exponential].asSpec;

(
Tdef( \playNotesAgain, { loop{
   //~sequence.postln;
   ~sequence.reverseDo{ |it|
      if ( ~notes[it].notNil ){
      if ( ~notes[it][\timeOff].notNil ){
            Synth.new( \note, [ \freq, (~notes[ it ].at( \note )%12 * 2 + ~pitches[5]).midicps, \dur, ( ~notes[it].at( \timeOff ) - ~notes[it].at( \timeOn ) ) * 2 * ~speedMap.map( ~midiMap.unmap( ~speeds[1] ) ) , \amp, ~notes[it].at( \velocity).linlin( 0, 127, 0, 0.5 ) ] );
            ( ( ~notes[it].at( \timeOff ) - ~notes[it][ \timeOn ] ) * ~speedMap.map( ~midiMap.unmap( ~speeds[1] ) ) ).wait;
      };
      };
   }; 0.05.wait; }
}).play;
);

(
Tdef( \playNotesAgain2, { loop{
   //~sequence2.postln;
   ~sequence2.reverseDo{ |it|
      if ( ~notes2[it].notNil ){
      if ( ~notes2[it][\timeOff].notNil ){
         Synth.new( \note2, [ \rq, 0.01, \freq, (~notes2[ it ].at( \note )%12 * 2 + ~pitches[6]).midicps, \dur, ( ~notes2[it].at( \timeOff ) - ~notes2[it].at( \timeOn ) ) * ~speedMap.map( ~midiMap.unmap( ~speeds[2] ) ) / 2, \amp, ~notes2[it].at( \velocity).linlin( 0, 127, 0, 0.5 ) ] );
         ( ( ~notes2[it].at( \timeOff ) - ~notes2[it][ \timeOn ] ) * ~speedMap.map( ~midiMap.unmap( ~speeds[2] ) ) ).wait;
      };
      };
   }; 0.05.wait; }
}).play;
);

(
Tdef( \playNotesAgain3, { loop{
   //~sequence3.postln;
   ~sequence3.reverseDo{ |it|
      if ( ~notes3[it].notNil ){
      if ( ~notes3[it][\timeOff].notNil ){
         Synth.new( \note3, [ \rq, 0.01, \freq, (~notes3[ it ].at( \note )%12 * 2 + ~pitches[7]).midicps, \dur, ( ~notes3[it].at( \timeOff ) - ~notes3[it].at( \timeOn ) ) * ~speedMap.map( ~midiMap.unmap( ~speeds[3] ) ) * 4, \amp, ~notes3[it].at( \velocity).linlin( 0, 127, 0, 0.5 ) ] );
         ( ( ~notes3[it].at( \timeOff ) - ~notes3[it][ \timeOn ] ) * ~speedMap.map( ~midiMap.unmap( ~speeds[3] ) ) ).wait;
      };
      };
   }; 0.05.wait; }
}).play;
);

(
Tdef( \playNotesAgain4, { loop{
   //~sequence4.postln;
   ~sequence4.reverseDo{ |it|
      if ( ~notes4[it].notNil ){
      if ( ~notes4[it][\timeOff].notNil ){
         Synth.new( \note4, [ \rq, 0.01, \freq, (~notes4[ it ].at( \note )%12 * 2 + ~pitches[8]).midicps, \dur, ( ~notes4[it].at( \timeOff ) - ~notes4[it].at( \timeOn ) ) * ~speedMap.map( ~midiMap.unmap( ~speeds[4] ) ) / 6, \amp, ~notes4[it].at( \velocity).linlin( 0, 127, 0, 0.5 ) ] );
         ( ( ~notes4[it].at( \timeOff ) - ~notes4[it][ \timeOn ] ) * ~speedMap.map( ~midiMap.unmap( ~speeds[4] ) ) ).wait;
      };
      };
   }; 0.05.wait; }
}).play;
);
//~notes

TdefAllGui.new;
});