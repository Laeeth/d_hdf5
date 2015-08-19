/**
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

  Ported by Laeeth Isharc 2014 to the D Programming Language
  Use at your own risk!

 *  This program shows how the H5Sselect_hyperslab and H5Sselect_elements
 *  functions are used to write selected data from memory to the file.
 *  Program takes 48 elements from the linear buffer and writes them into
 *  the matrix using 3x2 blocks, (4,3) stride and (2,4) count.
 *  Then four elements  of the matrix are overwritten with the new values and
 *  file is closed. Program reopens the file and selects the union of two
 *  hyperslabs in the dataset in the file. Then it reads the selection into the
 *  memory dataset preserving the shape of the selection.
*/


import hdf5.hdf5;
import std.stdio;
import std.exception;

enum  H5FILE_NAME ="Select.h5";
enum  MSPACE1_RANK =    1;          /* Rank of the first dataset in memory */
enum  MSPACE1_DIM   =   50;         /* Dataset size in memory */

enum  MSPACE2_RANK    = 1;          /* Rank of the second dataset in memory */
enum  MSPACE2_DIM     = 4;          /* Dataset size in memory */

enum  FSPACE_RANK      =2;          /* Dataset rank as it is stored in the file */
enum  FSPACE_DIM1      =8;          /* Dimension sizes of the dataset as it is
                                       stored in the file */
enum  FSPACE_DIM2      =12;

                                    /* We will read dataset back from the file
                                       to the dataset in memory with these
                                       dataspace parameters. */
enum  MSPACE_RANK      =2;
enum  MSPACE_DIM1      =8;
enum  MSPACE_DIM2      =9;

enum  NPOINTS          =4;          /* Number of points that will be selected
                                       and overwritten */
int main(string[] args)
{

   hid_t   mid1, mid2, mid;    /* Dataspace identifiers */

   hsize_t[] dim1 = [MSPACE1_DIM];  /* Dimension size of the first dataset
                                       (in memory) */
   hsize_t[] dim2 = [MSPACE2_DIM];  /* Dimension size of the second dataset
                                       (in memory */
   hsize_t[] fdim = [FSPACE_DIM1, FSPACE_DIM2];
                                    /* Dimension sizes of the dataset (on disk) */
   hsize_t[] mdim = [MSPACE_DIM1, MSPACE_DIM2]; /* Dimension sizes of the
                                                   dataset in memory when we
                                                   read selection from the
                                                   dataset on the disk */

   hsize_t[2] start,stride,count,block; // Start of hyperslab; Stride of hyperslab; Block count; Block sizes

   hsize_t[FSPACE_RANK][NPOINTS] coord; /* Array to store selected points
                                            from the file dataspace */
   int fillvalue = 0;   /* Fill value for the dataset */

   int[MSPACE_DIM2][MSPACE_DIM1]    matrix_out; /* Buffer to read from the
                                                   dataset */
   int[MSPACE1_DIM]    vector;
   int[]    values = [53, 59, 61, 67];  /* New values to be written */

   /*
    * Buffers' initialization.
    */
   vector[0] = vector[MSPACE1_DIM - 1] = -1;
   foreach(i;1..MSPACE1_DIM - 1)
       vector[i] = i;

   /*
    * Create a file.
    */
   auto file = H5F.create(H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

   /*
    * Create property list for a dataset and set up fill values.
    */
   auto plist = H5P.create(H5P_DATASET_CREATE);
   H5P.set_fill_value(plist, H5T_NATIVE_INT, &fillvalue);

    /*
     * Create dataspace for the dataset in the file.
     */
    auto fid = H5S.create_simple(fdim);

    /*
     * Create dataset in the file. Notice that creation
     * property list plist is used.
     */
    auto dataset = H5D.create2(file, "Matrix in file", H5T_NATIVE_INT, fid, H5P_DEFAULT, plist, H5P_DEFAULT);

    /*
     * Select hyperslab for the dataset in the file, using 3x2 blocks,
     * (4,3) stride and (2,4) count starting at the position (0,1).
     */
    start[0]  = 0; start[1]  = 1;
    stride[0] = 4; stride[1] = 3;
    count[0]  = 2; count[1]  = 4;
    block[0]  = 3; block[1]  = 2;
    H5S.select_hyperslab(fid, H5SSeloper.Set, start, stride, count, block);

    /*
     * Create dataspace for the first dataset.
     */
    mid1 = H5S.create_simple(dim1);

    /*
     * Select hyperslab.
     * We will use 48 elements of the vector buffer starting at the second element.
     * Selected elements are 1 2 3 . . . 48
     */
    start[0]  = 1;
    stride[0] = 1;
    count[0]  = 48;
    block[0]  = 1;
    H5S.select_hyperslab(mid1, H5SSeloper.Set, start, stride, count, block);

    /*
     * Write selection from the vector buffer to the dataset in the file.
     *
     * File dataset should look like this:
     *                    0  1  2  0  3  4  0  5  6  0  7  8
     *                    0  9 10  0 11 12  0 13 14  0 15 16
     *                    0 17 18  0 19 20  0 21 22  0 23 24
     *                    0  0  0  0  0  0  0  0  0  0  0  0
     *                    0 25 26  0 27 28  0 29 30  0 31 32
     *                    0 33 34  0 35 36  0 37 38  0 39 40
     *                    0 41 42  0 43 44  0 45 46  0 47 48
     *                    0  0  0  0  0  0  0  0  0  0  0  0
     */
    H5D.write(dataset, H5T_NATIVE_INT, mid1, fid, H5P_DEFAULT, cast(ubyte*)vector);

    /*
     * Reset the selection for the file dataspace fid.
     */
    H5S.select_none(fid);

    /*
     * Create dataspace for the second dataset.
     */
    mid2 = H5S.create_simple(dim2);

    /*
     * Select sequence of NPOINTS points in the file dataspace.
     */
    coord[0][0] = 0; coord[0][1] = 0;
    coord[1][0] = 3; coord[1][1] = 3;
    coord[2][0] = 3; coord[2][1] = 5;
    coord[3][0] = 5; coord[3][1] = 6;

    H5S.select_elements(fid, H5SSeloper  .Set, NPOINTS, cast(const hsize_t *)coord);

    /*
     * Write new selection of points to the dataset.
     */
    H5D.write(dataset, H5T_NATIVE_INT, mid2, fid, H5P_DEFAULT, cast(ubyte*)values);

    /*
     * File dataset should look like this:
     *                   53  1  2  0  3  4  0  5  6  0  7  8
     *                    0  9 10  0 11 12  0 13 14  0 15 16
     *                    0 17 18  0 19 20  0 21 22  0 23 24
     *                    0  0  0 59  0 61  0  0  0  0  0  0
     *                    0 25 26  0 27 28  0 29 30  0 31 32
     *                    0 33 34  0 35 36 67 37 38  0 39 40
     *                    0 41 42  0 43 44  0 45 46  0 47 48
     *                    0  0  0  0  0  0  0  0  0  0  0  0
     *
     */

    /*
     * Close memory file and memory dataspaces.
     */
    H5S.close(mid1);
    H5S.close(mid2);
    H5S.close(fid);

    /*
     * Close dataset.
     */
    H5D.close(dataset);

    /*
     * Close the file.
     */
    H5F.close(file);

    /*
     * Open the file.
     */
    file = H5F.open(H5FILE_NAME, H5F_ACC_RDONLY, H5P_DEFAULT);

    /*
     * Open the dataset.
     */
    dataset = H5D.open2(file, "Matrix in file", H5P_DEFAULT);

    /*
     * Get dataspace of the open dataset.
     */
    fid = H5D.get_space(dataset);

    /*
     * Select first hyperslab for the dataset in the file. The following
     * elements are selected:
     *                     10  0 11 12
     *                     18  0 19 20
     *                      0 59  0 61
     *
     */
    start[0] = 1; start[1] = 2;
    block[0] = 1; block[1] = 1;
    stride[0] = 1; stride[1] = 1;
    count[0]  = 3; count[1]  = 4;
    H5S.select_hyperslab(fid, H5SSeloper  .Set, start, stride, count, block);

    /*
     * Add second selected hyperslab to the selection.
     * The following elements are selected:
     *                    19 20  0 21 22
     *                     0 61  0  0  0
     *                    27 28  0 29 30
     *                    35 36 67 37 38
     *                    43 44  0 45 46
     *                     0  0  0  0  0
     * Note that two hyperslabs overlap. Common elements are:
     *                                              19 20
     *                                               0 61
     */
    start[0] = 2; start[1] = 4;
    block[0] = 1; block[1] = 1;
    stride[0] = 1; stride[1] = 1;
    count[0]  = 6; count[1]  = 5;
    H5S.select_hyperslab(fid, H5SSeloper.Or, start, stride, count, block);

    /*
     * Create memory dataspace.
     */
    mid = H5S.create_simple(mdim);

    /*
     * Select two hyperslabs in memory. Hyperslabs has the same
     * size and shape as the selected hyperslabs for the file dataspace.
     */
    start[0] = 0; start[1] = 0;
    block[0] = 1; block[1] = 1;
    stride[0] = 1; stride[1] = 1;
    count[0]  = 3; count[1]  = 4;
    H5S.select_hyperslab(mid, H5SSeloper  .Set, start, stride, count, block);

    start[0] = 1; start[1] = 2;
    block[0] = 1; block[1] = 1;
    stride[0] = 1; stride[1] = 1;
    count[0]  = 6; count[1]  = 5;
    H5S.select_hyperslab(mid, H5SSeloper  .Or, start, stride, count, block);

    /*
     * Initialize data buffer.
     */
    foreach(i;0.. MSPACE_DIM1) {
       foreach(j; 0.. MSPACE_DIM2)
            matrix_out[i][j] = 0;
    }
    /*
     * Read data back to the buffer matrix_out.
     */
    H5D.read(dataset, H5T_NATIVE_INT, mid, fid, H5P_DEFAULT, cast(ubyte*)matrix_out);

    /*
     * Display the result. Memory dataset is:
     *
     *                    10  0 11 12  0  0  0  0  0
     *                    18  0 19 20  0 21 22  0  0
     *                     0 59  0 61  0  0  0  0  0
     *                     0  0 27 28  0 29 30  0  0
     *                     0  0 35 36 67 37 38  0  0
     *                     0  0 43 44  0 45 46  0  0
     *                     0  0  0  0  0  0  0  0  0
     *                     0  0  0  0  0  0  0  0  0
     */
    foreach(i;0..MSPACE_DIM1) {
        foreach(j;0..MSPACE_DIM2)
            writef("%3d  ", matrix_out[i][j]);
        writef("\n");
    }

    H5S.close(mid);
    H5S.close(fid);
    H5D.close(dataset);
    H5P.close(plist);
    H5F.close(file);

    return 0;
}

