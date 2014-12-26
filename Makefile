PROGRAMS=h5ex_d_alloc h5ex_d_chunk h5_write h5_read h5_attribute h5_extend_write h5_chunk_read h5_compound h5_drivers h5_dtransform h5_group h5_ex_g_visit h5_extlink h5ex_d_unlimadd h5_rdwt h5_select h5ex_g_iterate h5_subset h5_reference h5_ref2reg

#.PHONY: all clean realclean purge

all: $(PROGRAMS)

#$(PROGRAMS): % : %.d hdf5.d
#	dmd $< hdf5.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5ex_d_alloc: d_examples/h5ex_d_alloc.d hdf5.d
		dmd d_examples/h5ex_d_alloc.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5ex_d_checksum: d_examples/h5ex_d_checksum.d hdf5.d
		dmd d_examples/h5ex_d_checksum.d -L-lhdf5 -L-lhdf5_hl

h5ex_d_chunk: d_examples/h5ex_d_chunk.d hdf5.d
		dmd d_examples/h5ex_d_chunk.d -L-lhdf5 -L-lhdf5_hl

h5_write: d_examples/h5_write.d hdf5.d
		dmd d_examples/h5_write.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_read: d_examples/h5_read.d hdf5.d
		dmd d_examples/h5_read.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_attribute: d_examples/h5_attribute.d hdf5.d
		dmd d_examples/h5_attribute.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_extend_write: d_examples/h5_extend_write.d hdf5.d
		dmd d_examples/h5_extend_write.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_chunk_read: d_examples/h5_chunk_read.d hdf5.d
		dmd d_examples/h5_chunk_read.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_compound: d_examples/h5_compound.d hdf5.d
		dmd d_examples/h5_compound.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_drivers: d_examples/h5_drivers.d hdf5.d
		dmd d_examples/h5_drivers.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_dtransform: d_examples/h5_dtransform.d hdf5.d
		dmd d_examples/h5_dtransform.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_group: d_examples/h5_group.d hdf5.d
		dmd d_examples/h5_group.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_ex_g_visit: d_examples/h5_ex_g_visit.d hdf5.d
		dmd d_examples/h5_ex_g_visit.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_extlink: d_examples/h5_extlink.d hdf5.d
		dmd d_examples/h5_extlink.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5ex_d_unlimadd: d_examples/h5ex_d_unlimadd.d hdf5.d
		dmd d_examples/h5ex_d_unlimadd.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_rdwt: d_examples/h5_rdwt.d hdf5.d
		dmd d_examples/h5_rdwt.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_select: d_examples/h5_select.d hdf5.d
		dmd d_examples/h5_select.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5ex_g_iterate: d_examples/h5ex_g_iterate.d hdf5.d
		dmd d_examples/h5ex_g_iterate.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_subset: d_examples/h5_subset.d hdf5.d
	dmd d_examples/h5_subset.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_shared_mesg: d_examples/h5_shared_mesg.d hdf5.d
	dmd d_examples/h5_shared_mesg.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_reference: d_examples/h5_reference.d hdf5.d
	dmd d_examples/h5_reference.d hdf5.d -L-lhdf5 -L-lhdf5_hl

h5_ref2reg: d_examples/h5_ref2reg.d hdf5.d
	dmd d_examples/h5_ref2reg.d hdf5.d -L-lhdf5 -L-lhdf5_hl

clean:		
	rm -f *.o

#realclean purge: clean
#	rm -f $(PROGRAMS)
