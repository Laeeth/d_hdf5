/**
    Ported by Laeeth Isharc 2014 to the D Programming Language
    Use at your own risk!

  This example shows how to set the space allocation time
  for a dataset.  The program first creates two datasets,
  one with the default allocation time (late) and one with
  early allocation time, and displays whether each has been
  allocated and their allocation size.  Next, it writes data
  to the datasets, and again displays whether each has been
  allocated and their allocation size.

  This file is intended for use with HDF5 Library version 1.6

*/

import hdf5.bindings.api;
import hdf5.bindings.enums;
import hdf5.wrap;
import std.stdio;
import std.file;

enum H5Dir="../h5data";
string f_name=H5Dir ~ "/h5ex_d_alloc.h5";
string DATASET1= "DS1";
string DATASET2="DS2";
enum DIM0=4;
enum DIM1=7;
enum FILLVAL=99;

int main (string[] args)
{
    hsize_t[2] dims = [DIM0, DIM1];
    int[DIM1][DIM0] wdata;  // write buffer
    if (!exists(H5Dir))
        mkdir(H5Dir);

    // Initialize data.
    foreach(i;0.. DIM0)
        foreach(j;0..DIM1)
            wdata[i][j] = i * j - j;

    // Create a new file using the default properties.
    hid_t file;
    file = H5F.create(f_name, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    // Create dataspace.  Leaving out maximum size sets the maximum size to be the current size.
    // passed as NULL to c API
    auto space = H5S.create_simple(dims);

    // Create the dataset creation property list, and set the chunk size
    auto dcpl = H5P.create (H5P_DATASET_CREATE);

    // Set the allocation time to "early".  This way we can be sure that reading from the dataset immediately
    // after creation will return the fill value.
    H5P.set_alloc_time (dcpl, H5DAllocTime.Early);

    writefln("Creating datasets...");
    writefln("%s has allocation time H5D_ALLOC_TIME_LATE", DATASET1);
    writefln("%s has allocation time H5D_ALLOC_TIME_EARLY", DATASET2);

    //Create the dataset using the dataset creation property list.
    auto dset1 = H5D.create2 (file, DATASET1, H5T_STD_I32LE, space, H5TCset.ASCII, dcpl ,H5P_DEFAULT);
    auto dset2 = H5D.create2(file, DATASET2, H5T_STD_I32LE, space, H5TCset.ASCII, dcpl,H5P_DEFAULT);

    // Retrieve and print space status and storage size for dset1.
    auto space_status = H5D.get_space_status (dset1);
    auto storage_size = H5D.get_storage_size (dset1);
    writefln("Space for %s has%sbeen allocated.", DATASET1,space_status == H5DSpaceStatus.Allocated ? " " : " not ");
    writefln("Storage size for %s is: %s bytes.", DATASET1,storage_size);

    // Retrieve and print space status and storage size for dset2.
    auto status = H5D.get_space_status (dset2);
    storage_size = H5D.get_storage_size (dset2);
    writefln("Space for %s has%sbeen allocated.", DATASET2, space_status == H5DSpaceStatus.Allocated ? " " : " not ");
    writefln("Storage size for %s is: %s bytes.", DATASET2, storage_size);
    writefln("\nWriting data...\n");

    // Write the data to the datasets.
    H5D.write(dset1, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&wdata);
    H5D.write(dset2, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&wdata);

    // Retrieve and print space status and storage size for dset1.
    status = H5D.get_space_status(dset1);
    storage_size = H5D.get_storage_size (dset1);
    writefln("Space for %s has%sbeen allocated.", DATASET1, space_status == H5DSpaceStatus.Allocated ? " " : " not ");
    writefln("Storage size for %s is: %s bytes.", DATASET1, storage_size);

    // Retrieve and print space status and storage size for dset2.
    status = H5D.get_space_status(dset2);
    storage_size = H5D.get_storage_size (dset2);
    writefln("Space for %s has%sbeen allocated.", DATASET2, space_status == H5DSpaceStatus.Allocated ? " " : " not ");
    writefln("Storage size for %s is: %s bytes.", DATASET2, storage_size);

    // Close and release resources.
    H5P.close(dcpl);
    H5D.close(dset1);
    H5D.close(dset2);
    H5S.close(space);
    H5F.close(file);
    return 0;
}
