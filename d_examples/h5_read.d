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

  Ported by Laeeth Ishaarc 2014 to the D Programming Language
  Use at your own risk!

 This example reads hyperslab from the SDS.h5 file
 created by h5_write.c program into two-dimensional
 plane of the three-dimensional array.
 Information about dataset in the SDS.h5 file is obtained.
*/

import hdf5;
import std.stdio;
import std.exception;

string H5FILE_NAME="hdf5/SDS.h5";
string DATASETNAME="IntArray";

enum NX_SUB =3;           /* hyperslab dimensions */
enum NY_SUB  =4;
enum NX =7 ;          /* output buffer dimensions */
enum NY =7;
enum NZ  =3;
enum RANK         =2;
enum RANK_OUT     =3;

int main(string[] args)
{
    hid_t       file, dataset;         /* handles */
    hid_t       datatype, dataspace;
    hid_t       memspace;
    H5TClass t_class;                 /* data type class */
    H5TByteOrder order;                 /* data order */
    size_t      size;                  // size of the data element stored in file
    hsize_t[3]     dimsm;              /* memory space dimensions */
    hsize_t[2]     dims_out;           /* dataset dimensions */
    herr_t      status;

    int[NZ][NY][NX] data_out; /* output buffer */

    hsize_t[2]      count;              /* size of the hyperslab in the file */
    hsize_t[2]      offset;             /* hyperslab offset in the file */
    hsize_t[3]      count_out;          /* size of the hyperslab in memory */
    hsize_t[3]      offset_out;         /* hyperslab offset in memory */
    int          status_n, rank;

    foreach(j;0..NX)
    {
    	foreach(i;0.. NY)
        {
    	    foreach(k;0..NZ)
        		data_out[j][i][k] = 0;
    	}
    }

     // Open the file and the dataset.
    file = H5F.open(H5FILE_NAME, H5F_ACC_RDONLY, H5P_DEFAULT);
    dataset = H5D.open2(file, DATASETNAME, H5P_DEFAULT);

    // Get datatype and dataspace handles and then query dataset class, order, size, rank and dimensions.
    datatype  = H5D.get_type(dataset);     /* datatype handle */
    t_class     = H5T.get_class(datatype);
    if (t_class == H5TClass.Integer)
        writefln("Data set has INTEGER type");
    order     = H5T.get_order(datatype);
    if (order == H5TByteOrder.LE)
        writefln("Little endian order");

    size  = H5T.get_size(datatype);
    writefln(" Data size is %s", size);

    dataspace = H5D.get_space(dataset);    /* dataspace handle */
    rank      = H5S.get_simple_extent_ndims(dataspace);
    status_n  = H5S.get_simple_extent_dims(dataspace, dims_out);
    writefln("rank %d, dimensions %s x %s ", rank, dims_out[0],dims_out[1]);

    // Define hyperslab in the dataset.
    offset[0] = 1;
    offset[1] = 2;
    count[0]  = NX_SUB;
    count[1]  = NY_SUB;
    H5S.select_hyperslab(dataspace, H5SSeloper.Set, offset, [], count, []);

    // Define the memory dataspace.
    dimsm[0] = NX;
    dimsm[1] = NY;
    dimsm[2] = NZ ;
    memspace = H5S.create_simple(dimsm);

     // Define memory hyperslab.
    offset_out[0] = 3;
    offset_out[1] = 0;
    offset_out[2] = 0;
    count_out[0]  = NX_SUB;
    count_out[1]  = NY_SUB;
    count_out[2]  = 1;
    H5S.select_hyperslab(memspace, H5SSeloper.Set, offset_out, [], count_out, []);

    // Read data from hyperslab in the file into the hyperslab in memory and display.
    H5D.read(dataset, H5T_NATIVE_INT, memspace, dataspace, H5P_DEFAULT, cast(ubyte*)data_out);
    foreach(j;0..NX)
    {
	   foreach(i;0..NY)
            writef("%s ", data_out[j][i][0]);
	   writefln("");
    }
    /*
     * 0 0 0 0 0 0 0
     * 0 0 0 0 0 0 0
     * 0 0 0 0 0 0 0
     * 3 4 5 6 0 0 0
     * 4 5 6 7 0 0 0
     * 5 6 7 8 0 0 0
     * 0 0 0 0 0 0 0
     */

    /*
     * Close/release resources.
     */
    H5T.close(datatype);
    H5D.close(dataset);
    H5S.close(dataspace);
    H5S.close(memspace);
    H5F.close(file);
    return 0;
}
