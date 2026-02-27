cc=gcc
flags=-c -Wall -Werror
sources=sub_tool.c main.c
objects=$(sources:.c=.o)
executable=sub_tool


all: $(sources) $(executable)

$(executable): $(objects)
	$(cc) $(objects) -o $@

.c.o:
	$(cc) $(flags) $< -o $@

clean:
	rm -rf *.o $(executable)