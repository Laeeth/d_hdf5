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

  This example shows how to read data from a chunked dataset.
  We will read from the file created by h5_extend_write.d
*/ 

import hdf5.wrap;
import hdf5.bindings.enums;
import std.stdio;
import std.exception;
import std.string;

string H5FILE_NAME="hdf5/SDSextendible.h5";
string DATASETNAME="ExtendibleArray";
enum RANK         =2;
enum RANKC        =1;
enum NX     =10;
enum  NY     =5;

int main(string[] args)
{
    hid_t       file;                        /* handles */
    hid_t       dataset;
    hid_t       filespace;
    hid_t       memspace;
    hid_t       cparms;
    hsize_t     dims[2];                     /* dataset and chunk dimensions*/
    hsize_t     chunk_dims[2];
    hsize_t     col_dims[1];
    hsize_t     count[2];
    hsize_t     offset[2];

    herr_t      status_n;

    int[NY][NX] data_out;  /* buffer for dataset to be read */
    int[5][2]   chunk_out;   /* buffer for chunk to be read */
    int[10] column;        /* buffer for column to be read */
    int         rank, rank_chunk;

    writefln("* Open the file and the dataset");
    file = H5F.open(H5FILE_NAME, H5F_ACC_RDONLY, H5P_DEFAULT);
    dataset = H5D.open2(file, DATASETNAME, H5P_DEFAULT);

    writefln("* Get dataset rank and dimension");
    filespace = H5D.get_space(dataset);    
    rank      = H5S.get_simple_extent_ndims(filespace);
    status_n  = H5S.get_simple_extent_dims(filespace, dims[]);
    writefln("dataset rank %s, dimensions %s x %s", rank, dims[0], dims[1]);

    writefln("* Define the memory space to read dataset");
    memspace = H5S.create_simple(dims[]);
    writefln("* Read dataset back and display");
    H5D.read(dataset, H5T_NATIVE_INT, memspace, filespace, H5P_DEFAULT, cast(ubyte*)data_out);
    writefln("\n");
    writefln("Dataset: \n");
    foreach(j;0..dims[0])
    {
    	foreach(i;0..dims[1])
            writef("%d ", data_out[j][i]);
        writefln("");
    }

    writefln("* Close/release resources");
    H5S.close(memspace);

    /*
     *	    dataset rank 2, dimensions 10 x 5
     *	    chunk rank 2, dimensions 2 x 5

     *	    Dataset:
     *	    1 1 1 3 3
     *	    1 1 1 3 3
     *	    1 1 1 0 0
     *	    2 0 0 0 0
     *	    2 0 0 0 0
     *	    2 0 0 0 0
     *	    2 0 0 0 0
     *	    2 0 0 0 0
     *	    2 0 0 0 0
     *	    2 0 0 0 0
     */

    writefln("* Read the third column from the dataset");
    writefln("* First define memory dataspace, then define hyperslab");
    writefln("* and read it into column array.");
    col_dims[0] = 10;
    memspace =  H5S.create_simple(col_dims);

    /*
     * Define the column (hyperslab) to read.
     */
    offset[0] = 0;
    offset[1] = 2;
    count[0]  = 10;
    count[1]  = 1;
    H5S.select_hyperslab(filespace, H5SSeloper.Set, offset, count );
    H5D.read(dataset, H5T_NATIVE_INT, memspace, filespace, H5P_DEFAULT, cast(ubyte*)column);
    writefln("");
    writefln("* Third column:");
    foreach(i;0..10)
    	writef("%s ", column[i]);
    writefln("");

    writefln("* Close/release resources");
    H5S.close(memspace);

    /*
     *	    Third column:
     *	    1
     *	    1
     *	    1
     *	    0
     *	    0
     *	    0
     *	    0
     *	    0
     *	    0
     *	    0
     */

    writefln("* Get creation properties list");
    cparms = H5D.get_create_plist(dataset); /* Get properties handle first. */

    if (H5DLayout.Chunked== H5P.get_layout(cparms))
    {
        writefln("* Get chunking information: rank and dimensions");
    	rank_chunk = H5P.get_chunk(cparms, chunk_dims[]);
    	writefln("chunk rank %d, dimensions %s x %s", rank_chunk, chunk_dims[0], chunk_dims[1]);
        writefln("* Define the memory space to read a chunk");
        memspace = H5S.create_simple(chunk_dims);
        writefln("* Define chunk in the file (hyperslab) to read");
        offset[0] = 2;
        offset[1] = 0;
        count[0]  = chunk_dims[0];
        count[1]  = chunk_dims[1];
        H5S.select_hyperslab(filespace, H5SSeloper.Set, offset,count);
        writefln("* Read chunk back and display");
        H5D.read(dataset, H5T_NATIVE_INT, memspace, filespace, H5P_DEFAULT, cast(ubyte*)chunk_out);
        writefln("");
        writefln("Chunk: ");
        foreach(j;0..chunk_dims[0]){
            foreach(i;0..chunk_dims[1])
                writef("%s ", chunk_out[j][i]);
            writefln("");
    }
        /*
         *	 Chunk:
         *	 1 1 1 0 0
         *	 2 0 0 0 0
         */

        writefln("* Close/release resources");
        H5S.close(memspace);
    }

    /*
     * Close/release resources.
     */
    H5P.close(cparms);
    H5D.close(dataset);
    H5S.close(filespace);
    H5F.close(file);

    return 0;
}
