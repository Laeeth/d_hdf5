# not currently compiling: h5_extlink h5ex_d_unlimadd h5_rdwt h5_select h5ex_g_iterate h5_subset h5_reference h5_ref2reg  h5ex_g_traverse h5ex_t_cpxcmpd.d
PROGRAMS=h5ex_d_alloc traits h5ex_d_chunk h5_write h5_read h5_attribute h5_extend_write h5_chunk_read h5_compound h5_group        h5ex_t_bit h5ex_t_stringatt h5ex_t_string myiterator h5ex_d_szip 
#.PHONY: all clean realclean purge

all: $(PROGRAMS)

#$(PROGRAMS): % : %.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
#	dmd $< hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl -L-lhdf5_cpp -L-lhdf5_hl_cpp

h5ex_d_alloc: d_examples/h5ex_d_alloc.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5ex_d_alloc.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_d_checksum: d_examples/h5ex_d_checksum.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5ex_d_checksum.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_d_chunk: d_examples/h5ex_d_chunk.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5ex_d_chunk.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d  -L-lhdf5 -L-lhdf5_hl

h5_write: d_examples/h5_write.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_write.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_read: d_examples/h5_read.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_read.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_attribute: d_examples/h5_attribute.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_attribute.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_extend_write: d_examples/h5_extend_write.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_extend_write.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_chunk_read: d_examples/h5_chunk_read.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_chunk_read.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_compound: d_examples/h5_compound.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_compound.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_drivers: d_examples/h5_drivers.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_drivers.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_dtransform: d_examples/h5_dtransform.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_dtransform.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_group: d_examples/h5_group.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_group.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_ex_g_visit: d_examples/h5_ex_g_visit.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_ex_g_visit.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_extlink: d_examples/h5_extlink.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_extlink.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_d_unlimadd: d_examples/h5ex_d_unlimadd.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5ex_d_unlimadd.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_rdwt: d_examples/h5_rdwt.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_rdwt.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_select: d_examples/h5_select.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5_select.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_g_iterate: d_examples/h5ex_g_iterate.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
		dmd d_examples/h5ex_g_iterate.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_subset: d_examples/h5_subset.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5_subset.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_shared_mesg: d_examples/h5_shared_mesg.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5_shared_mesg.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_reference: d_examples/h5_reference.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5_reference.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5_ref2reg: d_examples/h5_ref2reg.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5_ref2reg.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_g_traverse: d_examples/h5ex_g_traverse.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5ex_g_traverse.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_t_bit: d_examples/h5ex_t_bit.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5ex_t_bit.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_t_stringatt: d_examples/h5ex_t_stringatt.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5ex_t_stringatt.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_t_string: d_examples/h5ex_t_string.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5ex_t_string.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

myiterator: d_examples/myiterator.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/myiterator.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_d_szip: d_examples/h5ex_d_szip.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5ex_d_szip.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

h5ex_t_cpxcmpd: d_examples/h5ex_t_cpxcmpd.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/h5ex_t_cpxcmpd.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl

traits: hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d
	dmd d_examples/traits.d hdf5/wrap.d hdf5/bindings/enums.d hdf5/bindings/api.d -L-lhdf5 -L-lhdf5_hl


 clean:		
	rm -f *.o

#realclean purge: clean
#	rm -f $(PROGRAMS)
