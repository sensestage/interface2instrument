/// With the serial port, there is no fixed protocol, you have to know what bytes the device is expecting, or sending out.
//

SerialPort.listDevices;
// ttyUSB*, ttyACM*
(
p = SerialPort(
    "/dev/tty.usbserial-181",
    baudrate: 9600,
    crtscts: true);
)

// common baudrates:
// 9600, 19200
[9600, 19200, 38400, 57600, 115200 ]

// read a byte from the device

p.next;            // doesn't block
fork{p.read.postln};    // may suspend thisThread - should be called within a routine

// write a byte to the device

fork{p.put(42)};    // may suspend thisThread - should be called within a routine

// write multiple bytes to the device

p.putAll("whaddayawant");
p.putAll(Int8Array[13, 10]);

p.doneAction = { "my serial port got closed".postln; }

p.close;    // close the port

SerialPort.closeAll;    // close all ports


/// Arduino write example
// First load the sketch Examples/Communication/Dimmer. See http://www.arduino.cc/en/Tutorial/Dimmer
// NOTE: Always make sure the serial monitor is closed in the Arduino application before opening the port in SuperCollider.
(
p = SerialPort(
    "/dev/tty.usbserial-A800crTT",    //edit to match your port. SerialPort.listDevices
    baudrate: 9600,    //check that baudrate is the same as in arduino sketch
    crtscts: true);
)

110.fold(0,100)

//send serial data - slow pulsating
(
r= Routine({
    inf.do{|i|
        p.put(i.fold(0, 100).linexp(0, 100, 1, 255).asInteger.postln);
        0.02.wait;
    };
}).play;
)

r.stop;
p.close;

// Arduino read example
/// First load the sketch Examples/Communication/Graph. See http://www.arduino.cc/en/Tutorial/Graph
/// NOTE: Always make sure the serial monitor is closed in the Arduino application before opening the port in SuperCollider.
(
p = SerialPort(
    "/dev/tty.usbserial-A800crTT",    //edit to match your port. SerialPort.listDevices
    baudrate: 9600,    //check that baudrate is the same as in arduino sketch
    crtscts: true);
)

~vari = "somethings"
~vari2 = ~vari;

~vari2 === ~vari;
// true, they are the same string

~vari2 = ~vari.copy;
~vari2 === ~vari;
// false, one is a copy of the other string

~vari.dump
~vari2.dump;

$\n.ascii == 10
$\r.ascii

//read 10bit serial data sent from Arduino's Serial.println

500
$0.ascii
~str = "";
~str = ~str ++ 53.asAscii
~str
~str = ~str ++ 48.asAscii
~str.asInteger
(
r= Routine({
    var byte, str, res;
    99999.do{|i|
        if(p.read==10, {
            str = "";
            while({byte = p.read; byte !=13 }, {
                str= str++byte.asAscii;
            });
            res= str.asInteger;
            ("read value:"+res).postln;
        });
    };
}).play;
)

r.stop;
p.close;

Quarks.gui;
/// as an example, check Quarks:
// Arduino -> ArduinoSMS protocol, but also good example for general protocol
// DMX
// SCPyduino



// method to find the serial port automatically, if it got unplugged
~serialDevice = "/dev/tty.usbserial-A7005G4Y";
Tdef( \openSerial,{
	var mydev;
	while ( { mydev.isNil },{
		mydev = SerialPort.devices.detect{ |it| ~serialDevice == it }.postln;
		if ( mydev.notNil ){
         // this is a subclass of Arduion, with our own parser, thus opening the serialport:
			q = XBeeSMSOld.new( mydev, 19200 );
			q.port.doneAction = { Tdef( \openSerial ).play; }; // start the task when the port gets closed
         // set the action for what should happen when a message has come in
			q.action_( { |msg| fork{ x.setData( msg[0], msg.copyToEnd(1) ); }; ~sensingOn = 0; });
		}{
			// probe every three seconds;
			3.0.wait;
		};
	} );
});

Tdef( \openSerial ).play;