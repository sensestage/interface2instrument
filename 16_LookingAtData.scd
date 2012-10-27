/// Plotting data:

// from the SenseWorld Quark
SWPlotterMonitor

MIDIIn.connectAll;

~midiNote = 24;
~midiVel = 0;
MIDIdef.noteOn( \akaiPadsOn, { arg val, note; ~midiNote = note; ~midiVel = val; }, (36..43), 0 ); // listen to note on

~midiNote
~midiVel

// look at the data
m = SWPlotterMonitor.new( {
    //data to plot
    [ ~midiNote, ~midiVel ] },
    200, //nr of points to plot
    2, // channels
    0.025, // plot dtime
    10 // write every n data points
    ).start;

m.stop;