# Makefile to build HDF D examples - ported from C to D by Laeeth Isharc
#
# uses bindings and wrappers in hdf5 directory
#
# make => makes release build of the library
#
# make clean => removes all targets built by the makefile
#
# make BUILD=debug => makes debug build of the library
#
# build file inspired by Phobos make
################################################################################
# Configurable stuff, usually from the command line
#
# OS can be linux, win32, win32wine, osx, or freebsd. The system will be
# determined by using uname
#
# Default to a release built, override with BUILD=debug
ifeq (,$(BUILD))
BUILD_WAS_SPECIFIED=0
BUILD=release
else
BUILD_WAS_SPECIFIED=1
endif

ifneq ($(BUILD),release)
    ifneq ($(BUILD),debug)
        $(error Unrecognized BUILD=$(BUILD), must be 'debug' or 'release')
    endif
endif
BUILD_DIR=build

LIBS = -L-lhdf5 -L-lhdf5_hl
DMD = dmd
BUILDTYPE = -release
# Set DFLAGS
ifeq ($(BUILD),debug)
	DFLAGS += -g -debug
else
	DFLAGS += -O -release
endif

DFLAGS=$($LIBS) $(BUILDTYPE)
DEPS=hdf5/wrap hdf5/bindings/enums hdf5/bindings/api hdf5/hdf5

# not currently compiling:
#	h5_extlink h5ex_d_unlimadd h5_rdwt h5_select h5ex_g_iterate h5_subset h5_reference h5_ref2reg 
#	h5ex_g_traverse h5ex_t_cpxcmpd.d

EXAMPLES =  $(addprefix examples/h5ex_d_,	alloc chunk szip)				\
			$(addprefix examples/h5_,		write read attribute extend_write chunk_read compound group) \
			$(addprefix examples/,		traits myiterator)											\
			$(addprefix examples/h5ex_t_, bit stringatt string)

all: $(EXAMPLES) $(DEPS)

# line below is gnu make specific.  change to the following if it fails
#	$(DMD) $(DFLAGS) $(LIBS) $@ $(DEPS) -of$@
$(EXAMPLES): % : %.d $(DEPS)
	$(DMD) $(DFLAGS) $(LIBS) $@ $(DEPS) -of$(BUILD_DIR)/$(notdir $@)

$(DEPS): 
	$(DMD) -c $@ $(BUILDTYPE) -of$@

clean:		
	rm -f build/*.o
	rm -f build/h5_*
	rm -f build/h5ex_*
	rm -f build/traits
	rm -f build/myiterator

#realclean purge: clean
#	rm -f $(PROGRAMS)
