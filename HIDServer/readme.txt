    HIDserver 0.3.1
    ixi software - 2012
    www.ixi-software.net | www.ixi-audio.net

	adapted by Marije Baalman - nescivi - www.nescivi.nl
	September 2007

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
     General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


#######################################
description :
HID OSC server is a SDL based python app that sends out via OSC any HID device (gamepad, joystick)
event generated data.

usage :
just run the app, you can pass the following arguments : ip, port, rate, verbose, log
the default values are : ip = "127.0.0.1", port = 57120, rate=12, verbose=0, log=0
to quit just close the server window


config file :
you can create a config.json file to specify the following options
{
     "ip": "127.0.0.1",
     "port" : 57210,
     "rate" : 12,
     "verbose"  : 0,
     "log" : 0
}

description of OSC messages sent by the server :
    - adress : /hid
    - value :
    INIT event : [ 'running', joystickname, joystickID ]
	INIT event : [ joystickID, 'axes', count ]
	INIT event : [ joystickID, 'hats', count ]
	INIT event : [ joystickID, 'balls', count ]
	INIT event : [ joystickID, 'buttons', count ]
    QUIT event : [ 'quit' ]
    JOYAXISMOTION event : [ 'axismotion', joystickID, axis, value ]
    JOYBALLMOTION event : [ 'ballmotion',  joystickID, ball, value ]
    JOYHATMOTION event : [ 'hatmotion',  joystickID, hat, valueX, valueY ]
    JOYBUTTON event : [ 'button', joystickID, button, value(1 for DOWN or 0 for UP) ]


dependencies :

Pygame http://pygame.org
SimpleOSC http://pypi.python.org/pypi/SimpleOSC/0.3.1
pyOSC http://pypi.python.org/pypi/pyOSC/0.3.5b-5294



Donations :
we do accept donations, thanks :)
http://ixi-audio.net/content/body_donations.html
#########################################
changes :

changes:
0.3.1 : updated to latest version of SimpleOSC based on pyOSC now

0.2 
Thanks to Martin. fixed JOYHATMOTION event sending error. Because e.value is an array it was completely dropped, the output was only 'hatmotion', 0,0  now it is eg 'hatmotion', 0, 0, 1, -1 for x/y axis of the cooliehat
removed logo and added pygame text to display ip and port
added config.json support
moved to latest version of SimpleOSC
compiled with pyinstaller under windows
