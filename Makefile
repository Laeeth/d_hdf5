PROGRAMS=h5ex_d_alloc h5ex_d_chunk h5_write h5_read h5_attribute h5_extend_write h5_chunk_read h5_compound h5_drivers h5_dtransform h5_group

#.PHONY: all clean realclean purge

all: $(PROGRAMS)

#$(PROGRAMS): % : %.d hdf5.d
#	dmd $< hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5ex_d_alloc: d_examples/h5ex_d_alloc.d hdf5.d
		dmd d_examples/h5ex_d_alloc.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5ex_d_checksum: d_examples/h5ex_d_checksum.d hdf5.d
		dmd d_examples/h5ex_d_checksum.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5ex_d_chunk: d_examples/h5ex_d_chunk.d hdf5.d
		dmd d_examples/h5ex_d_chunk.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5_write: d_examples/h5_write.d hdf5.d
		dmd d_examples/h5_write.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5_read: d_examples/h5_read.d hdf5.d
		dmd d_examples/h5_read.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5_attribute: d_examples/h5_attribute.d hdf5.d
		dmd d_examples/h5_attribute.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5_extend_write: d_examples/h5_extend_write.d hdf5.d
		dmd d_examples/h5_extend_write.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5_chunk_read: d_examples/h5_chunk_read.d hdf5.d
		dmd d_examples/h5_chunk_read.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5_compound: d_examples/h5_compound.d hdf5.d
		dmd d_examples/h5_compound.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5_drivers: d_examples/h5_drivers.d hdf5.d
		dmd d_examples/h5_drivers.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5_dtransform: d_examples/h5_dtransform.d hdf5.d
		dmd d_examples/h5_dtransform.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5_group: d_examples/h5_group.d hdf5.d
		dmd d_examples/h5_group.d hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

clean:		
	rm -f *.o

#realclean purge: clean
#	rm -f $(PROGRAMS)
