# Variables
YACC = yacc
CC = gcc
SOURCES = work2_plus.y work2.y work2_final
OUTPUTS_C = $(SOURCES:.y=.tab.c)
TARGETS = $(SOURCES:.y=)

# Default target
all: $(TARGETS)

# Rules
%.tab.c: %.y
	$(YACC) $< -o $@

%: %.tab.c
	$(CC) $< -o $@

# Run targets
run: work2
	./work2

run-plus: work2_plus
	./work2_plus

run-final:work2_final
	./work2_final
	
# Clean up
clean:
	rm -f $(OUTPUTS_C) $(TARGETS)
