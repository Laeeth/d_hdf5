/**
  hdf5.bindings

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

module hdf5.bindings;
public import core.stdc.stdint;
public import core.sys.posix.sys.types: off_t;
public import core.stdc.time;
public import core.stdc.stdint;
import std.conv;
import std.string;
import std.array;
import std.stdio;

enum h5parallel=0;

enum H5_VERS_MAJOR   = 1;  /* For major interface/format changes */
enum H5_VERS_MINOR   = 8;  /* For minor interface/format changes */
enum H5_VERS_RELEASE = 14; /* For tweaks, bug-fixes, or development */
enum H5_VERS_SUBRELEASE  = ""; /* For pre-releases like snap0 */
                /* Empty string for real releases.           */
enum H5_VERS_INFO = "HDF5 library version: 1.8.14"; /* Full version string */

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
alias herr_t = int;
alias hbool_t = uint;
alias htri_t = int;

static if ( H5_SIZEOF_SIZE_T==H5_SIZEOF_INT ) {
  alias ssize_t = int;
 }
else static if ( H5_SIZEOF_SIZE_T==H5_SIZEOF_LONG ) {
  alias ssize_t = long;
}
else static if ( H5_SIZEOF_SIZE_T==H5_SIZEOF_LONG_LONG ) {
  alias ssize_t = long;
}
else {
  static assert(0, "nothing appropriate for ssize_t");
}

alias hsize_t = ulong;
alias hssize_t = long;

static if (H5_SIZEOF_INT64_T >= 8 ) {
  alias haddr_t = uint64_t;
  enum HADDR_UNDEF = ( cast(haddr_t) cast(int64_t)(-1));
  enum H5_SIZEOF_HADDR_T = H5_SIZEOF_INT64_T;
  enum HADDR_AS_MPI_TYPE = MPI_LONG_LONG_INT;
}
else static if (H5_SIZEOF_INT >= 8 ) {
  alias haddr_t = uint;
  enum HADDR_UNDEF = (cast(haddr_t)(-1));
  enum H5_SIZEOF_HADDR_T = H5_SIZEOF_INT;
  enum HADDR_AS_MPI_TYPE = MPI_UNSIGNED;
}
else static if (H5_SIZEOF_LONG >= 8 ) {
  alias haddr_t = ulong;
  enum HADDR_UNDEF = (cast(haddr_t) cast(long)(-1));
  enum H5_SIZEOF_HADDR_T = H5_SIZEOF_LONG;
  enum HADDR_AS_MPI_TYPE = MPI_UNSIGNED_LONG;
}
else static if (H5_SIZEOF_LONG_LONG >= 8 ) {
  alias haddr_t = ulong;
  enum HADDR_UNDEF = (cast(haddr_t) cast(long)(-1));
  enum H5_SIZEOF_HADDR_T = H5_SIZEOF_LONG_LONG;
  enum HADDR_AS_MPI_TYPE = MPI_LONG_LONG_INT;
}
else {
  static assert(0, "nothing appropriate for haddr_t");
 }

static if ( H5_SIZEOF_UINT64_T>=8 ) { }
 else static if ( H5_SIZEOF_INT>=8 ) {
    alias uint64_t = uint;
    enum H5_SIZEOF_UINT64_T = H5_SIZEOF_INT;
   }
 else static if ( H5_SIZEOF_LONG>=8 ) {
    alias uint64_t = uint;
    enum H5_SIZEOF_UINT64_T = H5_SIZEOF_LONG;
   }
 else static if ( H5_SIZEOF_LONG_LONG>=8 ) {
    alias uint64_t = ulong;
    enum H5_SIZEOF_UINT64_T = H5_SIZEOF_LONG_LONG;
   }
   else {
     static assert(0, "nothing appropriate for uint64_t");
   }

/* Default value for all property list classes */
enum H5P_DEFAULT = 0;

/* Common iteration orders */
enum H5IterOrder
{
    Unknown = -1,       /* Unknown order */
    Inc,                /* Increasing order */
    Dec,                /* Decreasing order */
    Native,             /* No particular order, whatever is fastest */
    N               /* Number of iteration orders */
}

/* Iteration callback values */
/* (Actually, any postive value will cause the iterator to stop and pass back
 *      that positive value to the function that called the iterator)
 */
enum H5_ITER_ERROR = (-1);
enum H5_ITER_CONT = (0);
enum H5_ITER_STOP = (1);

/*
 * The types of indices on links in groups/attributes on objects.
 * Primarily used for "<do> <foo> by index" routines and for iterating over
 * links in groups/attributes on objects.
 */
enum H5Index {
    Unknown = -1,  /* Unknown index type           */
    Name,      /* Index on names           */
    CRTOrder,     /* Index on creation order      */
    N          /* Number of indices defined        */
}

/*
 * Storage info struct used by H5O_info_t and H5F_info_t
 */
align(1)
{
  struct H5_ih_info_t {
      hsize_t     index_size;     /* btree and/or list */
      hsize_t     heap_size;
  }
}
/* Functions in H5.c */
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

string ZtoString(const char[] c)
{
    return to!string(fromStringz(cast(char*)c));
}

string ZtoString(const char* c)
{
    return to!string(fromStringz(c));
}

enum H5AC__CURR_CACHE_CONFIG_VERSION   =1;
enum H5AC__MAX_TRACE_FILE_NAME_LEN   =1024;

enum H5AC_METADATA
{
  WRITE_STRATEGY__PROCESS_0_ONLY    =0,
  WRITE_STRATEGY__DISTRIBUTED       =1,
}
struct H5ACCacheConfig
{
    align(1)
    {
      /* general configuration fields: */
      int                     ver;

      hbool_t        rpt_fcn_enabled;

      hbool_t        open_trace_file;
      hbool_t                  close_trace_file;
      char[H5AC__MAX_TRACE_FILE_NAME_LEN + 1] trace_file_name;

      hbool_t                  evictions_enabled;

      hbool_t                  set_initial_size;
      size_t                   initial_size;

      double                   min_clean_fraction;

      size_t                   max_size;
      size_t                   min_size;

      long                 epoch_length;


      /* size increase control fields: */
      //enum H5C_cache_incr_mode=incr_mode;

      double                   lower_hr_threshold;

      double                   increment;

      hbool_t                  apply_max_increment;
      size_t                   max_increment;

      //enum H5C_cache_flash_incr_mode      =flash_incr_mode;
      double                              flash_multiple;
      double                              flash_threshold;


      /* size decrease control fields: */
      //enum H5C_cache_decr_mode decr_mode;

      double                   upper_hr_threshold;

      double                   decrement;

      hbool_t                  apply_max_decrement;
      size_t                   max_decrement;

      int                      epochs_before_eviction;

      hbool_t                  apply_empty_reserve;
      double                   empty_reserve;


      /* parallel configuration fields: */
      int                      dirty_bytes_threshold;
      int                      metadata_write_strategy;
    }
}




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
enum H5DLayout
{
    Error    = -1,

    Compact     = 0,    /*raw data is very small             */
    Contiguous  = 1,    /*the default                    */
    Chunked     = 2,    /*slow and fancy                 */
    Nlayouts    = 3 /*this one must be last!             */
}

/* Types of chunk index data structures */
enum H5D_chunk_index_t {
    H5D_CHUNK_BTREE = 0 /* v1 B-tree index               */
}

/* Values for the space allocation time property */
enum H5DAllocTime {
    Error    = -1,
    Default      = 0,
    Early    = 1,
    Late     = 2,
    Incr     = 3
}

/* Values for the status of space allocation */
enum H5DSpaceStatus
{
    Error      = -1,
    NotAllocated  = 0,
    PartAllocated = 1,
    Allocated      = 2
}

/* Values for time of writing fill value property */
enum H5D_fill_time_t {
    H5D_FILL_TIME_ERROR = -1,
    H5D_FILL_TIME_ALLOC = 0,
    H5D_FILL_TIME_NEVER = 1,
    H5D_FILL_TIME_IFSET = 2
}

/* Values for fill value status */
enum H5D_fill_value_t {
    H5D_FILL_VALUE_ERROR        =-1,
    H5D_FILL_VALUE_UNDEFINED    =0,
    H5D_FILL_VALUE_DEFAULT      =1,
    H5D_FILL_VALUE_USER_DEFINED =2
}

    /*********************/
    /* Public Prototypes */
    /*********************/

    /* Define the operator function pointer for H5Diterate() */
extern(C)
{
  alias H5D_operator_t = herr_t function(void *elem, hid_t type_id, int ndim, const hsize_t *point, void *operator_data);
  /* Define the operator function pointer for H5Dscatter() */
  alias H5D_scatter_func_t = herr_t function(const void **src_buf/*out*/, size_t *src_buf_bytes_used/*out*/, void *op_data);
  /* Define the operator function pointer for H5Dgather() */
  alias H5D_gather_func_t = herr_t function(const void *dst_buf, size_t dst_buf_bytes_used, void *op_data);
  version(Posix) {
    hid_t H5Dcreate2(hid_t loc_id, const char *name, hid_t type_id,
                     hid_t space_id, hid_t lcpl_id, hid_t dcpl_id, hid_t dapl_id);
    hid_t H5Dcreate_anon(hid_t file_id, hid_t type_id, hid_t space_id, hid_t plist_id, hid_t dapl_id);
    hid_t H5Dopen2(hid_t file_id, const char *name, hid_t dapl_id);
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



/* Information struct for attribute (for H5Aget_info/H5Aget_info_by_idx) */
align(1)
{
  struct H5A_info_t {
      hbool_t             corder_valid;   /* Indicate if creation order is valid */
      H5O_msg_crt_idx_t   corder;         /* Creation order                 */
      H5TCset             cset;           /* Character set of attribute name */
      hsize_t             data_size;      /* Size of raw data		  */
  }
}
// Typedef for H5Aiterate2() callbacks
extern(C)
{
  alias H5A_operator2_t = herr_t function(hid_t location_id/*in*/, const char *attr_name/*in*/, const H5A_info_t *ainfo/*in*/, void *op_data/*in,out*/);
}
version(Posix)
{
  extern(C)
  {
    // Public function prototypes

    hid_t   H5Acreate2(hid_t loc_id, const char *attr_name, hid_t type_id, hid_t space_id, hid_t acpl_id, hid_t aapl_id);
    hid_t   H5Acreate_by_name(hid_t loc_id, const char *obj_name, const char *attr_name,
        hid_t type_id, hid_t space_id, hid_t acpl_id, hid_t aapl_id, hid_t lapl_id);
    hid_t   H5Aopen(hid_t obj_id, const char *attr_name, hid_t aapl_id);
    hid_t   H5Aopen_by_name(hid_t loc_id, const char *obj_name, const char *attr_name, hid_t aapl_id, hid_t lapl_id);
    hid_t   H5Aopen_by_idx(hid_t loc_id, const char *obj_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t aapl_id,
        hid_t lapl_id);
    herr_t  H5Awrite(hid_t attr_id, hid_t type_id, const void *buf);
    herr_t  H5Aread(hid_t attr_id, hid_t type_id, void *buf);
    herr_t  H5Aclose(hid_t attr_id);
    hid_t   H5Aget_space(hid_t attr_id);
    hid_t   H5Aget_type(hid_t attr_id);
    hid_t   H5Aget_create_plist(hid_t attr_id);
    ssize_t H5Aget_name(hid_t attr_id, size_t buf_size, char *buf);
    ssize_t H5Aget_name_by_idx(hid_t loc_id, const char *obj_name, H5Index idx_type, H5IterOrder order, hsize_t n,
        char *name /*out*/, size_t size, hid_t lapl_id);
    hsize_t H5Aget_storage_size(hid_t attr_id);
    herr_t  H5Aget_info(hid_t attr_id, H5A_info_t *ainfo /*out*/);
    herr_t  H5Aget_info_by_name(hid_t loc_id, const char *obj_name, const char *attr_name, H5A_info_t *ainfo /*out*/, hid_t lapl_id);
    herr_t  H5Aget_info_by_idx(hid_t loc_id, const char *obj_name, H5Index idx_type, H5IterOrder order, hsize_t n,
        H5A_info_t *ainfo /*out*/, hid_t lapl_id);
    herr_t  H5Arename(hid_t loc_id, const char *old_name, const char *new_name);
    herr_t  H5Arename_by_name(hid_t loc_id, const char *obj_name, const char *old_attr_name, const char *new_attr_name, hid_t lapl_id);
    herr_t  H5Aiterate2(hid_t loc_id, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5A_operator2_t op, void *op_data);
    herr_t  H5Aiterate_by_name(hid_t loc_id, const char *obj_name, H5Index idx_type, H5IterOrder order, hsize_t *idx,
         H5A_operator2_t op, void *op_data, hid_t lapd_id);
    herr_t  H5Adelete(hid_t loc_id, const char *name);
    herr_t  H5Adelete_by_name(hid_t loc_id, const char *obj_name, const char *attr_name, hid_t lapl_id);
    herr_t  H5Adelete_by_idx(hid_t loc_id, const char *obj_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id);
    htri_t H5Aexists(hid_t obj_id, const char *attr_name);
    htri_t H5Aexists_by_name(hid_t obj_id, const char *obj_name, const char *attr_name, hid_t lapl_id);
  }
}


enum H5D_ONE_LINK_CHUNK_IO_THRESHOLD = 0;
enum H5D_MULTI_CHUNK_IO_COL_THRESHOLD = 60;
enum H5FDMPIO {
    Independent = 0,      /*zero is the default*/
    Collective
}

/* Type of chunked dataset I/O */
enum H5FDMPIOChunkOptions
{
    Default = 0,
    OneIO,         /*zero is the default*/
    MultiIO
}

/* Type of collective I/O */

alias H5FD_MPIO=H5FD_mpio_init;



static if (H5_HAVE_PARALLEL)
{
  enum H5F_DEBUG = true;
}

  /* Global var whose value comes from environment variable */
  /* (Defined in H5FDmpio.c) */
  extern __gshared hbool_t H5FD_mpi_opt_types_g;

  version(Posix) {

  /* Function prototypes */
    hid_t H5FD_mpio_init();
    void H5FD_mpio_term();
    herr_t H5Pset_fapl_mpio(hid_t fapl_id, MPI_Comm comm, MPI_Info info);
    herr_t H5Pget_fapl_mpio(hid_t fapl_id, MPI_Comm *comm/*out*/, MPI_Info *info/*out*/);
    herr_t H5Pset_dxpl_mpio(hid_t dxpl_id, H5FDMPIO xfer_mode);
    herr_t H5Pget_dxpl_mpio(hid_t dxpl_id, H5FDMPIO *xfer_mode/*out*/);
    herr_t H5Pset_dxpl_mpio_collective_opt(hid_t dxpl_id, H5FDMPIO opt_mode);
    herr_t H5Pset_dxpl_mpio_chunk_opt(hid_t dxpl_id, H5FDMPIOChunkOptions opt_mode);
    herr_t H5Pset_dxpl_mpio_chunk_opt_num(hid_t dxpl_id, uint num_chunk_per_proc);
    herr_t H5Pset_dxpl_mpio_chunk_opt_ratio(hid_t dxpl_id, uint percent_num_proc_per_chunk);
  }
}



/*
 * These are the bits that can be passed to the `flags' argument of
 * H5Fcreate() and H5Fopen(). Use the bit-wise OR operator (|) to combine
 * them as needed.  As a side effect, they call H5check_version() to make sure
 * that the application is compiled with a version of the hdf5 header files
 * which are compatible with the library to which the application is linked.
 * We're assuming that these constants are used rather early in the hdf5
 * session.
 *
 */
enum H5F_ACC_RDONLY  = 0x0000u; /*absence of rdwr => rd-only */
enum H5F_ACC_RDWR    = 0x0001u; /*open for read and write    */
enum H5F_ACC_TRUNC   = 0x0002u; /*overwrite existing files   */
enum H5F_ACC_EXCL    = 0x0004u; /*fail if file already exists*/
enum H5F_ACC_DEBUG   = 0x0008u; /*print debug info       */
enum H5F_ACC_CREAT   = 0x0010u; /*create non-existing files  */

/* Value passed to H5Pset_elink_acc_flags to cause flags to be taken from the
 * parent file. */
enum H5F_ACC_DEFAULT = 0xffffu; /*ignore setting on lapl     */

/* Flags for H5Fget_obj_count() & H5Fget_obj_ids() calls */
enum H5F_OBJ_FILE    = 0x0001u; /* File objects */
enum H5F_OBJ_DATASET = 0x0002u; /* Dataset objects */
enum H5F_OBJ_GROUP   = 0x0004u; /* Group objects */
enum H5F_OBJ_DATATYPE= 0x0008u; /* Named datatype objects */
enum H5F_OBJ_ATTR    = 0x0010u; /* Attribute objects */
enum H5F_OBJ_ALL     = (H5F_OBJ_FILE|H5F_OBJ_DATASET|H5F_OBJ_GROUP|H5F_OBJ_DATATYPE|H5F_OBJ_ATTR);
enum H5F_OBJ_LOCAL   = 0x0020u; /* Restrict search to objects opened through current file ID */
                                /* (as opposed to objects opened through any file ID accessing this file) */


enum H5F_FAMILY_DEFAULT = cast(hsize_t) 0;

/*
 * Use this constant string as the MPI_Info key to set H5Fmpio debug flags.
 * To turn on H5Fmpio debug flags, set the MPI_Info value with this key to
 * have the value of a string consisting of the characters that turn on the
 * desired flags.
 */
enum H5F_MPIO_DEBUG_KEY = "H5F_mpio_debug_key";

/* The difference between a single file and a set of mounted files */
enum H5F_scope_t {
    H5F_SCOPE_LOCAL = 0,    /*specified file handle only        */
    H5F_SCOPE_GLOBAL    = 1     /*entire virtual file           */
}

/* Unlimited file size for H5Pset_external() */
enum H5F_UNLIMITED = (cast(hsize_t)(-1L));

/* How does file close behave?
 * H5F_CLOSE_DEFAULT - Use the degree pre-defined by underlining VFL
 * H5F_CLOSE_WEAK    - file closes only after all opened objects are closed
 * H5F_CLOSE_SEMI    - if no opened objects, file is close; otherwise, file
               close fails
 * H5F_CLOSE_STRONG  - if there are opened objects, close them first, then
               close file
 */
enum H5F_close_degree_t {
    H5F_CLOSE_DEFAULT   = 0,
    H5F_CLOSE_WEAK      = 1,
    H5F_CLOSE_SEMI      = 2,
    H5F_CLOSE_STRONG    = 3
}

/* Current "global" information about file */
/* (just size info currently) */
align(1)
{
  struct H5F_info_t {
      hsize_t     super_ext_size; /* Superblock extension size */
      struct {
      hsize_t     hdr_size;       /* Shared object header message header size */
      H5_ih_info_t    msgs_info;      /* Shared object header message index & heap size */
      };
    }
}

/*
 * Types of allocation requests. The values larger than H5FD_MEM_DEFAULT
 * should not change other than adding new types to the end. These numbers
 * might appear in files.
 *
 * Note: please change the log VFD flavors array if you change this
 * enumeration.
 */
enum H5F_mem_t {
    H5FD_MEM_NOLIST     = -1,   /* Data should not appear in the free list.
                                 * Must be negative.
                                 */
    H5FD_MEM_DEFAULT    = 0,    /* Value not yet set.  Can also be the
                                 * datatype set in a larger allocation
                                 * that will be suballocated by the library.
                                 * Must be zero.
                                 */
    H5FD_MEM_SUPER      = 1,    /* Superblock data */
    H5FD_MEM_BTREE      = 2,    /* B-tree data */
    H5FD_MEM_DRAW       = 3,    /* Raw data (content of datasets, etc.) */
    H5FD_MEM_GHEAP      = 4,    /* Global heap data */
    H5FD_MEM_LHEAP      = 5,    /* Local heap data */
    H5FD_MEM_OHDR       = 6,    /* Object header data */

    H5FD_MEM_NTYPES             /* Sentinel value - must be last */
}

/* Library's file format versions */
enum H5F_libver_t {
    H5F_LIBVER_EARLIEST,        /* Use the earliest possible format for storing objects */
    H5F_LIBVER_LATEST           /* Use the latest possible format available for storing objects*/
}

    /* Define file format version for 1.8 to prepare for 1.10 release.  
     * (Not used anywhere now)*/
    // #define H5F_LIBVER_18 H5F_LIBVER_LATEST

    /* Functions in H5F.c */
version(Posix) {
  extern(C)
  {
    htri_t H5Fis_hdf5(const char *filename);
    hid_t  H5Fcreate(const char *filename, uint flags, hid_t create_plist, hid_t access_plist);
    hid_t  H5Fopen(const char *filename, uint flags, hid_t access_plist);
    hid_t  H5Freopen(hid_t file_id);
    herr_t H5Fflush(hid_t object_id, H5F_scope_t _scope);
    herr_t H5Fclose(hid_t file_id);
    hid_t  H5Fget_create_plist(hid_t file_id);
    hid_t  H5Fget_access_plist(hid_t file_id);
    herr_t H5Fget_intent(hid_t file_id, uint * intent);
    ssize_t H5Fget_obj_count(hid_t file_id, uint types);
    ssize_t H5Fget_obj_ids(hid_t file_id, uint types, size_t max_objs, hid_t *obj_id_list);
    herr_t H5Fget_vfd_handle(hid_t file_id, hid_t fapl, void **file_handle);
    herr_t H5Fmount(hid_t loc, const char *name, hid_t child, hid_t plist);
    herr_t H5Funmount(hid_t loc, const char *name);
    hssize_t H5Fget_freespace(hid_t file_id);
    herr_t H5Fget_filesize(hid_t file_id, hsize_t *size);
    ssize_t H5Fget_file_image(hid_t file_id, void * buf_ptr, size_t buf_len);
    herr_t H5Fget_mdc_hit_rate(hid_t file_id, double * hit_rate_ptr);
    herr_t H5Fget_mdc_size(hid_t file_id, size_t * max_size_ptr, size_t * min_clean_size_ptr, size_t * cur_size_ptr, int * cur_num_entries_ptr);
    herr_t H5Freset_mdc_hit_rate_stats(hid_t file_id);
    ssize_t H5Fget_name(hid_t obj_id, char *name, size_t size);
    herr_t H5Fget_info(hid_t obj_id, H5F_info_t *bh_info);
    herr_t H5Fclear_elink_file_cache(hid_t file_id);
    version(h5parallel) herr_t H5Fset_mpi_atomicity(hid_t file_id, hbool_t flag);
    version(h5parallel) herr_t H5Fget_mpi_atomicity(hid_t file_id, hbool_t *flag);
  }
}

enum H5GStorageType {
    Unknown = -1,  /* Unknown link storage type  */
    SymbolTable,      /* Links in group are stored with a "symbol table" */
                                        /* (this is sometimes called "old-style" groups) */
    Compact,   /* Links are stored in object header */
    Dense    /* Links are stored in fractal heap & indexed with v2 B-tree */
}

/* Information struct for group (for H5Gget_info/H5Gget_info_by_name/H5Gget_info_by_idx) */
struct H5GInfo {
    align(1)
    {
      H5GStorageType  storage_type;    /* Type of storage for links in group */
      hsize_t   nlinks;               /* Number of links in group */
      long     max_corder;             /* Current max. creation order value for group */
      hbool_t     mounted;             /* Whether group has a file mounted on it */
  }
}

extern(C)
{
  hid_t H5Gcreate2(hid_t loc_id, const char *name, hid_t lcpl_id, hid_t gcpl_id, hid_t gapl_id);
  hid_t H5Gcreate_anon(hid_t loc_id, hid_t gcpl_id, hid_t gapl_id);
  hid_t H5Gopen2(hid_t loc_id, const char *name, hid_t gapl_id);
  hid_t H5Gget_create_plist(hid_t group_id);
  herr_t H5Gget_info(hid_t loc_id, H5GInfo *ginfo);
  herr_t H5Gget_info_by_name(hid_t loc_id, const(char *)name, H5GInfo *ginfo, hid_t lapl_id);
  herr_t H5Gget_info_by_idx(hid_t loc_id, const(char *)group_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5GInfo *ginfo, hid_t lapl_id);
  herr_t H5Gclose(hid_t group_id);
}

/*
 * Library type values.  Start with `1' instead of `0' because it makes the
 * tracing output look better when hid_t values are large numbers.  Change the
 * TYPE_BITS in H5I.c if the MAXID gets larger than 32 (an assertion will
 * fail otherwise).
 *
 * When adding types here, add a section to the 'misc19' test in test/tmisc.c
 * to verify that the H5I{inc|dec|get}_ref() routines work correctly with in.
 *
 */

enum H5IType
{
    Uninitialized    = (-2), /*uninitialized type                */
    BadID       = (-1), /*invalid Type                  */
    FileObject        = 1,    /*type ID for File objects          */
    Group,              /*type ID for Group objects         */
    DataType,           /*type ID for Datatype objects          */
    DataSpace,          /*type ID for Dataspace objects         */
    DataSet,            /*type ID for Dataset objects           */
    Attr,               /*type ID for Attribute objects         */
    Reference,          /*type ID for Reference objects         */
    VirtualFileLayer,            /*type ID for virtual file layer        */
    GenericPropClass,            /*type ID for generic property list classes */
    GenericPropList,            /*type ID for generic property lists        */
    ErrorClass,            /*type ID for error classes         */
    ErrorMsg,              /*type ID for error messages            */
    ErrorStack,            /*type ID for error stacks          */
    Numtypes              /*number of library types, MUST BE LAST!    */
}

/* Type of atoms to return to users */
alias hid_t = int;
enum H5_SIZEOF_HID_T = H5_SIZEOF_INT;

/* An invalid object ID. This is also negative for error return. */
enum H5I_INVALID_HID = (-1);

/*
 * Function for freeing objects. This function will be called with an object
 * ID type number and a pointer to the object. The function should free the
 * object and return non-negative to indicate that the object
 * can be removed from the ID type. If the function returns negative
 * (failure) then the object will remain in the ID type.
 */
extern(C)
{
  alias H5I_free_t = herr_t function(void*);

  /* Type of the function to compare objects & keys */
  alias H5I_search_func_t = int function(void *obj, hid_t id, void *key);
}
//Public API functions

version(Posix)
{
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
}
enum H5L_MAX_LINK_NAME_LEN  = (cast(uint32_t)(-1));  /* (4GB - 1) */
enum H5L_SAME_LOC = 0;
enum H5L_LINK_CLASS_T_VERS = 0;

/* Link class types.
 * Values less than 64 are reserved for the HDF5 library's internal use.
 * Values 64 to 255 are for "user-defined" link class types; these types are
 * defined by HDF5 but their behavior can be overridden by users.
 */
enum H5LType {
    Error = (-1),      /* Invalid link type id         */
    Hard  = 0,          /* Hard link id                 */
    Soft  = 1,          /* Soft link id                 */
    External  = 64,     /* External link id             */
    Max = 255          /* Maximum link type id         */
};
enum H5L_TYPE_BUILTIN_MAX = H5LType.Soft;      /* Maximum value link value for "built-in" link types */
enum H5L_TYPE_UD_MIN = H5LType.External;  /* Link ids at or above this value are "user-defined" link types. */

/* Information struct for link (for H5Lget_info/H5Lget_info_by_idx) */
  struct H5LInfo {
      H5LType          type;           /* Type of link                   */
      hbool_t             corder_valid;   /* Indicate if creation order is valid */
      int64_t             corder;         /* Creation order                 */
      H5TCset          cset;           /* Character set of link name     */
      union u {
          haddr_t         address;        /* Address hard link points to    */
          size_t          val_size;       /* Size of a soft link or UD link value */
      };
  }

extern(C)
{
/* The H5L_class_t struct can be used to override the behavior of a
 * "user-defined" link class. Users should populate the struct with callback
 * functions defined below.
 */
/* Callback prototypes for user-defined links */
/* Link creation callback */
alias H5L_create_func_t = herr_t function(const char *link_name, hid_t loc_group, const void *lnkdata, size_t lnkdata_size, hid_t lcpl_id);

/* Callback for when the link is moved */
alias H5L_move_func_t = herr_t function(const char *new_name, hid_t new_loc, const void *lnkdata, size_t lnkdata_size);

/* Callback for when the link is copied */
alias H5L_copy_func_t = herr_t function(const char *new_name, hid_t new_loc, const void *lnkdata, size_t lnkdata_size);

/* Callback during link traversal */
alias H5L_traverse_func_t = herr_t function(const char *link_name, hid_t cur_group, const void *lnkdata, size_t lnkdata_size, hid_t lapl_id);

/* Callback for when the link is deleted */
alias H5L_delete_func_t = herr_t function(const char *link_name, hid_t file, const void *lnkdata, size_t lnkdata_size);

/* Callback for querying the link */
/* Returns the size of the buffer needed */
alias H5L_query_func_t = ssize_t function(const char *link_name, const void *lnkdata, size_t lnkdata_size, void *buf /*out*/, size_t buf_size);

/* User-defined link types */
  struct H5L_class_t {
      int _version;                    /* Version number of this struct        */
      H5LType id;                  /* Link type ID                         */
      const char *comment;            /* Comment for debugging                */
      H5L_create_func_t create_func;  /* Callback during link creation        */
      H5L_move_func_t move_func;      /* Callback after moving link           */
      H5L_copy_func_t copy_func;      /* Callback after copying link          */
      H5L_traverse_func_t trav_func;  /* Callback during link traversal       */
      H5L_delete_func_t del_func;     /* Callback for link deletion           */
      H5L_query_func_t query_func;    /* Callback for queries                 */
  }

/* Prototype for H5Literate/H5Literate_by_name() operator */
alias H5L_iterate_t = herr_t function(hid_t group, const char *name, const H5LInfo *info, void *op_data);

/* Callback for external link traversal */
alias H5L_elink_traverse_t = herr_t function(const char *parent_file_name,
    const char *parent_group_name, const char *child_file_name,
    const char *child_object_name, uint *acc_flags, hid_t fapl_id,
    void *op_data);
}

/********************/
/* Public Variables */
/********************/

version(Posix)
{
  //Public Prototypes
  extern(C)
  {
    herr_t H5Lmove(hid_t src_loc, const char *src_name, hid_t dst_loc, const char *dst_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Lcopy(hid_t src_loc, const char *src_name, hid_t dst_loc, const char *dst_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Lcreate_hard(hid_t cur_loc, const char *cur_name, hid_t dst_loc, const char *dst_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Lcreate_soft(const char *link_target, hid_t link_loc_id, const char *link_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Ldelete(hid_t loc_id, const char *name, hid_t lapl_id);
    herr_t H5Ldelete_by_idx(hid_t loc_id, const char *group_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id);
    herr_t H5Lget_val(hid_t loc_id, const char *name, void *buf/*out*/, size_t size, hid_t lapl_id);
    herr_t H5Lget_val_by_idx(hid_t loc_id, const char *group_name, H5Index idx_type, H5IterOrder order, hsize_t n, void *buf/*out*/, size_t size, hid_t lapl_id);
    htri_t H5Lexists(hid_t loc_id, const char *name, hid_t lapl_id);
    herr_t H5Lget_info(hid_t loc_id, const char *name, H5LInfo *linfo /*out*/, hid_t lapl_id);
    herr_t H5Lget_info_by_idx(hid_t loc_id, const char *group_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5LInfo *linfo /*out*/, hid_t lapl_id); ssize_t H5Lget_name_by_idx(hid_t loc_id, const char *group_name, H5Index idx_type, H5IterOrder order, hsize_t n, char *name /*out*/, size_t size, hid_t lapl_id);
    herr_t H5Literate(hid_t grp_id, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5L_iterate_t op, void *op_data);
    herr_t H5Literate_by_name(hid_t loc_id, const char *group_name, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5L_iterate_t op, void *op_data, hid_t lapl_id);
    herr_t H5Lvisit(hid_t grp_id, H5Index idx_type, H5IterOrder order, H5L_iterate_t op, void *op_data);
    herr_t H5Lvisit_by_name(hid_t loc_id, const char *group_name, H5Index idx_type, H5IterOrder order, H5L_iterate_t op, void *op_data, hid_t lapl_id);

    /* UD link functions */
    herr_t H5Lcreate_ud(hid_t link_loc_id, const char *link_name, H5LType link_type, const void *udata, size_t udata_size, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Lregister(const H5L_class_t *cls);
    herr_t H5Lunregister(H5LType id);
    htri_t H5Lis_registered(H5LType id);

    /* External link functions */
    herr_t H5Lunpack_elink_val(const void *ext_linkval/*in*/, size_t link_size, uint *flags, const char **filename/*out*/, const char **obj_path /*out*/);
    herr_t H5Lcreate_external(const char *file_name, const char *obj_name, hid_t link_loc_id, const char *link_name, hid_t lcpl_id, hid_t lapl_id);
  }
}



extern(C)
{

  /*****************/
  /* Public Macros */
  /*****************/

  /* Flags for object copy (H5Ocopy) */
  enum H5O_COPY_SHALLOW_HIERARCHY_FLAG = (0x0001u);   /* Copy only immediate members */
  enum H5O_COPY_EXPAND_SOFT_LINK_FLAG  = (0x0002u);   /* Expand soft links into new objects */
  enum H5O_COPY_EXPAND_EXT_LINK_FLAG   = (0x0004u);   /* Expand external links into new objects */
  enum H5O_COPY_EXPAND_REFERENCE_FLAG  = (0x0008u);   /* Copy objects that are pointed by references */
  enum H5O_COPY_WITHOUT_ATTR_FLAG      = (0x0010u);   /* Copy object without copying attributes */
  enum H5O_COPY_PRESERVE_NULL_FLAG     = (0x0020u);   /* Copy NULL messages (empty space) */
  enum H5O_COPY_MERGE_COMMITTED_DTYPE_FLAG = (0x0040u);   /* Merge committed datatypes in dest file */
  enum H5O_COPY_ALL                    =(0x007Fu);   /* All object copying flags (for internal checking) */

  /* Flags for shared message indexes.
   * Pass these flags in using the mesg_type_flags parameter in
   * H5P_set_shared_mesg_index.
   * (Developers: These flags correspond to object header message type IDs,
   * but we need to assign each kind of message to a different bit so that
   * one index can hold multiple types.)
   */
  enum H5O_SHMESG_NONE_FLAG    = 0x0000;          /* No shared messages */
  enum H5O_SHMESG_SDSPACE_FLAG = (cast(uint)1 << 0x0001); /* Simple Dataspace Message.  */
  enum H5O_SHMESG_DTYPE_FLAG   = (cast(uint)1 << 0x0003); /* Datatype Message.  */
  enum H5O_SHMESG_FILL_FLAG    = (cast(uint)1 << 0x0005); /* Fill Value Message. */
  enum H5O_SHMESG_PLINE_FLAG   = (cast(uint)1 << 0x000b); /* Filter pipeline message.  */
  enum H5O_SHMESG_ATTR_FLAG    = (cast(uint)1 << 0x000c); /* Attribute Message.  */
  enum H5O_SHMESG_ALL_FLAG     = (H5O_SHMESG_SDSPACE_FLAG | H5O_SHMESG_DTYPE_FLAG | H5O_SHMESG_FILL_FLAG | H5O_SHMESG_PLINE_FLAG | H5O_SHMESG_ATTR_FLAG);

  /* Object header status flag definitions */
  enum H5O_HDR_CHUNK0_SIZE             = 0x03;    /* 2-bit field indicating # of bytes to store the size of chunk 0's data */
  enum H5O_HDR_ATTR_CRT_ORDER_TRACKED  = 0x04;    /* Attribute creation order is tracked */
  enum H5O_HDR_ATTR_CRT_ORDER_INDEXED  = 0x08;    /* Attribute creation order has index */
  enum H5O_HDR_ATTR_STORE_PHASE_CHANGE = 0x10;    /* Non-default attribute storage phase change values stored */
  enum H5O_HDR_STORE_TIMES             = 0x20;    /* Store access, modification, change & birth times for object */
  enum H5O_HDR_ALL_FLAGS = (H5O_HDR_CHUNK0_SIZE | H5O_HDR_ATTR_CRT_ORDER_TRACKED | H5O_HDR_ATTR_CRT_ORDER_INDEXED | H5O_HDR_ATTR_STORE_PHASE_CHANGE | H5O_HDR_STORE_TIMES);

  /* Maximum shared message values.  Number of indexes is 8 to allow room to add
   * new types of messages.
   */
  enum H5O_SHMESG_MAX_NINDEXES = 8;
  enum H5O_SHMESG_MAX_LIST_SIZE = 5000;

  /*******************/
  /* Public Typedefs */
  /*******************/

  /* Types of objects in file */
  enum H5OType {
      Unknown = -1,  /* Unknown object type      */
      Group,         /* Object is a group        */
      Dataset,       /* Object is a dataset      */
      NamedDataType,    /* Object is a named data type  */
      TypeNTypes             /* Number of different object types (must be last!) */
  }

  /* Information struct for object header metadata (for H5Oget_info/H5Oget_info_by_name/H5Oget_info_by_idx) */
  align(1)
  {
    struct H5O_hdr_info_t {
        uint _version;      /* Version number of header format in file */
        uint nmesgs;        /* Number of object header messages */
        uint nchunks;       /* Number of object header chunks */
        uint flags;             /* Object header status flags */
        struct space {
            hsize_t total;      /* Total space for storing object header in file */
            hsize_t meta;       /* Space within header for object header metadata information */
            hsize_t mesg;       /* Space within header for actual message information */
            hsize_t free;       /* Free space within object header */
        }
        struct mesg {
            uint64_t present;   /* Flags to indicate presence of message type in header */
            uint64_t _shared;   /* Flags to indicate message type is shared in header */
        }
    }
  }

  /* Information struct for object (for H5Oget_info/H5Oget_info_by_name/H5Oget_info_by_idx) */
    struct H5O_info_t {
      ulong    fileno;     /* File number that object is located in */
      haddr_t         addr;       /* Object address in file   */
      H5OType       type;       /* Basic object type (group, dataset, etc.) */
      uint        rc;     /* Reference count of object    */
      time_t      atime;      /* Access time          */
      time_t      mtime;      /* Modification time        */
      time_t      ctime;      /* Change time          */
      time_t      btime;      /* Birth time           */
      hsize_t         num_attrs;  /* # of attributes attached to object */
      H5O_hdr_info_t      hdr;            /* Object header information */
      /* Extra metadata storage for obj & attributes */
      struct meta_size {
          H5_ih_info_t   obj;             /* v1/v2 B-tree & local/fractal heap for groups, B-tree for chunked datasets */
          H5_ih_info_t   attr;            /* v2 B-tree & heap for attributes */
      }
    }
}

extern(C)
{
    /* Typedef for message creation indexes */
    alias H5O_msg_crt_idx_t = uint32_t;

    /* Prototype for H5Ovisit/H5Ovisit_by_name() operator */
    alias H5O_iterate_t = herr_t function(hid_t obj, const char *name, const H5O_info_t *info, void *op_data);
  }
    enum H5O_mcdt_search_ret_t {
        H5O_MCDT_SEARCH_ERROR = -1, /* Abort H5Ocopy */
        H5O_MCDT_SEARCH_CONT,   /* Continue the global search of all committed datatypes in the destination file */
        H5O_MCDT_SEARCH_STOP    /* Stop the search, but continue copying.  The committed datatype will be copied but not merged. */
    };

    /* Callback to invoke when completing the search for a matching committed datatype from the committed dtype list */
extern(C)
{
  alias H5O_mcdt_search_cb_t = H5O_mcdt_search_ret_t function(void *op_data);
}
    /********************/
    /* Public Variables */
    /********************/

version(Posix)
{
  extern(C)
  {
    // Public Prototypes 
    hid_t H5Oopen(hid_t loc_id, const char *name, hid_t lapl_id);
    hid_t H5Oopen_by_addr(hid_t loc_id, haddr_t addr);
    hid_t H5Oopen_by_idx(hid_t loc_id, const char *group_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id);
    htri_t H5Oexists_by_name(hid_t loc_id, const char *name, hid_t lapl_id);
    herr_t H5Oget_info(hid_t loc_id, H5O_info_t *oinfo);
    herr_t H5Oget_info_by_name(hid_t loc_id, const (char *)name, H5O_info_t *oinfo, hid_t lapl_id);
    herr_t H5Oget_info_by_idx(hid_t loc_id, const char *group_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5O_info_t *oinfo, hid_t lapl_id);
    herr_t H5Olink(hid_t obj_id, hid_t new_loc_id, const char *new_name, hid_t lcpl_id, hid_t lapl_id);
    herr_t H5Oincr_refcount(hid_t object_id);
    herr_t H5Odecr_refcount(hid_t object_id);
    herr_t H5Ocopy(hid_t src_loc_id, const char *src_name, hid_t dst_loc_id, const char *dst_name, hid_t ocpypl_id, hid_t lcpl_id);
    herr_t H5Oset_comment(hid_t obj_id, const char *comment);
    herr_t H5Oset_comment_by_name(hid_t loc_id, const char *name, const char *comment, hid_t lapl_id);
    ssize_t H5Oget_comment(hid_t obj_id, char *comment, size_t bufsize);
    ssize_t H5Oget_comment_by_name(hid_t loc_id, const char *name, char *comment, size_t bufsize, hid_t lapl_id);
    herr_t H5Ovisit(hid_t obj_id, H5Index idx_type, H5IterOrder order, H5O_iterate_t op, void *op_data);
    herr_t H5Ovisit_by_name(hid_t loc_id, const char *obj_name, H5Index idx_type, H5IterOrder order, H5O_iterate_t op, void *op_data, hid_t lapl_id);
    herr_t H5Oclose(hid_t object_id);
  }
}
extern(C)
{

  /*****************/
  /* Public Macros */
  /*****************/

  /*
   * The library's property list classes
   */
  alias   H5P_ROOT = H5P_CLS_ROOT_g;
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
  enum  H5P_CRT_ORDER_TRACKED = 0x0001;
  enum  H5P_CRT_ORDER_INDEXED = 0x0002;

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
}

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
extern(C)
{
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
}
    /*********************/
    /* Public Prototypes */
    /*********************/

version(Posix) {
  extern(C)
  {
    /* Generic property list routines */
    hid_t H5Pcreate_class(hid_t parent, const char *name, H5P_cls_create_func_t cls_create, void *create_data,
        H5P_cls_copy_func_t cls_copy, void *copy_data, H5P_cls_close_func_t cls_close, void *close_data);
    char *H5Pget_class_name(hid_t pclass_id);
    hid_t H5Pcreate(hid_t cls_id);
    herr_t H5Pregister2(hid_t cls_id, const char *name, size_t size, void *def_value, H5P_prp_create_func_t prp_create,
        H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get, H5P_prp_delete_func_t prp_del, H5P_prp_copy_func_t prp_copy,
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
}

enum H5RType
{
    BadType=-1,   /*invalid Reference Type                     */
    ObjectRef,                 /*Object reference                           */
    DatasetRegion,         /*Dataset Region Reference                   */
    MaxType                /*highest type (Invalid as true type)      */
}

/* Note! Be careful with the sizes of the references because they should really
 * depend on the run-time values in the file.  Unfortunately, the arrays need
 * to be defined at compile-time, so we have to go with the worst case sizes for
 * them.  -QAK
 */
enum  H5R_OBJ_REF_BUF_SIZE =haddr_t.sizeof;
/* Object reference structure for user's code */
//alias  hobj_ref_t  haddr_t ; /* Needs to be large enough to store largest haddr_t in a worst case machine (ie. 8 bytes currently) */

enum H5R_DSET_REG_REF_BUF_SIZE  =haddr_t.sizeof+4;
/* 4 is used instead of sizeof(int) to permit portability between
   the Crays and other machines (the heap ID is always encoded as an int32 anyway)
*/
/* Dataset Region reference structure for user's code */
alias hdset_reg_ref_t = ubyte[H5R_DSET_REG_REF_BUF_SIZE];/* Buffer to store heap ID and index */
/* Needs to be large enough to store largest haddr_t in a worst case machine (ie. 8 bytes currently) plus an int */

extern(C)
{
   herr_t H5Rcreate(void *_ref, hid_t loc_id, const char *name, H5RType reftype, hid_t space_id);
   hid_t H5Rdereference(hid_t dataset, H5RType ref_type, const void *_ref);
   hid_t H5Rget_region(hid_t dataset, H5RType ref_type, const void *_ref);
   herr_t H5Rget_obj_type2(hid_t id, H5RType ref_type, const void *_ref, H5OType *obj_type);
   ssize_t H5Rget_name(hid_t loc_id, H5RType ref_type, const void *_ref, char *name/*out*/, size_t size);
}


/* Define atomic datatypes */
enum H5S_ALL = 0;
enum H5S_UNLIMITED = (cast(hsize_t)cast(hssize_t)(-1));

/* Define user-level maximum number of dimensions */
enum H5S_MAX_RANK = 32;

/* Different types of dataspaces */
enum H5SClass {
    None         = -1,  /*error                                      */
    Scalar           = 0,   /*scalar variable                            */
    Simple           = 1,   /*simple data space                          */
    Null             = 2    /*null data space                            */
}

/* Different ways of combining selections */
enum H5SSeloper {
    Noop      = -1,  /* error                                     */
    Set       = 0,   /* Select "set" operation            */
    Or,
    And,
    Xor,
    NotB,
    NotA,
    Append,
    Prepend,
    Invalid,
}

enum {
    H5S_SELECT_NOOP      = -1,  /* error                                     */
    H5S_SELECT_SET       = 0,   /* Select "set" operation            */
    H5S_SELECT_OR,              /* Binary "or" operation for hyperslabs
                                 * (add new selection to existing selection)
                                 * Original region:  AAAAAAAAAA
                                 * New region:             BBBBBBBBBB
                                 * A or B:           CCCCCCCCCCCCCCCC
                                 */
    H5S_SELECT_AND,             /* Binary "and" operation for hyperslabs
                                 * (only leave overlapped regions in selection)
                                 * Original region:  AAAAAAAAAA
                                 * New region:             BBBBBBBBBB
                                 * A and B:                CCCC
                                 */
    H5S_SELECT_XOR,             /* Binary "xor" operation for hyperslabs
                                 * (only leave non-overlapped regions in selection)
                                 * Original region:  AAAAAAAAAA
                                 * New region:             BBBBBBBBBB
                                 * A xor B:          CCCCCC    CCCCCC
                                 */
    H5S_SELECT_NOTB,            /* Binary "not" operation for hyperslabs
                                 * (only leave non-overlapped regions in original selection)
                                 * Original region:  AAAAAAAAAA
                                 * New region:             BBBBBBBBBB
                                 * A not B:          CCCCCC
                                 */
    H5S_SELECT_NOTA,            /* Binary "not" operation for hyperslabs
                                 * (only leave non-overlapped regions in new selection)
                                 * Original region:  AAAAAAAAAA
                                 * New region:             BBBBBBBBBB
                                 * B not A:                    CCCCCC
                                 */
    H5S_SELECT_APPEND,          /* Append elements to end of point selection */
    H5S_SELECT_PREPEND,         /* Prepend elements to beginning of point selection */
    H5S_SELECT_INVALID          /* Invalid upper bound on selection operations */
}

/* Enumerated type for the type of selection */
enum H5S_sel_type {
    H5S_SEL_ERROR   = -1,   /* Error            */
    H5S_SEL_NONE    = 0,    /* Nothing selected         */
    H5S_SEL_POINTS  = 1,    /* Sequence of points selected  */
    H5S_SEL_HYPERSLABS  = 2,    /* "New-style" hyperslab selection defined  */
    H5S_SEL_ALL     = 3,    /* Entire extent selected   */
    H5S_SEL_N           /*THIS MUST BE LAST     */
}


version(Posix) {
  extern(C)
  {
      /* Functions in H5S.c */
      hid_t H5Screate(H5SClass type);
      hid_t H5Screate_simple(int rank, const hsize_t *dims,
                             const hsize_t *maxdims);
      herr_t H5Sset_extent_simple(hid_t space_id, int rank,
                                  const hsize_t *dims,
                                  const hsize_t *max);
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
    }
}

/* These are the various classes of datatypes */
/* If this goes over 16 types (0-15), the file format will need to change) */
enum H5TClass {
    None         = -1,  /*error                                      */
    Integer          = 0,   /*integer types                              */
    Float            = 1,   /*floating-point types                       */
    Time             = 2,   /*date and time types                        */
    String           = 3,   /*character string types                     */
    Bitfield         = 4,   /*bit field types                            */
    Opaque           = 5,   /*opaque types                               */
    Compound         = 6,   /*compound types                             */
    Reference        = 7,   /*reference types                            */
    Enum        = 8,   /*enumeration types                          */
    Vlen         = 9,   /*Variable-Length types                      */
    Array            = 10,  /*Array types                                */
    Nclasses                /*this must be last                          */
}

/* Byte orders */
enum H5TByteOrder {
    Error      = -1,  /*error                                      */
    LE         = 0,   /*little endian                              */
    BE         = 1,   /*bit endian                                 */
    Vax        = 2,   /*VAX mixed endian                           */
    Mixed      = 3,   /*Compound type with mixed member orders     */
    None       = 4    /*no particular order (strings, bits,..)     */
    /*H5T_ORDER_NONE must be last */
}

/* Types of integer sign schemes */
enum H5T_sign_t {
    H5T_SGN_ERROR        = -1,  /*error                                      */
    H5T_SGN_NONE         = 0,   /*this is an unsigned type                   */
    H5T_SGN_2            = 1,   /*two's complement                           */

    H5T_NSGN             = 2    /*this must be last!                         */
}

/* Floating-point normalization schemes */
enum H5T_norm_t {
    H5T_NORM_ERROR       = -1,  /*error                                      */
    H5T_NORM_IMPLIED     = 0,   /*msb of mantissa isn't stored, always 1     */
    H5T_NORM_MSBSET      = 1,   /*msb of mantissa is always 1                */
    H5T_NORM_NONE        = 2    /*not normalized                             */
    /*H5T_NORM_NONE must be last */
}

/*
 * Character set to use for text strings.  Do not change these values since
 * they appear in HDF5 files!
 */
enum H5TCset {
    Error       = -1,  /*error                                      */
    ASCII       = 0,   /*US ASCII                                   */
    UTF8        = 1,   /*UTF-8 Unicode encoding             */
    Reserved2  = 2,   /*reserved for later use             */
    Reserved3  = 3,   /*reserved for later use             */
    Reserved4  = 4,   /*reserved for later use             */
    Reserved5  = 5,   /*reserved for later use             */
    Reserved6  = 6,   /*reserved for later use             */
    Reserved7  = 7,   /*reserved for later use             */
    Reserved8  = 8,   /*reserved for later use             */
    Reserved9  = 9,   /*reserved for later use             */
    Reserved10 = 10,  /*reserved for later use             */
    Reserved11 = 11,  /*reserved for later use             */
    Reserved12 = 12,  /*reserved for later use             */
    Reserved13 = 13,  /*reserved for later use             */
    Reserved14 = 14,  /*reserved for later use             */
    Reserved15 = 15   /*reserved for later use             */
}

enum H5T_NCSET = H5TCset.Reserved2 ; /*Number of character sets actually defined  */

/*
 * Type of padding to use in character strings.  Do not change these values
 * since they appear in HDF5 files!
 */
enum H5TString {
    Error        = -1,  /*error                                      */
    Nullterm     = 0,   /*null terminate like in C                   */
    Nullpas      = 1,   /*pad with nulls                             */
    Spacepad     = 2,   /*pad with spaces like in Fortran            */
    Reserved3   = 3,   /*reserved for later use             */
    Reserved4   = 4,   /*reserved for later use             */
    Reserved5   = 5,   /*reserved for later use             */
    Reserved6   = 6,   /*reserved for later use             */
    Reserved7   = 7,   /*reserved for later use             */
    Reserved8   = 8,   /*reserved for later use             */
    Reserved9   = 9,   /*reserved for later use             */
    Reserved10  = 10,  /*reserved for later use             */
    Reserved11  = 11,  /*reserved for later use             */
    Reserved12  = 12,  /*reserved for later use             */
    Reserved13  = 13,  /*reserved for later use             */
    Reserved14  = 14,  /*reserved for later use             */
    Reserved15  = 15   /*reserved for later use             */
}

enum H5T_NSTR = H5TString.Reserved3; /*num H5TString types actually defined         */

/* Type of padding to use in other atomic types */
enum H5T_pad_t {
    H5T_PAD_ERROR        = -1,  /*error                                      */
    H5T_PAD_ZERO         = 0,   /*always set to zero                         */
    H5T_PAD_ONE          = 1,   /*always set to one                          */
    H5T_PAD_BACKGROUND   = 2,   /*set to background value                    */

    H5T_NPAD             = 3    /*THIS MUST BE LAST                          */
}

/* Commands sent to conversion functions */
enum H5T_cmd_t {
    H5T_CONV_INIT   = 0,    /*query and/or initialize private data       */
    H5T_CONV_CONV   = 1,    /*convert data from source to dest datatype */
    H5T_CONV_FREE   = 2 /*function is being removed from path        */
}

/* How is the `bkg' buffer used by the conversion function? */
enum H5T_bkg_t {
    H5T_BKG_NO      = 0,    /*background buffer is not needed, send NULL */
    H5T_BKG_TEMP    = 1,    /*bkg buffer used as temp storage only       */
    H5T_BKG_YES     = 2 /*init bkg buf with data before conversion   */
}

/* Type conversion client data */
  struct H5T_cdata_t {
      H5T_cmd_t       command;/*what should the conversion function do?    */
      H5T_bkg_t       need_bkg;/*is the background buffer needed?      */
      hbool_t     recalc; /*recalculate private data           */
      void        *priv;  /*private data                   */
  }

/* Conversion function persistence */
enum H5T_pers_t {
    H5T_PERS_DONTCARE   = -1,   /*wild card                  */
    H5T_PERS_HARD   = 0,    /*hard conversion function           */
    H5T_PERS_SOFT   = 1     /*soft conversion function           */
}

/* The order to retrieve atomic native datatype */
enum H5TDirection
{
    Default     = 0,    /*default direction is inscendent            */
    Ascend      = 1,    /*in inscendent order                        */
    Descend     = 2     /*in descendent order                        */
}

/* The exception type passed into the conversion callback function */
enum H5T_conv_except_t {
    H5T_CONV_EXCEPT_RANGE_HI       = 0,   /*source value is greater than destination's range */
    H5T_CONV_EXCEPT_RANGE_LOW      = 1,   /*source value is less than destination's range    */
    H5T_CONV_EXCEPT_PRECISION      = 2,   /*source value loses precision in destination      */
    H5T_CONV_EXCEPT_TRUNCATE       = 3,   /*source value is truncated in destination         */
    H5T_CONV_EXCEPT_PINF           = 4,   /*source value is positive infinity(floating number) */
    H5T_CONV_EXCEPT_NINF           = 5,   /*source value is negative infinity(floating number) */
    H5T_CONV_EXCEPT_NAN            = 6    /*source value is NaN(floating number)             */
}

/* The return value from conversion callback function H5T_conv_except_func_t */
enum H5T_conv_ret_t {
    H5T_CONV_ABORT      = -1,   /*abort conversion                           */
    H5T_CONV_UNHANDLED  = 0,    /*callback function failed to handle the exception      */
    H5T_CONV_HANDLED    = 1     /*callback function handled the exception successfully  */
}

/* Variable Length Datatype struct in memory */
/* (This is only used for VL sequences, not VL strings, which are stored in char *'s) */
  struct hvl_t {
      size_t len; /* Length of VL data (in base type units) */
      void *p;    /* Pointer to VL data */
  }

/* Variable Length String information */
enum H5T_VARIABLE = (cast(size_t)(-1));  /* Indicate that a string is variable length (null-terminated in C, instead of fixed length) */

/* Opaque information */
enum H5T_OPAQUE_TAG_MAX = 256; /* Maximum length of an opaque tag */
                                        /* This could be raised without too much difficulty */

extern(C)
{
    /* All datatype conversion functions are... */
    alias H5T_conv_t = herr_t function(hid_t src_id, hid_t dst_id, H5T_cdata_t *cdata,
          size_t nelmts, size_t buf_stride, size_t bkg_stride, void *buf,
          void *bkg, hid_t dset_xfer_plist);

    /* Exception handler.  If an exception like overflow happenes during conversion,
     * this function is called if it's registered through H5Pset_type_conv_cb.
     */
    alias H5T_conv_except_func_t = H5T_conv_ret_t function(H5T_conv_except_t except_type,
        hid_t src_id, hid_t dst_id, void *src_buf, void *dst_buf, void *user_data);


    /*
     * The IEEE floating point types in various byte orders.
     */
    alias H5T_IEEE_F32BE = H5T_IEEE_F32BE_g;
    alias H5T_IEEE_F32LE = H5T_IEEE_F32LE_g;
    alias H5T_IEEE_F64BE = H5T_IEEE_F64BE_g;
    alias H5T_IEEE_F64LE = H5T_IEEE_F64LE_g;
    extern __gshared hid_t H5T_IEEE_F32BE_g;
    extern __gshared hid_t H5T_IEEE_F32LE_g;
    extern __gshared hid_t H5T_IEEE_F64BE_g;
    extern __gshared hid_t H5T_IEEE_F64LE_g;

    /*
     * These are "standard" types.  For instance, signed (2's complement) and
     * unsigned integers of various sizes and byte orders.
     */
    alias H5T_STD_I8BE = H5T_STD_I8BE_g;
    alias H5T_STD_I8LE = H5T_STD_I8LE_g;
    alias H5T_STD_I16BE = H5T_STD_I16BE_g;
    alias H5T_STD_I16LE = H5T_STD_I16LE_g;
    alias H5T_STD_I32BE = H5T_STD_I32BE_g;
    alias H5T_STD_I32LE = H5T_STD_I32LE_g;
    alias H5T_STD_I64BE = H5T_STD_I64BE_g;
    alias H5T_STD_I64LE = H5T_STD_I64LE_g;
    alias H5T_STD_U8BE = H5T_STD_U8BE_g;
    alias H5T_STD_U8LE = H5T_STD_U8LE_g;
    alias H5T_STD_U16BE = H5T_STD_U16BE_g;
    alias H5T_STD_U16LE = H5T_STD_U16LE_g;
    alias H5T_STD_U32BE = H5T_STD_U32BE_g;
    alias H5T_STD_U32LE = H5T_STD_U32LE_g;
    alias H5T_STD_U64BE = H5T_STD_U64BE_g;
    alias H5T_STD_U64LE = H5T_STD_U64LE_g;
    alias H5T_STD_B8BE = H5T_STD_B8BE_g;
    alias H5T_STD_B8LE = H5T_STD_B8LE_g;
    alias H5T_STD_B16BE = H5T_STD_B16BE_g;
    alias H5T_STD_B16LE = H5T_STD_B16LE_g;
    alias H5T_STD_B32BE = H5T_STD_B32BE_g;
    alias H5T_STD_B32LE = H5T_STD_B32LE_g;
    alias H5T_STD_B64BE = H5T_STD_B64BE_g;
    alias H5T_STD_B64LE = H5T_STD_B64LE_g;
    alias H5T_STD_REF_OBJ = H5T_STD_REF_OBJ_g;
    alias H5T_STD_REF_DSETREG = H5T_STD_REF_DSETREG_g;
    extern __gshared hid_t H5T_STD_I8BE_g;
    extern __gshared hid_t H5T_STD_I8LE_g;
    extern __gshared hid_t H5T_STD_I16BE_g;
    extern __gshared hid_t H5T_STD_I16LE_g;
    extern __gshared hid_t H5T_STD_I32BE_g;
    extern __gshared hid_t H5T_STD_I32LE_g;
    extern __gshared hid_t H5T_STD_I64BE_g;
    extern __gshared hid_t H5T_STD_I64LE_g;
    extern __gshared hid_t H5T_STD_U8BE_g;
    extern __gshared hid_t H5T_STD_U8LE_g;
    extern __gshared hid_t H5T_STD_U16BE_g;
    extern __gshared hid_t H5T_STD_U16LE_g;
    extern __gshared hid_t H5T_STD_U32BE_g;
    extern __gshared hid_t H5T_STD_U32LE_g;
    extern __gshared hid_t H5T_STD_U64BE_g;
    extern __gshared hid_t H5T_STD_U64LE_g;
    extern __gshared hid_t H5T_STD_B8BE_g;
    extern __gshared hid_t H5T_STD_B8LE_g;
    extern __gshared hid_t H5T_STD_B16BE_g;
    extern __gshared hid_t H5T_STD_B16LE_g;
    extern __gshared hid_t H5T_STD_B32BE_g;
    extern __gshared hid_t H5T_STD_B32LE_g;
    extern __gshared hid_t H5T_STD_B64BE_g;
    extern __gshared hid_t H5T_STD_B64LE_g;
    extern __gshared hid_t H5T_STD_REF_OBJ_g;
    extern __gshared hid_t H5T_STD_REF_DSETREG_g;

    /*
     * Types which are particular to Unix.
     */
    alias H5T_UNIX_D32BE = H5T_UNIX_D32BE_g;
    alias H5T_UNIX_D32LE = H5T_UNIX_D32LE_g;
    alias H5T_UNIX_D64BE = H5T_UNIX_D64BE_g;
    alias H5T_UNIX_D64LE = H5T_UNIX_D64LE_g;
    extern __gshared hid_t H5T_UNIX_D32BE_g;
    extern __gshared hid_t H5T_UNIX_D32LE_g;
    extern __gshared hid_t H5T_UNIX_D64BE_g;
    extern __gshared hid_t H5T_UNIX_D64LE_g;

    /*
     * Types particular to the C language.  String types use `bytes' instead
     * of `bits' as their size.
     */
    alias H5T_C_S1 = H5T_C_S1_g;
    extern __gshared hid_t H5T_C_S1_g;

    /*
     * Types particular to Fortran.
     */
    alias H5T_FORTRAN_S1 = H5T_FORTRAN_S1_g;
    extern __gshared hid_t H5T_FORTRAN_S1_g;


    /*
     * These types are for Intel CPU's.  They are little endian with IEEE
     * floating point.
     */
    alias H5T_INTEL_I8 = H5T_STD_I8LE;
    alias H5T_INTEL_I16 = H5T_STD_I16LE;
    alias H5T_INTEL_I32 = H5T_STD_I32LE;
    alias H5T_INTEL_I64 = H5T_STD_I64LE;
    alias H5T_INTEL_U8 = H5T_STD_U8LE;
    alias H5T_INTEL_U16 = H5T_STD_U16LE;
    alias H5T_INTEL_U32 = H5T_STD_U32LE;
    alias H5T_INTEL_U64 = H5T_STD_U64LE;
    alias H5T_INTEL_B8 = H5T_STD_B8LE;
    alias H5T_INTEL_B16 = H5T_STD_B16LE;
    alias H5T_INTEL_B32 = H5T_STD_B32LE;
    alias H5T_INTEL_B64 = H5T_STD_B64LE;
    alias H5T_INTEL_F32 = H5T_IEEE_F32LE;
    alias H5T_INTEL_F64 = H5T_IEEE_F64LE;


    /*
     * The VAX floating point types (i.e. in VAX byte order)
     */
    alias H5T_VAX_F32 = H5T_VAX_F32_g;
    alias H5T_VAX_F64 = H5T_VAX_F64_g;
    extern __gshared hid_t H5T_VAX_F32_g;
    extern __gshared hid_t H5T_VAX_F64_g;
    alias H5T_NATIVE_SCHAR = H5T_NATIVE_SCHAR_g;
    alias H5T_NATIVE_UCHAR = H5T_NATIVE_UCHAR_g;
    alias H5T_NATIVE_SHORT = H5T_NATIVE_SHORT_g;
    alias H5T_NATIVE_USHORT = H5T_NATIVE_USHORT_g;
    alias H5T_NATIVE_INT = H5T_NATIVE_INT_g;
    alias H5T_NATIVE_UINT = H5T_NATIVE_UINT_g;
    alias H5T_NATIVE_LONG = H5T_NATIVE_LONG_g;
    alias H5T_NATIVE_ULONG = H5T_NATIVE_ULONG_g;
    alias H5T_NATIVE_LLONG = H5T_NATIVE_LLONG_g;
    alias H5T_NATIVE_ULLONG = H5T_NATIVE_ULLONG_g;
    alias H5T_NATIVE_FLOAT = H5T_NATIVE_FLOAT_g;
    alias H5T_NATIVE_DOUBLE = H5T_NATIVE_DOUBLE_g;
    alias H5T_NATIVE_B8 = H5T_NATIVE_B8_g;
    alias H5T_NATIVE_B16 = H5T_NATIVE_B16_g;
    alias H5T_NATIVE_B32 = H5T_NATIVE_B32_g;
    alias H5T_NATIVE_B64 = H5T_NATIVE_B64_g;
    alias H5T_NATIVE_OPAQUE = H5T_NATIVE_OPAQUE_g;
    alias H5T_NATIVE_HADDR = H5T_NATIVE_HADDR_g;
    alias H5T_NATIVE_HSIZE = H5T_NATIVE_HSIZE_g;
    alias H5T_NATIVE_HSSIZE = H5T_NATIVE_HSSIZE_g;
    alias H5T_NATIVE_HERR = H5T_NATIVE_HERR_g;
    alias H5T_NATIVE_HBOOL = H5T_NATIVE_HBOOL_g;
    extern __gshared hid_t H5T_NATIVE_SCHAR_g;
    extern __gshared hid_t H5T_NATIVE_UCHAR_g;
    extern __gshared hid_t H5T_NATIVE_SHORT_g;
    extern __gshared hid_t H5T_NATIVE_USHORT_g;
    extern __gshared hid_t H5T_NATIVE_INT_g;
    extern __gshared hid_t H5T_NATIVE_UINT_g;
    extern __gshared hid_t H5T_NATIVE_LONG_g;
    extern __gshared hid_t H5T_NATIVE_ULONG_g;
    extern __gshared hid_t H5T_NATIVE_LLONG_g;
    extern __gshared hid_t H5T_NATIVE_ULLONG_g;
    extern __gshared hid_t H5T_NATIVE_FLOAT_g;
    extern __gshared hid_t H5T_NATIVE_DOUBLE_g;
    static if ( H5_SIZEOF_LONG_DOUBLE !=0 ) {
      extern __gshared hid_t H5T_NATIVE_LDOUBLE_g;
    }
    extern __gshared hid_t H5T_NATIVE_B8_g;
    extern __gshared hid_t H5T_NATIVE_B16_g;
    extern __gshared hid_t H5T_NATIVE_B32_g;
    extern __gshared hid_t H5T_NATIVE_B64_g;
    extern __gshared hid_t H5T_NATIVE_OPAQUE_g;
    extern __gshared hid_t H5T_NATIVE_HADDR_g;
    extern __gshared hid_t H5T_NATIVE_HSIZE_g;
    extern __gshared hid_t H5T_NATIVE_HSSIZE_g;
    extern __gshared hid_t H5T_NATIVE_HERR_g;
    extern __gshared hid_t H5T_NATIVE_HBOOL_g;

    /* C9x integer types */
    alias H5T_NATIVE_INT8 = H5T_NATIVE_INT8_g;
    alias H5T_NATIVE_UINT8 = H5T_NATIVE_UINT8_g;
    alias H5T_NATIVE_INT_LEAST8 = H5T_NATIVE_INT_LEAST8_g;
    alias H5T_NATIVE_UINT_LEAST8 = H5T_NATIVE_UINT_LEAST8_g;
    alias H5T_NATIVE_INT_FAST8 = H5T_NATIVE_INT_FAST8_g;
    alias H5T_NATIVE_UINT_FAST8 = H5T_NATIVE_UINT_FAST8_g;
    extern __gshared hid_t H5T_NATIVE_INT8_g;
    extern __gshared hid_t H5T_NATIVE_UINT8_g;
    extern __gshared hid_t H5T_NATIVE_INT_LEAST8_g;
    extern __gshared hid_t H5T_NATIVE_UINT_LEAST8_g;
    extern __gshared hid_t H5T_NATIVE_INT_FAST8_g;
    extern __gshared hid_t H5T_NATIVE_UINT_FAST8_g;

    alias H5T_NATIVE_INT16 = H5T_NATIVE_INT16_g;
    alias H5T_NATIVE_UINT16 = H5T_NATIVE_UINT16_g;
    alias H5T_NATIVE_INT_LEAST16 = H5T_NATIVE_INT_LEAST16_g;
    alias H5T_NATIVE_UINT_LEAST16 = H5T_NATIVE_UINT_LEAST16_g;
    alias H5T_NATIVE_INT_FAST16 = H5T_NATIVE_INT_FAST16_g;
    alias H5T_NATIVE_UINT_FAST16 = H5T_NATIVE_UINT_FAST16_g;
    extern __gshared hid_t H5T_NATIVE_INT16_g;
    extern __gshared hid_t H5T_NATIVE_UINT16_g;
    extern __gshared hid_t H5T_NATIVE_INT_LEAST16_g;
    extern __gshared hid_t H5T_NATIVE_UINT_LEAST16_g;
    extern __gshared hid_t H5T_NATIVE_INT_FAST16_g;
    extern __gshared hid_t H5T_NATIVE_UINT_FAST16_g;

    alias H5T_NATIVE_INT32 = H5T_NATIVE_INT32_g;
    alias H5T_NATIVE_UINT32 = H5T_NATIVE_UINT32_g;
    alias H5T_NATIVE_INT_LEAST32 = H5T_NATIVE_INT_LEAST32_g;
    alias H5T_NATIVE_UINT_LEAST32 = H5T_NATIVE_UINT_LEAST32_g;
    alias H5T_NATIVE_INT_FAST32 = H5T_NATIVE_INT_FAST32_g;
    alias H5T_NATIVE_UINT_FAST32 = H5T_NATIVE_UINT_FAST32_g;
    extern __gshared hid_t H5T_NATIVE_INT32_g;
    extern __gshared hid_t H5T_NATIVE_UINT32_g;
    extern __gshared hid_t H5T_NATIVE_INT_LEAST32_g;
    extern __gshared hid_t H5T_NATIVE_UINT_LEAST32_g;
    extern __gshared hid_t H5T_NATIVE_INT_FAST32_g;
    extern __gshared hid_t H5T_NATIVE_UINT_FAST32_g;

    alias H5T_NATIVE_INT64 = H5T_NATIVE_INT64_g;
    alias H5T_NATIVE_UINT64 = H5T_NATIVE_UINT64_g;
    alias H5T_NATIVE_INT_LEAST64 = H5T_NATIVE_INT_LEAST64_g;
    alias H5T_NATIVE_UINT_LEAST64 = H5T_NATIVE_UINT_LEAST64_g;
    alias H5T_NATIVE_INT_FAST64 = H5T_NATIVE_INT_FAST64_g;
    alias H5T_NATIVE_UINT_FAST64 = H5T_NATIVE_UINT_FAST64_g;
    extern __gshared hid_t H5T_NATIVE_INT64_g;
    extern __gshared hid_t H5T_NATIVE_UINT64_g;
    extern __gshared hid_t H5T_NATIVE_INT_LEAST64_g;
    extern __gshared hid_t H5T_NATIVE_UINT_LEAST64_g;
    extern __gshared hid_t H5T_NATIVE_INT_FAST64_g;
    extern __gshared hid_t H5T_NATIVE_UINT_FAST64_g;

    version(Posix) {

    /* Operations defined on all datatypes */
    hid_t H5Tcreate(H5TClass type, size_t size);
    hid_t H5Tcopy(hid_t type_id);
    herr_t H5Tclose(hid_t type_id);
    htri_t H5Tequal(hid_t type1_id, hid_t type2_id);
    herr_t H5Tlock(hid_t type_id);
    herr_t H5Tcommit2(hid_t loc_id, const char *name, hid_t type_id,
        hid_t lcpl_id, hid_t tcpl_id, hid_t tapl_id);
    hid_t H5Topen2(hid_t loc_id, const char *name, hid_t tapl_id);
    herr_t H5Tcommit_anon(hid_t loc_id, hid_t type_id, hid_t tcpl_id, hid_t tapl_id);
    hid_t H5Tget_create_plist(hid_t type_id);
    htri_t H5Tcommitted(hid_t type_id);
    herr_t H5Tencode(hid_t obj_id, void *buf, size_t *nalloc);
    hid_t H5Tdecode(const void *buf);

    /* Operations defined on compound datatypes */
    herr_t H5Tinsert(hid_t parent_id, const char *name, size_t offset,
                 hid_t member_id);
    herr_t H5Tpack(hid_t type_id);

    /* Operations defined on enumeration datatypes */
    hid_t H5Tenum_create(hid_t base_id);
    herr_t H5Tenum_insert(hid_t type, const char *name, const void *value);
    herr_t H5Tenum_nameof(hid_t type, const void *value, char *name/*out*/,
                     size_t size);
    herr_t H5Tenum_valueof(hid_t type, const char *name,
                      void *value/*out*/);

    /* Operations defined on variable-length datatypes */
    hid_t H5Tvlen_create(hid_t base_id);

    /* Operations defined on array datatypes */
    hid_t H5Tarray_create2(hid_t base_id, uint ndims,
                const hsize_t dim[/* ndims */]);
    int H5Tget_array_ndims(hid_t type_id);
    int H5Tget_array_dims2(hid_t type_id, hsize_t* dims);

    /* Operations defined on opaque datatypes */
    herr_t H5Tset_tag(hid_t type, const char *tag);
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
    int H5Tget_member_index(hid_t type_id, const char *name);
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
    herr_t H5Tregister(H5T_pers_t pers, const char *name, hid_t src_id,
                   hid_t dst_id, H5T_conv_t func);
    herr_t H5Tunregister(H5T_pers_t pers, const char *name, hid_t src_id,
                     hid_t dst_id, H5T_conv_t func);
    H5T_conv_t H5Tfind(hid_t src_id, hid_t dst_id, H5T_cdata_t **pcdata);
    htri_t H5Tcompiler_conv(hid_t src_id, hid_t dst_id);
    herr_t H5Tconvert(hid_t src_id, hid_t dst_id, size_t nelmts,
                  void *buf, void *background, hid_t plist_id);
    }
}

// alias H5ZFilter = int;

/* Filter IDs */
enum H5ZFilter
{
  Error       = (-1), /*no filter         */
  None        = 0,    /*reserved indefinitely     */
  Deflate     = 1,    /*deflation like gzip           */
  Shuffle     = 2,       /*shuffle the data              */
  Fletcher32  = 3,       /*fletcher32 checksum of EDC    */
  SZip        = 4,       /*szip compression              */
  NBit        = 5,       /*nbit compression              */
  ScaleOffset = 6,      /*scale+offset compression      */
  Reserved    = 256,  /*filter ids below this value are reserved for library use */
  Max         = 65535,    /*maximum filter id     */
  All         = 0,      /* Symbol to remove all filters in H5Premove_filter */
}

enum H5Z_MAX_NFILTERS       = 32;      /* Maximum number of filters allowed in a pipeline */
                                        /* (should probably be allowed to be an
                                         * unlimited amount, but currently each
                                         * filter uses a bit in a 32-bit field,
                                         * so the format would have to be
                                         * changed to accomodate that)
                                         */

/* Flags for filter definition (stored) */
enum H5Z_FLAG_DEFMASK        = 0x00ff;  /*definition flag mask      */
enum H5Z_FLAG_MANDATORY      = 0x0000;  /*filter is mandatory       */
enum H5Z_FLAG_OPTIONAL       = 0x0001; /*filter is optional     */

/* Additional flags for filter invocation (not stored) */
enum H5Z_FLAG_INVMASK        = 0xff00; /*invocation flag mask       */
enum H5Z_FLAG_REVERSE        = 0x0100; /*reverse direction; read    */
enum H5Z_FLAG_SKIP_EDC       = 0x0200; /*skip EDC filters for read  */

/* Special parameters for szip compression */
/* [These are aliases for the similar definitions in szlib.h, which we can't
 * include directly due to the duplication of various symbols with the zlib.h
 * header file] */
enum H5_SZIP_ALLOW_K13_OPTION_MASK = 1;
enum H5_SZIP_CHIP_OPTION_MASK      = 2;
enum H5_SZIP_EC_OPTION_MASK        = 4;
enum H5_SZIP_NN_OPTION_MASK        = 32;
enum H5_SZIP_MAX_PIXELS_PER_BLOCK  = 32;

/* Macros for the shuffle filter */
enum H5Z_SHUFFLE_USER_NPARMS  = 0;    /* Number of parameters that users can set */
enum H5Z_SHUFFLE_TOTAL_NPARMS = 1;    /* Total number of parameters for filter */

/* Macros for the szip filter */
enum H5Z_SZIP_USER_NPARMS  = 2;       /* Number of parameters that users can set */
enum H5Z_SZIP_TOTAL_NPARMS = 4;       /* Total number of parameters for filter */
enum H5Z_SZIP_PARM_MASK    = 0;       /* "User" parameter for option mask */
enum H5Z_SZIP_PARM_PPB     = 1;       /* "User" parameter for pixels-per-block */
enum H5Z_SZIP_PARM_BPP     = 2;       /* "Local" parameter for bits-per-pixel */
enum H5Z_SZIP_PARM_PPS     = 3;       /* "Local" parameter for pixels-per-scanline */

/* Macros for the nbit filter */
enum H5Z_NBIT_USER_NPARMS = 0;     /* Number of parameters that users can set */

/* Macros for the scale offset filter */
enum H5Z_SCALEOFFSET_USER_NPARMS = 2;    /* Number of parameters that users can set */

/* Special parameters for ScaleOffset filter*/
enum H5Z_SO_INT_MINBITS_DEFAULT = 0;
enum H5Z_SO_scale_type_t {
    H5Z_SO_FLOAT_DSCALE = 0,
    H5Z_SO_FLOAT_ESCALE = 1,
    H5Z_SO_INT          = 2
}

/* Current version of the H5Z_class_t struct */
enum H5Z_CLASS_T_VERS = (1);

/* Values to decide if EDC is enabled for reading data */
enum H5Z_EDC_t {
    H5Z_ERROR_EDC       = -1,   /* error value */
    H5Z_DISABLE_EDC     = 0,
    H5Z_ENABLE_EDC      = 1,
    H5Z_NO_EDC          = 2     /* must be the last */
}

/* Bit flags for H5Zget_filter_info */
enum H5Z_FILTER_CONFIG_ENCODE_ENABLED = (0x0001);
enum H5Z_FILTER_CONFIG_DECODE_ENABLED = (0x0002);

/* Return values for filter callback function */
enum H5Z_cb_return_t {
    H5Z_CB_ERROR  = -1,
    H5Z_CB_FAIL   = 0,    /* I/O should fail if filter fails. */
    H5Z_CB_CONT   = 1,    /* I/O continues if filter fails.   */
    H5Z_CB_NO     = 2
}

extern(C)
{
    /* Filter callback function definition */
    alias H5Z_filter_func_t = H5Z_cb_return_t function(H5ZFilter filter, void* buf,
                                    size_t buf_size, void* op_data);

    /* Structure for filter callback property */
        struct H5Z_cb_t {
          H5Z_filter_func_t func;
          void*              op_data;
       }
    alias H5Z_can_apply_func_t = htri_t function(hid_t dcpl_id, hid_t type_id, hid_t space_id);
    alias H5Z_set_local_func_t = herr_t function(hid_t dcpl_id, hid_t type_id, hid_t space_id);
    alias H5Z_func_t = size_t function(uint flags, size_t cd_nelmts, const uint* cd_values, size_t nbytes, size_t *buf_size, void **buf);

      struct H5Z_class2_t {
        int _version;                /* Version number of the H5Z_class_t struct */
        H5ZFilter id;        /* Filter ID number              */
        int encoder_present;   /* Does this filter have an encoder? */
        int decoder_present;   /* Does this filter have a decoder? */
        const char  *name;      /* Comment for debugging             */
        H5Z_can_apply_func_t can_apply; /* The "can apply" callback for a filter */
        H5Z_set_local_func_t set_local; /* The "set local" callback for a filter */
        H5Z_func_t filter;      /* The actual filter function            */
      }

    herr_t H5Zregister(const void *cls);
    herr_t H5Zunregister(H5ZFilter id);
    htri_t H5Zfilter_avail(H5ZFilter id);
    herr_t H5Zget_filter_info(H5ZFilter filter, uint *filter_config_flags);
}


alias MPI_Datatype = int;
alias MPI_Comm = int;
alias MPI_Info = int;
enum MPI_LONG_LONG_INT = cast(MPI_Datatype) 0x4c000809;
enum H5_CLEAR_MEMORY = 1;
enum H5_CONVERT_DENORMAL_FLOAT = 1;
enum H5_DEFAULT_PLUGINDIR = "/usr/local/hdf5/lib/plugin";
enum H5_DEV_T_IS_SCALAR = 1;
enum H5_FP_TO_INTEGER_OVERFLOW_WORKS = 1;
enum H5_FP_TO_ULLONG_ACCURATE = 1;
enum H5_FP_TO_ULLONG_RIGHT_MAXIMUM = 1;
enum H5_GETTIMEOFDAY_GIVES_TZ = 1;
enum H5_HAVE_ALARM = 1;
enum H5_HAVE_ATTRIBUTE = 1;
enum H5_HAVE_C99_DESIGNATED_INITIALIZER = 1;
enum H5_HAVE_C99_FUNC = 1;
enum H5_HAVE_CLOCK_GETTIME = 1;
enum H5_HAVE_DIFFTIME = 1;
enum H5_HAVE_DIRENT_H = 1;
enum H5_HAVE_DLFCN_H = 1;
enum H5_HAVE_EMBEDDED_LIBINFO = 1;
enum H5_HAVE_FEATURES_H = 1;
enum H5_HAVE_FILTER_DEFLATE = 1;
enum H5_HAVE_FILTER_FLETCHER32 = 1;
enum H5_HAVE_FILTER_NBIT = 1;
enum H5_HAVE_FILTER_SCALEOFFSET = 1;
enum H5_HAVE_FILTER_SHUFFLE = 1;
enum H5_HAVE_FORK = 1;
enum H5_HAVE_FREXPF = 1;
enum H5_HAVE_FREXPL = 1;
enum H5_HAVE_FSEEKO = 1;
enum H5_HAVE_FSEEKO64 = 1;
enum H5_HAVE_FSTAT64 = 1;
enum H5_HAVE_FTELLO = 1;
enum H5_HAVE_FTELLO64 = 1;
enum H5_HAVE_FTRUNCATE64 = 1;
enum H5_HAVE_FUNCTION = 1;
enum H5_HAVE_GETHOSTNAME = 1;
enum H5_HAVE_GETPWUID = 1;
enum H5_HAVE_GETRUSAGE = 1;
enum H5_HAVE_GETTIMEOFDAY = 1;
enum H5_HAVE_INTTYPES_H = 1;
enum H5_HAVE_IOCTL = 1;
enum H5_HAVE_LIBDL = 1;
enum H5_HAVE_LIBM = 1;
enum H5_HAVE_LIBZ = 1;
enum H5_HAVE_LONGJMP = 1;
enum H5_HAVE_LSEEK64 = 1;
enum H5_HAVE_LSTAT = 1;
enum H5_HAVE_MEMORY_H = 1;
enum H5_HAVE_MPI_GET_SIZE = 1;
enum H5_HAVE_MPI_MULTI_LANG_Comm = 1;
enum H5_HAVE_MPI_MULTI_LANG_Info = 1;
enum H5_HAVE_PARALLEL = 1;
enum H5_HAVE_RANDOM = 1;
enum H5_HAVE_RAND_R = 1;
enum H5_HAVE_SETJMP = 1;
enum H5_HAVE_SETJMP_H = 1;
enum H5_HAVE_SIGLONGJMP = 1;
enum H5_HAVE_SIGNAL = 1;
enum H5_HAVE_SIGPROCMASK = 1;
enum H5_HAVE_SNPRINTF = 1;
enum H5_HAVE_SRANDOM = 1;
enum H5_HAVE_STAT64 = 1;
enum H5_HAVE_STAT_ST_BLOCKS = 1;
enum H5_HAVE_STDDEF_H = 1;
enum H5_HAVE_STDINT_H = 1;
enum H5_HAVE_STDLIB_H = 1;
enum H5_HAVE_STRDUP = 1;
enum H5_HAVE_STRINGS_H = 1;
enum H5_HAVE_STRING_H = 1;
enum H5_HAVE_STRUCT_TIMEZONE = 1;
enum H5_HAVE_STRUCT_TM_TM_ZONE = 1;
enum H5_HAVE_SYMLINK = 1;
enum H5_HAVE_SYSTEM = 1;
enum H5_HAVE_SYS_IOCTL_H = 1;
enum H5_HAVE_SYS_RESOURCE_H = 1;
enum H5_HAVE_SYS_SOCKET_H = 1;
enum H5_HAVE_SYS_STAT_H = 1;
enum H5_HAVE_SYS_TIMEB_H = 1;
enum H5_HAVE_SYS_TIME_H = 1;
enum H5_HAVE_SYS_TYPES_H = 1;
enum H5_HAVE_TIOCGETD = 1;
enum H5_HAVE_TIOCGWINSZ = 1;
enum H5_HAVE_TMPFILE = 1;
enum H5_HAVE_TM_GMTOFF = 1;
enum H5_HAVE_TM_ZONE = 1;
enum H5_HAVE_UNISTD_H = 1;
enum H5_HAVE_VASPRINTF = 1;
enum H5_HAVE_VSNPRINTF = 1;
enum H5_HAVE_WAITPID = 1;
enum H5_HAVE_ZLIB_H = 1;
enum H5_INCLUDE_HL = 1;
enum H5_INTEGER_TO_LDOUBLE_ACCURATE = 1;
enum H5_LDOUBLE_TO_INTEGER_ACCURATE = 1;
enum H5_LDOUBLE_TO_INTEGER_WORKS = 1;
enum H5_LDOUBLE_TO_LLONG_ACCURATE = 1;
enum H5_LDOUBLE_TO_UINT_ACCURATE = 1;
enum H5_LLONG_TO_FP_CAST_WORKS = 1;
enum H5_LLONG_TO_LDOUBLE_CORRECT = 1;
enum H5_LT_OBJDIR = ".libs/";
enum H5_MPI_FILE_SET_SIZE_BIG = 1;
enum H5_NO_ALIGNMENT_RESTRICTIONS = 1;
enum H5_PACKAGE = "hdf5";
enum H5_PACKAGE_BUGREPORT = "help@hdfgroup.org";
enum H5_PACKAGE_NAME = "HDF5";
enum H5_PACKAGE_STRING = "HDF5 1.8.13";
enum H5_PACKAGE_TARNAME = "hdf5";
enum H5_PACKAGE_URL = "";
enum H5_PACKAGE_VERSION = "1.8.13";
enum H5_PRINTF_LL_WIDTH = "l";
enum H5_SIZEOF_CHAR = 1;
enum H5_SIZEOF_DOUBLE = 8;
enum H5_SIZEOF_FLOAT = 4;
enum H5_SIZEOF_INT = 4;
enum H5_SIZEOF_INT16_T = 2;
enum H5_SIZEOF_INT32_T = 4;
enum H5_SIZEOF_INT64_T = 8;
enum H5_SIZEOF_INT8_T = 1;
enum H5_SIZEOF_INT_FAST16_T = 8;
enum H5_SIZEOF_INT_FAST32_T = 8;
enum H5_SIZEOF_INT_FAST64_T = 8;
enum H5_SIZEOF_INT_FAST8_T = 1;
enum H5_SIZEOF_INT_LEAST16_T = 2;
enum H5_SIZEOF_INT_LEAST32_T = 4;
enum H5_SIZEOF_INT_LEAST64_T = 8;
enum H5_SIZEOF_INT_LEAST8_T = 1;
enum H5_SIZEOF_LONG = 8;
enum H5_SIZEOF_LONG_DOUBLE = 16;
enum H5_SIZEOF_LONG_LONG = 8;
enum H5_SIZEOF_OFF64_T = 8;
enum H5_SIZEOF_OFF_T = 8;
enum H5_SIZEOF_PTRDIFF_T = 8;
enum H5_SIZEOF_SHORT = 2;
enum H5_SIZEOF_SIZE_T = 8;
enum H5_SIZEOF_SSIZE_T = 8;
enum H5_SIZEOF_UINT16_T = 2;
enum H5_SIZEOF_UINT32_T = 4;
enum H5_SIZEOF_UINT64_T = 8;
enum H5_SIZEOF_UINT8_T = 1;
enum H5_SIZEOF_UINT_FAST16_T = 8;
enum H5_SIZEOF_UINT_FAST32_T = 8;
enum H5_SIZEOF_UINT_FAST64_T = 8;
enum H5_SIZEOF_UINT_FAST8_T = 1;
enum H5_SIZEOF_UINT_LEAST16_T = 2;
enum H5_SIZEOF_UINT_LEAST32_T = 4;
enum H5_SIZEOF_UINT_LEAST64_T = 8;
enum H5_SIZEOF_UINT_LEAST8_T = 1;
enum H5_SIZEOF_UNSIGNED = 4;
enum H5_SIZEOF___INT64 = 0;
enum H5_STDC_HEADERS = 1;
enum H5_SYSTEM_SCOPE_THREADS = 1;
enum H5_TIME_WITH_SYS_TIME = 1;
enum H5_ULLONG_TO_FP_CAST_WORKS = 1;
enum H5_ULLONG_TO_LDOUBLE_PRECISION = 1;
enum H5_ULONG_TO_FLOAT_ACCURATE = 1;
enum H5_ULONG_TO_FP_BOTTOM_BIT_ACCURATE = 1;
enum H5_VERSION = "1.8.13";
enum H5_VSNPRINTF_WORKS = 1;
enum H5_WANT_DATA_ACCURACY = 1;
enum H5_WANT_DCONV_EXCEPTION = 1;
enum WORDS_BIGENDIAN = 0;

