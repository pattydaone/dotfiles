#include <stdio.h>
#include "change.h"
#include "../sketchybar.h"

int main(int argc, char** argv) {
    float update_freq;
    if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
        printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", argv[0]);
        exit(1);
    }

    alarm(0);

    char eventMessage[512];
    snprintf(eventMessage, 512, "--add event '%s'", argv[1]);
    sketchybar(eventMessage);

    AudioDeviceID oldDevice;
    char triggerMessage[512];
    while (true) {
        char deviceName[256];
        AudioDeviceID device = getCurrentOutput();
        if (device != oldDevice) {
            oldDevice = device;
            getDeviceName(device, deviceName);

            snprintf(triggerMessage, 512, 
                    "--trigger '%s' device_name='%s'", 
                    argv[1], deviceName);
            
            sketchybar(triggerMessage);
        }

        usleep(update_freq * 1000000);
    }

    return 0;
}
