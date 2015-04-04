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

  This shows how to use the hdf5 virtual file drivers.
  The example codes here do not check return values for the
  sake of simplicity.  As in all proper programs, return codes
  should be checked.
*/ 

import hdf5.wrap;
import hdf5.bindings.enums;
import hdf5.bindings.api;
import std.file;
import std.stdio;
import std.exception;
import std.string;
import std.conv;
import std.process;

/* global variables */
int cleanup_g	=	-1;	/* whether to clean.  Init to not set. */


// Cleanup a file unless $HDF5_NOCLEANUP is set.
void cleanup(string filename)
{
    if (cleanup_g == -1)
	cleanup_g = environment.get("HDF5_NOCLEANUP") ? 0 : 1;
    if (cleanup_g)
	   remove(filename);
}


/// This shows how to use the split file driver.
 
void split_file()
{
    hid_t fapl, fid;

    /* Example 1: Both metadata and rawdata files are in the same  */
    /*    directory.   Use Station1-m.h5 and Station1-r.h5 as      */
    /*    the metadata and rawdata files.                          */
    fapl = H5P.create(H5P_FILE_ACCESS);
    H5P.set_fapl_split(fapl, "-m.h5", H5P_DEFAULT, "-r.h5", H5P_DEFAULT);
    fid=H5F.create("Station1",H5F_ACC_TRUNC,H5P_DEFAULT,fapl);
    /* using the file ... */
    H5F.close(fid);
    H5P.close(fapl);
    /* Remove files created */
    cleanup("Station1-m.h5");
    cleanup("Station1-r.h5");

    /* Example 2: metadata and rawdata files are in different      */
    /*    directories.  Use PointA-m.h5 and /tmp/PointA-r.h5 as    */
    /*    the metadata and rawdata files.                          */
    fapl = H5P.create(H5P_FILE_ACCESS);
    H5P.set_fapl_split(fapl, "-m.h5", H5P_DEFAULT, "/tmp/%s-r.h5", H5P_DEFAULT);
    fid=H5F.create("PointA",H5F_ACC_TRUNC,H5P_DEFAULT,fapl);
    /* using the file ... */
    H5F.close(fid);
    H5P.close(fapl);
    /* Remove files created */
    cleanup("PointA-m.h5");
    cleanup("/tmp/PointA-r.h5");

    /* Example 3: Using default extension names for the metadata   */
    /*    and rawdata files.  Use Measure.meta and Measure.raw as  */
    /*    the metadata and rawdata files.                          */
    fapl = H5P.create(H5P_FILE_ACCESS);
    H5P.set_fapl_split(fapl, NULL, H5P_DEFAULT, NULL, H5P_DEFAULT);
    fid=H5F.create("Measure",H5F_ACC_TRUNC,H5P_DEFAULT,fapl);
    /* using the file ... */
    H5F.close(fid);
    H5P.close(fapl);
    /* Remove files created */
    cleanup("Measure.meta");
    cleanup("Measure.raw");
}

// Main Body
int main(string[] args)
{
    split_file();
    return(0);
}
