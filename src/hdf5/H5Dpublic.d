/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright by The HDF Group.                                               *
 * Copyright by the Board of Trustees of the University of Illinois.         *
 * All rights reserved.                                                      *
 *                                                                           *
 * This file is part of HDF5.  The full HDF5 copyright notice, including     *
 * terms governing use, modification, and redistribution, is contained in    *
 * the files COPYING and Copyright.html.  COPYING can be found at the root   *
 * of the source code distribution tree; Copyright.html can be found at the  *
 * root level of an installed copy of the electronic HDF5 document set and   *
 * is linked from the top-level documents page.  It can also be found at     *
 * http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          *
 * access to either file, you may request a copy from help@hdfgroup.org.     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

module hdf5.H5Dpublic;

/*
 * This file contains public declarations for the H5D module.
 */

/* Public headers needed by this file */
import hdf5.H5public;
import hdf5.H5Ipublic;

extern(C):

/*****************/
/* Public Macros */
/*****************/

/* Macros used to "unset" chunk cache configuration parameters */
enum H5D_CHUNK_CACHE_NSLOTS_DEFAULT = (cast(size_t) -1);
enum H5D_CHUNK_CACHE_NBYTES_DEFAULT = (cast(size_t) -1);
enum H5D_CHUNK_CACHE_W0_DEFAULT     = -1.;

/* Property names for H5LTDdirect_chunk_write */   
enum H5D_XFER_DIRECT_CHUNK_WRITE_FLAG_NAME     = "direct_chunk_flag";
enum H5D_XFER_DIRECT_CHUNK_WRITE_FILTERS_NAME  = "direct_chunk_filters";
enum H5D_XFER_DIRECT_CHUNK_WRITE_OFFSET_NAME   = "direct_chunk_offset";
enum H5D_XFER_DIRECT_CHUNK_WRITE_DATASIZE_NAME = "direct_chunk_datasize";

/*******************/
/* Public Typedefs */
/*******************/

/* Values for the H5D_LAYOUT property */
enum H5D_layout_t {
    H5D_LAYOUT_ERROR	= -1,

    H5D_COMPACT		= 0,	/*raw data is very small		     */
    H5D_CONTIGUOUS	= 1,	/*the default				     */
    H5D_CHUNKED		= 2,	/*slow and fancy			     */
    H5D_NLAYOUTS	= 3	/*this one must be last!		     */
}

/* Types of chunk index data structures */
enum H5D_chunk_index_t {
    H5D_CHUNK_BTREE	= 0	/* v1 B-tree index			     */
}

/* Values for the space allocation time property */
enum H5D_alloc_time_t {
    H5D_ALLOC_TIME_ERROR	= -1,
    H5D_ALLOC_TIME_DEFAULT  	= 0,
    H5D_ALLOC_TIME_EARLY	= 1,
    H5D_ALLOC_TIME_LATE		= 2,
    H5D_ALLOC_TIME_INCR		= 3
}

/* Values for the status of space allocation */
enum H5D_space_status_t {
    H5D_SPACE_STATUS_ERROR		= -1,
    H5D_SPACE_STATUS_NOT_ALLOCATED	= 0,
    H5D_SPACE_STATUS_PART_ALLOCATED	= 1,
    H5D_SPACE_STATUS_ALLOCATED		= 2
}

/* Values for time of writing fill value property */
enum H5D_fill_time_t {
    H5D_FILL_TIME_ERROR	= -1,
    H5D_FILL_TIME_ALLOC = 0,
    H5D_FILL_TIME_NEVER	= 1,
    H5D_FILL_TIME_IFSET	= 2
}

/* Values for fill value status */
enum H5D_fill_value_t {
    H5D_FILL_VALUE_ERROR        =-1,
    H5D_FILL_VALUE_UNDEFINED    =0,
    H5D_FILL_VALUE_DEFAULT      =1,
    H5D_FILL_VALUE_USER_DEFINED =2
}

/********************/
/* Public Variables */
/********************/

/*********************/
/* Public Prototypes */
/*********************/

/* Define the operator function pointer for H5Diterate() */
alias H5D_operator_t = herr_t function(void *elem, hid_t type_id, int ndim,
				 const hsize_t *point, void *operator_data);

/* Define the operator function pointer for H5Dscatter() */
alias H5D_scatter_func_t = herr_t function(const void **src_buf/*out*/,
                                     size_t *src_buf_bytes_used/*out*/,
                                     void *op_data);

/* Define the operator function pointer for H5Dgather() */
alias H5D_gather_func_t = herr_t function(const void *dst_buf,
                                    size_t dst_buf_bytes_used, void *op_data);

version(Posix) {
  hid_t H5Dcreate2(hid_t loc_id, const char *name, hid_t type_id,
                   hid_t space_id, hid_t lcpl_id, hid_t dcpl_id, hid_t dapl_id);
  hid_t H5Dcreate_anon(hid_t file_id, hid_t type_id, hid_t space_id,
                       hid_t plist_id, hid_t dapl_id);
  hid_t H5Dopen2(hid_t file_id, const char *name, hid_t dapl_id);
  herr_t H5Dclose(hid_t dset_id);
  hid_t H5Dget_space(hid_t dset_id);
  herr_t H5Dget_space_status(hid_t dset_id, H5D_space_status_t *allocation);
  hid_t H5Dget_type(hid_t dset_id);
  hid_t H5Dget_create_plist(hid_t dset_id);
  hid_t H5Dget_access_plist(hid_t dset_id);
  hsize_t H5Dget_storage_size(hid_t dset_id);
  haddr_t H5Dget_offset(hid_t dset_id);
  herr_t H5Dread(hid_t dset_id, hid_t mem_type_id, hid_t mem_space_id,
                 hid_t file_space_id, hid_t plist_id, void *buf/*out*/);
  herr_t H5Dwrite(hid_t dset_id, hid_t mem_type_id, hid_t mem_space_id,
                  hid_t file_space_id, hid_t plist_id, const void *buf);
  herr_t H5Diterate(void *buf, hid_t type_id, hid_t space_id,
                    H5D_operator_t op, void *operator_data);
  herr_t H5Dvlen_reclaim(hid_t type_id, hid_t space_id, hid_t plist_id, void *buf);
  herr_t H5Dvlen_get_buf_size(hid_t dataset_id, hid_t type_id, hid_t space_id, hsize_t *size);
  herr_t H5Dfill(const void *fill, hid_t fill_type, void *buf,
                 hid_t buf_type, hid_t space);
  herr_t H5Dset_extent(hid_t dset_id, const hsize_t size[]);
  herr_t H5Dscatter(H5D_scatter_func_t op, void *op_data, hid_t type_id,
                    hid_t dst_space_id, void *dst_buf);
  herr_t H5Dgather(hid_t src_space_id, const void *src_buf, hid_t type_id,
                   size_t dst_buf_size, void *dst_buf, H5D_gather_func_t op, void *op_data);
  herr_t H5Ddebug(hid_t dset_id);
}

/++ DEPRECATED
/* Symbols defined for compatibility with previous versions of the HDF5 API.
 *
 * Use of these symbols is deprecated.
 */
#ifndef H5_NO_DEPRECATED_SYMBOLS

/* Macros */


/* Typedefs */


/* Function prototypes */
hid_t H5Dcreate1(hid_t file_id, const char *name, hid_t type_id,
    hid_t space_id, hid_t dcpl_id);
hid_t H5Dopen1(hid_t file_id, const char *name);
herr_t H5Dextend(hid_t dset_id, const hsize_t size[]);

#endif /* H5_NO_DEPRECATED_SYMBOLS */
+/

