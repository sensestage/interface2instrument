IxiHID{
	classvar <path, responder;
	classvar <deviceList;
	classvar <eventLoopIsRunning=false;
	classvar <debug = false;
	classvar <>rate = 50;

	*initClass{
		path = "/home/nescivi/Downloads/HIDserver/";
		deviceList = ();
	}
	
	*debug_{ |onoff|
		debug = onoff;
	}

	*start{
		responder = OSCresponderNode( nil , '/hid' , { arg time, responder, msg;
			//	msg.postln;
			if ( msg[1] == 'running', {
				deviceList = deviceList.put( msg[3], IxiHIDDevice.new( msg[3], msg[2] ) );
			});
			if ( msg[1] == 'quit', {
				IxiHID.stop( "IxiHID was stopped" );
			});
			if ( msg[2] == 'axes', { IxiHID.deviceList[msg[1]].axes( msg[3] ) });
			if ( msg[2] == 'buttons', { IxiHID.deviceList[msg[1]].buttons( msg[3] ) });
			if ( msg[2] == 'hats', { IxiHID.deviceList[msg[1]].hats( msg[3] ) });
			if ( msg[2] == 'balls', { IxiHID.deviceList[msg[1]].balls( msg[3] ) });

			if ( msg[1] == 'button', { 
				IxiHID.deviceList[msg[2]].slots[1][msg[3]].value_( msg[4] );
			} );
			if ( msg[1] == 'axismotion', { 
				IxiHID.deviceList[msg[2]].slots[3][msg[3]].value_( msg[4] );
			});
			if ( msg[1] == 'hatmotion', { 
				IxiHID.deviceList[msg[2]].slots[3][msg[3]+20].value_( msg[4] );
			});
			if ( msg[1] == 'ballmotion', { 
				IxiHID.deviceList[msg[2]].slots[2][msg[3]].value_( msg[4] );
			});


		}).add;
		
		("python"+path++"hidserver.py \"127.0.0.1\""+NetAddr.langPort+rate).unixCmd;
		eventLoopIsRunning = true;
	}

	*stop{ arg message="close the HID OSC window manually!";
		responder.remove;
		eventLoopIsRunning=false;
		deviceList.do{ |it| it.close };
		message.postln;
	}

}

IxiHIDDevice{
	var <id,<name;
	var <slots;
	var open=false;

	*new{ |id,name|
		^super.new.init( id, name );
	}

	init{ |idn,nm|
		id = idn;
		name = nm;
		open = true;
		slots = IdentityDictionary.new;
		GeneralHIDSlot.typeMap.keysValuesDo{ |key|
			slots.put( key, IdentityDictionary.new );
		};
	}

	close{
		open = false;
	}

	isOpen{
		^open;
	}

	info{
		^[id,name];
	}

	axes{ |no|
		var newSlot;
		no.do{ |it| 
			newSlot = IxiHIDSlot.new( this, 0x0003, it, it );
			slots[0x0003].put( it, newSlot );
		};	
	}

	buttons{ |no|
		var newSlot;
		no.do{ |it| 
			newSlot = IxiHIDSlot.new( this, 0x0001, it, it );
			slots[0x0001].put( it, newSlot );
		};	
	}

	balls{ |no|
		var newSlot;
		no.do{ |it| 
			newSlot = IxiHIDSlot.new( this, 0x0002, it, it );
			slots[0x0003].put( it, newSlot );
		};	
		}

	hats{ |no|
		var newSlot;
		no.do{ |it| 
			newSlot = IxiHIDSlot.new( this, 0x0003, it+20, it+20 );
			slots[0x0003].put( it+20, newSlot );
		};	
	}
}


IxiHIDSlot {
	var <device, <type, <code, <cookie, value=0,  <>action;
	var <spec;
	classvar slotTypeMap;
	
	*initClass {
		slotTypeMap = IdentityDictionary.new.addAll([
			0x0001 -> IxiHIDKeySlot,
			0x0002 -> IxiHIDRelSlot,
			0x0003 -> IxiHIDAbsSlot//,
			//	0x0011 -> IxiHIDLedSlot
		]);
	}

	*new { | device, evtType, evtCode, evtCookie |
		^(slotTypeMap[evtType] ? this).newCopyArgs(device, evtType, evtCode, evtCookie).initSpec
	}
	initSpec {
		spec = ControlSpec(0, 1, \lin, 0.0, 0.0);
	}
	rawValue {
		^value
	}
	value {
		^spec.unmap(value)
	}
	value_ { | rawValue |
		//rawValue.postln;
		value = rawValue;
		action.value(this);
	}
	next {
		^this.value
	}
}

IxiHIDKeySlot : IxiHIDSlot {
	initSpec {
		super.initSpec;
		//FIXME: 
		//value = device.valueByCookie(cookie);
	}
}

IxiHIDRelSlot : IxiHIDSlot {
	var delta, <>deltaAction;

	initSpec { }
	value { ^value }
	value_ { | dta |
		delta = dta;
		value = value + delta;
		action.value(this);
		deltaAction.value(this);
	}

	delta { ^delta }
}

/* not implemented yet
IxiHIDLedSlot : IxiHIDSlot {

	initSpec { }
	value { ^value }
	value_ { | v |
		value = v;
		// FIXME: device.setLEDState( code, value );
		device.setValueByCookie(cookie);
		action.value(this);
	}
}
*/

IxiHIDAbsSlot : IxiHIDSlot {
	var <info;

	initSpec {
		//		info = device.elements.detect( { |ele| ele.cookie == cookie } );
		//		spec = ControlSpec(info.min, info.max, \lin, 1);
		spec = ControlSpec(-1, 1, \lin, 0);
		spec.default = spec.map(0.5).asInteger;
		//value = info.value;
	}
}

IxiHIDAbsInfo {
	var <value = 0, <min = 0, <max = 0, <fuzz = 0, <flat = 0;

	printOn { | stream |
		stream
		<< this.class.name << $(
		<< "value: " << value << ", "
		<< "min: " << min << ", "
		<< "max: " << max << ", "
		<< "fuzz: " << fuzz << ", "
		<< "flat: " << flat << $)
	}
}