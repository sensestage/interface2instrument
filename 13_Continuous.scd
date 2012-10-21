// "continuous" controllers include things like Sliders/Faders, Knobs, Joystick axes, and so on.
// The controllers output a range of values based on the position they are in.

// For MIDI controllers these are usually CC - continuous control - messages.
// Continuous however in the MIDI world means that the controller can have 127 values.

// On Game devices the resolution of continuous controls may vary, they can be 8 bit, 10 bit or even higher.
// Usually advanced game controllers, give you higher accuracy (with increasing cost).

// -------- mapping ranges -----------

// linear

// exponential - dbamp


// -------- behaviour changes in different regions of the controller ---------

// segwarp, table lookup


// -------- rate of change -------------


// -------- statistics -------------


// -------- soft set -------------------

// if a controller is dynamically assigned to a parameter, or the parameter can also be changed by other means (e.g. code),
// then it can be useful to "soft set" the parameter, meaning the controller will only really start changing the value, once
// you moved the controller close to its current setting.

// ----------- default states ----------

// Some continuous controllers have a default state, a joystick will always return to the center if you don't touch it. When mapping it is important to keep the default state in mind...