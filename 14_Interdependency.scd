// Some controllers are physically dependent on each other, that is you cannot move one, without changing the value of the other.

// For example, when you move the x-axis of a joystick, you will usually also cause (small) changes in the y-axis.
// So in the design of the instrument, you need to keep this in mind; the axes will need to be used together.
// For example, rather than using x and y, you could use them with polar coordinates, and use the radius (how far out the joystick is moved) and the angle as controls.



// A similar case is a triple-axis accelerometer, with x, y, z axes...


