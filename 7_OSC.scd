// OpenSoundControl (OSC):

// OSC is a new protocol that was invented in the 2000's to allow music software and devices to talk to each other.

// The protocol can support any kind of messages, and the messages are usually transported through UDP or TCP.


// SuperCollider uses OSC to communicate between the language (sclang) and the server (scsynth).
// the language can also talk to other programs, or get commands from them, or you can have several instances of the language talk to each other.
// the server can also support various clients talking to it, e.g. multiple SC-users sending messages to one scsynth instance, or other programming language (haskel, ruby, C++) talking to scsynth.


// SuperCollider opens up an OSC-port at startup; normally this is port 57120, but when this one is not available (e.g. when already another instance of sclang is running, or one did not close the port properly) it may be the next one up (57121), or the next, until it finds one that opens without problems. You can retrieve always retrieve the current port with:

NetAddr.langPort;

// Or you can retrieve both the IP and the port with:

NetAddr.localAddr;    // retrieve the current IP and port


// since SC 3.5 you can open up additional ports:
thisProcess.openUDPPort(1121); // attempt to open 1121
// return true when it succeeded, false if not

thisProcess.openPorts; // list all open custom ports


// OSC messages are sent from one application to another via the UDP ports they have opened, e.g.

// max-msp sends a message from it's outgoing port to sclangs incoming port:
// max-msp -> udp port out -> udp port in -> sclang

// SuperCollider uses the same port to send from, as that is listens to.

// to send a message to yourself:

// set the target address:
b = NetAddr( "127.0.0.1", NetAddr.langPort );
// or:
b = NetAddr( "127.0.0.1", 57120 );

b.sendMsg( "/hello", "there" );

// listen to this:
o = OSCFunc({ arg ...args; args.postln; }, "/hello", NetAddr( "127.0.0.1", 57120 ) );

b.sendMsg( "/hello", "there" );

// the NetAddr in the OSCFunc is the NetAddr of the sender, so where the message comes from.
// if the udp port of the sender is not constant, you can set the NetAddr of the sender to nil, and the OSCFunc will still fire:
~onil = OSCFunc({ arg ...args; args.postln; }, "/hello", NetAddr( "127.0.0.1", nil ) );

// you can also set the port on which to listen (e.g. if the sender can only send to a specific port)
~oport = OSCFunc({ arg ...args; args.postln; }, "/hello", NetAddr( "127.0.0.1", nil ), 7771 );

// the function that you define, gets the arguments:
// msg - an array, starting with the osc-tag (/hello), and then the other values that are sent
// a time - this is the time the message arrived, or the time tag
// a NetAddr - this is the address of the sender (where the message came from)
// the recvport - the port that the message came into

// to track which messages come in, you can do:
OSCFunc.trace( true );

// with sendBundle, you can add a timestamp to the OSC message. Compare the time's of these messages:
b.sendBundle(0.2, ["/good/news", 1, 1.3, 77]); b.sendMsg( "/hello", "there" );

// turn tracing off:
OSCFunc.trace( false );

// CmdPeriod releases all OSCFunc's just like the MIDIFunc, unless you made them permanent or fixed them.
~onil.fix;


// as with MIDIFunc's - where you can use named versions with MIDIdef, you can use OSCdef for OSC:
// the advantage is that the OSCdef is replaced, if you change the function for an OSCdef with the same name.

OSCdef( \onlymine, { arg ...args; args.postln; }, "/hello", NetAddr( "127.0.0.1", 57120 ) );
OSCdef( \anyport, { arg ...args; args.postln; }, "/hello", NetAddr( "127.0.0.1", nil ) );
OSCdef( \otherreceiveport, { arg ...args; args.postln; }, "/hello", NetAddr( "127.0.0.1", nil ), 7771 );
OSCdef( \anywhere, { arg ...args; args.postln; }, "/hello", nil );

OSCdef.all;

OSCdef.freeAll;


// in 3.4, OSCFunc does not yet exist, instead you have to use OSCresponderNode, the argument list is in a different order though:
~orn = OSCresponderNode.new( NetAddr( "127.0.0.1", nil ), "/hello", { arg ...args; args.postln; } );
// and you need to add it:
~orn.add;

b.sendMsg( "/hello", "there" );

// the function is passed:
// a time - this is the time the message arrived, or the time tag
// the responder
// a NetAddr - this is the address of the sender (where the message came from)
// msg - an array, starting with the osc-tag (/hello), and then the other values that are sent

// the same kind of filtering happens based on sender:

// fixed sender ip, fixed port
~ormy = OSCresponderNode.new( NetAddr( "127.0.0.1", 57120 ), "/hello", { arg ...args; args.postln; } ).add;

// fixed sender ip, any port
~oranyport = OSCresponderNode.new( NetAddr( "127.0.0.1", nil ), "/hello", { arg ...args; args.postln; } ).add;

// from anywhere
~oranywhere = OSCresponderNode.new( nil, "/hello", { arg ...args; args.postln; } ).add;

// in 3.4 you cannot set the receiveport, you can only use the default language port:
NetAddr.langPort;

// and you can remove the OSCresponderNode:
~orn.remove;

// or remove all:
OSCresponderNode.all.do{ |it| it.remove };

b.sendMsg( "/hello", "there" );
