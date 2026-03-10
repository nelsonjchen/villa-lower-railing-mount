# Makefile for clamp

SCAD_FILES = clamp.scad cover.scad
OUTPUTS = $(SCAD_FILES:.scad=.stl) clamp_test.stl

all: $(OUTPUTS)

%.stl: %.scad
	openscad -o $@ $<

clamp_test.stl: clamp.scad
	openscad -D "RENDER_TEST=true" -o $@ $<

clean:
	rm -f $(OUTPUTS)

.PHONY: all clean