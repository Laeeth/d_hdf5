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

  This example writes data to the HDF5 file.
  Data conversion is performed during write operation.
 */

import hdf5.wrap;
import hdf5.bindings.enums;
import hdf5.bindings.api;
import std.stdio;
import std.exception;

string H5FILE_NAME="../h5data/SDS.h5";
string DATASETNAME="IntArray";
enum NX=5;                      /* dataset dimensions */
enum NY=6;
enum RANK=2;

int main(string[] args)
{
    hid_t       file, dataset;         /* file and dataset handles */
    hid_t       datatype, dataspace;   /* handles */
    hsize_t[2]     dimsf;              /* dataset dimensions */
    herr_t      status;
    int[NY][NX] data;          /* data to write */
    int i, j;

    writefln("* initializing buffer");
    // Data  and output buffer initialization.
    for(j = 0; j < NX; j++)
	for(i = 0; i < NY; i++)
	    data[j][i] = i + j;
    /*
     * 0 1 2 3 4 5
     * 1 2 3 4 5 6
     * 2 3 4 5 6 7
     * 3 4 5 6 7 8
     * 4 5 6 7 8 9
     */

    
    // Create a new file using H5F_ACC_TRUNC access, default file creation properties, and default file
    // access properties.
    writefln("* creating file %s",H5FILE_NAME);
    file = H5F.create(H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    // Describe the size of the array and create the data space for fixed size dataset.
    dimsf[0] = NX;
    dimsf[1] = NY;
    writefln("* creating dataspace with dims [%s,%s]",dimsf[0],dimsf[1]);
    dataspace = H5S.create_simple(dimsf);

    // Define datatype for the data in the file. We will store little endian INT numbers.
    writefln("* copying dataset");
    datatype = H5T.copy(H5T_NATIVE_INT);
    writefln("* byteorder = little-endian");
    H5T.set_order(datatype, H5TByteOrder.LE);

    // Create a new dataset within the file using defined dataspace and datatype and default dataset creation properties.
    writefln("* new dataset within file called %s",DATASETNAME);
    dataset = H5D.create2(file, DATASETNAME, datatype, dataspace, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

    // Write the data to the dataset using default transfer properties.
    writefln("* writing");
    H5D.write(dataset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&data);

    /*
     * Close/release resources.
     */
    writefln("* closing up shop");
    H5S.close(dataspace);
    H5T.close(datatype);
    H5D.close(dataset);
    H5F.close(file);

    return 0;
}
