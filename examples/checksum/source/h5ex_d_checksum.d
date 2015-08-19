/**
    Ported by Laeeth Isharc 2014 to the D Programming Language
    Use at your own risk!

  This example shows how to read and write data to a dataset
  using the Fletcher32 checksum filter.  The program first
  checks if the Fletcher32 filter is available, then if it
  is it writes integers to a dataset using Fletcher32, then
  closes the file.  Next, it reopens the file, reads back
  the data, checks if the filter detected an error and
  outputs the type of filter and the maximum value in the
  dataset to the screen.
*/

import hdf5.hdf5;
import std.stdio;
import std.exception;

alias hsize_t=ulong;

string fname="h5ex_d_checksum.h5";
string DATASET= "DS1";
enum DIM0            =32;
enum DIM1            =64;
enum  CHUNK0         =4;
enum CHUNK1          =8;

int main(string[] args)
{
    hid_t file, space, dcpl;
                                                /* Handles */
    H5ZFilter filter_type;
    hsize_t[2] dims = [DIM0, DIM1], chunk = [CHUNK0, CHUNK1];
    size_t nelmts;
    uint flags, filter_info;
    int[DIM1][DIM0] wdata,rdata; // write buffer, read buffer
    int max,i,j;

    /**
        Check if the Fletcher32 filter is available and can be used for
        both encoding and decoding.  Normally we do not perform error
        checking in these examples for the sake of clarity, but in this
        case we will make an exception because this filter is an
        optional part of the hdf5 library.
     */
    auto avail = H5Z.filter_avail(H5ZFilter.Fletcher32);
    if (!avail)
    {
        writefln("N-Bit filter not available.");
        return 1;
    }
    H5Z.get_filter_info (H5ZFilter.Fletcher32, &filter_info);
    if ( !(filter_info & H5Z_FILTER_CONFIG_ENCODE_ENABLED) || !(filter_info & H5Z_FILTER_CONFIG_DECODE_ENABLED) )
    {
        writefln("N-Bit filter not available for encoding and decoding.");
        return 1;
    }

    /*
     * Initialize data.
     */
    for (i=0; i<DIM0; i++)
        for (j=0; j<DIM1; j++)
            wdata[i][j] = i * j - j;

    /*
     * Create a new file using the default properties.
     */
    file = H5F.create (fname, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    /*
     * Create dataspace.  Setting maximum size to NULL sets the maximum
     * size to be the current size.
     */
    space = H5S.create_simple(dims);

    /*
     * Create the dataset creation property list, add the N-Bit filter
     * and set the chunk size.
     */
    dcpl = H5P.create(H5P_DATASET_CREATE);
    H5P.set_fletcher32(dcpl);
    H5P.set_chunk(dcpl, chunk);

    // Create the dataset.
    auto dset = H5D.create2(file, DATASET, H5T_STD_I32LE, space, H5TCset.ASCII,dcpl,H5P_DEFAULT);

    // Write the data to the dataset.
    H5D.write(dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&wdata);

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
    // H5ZFilter get_filter2(hid_t plist_id, uint filter, int *flags/*out*/, size_t *cd_nelmts/*out*/, uint cd_values[]/*out*/, size_t namelen, char name[], uint *filter_config /*out*/)
    filter_type = H5ZFilter.Deflate;
    // H5P.get_filter2(dcpl, 0, &flags, &nelmts, NULL, 0, NULL);
    writefln("Filter type is: %s",filter_type);
    // H5ZFilter.Defalte, Shugffle, Fletcher32, or SZip
    /**
        Read the data using the default properties.
        Check if the read was successful.  Normally we do not perform
        error checking in these examples for the sake of clarity, but in
        this case we will make an exception because this is how the
        fletcher32 checksum filter reports data errors.
    */

    try
    {
        H5D.read (dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&rdata);
    }
    catch(Throwable o)
    {
        stderr.writefln("Dataset read failed!");
        H5P.close (dcpl);
        H5D.close (dset);
        H5F.close (file);
        throw o;
    }


    // Find the maximum value in the dataset, to verify that it was  read correctly
    max = rdata[0][0];
    for (i=0; i<DIM0; i++)
        for (j=0; j<DIM1; j++)
            if (max < rdata[i][j])
                max = rdata[i][j];

    // Print the maximum value.
    writefln("Maximum value in %s is: %d", DATASET, max);

    // Close and release resources.
    H5P.close(dcpl);
    H5D.close(dset);
    H5F.close(file);
    return 0;
}
