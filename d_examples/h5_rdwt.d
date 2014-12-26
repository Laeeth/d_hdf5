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

   This example illustrates how to write and read data in an existing
   dataset.  It is used in the HDF5 Tutorial.
*/

import hdf5;
import std.stdio;
import std.exception;

enum filename="d_examples/dset.h5";

int main(string[] args)
{

   int[600][1000] dset_data;

   H5open();
   /* Initialize the dataset. */
   foreach(i;0..dset_data.length)
      foreach(j;0..dset_data[0].length)
         dset_data[i][j] = cast(int)i * cast(int)dset_data.length + cast(int)j + 1;

   writefln("* opening %s",filename);
   /* Open an existing file. */
   auto file_id = H5F.open(filename, H5F_ACC_RDWR, H5P_DEFAULT);

   writefln("* opening /dset");
   /* Open an existing dataset. */
   auto dataset_id = H5D.open2(file_id, "/dset", H5P_DEFAULT);

   /* Write the dataset. */
   writefln("* writing dataset");
   H5D.write(dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)dset_data);
   writefln("* reading dataset");

   H5D.read(dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&dset_data);

   writefln("* closing dataset");
   /* Close the dataset. */
   H5D.close(dataset_id);
   writefln("* closing file");
   /* Close the file. */
   H5F.close(file_id);
   H5close();
  return 0;
}
