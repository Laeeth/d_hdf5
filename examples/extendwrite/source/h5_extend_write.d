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

  This example shows how to work with extendible dataset.
  In the current version of the library dataset MUST be
  chunked.
*/


import hdf5.hdf5;

import std.stdio;
import std.exception;
import std.string;

string H5FILE_NAME="SDSextendible.h5";
string DATASETNAME="ExtendibleArray";
enum RANK         =2;
enum NX     =10;
enum  NY     =5;

int main(string[] args)
{
    hid_t       file;                          /* handles */
    hid_t       dataspace, dataset;
    hid_t       filespace;
    hid_t       cparms;
    hsize_t[2]     dims  = [3, 3];            /*
             * dataset dimensions
             * at the creation time
             */
    hsize_t[2] dims1 = [ 3, 3];            /* data1 dimensions */
    hsize_t[2] dims2 = [ 7, 1];            /* data2 dimensions */
    hsize_t[2] dims3 = [ 2, 2];            /* data3 dimensions */

    hsize_t[2] maxdims = [H5S_UNLIMITED, H5S_UNLIMITED];
    hsize_t[2] chunk_dims =[2, 5];
    hsize_t[2] size;
    hsize_t[2] offset;

    herr_t status;

    int[3][3] data1 = [ [1, 1, 1],       /* data to write */
                        [1, 1, 1],
                        [1, 1, 1]];

    int[7] data2    = [2, 2, 2, 2, 2, 2, 2];

    int[2][2] data3 = [[3, 3],
                       [3, 3]];
    int fillvalue = 0;

    writefln("* Create the data space with unlimited dimensions.");
    dataspace = H5S.create_simple(dims, maxdims); //
    writefln("* Create a new file. If file exists its contents will be overwritten.");
    file = H5F.create(H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
    cparms = H5P.create(H5P_DATASET_CREATE); // Modify dataset creation properties, i.e. enable chunking.
    H5P.set_chunk( cparms, chunk_dims);
    H5P.set_fill_value (cparms, H5T_NATIVE_INT, &fillvalue );

    writefln("* Create a new dataset within the file using cparmscreation properties.");
    dataset = H5D.create2(file, DATASETNAME, H5T_NATIVE_INT, dataspace, H5P_DEFAULT, cparms, H5P_DEFAULT);

    writefln("* Extend the dataset. This call assures that dataset is at least 3 x 3.");
    size[0]   = 3;
    size[1]   = 3;
    writefln("* Calling to set_extent");
    H5D.set_extent(dataset, size);

    writefln("* Select a hyperslab.");
    filespace = H5D.get_space(dataset); 
    offset[0] = 0;
    offset[1] = 0;
    // H5S.select_hyperslab(filespace, H5SSeloper.Set, offset, cast(hsize_t[])[], dims1, cast(hsize_t[])[]);
    H5S.select_hyperslab(filespace, H5SSeloper.Set, offset, dims1);

    writefln("* Write the data to the hyperslab.");
    H5D.write(dataset, H5T_NATIVE_INT, dataspace, filespace, H5P_DEFAULT, cast(ubyte*)data1);

    writefln("* Extend the dataset. Dataset becomes 10 x 3.");
    dims[0]   = dims1[0] + dims2[0]; 
    size[0]   = dims[0];
    size[1]   = dims[1];
    writefln("* calling set_extent");
    H5D.set_extent(dataset, size);

    writefln("* Select a hyperslab.");
    filespace = H5D.get_space(dataset); 
    offset[0] = 3;
    offset[1] = 0;
    H5S.select_hyperslab(filespace, H5SSeloper.Set, offset, dims2);

    writefln("* Define memory space");
    dataspace = H5S.create_simple(dims2); 
    H5D.write(dataset, H5T_NATIVE_INT, dataspace, filespace, H5P_DEFAULT, cast(ubyte*)data2); // // Write the data to the hyperslab.
    
    writefln("* Extend the dataset. Dataset becomes 10 x 5");
    dims[1]   = dims1[1] + dims3[1];
    size[0]   = dims[0];
    size[1]   = dims[1];
    H5D.set_extent(dataset, size);

    writefln("* Select a hyperslab");
    filespace = H5D.get_space(dataset);
    offset[0] = 0;
    offset[1] = 3;
    H5S.select_hyperslab(filespace, H5SSeloper.Set, offset, dims3);
    writefln("* Define memory space");
    dataspace = H5S.create_simple(dims3);

    writefln("* Write the data to the hyperslab");
    H5D.write(dataset, H5T_NATIVE_INT, dataspace, filespace, H5P_DEFAULT, cast(ubyte*)data3);

    /**
        Resulting dataset
     *
        3 3 3 2 2
        3 3 3 2 2
        3 3 3 0 0
        2 0 0 0 0
        2 0 0 0 0
        2 0 0 0 0
        2 0 0 0 0
        2 0 0 0 0
        2 0 0 0 0
        2 0 0 0 0
    */
    writefln("* Close/release resources");
    H5D.close(dataset);
    H5S.close(dataspace);
    H5S.close(filespace);
    H5P.close(cparms);
    H5F.close(file);
    return 0;
}