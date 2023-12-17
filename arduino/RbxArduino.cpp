//------------------------------------------------------------------------------
//
// RbxArduino.cpp
//
// plainenglish
// December 2023
//
// Main source file for the Arduino Library.
//
//------------------------------------------------------------------------------

#include "Arduino.h"
#include "RbxArduino.h"
#include "xinput/XInput.h"

//------------------------------------------------------------------------------
//
// RbxArduino::RbxArduino
//
// Constructor
//
//------------------------------------------------------------------------------
RbxArduino::RbxArduino() {
    XInput.setAutoSend(false);
	XInput.begin();
    _prev_clock = false;
}


//------------------------------------------------------------------------------
//
// RbxArduino::read_byte
//
// Reads the current byte.
//
//------------------------------------------------------------------------------
int RbxArduino::read_byte() {
    int byte = XInput.getRumbleRight();
    char character = byte;

    return character;
}

//------------------------------------------------------------------------------
//
// RbxArduino::available
//
// Returns true if another byte is ready to be read.
// Must be called on every loop exec.
//
//------------------------------------------------------------------------------
bool RbxArduino::available() {
    bool curr_clock = XInput.getRumbleLeft() == 255;

    if (curr_clock != _prev_clock) {
        _prev_clock = curr_clock;

        if (curr_clock == true) { // Only read on a full cycle.
            return true;
        }
    }
}


//------------------------------------------------------------------------------
//
// RbxArduino::send_byte
//
// Sends a byte.
//
//------------------------------------------------------------------------------
void RbxArduino::send_byte() {
    XInput.setTrigger(16, val);
    XInput.send();
}
