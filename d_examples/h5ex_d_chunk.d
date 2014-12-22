/**
    Ported by Laeeth Isharc 2014 to the D Programming Language
    Use at your own risk!

    This example shows how to create a chunked dataset.  The
    program first writes integers in a hyperslab selection to
    a chunked dataset with dataspace dimensions of DIM0xDIM1
    and chunk size of CHUNK0xCHUNK1, then closes the file.
    Next, it reopens the file, reads back the data, and
    outputs it to the screen.  Finally it reads the data again
    using a different hyperslab selection, and outputs
    the result to the screen.

    This file is intended for use with HDF5 Library version 1.6
*/
import hdf5;
import std.stdio;
import std.exception;

string fname="h5ex_d_chunk.h5";
string DATASET="DS1";
enum  DIM0            =6L;
enum DIM1            =8L;
enum CHUNK0          =4L;
enum CHUNK1          =4L;

int main(string[] args)
{
    hsize_t[2] dims=[DIM0,DIM1];
    hsize_t[2] chunk=[CHUNK0,CHUNK1];
    hsize_t[2] start,stride,count,block;
    int[DIM1][DIM0] wdata,rdata;        // write buffer, read buffer

    // Initialize data to "1", to make it easier to see the selections.
    foreach(i;0..DIM0)
        foreach(j;0..DIM1)
            wdata[i][j] = 1;

    // Print the data to the screen.
    writefln("Original Data:\n");
    foreach(i;0..DIM0)
    {
        writefln(" [");
        foreach(j;0..DIM1)
            writefln(" %3d", wdata[i][j]);
        writefln("]\n");
    }

    //  Create a new file using the default properties.
    auto file = H5F.create(fname, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    // Create dataspace.  Setting maximum size to NULL sets the maximum size to be the current size.
    auto space = H5S.create_simple(dims);

    // Create the dataset creation property list, and set the chunk size
    auto dcpl = H5P.create (H5P_DATASET_CREATE);
    H5P.set_chunk(dcpl, chunk);

    // Create the chunked dataset.
    auto dset = H5D.create2(file, DATASET, H5T_STD_I32LE, space, dcpl);

    // Define and select the first part of the hyperslab selection.
    start[0] = 0;
    start[1] = 0;
    stride[0] = 3;
    stride[1] = 3;
    count[0] = 2;
    count[1] = 3;
    block[0] = 2;
    block[1] = 2;
    H5S.select_hyperslab(space, H5SSeloper.Set , start, stride, count, block);

    /**
        Define and select the second part of the hyperslab selection,
        which is subtracted from the first selection by the use of H5S_SELECT_NOTB
    */
    block[0] = 1;
    block[1] = 1;
    H5S.select_hyperslab (space, H5SSeloper.NotB, start, stride, count, block);

    // Write the data to the dataset.
    H5D.write (dset, H5T_NATIVE_INT, H5S_ALL, space, H5P_DEFAULT, cast(ubyte*)&wdata);

    // Close and release resources.
    H5P.close(dcpl);
    H5D.close(dset);
    H5S.close(space);
    H5F.close(file);


    /*
     * Now we begin the read section of this example.
     */

    /*
     * Open file and dataset using the default properties.
     */
    file = H5F.open(fname, H5F_ACC_RDONLY, H5P_DEFAULT);
    dset = H5D.open(file, DATASET);

    /*
     * Retrieve the dataset creation property list, and print the
     * storage layout.
     */
    dcpl = H5D.get_create_plist (dset);
    auto layout = H5P.get_layout (dcpl);
    writefln("\nStorage layout for %s is: ", DATASET);
    switch (layout) {
        case H5DLayout.Compact:
            writefln("H5D_COMPACT\n");
            break;
        case H5DLayout.Contiguous:
            writefln("H5D_CONTIGUOUS\n");
            break;
        case H5DLayout.Chunked:
            writefln("H5D_CHUNKED\n");
        default:
            assert(0);
    }

    //  Read the data using the default properties.
    H5D.read(dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&rdata);

     // Output the data to the screen.
    writefln("\nData as written to disk by hyberslabs:");
    foreach(i;0..DIM0) {
        writef(" [");
        foreach(j;0..DIM1)
            writef(" %3d", rdata[i][j]);
        writefln("]");
    }

    // Initialize the read array.
    foreach(i;0..DIM0)
        foreach(j;0..DIM1)
            rdata[i][j] = 0;

    // Define and select the hyperslab to use for reading.
    space = H5Dget_space (dset);
    start[0] = 0;
    start[1] = 1;
    stride[0] = 4;
    stride[1] = 4;
    count[0] = 2;
    count[1] = 2;
    block[0] = 2;
    block[1] = 3;
    H5S.select_hyperslab (space, H5SSeloper.Set, start, stride, count, block);
    //  Read the data using the previously defined hyperslab.
    H5D.read(dset, H5T_NATIVE_INT, H5S_ALL, space, H5P_DEFAULT, cast(ubyte*)&rdata);

    /*
     * Output the data to the screen.
     */
    writefln("\nData as read from disk by hyperslab:");
    foreach(i;0..DIM0)
    {
        writefln(" [");
        foreach(j;0..DIM1)
            writef(" %3d", rdata[i][j]);
        writefln("]");
    }

    // Close and release resources.
    H5P.close(dcpl);
    H5D.close(dset);
    H5S.close(space);
    H5F.close(file);
    return 0;
}
