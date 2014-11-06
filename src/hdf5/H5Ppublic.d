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

module hdf5.H5Ppublic;

/*
 * This file contains function prototypes for each exported function in the
 * H5P module.
 */

/* System headers needed by this file */

/* Public headers needed by this file */
/++ HEADERS
#include "H5ACpublic.h"
#include "H5FDpublic.h"
#include "H5Lpublic.h"
#include "H5Opublic.h"
#include "H5MMpublic.h"
+/

import hdf5.H5public;
import hdf5.H5Dpublic;
import hdf5.H5Fpublic;
import hdf5.H5Ipublic;
import hdf5.H5Tpublic;
import hdf5.H5Zpublic;

extern(C):

/*****************/
/* Public Macros */
/*****************/

/*
 * The library's property list classes
 */
alias H5P_ROOT = H5P_CLS_ROOT_g;
alias H5P_OBJECT_CREATE = H5P_CLS_OBJECT_CREATE_g;
alias H5P_FILE_CREATE = H5P_CLS_FILE_CREATE_g;
alias H5P_FILE_ACCESS = H5P_CLS_FILE_ACCESS_g;
alias H5P_DATASET_CREATE = H5P_CLS_DATASET_CREATE_g;
alias H5P_DATASET_ACCESS = H5P_CLS_DATASET_ACCESS_g;
alias H5P_DATASET_XFER = H5P_CLS_DATASET_XFER_g;
alias H5P_FILE_MOUNT = H5P_CLS_FILE_MOUNT_g;
alias H5P_GROUP_CREATE = H5P_CLS_GROUP_CREATE_g;
alias H5P_GROUP_ACCESS = H5P_CLS_GROUP_ACCESS_g;
alias H5P_DATATYPE_CREATE = H5P_CLS_DATATYPE_CREATE_g;
alias H5P_DATATYPE_ACCESS = H5P_CLS_DATATYPE_ACCESS_g;
alias H5P_STRING_CREATE = H5P_CLS_STRING_CREATE_g;
alias H5P_ATTRIBUTE_CREATE = H5P_CLS_ATTRIBUTE_CREATE_g;
alias H5P_OBJECT_COPY = H5P_CLS_OBJECT_COPY_g;
alias H5P_LINK_CREATE = H5P_CLS_LINK_CREATE_g;
alias H5P_LINK_ACCESS = H5P_CLS_LINK_ACCESS_g;

/*
 * The library's default property lists
 */
alias H5P_FILE_CREATE_DEFAULT = H5P_LST_FILE_CREATE_g;
alias H5P_FILE_ACCESS_DEFAULT = H5P_LST_FILE_ACCESS_g;
alias H5P_DATASET_CREATE_DEFAULT = H5P_LST_DATASET_CREATE_g;
alias H5P_DATASET_ACCESS_DEFAULT = H5P_LST_DATASET_ACCESS_g;
alias H5P_DATASET_XFER_DEFAULT = H5P_LST_DATASET_XFER_g;
alias H5P_FILE_MOUNT_DEFAULT = H5P_LST_FILE_MOUNT_g;
alias H5P_GROUP_CREATE_DEFAULT = H5P_LST_GROUP_CREATE_g;
alias H5P_GROUP_ACCESS_DEFAULT = H5P_LST_GROUP_ACCESS_g;
alias H5P_DATATYPE_CREATE_DEFAULT = H5P_LST_DATATYPE_CREATE_g;
alias H5P_DATATYPE_ACCESS_DEFAULT = H5P_LST_DATATYPE_ACCESS_g;
alias H5P_ATTRIBUTE_CREATE_DEFAULT = H5P_LST_ATTRIBUTE_CREATE_g;
alias H5P_OBJECT_COPY_DEFAULT = H5P_LST_OBJECT_COPY_g;
alias H5P_LINK_CREATE_DEFAULT = H5P_LST_LINK_CREATE_g;
alias H5P_LINK_ACCESS_DEFAULT = H5P_LST_LINK_ACCESS_g;

/* Common creation order flags (for links in groups and attributes on objects) */
enum H5P_CRT_ORDER_TRACKED = 0x0001;
enum H5P_CRT_ORDER_INDEXED = 0x0002;

/*******************/
/* Public Typedefs */
/*******************/

/* Define property list class callback function pointer types */
alias H5P_cls_create_func_t = herr_t function(hid_t prop_id, void *create_data);
alias H5P_cls_copy_func_t = herr_t function(hid_t new_prop_id, hid_t old_prop_id, void *copy_data);
alias H5P_cls_close_func_t = herr_t function(hid_t prop_id, void *close_data);

/* Define property list callback function pointer types */
alias H5P_prp_cb1_t = herr_t function(const char *name, size_t size, void *value);
alias H5P_prp_cb2_t = herr_t function(hid_t prop_id, const char *name, size_t size, void *value);
alias H5P_prp_create_func_t = H5P_prp_cb1_t;
alias H5P_prp_set_func_t = H5P_prp_cb2_t;
alias H5P_prp_get_func_t = H5P_prp_cb2_t;
alias H5P_prp_delete_func_t = H5P_prp_cb2_t;
alias H5P_prp_copy_func_t = H5P_prp_cb1_t;
alias H5P_prp_compare_func_t = int function(const void *value1, const void *value2, size_t size);
alias H5P_prp_close_func_t = H5P_prp_cb1_t;

/* Define property list iteration function type */
alias H5P_iterate_t = herr_t function(hid_t id, const char *name, void *iter_data);

/* Actual IO mode property */
enum H5D_mpio_actual_chunk_opt_mode_t {
    /* The default value, H5D_MPIO_NO_CHUNK_OPTIMIZATION, is used for all I/O
     * operations that do not use chunk optimizations, including non-collective
     * I/O and contiguous collective I/O.
     */
    H5D_MPIO_NO_CHUNK_OPTIMIZATION = 0,
    H5D_MPIO_LINK_CHUNK,
    H5D_MPIO_MULTI_CHUNK
}

enum H5D_mpio_actual_io_mode_t {
    /* The following four values are conveniently defined as a bit field so that
     * we can switch from the default to indpendent or collective and then to
     * mixed without having to check the original value. 
     * 
     * NO_COLLECTIVE means that either collective I/O wasn't requested or that 
     * no I/O took place.
     *
     * CHUNK_INDEPENDENT means that collective I/O was requested, but the
     * chunk optimization scheme chose independent I/O for each chunk.
     */
    H5D_MPIO_NO_COLLECTIVE = 0x0,
    H5D_MPIO_CHUNK_INDEPENDENT = 0x1,
    H5D_MPIO_CHUNK_COLLECTIVE = 0x2,
    H5D_MPIO_CHUNK_MIXED = 0x1 | 0x2,

    /* The contiguous case is separate from the bit field. */
    H5D_MPIO_CONTIGUOUS_COLLECTIVE = 0x4
}

/* Broken collective IO property */
enum H5D_mpio_no_collective_cause_t {
    H5D_MPIO_COLLECTIVE = 0x00,
    H5D_MPIO_SET_INDEPENDENT = 0x01,
    H5D_MPIO_DATATYPE_CONVERSION = 0x02,
    H5D_MPIO_DATA_TRANSFORMS = 0x04,
    H5D_MPIO_MPI_OPT_TYPES_ENV_VAR_DISABLED = 0x08,
    H5D_MPIO_NOT_SIMPLE_OR_SCALAR_DATASPACES = 0x10,
    H5D_MPIO_NOT_CONTIGUOUS_OR_CHUNKED_DATASET = 0x20,
    H5D_MPIO_FILTERS = 0x40
}

/********************/
/* Public Variables */
/********************/

/* Property list class IDs */
/* (Internal to library, do not use!  Use macros above) */
extern __gshared hid_t H5P_CLS_ROOT_g;
extern __gshared hid_t H5P_CLS_OBJECT_CREATE_g;
extern __gshared hid_t H5P_CLS_FILE_CREATE_g;
extern __gshared hid_t H5P_CLS_FILE_ACCESS_g;
extern __gshared hid_t H5P_CLS_DATASET_CREATE_g;
extern __gshared hid_t H5P_CLS_DATASET_ACCESS_g;
extern __gshared hid_t H5P_CLS_DATASET_XFER_g;
extern __gshared hid_t H5P_CLS_FILE_MOUNT_g;
extern __gshared hid_t H5P_CLS_GROUP_CREATE_g;
extern __gshared hid_t H5P_CLS_GROUP_ACCESS_g;
extern __gshared hid_t H5P_CLS_DATATYPE_CREATE_g;
extern __gshared hid_t H5P_CLS_DATATYPE_ACCESS_g;
extern __gshared hid_t H5P_CLS_STRING_CREATE_g;
extern __gshared hid_t H5P_CLS_ATTRIBUTE_CREATE_g;
extern __gshared hid_t H5P_CLS_OBJECT_COPY_g;
extern __gshared hid_t H5P_CLS_LINK_CREATE_g;
extern __gshared hid_t H5P_CLS_LINK_ACCESS_g;

/* Default roperty list IDs */
/* (Internal to library, do not use!  Use macros above) */
extern __gshared hid_t H5P_LST_FILE_CREATE_g;
extern __gshared hid_t H5P_LST_FILE_ACCESS_g;
extern __gshared hid_t H5P_LST_DATASET_CREATE_g;
extern __gshared hid_t H5P_LST_DATASET_ACCESS_g;
extern __gshared hid_t H5P_LST_DATASET_XFER_g;
extern __gshared hid_t H5P_LST_FILE_MOUNT_g;
extern __gshared hid_t H5P_LST_GROUP_CREATE_g;
extern __gshared hid_t H5P_LST_GROUP_ACCESS_g;
extern __gshared hid_t H5P_LST_DATATYPE_CREATE_g;
extern __gshared hid_t H5P_LST_DATATYPE_ACCESS_g;
extern __gshared hid_t H5P_LST_ATTRIBUTE_CREATE_g;
extern __gshared hid_t H5P_LST_OBJECT_COPY_g;
extern __gshared hid_t H5P_LST_LINK_CREATE_g;
extern __gshared hid_t H5P_LST_LINK_ACCESS_g;

/*********************/
/* Public Prototypes */
/*********************/

version(Posix) {

/* Generic property list routines */
hid_t H5Pcreate_class(hid_t parent, const char *name,
    H5P_cls_create_func_t cls_create, void *create_data,
    H5P_cls_copy_func_t cls_copy, void *copy_data,
    H5P_cls_close_func_t cls_close, void *close_data);
char *H5Pget_class_name(hid_t pclass_id);
hid_t H5Pcreate(hid_t cls_id);
herr_t H5Pregister2(hid_t cls_id, const char *name, size_t size,
    void *def_value, H5P_prp_create_func_t prp_create,
    H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get,
    H5P_prp_delete_func_t prp_del, H5P_prp_copy_func_t prp_copy,
    H5P_prp_compare_func_t prp_cmp, H5P_prp_close_func_t prp_close);
herr_t H5Pinsert2(hid_t plist_id, const char *name, size_t size,
    void *value, H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get,
    H5P_prp_delete_func_t prp_delete, H5P_prp_copy_func_t prp_copy,
    H5P_prp_compare_func_t prp_cmp, H5P_prp_close_func_t prp_close);
herr_t H5Pset(hid_t plist_id, const char *name, void *value);
htri_t H5Pexist(hid_t plist_id, const char *name);
herr_t H5Pget_size(hid_t id, const char *name, size_t *size);
herr_t H5Pget_nprops(hid_t id, size_t *nprops);
hid_t H5Pget_class(hid_t plist_id);
hid_t H5Pget_class_parent(hid_t pclass_id);
herr_t H5Pget(hid_t plist_id, const char *name, void * value);
htri_t H5Pequal(hid_t id1, hid_t id2);
htri_t H5Pisa_class(hid_t plist_id, hid_t pclass_id);
int H5Piterate(hid_t id, int *idx, H5P_iterate_t iter_func,
            void *iter_data);
herr_t H5Pcopy_prop(hid_t dst_id, hid_t src_id, const char *name);
herr_t H5Premove(hid_t plist_id, const char *name);
herr_t H5Punregister(hid_t pclass_id, const char *name);
herr_t H5Pclose_class(hid_t plist_id);
herr_t H5Pclose(hid_t plist_id);
hid_t H5Pcopy(hid_t plist_id);

/* Object creation property list (OCPL) routines */
herr_t H5Pset_attr_phase_change(hid_t plist_id, uint max_compact, uint min_dense);
herr_t H5Pget_attr_phase_change(hid_t plist_id, uint *max_compact, uint *min_dense);
herr_t H5Pset_attr_creation_order(hid_t plist_id, uint crt_order_flags);
herr_t H5Pget_attr_creation_order(hid_t plist_id, uint *crt_order_flags);
herr_t H5Pset_obj_track_times(hid_t plist_id, hbool_t track_times);
herr_t H5Pget_obj_track_times(hid_t plist_id, hbool_t *track_times);
herr_t H5Pmodify_filter(hid_t plist_id, H5Z_filter_t filter,
        int flags, size_t cd_nelmts,
        const int cd_values[/*cd_nelmts*/]);
herr_t H5Pset_filter(hid_t plist_id, H5Z_filter_t filter,
        int flags, size_t cd_nelmts,
        const int c_values[]);
int H5Pget_nfilters(hid_t plist_id);
H5Z_filter_t H5Pget_filter2(hid_t plist_id, uint filter,
       int *flags/*out*/,
       size_t *cd_nelmts/*out*/,
       uint cd_values[]/*out*/,
       size_t namelen, char name[],
       uint *filter_config /*out*/);
herr_t H5Pget_filter_by_id2(hid_t plist_id, H5Z_filter_t id,
       uint *flags/*out*/, size_t *cd_nelmts/*out*/,
       int cd_values[]/*out*/, size_t namelen, char name[]/*out*/,
       int *filter_config/*out*/);
htri_t H5Pall_filters_avail(hid_t plist_id);
herr_t H5Premove_filter(hid_t plist_id, H5Z_filter_t filter);
herr_t H5Pset_deflate(hid_t plist_id, int aggression);
herr_t H5Pset_fletcher32(hid_t plist_id);

/* File creation property list (FCPL) routines */
herr_t H5Pget_version(hid_t plist_id, uint *boot/*out*/,
         uint *freelist/*out*/, uint *stab/*out*/,
         uint *shhdr/*out*/);
herr_t H5Pset_userblock(hid_t plist_id, hsize_t size);
herr_t H5Pget_userblock(hid_t plist_id, hsize_t *size);
herr_t H5Pset_sizes(hid_t plist_id, size_t sizeof_addr,
       size_t sizeof_size);
herr_t H5Pget_sizes(hid_t plist_id, size_t *sizeof_addr/*out*/,
       size_t *sizeof_size/*out*/);
herr_t H5Pset_sym_k(hid_t plist_id, uint ik, uint lk);
herr_t H5Pget_sym_k(hid_t plist_id, uint *ik/*out*/, uint *lk/*out*/);
herr_t H5Pset_istore_k(hid_t plist_id, uint ik);
herr_t H5Pget_istore_k(hid_t plist_id, uint *ik/*out*/);
herr_t H5Pset_shared_mesg_nindexes(hid_t plist_id, uint nindexes);
herr_t H5Pget_shared_mesg_nindexes(hid_t plist_id, uint *nindexes);
herr_t H5Pset_shared_mesg_index(hid_t plist_id, uint index_num, uint mesg_type_flags, uint min_mesg_size);
herr_t H5Pget_shared_mesg_index(hid_t plist_id, uint index_num, uint *mesg_type_flags, uint *min_mesg_size);
herr_t H5Pset_shared_mesg_phase_change(hid_t plist_id, uint max_list, uint min_btree);
herr_t H5Pget_shared_mesg_phase_change(hid_t plist_id, uint *max_list, uint *min_btree);

/* File access property list (FAPL) routines */
herr_t H5Pset_alignment(hid_t fapl_id, hsize_t threshold,
    hsize_t alignment);
herr_t H5Pget_alignment(hid_t fapl_id, hsize_t *threshold/*out*/,
    hsize_t *alignment/*out*/);
herr_t H5Pset_driver(hid_t plist_id, hid_t driver_id,
        const void *driver_info);
hid_t H5Pget_driver(hid_t plist_id);
void *H5Pget_driver_info(hid_t plist_id);
herr_t H5Pset_family_offset(hid_t fapl_id, hsize_t offset);
herr_t H5Pget_family_offset(hid_t fapl_id, hsize_t *offset);
/++
herr_t H5Pset_multi_type(hid_t fapl_id, H5FD_mem_t type);
herr_t H5Pget_multi_type(hid_t fapl_id, H5FD_mem_t *type);
+/
herr_t H5Pset_cache(hid_t plist_id, int mdc_nelmts,
       size_t rdcc_nslots, size_t rdcc_nbytes,
       double rdcc_w0);
herr_t H5Pget_cache(hid_t plist_id,
       int *mdc_nelmts, /* out */
       size_t *rdcc_nslots/*out*/,
       size_t *rdcc_nbytes/*out*/, double *rdcc_w0);
/++
herr_t H5Pset_mdc_config(hid_t    plist_id,
       H5AC_cache_config_t * config_ptr);
herr_t H5Pget_mdc_config(hid_t     plist_id,
       H5AC_cache_config_t * config_ptr);	/* out */
+/
herr_t H5Pset_gc_references(hid_t fapl_id, uint gc_ref);
herr_t H5Pget_gc_references(hid_t fapl_id, uint *gc_ref/*out*/);
herr_t H5Pset_fclose_degree(hid_t fapl_id, H5F_close_degree_t degree);
herr_t H5Pget_fclose_degree(hid_t fapl_id, H5F_close_degree_t *degree);
herr_t H5Pset_meta_block_size(hid_t fapl_id, hsize_t size);
herr_t H5Pget_meta_block_size(hid_t fapl_id, hsize_t *size/*out*/);
herr_t H5Pset_sieve_buf_size(hid_t fapl_id, size_t size);
herr_t H5Pget_sieve_buf_size(hid_t fapl_id, size_t *size/*out*/);
herr_t H5Pset_small_data_block_size(hid_t fapl_id, hsize_t size);
herr_t H5Pget_small_data_block_size(hid_t fapl_id, hsize_t *size/*out*/);
herr_t H5Pset_libver_bounds(hid_t plist_id, H5F_libver_t low,
    H5F_libver_t high);
herr_t H5Pget_libver_bounds(hid_t plist_id, H5F_libver_t *low,
    H5F_libver_t *high);
herr_t H5Pset_elink_file_cache_size(hid_t plist_id, uint efc_size);
herr_t H5Pget_elink_file_cache_size(hid_t plist_id, uint *efc_size);
herr_t H5Pset_file_image(hid_t fapl_id, void *buf_ptr, size_t buf_len);
herr_t H5Pget_file_image(hid_t fapl_id, void **buf_ptr_ptr, size_t *buf_len_ptr);
/++
herr_t H5Pset_file_image_callbacks(hid_t fapl_id,
       H5FD_file_image_callbacks_t *callbacks_ptr);
herr_t H5Pget_file_image_callbacks(hid_t fapl_id,
       H5FD_file_image_callbacks_t *callbacks_ptr);
+/

herr_t H5Pset_core_write_tracking(hid_t fapl_id, hbool_t is_enabled, size_t page_size);
herr_t H5Pget_core_write_tracking(hid_t fapl_id, hbool_t *is_enabled, size_t *page_size);

/* Dataset creation property list (DCPL) routines */
herr_t H5Pset_layout(hid_t plist_id, H5D_layout_t layout);
H5D_layout_t H5Pget_layout(hid_t plist_id);
herr_t H5Pset_chunk(hid_t plist_id, int ndims, const hsize_t *dim/*ndims*/);
int H5Pget_chunk(hid_t plist_id, int max_ndims, hsize_t *dim/*out*/);
herr_t H5Pset_external(hid_t plist_id, const char *name, off_t offset,
          hsize_t size);
int H5Pget_external_count(hid_t plist_id);
herr_t H5Pget_external(hid_t plist_id, uint idx, size_t name_size,
          char *name/*out*/, off_t *offset/*out*/,
          hsize_t *size/*out*/);
herr_t H5Pset_szip(hid_t plist_id, uint options_mask, uint pixels_per_block);
herr_t H5Pset_shuffle(hid_t plist_id);
herr_t H5Pset_nbit(hid_t plist_id);
herr_t H5Pset_scaleoffset(hid_t plist_id, H5Z_SO_scale_type_t scale_type, int scale_factor);
herr_t H5Pset_fill_value(hid_t plist_id, hid_t type_id,
     const void *value);
herr_t H5Pget_fill_value(hid_t plist_id, hid_t type_id,
     void *value/*out*/);
herr_t H5Pfill_value_defined(hid_t plist, H5D_fill_value_t *status);
herr_t H5Pset_alloc_time(hid_t plist_id, H5D_alloc_time_t
	alloc_time);
herr_t H5Pget_alloc_time(hid_t plist_id, H5D_alloc_time_t
	*alloc_time/*out*/);
herr_t H5Pset_fill_time(hid_t plist_id, H5D_fill_time_t fill_time);
herr_t H5Pget_fill_time(hid_t plist_id, H5D_fill_time_t
	*fill_time/*out*/);

/* Dataset access property list (DAPL) routines */
herr_t H5Pset_chunk_cache(hid_t dapl_id, size_t rdcc_nslots,
       size_t rdcc_nbytes, double rdcc_w0);
herr_t H5Pget_chunk_cache(hid_t dapl_id,
       size_t *rdcc_nslots/*out*/,
       size_t *rdcc_nbytes/*out*/,
       double *rdcc_w0/*out*/);

/* Dataset xfer property list (DXPL) routines */
herr_t H5Pset_data_transform(hid_t plist_id, const char* expression);
ssize_t H5Pget_data_transform(hid_t plist_id, char* expression /*out*/, size_t size);
herr_t H5Pset_buffer(hid_t plist_id, size_t size, void *tconv,
        void *bkg);
size_t H5Pget_buffer(hid_t plist_id, void **tconv/*out*/,
        void **bkg/*out*/);
herr_t H5Pset_preserve(hid_t plist_id, hbool_t status);
int H5Pget_preserve(hid_t plist_id);
herr_t H5Pset_edc_check(hid_t plist_id, H5Z_EDC_t check);
H5Z_EDC_t H5Pget_edc_check(hid_t plist_id);
herr_t H5Pset_filter_callback(hid_t plist_id, H5Z_filter_func_t func,
                                     void* op_data);
herr_t H5Pset_btree_ratios(hid_t plist_id, double left, double middle,
       double right);
herr_t H5Pget_btree_ratios(hid_t plist_id, double *left/*out*/,
       double *middle/*out*/,
       double *right/*out*/);
/++
herr_t H5Pset_vlen_mem_manager(hid_t plist_id,
                                       H5MM_allocate_t alloc_func,
                                       void *alloc_info, H5MM_free_t free_func,
                                       void *free_info);
herr_t H5Pget_vlen_mem_manager(hid_t plist_id,
                                       H5MM_allocate_t *alloc_func,
                                       void **alloc_info,
                                       H5MM_free_t *free_func,
                                       void **free_info);
+/
herr_t H5Pset_hyper_vector_size(hid_t fapl_id, size_t size);
herr_t H5Pget_hyper_vector_size(hid_t fapl_id, size_t *size/*out*/);
herr_t H5Pset_type_conv_cb(hid_t dxpl_id, H5T_conv_except_func_t op, void* operate_data);
herr_t H5Pget_type_conv_cb(hid_t dxpl_id, H5T_conv_except_func_t *op, void** operate_data);
//#ifdef H5_HAVE_PARALLEL
herr_t H5Pget_mpio_actual_chunk_opt_mode(hid_t plist_id, H5D_mpio_actual_chunk_opt_mode_t *actual_chunk_opt_mode);
herr_t H5Pget_mpio_actual_io_mode(hid_t plist_id, H5D_mpio_actual_io_mode_t *actual_io_mode);
herr_t H5Pget_mpio_no_collective_cause(hid_t plist_id, uint32_t *local_no_collective_cause, uint32_t *global_no_collective_cause);
//#endif /* H5_HAVE_PARALLEL */

/* Link creation property list (LCPL) routines */
herr_t H5Pset_create_intermediate_group(hid_t plist_id, uint crt_intmd);
herr_t H5Pget_create_intermediate_group(hid_t plist_id, uint *crt_intmd /*out*/);

/* Group creation property list (GCPL) routines */
herr_t H5Pset_local_heap_size_hint(hid_t plist_id, size_t size_hint);
herr_t H5Pget_local_heap_size_hint(hid_t plist_id, size_t *size_hint /*out*/);
herr_t H5Pset_link_phase_change(hid_t plist_id, uint max_compact, uint min_dense);
herr_t H5Pget_link_phase_change(hid_t plist_id, uint *max_compact /*out*/, uint *min_dense /*out*/);
herr_t H5Pset_est_link_info(hid_t plist_id, uint est_num_entries, uint est_name_len);
herr_t H5Pget_est_link_info(hid_t plist_id, uint *est_num_entries /* out */, uint *est_name_len /* out */);
herr_t H5Pset_link_creation_order(hid_t plist_id, uint crt_order_flags);
herr_t H5Pget_link_creation_order(hid_t plist_id, uint *crt_order_flags /* out */);

/* String creation property list (STRCPL) routines */
herr_t H5Pset_char_encoding(hid_t plist_id, H5T_cset_t encoding);
herr_t H5Pget_char_encoding(hid_t plist_id, H5T_cset_t *encoding /*out*/);

/* Link access property list (LAPL) routines */
herr_t H5Pset_nlinks(hid_t plist_id, size_t nlinks);
herr_t H5Pget_nlinks(hid_t plist_id, size_t *nlinks);
herr_t H5Pset_elink_prefix(hid_t plist_id, const char *prefix);
ssize_t H5Pget_elink_prefix(hid_t plist_id, char *prefix, size_t size);
hid_t H5Pget_elink_fapl(hid_t lapl_id);
herr_t H5Pset_elink_fapl(hid_t lapl_id, hid_t fapl_id);
herr_t H5Pset_elink_acc_flags(hid_t lapl_id, uint flags);
herr_t H5Pget_elink_acc_flags(hid_t lapl_id, uint *flags);
/++
herr_t H5Pset_elink_cb(hid_t lapl_id, H5L_elink_traverse_t func, void *op_data);
herr_t H5Pget_elink_cb(hid_t lapl_id, H5L_elink_traverse_t *func, void **op_data);
+/

/* Object copy property list (OCPYPL) routines */
herr_t H5Pset_copy_object(hid_t plist_id, uint crt_intmd);
herr_t H5Pget_copy_object(hid_t plist_id, uint *crt_intmd /*out*/);
herr_t H5Padd_merge_committed_dtype_path(hid_t plist_id, const char *path);
herr_t H5Pfree_merge_committed_dtype_paths(hid_t plist_id);
/++
herr_t H5Pset_mcdt_search_cb(hid_t plist_id, H5O_mcdt_search_cb_t func, void *op_data);
herr_t H5Pget_mcdt_search_cb(hid_t plist_id, H5O_mcdt_search_cb_t *func, void **op_data);
+/

}

/++ DEPRECATED
/* Symbols defined for compatibility with previous versions of the HDF5 API.
 *
 * Use of these symbols is deprecated.
 */
#ifndef H5_NO_DEPRECATED_SYMBOLS

/* Macros */

/* We renamed the "root" of the property list class hierarchy */
#define H5P_NO_CLASS            H5P_ROOT


/* Typedefs */

/* Function prototypes */
herr_t H5Pregister1(hid_t cls_id, const char *name, size_t size,
    void *def_value, H5P_prp_create_func_t prp_create,
    H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get,
    H5P_prp_delete_func_t prp_del, H5P_prp_copy_func_t prp_copy,
    H5P_prp_close_func_t prp_close);
herr_t H5Pinsert1(hid_t plist_id, const char *name, size_t size,
    void *value, H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get,
    H5P_prp_delete_func_t prp_delete, H5P_prp_copy_func_t prp_copy,
    H5P_prp_close_func_t prp_close);
H5Z_filter_t H5Pget_filter1(hid_t plist_id, uint filter,
    int *flags/*out*/, size_t *cd_nelmts/*out*/,
    uint cd_values[]/*out*/, size_t namelen, char name[]);
herr_t H5Pget_filter_by_id1(hid_t plist_id, H5Z_filter_t id,
    int *flags/*out*/, size_t *cd_nelmts/*out*/,
    uint cd_values[]/*out*/, size_t namelen, char name[]/*out*/);

#endif /* H5_NO_DEPRECATED_SYMBOLS */
+/

