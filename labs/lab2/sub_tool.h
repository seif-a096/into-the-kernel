#pragma once

int view_all(char* filename);
int view_nth(char* filename ,int n);
int view_firstn(char* filename ,int n);
int view_lastn(char* filename ,int n);
int edit_line(char* filename ,char* text ,int n);
int append_line(char* filename ,char* text);
int edit_line_to_output(char* filename ,char* output ,char* text ,int n);
int append_line_to_output(char* filename ,char* output ,char* text);