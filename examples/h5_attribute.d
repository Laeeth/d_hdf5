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

  This program illustrates the usage of the H5A Interface functions.
  It creates and writes a dataset, and then creates and writes array,
  scalar, and string attributes of the dataset.
   Program reopens the file, attaches to the scalar attribute using
   attribute name and reads and displays its value. Then index of the
   third attribute is used to read and display attribute values.
   The H5Aiterate function is used to iterate through the dataset attributes,
   and display their names. The function is also reads and displays the values
   of the array attribute.
*/

import hdf5.wrap;
import hdf5.bindings.enums;
import std.stdio;
import std.exception;
import std.string;

string H5FILE_NAME="h5/Attributes.h5";
enum RANK=  1;   /* Rank and size of the dataset  */
enum SIZE = 7;

enum ARANK  =2;   /* Rank and dimension sizes of the first dataset attribute */
enum ADIM1  =2;
enum ADIM2  =3;
string ANAME = "Float attribute";      /* Name of the array attribute */
string ANAMES= "Character attribute"; /* Name of the string attribute */


int main(string[] args)
{

   hid_t   file, dataset;       /* File and dataset identifiers */

   hid_t   fid;                 /* Dataspace identifier */
   hid_t   attr1, attr2, attr3; /* Attribute identifiers */
   hid_t   attr;
   hid_t   aid1, aid2, aid3;    /* Attribute dataspace identifiers */
   hid_t   atype, atype_mem;    /* Attribute type */
   H5TClass  type_class;

   hsize_t[] fdim = [SIZE];
   hsize_t[] adim = [ADIM1, ADIM2];  /* Dimensions of the first attribute  */

   float[ADIM2][ADIM1] matrix; /* Attribute data */

   herr_t  ret;                /* Return value */
   H5O_info_t oinfo;           /* Object info */
   char    string_out[80];     /* Buffer to read string attribute back */
   int     point_out;          /* Buffer to read scalar attribute back */

   // Data initialization.
   int[] vector = [1, 2, 3, 4, 5, 6, 7];  /* Dataset data */
   int point = 1;                         /* Value of the scalar attribute */
   immutable char* stringattrib = toStringz("ABCD");                /* Value of the string attribute */


   foreach(i;0..ADIM1)
       foreach(j;0..ADIM2)
        matrix[i][j] = -1.0;
   

   file = H5F.create(H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT); // Create a file.
   fid = H5S.create(H5SClass.Simple); //  * Create the dataspace for the dataset in the file.
   H5S.set_extent_simple(fid, fdim);
   dataset = H5D.create2(file, "Dataset", H5T_NATIVE_INT, fid, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT); //  Create the dataset in the file.
   H5D.write(dataset, H5T_NATIVE_INT, H5S_ALL , H5S_ALL, H5P_DEFAULT, cast(ubyte*)&vector);     //Write data to the dataset.

   aid1 = H5S.create(H5SClass.Simple); //     * Create dataspace for the first attribute.
   H5S.set_extent_simple(aid1, adim);
   attr1 = H5A.create2(dataset, ANAME, H5T_NATIVE_FLOAT, aid1, H5P_DEFAULT, H5P_DEFAULT); //     Create array attribute.
   H5A.write(attr1, H5T_NATIVE_FLOAT, cast(ubyte*)&matrix); //    * Write array attribute.
   aid2  = H5S.create(H5SClass.Scalar); //     * Create scalar attribute.
   attr2 = H5A.create2(dataset, "Integer attribute", H5T_NATIVE_INT, aid2, H5P_DEFAULT, H5P_DEFAULT);
   H5A.write(attr2, H5T_NATIVE_INT, cast(ubyte*)&point); //     *Write scalar attribute.
   // Create string attribute.
   aid3  = H5S.create(H5SClass.Scalar);
   atype = H5T.copy(H5T_C_S1);
   H5T.set_size(atype, 5);
   H5T.set_strpad(atype,H5TString.Nullterm);
   attr3 = H5A.create2(dataset, ANAMES, atype, aid3, H5P_DEFAULT, H5P_DEFAULT);
   H5A.write(attr3, atype, cast(ubyte*)stringattrib); //    Write string attribute.

   H5S.close(aid1);        //Close attribute and file dataspaces, and datatype.
   H5S.close(aid2);
   H5S.close(aid3);
   H5S.close(fid);
   H5T.close(atype);

   H5A.close(attr1); // Close the attributes.
   H5A.close(attr2);
   H5A.close(attr3);

   H5D.close(dataset); // Close the dataset.
   H5F.close(file); // Close the file.

   file = H5F.open(H5FILE_NAME, H5F_ACC_RDONLY, H5P_DEFAULT); // Reopen the file.

   dataset = H5D.open2(file, "Dataset", H5P_DEFAULT); // Open the dataset.

   // Attach to the scalar attribute using attribute name, then read and display its value.
   attr = H5A.open(dataset, "Integer attribute", H5P_DEFAULT);
   H5A.read(attr, H5T_NATIVE_INT, cast(ubyte*)&point_out);
   writefln("The value of the attribute \"Integer attribute\" is %s", point_out);
   H5A.close(attr);

   // Find string attribute by iterating through all attributes
   H5O.get_info(dataset, &oinfo);
   foreach(i;0.. oinfo.num_attrs)
   {
      attr = H5A.open_by_idx(dataset, ".", H5Index.CRTOrder, H5IterOrder.Inc, cast(hsize_t)i, H5P_DEFAULT, H5P_DEFAULT);
      atype = H5A.get_type(attr);
      type_class = H5T.get_class(atype);
      if (type_class == H5TClass.String) {
           atype_mem = H5T.get_native_type(atype, H5TDirection.Ascend);
           H5A.read(attr, atype_mem, cast(ubyte*)string_out);
           writefln("Found string attribute; its index is %d , value =   %s \n", i, ZtoString(string_out));
           H5T.close(atype_mem);
      }
       H5A.close(attr);
       H5T.close(atype);
    }

    // Get attribute info using iteration function.
   H5A.iterate2(dataset, H5Index.Name, H5IterOrder.Inc, cast(hsize_t*)0, &attr_info, cast(void*)0);

   // Close the dataset and the file.
   H5D.close(dataset);
   H5F.close(file);

   return 0;
}

// alias H5A_operator2_t = herr_t function(hid_t location_id/*in*/, const char *attr_name/*in*/, const H5A_info_t *ainfo/*in*/, void *op_data/*in,out*/);

extern(C) static herr_t attr_info(hid_t loc_id, const char *name, const H5A_info_t *ainfo, void *opdata)
{
    hid_t attr, atype, aspace;  /* Attribute, datatype and dataspace identifiers */
    int   rank;
    hsize_t[64] sdim;
    herr_t ret;
    size_t npoints;             /* Number of elements in the array attribute. */
    float[] float_array;         /* Pointer to the array attribute. */

    // avoid warnings
    opdata = opdata;

    // Open the attribute using its name.
     
    attr = H5A.open(loc_id, ZtoString(cast(char*)name), H5P_DEFAULT);

    // Display attribute name.
    writefln("\nName : %s", ZtoString(name));

    // Get attribute datatype, dataspace, rank, and dimensions.
    atype  = H5A.get_type(attr);
    aspace = H5A.get_space(attr);
    rank = H5S.get_simple_extent_ndims(aspace);
    ret = H5S.get_simple_extent_dims(aspace, sdim);

    // Display rank and dimension sizes for the array attribute.
    if(rank > 0)
    {
        writefln("Rank : %d", rank);
        writef("Dimension sizes : ");
        foreach(i;0..rank)
            writef("%s ", sdim[i]);
        writefln("");
    }

    // Read array attribute and display its type and values.

    if (H5TClass.Float== H5T.get_class(atype))
    {
        writefln("Type : FLOAT");
        npoints = H5S.get_simple_extent_npoints(aspace);
        float_array.length = npoints;
        H5A.read(attr, atype, cast(ubyte*)float_array);
        writefln("Values : ");
        foreach(i;0..npoints)
            writef("%f ", float_array[i]);
        writefln("");
    }

    // Release all identifiers.
    H5T.close(atype);
    H5S.close(aspace);
    H5A.close(attr);
    return 0;
}