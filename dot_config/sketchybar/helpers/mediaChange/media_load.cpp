#include <cstddef>
#include <stdexcept>
#include <string>
#include <iostream>
#include <cstdio>
#include <unistd.h>

extern "C" {

extern char* sketchybar(char* message);

}

void eraseProblemChars(std::string& string) {
    std::size_t pos = 0;
    while ((pos = string.find("'", pos)) != std::string::npos) {
        string.erase(pos, 1);
        ++pos;
    }
    
    pos = 0;
    while ((pos = string.find("[", pos)) != std::string::npos) {
        string.erase(pos, 1);
        ++pos;
    }

    pos = 0;
    while ((pos = string.find("]", pos)) != std::string::npos) {
        string.erase(pos, 1);
        ++pos;
    }
}

void checkComma(std::string& inp) {
    if (inp.back() == ',') inp.pop_back();
}

int main(int argc, char** argv) {
    float update_freq;
    if (argc < 4 || (std::sscanf(argv[4], "%f", &update_freq) != 1)) {
        std::cout << "Usage: << argv[0] << \"<playing-event-name>\" \"<media-event-name-2>\" \"<media-event-name-3>\" \"<event_freq>\"\n";
        exit(1);
    }

    alarm(0);

    char eventMessage[512];
    snprintf(eventMessage, 512, "--add event '%s'", argv[1]);
    sketchybar(eventMessage);
    snprintf(eventMessage, 512, "--add event '%s'", argv[2]);
    sketchybar(eventMessage);
    snprintf(eventMessage, 512, "--add event '%s'", argv[3]);
    sketchybar(eventMessage);

    const char* command = "/usr/bin/perl /Users/patrick/.config/sketchybar/helpers/mediaChange/mediaremote-adapter/bin/mediaremote-adapter.pl /Users/patrick/.config/sketchybar/helpers/mediaChange/bin/MediaRemoteAdapter.framework get -h --now";
    std::size_t prevpos;
    std::size_t newpos;
    char output[4096];
    std::string title_old;
    std::string title;
    std::string artist_old;
    std::string artist;
    std::string playing_old;
    std::string playing;
    double totalDuration = 1;
    double elapsed;
    bool null = false;

    char triggerMessage[1024];
    while (true) {

        FILE* file = popen(command, "r");
        std::size_t nbytes = read(fileno(file), output, sizeof(output));
        pclose(file);

        std::string stringoutput { output, nbytes };

        if (stringoutput.find("null") != std::string::npos) {
            if (!null) {
                null = true;
                snprintf(triggerMessage, 512, 
                        "--trigger '%s' playing=false", 
                        argv[1]);
                sketchybar(triggerMessage);
                snprintf(triggerMessage, 512, 
                        "--trigger '%s' title=\" \" artist=\" \"", 
                        argv[2]);
                sketchybar(triggerMessage);
                snprintf(triggerMessage, 512, 
                        "--trigger '%s' percentage=0", 
                        argv[3]);
                sketchybar(triggerMessage);
            }
        }

        else {
            if (null) null = false;
            prevpos = stringoutput.find("\"title\" : ") + 11;
            newpos = stringoutput.find('\n', prevpos);
            title = stringoutput.substr(prevpos, newpos - prevpos - 2);
            eraseProblemChars(title);

            prevpos = stringoutput.find("\"artist\" : ", 0) + 12;
            newpos = stringoutput.find('\n', prevpos);
            artist = stringoutput.substr(prevpos, newpos - prevpos - 2);
            eraseProblemChars(artist);

            prevpos = stringoutput.find("\"playing\" : ", 0) + 12;
            newpos = stringoutput.find('\n', prevpos);
            playing = stringoutput.substr(prevpos, newpos - prevpos);
            checkComma(playing);

            if (playing == "true") {
                prevpos = stringoutput.find("\"elapsedTimeNow\" : ", 0) + 19;
                newpos = stringoutput.find('\n', prevpos);
                try {
                    elapsed = std::stof(stringoutput.substr(prevpos, newpos - prevpos - 1));
                }
                catch (std::invalid_argument) {
                    std::cout << stringoutput.substr(prevpos, newpos - prevpos - 1);
                    elapsed = 0;
                }

                prevpos = stringoutput.find("\"duration\" : ", 0) + 13;
                newpos = stringoutput.find('\n', prevpos);
                try {
                    totalDuration = std::stof(stringoutput.substr(prevpos, newpos - prevpos - 1));
                }
                catch (std::invalid_argument) {
                    std::cout << stringoutput.substr(prevpos, newpos - prevpos - 1);
                    elapsed = 0;
                    totalDuration = 1;
                }

                snprintf(triggerMessage, 512, 
                        "--trigger '%s' percentage='%f'",
                        argv[3], (elapsed/totalDuration)*100);
                sketchybar(triggerMessage);
            }

            if (playing_old != playing) {
                playing_old = playing;
                snprintf(triggerMessage, 512, 
                        "--trigger '%s' playing='%s'", 
                        argv[1], playing.c_str());
                sketchybar(triggerMessage);
            }

            if (title_old != title || artist_old != artist) {
                title_old = title;
                artist_old = artist;
                snprintf(triggerMessage, 512, 
                        "--trigger '%s' title='%s' artist='%s'", 
                        argv[2], title.c_str(), artist.c_str());
                sketchybar(triggerMessage);
            }
       }

        usleep(update_freq * 1000000);
    }
    
    return 0;
}
