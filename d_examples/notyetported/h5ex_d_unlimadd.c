/**
    Ported to D Language 2014 by Laeeth Isharc
 * Copyright by The HDF Group.                                               *
 * Copyright by the Board of Trustees of the University of Illinois.         *
 * All rights reserved.                                                      *
 *                                                                           *
 * This file is part of HDF5.  The full HDF5 copyright notice, including     *
 * terms governing use, modification, and redistribution, is contained in    *
 * the files COPYING and Copyright.html.  COPYING can be found at the root   *
 * of the source code distribution tree; Copyright.html can be found at the  *
 * root level of an installed copy of the electronic HDF5 document set and   *
 * is linked from the top-level documents page.  It can also be found at     *
 * http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          *
 * access to either file, you may request a copy from help@hdfgroup.org.     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  This example shows how to create and extend an unlimited
  dataset.  The program first writes integers to a dataset
  with dataspace dimensions of DIM0xDIM1, then closes the
  file.  Next, it reopens the file, reads back the data,
  outputs it to the screen, extends the dataset, and writes
  new data to the extended portions of the dataset.  Finally
  it reopens the file again, reads back the data, and
  outputs it to the screen.
*/

import hdf5;
import std.string;
import std.stdio;


enum FILE            ="h5ex_d_unlimadd.h5";
enum DATASET         ="DS1";
enum DIM0            =4;
enum DIM1            =7;
enum EDIM0           =6;
enum EDIM1           =10;
enum CHUNK0          =4;
enum CHUNK1          =4;

int main (string[] args)
{
    hid_t file, space, dset, dcpl;    /* Handles */
    herr_t status;
    hsize_t[2] dims = [DIM0, DIM1];
    hsize_t[2] extdims = [EDIM0, EDIM1];
    hsize_t[2] maxdims;
    hsize_t[2] chunk = [CHUNK0, CHUNK1];
    hsize_t[2] start,count;
    int[DIM1][DIM0]wdata[DIM0][DIM1];          /* Write buffer */
    int [EDIM1][EDIM0] wdata2;       /* Write buffer for
                                                   extension */
    int[][] rdata;                    /* Read buffer */
    int ndims;

    /*
     * Initialize data.
     */
    foreach(i;0..DIM0)
        foreach(j;0..DIM1)
            wdata[i][j] = i * j - j;

    /*
     * Create a new file using the default properties.
     */
    file = H5F.create (FILE, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    /*
     * Create dataspace with unlimited dimensions.
     */
    maxdims[0] = H5S_UNLIMITED;
    maxdims[1] = H5S_UNLIMITED;
    space = H5S.create_simple(dims, maxdims);

    /*
     * Create the dataset creation property list, and set the chunk
     * size.
     */
    dcpl = H5P.create (H5P_DATASET_CREATE);
    H5P.set_chunk(dcpl, 2, chunk);

    /*
     * Create the unlimited dataset.
     */
    dset = H5D.create (file, DATASET, H5T_STD_I32LE, space, dcpl);

    /*
     * Write the data to the dataset.
     */
    H5D.write (dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, wdata[0]);

    /*
     * Close and release resources.
     */
    H5Pclose (dcpl);
    H5Dclose (dset);
    H5Sclose (space);
    H5Fclose (file);


    /*
     * In this next section we read back the data, extend the dataset,
     * and write new data to the extended portions.
     */

    /*
     * Open file and dataset using the default properties.
     */
    file = H5F.open (FILE, H5F_ACC_RDWR, H5P_DEFAULT);
    dset = H5D.open (file, DATASET);

    /*
     * Get dataspace and allocate memory for read buffer.  This is a
     * two dimensional dataset so the dynamic allocation must be done
     * in steps.
     */
    space = H5D.get_space (dset);
    ndims = H5S.get_simple_extent_dims (space, dims, NULL);

    /*
     * Allocate array of pointers to rows.
     */
    //rdata = (int **) malloc (dims[0] * sizeof (int *));
    rdata.length=dims[0];
    /*
     * Allocate space for integer data.
     */
    //rdata[0] = (int *) malloc (dims[0] * dims[1] * sizeof (int));

    /*
     * Set the rest of the pointers to rows to the correct addresses.
     */
    //foreach(i;1..dims[0])
     //   rdata[i] = rdata[0] + i * dims[1];
    foreach(i;0..rdata.length)
        rdata[i].length=dims[1];
    /*
     * Read the data using the default properties.
     */
    H5Dread (dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, rdata.ptr);

    /*
     * Output the data to the screen.
     */
    writefln("Dataset before extension:");
    foreach(i;0..dims[0])
    {
        writef (" [");
        for (j=0; j<dims[1]; j++)
            writef (" %3d", rdata[i][j]);
        writefln("]");
    }

    status = H5Sclose (space);

    /*
     * Extend the dataset.
     */
    status = H5Dextend (dset, extdims);

    /*
     * Retrieve the dataspace for the newly extended dataset.
     */
    space = H5Dget_space (dset);

    /*
     * Initialize data for writing to the extended dataset.
     */
    for (i=0; i<EDIM0; i++)
        for (j=0; j<EDIM1; j++)
            wdata2[i][j] = j;

    /*
     * Select the entire dataspace.
     */
    status = H5Sselect_all (space);

    /*
     * Subtract a hyperslab reflecting the original dimensions from the
     * selection.  The selection now contains only the newly extended
     * portions of the dataset.
     */
    start[0] = 0;
    start[1] = 0;
    count[0] = dims[0];
    count[1] = dims[1];
    status = H5Sselect_hyperslab (space, H5S_SELECT_NOTB, start, NULL, count,
                NULL);

    /*
     * Write the data to the selected portion of the dataset.
     */
    status = H5Dwrite (dset, H5T_NATIVE_INT, H5S_ALL, space, H5P_DEFAULT,
                wdata2[0]);

    /*
     * Close and release resources.
     */
    //free (rdata[0]);
    //free(rdata);
    status = H5Dclose (dset);
    status = H5Sclose (space);
    status = H5Fclose (file);


    /*
     * Now we simply read back the data and output it to the screen.
     */

    /*
     * Open file and dataset using the default properties.
     */
    file = H5Fopen (FILE, H5F_ACC_RDONLY, H5P_DEFAULT);
    dset = H5Dopen (file, DATASET);

    /*
     * Get dataspace and allocate memory for the read buffer as before.
     */
    space = H5Dget_space (dset);
    ndims = H5Sget_simple_extent_dims (space, dims, NULL);
    rdata = (int **) malloc (dims[0] * sizeof (int *));
    rdata[0] = (int *) malloc (dims[0] * dims[1] * sizeof (int));
    for (i=1; i<dims[0]; i++)
        rdata[i] = rdata[0] + i * dims[1];

    /*
     * Read the data using the default properties.
     */
    status = H5Dread (dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT,
                rdata[0]);

    /*
     * Output the data to the screen.
     */
    writef ("\nDataset after extension:\n");
    for (i=0; i<dims[0]; i++) {
        writef (" [");
        for (j=0; j<dims[1]; j++)
            writef (" %3d", rdata[i][j]);
        writef ("]\n");
    }

    /*
     * Close and release resources.
     */
    free (rdata[0]);
    free(rdata);
    H5D.close(dset);
    H5S.close(space);
    H5F.close(file);
    return 0;
}
