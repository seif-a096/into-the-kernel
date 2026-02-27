#include "sub_tool.h"
#include <stdio.h>
#include <stdlib.h>

#define LINE_BUFFER_SIZE 256

static FILE* open_input_file_or_error(const char* filename){
    FILE* file = fopen(filename, "r");
    if(!file){
        fprintf(stderr,"Error: File does not exist.");
    }
    return file;
}

static FILE* open_output_file(const char* filename, const char* mode){
    return fopen(filename, mode);
}

static int count_lines_in_file(FILE* file){
    int count = 0;
    char line[LINE_BUFFER_SIZE];
    while(fgets(line, sizeof(line), file)){
        count++;
    }
    rewind(file);
    return count;
}

static void free_lines(char** lines, int count){
    if(!lines){
        return;
    }
    for(int i = 0; i < count; ++i){
        free(lines[i]);
    }
    free(lines);
}

static char** read_file_lines(const char* filename, int* out_count){
    *out_count = -1;
    FILE* file = open_input_file_or_error(filename);
    if(!file){
        return NULL;
    }

    int count = count_lines_in_file(file);
    char** lines = NULL;

    if(count > 0){
        lines = malloc(sizeof(char*) * count);
        if(!lines){
            fclose(file);
            return NULL;
        }

        for(int i = 0; i < count; ++i){
            lines[i] = malloc(LINE_BUFFER_SIZE);
            if(!lines[i]){
                for(int j = 0; j < i; ++j){
                    free(lines[j]);
                }
                free(lines);
                fclose(file);
                return NULL;
            }

            if(!fgets(lines[i], LINE_BUFFER_SIZE, file)){
                lines[i][0] = '\0';
            }
        }
    }

    fclose(file);
    *out_count = count;
    return lines;
}

int view_all(char* filename){
    FILE* file = open_input_file_or_error(filename);
    if(!file){
        return 0;
    }

    char line[LINE_BUFFER_SIZE];
    while(fgets(line, sizeof(line), file)){
        printf("%s", line);
    }

    fclose(file);
    return 0;
}

int view_nth(char* filename ,int n){
    if(n < 1){
        fprintf(stderr,"Error: Line out of bounds.");
        return 0;
    }

    FILE* file = open_input_file_or_error(filename);
    if(!file){
        return 0;
    }

    int count = count_lines_in_file(file);
    if(n > count){
        fprintf(stderr,"Error: Line out of bounds.");
        fclose(file);
        return 0;
    }

    char line[LINE_BUFFER_SIZE];
    for(int i = 0; i < n; ++i){
        if(!fgets(line, sizeof(line), file)){
            break;
        }
        if(i == n - 1){
            printf("%s", line);
        }
    }

    fclose(file);
    return 0;
}

int view_firstn(char* filename ,int n){
    FILE* file = open_input_file_or_error(filename);
    if(!file){
        return 0;
    }

    int count = count_lines_in_file(file);
    if(n > count){
        fprintf(stderr ,"Error: File limit exceeded.");
        fclose(file);
        return 0;
    }

    char line[LINE_BUFFER_SIZE];
    for(int i = 0; i < n; ++i){
        if(!fgets(line, sizeof(line), file)){
            break;
        }
        printf("%s", line);
    }

    fclose(file);
    return 0;
}

int view_lastn(char* filename ,int n){
    FILE* file = open_input_file_or_error(filename);
    if(!file){
        return 0;
    }

    int count = count_lines_in_file(file);
    if(n > count){
        fprintf(stderr ,"Error: File limit exceeded.");
        fclose(file);
        return 0;
    }

    char line[LINE_BUFFER_SIZE];
    for(int i = 0; i < count - n; ++i){
        if(!fgets(line, sizeof(line), file)){
            break;
        }
    }

    for(int i = 0; i < n; ++i){
        if(!fgets(line, sizeof(line), file)){
            break;
        }
        printf("%s", line);
    }

    fclose(file);
    return 0;
}


int edit_line(char* filename ,char* text ,int n){
    int count = 0;
    char** lines = read_file_lines(filename, &count);
    if(count < 0){
        return 0;
    }
    if(n > count || n <= 0){
        fprintf(stderr ,"Error: Line out of bounds.");
        free_lines(lines, count);
        return 0;
    }

    free(lines[n - 1]);
    lines[n - 1] = malloc(LINE_BUFFER_SIZE);
    if(!lines[n - 1]){
        free_lines(lines, count);
        return 0;
    }
    snprintf(lines[n - 1], LINE_BUFFER_SIZE, "%s\n", text);

    FILE* file = open_output_file(filename, "w");
    if(!file){
        free_lines(lines, count);
        return 0;
    }

    for(int i = 0; i < count; ++i){
        fprintf(file, "%s", lines[i]);
    }
    fclose(file);
    free_lines(lines, count);
    return 0;
}

int append_line(char* filename ,char* text){
    FILE* file = open_output_file(filename, "a");
    if(!file){
        return 0;
    }
    fprintf(file, "%s\n", text);
    fclose(file);
    return 0;
}

int edit_line_to_output(char* filename ,char* output ,char* text ,int n){
    int count = 0;
    char** lines = read_file_lines(filename, &count);
    if(count < 0){
        return 0;
    }
    if(n > count || n <= 0){
        fprintf(stderr ,"Error: Line out of bounds.");
        free_lines(lines, count);
        return 0;
    }

    free(lines[n - 1]);
    lines[n - 1] = malloc(LINE_BUFFER_SIZE);
    if(!lines[n - 1]){
        free_lines(lines, count);
        return 0;
    }
    snprintf(lines[n - 1], LINE_BUFFER_SIZE, "%s\n", text);

    FILE* file = open_output_file(output, "w");
    if(!file){
        free_lines(lines, count);
        return 0;
    }

    for(int i = 0; i < count; ++i){
        fprintf(file, "%s", lines[i]);
    }
    fclose(file);
    free_lines(lines, count);
    return 0;
}

int append_line_to_output(char* filename ,char* output ,char* text){
    int count = 0;
    char** lines = read_file_lines(filename, &count);
    if(count < 0){
        return 0;
    }

    FILE* file = open_output_file(output, "w");
    if(!file){
        free_lines(lines, count);
        return 0;
    }

    for(int i = 0; i < count; ++i){
        fprintf(file, "%s", lines[i]);
    }
    fprintf(file, "%s\n", text);
    fclose(file);
    free_lines(lines, count);
    return 0;
}