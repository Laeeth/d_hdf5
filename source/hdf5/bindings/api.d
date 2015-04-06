/**
  hdf5.bindings.api

  Low level C API declarations

  D Language bindings to the HDF5 Library.  (Paired with a set of high-level wrappers)
  https://github.com/Laeeth/d_hdf5
  No restriction on use beyond those applying from HDF5 and the original C API by Stefan Frijters
  However, if you use them, I would not mind knowing your application and suggestions for
  improvement if you feel like sharing.  laeeth@laeeth.com



  Copyright by The HDF Group.                                               *
  Copyright by the Board of Trustees of the University of Illinois.         *
  All rights reserved.                                                      *
                                                                            *
  This file is part of HDF5.  The full HDF5 copyright notice, including     *
  terms governing use, modification, and redistribution, is contained in    *
  the files COPYING and Copyright.html.  COPYING can be found at the root   *
  of the source code distribution tree; Copyright.html can be found at the  *
  root level of an installed copy of the electronic HDF5 document set and   *
  is linked from the top-level documents page.  It can also be found at     *
  http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          *
  access to either file, you may request a copy from help@hdfgroup.org.     *
  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Ported to D by Laeeth Isharc 2014
  Borrowed heavily in terms of C API declarations from https://github.com/SFrijters/hdf5-d
  Stefan Frijters bindings for D

  Bindings probably not yet complete or bug-free.

  Consider this not even alpha stage.  It probably isn't so far away from being useful though.
  This is written for Linux and will need modification to work on other platforms.
*/

module hdf5.bindings.api;
public import core.stdc.stdint;
public import core.sys.posix.sys.types: off_t;
public import core.stdc.time;
public import core.stdc.stdint;
import std.conv;
import std.string;
import std.array;
import std.stdio;
import hdf5.bindings.enums;

auto H5check() {
  return H5check_version(H5_VERS_MAJOR,H5_VERS_MINOR, H5_VERS_RELEASE);
}

/* macros for comparing the version */
bool H5_VERSION_GE(Maj,Min,Rel)() {
  return (((H5_VERS_MAJOR==Maj) && (H5_VERS_MINOR==Min) && (H5_VERS_RELEASE>=Rel)) ||
        ((H5_VERS_MAJOR==Maj) && (H5_VERS_MINOR>Min)) ||
          (H5_VERS_MAJOR>Maj));
}

bool H5_VERSION_LE(Maj,Min,Rel)() {
  return (((H5_VERS_MAJOR==Maj) && (H5_VERS_MINOR==Min) && (H5_VERS_RELEASE<=Rel)) ||
        ((H5_VERS_MAJOR==Maj) && (H5_VERS_MINOR<Min)) ||
          (H5_VERS_MAJOR<Maj));
}
version(Posix)
{
  extern(C)
  {
    herr_t H5open();
    herr_t H5close();
    herr_t H5dont_atexit();
    herr_t H5garbage_collect();
    herr_t H5set_free_list_limits (int reg_global_lim, int reg_list_lim,
                                   int arr_global_lim, int arr_list_lim, int blk_global_lim, int blk_list_lim);
    herr_t H5get_libversion(uint *majnum, uint *minnum, uint *relnum);
    herr_t H5check_version(uint majnum, uint minnum, uint relnum);
    herr_t H5free_memory(void *mem);
  }
}

    /* Define the operator function pointer for H5Diterate() */
extern(C)
{
    hid_t H5Dcreate2(hid_t loc_id, const (char*)name, hid_t type_id,
                     hid_t space_id, hid_t lcpl_id, hid_t dcpl_id, hid_t dapl_id);
    hid_t H5Dcreate_anon(hid_t file_id, hid_t type_id, hid_t space_id, hid_t plist_id, hid_t dapl_id);
    hid_t H5Dopen2(hid_t file_id, const (char*)name, hid_t dapl_id);
    herr_t H5Dclose(hid_t dset_id);
    hid_t H5Dget_space(hid_t dset_id);
    herr_t H5Dget_space_status(hid_t dset_id, H5DSpaceStatus *allocation);
    hid_t H5Dget_type(hid_t dset_id);
    hid_t H5Dget_create_plist(hid_t dset_id);
    hid_t H5Dget_access_plist(hid_t dset_id);
    hsize_t H5Dget_storage_size(hid_t dset_id);
    haddr_t H5Dget_offset(hid_t dset_id);
    herr_t H5Dread(hid_t dset_id, hid_t mem_type_id, hid_t mem_space_id, hid_t file_space_id, hid_t plist_id, void *buf/*out*/);
    herr_t H5Dwrite(hid_t dset_id, hid_t mem_type_id, hid_t mem_space_id, hid_t file_space_id, hid_t plist_id, const void *buf);
    herr_t H5Diterate(void *buf, hid_t type_id, hid_t space_id, H5D_operator_t op, void *operator_data);
    herr_t H5Dvlen_reclaim(hid_t type_id, hid_t space_id, hid_t plist_id, void *buf);
    herr_t H5Dvlen_get_buf_size(hid_t dataset_id, hid_t type_id, hid_t space_id, hsize_t *size);
    herr_t H5Dfill(const void *fill, hid_t fill_type, void *buf, hid_t buf_type, hid_t space);
    herr_t H5Dset_extent(hid_t dset_id, const hsize_t* size);
    herr_t H5Dscatter(H5D_scatter_func_t op, void *op_data, hid_t type_id, hid_t dst_space_id, void *dst_buf);
    herr_t H5Dgather(hid_t src_space_id, const void *src_buf, hid_t type_id, size_t dst_buf_size, void *dst_buf, H5D_gather_func_t op, void *op_data);
    herr_t H5Ddebug(hid_t dset_id);
}
  extern(C)
  {
    // Public function prototypes

    hid_t   H5Acreate2(hid_t loc_id, const (char*)attr_name, hid_t type_id, hid_t space_id, hid_t acpl_id, hid_t aapl_id);
    hid_t   H5Acreate_by_name(hid_t loc_id, const (char*)obj_name, const (char*)attr_name,
        hid_t type_id, hid_t space_id, hid_t acpl_id, hid_t aapl_id, hid_t lapl_id);
    hid_t   H5Aopen(hid_t obj_id, const (char*)attr_name, hid_t aapl_id);
    hid_t   H5Aopen_by_name(hid_t loc_id, const (char*)obj_name, const (char*)attr_name, hid_t aapl_id, hid_t lapl_id);
    hid_t   H5Aopen_by_idx(hid_t loc_id, const (char*)obj_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t aapl_id,
        hid_t lapl_id);
    herr_t  H5Awrite(hid_t attr_id, hid_t type_id, const void *buf);
    herr_t  H5Aread(hid_t attr_id, hid_t type_id, void *buf);
    herr_t  H5Aclose(hid_t attr_id);
    hid_t   H5Aget_space(hid_t attr_id);
    hid_t   H5Aget_type(hid_t attr_id);
    hid_t   H5Aget_create_plist(hid_t attr_id);
    ssize_t H5Aget_name(hid_t attr_id, size_t buf_size, char *buf);
    ssize_t H5Aget_name_by_idx(hid_t loc_id, const (char*)obj_name, H5Index idx_type, H5IterOrder order, hsize_t n,
        char *name /*out*/, size_t size, hid_t lapl_id);
    hsize_t H5Aget_storage_size(hid_t attr_id);
    herr_t  H5Aget_info(hid_t attr_id, H5A_info_t *ainfo /*out*/);
    herr_t  H5Aget_info_by_name(hid_t loc_id, const (char*)obj_name, const (char*)attr_name, H5A_info_t *ainfo /*out*/, hid_t lapl_id);
    herr_t  H5Aget_info_by_idx(hid_t loc_id, const (char*)obj_name, H5Index idx_type, H5IterOrder order, hsize_t n,
        H5A_info_t *ainfo /*out*/, hid_t lapl_id);
    herr_t  H5Arename(hid_t loc_id, const (char*)old_name, const (char*)new_name);
    herr_t  H5Arename_by_name(hid_t loc_id, const (char*)obj_name, const (char*)old_attr_name, const (char*)new_attr_name, hid_t lapl_id);
    herr_t  H5Aiterate2(hid_t loc_id, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5A_operator2_t op, void *op_data);
    herr_t  H5Aiterate_by_name(hid_t loc_id, const (char*)obj_name, H5Index idx_type, H5IterOrder order, hsize_t *idx,
         H5A_operator2_t op, void *op_data, hid_t lapd_id);
    herr_t  H5Adelete(hid_t loc_id, const (char*)name);
    herr_t  H5Adelete_by_name(hid_t loc_id, const (char*)obj_name, const (char*)attr_name, hid_t lapl_id);
    herr_t  H5Adelete_by_idx(hid_t loc_id, const (char*)obj_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id);
    htri_t H5Aexists(hid_t obj_id, const (char*)attr_name);
    htri_t H5Aexists_by_name(hid_t obj_id, const (char*)obj_name, const (char*)attr_name, hid_t lapl_id);
}

  /* Global var whose value comes from environment variable */
  /* (Defined in H5FDmpio.c) */
  extern __gshared hbool_t H5FD_mpi_opt_types_g;

extern(C)
{
    
    alias H5MM_allocate_t=void* function (c_ulong, void*) ;
    alias H5MM_free_t=void function (void*, void*);
    enum H5PL_type_t
    {
      H5PL_TYPE_ERROR = -1,
      H5PL_TYPE_FILTER = 0,
      H5PL_TYPE_NONE = 1
    }

    H5PL_type_t H5PLget_plugin_type ();
    const(void)* H5PLget_plugin_info ();
    alias H5F_mem_t=H5FD_mem_t;

    hid_t H5FD_mpio_init();
    void H5FD_mpio_term();
    hid_t H5FDregister (const(H5FD_class_t)* cls);
    herr_t H5FDunregister (hid_t driver_id);
    H5FD_t* H5FDopen (const(char)* name, uint flags, hid_t fapl_id, haddr_t maxaddr);
    herr_t H5FDclose (H5FD_t* file);
    int H5FDcmp (const(H5FD_t)* f1, const(H5FD_t)* f2);
    int H5FDquery (const(H5FD_t)* f, c_ulong* flags);
    haddr_t H5FDalloc (H5FD_t* file, H5FD_mem_t type, hid_t dxpl_id, hsize_t size);
    herr_t H5FDfree (H5FD_t* file, H5FD_mem_t type, hid_t dxpl_id, haddr_t addr, hsize_t size);
    haddr_t H5FDget_eoa (H5FD_t* file, H5FD_mem_t type);
    herr_t H5FDset_eoa (H5FD_t* file, H5FD_mem_t type, haddr_t eoa);
    haddr_t H5FDget_eof (H5FD_t* file);
    herr_t H5FDget_vfd_handle (H5FD_t* file, hid_t fapl, void** file_handle);
    herr_t H5FDread (H5FD_t* file, H5FD_mem_t type, hid_t dxpl_id, haddr_t addr, size_t size, void* buf);
    herr_t H5FDwrite (H5FD_t* file, H5FD_mem_t type, hid_t dxpl_id, haddr_t addr, size_t size, const(void)* buf);
    herr_t H5FDflush (H5FD_t* file, hid_t dxpl_id, uint closing);
    herr_t H5FDtruncate (H5FD_t* file, hid_t dxpl_id, hbool_t closing);

    herr_t H5Pset_fapl_mpio(hid_t fapl_id, MPI_Comm comm, MPI_Info info);
    herr_t H5Pget_fapl_mpio(hid_t fapl_id, MPI_Comm *comm/*out*/, MPI_Info *info/*out*/);
    herr_t H5Pset_dxpl_mpio(hid_t dxpl_id, H5FDMPIO xfer_mode);
    herr_t H5Pget_dxpl_mpio(hid_t dxpl_id, H5FDMPIO *xfer_mode/*out*/);
    herr_t H5Pset_dxpl_mpio_collective_opt(hid_t dxpl_id, H5FDMPIO opt_mode);
    herr_t H5Pset_dxpl_mpio_chunk_opt(hid_t dxpl_id, H5FDMPIOChunkOptions opt_mode);
    herr_t H5Pset_dxpl_mpio_chunk_opt_num(hid_t dxpl_id, uint num_chunk_per_proc);
    herr_t H5Pset_dxpl_mpio_chunk_opt_ratio(hid_t dxpl_id, uint percent_num_proc_per_chunk);

    
    hid_t H5Pcreate_class(hid_t parent, const (char*)name,
    H5P_cls_create_func_t cls_create, void *create_data,
    H5P_cls_copy_func_t cls_copy, void *copy_data,
    H5P_cls_close_func_t cls_close, void *close_data);
    char *H5Pget_class_name(hid_t pclass_id);
    hid_t H5Pcreate(hid_t cls_id);
    herr_t H5Pregister2(hid_t cls_id, const (char*)name, size_t size,
    void *def_value, H5P_prp_create_func_t prp_create,
    H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get,
    H5P_prp_delete_func_t prp_del, H5P_prp_copy_func_t prp_copy,
    H5P_prp_compare_func_t prp_cmp, H5P_prp_close_func_t prp_close);
    herr_t H5Pinsert2(hid_t plist_id, const (char*)name, size_t size,
    void *value, H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get,
    H5P_prp_delete_func_t prp_delete, H5P_prp_copy_func_t prp_copy,
    H5P_prp_compare_func_t prp_cmp, H5P_prp_close_func_t prp_close);
    herr_t H5Pset(hid_t plist_id, const (char*)name, void *value);
    htri_t H5Pexist(hid_t plist_id, const (char*)name);
    herr_t H5Pget_size(hid_t id, const (char*)name, size_t *size);
    herr_t H5Pget_nprops(hid_t id, size_t *nprops);
    hid_t H5Pget_class(hid_t plist_id);
    hid_t H5Pget_class_parent(hid_t pclass_id);
    herr_t H5Pget(hid_t plist_id, const (char*)name, void * value);
    htri_t H5Pequal(hid_t id1, hid_t id2);
    htri_t H5Pisa_class(hid_t plist_id, hid_t pclass_id);
    int H5Piterate(hid_t id, int *idx, H5P_iterate_t iter_func, void *iter_data);
    herr_t H5Pcopy_prop(hid_t dst_id, hid_t src_id, const (char*)name);
    herr_t H5Premove(hid_t plist_id, const (char*)name);
    herr_t H5Punregister(hid_t pclass_id, const (char*)name);
    herr_t H5Pclose_class(hid_t plist_id);
    herr_t H5Pclose(hid_t plist_id);
    hid_t H5Pcopy(hid_t plist_id);
    herr_t H5Pset_attr_phase_change(hid_t plist_id, uint max_compact, uint min_dense);
    herr_t H5Pget_attr_phase_change(hid_t plist_id, uint *max_compact, uint *min_dense);
    herr_t H5Pset_attr_creation_order(hid_t plist_id, uint crt_order_flags);
    herr_t H5Pget_attr_creation_order(hid_t plist_id, uint *crt_order_flags);
    herr_t H5Pset_obj_track_times(hid_t plist_id, hbool_t track_times);
    herr_t H5Pget_obj_track_times(hid_t plist_id, hbool_t *track_times);
    herr_t H5Pmodify_filter(hid_t plist_id, H5ZFilter filter, uint flags, size_t cd_nelmts, const uint* cd_values/*cd_nelmts*/);
    herr_t H5Pset_filter(hid_t plist_id, H5ZFilter filter, uint flags, size_t cd_nelmts, const uint* c_values);
    int H5Pget_nfilters(hid_t plist_id);
    H5ZFilter H5Pget_filter2(hid_t plist_id, uint filter, uint *flags/*out*/, size_t *cd_nelmts/*out*/, uint* cd_values/*out*/, 
          size_t namelen, char* name, uint *filter_config /*out*/);
    herr_t H5Pget_filter_by_id2(hid_t plist_id, H5ZFilter id, uint *flags/*out*/, size_t *cd_nelmts/*out*/, uint* cd_values/*out*/,
      size_t namelen, char* name/*out*/, uint *filter_config/*out*/);
    htri_t H5Pall_filters_avail(hid_t plist_id);
    herr_t H5Premove_filter(hid_t plist_id, H5ZFilter filter);
    herr_t H5Pset_deflate(hid_t plist_id, uint aggression);
    herr_t H5Pset_fletcher32(hid_t plist_id);
    herr_t H5Pget_version(hid_t plist_id, uint *boot/*out*/, uint *freelist/*out*/, uint *stab/*out*/, uint *shhdr/*out*/);
    herr_t H5Pset_userblock(hid_t plist_id, hsize_t size);
    herr_t H5Pget_userblock(hid_t plist_id, hsize_t *size);
    herr_t H5Pset_sizes(hid_t plist_id, size_t sizeof_addr, size_t sizeof_size);
    herr_t H5Pget_sizes(hid_t plist_id, size_t *sizeof_addr/*out*/, size_t *sizeof_size/*out*/);
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
    herr_t H5Pset_alignment(hid_t fapl_id, hsize_t threshold, hsize_t alignment);
    herr_t H5Pget_alignment(hid_t fapl_id, hsize_t *threshold/*out*/, hsize_t *alignment/*out*/);
    herr_t H5Pset_driver(hid_t plist_id, hid_t driver_id, const void *driver_info);
    hid_t H5Pget_driver(hid_t plist_id);
    void *H5Pget_driver_info(hid_t plist_id);
    herr_t H5Pset_family_offset(hid_t fapl_id, hsize_t offset);
    herr_t H5Pget_family_offset(hid_t fapl_id, hsize_t *offset);
    herr_t H5Pset_multi_type(hid_t fapl_id, H5FD_mem_t type);
    herr_t H5Pget_multi_type(hid_t fapl_id, H5FD_mem_t *type);
    herr_t H5Pset_cache(hid_t plist_id, int mdc_nelmts, size_t rdcc_nslots, size_t rdcc_nbytes, double rdcc_w0);
    herr_t H5Pget_cache(hid_t plist_id, int *mdc_nelmts, /* out */ size_t *rdcc_nslots/*out*/, size_t *rdcc_nbytes/*out*/, double *rdcc_w0);
    herr_t H5Pset_mdc_config(hid_t    plist_id, H5AC_cache_config_t * config_ptr);
    herr_t H5Pget_mdc_config(hid_t     plist_id, H5AC_cache_config_t * config_ptr);  /* out */
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
    herr_t H5Pset_file_image_callbacks(hid_t fapl_id, H5FD_file_image_callbacks_t *callbacks_ptr);
    herr_t H5Pget_file_image_callbacks(hid_t fapl_id, H5FD_file_image_callbacks_t *callbacks_ptr);

    herr_t H5Pset_core_write_tracking(hid_t fapl_id, hbool_t is_enabled, size_t page_size);
    herr_t H5Pget_core_write_tracking(hid_t fapl_id, hbool_t *is_enabled, size_t *page_size);
    herr_t H5Pset_layout(hid_t plist_id, H5DLayout layout);
    H5DLayout H5Pget_layout(hid_t plist_id);
    herr_t H5Pset_chunk(hid_t plist_id, int ndims, const hsize_t* dim/*ndims*/);
    int H5Pget_chunk(hid_t plist_id, int max_ndims, hsize_t* dim/*out*/);
    herr_t H5Pset_external(hid_t plist_id, const (char*)name, off_t offset,
              hsize_t size);
    int H5Pget_external_count(hid_t plist_id);
    herr_t H5Pget_external(hid_t plist_id, uint idx, size_t name_size,
              char *name/*out*/, off_t *offset/*out*/,
              hsize_t *size/*out*/);
    herr_t H5Pset_szip(hid_t plist_id, uint options_mask, uint pixels_per_block);
    herr_t H5Pset_shuffle(hid_t plist_id);
    herr_t H5Pset_nbit(hid_t plist_id);
    herr_t H5Pset_scaleoffset(hid_t plist_id, H5Z_SO_scale_type_t scale_type, int scale_factor);
    herr_t H5Pset_fill_value(hid_t plist_id, hid_t type_id, const void *value);
    herr_t H5Pget_fill_value(hid_t plist_id, hid_t type_id,
         void *value/*out*/);
    herr_t H5Pfill_value_defined(hid_t plist, H5D_fill_value_t *status);
    herr_t H5Pset_alloc_time(hid_t plist_id, H5DAllocTime
      alloc_time);
    herr_t H5Pget_alloc_time(hid_t plist_id, H5DAllocTime
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
    herr_t H5Pset_vlen_mem_manager(hid_t plist_id,
                                           H5MM_allocate_t alloc_func,
                                           void *alloc_info, H5MM_free_t free_func,
                                           void *free_info);
    herr_t H5Pget_vlen_mem_manager(hid_t plist_id,
                                           H5MM_allocate_t *alloc_func,
                                           void **alloc_info,
                                           H5MM_free_t *free_func,
                                           void **free_info);
    herr_t H5Pset_hyper_vector_size(hid_t fapl_id, size_t size);
    herr_t H5Pget_hyper_vector_size(hid_t fapl_id, size_t *size/*out*/);
    herr_t H5Pset_type_conv_cb(hid_t dxpl_id, H5T_conv_except_func_t op, void* operate_data);
    herr_t H5Pget_type_conv_cb(hid_t dxpl_id, H5T_conv_except_func_t *op, void** operate_data);
    herr_t H5Pget_mpio_actual_chunk_opt_mode(hid_t plist_id, H5D_mpio_actual_chunk_opt_mode_t *actual_chunk_opt_mode);
    herr_t H5Pget_mpio_actual_io_mode(hid_t plist_id, H5D_mpio_actual_io_mode_t *actual_io_mode);
    herr_t H5Pget_mpio_no_collective_cause(hid_t plist_id, uint32_t *local_no_collective_cause, uint32_t *global_no_collective_cause);
    herr_t H5Pset_create_intermediate_group(hid_t plist_id, uint crt_intmd);
    herr_t H5Pget_create_intermediate_group(hid_t plist_id, uint *crt_intmd /*out*/);
    herr_t H5Pset_local_heap_size_hint(hid_t plist_id, size_t size_hint);
    herr_t H5Pget_local_heap_size_hint(hid_t plist_id, size_t *size_hint /*out*/);
    herr_t H5Pset_link_phase_change(hid_t plist_id, uint max_compact, uint min_dense);
    herr_t H5Pget_link_phase_change(hid_t plist_id, uint *max_compact /*out*/, uint *min_dense /*out*/);
    herr_t H5Pset_est_link_info(hid_t plist_id, uint est_num_entries, uint est_name_len);
    herr_t H5Pget_est_link_info(hid_t plist_id, uint *est_num_entries /* out */, uint *est_name_len /* out */);
    herr_t H5Pset_link_creation_order(hid_t plist_id, uint crt_order_flags);
    herr_t H5Pget_link_creation_order(hid_t plist_id, uint *crt_order_flags /* out */);
    herr_t H5Pset_char_encoding(hid_t plist_id, H5TCset encoding);
    herr_t H5Pget_char_encoding(hid_t plist_id, H5TCset *encoding /*out*/);
    herr_t H5Pset_nlinks(hid_t plist_id, size_t nlinks);
    herr_t H5Pget_nlinks(hid_t plist_id, size_t *nlinks);
    herr_t H5Pset_elink_prefix(hid_t plist_id, const (char*)prefix);
    ssize_t H5Pget_elink_prefix(hid_t plist_id, char *prefix, size_t size);
    hid_t H5Pget_elink_fapl(hid_t lapl_id);
    herr_t H5Pset_elink_fapl(hid_t lapl_id, hid_t fapl_id);
    herr_t H5Pset_elink_acc_flags(hid_t lapl_id, uint flags);
    herr_t H5Pget_elink_acc_flags(hid_t lapl_id, uint *flags);
    herr_t H5Pset_elink_cb(hid_t lapl_id, H5L_elink_traverse_t func, void *op_data);
    herr_t H5Pget_elink_cb(hid_t lapl_id, H5L_elink_traverse_t *func, void **op_data);
    herr_t H5Pset_copy_object(hid_t plist_id, uint crt_intmd);
    herr_t H5Pget_copy_object(hid_t plist_id, uint *crt_intmd /*out*/);
    herr_t H5Padd_merge_committed_dtype_path(hid_t plist_id, const (char*)path);
    herr_t H5Pfree_merge_committed_dtype_paths(hid_t plist_id);
    herr_t H5Pset_mcdt_search_cb(hid_t plist_id, H5O_mcdt_search_cb_t func, void *op_data);
    herr_t H5Pget_mcdt_search_cb(hid_t plist_id, H5O_mcdt_search_cb_t *func, void **op_data);
    alias H5P_NO_CLASS = H5P_ROOT; // We renamed the "root" of the property list class hierarchy


    herr_t H5Pregister1(hid_t cls_id, const (char*)name, size_t size, void *def_value, H5P_prp_create_func_t prp_create,
        H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get, H5P_prp_delete_func_t prp_del, H5P_prp_copy_func_t prp_copy, H5P_prp_close_func_t prp_close);
    herr_t H5Pinsert1(hid_t plist_id, const (char*)name, size_t size, void *value, H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get,
        H5P_prp_delete_func_t prp_delete, H5P_prp_copy_func_t prp_copy, H5P_prp_close_func_t prp_close);
    H5ZFilter H5Pget_filter1(hid_t plist_id, uint filter, uint *flags/*out*/, size_t *cd_nelmts/*out*/,
        uint* cd_values/*out*/, size_t namelen, char* name);
    herr_t H5Pget_filter_by_id1(hid_t plist_id, H5ZFilter id,
        uint *flags/*out*/, size_t *cd_nelmts/*out*/, uint* cd_values/*out*/, size_t namelen, char* name/*out*/);
}



  extern(C)
  {
    htri_t H5Fis_hdf5(const (char*)filename);
    hid_t  H5Fcreate(const (char*)filename, uint flags, hid_t create_plist, hid_t access_plist);
    hid_t  H5Fopen(const (char*)filename, uint flags, hid_t access_plist);
    hid_t  H5Freopen(hid_t file_id);
    herr_t H5Fflush(hid_t object_id, H5F_scope_t _scope);
    herr_t H5Fclose(hid_t file_id);
    hid_t  H5Fget_create_plist(hid_t file_id);
    hid_t  H5Fget_access_plist(hid_t file_id);
    herr_t H5Fget_intent(hid_t file_id, uint * intent);
    ssize_t H5Fget_obj_count(hid_t file_id, uint types);
    ssize_t H5Fget_obj_ids(hid_t file_id, uint types, size_t max_objs, hid_t *obj_id_list);
    herr_t H5Fget_vfd_handle(hid_t file_id, hid_t fapl, void **file_handle);
    herr_t H5Fmount(hid_t loc, const (char*)name, hid_t child, hid_t plist);
    herr_t H5Funmount(hid_t loc, const (char*)name);
    hssize_t H5Fget_freespace(hid_t file_id);
    herr_t H5Fget_filesize(hid_t file_id, hsize_t *size);
    ssize_t H5Fget_file_image(hid_t file_id, void * buf_ptr, size_t buf_len);
    herr_t H5Fget_mdc_config(hid_t file_id, H5AC_cache_config_t * config_ptr);
    herr_t H5Fset_mdc_config(hid_t file_id, H5AC_cache_config_t * config_ptr);

    herr_t H5Fget_mdc_hit_rate(hid_t file_id, double * hit_rate_ptr);
    herr_t H5Fget_mdc_size(hid_t file_id, size_t * max_size_ptr, size_t * min_clean_size_ptr, size_t * cur_size_ptr, int * cur_num_entries_ptr);
    herr_t H5Freset_mdc_hit_rate_stats(hid_t file_id);
    ssize_t H5Fget_name(hid_t obj_id, char *name, size_t size);
    herr_t H5Fget_info(hid_t obj_id, H5F_info_t *bh_info);
    herr_t H5Fclear_elink_file_cache(hid_t file_id);
    version(h5parallel) herr_t H5Fset_mpi_atomicity(hid_t file_id, hbool_t flag);
    version(h5parallel) herr_t H5Fget_mpi_atomicity(hid_t file_id, hbool_t *flag);
    version(h5parallel) alias H5FD_MPIO=H5FD_mpio_init;
}
extern(C)
{
  alias H5GLinkType=H5LType;
  alias H5GIterateType=herr_t function(hid_t group, const char *name, void *op_data);

  hid_t H5Gcreate2(hid_t loc_id, const (char*)name, hid_t lcpl_id, hid_t gcpl_id, hid_t gapl_id);
  hid_t H5Gcreate_anon(hid_t loc_id, hid_t gcpl_id, hid_t gapl_id);
  hid_t H5Gopen2(hid_t loc_id, const (char*)name, hid_t gapl_id);
  hid_t H5Gget_create_plist(hid_t group_id);
  herr_t H5Gget_info(hid_t loc_id, H5GInfo *ginfo);
  herr_t H5Gget_info_by_name(hid_t loc_id, const(char *)name, H5GInfo *ginfo, hid_t lapl_id);
  herr_t H5Gget_info_by_idx(hid_t loc_id, const(char *)group_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5GInfo *ginfo, hid_t lapl_id);
  herr_t H5Gclose(hid_t group_id);

  hid_t H5Gcreate1(hid_t loc_id, const(char*) name, size_t size_hint);
  hid_t H5Gopen1(hid_t loc_id, const(char*) name);
  herr_t H5Glink(hid_t cur_loc_id, H5GLinkType type, const(char*) cur_name, const(char*) new_name);
  herr_t H5Glink2(hid_t cur_loc_id, const(char*) cur_name, H5GLinkType type, hid_t new_loc_id, const(char*) new_name);
  herr_t H5Gmove(hid_t src_loc_id, const(char*) src_name, const(char*) dst_name);
  herr_t H5Gmove2(hid_t src_loc_id, const(char*) src_name, hid_t dst_loc_id, const(char*) dst_name);
  herr_t H5Gunlink(hid_t loc_id, const(char*) name);
  herr_t H5Gget_linkval(hid_t loc_id, const(char*) name, size_t size, char *buf/*out*/);
  herr_t H5Gset_comment(hid_t loc_id, const(char*) name, const(char*) comment);
  int H5Gget_comment(hid_t loc_id, const(char*) name, size_t bufsize, char *buf);
  herr_t H5Giterate(hid_t loc_id, const(char*) name, int *idx, H5GIterateType op, void *op_data);
  herr_t H5Gget_num_objs(hid_t loc_id, hsize_t *num_objs);
  herr_t H5Gget_objinfo(hid_t loc_id, const(char*) name, hbool_t follow_link, H5GStatType *statbuf/*out*/);
  ssize_t H5Gget_objname_by_idx(hid_t loc_id, hsize_t idx, char* name, size_t size);
  H5GObjectType H5Gget_objtype_by_idx(hid_t loc_id, hsize_t idx);
}

  extern(C)
  {
    hid_t H5Iregister(H5IType type, const void *object);
    void *H5Iobject_verify(hid_t id, H5IType id_type);
    void *H5Iremove_verify(hid_t id, H5IType id_type);
    H5IType H5Iget_type(hid_t id);
    hid_t H5Iget_file_id(hid_t id);
    ssize_t H5Iget_name(hid_t id, char *name/*out*/, size_t size);
    int H5Iinc_ref(hid_t id);
    int H5Idec_ref(hid_t id);
    int H5Iget_ref(hid_t id);
    H5IType H5Iregister_type(size_t hash_size, uint reserved, H5I_free_t free_func);
    herr_t H5Iclear_type(H5IType type, hbool_t force);
    herr_t H5Idestroy_type(H5IType type);
    int H5Iinc_type_ref(H5IType type);
    int H5Idec_type_ref(H5IType type);
    int H5Iget_type_ref(H5IType type);
    void *H5Isearch(H5IType type, H5I_search_func_t func, void *key);
    herr_t H5Inmembers(H5IType type, hsize_t *num_members);
    htri_t H5Itype_exists(H5IType type);
    htri_t H5Iis_valid(hid_t id);
  }
  extern(C)
  {
    herr_t H5Lmove(hid_t src_loc, const (char*)src_name, hid_t dst_loc, const (char*)dst_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Lcopy(hid_t src_loc, const (char*)src_name, hid_t dst_loc, const (char*)dst_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Lcreate_hard(hid_t cur_loc, const (char*)cur_name, hid_t dst_loc, const (char*)dst_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Lcreate_soft(const (char*)link_target, hid_t link_loc_id, const (char*)link_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Ldelete(hid_t loc_id, const (char*)name, hid_t lapl_id);
    herr_t H5Ldelete_by_idx(hid_t loc_id, const (char*)group_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id);
    herr_t H5Lget_val(hid_t loc_id, const (char*)name, void *buf/*out*/, size_t size, hid_t lapl_id);
    herr_t H5Lget_val_by_idx(hid_t loc_id, const (char*)group_name, H5Index idx_type, H5IterOrder order, hsize_t n, void *buf/*out*/, size_t size, hid_t lapl_id);
    htri_t H5Lexists(hid_t loc_id, const (char*)name, hid_t lapl_id);
    herr_t H5Lget_info(hid_t loc_id, const (char*)name, H5LInfo *linfo /*out*/, hid_t lapl_id);
    herr_t H5Lget_info_by_idx(hid_t loc_id, const (char*)group_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5LInfo *linfo /*out*/, hid_t lapl_id); ssize_t H5Lget_name_by_idx(hid_t loc_id, const (char*)group_name, H5Index idx_type, H5IterOrder order, hsize_t n, char *name /*out*/, size_t size, hid_t lapl_id);
    herr_t H5Literate(hid_t grp_id, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5L_iterate_t op, void *op_data);
    herr_t H5Literate_by_name(hid_t loc_id, const (char*)group_name, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5L_iterate_t op, void *op_data, hid_t lapl_id);
    herr_t H5Lvisit(hid_t grp_id, H5Index idx_type, H5IterOrder order, H5L_iterate_t op, void *op_data);
    herr_t H5Lvisit_by_name(hid_t loc_id, const (char*)group_name, H5Index idx_type, H5IterOrder order, H5L_iterate_t op, void *op_data, hid_t lapl_id);

    /* UD link functions */
    herr_t H5Lcreate_ud(hid_t link_loc_id, const (char*)link_name, H5LType link_type, const void *udata, size_t udata_size, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Lregister(const H5L_class_t *cls);
    herr_t H5Lunregister(H5LType id);
    htri_t H5Lis_registered(H5LType id);

    /* External link functions */
    herr_t H5Lunpack_elink_val(const void *ext_linkval/*in*/, size_t link_size, uint *flags, const (char*)*filename/*out*/, const (char*)*obj_path /*out*/);
    herr_t H5Lcreate_external(const (char*)file_name, const (char*)obj_name, hid_t link_loc_id, const (char*)link_name, hid_t lcpl_id, hid_t lapl_id);
  }


extern(C)
{
    hid_t H5Oopen(hid_t loc_id, const (char*)name, hid_t lapl_id);
    hid_t H5Oopen_by_addr(hid_t loc_id, haddr_t addr);
    hid_t H5Oopen_by_idx(hid_t loc_id, const (char*)group_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id);
    htri_t H5Oexists_by_name(hid_t loc_id, const (char*)name, hid_t lapl_id);
    herr_t H5Oget_info(hid_t loc_id, H5OInfo  *oinfo);
    herr_t H5Oget_info_by_name(hid_t loc_id, const (char *)name, H5OInfo  *oinfo, hid_t lapl_id);
    herr_t H5Oget_info_by_idx(hid_t loc_id, const (char*)group_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5OInfo  *oinfo, hid_t lapl_id);
    herr_t H5Olink(hid_t obj_id, hid_t new_loc_id, const (char*)new_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Oincr_refcount(hid_t object_id);
    herr_t H5Odecr_refcount(hid_t object_id);
    herr_t H5Ocopy(hid_t src_loc_id, const (char*)src_name, hid_t dst_loc_id, const (char*)dst_name, hid_t ocpypl_id, hid_t lcpl_id);
    herr_t H5Oset_comment(hid_t obj_id, const (char*)comment);
    herr_t H5Oset_comment_by_name(hid_t loc_id, const (char*)name, const (char*)comment, hid_t lapl_id);
    ssize_t H5Oget_comment(hid_t obj_id, char *comment, size_t bufsize);
    ssize_t H5Oget_comment_by_name(hid_t loc_id, const (char*)name, char *comment, size_t bufsize, hid_t lapl_id);
    herr_t H5Ovisit(hid_t obj_id, H5Index idx_type, H5IterOrder order, H5O_iterate_t op, void *op_data);
    herr_t H5Ovisit_by_name(hid_t loc_id, const (char*)obj_name, H5Index idx_type, H5IterOrder order, H5O_iterate_t op, void *op_data, hid_t lapl_id);
    herr_t H5Oclose(hid_t object_id);
    
alias H5P_ROOT=H5P_CLS_ROOT_ID_g;
alias H5P_OBJECT_CREATE=H5P_CLS_OBJECT_CREATE_ID_g;
alias H5P_DATASET_CREATE=H5P_CLS_DATASET_CREATE_ID_g;
alias H5P_FILE_CREATE             = H5P_CLS_FILE_CREATE_ID_g;
alias H5P_FILE_ACCESS             = H5P_CLS_FILE_ACCESS_ID_g;

alias H5P_DATASET_ACCESS          = H5P_CLS_DATASET_ACCESS_ID_g;
alias H5P_DATASET_XFER            = H5P_CLS_DATASET_XFER_ID_g;
alias H5P_FILE_MOUNT              = H5P_CLS_FILE_MOUNT_ID_g;
alias H5P_GROUP_CREATE            = H5P_CLS_GROUP_CREATE_ID_g;
alias H5P_GROUP_ACCESS            = H5P_CLS_GROUP_ACCESS_ID_g;
alias H5P_DATATYPE_CREATE         = H5P_CLS_DATATYPE_CREATE_ID_g;
alias H5P_DATATYPE_ACCESS         = H5P_CLS_DATATYPE_ACCESS_ID_g;
alias H5P_STRING_CREATE           = H5P_CLS_STRING_CREATE_ID_g;
alias H5P_ATTRIBUTE_CREATE        = H5P_CLS_ATTRIBUTE_CREATE_ID_g;
alias H5P_OBJECT_COPY             = H5P_CLS_OBJECT_COPY_ID_g;
alias H5P_LINK_CREATE             = H5P_CLS_LINK_CREATE_ID_g;
alias H5P_LINK_ACCESS             = H5P_CLS_LINK_ACCESS_ID_g;


alias H5P_FILE_CREATE_DEFAULT     = H5P_LST_FILE_CREATE_ID_g;
alias H5P_FILE_ACCESS_DEFAULT     = H5P_LST_FILE_ACCESS_ID_g;
alias H5P_DATASET_CREATE_DEFAULT  = H5P_LST_DATASET_CREATE_ID_g;
alias H5P_DATASET_ACCESS_DEFAULT  = H5P_LST_DATASET_ACCESS_ID_g;
alias H5P_DATASET_XFER_DEFAULT    = H5P_LST_DATASET_XFER_ID_g;
alias H5P_FILE_MOUNT_DEFAULT      = H5P_LST_FILE_MOUNT_ID_g;
alias H5P_GROUP_CREATE_DEFAULT    = H5P_LST_GROUP_CREATE_ID_g;
alias H5P_GROUP_ACCESS_DEFAULT    = H5P_LST_GROUP_ACCESS_ID_g;
alias H5P_DATATYPE_CREATE_DEFAULT = H5P_LST_DATATYPE_CREATE_ID_g;
alias H5P_DATATYPE_ACCESS_DEFAULT = H5P_LST_DATATYPE_ACCESS_ID_g;
alias H5P_ATTRIBUTE_CREATE_DEFAULT= H5P_LST_ATTRIBUTE_CREATE_ID_g;
alias H5P_OBJECT_COPY_DEFAULT     = H5P_LST_OBJECT_COPY_ID_g;
alias H5P_LINK_CREATE_DEFAULT     = H5P_LST_LINK_CREATE_ID_g;
alias H5P_LINK_ACCESS_DEFAULT     = H5P_LST_LINK_ACCESS_ID_g;



struct H5P_genplist_t {};
struct H5P_genclass_t {};

     /* Default roperty list IDs */
    /* (Internal to library, do not use!  Use macros above) */
    extern __gshared hid_t H5P_LST_FILE_CREATE_ID_g   ;
    extern __gshared hid_t H5P_LST_FILE_ACCESS_ID_g   ;
    extern __gshared hid_t H5P_LST_DATASET_CREATE_ID_g;
    extern __gshared hid_t H5P_LST_DATASET_ACCESS_ID_g;
    extern __gshared hid_t H5P_LST_DATASET_XFER_ID_g  ;
    extern __gshared hid_t H5P_LST_FILE_MOUNT_ID_g    ;
    extern __gshared hid_t H5P_LST_GROUP_CREATE_ID_g  ;
    extern __gshared hid_t H5P_LST_GROUP_ACCESS_ID_g  ;
    extern __gshared hid_t H5P_LST_DATATYPE_CREATE_ID_g ;
    extern __gshared hid_t H5P_LST_DATATYPE_ACCESS_ID_g ;
    extern __gshared hid_t H5P_LST_ATTRIBUTE_CREATE_ID_g;
    extern __gshared hid_t H5P_LST_OBJECT_COPY_ID_g   ;
    extern __gshared hid_t H5P_LST_LINK_CREATE_ID_g   ;
    extern __gshared hid_t H5P_LST_LINK_ACCESS_ID_g   ;

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

    extern __gshared hid_t H5P_CLS_ROOT_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_ROOT_g;
    extern __gshared hid_t H5P_CLS_OBJECT_CREATE_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_OBJECT_CREATE_g;
    extern __gshared hid_t H5P_CLS_FILE_CREATE_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_FILE_CREATE_g;
    extern __gshared hid_t H5P_CLS_FILE_ACCESS_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_FILE_ACCESS_g;
    extern __gshared hid_t H5P_CLS_DATASET_CREATE_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_DATASET_CREATE_g;
    extern __gshared hid_t H5P_CLS_DATASET_ACCESS_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_DATASET_ACCESS_g;
    extern __gshared hid_t H5P_CLS_DATASET_XFER_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_DATASET_XFER_g;
    extern __gshared hid_t H5P_CLS_FILE_MOUNT_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_FILE_MOUNT_g;
    extern __gshared hid_t H5P_CLS_GROUP_CREATE_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_GROUP_CREATE_g;
    extern __gshared hid_t H5P_CLS_GROUP_ACCESS_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_GROUP_ACCESS_g;
    extern __gshared hid_t H5P_CLS_DATATYPE_CREATE_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_DATATYPE_CREATE_g;
    extern __gshared hid_t H5P_CLS_DATATYPE_ACCESS_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_DATATYPE_ACCESS_g;
    extern __gshared hid_t H5P_CLS_ATTRIBUTE_CREATE_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_ATTRIBUTE_CREATE_g;
    extern __gshared hid_t H5P_CLS_OBJECT_COPY_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_OBJECT_COPY_g;
    extern __gshared hid_t H5P_CLS_LINK_CREATE_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_LINK_CREATE_g;
    extern __gshared hid_t H5P_CLS_LINK_ACCESS_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_LINK_ACCESS_g;
    extern __gshared hid_t H5P_CLS_STRING_CREATE_ID_g;
    extern __gshared H5P_genclass_t *H5P_CLS_STRING_CREATE_g;

    /+
    /* Generic property list routines */
    hid_t H5Pcreate_class(hid_t parent, const (char*)name, H5P_cls_create_func_t cls_create, void *create_data,
        H5P_cls_copy_func_t cls_copy, void *copy_data, H5P_cls_close_func_t cls_close, void *close_data);
    char *H5Pget_class_name(hid_t pclass_id);
    hid_t H5Pcreate(hid_t cls_id);
    herr_t H5Pregister2(hid_t cls_id, const (char*)name, size_t size, void *def_value, H5P_prp_create_func_t prp_create,
        H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get, H5P_prp_delete_func_t prp_del, H5P_prp_copy_func_t prp_copy,
        H5P_prp_compare_func_t prp_cmp, H5P_prp_close_func_t prp_close);
    herr_t H5Pinsert2(hid_t plist_id, const (char*)name, size_t size,
        void *value, H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get,
        H5P_prp_delete_func_t prp_delete, H5P_prp_copy_func_t prp_copy,
        H5P_prp_compare_func_t prp_cmp, H5P_prp_close_func_t prp_close);
    herr_t H5Pset(hid_t plist_id, const (char*)name, void *value);
    htri_t H5Pexist(hid_t plist_id, const (char*)name);
    herr_t H5Pget_size(hid_t id, const (char*)name, size_t *size);
    herr_t H5Pget_nprops(hid_t id, size_t *nprops);
    hid_t H5Pget_class(hid_t plist_id);
    hid_t H5Pget_class_parent(hid_t pclass_id);
    herr_t H5Pget(hid_t plist_id, const (char*)name, void * value);
    htri_t H5Pequal(hid_t id1, hid_t id2);
    htri_t H5Pisa_class(hid_t plist_id, hid_t pclass_id);
    int H5Piterate(hid_t id, int *idx, H5P_iterate_t iter_func,
                void *iter_data);
    herr_t H5Pcopy_prop(hid_t dst_id, hid_t src_id, const (char*)name);
    herr_t H5Premove(hid_t plist_id, const (char*)name);
    herr_t H5Punregister(hid_t pclass_id, const (char*)name);
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
    herr_t H5Pmodify_filter(hid_t plist_id, H5ZFilter filter,
            int flags, size_t cd_nelmts,
            const int* cd_values);
    herr_t H5Pset_filter(hid_t plist_id, H5ZFilter filter, int flags, size_t cd_nelmts, const int* c_values);
    int H5Pget_nfilters(hid_t plist_id);
    H5ZFilter H5Pget_filter2(hid_t plist_id, uint filter,
           int *flags/*out*/,
           size_t *cd_nelmts/*out*/,
           uint* cd_values/*out*/,
           size_t namelen, char* name,
           uint *filter_config /*out*/);
    herr_t H5Pget_filter_by_id2(hid_t plist_id, H5ZFilter id,
           uint *flags/*out*/, size_t *cd_nelmts/*out*/,
           int* cd_values/*out*/, size_t namelen, char* name/*out*/,
           int *filter_config/*out*/);
    htri_t H5Pall_filters_avail(hid_t plist_id);
    herr_t H5Premove_filter(hid_t plist_id, H5ZFilter filter);
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
    herr_t H5Pset_cache(hid_t plist_id, int mdc_nelmts,
           size_t rdcc_nslots, size_t rdcc_nbytes,
           double rdcc_w0);
    herr_t H5Pget_cache(hid_t plist_id,
           int *mdc_nelmts, /* out */
           size_t *rdcc_nslots/*out*/,
           size_t *rdcc_nbytes/*out*/, double *rdcc_w0);
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
    version(h5parallel) herr_t H5Pset_core_write_tracking(hid_t fapl_id, hbool_t is_enabled, size_t page_size);
    version(h5parallel) herr_t H5Pget_core_write_tracking(hid_t fapl_id, hbool_t *is_enabled, size_t *page_size);
    herr_t H5Pset_layout(hid_t plist_id, H5DLayout layout);
    H5DLayout H5Pget_layout(hid_t plist_id);
    herr_t H5Pset_chunk(hid_t plist_id, int ndims, const hsize_t *dim/*ndims*/);
    int H5Pget_chunk(hid_t plist_id, int max_ndims, hsize_t *dim/*out*/);
    herr_t H5Pset_external(hid_t plist_id, const (char*)name, off_t offset,
              hsize_t size);
    int H5Pget_external_count(hid_t plist_id);
    herr_t H5Pget_external(hid_t plist_id, uint idx, size_t name_size,
              char *name/*out*/, off_t *offset/*out*/,
              hsize_t *size/*out*/);
    herr_t H5Pset_szip(hid_t plist_id, uint options_mask, uint pixels_per_block);
    herr_t H5Pset_shuffle(hid_t plist_id);
    herr_t H5Pset_nbit(hid_t plist_id);
    herr_t H5Pset_scaleoffset(hid_t plist_id, H5Z_SO_scale_type_t scale_type, int scale_factor);
    herr_t H5Pset_fill_value(hid_t plist_id, hid_t type_id, const void *value);
    herr_t H5Pget_fill_value(hid_t plist_id, hid_t type_id, void *value/*out*/);
    herr_t H5Pfill_value_defined(hid_t plist, H5D_fill_value_t *status);
    herr_t H5Pset_alloc_time(hid_t plist_id, H5DAllocTime alloc_time);
    herr_t H5Pget_alloc_time(hid_t plist_id, H5DAllocTime *alloc_time/*out*/);
    herr_t H5Pset_fill_time(hid_t plist_id, H5D_fill_time_t fill_time);
    herr_t H5Pget_fill_time(hid_t plist_id, H5D_fill_time_t *fill_time/*out*/);

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
    herr_t H5Pset_hyper_vector_size(hid_t fapl_id, size_t size);
    herr_t H5Pget_hyper_vector_size(hid_t fapl_id, size_t *size/*out*/);
    herr_t H5Pset_type_conv_cb(hid_t dxpl_id, H5T_conv_except_func_t op, void* operate_data);
    herr_t H5Pget_type_conv_cb(hid_t dxpl_id, H5T_conv_except_func_t *op, void** operate_data);
    version(h5parallel)
    {
      herr_t H5Pget_mpio_actual_chunk_opt_mode(hid_t plist_id, H5D_mpio_actual_chunk_opt_mode_t *actual_chunk_opt_mode);
      herr_t H5Pget_mpio_actual_io_mode(hid_t plist_id, H5D_mpio_actual_io_mode_t *actual_io_mode);
      herr_t H5Pget_mpio_no_collective_cause(hid_t plist_id, uint32_t *local_no_collective_cause, uint32_t *global_no_collective_cause);
    }

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
    herr_t H5Pset_char_encoding(hid_t plist_id, H5TCset encoding);
    herr_t H5Pget_char_encoding(hid_t plist_id, H5TCset *encoding /*out*/);

    /* Link access property list (LAPL) routines */
    herr_t H5Pset_nlinks(hid_t plist_id, size_t nlinks);
    herr_t H5Pget_nlinks(hid_t plist_id, size_t *nlinks);
    herr_t H5Pset_elink_prefix(hid_t plist_id, const (char*)prefix);
    ssize_t H5Pget_elink_prefix(hid_t plist_id, char *prefix, size_t size);
    hid_t H5Pget_elink_fapl(hid_t lapl_id);
    herr_t H5Pset_elink_fapl(hid_t lapl_id, hid_t fapl_id);
    herr_t H5Pset_elink_acc_flags(hid_t lapl_id, uint flags);
    herr_t H5Pget_elink_acc_flags(hid_t lapl_id, uint *flags);
    /*
    herr_t H5Pset_elink_cb(hid_t lapl_id, H5L_elink_traverse_t func, void *op_data);
    herr_t H5Pget_elink_cb(hid_t lapl_id, H5L_elink_traverse_t *func, void **op_data);
    */

    /* Object copy property list (OCPYPL) routines */
    herr_t H5Pset_copy_object(hid_t plist_id, uint crt_intmd);
    herr_t H5Pget_copy_object(hid_t plist_id, uint *crt_intmd /*out*/);
    herr_t H5Padd_merge_committed_dtype_path(hid_t plist_id, const (char*)path);
    herr_t H5Pfree_merge_committed_dtype_paths(hid_t plist_id);
    /*
    herr_t H5Pset_mcdt_search_cb(hid_t plist_id, H5O_mcdt_search_cb_t func, void *op_data);
    herr_t H5Pget_mcdt_search_cb(hid_t plist_id, H5O_mcdt_search_cb_t *func, void **op_data);
    */
dupes
+/
   herr_t H5Rcreate(void *_ref, hid_t loc_id, const (char*)name, H5RType reftype, hid_t space_id);
   hid_t H5Rdereference(hid_t dataset, H5RType ref_type, const void *_ref);
   hid_t H5Rget_region(hid_t dataset, H5RType ref_type, const void *_ref);
   herr_t H5Rget_obj_type2(hid_t id, H5RType ref_type, const void *_ref, H5OType *obj_type);
   ssize_t H5Rget_name(hid_t loc_id, H5RType ref_type, const void *_ref, char *name/*out*/, size_t size);
    hid_t H5Screate(H5SClass type);
    hid_t H5Screate_simple(int rank, const hsize_t *dims, const hsize_t *maxdims);
    herr_t H5Sset_extent_simple(hid_t space_id, int rank, const hsize_t *dims, const hsize_t *max);
    hid_t H5Scopy(hid_t space_id);
    herr_t H5Sclose(hid_t space_id);
    herr_t H5Sencode(hid_t obj_id, void *buf, size_t *nalloc);
    hid_t H5Sdecode(const void *buf);
    hssize_t H5Sget_simple_extent_npoints(hid_t space_id);
    int H5Sget_simple_extent_ndims(hid_t space_id);
    int H5Sget_simple_extent_dims(hid_t space_id, hsize_t *dims,
                                  hsize_t *maxdims);
    htri_t H5Sis_simple(hid_t space_id);
    hssize_t H5Sget_select_npoints(hid_t spaceid);
    herr_t H5Sselect_hyperslab(hid_t space_id, H5SSeloper op,
                               const hsize_t *start,
                               const hsize_t *_stride,
                               const hsize_t *count,
                               const hsize_t *_block);
    hid_t H5Scombine_hyperslab(hid_t space_id, H5SSeloper op,
                               const hsize_t *start,
                               const hsize_t *_stride,
                               const hsize_t *count,
                               const hsize_t *_block);
    herr_t H5Sselect_select(hid_t space1_id, H5SSeloper op,
                            hid_t space2_id);
    hid_t H5Scombine_select(hid_t space1_id, H5SSeloper op,
                            hid_t space2_id);
    herr_t H5Sselect_elements(hid_t space_id, H5SSeloper op,
                              size_t num_elem, const hsize_t *coord);
    H5SClass H5Sget_simple_extent_type(hid_t space_id);
    herr_t H5Sset_extent_none(hid_t space_id);
    herr_t H5Sextent_copy(hid_t dst_id,hid_t src_id);
    htri_t H5Sextent_equal(hid_t sid1, hid_t sid2);
    herr_t H5Sselect_all(hid_t spaceid);
    herr_t H5Sselect_none(hid_t spaceid);
    herr_t H5Soffset_simple(hid_t space_id, const hssize_t *offset);
    htri_t H5Sselect_valid(hid_t spaceid);
    hssize_t H5Sget_select_hyper_nblocks(hid_t spaceid);
    hssize_t H5Sget_select_elem_npoints(hid_t spaceid);
    herr_t H5Sget_select_hyper_blocklist(hid_t spaceid, hsize_t startblock,
                                         hsize_t numblocks, hsize_t *buf);
    herr_t H5Sget_select_elem_pointlist(hid_t spaceid, hsize_t startpoint,
                                        hsize_t numpoints, hsize_t *buf);
    herr_t H5Sget_select_bounds(hid_t spaceid, hsize_t *start,
                                hsize_t *end);
    H5S_sel_type H5Sget_select_type(hid_t spaceid);


    /* Operations defined on all datatypes */
    hid_t H5Tcreate(H5TClass type, size_t size);
    hid_t H5Tcopy(hid_t type_id);
    herr_t H5Tclose(hid_t type_id);
    htri_t H5Tequal(hid_t type1_id, hid_t type2_id);
    herr_t H5Tlock(hid_t type_id);
    herr_t H5Tcommit2(hid_t loc_id, const (char*)name, hid_t type_id,
        hid_t lcpl_id, hid_t tcpl_id, hid_t tapl_id);
    hid_t H5Topen2(hid_t loc_id, const (char*)name, hid_t tapl_id);
    herr_t H5Tcommit_anon(hid_t loc_id, hid_t type_id, hid_t tcpl_id, hid_t tapl_id);
    hid_t H5Tget_create_plist(hid_t type_id);
    htri_t H5Tcommitted(hid_t type_id);
    herr_t H5Tencode(hid_t obj_id, void *buf, size_t *nalloc);
    hid_t H5Tdecode(const void *buf);

    /* Operations defined on compound datatypes */
    herr_t H5Tinsert(hid_t parent_id, const (char*)name, size_t offset,
                 hid_t member_id);
    herr_t H5Tpack(hid_t type_id);

    /* Operations defined on enumeration datatypes */
    hid_t H5Tenum_create(hid_t base_id);
    herr_t H5Tenum_insert(hid_t type, const (char*)name, const void *value);
    herr_t H5Tenum_nameof(hid_t type, const void *value, char *name/*out*/,
                     size_t size);
    herr_t H5Tenum_valueof(hid_t type, const (char*)name,
                      void *value/*out*/);

    /* Operations defined on variable-length datatypes */
    hid_t H5Tvlen_create(hid_t base_id);

    /* Operations defined on array datatypes */
    hid_t H5Tarray_create2(hid_t base_id, uint ndims,
                const hsize_t* dim);
    int H5Tget_array_ndims(hid_t type_id);
    int H5Tget_array_dims2(hid_t type_id, hsize_t* dims);

    /* Operations defined on opaque datatypes */
    herr_t H5Tset_tag(hid_t type, const (char*)tag);
    char *H5Tget_tag(hid_t type);

    /* Querying property values */
    hid_t H5Tget_super(hid_t type);
    H5TClass H5Tget_class(hid_t type_id);
    htri_t H5Tdetect_class(hid_t type_id, H5TClass cls);
    size_t H5Tget_size(hid_t type_id);
    H5TByteOrder H5Tget_order(hid_t type_id);
    size_t H5Tget_precision(hid_t type_id);
    int H5Tget_offset(hid_t type_id);
    herr_t H5Tget_pad(hid_t type_id, H5T_pad_t *lsb/*out*/,
                  H5T_pad_t *msb/*out*/);
    H5T_sign_t H5Tget_sign(hid_t type_id);
    herr_t H5Tget_fields(hid_t type_id, size_t *spos/*out*/,
                     size_t *epos/*out*/, size_t *esize/*out*/,
                     size_t *mpos/*out*/, size_t *msize/*out*/);
    size_t H5Tget_ebias(hid_t type_id);
    H5T_norm_t H5Tget_norm(hid_t type_id);
    H5T_pad_t H5Tget_inpad(hid_t type_id);
    H5TString H5Tget_strpad(hid_t type_id);
    int H5Tget_nmembers(hid_t type_id);
    char *H5Tget_member_name(hid_t type_id, uint membno);
    int H5Tget_member_index(hid_t type_id, const (char*)name);
    size_t H5Tget_member_offset(hid_t type_id, uint membno);
    H5TClass H5Tget_member_class(hid_t type_id, uint membno);
    hid_t H5Tget_member_type(hid_t type_id, uint membno);
    herr_t H5Tget_member_value(hid_t type_id, uint membno, void *value/*out*/);
    H5TCset H5Tget_cset(hid_t type_id);
    htri_t H5Tis_variable_str(hid_t type_id);
    hid_t H5Tget_native_type(hid_t type_id, H5TDirection direction);

    /* Setting property values */
    herr_t H5Tset_size(hid_t type_id, size_t size);
    herr_t H5Tset_order(hid_t type_id, H5TByteOrder order);
    herr_t H5Tset_precision(hid_t type_id, size_t prec);
    herr_t H5Tset_offset(hid_t type_id, size_t offset);
    herr_t H5Tset_pad(hid_t type_id, H5T_pad_t lsb, H5T_pad_t msb);
    herr_t H5Tset_sign(hid_t type_id, H5T_sign_t sign);
    herr_t H5Tset_fields(hid_t type_id, size_t spos, size_t epos,
                     size_t esize, size_t mpos, size_t msize);
    herr_t H5Tset_ebias(hid_t type_id, size_t ebias);
    herr_t H5Tset_norm(hid_t type_id, H5T_norm_t norm);
    herr_t H5Tset_inpad(hid_t type_id, H5T_pad_t pad);
    herr_t H5Tset_cset(hid_t type_id, H5TCset cset);
    herr_t H5Tset_strpad(hid_t type_id, H5TString strpad);

    /* Type conversion database */
    herr_t H5Tregister(H5T_pers_t pers, const (char*)name, hid_t src_id,
                   hid_t dst_id, H5T_conv_t func);
    herr_t H5Tunregister(H5T_pers_t pers, const (char*)name, hid_t src_id,
                     hid_t dst_id, H5T_conv_t func);
    H5T_conv_t H5Tfind(hid_t src_id, hid_t dst_id, H5T_cdata_t **pcdata);
    htri_t H5Tcompiler_conv(hid_t src_id, hid_t dst_id);
    herr_t H5Tconvert(hid_t src_id, hid_t dst_id, size_t nelmts,
                  void *buf, void *background, hid_t plist_id);
    herr_t H5Zregister(const void *cls);
    herr_t H5Zunregister(H5ZFilter id);
    htri_t H5Zfilter_avail(H5ZFilter id);
    herr_t H5Zget_filter_info(H5ZFilter filter, uint* filter_config_flags);
}
