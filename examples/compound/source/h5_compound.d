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

  This example shows how to create a compound data type,
  write an array which has the compound data type to the file,
  and read back fields' subsets.
*/ 

//import hdf5;
import hdf5.wrap;
import hdf5.bindings.enums;
import std.stdio;
import std.exception;
import std.string;
import std.conv;
import std.file:exists,mkdir;

enum H5Dir="../h5data";
string H5FILE_NAME = H5Dir~"/"~"SDScompound.h5";
string DATASETNAME  ="ArrayOfStructures";
enum LENGTH =10LU;
enum RANK          =1;

int main(string[] args)
{
    if (!exists(H5Dir))
        mkdir(H5Dir);
    writefln("* First structure  and dataset");
    struct s1_t {
	   int    a;
	   float  b;
	   double c;
    }
    s1_t[LENGTH] s1;
    hid_t s1_tid; //  File datatype identifier

    /* Second structure (subset of s1_t)  and dataset*/
    struct s2_t {
    	double c;
    	int    a;
    }
    s2_t[LENGTH] s2;
    hid_t      s2_tid;    /* Memory datatype handle */

    /* Third "structure" ( will be used to read float field of s1) */
    hid_t      s3_tid;   /* Memory datatype handle */
    float[LENGTH] s3;
    hid_t      file, dataset, space; /* Handles */
    herr_t     status;
    hsize_t[]  dim = [LENGTH];   /* Dataspace dimensions */


    writefln("* Initialize the data");
    foreach(i;0..LENGTH)
    {
        s1[i].a = to!int(i);
        s1[i].b = i*i;
        s1[i].c = 1./(i+1);
    }
    writefln("* Create the data space.");
    space = H5S.create_simple(dim);
    writefln("* Create the file");
    file = H5F.create(H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
    writefln("* Create the memory data type");
    s1_tid = H5T.create (H5TClass.Compound, s1_t.sizeof);
    H5T.insert(s1_tid, "a_name", s1_t.a.offsetof, H5T_NATIVE_INT);
    H5T.insert(s1_tid, "c_name", s1_t.c.offsetof, H5T_NATIVE_DOUBLE);
    H5T.insert(s1_tid, "b_name", s1_t.b.offsetof, H5T_NATIVE_FLOAT);
    writefln("* Create the dataset");
    dataset = H5D.create2(file, DATASETNAME, s1_tid, space, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
    writefln("* Write data to the dataset");
    H5D.write(dataset, s1_tid, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)s1);
    writefln("* Release resources");
    H5T.close(s1_tid);
    H5S.close(space);
    H5D.close(dataset);
    H5F.close(file);

    writefln("* Open the file and the dataset");
    file = H5F.open(H5FILE_NAME, H5F_ACC_RDONLY, H5P_DEFAULT);
    dataset = H5D.open2(file, DATASETNAME, H5P_DEFAULT);

    writefln("* Create a data type for s2");
    s2_tid = H5T.create(H5TClass.Compound, s2_t.sizeof);
    H5T.insert(s2_tid, "c_name", s2_t.c.offsetof, H5T_NATIVE_DOUBLE);
    H5T.insert(s2_tid, "a_name", s2_t.a.offsetof, H5T_NATIVE_INT);

    writefln("* Read two fields c and a from s1 dataset. Fields in the file are found by their names \"c_name\" and \"a_name\"");
    H5D.read(dataset, s2_tid, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)s2);

    writefln("* Display the fields");
    writefln("");
    writefln("Field c : ");
    foreach(i;0..LENGTH)
        writef("%.4f ", s2[i].c);
    writefln("");

    writefln("");
    writefln("Field a : ");
    foreach(i;0..LENGTH)
        writef("%d ", s2[i].a);
    writefln("");

    writefln("* Create a data type for s3");
    s3_tid = H5T.create(H5TClass.Compound, float.sizeof);
    H5T.insert(s3_tid, "b_name", 0, H5T_NATIVE_FLOAT);
    writefln("* Read field b from s1 dataset. Field in the file is found by its name");
    H5D.read(dataset, s3_tid, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)s3);

    writefln("* Display the field");
    writefln("Field b : ");
    foreach(i;0..LENGTH)
        writef("%.4f ", s3[i]);
    writefln("");

    writefln("* Release resources");
    H5T.close(s2_tid);
    H5T.close(s3_tid);
    H5D.close(dataset);
    H5F.close(file);
    return 0;
}
