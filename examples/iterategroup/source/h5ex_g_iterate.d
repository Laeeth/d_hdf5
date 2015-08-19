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

  This example shows how to iterate over group members using
  H5Giterate.
*/


import hdf5.hdf5;
import std.stdio;
import std.exception;

void main(string[] args)
{
  writefln("sorry but group iterate is not yet ported - bindings");
}
/+

enum   filename       ="d_examples/h5ex_g_iterate.h5";

/*
 * Operator function to be called by H5Giterate.
 */
herr_t op_func (hid_t loc_id, const char *name, void *operator_data);

int main(string[] args)
{
    hid_t           file;           /* Handle */
    herr_t          status;

    /*
     * Open file.
     */
    file = H5F.open (filename, H5F_ACC_RDONLY, H5P_DEFAULT);

    /*
     * Begin iteration.
     */
    writefln("Objects in root group:");
    status = H5G.iterate (file, "/", NULL, op_func, NULL);

    /*
     * Close and release resources.
     */
    status = H5F.close (file);
        return 0;
}


/************************************************************

  Operator function.  Prints the name and type of the object
  being examined.

 ************************************************************/
extern(C) herr_t op_func (hid_t loc_id, const char *name, void *operator_data)
{
    herr_t          status;
    H5G_stat_t      statbuf;

    /*
     * Get type of the object and display its name and type.
     * The name of the object is passed to this function by
     * the Library.
     */
    status = H5Gget_objinfo (loc_id, name, 0, &statbuf);
    switch (statbuf.type) {
        case H5G_GROUP:
            writef ("  Group: %s\n", name);
            break;
        case H5G_DATASET:
            writef ("  Dataset: %s\n", name);
            break;
        case H5G_TYPE:
            writef ("  Datatype: %s\n", name);
            break;
        default:
            writef ( "  Unknown: %s\n", name);
    }

    return 0;
}
+/