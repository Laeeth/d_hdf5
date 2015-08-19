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
*/
/* 
 *  This example illustrates how to read/write a subset of data (a slab) 
 *  from/to a dataset in an HDF5 file.  It is used in the HDF5 Tutorial.
 */
 
import hdf5;
import std.stdio;

enum filename=        "subset.h5";
enum DATASETNAME ="IntArray";
enum RANK  =2;

enum DIM0_SUB = 3;                         /* subset dimensions */ 
enum DIM1_SUB = 4 ;


enum DIM0     =8 ;                         /* size of dataset */       
enum DIM1     =10; 

int main(string[] args)
{
    hsize_t[2]  dims, dimsm;   
    int[DIM1][DIM0] data;           /* data to write */
    int[DIM1_SUB][DIM0_SUB] sdata;  /* subset to write */
    int[DIM1][DIM0] rdata;          /* buffer for read */
 
    hid_t       file_id, dataset_id;        /* handles */
    hid_t       dataspace_id, memspace_id; 

    herr_t      status;                             
   
    hsize_t[2]  count,offset,stride,block;              /* size of subset in the file */
                                                 /* subset offset in the file */

    
    /*****************************************************************
     * Create a new file with default creation and access properties.*
     * Then create a dataset and write data to it and close the file *
     * and dataset.                                                  *
     *****************************************************************/

    file_id = H5F.create (filename, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
    dims[0] = DIM0;
    dims[1] = DIM1;
    dataspace_id = H5S.create_simple(dims);

    dataset_id = H5D.create2(file_id, DATASETNAME, H5T_STD_I32BE, dataspace_id, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);


    foreach(j;0.. DIM0) {
	foreach(i;0..DIM1)
            if (i< (DIM1/2))
	       data[j][i] = 1;
            else
               data[j][i] = 2;
    }     

    H5D.write(dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)data);

    writefln("\nData Written to File:");
    foreach(i;0..DIM0){
       foreach(j;0..DIM1)
           writef (" %s", data[i][j]);
       writef ("\n");
    }
    H5S.close (dataspace_id);
    H5D.close (dataset_id);
    H5F.close (file_id);


    /*****************************************************
     * Reopen the file and dataset and write a subset of *
     * values to the dataset. 
     *****************************************************/

    file_id = H5F.open (filename, H5F_ACC_RDWR, H5P_DEFAULT);
    dataset_id = H5D.open2 (file_id, DATASETNAME, H5P_DEFAULT);

    /* Specify size and shape of subset to write. */

    offset[0] = 1;
    offset[1] = 2;

    count[0]  = DIM0_SUB;  
    count[1]  = DIM1_SUB;

    stride[0] = 1;
    stride[1] = 1;

    block[0] = 1;
    block[1] = 1;

    /* Create memory space with size of subset. Get file dataspace 
       and select subset from file dataspace. */

    dimsm[0] = DIM0_SUB;
    dimsm[1] = DIM1_SUB;
    memspace_id = H5S.create_simple(dimsm);

    dataspace_id = H5D.get_space (dataset_id);
    H5S.select_hyperslab (dataspace_id, H5SSeloper.Set, offset, stride, count, block);

    /* Write a subset of data to the dataset, then read the 
       entire dataset back from the file.  */

    writef ("\nWrite subset to file specifying:\n");
    writef ("    offset=1x2 stride=1x1 count=3x4 block=1x1\n");
    foreach(j;0.. DIM0_SUB) {
	foreach(i;0.. DIM1_SUB)
	   sdata[j][i] = 5;
    }     

    H5D.write (dataset_id, H5T_NATIVE_INT, memspace_id, dataspace_id, H5P_DEFAULT, cast(ubyte*)sdata);
    
    H5D.read (dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)rdata);

    writef ("\nData in File after Subset is Written:\n");
    foreach(i;0..DIM0){
       foreach(j;0..DIM1)
           writef (" %s", rdata[i][j]);
       writef ("\n");
    }

    H5S.close(memspace_id);
    H5S.close(dataspace_id);
    H5D.close(dataset_id);
    H5F.close(file_id);
    return 0;
}
