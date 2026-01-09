#include <unistd.h>
#include <CoreServices/CoreServices.h>
#include <CoreAudio/CoreAudio.h>
#include <CoreAudio/AudioHardware.h>
#include <CoreAudio/AudioHardwareBase.h>

inline AudioDeviceID getCurrentOutput() {
    AudioObjectPropertyAddress address;
    address.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
    address.mScope = kAudioObjectPropertyScopeGlobal;
    address.mElement = kAudioObjectPropertyElementMain;

    AudioDeviceID deviceID = kAudioDeviceUnknown;
    UInt32 dataSize = sizeof(AudioDeviceID);
    OSStatus status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, &dataSize, &deviceID);
    if (status != noErr) {
        // handle error
    }

    return deviceID;
}

inline void getDeviceName(AudioDeviceID deviceID, char* deviceName) {
    AudioObjectPropertyAddress address = {
        kAudioDevicePropertyDeviceNameCFString,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };
    CFStringRef cfDeviceName = NULL;
    UInt32 dataSize = sizeof(CFStringRef);
    OSStatus result = AudioObjectGetPropertyData(deviceID, &address, 0, NULL, &dataSize, &cfDeviceName);
    if (result == noErr && cfDeviceName != NULL) {
        CFStringGetCString(cfDeviceName, deviceName, 256, kCFStringEncodingUTF8);
        CFRelease(cfDeviceName);
    }
}
