/**

	Copyright by The HDF Group.                                               
	Copyright by the Board of Trustees of the University of Illinois.         
	All rights reserved.                                                      
	                                                                        
	This file is part of HDF5.  The full HDF5 copyright notice, including     
	terms governing use, modification, and redistribution, is contained in    
	the files COPYING and Copyright.html.  COPYING can be found at the root   
	of the source code distribution tree; Copyright.html can be found at the  
	root level of an installed copy of the electronic HDF5 document set and   
	is linked from the top-level documents page.  It can also be found at     
	http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          
	access to either file, you may request a copy from help@hdfgroup.org.     

	Ported 2015 to the D Programming Language by Laeeth Isharc

	hdf5.hl - bindings for 'high level' C API for HDF5

	Not tested and may not be complete
*/

module hdf5.bindings.hlapi;
import hdf5.bindings.api;
import hdf5.bindings.enums;

alias hbool_t=int;
enum VLPT_REMOVED=false;

extern(C)
{

/**
	H5DOpublic.h
*/

	herr_t H5DOwrite_chunk(hid_t dset_id, hid_t dxpl_id, uint filters, const hsize_t *offset, size_t data_size, const (void*) buf);

/**
	H5DSpublic
*/
	enum DimensionScaleClass =		"DIMENSION_SCALE";
	enum DimensionList = 			"DIMENSION_LIST";
	enum ReferenceList =        	"REFERENCE_LIST";
	enum DimensionLabels =       	"DIMENSION_LABELS";

	alias DIMENSION_SCALE_CLASS =	DimensionScaleClass;
	alias DIMENSION_LIST =			DimensionList;
	alias REFERENCE_LIST =			ReferenceList;
	alias DIMENSION_LABELS =		DimensionLabels;


	alias H5DS_iterate_t = herr_t  function(hid_t dset, uint dim, hid_t scale, void *visitor_data);
	herr_t  H5DSattach_scale( hid_t did, hid_t dsid, uint idx);
	herr_t  H5DSdetach_scale( hid_t did, hid_t dsid, uint idx);
	herr_t  H5DSset_scale( hid_t dsid, const (char*) dimname);
	int H5DSget_num_scales( hid_t did, uint dim);
	herr_t  H5DSset_label( hid_t did, uint idx, const (char*) label);
	ssize_t H5DSget_label( hid_t did, uint idx, char *label, size_t size);
	ssize_t H5DSget_scale_name( hid_t did, char *name, size_t size);
	htri_t H5DSis_scale( hid_t did);
	herr_t  H5DSiterate_scales( hid_t did, uint dim, int *idx, H5DS_iterate_t visitor, void *visitor_data);
	htri_t H5DSis_attached( hid_t did, hid_t dsid, uint idx);

/**
	H5IMpublic
*/

	herr_t  H5IMmake_image_8bit( hid_t loc_id, const (char*) dset_name, hsize_t width, hsize_t height, const (ubyte*) buffer );
	herr_t  H5IMmake_image_24bit( hid_t loc_id, const (char*) dset_name, hsize_t width, hsize_t height, const (char*) interlace,
		const (ubyte*) buffer );
	herr_t  H5IMget_image_info( hid_t loc_id, const (char*) dset_name, hsize_t *width, hsize_t *height, hsize_t *planes, char *interlace,
	                     hssize_t *npals );
	herr_t  H5IMread_image( hid_t loc_id, const (char*) dset_name, ubyte *buffer );
	herr_t  H5IMmake_palette( hid_t loc_id, const (char*) pal_name, const hsize_t *pal_dims, const (ubyte*) pal_data );
	herr_t  H5IMlink_palette( hid_t loc_id, const (char*) image_name, const (char*) pal_name );
	herr_t  H5IMunlink_palette( hid_t loc_id, const (char*) image_name, const (char*) pal_name );
	herr_t  H5IMget_npalettes( hid_t loc_id, const (char*) image_name, hssize_t *npals );
	herr_t  H5IMget_palette_info( hid_t loc_id, const (char*) image_name, int pal_number, hsize_t *pal_dims );
	herr_t  H5IMget_palette( hid_t loc_id, const (char*) image_name, int pal_number, ubyte *pal_data );
	herr_t  H5IMis_image( hid_t loc_id, const (char*) dset_name );
	herr_t  H5IMis_palette( hid_t loc_id, const (char*) dset_name );

/**
	H5LPTpublic
*/

	// Flag definitions for H5LTopen_file_image()
	enum H5LT_FILE_IMAGE_OPEN_RW	=	0x0001; 	// Open image for read-write
	enum H5LT_FILE_IMAGE_DONT_COPY  =	0x0002; // The HDF5 lib won't copy user supplied image buffer. The same image is open with the
												// core driver.
	enum H5LT_FILE_IMAGE_DONT_RELEASE=	0x0004; // The HDF5 lib won't deallocate user supplied image buffer. The user application is responsible.
	enum H5LT_FILE_IMAGE_ALL		=	0x0007;

	enum H5LT_lang_t
	{
	    H5LT_LANG_ERR = -1, /*this is the first*/
	    H5LT_DDL      = 0,  /*for DDL*/
	    H5LT_C        = 1,  /*for C*/
	    H5LT_FORTRAN  = 2,  /*for Fortran*/
	    H5LT_NO_LANG  = 3   /*this is the last*/
	}

/**

	Make dataset functions

*/
 
	herr_t  H5LTmake_dataset( hid_t loc_id, const (char*) dset_name, int rank, const hsize_t *dims, hid_t type_id, const (void*) buffer );
	herr_t  H5LTmake_dataset_char( hid_t loc_id, const (char*) dset_name, int rank, const hsize_t *dims, const (char*) buffer );
	herr_t  H5LTmake_dataset_short( hid_t loc_id, const (char*) dset_name, int rank, const hsize_t *dims, const short *buffer );
	herr_t  H5LTmake_dataset_int( hid_t loc_id, const (char*) dset_name, int rank, const hsize_t *dims, const int *buffer );
	herr_t  H5LTmake_dataset_long( hid_t loc_id, const (char*) dset_name, int rank, const hsize_t *dims, const long *buffer );
	herr_t  H5LTmake_dataset_float( hid_t loc_id, const (char*) dset_name, int rank, const hsize_t *dims, const float *buffer );
	herr_t  H5LTmake_dataset_double( hid_t loc_id, const (char*) dset_name, int rank, const hsize_t *dims, const double *buffer );
	herr_t  H5LTmake_dataset_string( hid_t loc_id, const (char*) dset_name, const (char*) buf );

/**

	Read dataset functions
 
*/

	herr_t  H5LTread_dataset( hid_t loc_id, const (char*) dset_name, hid_t type_id, void *buffer );
	herr_t  H5LTread_dataset_char( hid_t loc_id, const (char*) dset_name, char *buffer );
	herr_t  H5LTread_dataset_short( hid_t loc_id, const (char*) dset_name, short *buffer );
	herr_t  H5LTread_dataset_int( hid_t loc_id, const (char*) dset_name, int *buffer );
	herr_t  H5LTread_dataset_long( hid_t loc_id, const (char*) dset_name, long *buffer );
	herr_t  H5LTread_dataset_float( hid_t loc_id, const (char*) dset_name, float *buffer );
	herr_t  H5LTread_dataset_double( hid_t loc_id, const (char*) dset_name, double *buffer );
	herr_t  H5LTread_dataset_string( hid_t loc_id, const (char*) dset_name, char *buf );

/**
	
	Query dataset functions

*/
 
	herr_t  H5LTget_dataset_ndims( hid_t loc_id, const (char*) dset_name, int *rank );
	herr_t  H5LTget_dataset_info( hid_t loc_id, const (char*) dset_name, hsize_t *dims, H5TClass *type_class, size_t *type_size );
	herr_t  H5LTfind_dataset( hid_t loc_id, const (char*) name );


/**

	Set attribute functions

*/

	herr_t  H5LTset_attribute_string( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const (char*) attr_data );
	herr_t  H5LTset_attribute_char( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const (char*) buffer, size_t size );
	herr_t  H5LTset_attribute_uchar( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const (ubyte*) buffer, size_t size );
	herr_t  H5LTset_attribute_short( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const short *buffer, size_t size );
	herr_t  H5LTset_attribute_ushort( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const ushort* buffer, size_t size );
	herr_t  H5LTset_attribute_int( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const int *buffer, size_t size );
	herr_t  H5LTset_attribute_uint( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const uint *buffer, size_t size );
	herr_t  H5LTset_attribute_long( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const long *buffer, size_t size );
	herr_t  H5LTset_attribute_long_long( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const long *buffer, size_t size );
	herr_t  H5LTset_attribute_ulong( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const ulong *buffer, size_t size );
	herr_t  H5LTset_attribute_float( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const float *buffer, size_t size );
	herr_t  H5LTset_attribute_double( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, const double *buffer, size_t size );

/**

	Get attribute functions

*/

	herr_t  H5LTget_attribute( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, hid_t mem_type_id, void *data );
	herr_t  H5LTget_attribute_string( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, char *data );
	herr_t  H5LTget_attribute_char( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, char *data );
	herr_t  H5LTget_attribute_uchar( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, ubyte *data );
	herr_t  H5LTget_attribute_short( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, short *data );
	herr_t  H5LTget_attribute_ushort( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, ushort* data );
	herr_t  H5LTget_attribute_int( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, int *data );
	herr_t  H5LTget_attribute_uint( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, uint *data );
	herr_t  H5LTget_attribute_long( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, long *data );
	herr_t  H5LTget_attribute_long_long( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, long *data );
	herr_t  H5LTget_attribute_ulong( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, ulong *data );
	herr_t  H5LTget_attribute_float( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, float *data );
	herr_t  H5LTget_attribute_double( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, double *data );


/**

	Query attribute functions

*/


	herr_t  H5LTget_attribute_ndims( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, int *rank );
	herr_t  H5LTget_attribute_info( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, hsize_t *dims, H5TClass *type_class, size_t *type_size );

/**

	General functions

*/

	hid_t H5LTtext_to_dtype(const (char*) text, H5LT_lang_t lang_type);
	herr_t H5LTdtype_to_text(hid_t dtype, char *str, H5LT_lang_t lang_type, size_t *len);

/**

	Utility functions

*/

	herr_t H5LTfind_attribute( hid_t loc_id, const (char*) name );
	htri_t H5LTpath_valid(hid_t loc_id, const (char*) path, hbool_t check_object_valid);

/**
	
	File image operations functions
 
*/

	hid_t H5LTopen_file_image(void *buf_ptr, size_t buf_size, uint flags);

/**
	H5PTpublic
*/

/**
	
	Create/Open/Close functions

*/

	hid_t H5PTcreate_fl ( hid_t loc_id, const (char*) dset_name, hid_t dtype_id, hsize_t chunk_size, int compression );
	static if (VLPT_REMOVED)
		hid_t H5PTcreate_vl ( hid_t loc_id, const (char*) dset_name, hsize_t chunk_size );

	hid_t H5PTopen( hid_t loc_id, const (char*) dset_name );
	herr_t  H5PTclose( hid_t table_id );

/**

	Write functions

*/

herr_t  H5PTappend( hid_t table_id, size_t nrecords, const (void*) data );

/**

	Read functions

*/

herr_t  H5PTget_next( hid_t table_id, size_t nrecords, void * data );
herr_t  H5PTread_packets( hid_t table_id, hsize_t start, size_t nrecords, void *data );

/**

	Inquiry functions

*/


	herr_t  H5PTget_num_packets( hid_t table_id, hsize_t *nrecords );
	herr_t  H5PTis_valid( hid_t table_id );
	static if (VLPT_REMOVED)
		herr_t  H5PTis_varlen( hid_t table_id );

/**

	Packet Table "current index" functions

*/

	herr_t  H5PTcreate_index( hid_t table_id );
	herr_t  H5PTset_index( hid_t table_id, hsize_t pt_index );
	herr_t  H5PTget_index( hid_t table_id, hsize_t *pt_index );

/**

	Memory Management functions

*/

	static if (VLPT_REMOVED)
		herr_t  H5PTfree_vlen_readbuff( hid_t table_id, size_t bufflen, void * buff );

/**
	H5TBpublic
*/

/**

	Crea functions

*/

	herr_t  H5TBmake_table( const (char*) table_title, hid_t loc_id, const (char*) dset_name, hsize_t nfields, hsize_t nrecords,
                       size_t type_size, const (char**) field_names, const size_t *field_offset, const hid_t *field_types,
                       hsize_t chunk_size, void *fill_data, int compress, const (void*) buf );


/**

	Write functions

*/

	herr_t  H5TBappend_records( hid_t loc_id, const (char*) dset_name, hsize_t nrecords, size_t type_size, const size_t *field_offset,
                           const size_t *dst_sizes, const (void*) buf );

	herr_t  H5TBwrite_records( hid_t loc_id, const (char*) dset_name, hsize_t start, hsize_t nrecords, size_t type_size, const size_t *field_offset,
                          const size_t *dst_sizes, const (void*) buf );

	herr_t  H5TBwrite_fields_name( hid_t loc_id, const (char*) dset_name, const (char*) field_names, hsize_t start, hsize_t nrecords,
						size_t type_size, const size_t *field_offset, const size_t *dst_sizes, const (void*) buf );

	herr_t  H5TBwrite_fields_index( hid_t loc_id, const (char*) dset_name, hsize_t nfields, const int *field_index, hsize_t start,
						hsize_t nrecords, size_t type_size, const size_t *field_offset, const size_t *dst_sizes, const (void*) buf );


/**

	Read functions

*/

	herr_t  H5TBread_table( hid_t loc_id, const (char*) dset_name, size_t dst_size, const size_t *dst_offset, const size_t *dst_sizes,
                       void *dst_buf );

	herr_t  H5TBread_fields_name( hid_t loc_id, const (char*) dset_name, const (char*) field_names, hsize_t start, hsize_t nrecords,
                        size_t type_size, const size_t *field_offset, const size_t *dst_sizes, void *buf );

	herr_t  H5TBread_fields_index( hid_t loc_id, const (char*) dset_name, hsize_t nfields, const int *field_index, hsize_t start,
                        hsize_t nrecords, size_t type_size, const size_t *field_offset, const size_t *dst_sizes, void *buf );


	herr_t  H5TBread_records( hid_t loc_id, const (char*) dset_name, hsize_t start, hsize_t nrecords, size_t type_size,
						const size_t *dst_offset, const size_t *dst_sizes, void *buf );


/**

	Inquiry functions

*/

	herr_t  H5TBget_table_info ( hid_t loc_id, const (char*) dset_name, hsize_t *nfields, hsize_t *nrecords );
	herr_t  H5TBget_field_info( hid_t loc_id, const (char*) dset_name, char **field_names, size_t *field_sizes, size_t *field_offsets,
						size_t *type_size );


/**

	Manipulation functions
 
*/

	herr_t  H5TBdelete_record( hid_t loc_id, const (char*) dset_name, hsize_t start, hsize_t nrecords );
	herr_t  H5TBinsert_record( hid_t loc_id, const (char*) dset_name, hsize_t start, hsize_t nrecords, size_t dst_size, const size_t *dst_offset,
	                          const size_t *dst_sizes, void *buf );
	herr_t  H5TBadd_records_from( hid_t loc_id, const (char*) dset_name1, hsize_t start1, hsize_t nrecords, const (char*) dset_name2,
	                             hsize_t start2 );
	herr_t  H5TBcombine_tables( hid_t loc_id1, const (char*) dset_name1, hid_t loc_id2, const (char*) dset_name2, const (char*) dset_name3 );
	herr_t  H5TBinsert_field( hid_t loc_id, const (char*) dset_name, const (char*) field_name, hid_t field_type, hsize_t position,
	                         const (void*) fill_data, const (void*) buf );
	herr_t  H5TBdelete_field( hid_t loc_id, const (char*) dset_name, const (char*) field_name );


/**

	Table attribute functions

*/

	herr_t  H5TBAget_title( hid_t loc_id, char *table_title );
	htri_t  H5TBAget_fill(hid_t loc_id, const (char*) dset_name, hid_t dset_id, ubyte *dst_buf);

} // end extern(C)