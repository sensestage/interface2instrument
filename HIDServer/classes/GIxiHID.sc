/* Wrapper for IxiHID for General HID support */

GIxiHID{
	classvar extraClasses;
	classvar <debug = false;
	var <device;

	*initClass{
		if ( \IxiHID.asClass.notNil, {
			Class.initClassTree( Event );
			extraClasses = Event.new;
			Class.initClassTree( GeneralHID );
			GeneralHID.add( this );
		});
	}

	*id { ^\ixi_hid }

	*put { arg key, object;
		extraClasses.put( key, object );
	}

	*doesNotUnderstand { arg selector ... args;
		^extraClasses.perform( selector, *args );
	}

	// ------------ functions ------------

	// note: this may actually take a while before the devices are found and detected
	*buildDeviceList{
		IxiHID.start;
		^this.deviceList;
	}

	*deviceList{
      var list = IxiHID.deviceList.asArray;
		^list;
	}

	*postDevices {
		IxiHID.deviceList.do({arg dev;
			[ dev.id, dev.name ].postcs;
		});
	}

	*postDevicesAndProperties {
		IxiHID.deviceList.do({arg dev;
			"".postln;
			[ dev.id, dev.name ].postln;
			dev.slots.keysValuesDo{ |key,slotgroup,i|
				("\t"++key+IxiHIDSlot.slotTypeStrings[key]).postln;
				slotgroup.do{ |slot|
					"\t\t".post;
					if ( slot.isKindOf( IxiHIDAbsSlot ),{
						[ slot.type, IxiHIDSlot.slotTypeStrings[slot.type], slot.code, slot.info.asString ].postcs;
					},{
						[ slot.type, IxiHIDSlot.slotTypeStrings[slot.type], slot.code ].postcs;
					});
				};
			};
		});
	}

	*startEventLoop{ |rate|
		// event loop starts at startup with LID
	}

	*stopEventLoop{
		// event loop is stopped at shutdown with LID
	}

	*eventLoopIsRunning{
		^IxiHID.eventLoopIsRunning;
	}

	*debug_{ |onoff|
		debug = onoff;
	}

	*open { arg dev;
		^super.new.init( dev );
	}

	init{ |dev|
		//	dev[0].postcs;
		if ( dev.isKindOf( IxiHIDDevice ),
			{
				device = dev;
				^GeneralHIDDevice.new( this );
			},{
				"not a valid device or could not open device".warn;
				^nil;
			});
	}

   getInfo{
      var info;
      info = GeneralHIDInfo.new( device.name );
      ^info;
   }

	getSlots{
		var mySlots = IdentityDictionary.new;
		var devSlots = device.slots;
		devSlots.keysValuesDo{ |key,value,i|
			//(""++i+"key"+key+"value"+value).postcs;
			if ( devSlots.size > 0 ,{
				mySlots[key] = IdentityDictionary.new;
				value.keysValuesDo{ |key2,value2,i2|
					mySlots[key][key2] = GeneralHIDSlot.new( key, key2, device, value2 );
				};
			});
		};
		//mySlots.postcs;
		^mySlots;
	}

	close{
		if ( device.notNil,
			{
				device.close;
			});
	}

	isOpen{
		if ( device.notNil,
			{
				^device.isOpen;
			},{
				^false;
			}
		);
	}

	info{
		if ( device.notNil,
			{
				^device.info;
			},{
				^nil;
			}
		);
	}

}