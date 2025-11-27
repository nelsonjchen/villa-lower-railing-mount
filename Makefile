# Makefile for clamp

SCAD_FILE = clamp.scad
OUTPUT = clamp.stl

all: $(OUTPUT)

$(OUTPUT): $(SCAD_FILE)
	openscad -o $@ $<

clean:
	rm -f $(OUTPUT)

.PHONY: all clean