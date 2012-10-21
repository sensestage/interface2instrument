/// Accessing HID devices in SuperCollider on the server side

s.boot;

// On the Server side there are special UGens that can access the Mouse or the Keyboard:

(
SynthDef( \mousexyb, { |out=0|
	var mousex, mousey, mousebutton;
	mousex = MouseX.kr( 500, 1000 ); // this will determine the frequency of the sound (minimum value, maximum value, warp, lag)
	mousey = MouseY.kr( 0, 0.3 ); // this will determine the amplitude of the sound
	mousebutton = MouseButton.kr( 0, 1, 2 ); // this will turn the sound on or off (minimum value, maximum value, lag)
	Out.ar( out, SinOsc.ar( mousex, 0, mousey ) * mousebutton );
}).add
)

s.meter;
x = Synth.new( \mousexyb );
x.free;

// Using the mouse controls is often a good method to find interesting values for frequencies while designing a sound, but can sometimes interfer with controlling your computer!

(
SynthDef( \mousepoll, { |out=0|
	var mousex;
	mousex = MouseX.kr( 500, 10000, \exponential ).poll; // .poll will print the current value
	Out.ar( out, SinOsc.ar( mousex, 0, 0.1 ) );
}).add
)

y = Synth.new( \mousepoll );
y.free;


/// KeyState:

// execute the code below to find out a key's keycode
// the char and keycode of any key you press will be printed in the post window
(
w = Window.new("I catch keystrokes");
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;  [char, keycode].postln; };
w.front;
)

// then execute this and then type "supercollider" in the window
(
w.front; // something safe to type on
{ Mix.new( SinOsc.ar(
	Array.geom(13, 1, 1.2)*500, 0,
	KeyState.kr(
		[ 39, 30, 33, 26, 27, 54, 32, 46, 46, 31, 40, 26, 27 ], 0, 0.1)
) ) }.play
)


// KeyState.kr( keycode,  )

// You can also use GUI windows to capture keystrokes (as shown in the example), and capture mouse events. We will not go into this right now.

