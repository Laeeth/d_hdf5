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

  This example shows how to read and write data to a dataset
  using szip compression.    The program first checks if
  szip compression is available, then if it is it writes
  integers to a dataset using szip, then closes the file.
  Next, it reopens the file, reads back the data, and
  outputs the type of compression and the maximum value in
  the dataset to the screen.
*/

import hdf5.wrap;
import hdf5.bindings.enums;
import std.stdio;
import std.exception;
import std.string;

enum  filename            ="d_examples/h5/h5ex_d_szip.h5";
enum  DATASET        = "DS1";
enum  DIM0           = 32;
enum  DIM1           = 64;
enum  CHUNK0         = 4;
enum  CHUNK1         = 8;

int main(string[] args)
{
    hid_t           file, space, dset, dcpl;    /* Handles */
    herr_t          status;
    htri_t          avail;
    H5ZFilter    filter_type;
    hsize_t[2]         dims = [DIM0, DIM1],
                    chunk = [CHUNK0, CHUNK1];
    size_t          nelmts;
    int            flags;
    uint filter_info;
    int[DIM1][DIM0] wdata,rdata;
    int max;

    /*
     * Check if szip compression is available and can be used for both
     * compression and decompression.  Normally we do not perform error
     * checking in these examples for the sake of clarity, but in this
     * case we will make an exception because this filter is an
     * optional part of the hdf5 library.
     */
    avail = H5Z.filter_avail(H5ZFilter.SZip);
    if (!avail) {
        writefln("szip filter not available.");
        return 1;
    }
    H5Z.get_filter_info(H5ZFilter.SZip, &filter_info);
    if ( !(filter_info & H5Z_FILTER_CONFIG_ENCODE_ENABLED) ||
                !(filter_info & H5Z_FILTER_CONFIG_DECODE_ENABLED) ) {
        writefln("szip filter not available for encoding and decoding.");
        return 1;
    }

    /*
     * Initialize data.
     */
    foreach(i;0..DIM0)
        foreach(j;0..DIM1)
            wdata[i][j] = i * j - j;

    /*
     * Create a new file using the default properties.
     */
    file = H5F.create(filename, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    /*
     * Create dataspace.  Setting maximum size to NULL sets the maximum
     * size to be the current size.
     */
    space = H5S.create_simple(dims);

    /*
     * Create the dataset creation property list, add the szip
     * compression filter and set the chunk size.
     */
    dcpl = H5P.create (H5P_DATASET_CREATE);
    H5P.set_szip (dcpl, H5_SZIP_NN_OPTION_MASK, 8);
    H5P.set_chunk (dcpl, chunk);

    /*
     * Create the dataset.
     */
    dset = H5D.create2(file, DATASET, H5T_STD_I32LE, space, H5P_DEFAULT,dcpl,H5P_DEFAULT);

    /*
     * Write the data to the dataset.
     */
    H5D.write (dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT,cast(ubyte*)wdata.ptr);

    /*
     * Close and release resources.
     */
    H5P.close (dcpl);
    H5D.close (dset);
    H5S.close (space);
    H5F.close (file);


    /*
     * Now we begin the read section of this example.
     */

    /*
     * Open file and dataset using the default properties.
     */
    file = H5F.open (filename, H5F_ACC_RDONLY, H5P_DEFAULT);
    dset = H5D.open2(file, DATASET,H5P_DEFAULT);

    /*
     * Retrieve dataset creation property list.
     */
    dcpl = H5D.get_create_plist (dset);

    /*
     * Retrieve and print the filter type.  Here we only retrieve the
     * first filter because we know that we only added one filter.
     */
    nelmts = 0;
    //uint cd_values[]/*out*/, size_t namelen, char name[], uint *filter_config /*out*/)

    filter_type = H5P.get_filter2(dcpl, 0, &flags, &nelmts,  cast(uint[])[0],0LU,cast(char[])"",cast(uint*)0);
    writef  ("Filter type is: ");
    switch (filter_type) {
        case H5ZFilter.Deflate:
            writefln("H5Z_FILTER_DEFLATE");
            break;
        case H5ZFilter.Shuffle:
            writefln("H5Z_FILTER_SHUFFLE");
            break;
        case H5ZFilter.Fletcher32:
            writefln("H5Z_FILTER_FLETCHER32");
            break;
        case H5ZFilter.SZip:
            writefln("H5Z_FILTER_SZIP");
        default:
            assert(0);
    }

    /*
     * Read the data using the default properties.
     */
    H5D.read(dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)rdata.ptr);

    /*
     * Find the maximum value in the dataset, to verify that it was
     * read correctly.
     */
    max = rdata[0][0];
    foreach(i;0..DIM0)
        foreach(j;0..DIM1)
            if (max < rdata[i][j])
                max=rdata[i][j];

    /*
     * Print the maximum value.
     */
    writefln("Maximum value in %s is: %d", DATASET, max);

    /*
     * Close and release resources.
     */
    H5P.close (dcpl);
    H5D.close (dset);
    H5F.close (file);

    return 0;
}
