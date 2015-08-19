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

  This example shows how to read and write bitfield
  datatypes to a dataset.  The program first writes bit
  fields to a dataset with a dataspace of DIM0xDIM1, then
  closes the file.  Next, it reopens the file, reads back
  the data, and outputs it to the screen.

*/ 

import hdf5.wrap;
import hdf5.bindings.enums;
import hdf5.bindings.api:H5open;
import std.file;
import std.stdio;
import std.exception;
import std.string;
import std.conv;
import std.process;


enum  filename            ="h5ex_t_bit.h5";
enum  DATASET         ="DS1";
enum  DIM0            =4;
enum  DIM1            =7;

int main(string[] args)
{
    hid_t           file, space, dset;          /* Handles */
    herr_t          status;
    hsize_t[2]         dims = [DIM0, DIM1];
    ubyte[DIM1][DIM0]   wdata; // write buff
    ubyte[] rdata;               // read
    int             ndims, A, B, C, D;
    
    H5open();
    /*
     * Initialize data.  We will manually pack 4 2-bit integers into
     * each unsigned char data element.
     */
    foreach(i;0..DIM0)
        foreach(j;0..DIM1)
        {
            wdata[i][j] = 0;
            wdata[i][j] |= (i * j - j) & 0x03;          /* Field "A" */
            wdata[i][j] |= (i & 0x03) << 2;             /* Field "B" */
            wdata[i][j] |= (j & 0x03) << 4;             /* Field "C" */
            wdata[i][j] |= ( (i + j) & 0x03 ) <<6;      /* Field "D" */
        }

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
     * Create the dataset and write the bitfield data to it.
     */
    dset = H5D.create2(file, DATASET, H5T_NATIVE_UCHAR, space, H5P_DEFAULT,H5P_DEFAULT,H5P_DEFAULT);
    H5D.write(dset, H5T_NATIVE_UCHAR, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)wdata.ptr);

    /*
     * Close and release resources.
     */
    H5D.close(dset);
    H5S.close(space);
    H5F.close(file);


    /*
     * Now we begin the read section of this example.  Here we assume
     * the dataset has the same name and rank, but can have any size.
     * Therefore we must allocate a new array to read in data using
     * malloc().
     */

    /*
     * Open file and dataset.
     */
    file = H5F.open(filename, H5F_ACC_RDONLY, H5P_DEFAULT);
    dset = H5D.open2(file, DATASET,H5P_DEFAULT);

    /*
     * Get dataspace and allocate memory for read buffer.  This is a
     * two dimensional dataset so the dynamic allocation must be done
     * in steps.
     */
    space = H5D.get_space (dset);
    ndims = H5S.get_simple_extent_dims(space,dims);

    /*
     * Allocate array of pointers to rows.
     */
    
    /*
     * Allocate space for bitfield data.
     */
    rdata.length=dims[0]*dims[1];
    
     // Read the data.
    H5D.read(dset, H5T_NATIVE_UCHAR, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)rdata.ptr);

    /*
     * Output the data to the screen.
     */
    writef ("%s is [%s x %s]\n", DATASET,dims[0],dims[1]);
    foreach(i;0..dims[0])
    {
        writef(" [");
        foreach(j;0..dims[1])
        {
            //writefln("%s,%s:%s",i,j,rdata[i*dims[1]+j]);
            A = rdata[i*dims[1]+j] & 0x03;         /* Retrieve field "A" */
            B = (rdata[i*dims[1]+j] >> 2) & 0x03;  /* Retrieve field "B" */
            C = (rdata[i*dims[1]+j] >> 4) & 0x03;  /* Retrieve field "C" */
            D = (rdata[i*dims[1]+j] >> 6) & 0x03;  /* Retrieve field "D" */
            writef (" [%s, %s, %s, %s]", A, B, C, D);
        }
        writef (" ]\n");
    }

    /*
     * Close and release resources.
     */
    H5D.close (dset);
    H5S.close (space);
    H5F.close (file);

    return 0;
}
