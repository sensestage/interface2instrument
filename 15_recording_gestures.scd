// Useful Quark: GamePad

// specifically CtLoop

	// a simple synth
s.boot;
Ndef(\test, { |pFreq=100, pWidth=0.5| LPF.ar(LFPulse.ar(pFreq, 0, pWidth), 1500) * 0.1 });
Ndef(\test).play;
Ndef(\test).scope;

(	// controlspecs for its params
Spec.add(\pFreq, [2, 200, \exp]);
Spec.add(\pWidth, [0.01, 0.5, \exp]);
)
	// an editor to see the params changing
NdefGui(Ndef(\test), 5);
Ndef(\test).set(\pFreq, \pFreq.asSpec.map(0.5));
Ndef(\test).set(\pWidth, \pWidth.asSpec.map(0.5));


	*new(key, ctlMap)
	// make a controlLoop to record and play back slider movement:
	// prepare for two normalized controls (range 0 - 1).
	// ctlMap defines the actions to take when a control event
	// is played back. here, \x sets the parameter \pFreq,
	// and y will set parameter \pWidth (later).
(
c = CtLoop(\mytest,
	(
	x: { |val| Ndef(\test).set(\pFreq, \pFreq.asSpec.map(val)) },
	y: { |val| Ndef(\test).set(\pWidth, \pWidth.asSpec.map(val)) }
	)
);
)

	// a gui to control one synth param, and to record movements
(
EZSlider(nil, nil, \ctLooptest, nil, { |sl|
	var normVal =  sl.value;	//
		// keep new events if recording
	c.recordEvent(\x, normVal);
		// set synth param
	Ndef(\test).set(\pFreq, \pFreq.asSpec.map(normVal))
});
)

c.startRec; 	// wiggle slider now
c.stopRec;	// stop when done

c.play;	// see slider in NodeProxyEditor for recorded movement
c.stop;


	// use the same CtLoop with a 2D controller:
(
w = Window("play me").front;
t = Slider2D(w, Rect(0,0,400,400))
	.action_({ |sl|
		var x, y; x = sl.x; y = sl.y;

		c.recordEvent(\x, x);
		c.recordEvent(\y, y);

		Ndef(\test).set(
			\pFreq, \pFreq.asSpec.map(x),
			\pWidth, \pWidth.asSpec.map(y)
		);
	});
)


c.startRec; 	// wiggle 2dslider now
c.stopRec;	// stop when done

	// playback options:
c.play;
c.togglePlay;
c.togglePlay;

	// playback is looped by default
c.reverse;
c.forward;
c.flip;	// toggle loop direction
c.flip;

c.tempo = 2;		// faster
c.tempo = 0.5;	// slower
c.tempo = 1;		// orig

	// play only part of the loop:
c.start = 0.3;	// a segment within range 0.0-1.0.
				// percentage is of the number of events, not of loop duration

c.start = 1.0.rand;	//
c.length = 1.0.rand;	//
c.length = 0.1.rand;	//

	// full loop
c.start_(0).length_(1);

	// 'sequence jitter':  loop index moves as before,
	// the actual event played is chosen within jitter range near the loop index.
c.jitter = 0.1;	// +- 10% loop length jitter
c.jitter = 0.2;
c.jitter = 0.0;	// orig. sequence

c.resetLoop;		// reset to defaults;



	// gesture range can be rescaled in several ways

	// turn on gesture rescaling
c.rescaled_(true);

c.invert;		// invert around middle axis
c.up; 		// that is right side up
c.flipInv;	// toggle inversion on/off
c.flipInv;



c.scaler = 2;		// make gesture bigger
c.scaler = 1;		// orig size
c.scaler = 0.5;	// smaller
c.scaler = 0.2;	// or even smaller

c.shift = 0.1;	// shift its range up
c.shift = 0.2;
c.shift = 0.3;
				// Q: maybe rescaling could optionally go outside the spec range?

c.resetScaling;	// back to orig


c.rescaled_(false);
c.scaler = 0.1;	// no effect when rescaled is false

c.rescaled_(true);	// should rescale to tiny now
c.scaler = 2;		// and big again.


c.dontRescale(\x);		// except a control name from rescaling
					// so here, x will not be rescaled, but y will.
c.nonRescalableCtls;

c.dontRescale(\x, \y);
c.doRescale(\x, \y);	// make sure they all rescale again

c.list;	// the list of recorded control events
c.clear;	// clear it

c.startRec; // this also clears the list;
c.stopRec;

c.list.printAll;
c.play;
