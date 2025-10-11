# Compiler
CC := cc

ifdef RELEASE
	# Compile flags
	CFLAGS := -Wall -Werror -Wextra -pedantic -std=c99 -s
else
	# Compile flags
	CFLAGS := -Wall -Werror -Wextra -pedantic -std=c99 -g
endif


# Test executable
TESTEXEC := run_test.out

# Source directory
SRCDIR := src

# Build files go here
BUILDDIR := build

# Export dir
TARDIR ?= target

# Export header dir
TAR_INCLUDEDIR ?= include

# External libraries
EXTERN := extern

# Test
TESTDIR := test

# Public headers
INCLUDEDIR := include

# Source files
SRCFILES := $(shell find $(SRCDIR) -type f -name *.c)

# Test sourcefile
TESTSRC := $(TESTDIR)/main_test.c

# Test object file
TESTOBJ := $(BUILDDIR)/main_test.o

# Additional object files
ADD_OBJECTS :=

# Derive Object files from source files
# OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SRCFILES:.c=.o)) $(ADD_OBJECTS)
OBJECTS :=


# Derive Header files from source files
HEADERS := $(SOURCES:.c=.h)

############################### Custom variables ###############################

################################ Custom targets ################################

################################################################################

test: $(TESTEXEC)

$(TESTEXEC): $(OBJECTS) $(TESTOBJ)
	@echo "Building $(shell basename $(TESTEXEC))"
	$(CC) $(CFLAGS) $^ -o $(TESTEXEC)


$(TESTOBJ): $(TESTSRC)
	@echo "Building $(shell basename $@)"
	$(CC) $(CFLAGS) -c $< -o $@

# Default target for source files
$(BUILDDIR)/%.o: $(SRCDIR)/%.c $(SRCDIR)/%.h
	@echo "Building $(shell basename $@)"
	@mkdir -p $(shell dirname $@)
	$(CC) $(CFLAGS) -c $< -o $@


clean:
	rm -rf build/*
	rm -rf target/*
	$(shell test -e *.out && rm *.out)
