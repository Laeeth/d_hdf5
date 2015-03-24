/**
   Ported to the D Programming Language by Laeeth Isharc 2014
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

import hdf5;
import std.stdio;
import std.string;
import std.file;
//#include "H5private.h"    /* Generic Functions      */
//#include "h5tools.h"
//#include "h5tools_utils.h"
//#include "h5tools_ref.h"
//#include "h5trav.h"

/* Name of tool */
enum  PROGRAMNAME ="h5stat";

/* Parameters to control statistics gathered */

/* Default threshold for small groups/datasets/attributes */
enum  DEF_SIZE_SMALL_GROUPS =      	10;
enum  DEF_SIZE_SMALL_DSETS   =     	10;
enum  DEF_SIZE_SMALL_ATTRS  =		10;

enum   H5_NFILTERS_IMPL        =8;     /* Number of currently implemented filters + one to
                                          accommodate for user-define filters + one
                                          to accomodate datasets whithout any filters */



/* Datatype statistics for datasets */
struct dtype_info_t {
    hid_t tid;                          /* ID of datatype */
    ulong  count;                /* Number of types found */
    ulong  named;                /* Number of types that are named */
}

struct ohdr_info_t {
    hsize_t total_size;                 /* Total size of object headers */
    hsize_t free_size;                  /* Total free space in object headers */
}

/* Info to pass to the iteration functions */
struct iter_t {
    hid_t fid;                          /* File ID */
    hsize_t filesize;      /* Size of the file */
    ulong  uniq_groups;          /* Number of unique groups */
    ulong  uniq_dsets;           /* Number of unique datasets */
    ulong  uniq_dtypes;          /* Number of unique named datatypes */
    ulong  uniq_links;           /* Number of unique links */
    ulong  uniq_others;          /* Number of other unique objects */

    ulong  max_links;            /* Maximum # of links to an object */
    hsize_t max_fanout;                 /* Maximum fanout from a group */
    ulong  *num_small_groups;    /* Size of small groups tracked */
    uint  group_nbins;               /* Number of bins for group counts */
    ulong  *group_bins;          /* Pointer to array of bins for group counts */
    ohdr_info_t group_ohdr_info;        /* Object header information for groups */

    hsize_t  max_attrs;                 /* Maximum attributes from a group */
    ulong  *num_small_attrs;    	/* Size of small attributes tracked */
    uint  attr_nbins;                /* Number of bins for attribute counts */
    ulong  *attr_bins;           /* Pointer to array of bins for attribute counts */

    uint  max_dset_rank;             /* Maximum rank of dataset */
    ulong  dset_rank_count[H5S_MAX_RANK];   /* Number of datasets of each rank */
    hsize_t max_dset_dims;              /* Maximum dimension size of dataset */
    ulong  *small_dset_dims;    /* Size of dimensions of small datasets tracked */
    ulong  dset_layouts[H5D_NLAYOUTS];           /* Type of storage for each dataset */
    ulong  dset_comptype[H5_NFILTERS_IMPL]; 	/* Number of currently implemented filters */
    ulong  dset_ntypes;          /* Number of diff. dataset datatypes found */
    dtype_info_t *dset_type_info;       /* Pointer to dataset datatype information found */
    uint  dset_dim_nbins;            /* Number of bins for dataset dimensions */
    ulong  *dset_dim_bins;       /* Pointer to array of bins for dataset dimensions */
    ohdr_info_t dset_ohdr_info;         /* Object header information for datasets */
    hsize_t dset_storage_size;          /* Size of raw data for datasets */
    hsize_t dset_external_storage_size; /* Size of raw data for datasets with external storage */
    ohdr_info_t dtype_ohdr_info;        /* Object header information for datatypes */
    hsize_t groups_btree_storage_size;  /* btree size for group */
    hsize_t groups_heap_storage_size;   /* heap size for group */
    hsize_t attrs_btree_storage_size;   /* btree size for attributes (1.8) */
    hsize_t attrs_heap_storage_size;    /* fractal heap size for attributes (1.8) */
    hsize_t SM_hdr_storage_size;        /* header size for SOHM table (1.8) */
    hsize_t SM_index_storage_size;      /* index (btree & list) size for SOHM table (1.8) */
    hsize_t SM_heap_storage_size;       /* fractal heap size for SOHM table (1.8) */
    hsize_t super_ext_size;             /* superblock extension size */
    hsize_t ublk_size;                  /* user block size (if exists) */
    hsize_t datasets_index_storage_size;/* meta size for chunked dataset's indexing type */
    hsize_t datasets_heap_storage_size; /* heap size for dataset with external storage */
    ulong  nexternal;            /* Number of external files for a dataset */
    int           local;                /* Flag to indicate iteration over the object*/
}


static int        display_all = true ;

/* Enable the printing of selected statistics */
static int        display_file = false ;     /* display file information */
static int        display_group = false ;    /* display groups information */
static int        display_dset = false ;     /* display datasets information */
static int        display_dset_dtype_meta = false ;  /* display datasets' datatype information */
static int        display_attr = false ;     /* display attributes information */
static int        display_summary = false ;  /* display summary of file space information */

static int        display_file_metadata = false ;    /* display file space info for file's metadata */
static int        display_group_metadata = false ;   /* display file space info for groups' metadata */
static int        display_dset_metadata = false ;    /* display file space info for datasets' metadata */

static int        display_object = false ;  /* not implemented yet */

/* Initialize threshold for small groups/datasets/attributes */
static int	  sgroups_threshold = DEF_SIZE_SMALL_GROUPS;
static int	  sdsets_threshold = DEF_SIZE_SMALL_DSETS;
static int	  sattrs_threshold = DEF_SIZE_SMALL_ATTRS;

/* a structure for handling the order command-line parameters come in */
struct handler_t {
    size_t obj_count;
    char **obj;
};

static const char *s_opts ="Aa:Ddm:FfhGgl:STO:V";
/* e.g. "filemetadata" has to precede "file"; "groupmetadata" has to precede "group" etc. */
struct long_options {
    const char  *name;          /* name of the long option              */
    int          has_arg;       /* whether we should look for an arg    */
    char         shortval;      /* the shortname equivalent of long arg
                                 * this gets returned from get_option   */
}
static long_options[] l_opts = [
    ["help", no_arg, 'h'],
    ["hel", no_arg, 'h'],
    ["he", no_arg, 'h'],
    ["filemetadata", no_arg, 'F'],
    ["filemetadat", no_arg, 'F'],
    ["filemetada", no_arg, 'F'],
    ["filemetad", no_arg, 'F'],
    ["filemeta", no_arg, 'F'],
    ["filemet", no_arg, 'F'],
    ["fileme", no_arg, 'F'],
    ["filem", no_arg, 'F'],
    ["file", no_arg, 'f'],
    ["fil", no_arg, 'f'],
    ["fi", no_arg, 'f'],
    ["groupmetadata", no_arg, 'G'],
    ["groupmetadat", no_arg, 'G'],
    ["groupmetada", no_arg, 'G'],
    ["groupmetad", no_arg, 'G'],
    ["groupmeta", no_arg, 'G'],
    ["groupmet", no_arg, 'G'],
    ["groupme", no_arg, 'G'],
    ["groupm", no_arg, 'G'],
    ["group", no_arg, 'g'],
    ["grou", no_arg, 'g'],
    ["gro", no_arg, 'g'],
    ["gr", no_arg, 'g'],
    [ "links", require_arg, 'l' ],
    [ "link", require_arg, 'l' ],
    [ "lin", require_arg, 'l' ],
    [ "li", require_arg, 'l' ],
    ["dsetmetadata", no_arg, 'D'],
    ["dsetmetadat", no_arg, 'D'],
    ["dsetmetada", no_arg, 'D'],
    ["dsetmetad", no_arg, 'D'],
    ["dsetmeta", no_arg, 'D'],
    ["dsetmet", no_arg, 'D'],
    ["dsetme", no_arg, 'D'],
    ["dsetm", no_arg, 'D'],
    ["dset", no_arg, 'd'],
    ["dse", no_arg, 'd'],
    ["ds", no_arg, 'd'],
    ["dims", require_arg, 'm'],
    ["dim", require_arg, 'm'],
    ["di", require_arg, 'm'],
    ["dtypemetadata", no_arg, 'T'],
    ["dtypemetadat", no_arg, 'T'],
    ["dtypemetada", no_arg, 'T'],
    ["dtypemetad", no_arg, 'T'],
    ["dtypemeta", no_arg, 'T'],
    ["dtypemet", no_arg, 'T'],
    ["dtypeme", no_arg, 'T'],
    ["dtypem", no_arg, 'T'],
    ["dtype", no_arg, 'T'],
    ["dtyp", no_arg, 'T'],
    ["dty", no_arg, 'T'],
    ["dt", no_arg, 'T'],
    [ "object", require_arg, 'O' ],
    [ "objec", require_arg, 'O' ],
    [ "obje", require_arg, 'O' ],
    [ "obj", require_arg, 'O' ],
    [ "ob", require_arg, 'O' ],
    [ "version", no_arg, 'V' ],
    [ "versio", no_arg, 'V' ],
    [ "versi", no_arg, 'V' ],
    [ "vers", no_arg, 'V' ],
    [ "ver", no_arg, 'V' ],
    [ "ve", no_arg, 'V' ],
    [ "attribute", no_arg, 'A' ],
    [ "attribut", no_arg, 'A' ],
    [ "attribu", no_arg, 'A' ],
    [ "attrib", no_arg, 'A' ],
    [ "attri", no_arg, 'A' ],
    [ "attr", no_arg, 'A' ],
    [ "att", no_arg, 'A' ],
    [ "at", no_arg, 'A' ],
    [ "numattrs", require_arg, 'a' ],
    [ "numattr", require_arg, 'a' ],
    [ "numatt", require_arg, 'a' ],
    [ "numat", require_arg, 'a' ],
    [ "numa", require_arg, 'a' ],
    [ "num", require_arg, 'a' ],
    [ "nu", require_arg, 'a' ],
    [ "summary", no_arg, 'S' ],
    [ "summar", no_arg, 'S' ],
    [ "summa", no_arg, 'S' ],
    [ "summ", no_arg, 'S' ],
    [ "sum", no_arg, 'S' ],
    [ "su", no_arg, 'S' ],
    [ NULL, 0, '\0' ]
];

static void
leave(int ret)
{
   h5tools_close();
   HDexit(ret);
}



/*-------------------------------------------------------------------------
 * Function: usage
 *
 * Purpose: Compute the ceiling of log_10(x)
 *
 * Return: >0 on success, 0 on failure
 *
 *-------------------------------------------------------------------------
 */
static void usage(const char *prog)
{
     HDfflush(stdout);
     HDfprintf(stdout, "Usage: %s [OPTIONS] file\n", prog);
     HDfprintf(stdout, "\n");
     HDfprintf(stdout, "      OPTIONS\n");
     HDfprintf(stdout, "     -h, --help            Print a usage message and exit\n");
     HDfprintf(stdout, "     -V, --version         Print version number and exit\n");
     HDfprintf(stdout, "     -f, --file            Print file information\n");
     HDfprintf(stdout, "     -F, --filemetadata    Print file space information for file's metadata\n");
     HDfprintf(stdout, "     -g, --group           Print group information\n");
     HDfprintf(stdout, "     -l N, --links=N       Set the threshold for the # of links when printing\n");
     HDfprintf(stdout, "                           information for small groups.  N is an integer greater\n");
     HDfprintf(stdout, "                           than 0.  The default threshold is 10.\n");
     HDfprintf(stdout, "     -G, --groupmetadata   Print file space information for groups' metadata\n");
     HDfprintf(stdout, "     -d, --dset            Print dataset information\n");
     HDfprintf(stdout, "     -m N, --dims=N        Set the threshold for the dimension sizes when printing\n");
     HDfprintf(stdout, "                           information for small datasets.  N is an integer greater\n");
     HDfprintf(stdout, "                           than 0.  The default threshold is 10.\n");
     HDfprintf(stdout, "     -D, --dsetmetadata    Print file space information for datasets' metadata\n");
     HDfprintf(stdout, "     -T, --dtypemetadata   Print datasets' datatype information\n");
     HDfprintf(stdout, "     -A, --attribute       Print attribute information\n");
     HDfprintf(stdout, "     -a N, --numattrs=N    Set the threshold for the # of attributes when printing\n");
     HDfprintf(stdout, "                           information for small # of attributes.  N is an integer greater\n");
     HDfprintf(stdout, "                           than 0.  The default threshold is 10.\n");
     HDfprintf(stdout, "     -S, --summary         Print summary of file space information\n");
}


/*-------------------------------------------------------------------------
 * Function: ceil_log10
 *
 * Purpose: Compute the ceiling of log_10(x)
 *
 * Return: >0 on success, 0 on failure
 *
 * Programmer: Quincey Koziol
 *              Monday, August 22, 2005
 *
 *-------------------------------------------------------------------------
 */
static uint 
ceil_log10(ulong  x)
{
    ulong  pow10 = 1;
    uint  ret = 0;

    while(x >= pow10) {
        pow10 *= 10;
        ret++;
    } /* end while */

    return(ret);
} /* ceil_log10() */


/*-------------------------------------------------------------------------
 * Function: attribute_stats
 *
 * Purpose: Gather statistics about attributes on an object
 *
 * Return:  Success: 0
 *
 *          Failure: -1
 *
 * Programmer:    Quincey Koziol
 *                Tuesday, July 17, 2007
 *
 *-------------------------------------------------------------------------
 */
static herr_t
attribute_stats(iter_t *iter, const H5O_info_t *oi)
{
    uint      bin;               /* "bin" the number of objects falls in */

    /* Update dataset & attribute metadata info */
    iter.attrs_btree_storage_size += oi.meta_size.attr.index_size;
    iter.attrs_heap_storage_size += oi.meta_size.attr.heap_size;

    /* Update small # of attribute count & limits */
    if(oi.num_attrs <= cast(hsize_t)sattrs_threshold)
        (iter.num_small_attrs[cast(size_t)oi.num_attrs])+=1;
    if(oi.num_attrs > iter.max_attrs)
        iter.max_attrs = oi.num_attrs;

    /* Add attribute count to proper bin */
    bin = ceil_log10(cast(ulong)oi.num_attrs);
    if((bin + 1) > iter.attr_nbins) {
  iter.attr_bins = cast(ulong *)HDrealloc(iter.attr_bins, (bin + 1) * ulong.sizeof);
        HDassert(iter.attr_bins);

  /* Initialize counts for intermediate bins */
        while(iter.attr_nbins < bin)
      iter.attr_bins[iter.attr_nbins++] = 0;
        iter.attr_nbins++;

        /* Initialize count for new bin */
        iter.attr_bins[bin] = 1;
     } /* end if */
     else
         (iter.attr_bins[bin])+=1;

     return 0;
} /* end attribute_stats() */


/*-------------------------------------------------------------------------
 * Function: group_stats
 *
 * Purpose: Gather statistics about the group
 *
 * Return: Success: 0
 *
 *  Failure: -1
 *
 * Programmer: Quincey Koziol
 *             Tuesday, August 16, 2005
 *
 * Modifications: Refactored code from the walk_function
 *                EIP, Wednesday, August 16, 2006
 *
 *      Vailin Choi 12 July 2007
 *      1. Gathered storage info for btree and heap
 *         (groups and attributes)
 *      2. Gathered info for attributes
 *
 *      Vailin Choi 14 July 2007
 *      Cast "num_objs" and "num_attrs" to size_t
 *      Due to the -Mbounds problem for the pgi-32 bit compiler on indexing
 *
 *-------------------------------------------------------------------------
 */
static herr_t
group_stats(iter_t *iter, const char *name, const H5O_info_t *oi)
{
    H5G_info_t     ginfo;                  /* Group information */
    uint      bin;                     /* "bin" the number of objects falls in */
    herr_t     ret;

    /* Gather statistics about this type of object */
    iter.uniq_groups++;

    /* Get object header information */
    iter.group_ohdr_info.total_size += oi.hdr.space.total;
    iter.group_ohdr_info.free_size += oi.hdr.space.free;

    /* Get group information */
    ret = H5Gget_info_by_name(iter.fid, name, &ginfo, H5P_DEFAULT);
    HDassert(ret >= 0);

    /* Update link stats */
    /* Collect statistics for small groups */
    if (ginfo.nlinks < cast(hsize_t)sgroups_threshold)
        (iter.num_small_groups[cast(size_t)ginfo.nlinks])+=1;
    /* Determine maximum link count */
    if(ginfo.nlinks > iter.max_fanout)
        iter.max_fanout = ginfo.nlinks;

    /* Add group count to proper bin */
    bin = ceil_log10(cast(ulong)ginfo.nlinks);
    if((bin + 1) > iter.group_nbins) {
        /* Allocate more storage for info about dataset's datatype */
        iter.group_bins = cast(ulong *)HDrealloc(iter.group_bins, (bin + 1) * ulong.sizeof);
        HDassert(iter.group_bins);

  /* Initialize counts for intermediate bins */
        while(iter.group_nbins < bin)
            iter.group_bins[iter.group_nbins++] = 0;
        iter.group_nbins++;

        /* Initialize count for new bin */
        iter.group_bins[bin] = 1;
    } /* end if */
    else
        (iter.group_bins[bin])+=1;

    /* Update group metadata info */
    iter.groups_btree_storage_size += oi.meta_size.obj.index_size;
    iter.groups_heap_storage_size += oi.meta_size.obj.heap_size;

    /* Update attribute metadata info */
    ret = attribute_stats(iter, oi);
    HDassert(ret >= 0);

    return 0;
} /* end group_stats() */

/*-------------------------------------------------------------------------
 * Function: dataset_stats
 *
 * Purpose: Gather statistics about the dataset
 *
 * Return:  Success: 0
 *
 *          Failure: -1
 *
 * Programmer:    Quincey Koziol
 *                Tuesday, August 16, 2005
 *
 *-------------------------------------------------------------------------
 */
static herr_t
dataset_stats(iter_t *iter, const char *name, const H5O_info_t *oi)
{
    uint      bin;               /* "bin" the number of objects falls in */
    hid_t     did;               /* Dataset ID */
    hid_t     sid;               /* Dataspace ID */
    hid_t     tid;               /* Datatype ID */
    hid_t     dcpl;              /* Dataset creation property list ID */
    hsize_t     dims[H5S_MAX_RANK];/* Dimensions of dataset */
    H5D_layout_t   lout;              /* Layout of dataset */
    uint      type_found;        /* Whether the dataset's datatype was */
                                         /* already found */
    int     ndims;             /* Number of dimensions of dataset */
    hsize_t     storage;           /* Size of dataset storage */
    uint      u;                 /* Local index variable */
    int     num_ext;           /* Number of external files for a dataset */
    int     nfltr;             /* Number of filters for a dataset */
    H5Z_filter_t  fltr;              /* Filter identifier */
    herr_t     ret;

    /* Gather statistics about this type of object */
    iter.uniq_dsets++;

    /* Get object header information */
    iter.dset_ohdr_info.total_size += oi.hdr.space.total;
    iter.dset_ohdr_info.free_size += oi.hdr.space.free;

    did = H5Dopen2(iter.fid, name, H5P_DEFAULT);
    HDassert(did > 0);

    /* Update dataset metadata info */
    iter.datasets_index_storage_size += oi.meta_size.obj.index_size;
    iter.datasets_heap_storage_size += oi.meta_size.obj.heap_size;

    /* Update attribute metadata info */
    ret = attribute_stats(iter, oi);
    HDassert(ret >= 0);

    /* Get storage info */
    storage = H5Dget_storage_size(did);

    /* Gather layout statistics */
    dcpl = H5Dget_create_plist(did);
    HDassert(dcpl > 0);

    lout = H5Pget_layout(dcpl);
    HDassert(lout >= 0);

    /* Object header's total size for H5D_COMPACT layout includes raw data size */
    /* "storage" also includes H5D_COMPACT raw data size */
    if(lout == H5D_COMPACT)
        iter.dset_ohdr_info.total_size -= storage;

    /* Track the layout type for dataset */
    (iter.dset_layouts[lout])+=1;

    /* Get the number of external files for the dataset */
    num_ext = H5Pget_external_count(dcpl);
    assert (num_ext >= 0);

    /* Accumulate raw data size accordingly */
    if(num_ext) {
        iter.nexternal += cast(ulong)num_ext;
        iter.dset_external_storage_size += cast(ulong)storage;
    } else
        iter.dset_storage_size += storage;

    /* Gather dataspace statistics */
    sid = H5Dget_space(did);
    HDassert(sid > 0);

    ndims = H5Sget_simple_extent_dims(sid, dims, NULL);
    HDassert(ndims >= 0);

    /* Check for larger rank of dataset */
    if(cast(uint )ndims > iter.max_dset_rank)
        iter.max_dset_rank = cast(uint )ndims;

    /* Track the number of datasets with each rank */
    (iter.dset_rank_count[ndims])+=1;

    /* Only gather dim size statistics on 1-D datasets */
    if(ndims == 1) {
	/* Determine maximum dimension size */
	if(dims[0] > iter.max_dset_dims)
	    iter.max_dset_dims = dims[0];
	/* Collect statistics for small datasets */
       if(dims[0] < cast(hsize_t)sdsets_threshold)
           (iter.small_dset_dims[cast(size_t)dims[0]])+=1;

       /* Add dim count to proper bin */
       bin = ceil_log10(cast(ulong)dims[0]);
       if((bin + 1) > iter.dset_dim_nbins) {
          /* Allocate more storage for info about dataset's datatype */
          iter.dset_dim_bins = cast(ulong *)HDrealloc(iter.dset_dim_bins, (bin + 1) * ulong.sizeof);
          HDassert(iter.dset_dim_bins);

          /* Initialize counts for intermediate bins */
          while(iter.dset_dim_nbins < bin)
              iter.dset_dim_bins[iter.dset_dim_nbins++] = 0;
          iter.dset_dim_nbins++;

          /* Initialize count for this bin */
          iter.dset_dim_bins[bin] = 1;
        } /* end if */
        else
            (iter.dset_dim_bins[bin])+=1;
    } /* end if */

    ret = H5Sclose(sid);
    HDassert(ret >= 0);

    /* Gather datatype statistics */
    tid = H5Dget_type(did);
    HDassert(tid > 0);

    type_found = false ;
    for(u = 0; u < iter.dset_ntypes; u++)
        if(H5Tequal(iter.dset_type_info[u].tid, tid) > 0) {
            type_found = true ;
            break;
        } /* end for */
    if(type_found)
         (iter.dset_type_info[u].count)++;
    else {
        uint  curr_ntype =cast(uint)iter.dset_ntypes;

        /* Increment # of datatypes seen for datasets */
        iter.dset_ntypes++;

        /* Allocate more storage for info about dataset's datatype */
        iter.dset_type_info =cast(dtype_info_t *)HDrealloc(iter.dset_type_info, iter.dset_ntypes * dtype_info_t.sizeof);
        HDassert(iter.dset_type_info);

        /* Initialize information about datatype */
        iter.dset_type_info[curr_ntype].tid = H5Tcopy(tid);
        HDassert(iter.dset_type_info[curr_ntype].tid > 0);
        iter.dset_type_info[curr_ntype].count = 1;
        iter.dset_type_info[curr_ntype].named = 0;

        /* Set index for later */
        u = curr_ntype;
    } /* end else */

    /* Check if the datatype is a named datatype */
    if(H5Tcommitted(tid) > 0)
        (iter.dset_type_info[u].named)++;

    ret = H5Tclose(tid);
    HDassert(ret >= 0);

    /* Track different filters */
    if((nfltr = H5Pget_nfilters(dcpl)) >= 0) {
       if(nfltr == 0)
           iter.dset_comptype[0]++;
        for(u = 0; u <cast(uint)nfltr; u++) {
            fltr = H5Pget_filter2(dcpl, u, 0, 0, 0, 0, 0, NULL);
            if(fltr >= 0) {
                if(fltr < (H5_NFILTERS_IMPL - 1))
                    iter.dset_comptype[fltr]++;
                else
                    iter.dset_comptype[H5_NFILTERS_IMPL - 1]++; /*other filters*/
            } /* end if */
        } /* end for */
    } /* endif nfltr */

     ret = H5Pclose(dcpl);
     HDassert(ret >= 0);

     ret = H5Dclose(did);
     HDassert(ret >= 0);

     return 0;
}  /* end dataset_stats() */


/*-------------------------------------------------------------------------
 * Function: datatype_stats
 *
 * Purpose: Gather statistics about the datatype
 *
 * Return:  Success: 0
 *          Failure: -1
 *
 * Programmer:    Vailin Choi; July 7th, 2009
 *
 *-------------------------------------------------------------------------
 */
static herr_t
datatype_stats(iter_t *iter, const H5O_info_t *oi)
{
    herr_t ret;

    /* Gather statistics about this type of object */
    iter.uniq_dtypes++;

    /* Get object header information */
    iter.dtype_ohdr_info.total_size += oi.hdr.space.total;
    iter.dtype_ohdr_info.free_size += oi.hdr.space.free;

    /* Update attribute metadata info */
    ret = attribute_stats(iter, oi);
    HDassert(ret >= 0);

     return 0;
}  /* end datatype_stats() */


/*-------------------------------------------------------------------------
 * Function: obj_stats
 *
 * Purpose: Gather statistics about an object
 *
 * Return: Success: 0
 *       Failure: -1
 *
 * Programmer: Quincey Koziol
 *             Tuesday, November 6, 2007
 *
 *-------------------------------------------------------------------------
 */
static herr_t
obj_stats(const char *path, const H5O_info_t *oi, const char *already_visited,
    void *_iter)
{
    iter_t *iter =cast(iter_t *)_iter;

    /* If the object has already been seen then just return */
    if(NULL == already_visited) {
        /* Gather some general statistics about the object */
        if(oi.rc > iter.max_links)
            iter.max_links = oi.rc;

        switch(oi.type) {
            case H5O_TYPE_GROUP:
                group_stats(iter, path, oi);
                break;

            case H5O_TYPE_DATASET:
                dataset_stats(iter, path, oi);
                break;

            case H5O_TYPE_NAMED_DATATYPE:
                datatype_stats(iter, oi);
                break;

            case H5O_TYPE_UNKNOWN:
            case H5O_TYPE_NTYPES:
            default:
                /* Gather statistics about this type of object */
                iter.uniq_others++;
                break;
        } /* end switch */
    } /* end if */

    return 0;
} /* end obj_stats() */

/*-------------------------------------------------------------------------
 * Function: lnk_stats
 *
 * Purpose: Gather statistics about a link
 *
 * Return: Success: 0
 *
 *  Failure: -1
 *
 * Programmer: Quincey Koziol
 *             Tuesday, November 6, 2007
 *
 *-------------------------------------------------------------------------
 */

static herr_t lnk_stats(const char /*UNUSED*/ *path, const H5L_info_t *li, void *_iter)
{
    iter_t *iter =cast(iter_t *)_iter;

    switch(li.type) {
        case H5L_TYPE_SOFT:
        case H5L_TYPE_EXTERNAL:
            /* Gather statistics about links and UD links */
            iter.uniq_links++;
            break;

        case H5L_TYPE_HARD:
        case H5L_TYPE_MAX:
        case H5L_TYPE_ERROR:
        default:
            /* Gather statistics about this type of object */
            iter.uniq_others++;
            break;
    } /* end switch() */

    return 0;
} /* end lnk_stats() */


/*-------------------------------------------------------------------------
 * Function: hand_free
 *
 * Purpose: Free handler structure
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 *-------------------------------------------------------------------------
 */
static void hand_free(handler_t *hand)
{
    if(hand) {
        uint  u;

        for(u = 0; u < hand.obj_count; u++)
            if(hand.obj[u]) {
                HDfree(hand.obj[u]);
                hand.obj[u] = NULL;
            } /* end if */
        hand.obj_count = 0;
        HDfree(hand.obj);
        HDfree(hand);
    } /* end if */
} /* end hand_free() */


/*-------------------------------------------------------------------------
 * Function: parse_command_line
 *
 * Purpose: Parses command line and sets up global variable to control output
 *
 * Return: Success: 0
 *
 * Failure: -1
 *
 * Programmer: Elena Pourmal
 *             Saturday, August 12, 2006
 *
 *-------------------------------------------------------------------------
 */
static int
parse_command_line(int argc, const char *argv[], handler_t **hand_ret)
{
    int                opt;
    uint            u;
    handler_t   *hand = NULL;

    /* parse command line options */
    while((opt = get_option(argc, argv, s_opts, l_opts)) != EOF) {
        switch(cast(char)opt) {
            case 'h':
                usage(h5tools_getprogname());
                h5tools_setstatus(EXIT_SUCCESS);
                goto done;
                break;

            case 'V':
                print_version(h5tools_getprogname());
                h5tools_setstatus(EXIT_SUCCESS);
                goto done;
                break;

            case 'F':
                display_all = false ;
                display_file_metadata = true ;
                break;

            case 'f':
                display_all = false ;
                display_file = true ;
                break;

            case 'G':
                display_all = false ;
                display_group_metadata = true ;
                break;

            case 'g':
                display_all = false ;
                display_group = true ;
                break;

            case 'l':
		if(opt_arg) {
		    sgroups_threshold = HDatoi(opt_arg);
		    if(sgroups_threshold < 1) {
			error_msg("Invalid threshold for small groups\n");
			goto error;
		    }
		} else
		    error_msg("Missing threshold for small groups\n");

                break;

            case 'D':
                display_all = false ;
                display_dset_metadata = true ;
                break;

            case 'd':
                display_all = false ;
                display_dset = true ;
                break;

            case 'm':
		if(opt_arg) {
		    sdsets_threshold = HDatoi(opt_arg);
		    if(sdsets_threshold < 1) {
			error_msg("Invalid threshold for small datasets\n");
			goto error;
		    }
		} else
		    error_msg("Missing threshold for small datasets\n");

                break;

            case 'T':
                display_all = false ;
                display_dset_dtype_meta = true ;
                break;

            case 'A':
                display_all = false ;
                display_attr = true ;
                break;

            case 'a':
		if(opt_arg) {
		    sattrs_threshold = HDatoi(opt_arg);
		    if(sattrs_threshold < 1) {
			error_msg("Invalid threshold for small # of attributes\n");
			goto error;
		    }
		} else
                    error_msg("Missing threshold for small # of attributes\n");

                break;

            case 'S':
                display_all = false ;
                display_summary = true ;
                break;

            case 'O':
                display_all = false ;
                display_object = true ;

                /* Allocate space to hold the command line info */
                if(NULL == (hand = cast(handler_t *)HDcalloc(cast(size_t)1, handler_t.sizeof))) {
                    error_msg("unable to allocate memory for object struct\n");
                    goto error;
                } /* end if */

                /* Allocate space to hold the object strings */
                hand.obj_count = cast(size_t)args.length;
                if(NULL == (hand.obj = cast(char **)HDcalloc(cast(size_t)args.length, (char*).sizeof))) {
                    error_msg("unable to allocate memory for object array\n");
                    goto error;
                } /* end if */

                /* Store object names */
                for(u = 0; u < hand.obj_count; u++)
                    if(NULL == (hand.obj[u] = HDstrdup(opt_arg))) {
                        error_msg("unable to allocate memory for object name\n");
                        goto error;
                    } /* end if */
                break;

            default:
                usage(h5tools_getprogname());
                goto error;
        } /* end switch */
    } /* end while */

    /* check for file name to be processed */
    if(args.length <= opt_ind) {
        error_msg("missing file name\n");
        usage(h5tools_getprogname());
        goto error;
    } /* end if */

    /* Set handler structure */
    *hand_ret = hand;

done:
    return 0;

error:
    hand_free(hand);
    h5tools_setstatus(EXIT_FAILURE);

    return -1;
}


/*-------------------------------------------------------------------------
 * Function: iter_free
 *
 * Purpose: Free iter structure
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 *-------------------------------------------------------------------------
 */
static void
iter_free(iter_t *iter)
{

    /* Clear array of bins for group counts */
    if(iter.group_bins) {
        HDfree(iter.group_bins);
        iter.group_bins = NULL;
    } /* end if */

    /* Clear array for tracking small groups */
    if(iter.num_small_groups) {
        HDfree(iter.num_small_groups);
        iter.num_small_groups = NULL;
    } /* end if */

    /* Clear array of bins for attribute counts */
    if(iter.attr_bins) {
        HDfree(iter.attr_bins);
        iter.attr_bins = NULL;
    } /* end if */

    /* Clear array for tracking small attributes */
    if(iter.num_small_attrs) {
        HDfree(iter.num_small_attrs);
        iter.num_small_attrs= NULL;
    } /* end if */

    /* Clear dataset datatype information found */
    if(iter.dset_type_info) {
        HDfree(iter.dset_type_info);
        iter.dset_type_info = NULL;
    } /* end if */

    /* Clear array of bins for dataset dimensions */
    if(iter.dset_dim_bins) {
        HDfree(iter.dset_dim_bins);
        iter.dset_dim_bins = NULL;
    } /* end if */

    /* Clear array of tracking 1-D small datasets */
    if(iter.small_dset_dims) {
        HDfree(iter.small_dset_dims);
        iter.small_dset_dims = NULL;
    } /* end if */

} /* end iter_free() */


/*-------------------------------------------------------------------------
 * Function: print_file_info
 *
 * Purpose: Prints information about file
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Elena Pourmal
 *             Saturday, August 12, 2006
 *
 * Modifications:
 *
 *-------------------------------------------------------------------------
 */
static herr_t
print_file_info(const iter_t *iter)
{
    writef("File information\n");
    writef("\t# of unique groups: %lu\n", iter.uniq_groups);
    writef("\t# of unique datasets: %lu\n", iter.uniq_dsets);
    writef("\t# of unique named datatypes: %lu\n", iter.uniq_dtypes);
    writef("\t# of unique links: %lu\n", iter.uniq_links);
    writef("\t# of unique other: %lu\n", iter.uniq_others);
    writef("\tMax. # of links to object: %lu\n", iter.max_links);
    HDfprintf(stdout, "\tMax. # of objects in group: %Hu\n", iter.max_fanout);

    return 0;
} /* print_file_info() */


/*-------------------------------------------------------------------------
 * Function: print_file_metadata
 *
 * Purpose: Prints file space information for file's metadata
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Elena Pourmal
 *             Saturday, August 12, 2006
 *
 *-------------------------------------------------------------------------
 */
static herr_t
print_file_metadata(const iter_t *iter)
{
    HDfprintf(stdout, "File space information for file metadata (in bytes):\n");
    HDfprintf(stdout, "\tSuperblock extension: %Hu\n", iter.super_ext_size);
    HDfprintf(stdout, "\tUser block: %Hu\n", iter.ublk_size);

    HDfprintf(stdout, "\tObject headers: (total/unused)\n");
    HDfprintf(stdout, "\t\tGroups: %Hu/%Hu\n",
                iter.group_ohdr_info.total_size,
    iter.group_ohdr_info.free_size);
    HDfprintf(stdout, "\t\tDatasets(exclude compact data): %Hu/%Hu\n",
    iter.dset_ohdr_info.total_size,
    iter.dset_ohdr_info.free_size);
    HDfprintf(stdout, "\t\tDatatypes: %Hu/%Hu\n",
                iter.dtype_ohdr_info.total_size,
    iter.dtype_ohdr_info.free_size);

    HDfprintf(stdout, "\tGroups:\n");
    HDfprintf(stdout, "\t\tB-tree/List: %Hu\n", iter.groups_btree_storage_size);
    HDfprintf(stdout, "\t\tHeap: %Hu\n", iter.groups_heap_storage_size);

    HDfprintf(stdout, "\tAttributes:\n");
    HDfprintf(stdout, "\t\tB-tree/List: %Hu\n", iter.attrs_btree_storage_size);
    HDfprintf(stdout, "\t\tHeap: %Hu\n", iter.attrs_heap_storage_size);

    HDfprintf(stdout, "\tChunked datasets:\n");
    HDfprintf(stdout, "\t\tIndex: %Hu\n", iter.datasets_index_storage_size);

    HDfprintf(stdout, "\tDatasets:\n");
    HDfprintf(stdout, "\t\tHeap: %Hu\n", iter.datasets_heap_storage_size);

    HDfprintf(stdout, "\tShared Messages:\n");
    HDfprintf(stdout, "\t\tHeader: %Hu\n", iter.SM_hdr_storage_size);
    HDfprintf(stdout, "\t\tB-tree/List: %Hu\n", iter.SM_index_storage_size);
    HDfprintf(stdout, "\t\tHeap: %Hu\n", iter.SM_heap_storage_size);

    return 0;
} /* print_file_metadata() */


/*-------------------------------------------------------------------------
 * Function: print_group_info
 *
 * Purpose: Prints information about groups in the file
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Elena Pourmal
 *             Saturday, August 12, 2006
 *
 * Modifications:
 *  bug #1253; Oct 6th 2008; Vailin Choi
 *  Fixed segmentation fault: print iter.group_bins[0] when
 *  there is iter.group_nbins
 *
 *-------------------------------------------------------------------------
 */
static herr_t
print_group_info(const iter_t *iter)
{
    ulong  power;        /* Temporary "power" for bins */
    ulong  total;        /* Total count for various statistics */
    uint  u;                 /* Local index variable */

    writef("Small groups (with 0 to %u links):\n", sgroups_threshold-1);
    total = 0;
    for(u = 0; u <cast(uint)sgroups_threshold; u++) {
        if(iter.num_small_groups[u] > 0) {
            writef("\t# of groups with %u link(s): %lu\n", u, iter.num_small_groups[u]);
            total += iter.num_small_groups[u];
        } /* end if */
    } /* end for */
    writef("\tTotal # of small groups: %lu\n", total);

    writef("Group bins:\n");
    total = 0;
    if((iter.group_nbins > 0) && (iter.group_bins[0] > 0)) {
       writef("\t# of groups with 0 link: %lu\n", iter.group_bins[0]);
       total = iter.group_bins[0];
    } /* end if */
    power = 1;
    for(u = 1; u < iter.group_nbins; u++) {
        if(iter.group_bins[u] > 0) {
           writef("\t# of groups with %lu - %lu links: %lu\n", power, (power * 10) - 1,
                    iter.group_bins[u]);
           total += iter.group_bins[u];
        } /* end if */
        power *= 10;
    } /* end for */
    writef("\tTotal # of groups: %lu\n", total);

    return 0;
} /* print_group_info() */


/*-------------------------------------------------------------------------
 * Function: print_group_metadata
 *
 * Purpose: Prints file space information for groups' metadata
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Vailin Choi; October 2009
 *
 *-------------------------------------------------------------------------
 */
static herr_t
print_group_metadata(const iter_t *iter)
{
    writef("File space information for groups' metadata (in bytes):\n");

    HDfprintf(stdout, "\tObject headers (total/unused): %Hu/%Hu\n",
            iter.group_ohdr_info.total_size, iter.group_ohdr_info.free_size);

    HDfprintf(stdout, "\tB-tree/List: %Hu\n", iter.groups_btree_storage_size);
    HDfprintf(stdout, "\tHeap: %Hu\n", iter.groups_heap_storage_size);

    return 0;
} /* print_group_metadata() */


/*-------------------------------------------------------------------------
 * Function: print_dataset_info
 *
 * Purpose: Prints information about datasets in the file
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Elena Pourmal
 *             Saturday, August 12, 2006
 *
 *-------------------------------------------------------------------------
 */
static herr_t
print_dataset_info(const iter_t *iter)
{
    ulong  power;        /* Temporary "power" for bins */
    ulong  total;        /* Total count for various statistics */

    if(iter.uniq_dsets > 0) {
        writefln("Dataset dimension information:");
        writefln("\tMax. rank of datasets: %u", iter.max_dset_rank);
        writefln("\tDataset ranks:");
        foreach(u;0.. H5S_MAX_RANK)
            if(iter.dset_rank_count[u] > 0)
                writefln("\t\t# of dataset with rank %u: %lu", u, iter.dset_rank_count[u]);

        writefln("1-D Dataset information:");
        HDfprintf(stdout, "\tMax. dimension size of 1-D datasets: %Hu\n", iter.max_dset_dims);
        writefln("\tSmall 1-D datasets (with dimension sizes 0 to %u):", sdsets_threshold - 1);
        total = 0;
        for(u = 0; u <cast(uint)sdsets_threshold; u++) {
            if(iter.small_dset_dims[u] > 0) {
                writefln("\t\t# of datasets with dimension sizes %u: %lu", u,
                         iter.small_dset_dims[u]);
                total += iter.small_dset_dims[u];
            } /* end if */
        } /* end for */
        writefln("\t\tTotal # of small datasets: %lu", total);

        /* Protect against no datasets in file */
        if(iter.dset_dim_nbins > 0) {
            writefln("\t1-D Dataset dimension bins:");
            total = 0;
            if(iter.dset_dim_bins[0] > 0) {
                writefln("\t\t# of datasets with dimension size 0: %lu", iter.dset_dim_bins[0]);
                total = iter.dset_dim_bins[0];
            } /* end if */
            power = 1;
            foreach(u;1..iter.dset_dim_nbins)
            {
                if(iter.dset_dim_bins[u] > 0) {
                    writefln("\t\t# of datasets with dimension size %lu - %lu: %lu", power, (power * 10) - 1,
                             iter.dset_dim_bins[u]);
                    total += iter.dset_dim_bins[u];
                } /* end if */
                power *= 10;
            } /* end for */
            writefln("\t\tTotal # of datasets: %lu", total);
        } /* end if */

        writefln("Dataset storage information:");
        HDfprintf(stdout, "\tTotal raw data size: %Hu\n", iter.dset_storage_size);
        HDfprintf(stdout, "\tTotal external raw data size: %Hu\n", iter.dset_external_storage_size);

        writefln("Dataset layout information:");
        for(u = 0; u < H5D_NLAYOUTS; u++)
        writef("\tDataset layout counts[%s]: %lu\n", (u == 0 ? "COMPACT" :
                (u == 1 ? "CONTIG" : "CHUNKED")), iter.dset_layouts[u]);
        writef("\tNumber of external files : %lu\n", iter.nexternal);

        writefln("Dataset filters information:");
        writefln("\tNumber of datasets with:");
        writefln("\t\tNO filter: %lu", iter.dset_comptype[H5Z_FILTER_ERROR+1]);
        writefln("\t\tGZIP filter: %lu", iter.dset_comptype[H5Z_FILTER_DEFLATE]);
        writefln("\t\tSHUFFLE filter: %lu", iter.dset_comptype[H5Z_FILTER_SHUFFLE]);
        writefln("\t\tFLETCHER32 filter: %lu", iter.dset_comptype[H5Z_FILTER_FLETCHER32]);
        writefln("\t\tSZIP filter: %lu", iter.dset_comptype[H5Z_FILTER_SZIP]);
        writefln("\t\tNBIT filter: %lu", iter.dset_comptype[H5Z_FILTER_NBIT]);
        writefln("\t\tSCALEOFFSET filter: %lu", iter.dset_comptype[H5Z_FILTER_SCALEOFFSET]);
        writefln("\t\tUSER-DEFINED filter: %lu", iter.dset_comptype[H5_NFILTERS_IMPL-1]);
    } /* end if */

    return 0;
} /* print_dataset_info() */


/*-------------------------------------------------------------------------
 * Function: print_dataset_metadata
 *
 * Purpose: Prints file space information for datasets' metadata
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer:  Vailin Choi; October 2009
 *
 *-------------------------------------------------------------------------
 */
static herr_t
print_dset_metadata(const iter_t *iter)
{
    writef("File space information for datasets' metadata (in bytes):\n");

    HDfprintf(stdout, "\tObject headers (total/unused): %Hu/%Hu\n",
            iter.dset_ohdr_info.total_size, iter.dset_ohdr_info.free_size);

    HDfprintf(stdout, "\tIndex for Chunked datasets: %Hu\n",
            iter.datasets_index_storage_size);
    HDfprintf(stdout, "\tHeap: %Hu\n", iter.datasets_heap_storage_size);

    return 0;
} /* print_dset_metadata() */


/*-------------------------------------------------------------------------
 * Function: print_dset_dtype_meta
 *
 * Purpose: Prints datasets' datatype information
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Vailin Choi; October 2009
 *
 *-------------------------------------------------------------------------
 */
static herr_t
print_dset_dtype_meta(const iter_t *iter)
{
    ulong  total;        /* Total count for various statistics */
    size_t   dtype_size;        /* Size of encoded datatype */
    uint  u;                 /* Local index variable */

    if(iter.dset_ntypes) {
        writef("Dataset datatype information:\n");
        writef("\t# of unique datatypes used by datasets: %lu\n", iter.dset_ntypes);
        total = 0;
        for(u = 0; u < iter.dset_ntypes; u++) {
            H5Tencode(iter.dset_type_info[u].tid, NULL, &dtype_size);
            writef("\tDataset datatype #%u:\n", u);
            writef("\t\tCount (total/named) = (%lu/%lu)\n",
                    iter.dset_type_info[u].count, iter.dset_type_info[u].named);
            writef("\t\tSize (desc./elmt) = (%lu/%lu)\n", cast(ulong)dtype_size,
                    cast(ulong)H5Tget_size(iter.dset_type_info[u].tid));
            H5Tclose(iter.dset_type_info[u].tid);
            total += iter.dset_type_info[u].count;
        } /* end for */
        writef("\tTotal dataset datatype count: %lu\n", total);
    } /* end if */

    return 0;
} /* print_dset_dtype_meta() */


/*-------------------------------------------------------------------------
 * Function: print_attr_info
 *
 * Purpose: Prints information about attributes in the file
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Vailin Choi
 *             July 12, 2007
 *
 *-------------------------------------------------------------------------
 */
static herr_t
print_attr_info(const iter_t *iter)
{
    ulong  power;        /* Temporary "power" for bins */
    ulong  total;        /* Total count for various statistics */
    uint  u;                 /* Local index variable */

    writef("Small # of attributes (objects with 1 to %u attributes):\n", sattrs_threshold);
    total = 0;
    for(u = 1; u <=cast(uint)sattrs_threshold; u++) {
        if(iter.num_small_attrs[u] > 0) {
            writef("\t# of objects with %u attributes: %lu\n", u, iter.num_small_attrs[u]);
            total += iter.num_small_attrs[u];
        } /* end if */
    } /* end for */
    writef("\tTotal # of objects with small # of attributes: %lu\n", total);

    writef("Attribute bins:\n");
    total = 0;
    power = 1;
    for(u = 1; u < iter.attr_nbins; u++) {
        if(iter.attr_bins[u] > 0) {
           writef("\t# of objects with %lu - %lu attributes: %lu\n", power, (power * 10) - 1,
                    iter.attr_bins[u]);
           total += iter.attr_bins[u];
        } /* end if */
        power *= 10;
    } /* end for */
    writef("\tTotal # of objects with attributes: %lu\n", total);
    writef("\tMax. # of attributes to objects: %lu\n", cast(ulong)iter.max_attrs);

    return 0;
} /* print_attr_info() */


/*-------------------------------------------------------------------------
 * Function: print_storage_summary
 *
 * Purpose: Prints file space information for the file
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Vailin Choi; August 2009
 *
 *-------------------------------------------------------------------------
 */
static herr_t
print_storage_summary(const iter_t *iter)
{
    hsize_t total_meta = 0;
    hsize_t unaccount = 0;

    writef("Summary of file space information:\n");
    total_meta =
            iter.super_ext_size + iter.ublk_size +
            iter.group_ohdr_info.total_size +
            iter.dset_ohdr_info.total_size +
            iter.dtype_ohdr_info.total_size +
            iter.groups_btree_storage_size +
            iter.groups_heap_storage_size +
            iter.attrs_btree_storage_size +
            iter.attrs_heap_storage_size +
            iter.datasets_index_storage_size +
            iter.datasets_heap_storage_size +
            iter.SM_hdr_storage_size +
            iter.SM_index_storage_size +
            iter.SM_heap_storage_size;

    HDfprintf(stdout, "  File metadata: %Hu bytes\n", total_meta);
    HDfprintf(stdout, "  Raw data: %Hu bytes\n", iter.dset_storage_size);

    if(iter.filesize < (total_meta + iter.dset_storage_size)) {
        unaccount = (total_meta + iter.dset_storage_size ) - iter.filesize;
        HDfprintf(stdout, "  ??? File has %Hu more bytes accounted for than its size! ???\n", unaccount);
    }
    else {
        unaccount = iter.filesize - (total_meta + iter.dset_storage_size);
        HDfprintf(stdout, "  Unaccounted space: %Hu bytes\n", unaccount);
    }

    HDfprintf(stdout, "Total space: %Hu bytes\n", total_meta + iter.dset_storage_size + unaccount);

    if(iter.nexternal)
        HDfprintf(stdout, "External raw data: %Hu bytes\n", iter.dset_external_storage_size);

    return 0;
} /* print_storage_summary() */


/*-------------------------------------------------------------------------
 * Function: print_file_statistics
 *
 * Purpose: Prints file statistics
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Elena Pourmal
 *             Saturday, August 12, 2006
 *
 *-------------------------------------------------------------------------
 */
static void
print_file_statistics(const iter_t *iter)
{
    if(display_all) {
        display_file = true ;
        display_group = true ;
        display_dset = true ;
        display_dset_dtype_meta = true ;
        display_attr = true ;
        display_summary = true ;

        display_file_metadata = true ;
        display_group_metadata = true ;
        display_dset_metadata = true ;
    }

    if(display_file)            print_file_info(iter);
    if(display_file_metadata)   print_file_metadata(iter);

    if(display_group)           print_group_info(iter);
    if(!display_all && display_group_metadata)   print_group_metadata(iter);

    if(display_dset)            print_dataset_info(iter);
    if(display_dset_dtype_meta) print_dset_dtype_meta(iter);
    if(!display_all && display_dset_metadata)   print_dset_metadata(iter);

    if(display_attr)            print_attr_info(iter);
    if(display_summary)         print_storage_summary(iter);
} /* print_file_statistics() */


/*-------------------------------------------------------------------------
 * Function: print_object_statistics
 *
 * Purpose: Prints object statistics
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Elena Pourmal
 *             Thursday, August 17, 2006
 *
 * Modifications:
 *
 *-------------------------------------------------------------------------
 */
static void
print_object_statistics(const char *name)
{
    writef("Object name %s\n", name);
} /* print_object_statistics() */


/*-------------------------------------------------------------------------
 * Function: print_statistics
 *
 * Purpose: Prints statistics
 *
 * Return: Success: 0
 *
 * Failure: Never fails
 *
 * Programmer: Elena Pourmal
 *             Thursday, August 17, 2006
 *
 * Modifications:
 *
 *-------------------------------------------------------------------------
 */
static void
print_statistics(const char *name, const iter_t *iter)
{
    if(display_object)
        print_object_statistics(name);
    else
        print_file_statistics(iter);
} /* print_statistics() */


/*-------------------------------------------------------------------------
 * Function: main
 *
 * Modifications:
 *      2/2010; Vailin Choi
 *      Get the size of user block
 *
 *-------------------------------------------------------------------------
 */
int main(string[] args)
{
    iter_t              iter;
    const char         *fname = NULL;
    hid_t               fid = -1;
    handler_t   *hand = NULL;

    h5tools_setprogname(PROGRAMNAME);
    h5tools_setstatus(EXIT_SUCCESS);

    /* Disable error reporting */
    H5Eset_auto2(H5E_DEFAULT, NULL, NULL);

    /* Initialize h5tools lib */
    h5tools_init();
    
    HDmemset(&iter, 0, iter.sizeof);

    if(parse_command_line(argc, argv, &hand) < 0)
        goto done;

    fname = argv[opt_ind];

    /* Check for filename given */
    if(fname) {
        hid_t               fcpl;
        H5F_info_t          finfo;

        writef("Filename: %s\n", fname);

        fid = H5Fopen(fname, H5F_ACC_RDONLY, H5P_DEFAULT);
        if(fid < 0) {
            error_msg("unable to open file \"%s\"\n", fname);
            h5tools_setstatus(EXIT_FAILURE);
            goto done;
        } /* end if */

        /* Initialize iter structure */
        iter.fid = fid;

        if(H5Fget_filesize(fid, &iter.filesize) < 0)
            warn_msg("Unable to retrieve file size\n");
        HDassert(iter.filesize != 0);

        /* Get storge info for file-level structures */
        if(H5Fget_info(fid, &finfo) < 0)
            warn_msg("Unable to retrieve file info\n");
        else {
            iter.super_ext_size = finfo.super_ext_size;
            iter.SM_hdr_storage_size = finfo.sohm.hdr_size;
            iter.SM_index_storage_size = finfo.sohm.msgs_info.index_size;
            iter.SM_heap_storage_size = finfo.sohm.msgs_info.heap_size;
        } /* end else */

	iter.num_small_groups = cast(ulong *)HDcalloc(cast(size_t)sgroups_threshold, ulong.sizeof);
	iter.num_small_attrs = cast(ulong *)HDcalloc(cast(size_t)(sattrs_threshold+1), ulong.sizeof);
	iter.small_dset_dims = cast(ulong *)HDcalloc(cast(size_t)sdsets_threshold, ulong.sizeof);

	if(iter.num_small_groups == NULL || iter.num_small_attrs == NULL || iter.small_dset_dims == NULL) {
	    error_msg("Unable to allocate memory for tracking small groups/datasets/attributes\n");
            h5tools_setstatus(EXIT_FAILURE);
	    goto done;
	}

        if((fcpl = H5Fget_create_plist(fid)) < 0)
            warn_msg("Unable to retrieve file creation property\n");

        if(H5Pget_userblock(fcpl, &iter.ublk_size) < 0)
            warn_msg("Unable to retrieve userblock size\n");

        /* Walk the objects or all file */
        if(display_object) {
            uint  u;

            for(u = 0; u < hand.obj_count; u++) {
                if(h5trav_visit(fid, hand.obj[u], true , true , obj_stats, lnk_stats, &iter) < 0)
                    warn_msg("Unable to traverse object \"%s\"\n", hand.obj[u]);
                else
                    print_statistics(hand.obj[u], &iter);
            } /* end for */
        } /* end if */
        else {
            if(h5trav_visit(fid, "/", true , true , obj_stats, lnk_stats, &iter) < 0)
                warn_msg("Unable to traverse objects/links in file \"%s\"\n", fname);
            else
                print_statistics("/", &iter);
        } /* end else */
    } /* end if */

done:
    hand_free(hand);

    /* Free iter structure */
    iter_free(&iter);

    if(fid >= 0 && H5Fclose(fid) < 0) {
        error_msg("unable to close file \"%s\"\n", fname);
        h5tools_setstatus(EXIT_FAILURE);
    } /* end if */

    leave(h5tools_getstatus());
} /* end main() */

