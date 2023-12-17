//------------------------------------------------------------------------------
//
// RbxArduino.h
//
// plainenglish
// December 2023
//
// Header file for the Arduino Library.
//
//------------------------------------------------------------------------------

#ifndef Morse_h
#define Morse_h

#include "Arduino.h"

class RbxArduino {
    public:
        RbxArduino();
        void begin();
        bool available();
        int read();
        void write(int byte);
    private:
        XInput _gamepad
        bool _prev_clock
}

#endif
