/// With the serial port, there is no fixed protocol, you have to know what bytes the device is expecting, or sending out.
//


(
p = SerialPort(
    "/dev/tty.usbserial-181",
    baudrate: 9600,
    crtscts: true);
)

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

//read 10bit serial data sent from Arduino's Serial.println
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


/// as an example, check Quarks:
// Arduino -> ArduinoSMS protocol, but also good example for general protocol
// DMX
// SCPyduino