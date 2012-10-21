/// Buttons

// Buttons can be used in various ways...

// most buttons have a default state (off), and a state when they are pressed (on).

MIDIIn.connectAll;


// ---------------- on - off --------------

// the simplest version is just on-off

SynthDef( \testSynth, { |out=0,on=0| Out.ar( out, SinOsc.ar( 440, 0, on * 0.1 ) ) } ).add;
x = Synth.new( \testSynth );

MIDIdef.noteOn( \akaiPad1On, { arg val; x.set( \on, 1 ); }, 36, 0, 1310720 ); // listen to note on
MIDIdef.noteOff( \akaiPad1Off, { arg val; x.set( \on, 0 ); }, 36, 0, 1310720 ); // listen to note on


// --------------- toggle -------------

// next one up is a toggle:
MIDIdef.freeAll;

~buttonState = 0;
MIDIdef.noteOn( \akaiPad1On, { arg val; ~buttonState = (~buttonState + 1).mod(2); x.set( \on, ~buttonState ); }, 36, 0, 1310720 ); // listen to note on

// clean up:
x.free;

// ------------- multistate ----------

// a toggle presents two different states that the button can be in, you can also have more states, advancing to the next state each time you press the button:

SynthDef( \testSynth2, { |out=0,select=0| Out.ar( out, Select.ar( select, [ SinOsc.ar( 440, 0, 0.1 ), Saw.ar( 440, 0.1 ), Pulse.ar( 440, 0.5, 0.1 ), WhiteNoise.ar( 0.1 ), PinkNoise.ar(0.1) ] ) ) } ).add;
x = Synth.new( \testSynth2 );

~buttonMultiState = 0;
MIDIdef.noteOn( \akaiPad1On, { arg val; ~buttonMultiState = (~buttonMultiState + 1).mod(5); x.set( \select, ~buttonMultiState ); }, 36, 0, 1310720 ); // listen to note on


// clean up:
x.free;


// ----------- tracking multiple clicks ----------

// You can also make actions dependent on multiple clicks on the same button, e.g. different actions for a double-click or triple-click, or use the time between clicks as a control value, or make a difference between a soft click before a hard one, and vice versa (if the button is sensitive to how hard you press it).

// the code below records the time between clicks, and for every click that is within a maximum time of a previous click (0.2), it records the time between the clicks (clickDeltas), the number of clicks, and the velocity of the clicks.

(
~multiclick = IdentityDictionary.new;
~multiclick.put( \clicks, 0 );
~multiclick.put( \clickDeltas, List.new );
~multiclick.put( \clickTimes, IdentityDictionary.new );
~multiclick.put( \clickVals, IdentityDictionary.new );
~multiclick.put( \maxClickDelta, 0.2 );
(
~multiclick.put( \timeOut, Task( {
   var clickcount;
   ~multiclick[\maxClickDelta].wait; "timeout".postln;
   // value of multiclick
   clickcount = ~multiclick[\clicks];
   // put an action based on the result of the multiclick here:
   [clickcount, ~multiclick[\clickVals], ~multiclick[ \clickTimes ], ~multiclick[ \clickDeltas ] ].postln;
   // reset variables:
   ~multiclick.put( \clicks, 0 );
   ~multiclick.put( \clickTimes, IdentityDictionary.new );
   ~multiclick.put( \clickVals, IdentityDictionary.new );
   ~multiclick.put( \clickDeltas, List.new );
} ) );
);
);

(
MIDIdef.noteOn( \akaiPad1On, { arg val;
   var thisTime = Process.elapsedTime;
//   if ( ~multiclick[ \clicks ] > 0 ){ ~multiclick };
   if ( ~multiclick[ \clicks ] > 0 ){
      ~multiclick[ \clickDeltas ].add( thisTime - ~multiclick[ \clickTimes ][ ~multiclick[ \clicks ] ] )
   };
   ~multiclick[ \clicks ] = ~multiclick[\clicks] + 1;
   ~multiclick[ \clickTimes ].put( ~multiclick[\clicks], thisTime );
   ~multiclick[ \clickVals ].put( ~multiclick[\clicks], val );
   ~multiclick[\timeOut].stop.reset.play;
   ~multiclick.put( \lastTime, thisTime );
   ~multiclick[\clicks].postln;
}, 36, 0, 1310720 ); // listen to note on
)


// ------------------ buttons in relationship to each other --------------

// You could extend the concept above to button presses on different buttons, so creating "key-combos", like in games where you have special actions dependent on using a specific control-sequence.


// -------------- modal control, a button press selects a mode for another control --------

// You can also use buttons to select between different modes of control, or to shift control from one controller to another.