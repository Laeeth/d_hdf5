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

  This example shows a way to recursively traverse the file
  using H5Giterate.  The method shown here guarantees that
  the recursion will not enter an infinite loop, but does
  not prevent objects from being visited more than once.
  The program prints the directory structure of the file
  specified in FILE.  The default file used by this example
  implements the structure described in the User's Guide,
  chapter 4, figure 26.
*/ 

import hdf5.wrap;
import hdf5.bindings.enums;
import std.file;
import std.stdio;
import std.exception;
import std.string;
import std.conv;
import std.process;

enum filename="../h5data/h5ex_g_traverse.h5";

/*
 * Define operator data structure type for H5Giterate callback.
 * During recursive iteration, these structures will form a
 * linked list that can be searched for duplicate groups,
 * preventing infinite recursion.
 */
struct opdata {
    uint recurs;         /* recursion level.  0=root */
    opdata   *prev;          /* pointer to previous opdata */
    ulong[2] groupno;     /* unique group number */
}

int main(string[] args)
{
    hid_t           file;           /* Handle */
    H5GStat      statbuf;
    opdata   od;

    /*
     * Open file and initialize the operator data structure.
     */
    file = H5F.open (FILE, H5F_ACC_RDONLY, H5P_DEFAULT);
    H5G.get_objinfo (file, "/", 0, &statbuf);
    od.recurs = 0;
    od.prev = NULL;
    od.groupno[0] = statbuf.objno[0];
    od.groupno[1] = statbuf.objno[1];

    /*
     * Print the root group and formatting, begin iteration.
     */
    writefln("/ {");
    H5G.iterate(file, "/", NULL, op_func, cast(void *) &od);
    writefln("}");

    /*
     * Close and release resources.
     */
    H5F.close (file);

    return 0;
}


/************************************************************

  Operator function.  This function prints the name and type
  of the object passed to it.  If the object is a group, it
  is first checked against other groups in its path using
  the group_check function, then if it is not a duplicate,
  H5Giterate is called for that group.  This guarantees that
  the program will not enter infinite recursion due to a
  circular path in the file.

// need to fix this to reflect new API
 ************************************************************/

herr_t op_func (hid_t loc_id, const char *name, void *operator_data)
{
    herr_t          return_val = 0;
    opdata   *od = cast(opdata *) operator_data;
    uint        spaces = 2*(od.recurs+1); // whitespace prepadding
    /*
     * Get type of the object and display its name and type.
     * The name of the object is passed to this function by
     * the Library.
     */
    H5OInfo buf;
    H5O.get_info(loc_id,&buf);
    writef("%*s", spaces, "");     /* Format output */
    switch (buf.type) {
        case H5G_GROUP:
            writefln("Group: %s {", name);
            /*
             * Check group objno against linked list of operator
             * data structures.  Only necessary if there is more
             * than 1 link to the group.
             */
            if ( (statbuf.nlink > 1) && group_check (od, statbuf.objno) ) {
                writefln("%*s  Warning: Loop detected!", spaces, "");
            }
            else {

                /*
                 * Initialize new operator data structure and
                 * begin recursive iteration on the discovered
                 * group.  The new opdata structure is given a
                 * pointer to the current one.
                 */
                opdata nextod;
                nextod.recurs = od.recurs + 1;
                nextod.prev = od;
                nextod.groupno[0] = statbuf.objno[0];
                nextod.groupno[1] = statbuf.objno[1];
                return_val = H5Giterate (loc_id, name, NULL, op_func, cast(void *) &nextod);
            }
            writef ("%*s}\n", spaces, "");
            break;
        case H5G_DATASET:
            writefln("Dataset: %s", name);
            break;
        case H5G_TYPE:
            writefln("Datatype: %s", name);
            break;
        default:
            writefln( "Unknown: %s", name);
    }

    return return_val;
}


/************************************************************
  This function recursively searches the linked list of
  opdata structures for one whose groupno field matches
  target_groupno.  Returns 1 if a match is found, and 0
  otherwise.
 ************************************************************/
int group_check(opdata *od, ulong[2] target_groupno)
{
    if ( (od.groupno[0] == target_groupno[0]) &&
                (od.groupno[1] == target_groupno[1]) )
        return 1;       /* Group numbers match */
    else if (!od.recurs)
        return 0;       /* Root group reached with no matches */
    else
        return group_check (od.prev, target_groupno);
                        /* Recursively examine the next node */
}
