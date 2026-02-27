#include "sub_tool.h"
#include <stdlib.h>
#include <string.h>

int main(int argc, char* argv[]) {
    char* filename = argv[1];
    char option = argv[2][1];
    int ret = 0;

    switch (option)
    {
        case 'v':
            if (argc >= 5 && argv[3][1] == 'n')
                ret = view_nth(filename, atoi(argv[4]));
            else
                ret = view_all(filename);
            break;

        case 'f':
            ret = view_firstn(filename, atoi(argv[3]));
            break;

        case 'l':
            ret = view_lastn(filename, atoi(argv[3]));
            break;

        case 'e':
        {
            char* text = argv[3];
            int n = atoi(argv[5]);
            if (argc == 8) {
                char* output = argv[7];
                ret = edit_line_to_output(filename, output, text, n);
            } else {
                ret = edit_line(filename, text, n);
            }
        }
        break;

        case 'i':
        {
            char* text = argv[3];
            if (argc == 6) {
                char* output = argv[5];
                ret = append_line_to_output(filename, output, text);
            } else {
                ret = append_line(filename, text);
            }
        }
        break;

        default:
            break;
    }

    return ret;
}