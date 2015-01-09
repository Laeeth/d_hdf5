
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

  *       This program illustrates how references to objects can be used.
  *       Program creates a dataset and a group in a file. It also creates
  *       second dataset, and references to the first dataset and the group
  *       are stored in it.
  *       Program reopens the file and reads dataset with the references.
  *       References are used to open the objects. Information about the
  *       objects is displayed.
*/

import hdf5;
import std.stdio;
import std.exception;
import std.string;


enum H5FILE_NAME="refere.h5";

int main(string[] args)
{
   hid_t fid;                         /* File, group, datasets, datatypes */
   hid_t gid_a;                       /* and  dataspaces identifiers   */
   hid_t did_b, sid_b, tid_b;
   hid_t did_r, tid_r, sid_r;
   H5OType obj_type;
   herr_t status;

   H5OType[2] wbuf; /* buffer to write to disk */
   H5OType[2] rbuf; /* buffer to read from disk */


   hsize_t[1] dim_r;
   hsize_t[2] dim_b;

   /*
    *  Create a file using default properties.
    */
   fid = H5F.create(H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

   /*
    *  Create  group "A" in the file.
    */
   gid_a = H5G.create2(fid, "A", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  /*
   *  Create dataset "B" in the file.
   */
   dim_b[0] = 2;
   dim_b[1] = 6;
   sid_b = H5S.create_simple(dim_b);
   did_b = H5D.create2(fid, "B", H5T_NATIVE_FLOAT, sid_b, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

   /*
    *  Create dataset "R" to store references to the objects "A" and "B".
    */
   dim_r[0] = 2;
   sid_r = H5S.create_simple(dim_r);
   tid_r = H5T.copy(H5T_STD_REF_OBJ);
   did_r = H5D.create2(fid, "R", tid_r, sid_r, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

   /*
    *  Create references to the group "A" and dataset "B"
    *  and store them in the wbuf.
    */
   H5R.create(&wbuf[0], fid, "A", H5RType.ObjectRef, cast(hid_t)-1);
   H5R.create(&wbuf[1], fid, "B", H5RType.ObjectRef, cast(hid_t)-1);

   /*
    *  Write dataset R using default transfer properties.
    */
   H5D.write(did_r, H5T_STD_REF_OBJ, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)wbuf);

   /*
    *  Close all objects.
    */
   H5G.close(gid_a);
   H5S.close(sid_b);
   H5D.close(did_b);
   H5T.close(tid_r);
   H5S.close(sid_r);
   H5D.close(did_r);
   H5F.close(fid);

   /*
    * Reopen the file.
    */
   fid = H5F.open(H5FILE_NAME, H5F_ACC_RDWR, H5P_DEFAULT);

   did_r  = H5D.open2(fid, "R", H5P_DEFAULT);
   H5D.read(did_r, H5T_STD_REF_OBJ, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)rbuf);

   /*
    * Find the type of referenced objects.
    */
    writefln("now trying to figure out obj type 1");
    H5R.get_obj_type2(did_r, H5RType.ObjectRef, &rbuf[0], &obj_type);
    if(obj_type == H5OType.Group)
        writefln("First dereferenced object is a group.");

    writefln("now trying to figure out obj type 2");
    H5R.get_obj_type2(did_r, H5RType.ObjectRef, &rbuf[1], &obj_type);
    if(obj_type == H5OType.Dataset)
        writefln("Second dereferenced object is a dataset.");

   /*
    *  Get datatype of the dataset "B"
    */
   did_b = H5R.dereference(did_r, H5RType.ObjectRef, &rbuf[1]);
   tid_b = H5D.get_type(did_b);
   if(H5Tequal(tid_b, H5T_NATIVE_FLOAT))
     writefln("Datatype of the dataset is H5T_NATIVE_FLOAT.");
   writefln("");
   H5D.close(did_r);
   H5D.close(did_b);
   H5T.close(tid_b);
   H5F.close(fid);
   return 0;
 }

