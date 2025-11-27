# Makefile for clamp

SCAD_FILES = clamp.scad cover.scad
OUTPUTS = $(SCAD_FILES:.scad=.stl)

all: $(OUTPUTS)

%.stl: %.scad
	openscad -o $@ $<

clean:
	rm -f $(OUTPUTS)

.PHONY: all clean