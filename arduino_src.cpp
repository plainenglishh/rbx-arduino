/* This is a very simple mockup and could probably be written better. idk, i dont use c++ */

// borrowed from https://stackoverflow.com/a/14824108.
String split_str(String data, char separator, int index) {
    int found = 0;
    int str_index[] = {0, -1};
    int max_index = data.length()-1;

    for (int i = 0; i <= max_index && found <= index; i++) {
        if (data.charAt(i) == separator || i == max_index) {
            found++;
            str_index[0] = str_index[1] + 1;
            str_index[1] = (i == max_index) ? i + 1 : i;
        }
    }

    return found > index ? data.substring(str_index[0], str_index[1]) : "";
}

bool prev_clock = false;
String full_line = "";
String current_line = "";


//------------------------------------------------------------------------------
//
// rbx_read
//
// Executes the update loop for rbx_arduino and returns the next byte, if found.
//
//------------------------------------------------------------------------------
int rbx_read() {
    bool curr_clock = XInput.getRumbleLeft() == 255;

    if (curr_clock != prev_clock) {
        prev_clock = curr_clock;
        if (curr_clock == true) {
            int byte = XInput.getRumbleRight();
            char character = byte;

            return character;
        }
    }
}


//------------------------------------------------------------------------------
//
// rbx_send_byte
//
// Sends a byte to a roblox game.
//
//------------------------------------------------------------------------------
void rbx_send_byte(int val) {
    XInput.setTrigger(16, val);
    XInput.send();
}


//------------------------------------------------------------------------------
//
// rbx_parse_cmd
//
// Parses and executes the command from rbx_arduino.
//
//------------------------------------------------------------------------------
void rbx_parse_cmd(String cmd) {
    if (cmd != "") {
        Serial1.println(cmd);
        String command = split_str(cmd, ';', 0);

        if (command == "PM") {          // PIN MODE
            int pin = split_str(cmd, ';', 1).toInt();
            int mode = split_str(cmd, ';', 2).toInt();
            pinMode(pin, mode);
        } else if (command == "DW") {   // DIGITAL WRITE
            int pin = split_str(cmd, ';', 1).toInt();
            int val = split_str(cmd, ';', 2).toInt();
            digitalWrite(pin, val);
        } else if (command == "EC") {   // ECHO
            int val = split_str(cmd, ';', 1).toInt();
            rbx_send_byte(val);
        }
    }
}


//------------------------------------------------------------------------------
//
// rbx_begin
//
// Starts XInput.
//
//------------------------------------------------------------------------------
void rbx_begin() {
    XInput.setAutoSend(false);
	XInput.begin();
}