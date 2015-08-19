
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

    This program shows how to create, store and dereference references
    to the dataset regions.

    It creates a file and writes a two dimensional integer dataset
    to it. Then it creates a dataset to store region references in. It
    stores references to a hyperslab and 3 points selected (for the
    integer dataset previously created).

    It then reopens the references dataset, reads and dereferences the
    region references, and then reads and displays the selected hyperslab
    and selected elements data from the integer dataset.
*/

import hdf5;
import std.stdio;
import std.exception;
import std.string;

enum filename="REF_REG.h5";
enum dsetnamev="MATRIX";
enum dsetnamer="REGION_REFERENCES";

int main(string[] args)
{
    hid_t file_id;        /* file identifier */
    hid_t space_id;       /* dataspace identifiers */
    hid_t spacer_id;
    hid_t dsetv_id;       /*dataset identifiers*/
    hid_t dsetr_id;
    hsize_t[2] dims =  [2,9];
    hsize_t[1] dimsr =  [2];
    int rank = 2;
    int rankr =1;
    herr_t status;
    hdset_reg_ref_t[2] _ref;
    hdset_reg_ref_t[2] _ref_out;
    int[9][2] data = [[1,1,2,3,3,4,5,5,6],[1,2,2,3,4,4,5,6,6]];
    int[9][2] data_out = [[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]];
    hsize_t[2] start;
    hsize_t[2] count;
    hsize_t[3][2] coord = [[0, 0, 1], [6, 0, 8]];
    uint num_points = 3;
    size_t name_size1, name_size2;
    char[10] buf1, buf2;

    /*
     * Create file with default file access and file creation properties.
     */
    file_id = H5F.create(filename, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    /*
     * Create dataspace for datasets.
     */
    space_id = H5S.create_simple(dims);
    spacer_id = H5S.create_simple(dimsr);

    /*
     * Create integer dataset.
     */
    dsetv_id = H5D.create2(file_id, dsetnamev, H5T_NATIVE_INT, space_id, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

    /*
     * Write data to the dataset.
     */
    H5D.write(dsetv_id, H5T_NATIVE_INT, H5S_ALL , H5S_ALL, H5P_DEFAULT,cast(ubyte*)data);
    H5D.close(dsetv_id);

    /*
     * Dataset with references.
     */
    dsetr_id = H5D.create2(file_id, dsetnamer, H5T_STD_REF_DSETREG, spacer_id, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

    /*
     * Create a reference to the hyperslab.
     */
    start[0] = 0;
    start[1] = 3;
    count[0] = 2;
    count[1] = 3;
    H5S.select_hyperslab(space_id, H5SSeloper.Set, start,count);
    H5R.create(&_ref[0], file_id, dsetnamev, H5RType.DatasetRegion, space_id);
    writefln("* created ref to hyperslab");
    /*
     * Create a reference to elements selection.
     */
    H5S.select_none(space_id);
    H5S.select_elements(space_id, H5SSeloper.Set, num_points, cast(const hsize_t *)coord);
    H5R.create(&_ref[1], file_id, dsetnamev, H5RType.DatasetRegion, space_id);

    /*
     * Write dataset with the references.
     */
    H5D.write(dsetr_id, H5T_STD_REF_DSETREG, H5S_ALL, H5S_ALL, H5P_DEFAULT,cast(ubyte*)_ref);

    /*
     * Close all objects.
     */
    H5S.close(space_id);
    H5S.close(spacer_id);
    H5D.close(dsetr_id);
    H5F.close(file_id);

    /*
     * Reopen the file to read selections back.
     */
    file_id = H5F.open(filename, H5F_ACC_RDWR,  H5P_DEFAULT);

    /*
     * Reopen the dataset with object references and read references
     * to the buffer.
     */
    dsetr_id = H5D.open2(file_id, dsetnamer, H5P_DEFAULT);

    H5D.read(dsetr_id, H5T_STD_REF_DSETREG, H5S_ALL, H5S_ALL,H5P_DEFAULT,cast(ubyte*)_ref_out);

    /*
     * Dereference the first reference.
     */
    dsetv_id = H5R.dereference(dsetr_id, H5RType.DatasetRegion, &_ref_out[0]);
    /*
     * Get name of the dataset the first region reference points to
     * using H5Rget_name
     */
    buf1 = H5R.get_name(dsetr_id, H5RType.DatasetRegion,&_ref_out[0]);
    writef(" Dataset's name (returned by H5Rget_name) the reference points to is %s, name length is %d\n", buf1, buf1.length);
    /*
     * Get name of the dataset the first region reference points to
     * using H5Iget_name
     */
    buf2 = H5I.get_name(dsetv_id);
    writef(" Dataset's name (returned by H5Iget_name) the reference points to is %s, name length is %d\n", buf2, buf2.length);

    space_id = H5R.get_region(dsetr_id, H5RType.DatasetRegion,&_ref_out[0]);

    /*
     * Read and display hyperslab selection from the dataset.
     */

    H5D.read(dsetv_id, H5T_NATIVE_INT, H5S_ALL, space_id,H5P_DEFAULT,cast(ubyte*) data_out);
    writef("Selected hyperslab: ");
    foreach(i;0..21)
    {
        writef("\n");
        foreach(j;0..9)
            writef("%s ", data_out[i][j]);
    }
    writefln("");

    /*
     * Close dataspace and the dataset.
     */
    H5S.close(space_id);
    H5D.close(dsetv_id);

    /*
     * Initialize data_out array again to get point selection.
     */
    foreach(i;0..2)
        foreach(j;0..9)
            data_out[i][j] = 0;

    /*
     * Dereference the second reference.
     */
    dsetv_id = H5R.dereference(dsetr_id, H5RType.DatasetRegion, &_ref_out[1]);
    space_id = H5R.get_region(dsetv_id, H5RType.DatasetRegion,&_ref_out[1]);

    /*
     * Read selected data from the dataset.
     */

    H5D.read(dsetv_id, H5T_NATIVE_INT, H5S_ALL, space_id, H5P_DEFAULT, cast(ubyte*)data_out);
    writef("Selected points: ");
    foreach(i;0..2)
    {
        writefln("");
        foreach(j;0..9)
            writef("%s ", data_out[i][j]);
    }
    writefln("");

    /*
     * Close dataspace and the dataset.
     */
    H5S.close(space_id);
    H5D.close(dsetv_id);
    H5D.close(dsetr_id);
    H5F.close(file_id);

    return 0;
}



