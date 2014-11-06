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

module hdf5.H5Spublic;

/*
 * This file contains public declarations for the H5S module.
 */

/* Public headers needed by this file */
public import hdf5.H5public;
public import hdf5.H5Ipublic;

extern(C):

/* Define atomic datatypes */
enum H5S_ALL = 0;
enum H5S_UNLIMITED = (cast(hsize_t)cast(hssize_t)(-1));

/* Define user-level maximum number of dimensions */
enum H5S_MAX_RANK = 32;

/* Different types of dataspaces */
enum H5S_class_t {
    H5S_NO_CLASS         = -1,  /*error                                      */
    H5S_SCALAR           = 0,   /*scalar variable                            */
    H5S_SIMPLE           = 1,   /*simple data space                          */
    H5S_NULL             = 2    /*null data space                            */
}

/* Different ways of combining selections */
enum H5S_seloper_t {
    H5S_SELECT_NOOP      = -1,  /* error                                     */
    H5S_SELECT_SET       = 0,   /* Select "set" operation 		     */
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

enum {
    H5S_SELECT_NOOP      = -1,  /* error                                     */
    H5S_SELECT_SET       = 0,   /* Select "set" operation 		     */
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
    H5S_SEL_ERROR	= -1, 	/* Error			*/
    H5S_SEL_NONE	= 0,    /* Nothing selected 		*/
    H5S_SEL_POINTS	= 1,    /* Sequence of points selected	*/
    H5S_SEL_HYPERSLABS  = 2,    /* "New-style" hyperslab selection defined	*/
    H5S_SEL_ALL		= 3,    /* Entire extent selected	*/
    H5S_SEL_N			/*THIS MUST BE LAST		*/
}

version(Posix) {
  /* Functions in H5S.c */
  hid_t H5Screate(H5S_class_t type);
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
  herr_t H5Sselect_hyperslab(hid_t space_id, H5S_seloper_t op,
                             const hsize_t *start,
                             const hsize_t *_stride,
                             const hsize_t *count,
                             const hsize_t *_block);
  hid_t H5Scombine_hyperslab(hid_t space_id, H5S_seloper_t op,
                             const hsize_t *start,
                             const hsize_t *_stride,
                             const hsize_t *count,
                             const hsize_t *_block);
  herr_t H5Sselect_select(hid_t space1_id, H5S_seloper_t op,
                          hid_t space2_id);
  hid_t H5Scombine_select(hid_t space1_id, H5S_seloper_t op,
                          hid_t space2_id);
  herr_t H5Sselect_elements(hid_t space_id, H5S_seloper_t op,
                            size_t num_elem, const hsize_t *coord);
  H5S_class_t H5Sget_simple_extent_type(hid_t space_id);
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
