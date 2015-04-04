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

  This program creates a group in the file and two datasets in the group.
  Hard link to the group object is created and one of the datasets is accessed
  under new name.
  Iterator functions are used to find information about the objects
  in the root group and in the created group.
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

string H5FILE_NAME="../h5data/group.h5";
enum RANK=2;

int main(string[] args)
{

    hid_t    file;
    hid_t    grp;
    hid_t    dataset, dataspace;
    
    herr_t   status;
    hsize_t[2] dims;
    hsize_t[2]  cdims;

    int      idx_f, idx_g;

    writefln("* H5open");
    H5open();
    writefln("* Create a file");
    file = H5F.create(H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
    writefln("* Create a group in the file");
    grp = H5G.create2(file, "/Data", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
    writefln("* Created group");
    /*
     * Create dataset "Compressed Data" in the group using absolute
     * name. Dataset creation property list is modified to use
     * GZIP compression with the compression effort set to 6.
     * Note that compression can be used only when dataset is chunked.
     */
    dims[0] = 1000;
    dims[1] = 20;
    cdims[0] = 20;
    cdims[1] = 20;
    dataspace = H5S.create_simple(dims);
    writefln("* Created dataspace");
    writefln("* Trying to create property list:%s",H5P_DATASET_CREATE);
    auto plist     = H5Pcreate(H5P_DATASET_CREATE);
    writefln("* Created property list: %s",plist);
    H5P.set_chunk(plist, cdims);
    writefln("* Set chunk");
    H5P.set_deflate( plist, 6);
    writefln("* Set deflate");
    dataset = H5D.create2(file, "/Data/Compressed_Data", H5T_NATIVE_INT, dataspace, H5P_DEFAULT, plist, H5P_DEFAULT);
    writefln("* Close the first dataset");
    H5S.close(dataspace);
    H5D.close(dataset);
    writefln("* Create the second dataset");
    dims[0] = 500;
    dims[1] = 20;
    dataspace = H5S.create_simple(dims);
    dataset = H5D.create2(file, "/Data/Float_Data", H5T_NATIVE_FLOAT, dataspace, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

    writefln("* Close the second dataset and file");
    H5S.close(dataspace);
    H5D.close(dataset);
    H5P.close(plist);
    H5G.close(grp);
    H5F.close(file);
    writefln("* Now reopen the file and group in the file");
    file = H5F.open(H5FILE_NAME, H5F_ACC_RDWR, H5P_DEFAULT);
    grp  = H5G.open2(file, "Data", H5P_DEFAULT);

    writefln("* Access \"Compressed_Data\" dataset in the group");
    dataset = H5D.open2(grp, "Compressed_Data", H5P_DEFAULT);
    if( dataset < 0) writefln(" Dataset 'Compressed-Data' is not found.");
    writefln("\"/Data/Compressed_Data\" dataset is open");

    writefln("* Close the dataset");
    H5D.close(dataset);

    writefln("* Create hard link to the Data group");
    H5L.create_hard(file, "Data", H5L_SAME_LOC, "Data_new", H5P_DEFAULT, H5P_DEFAULT);

    writefln("* We can access \"Compressed_Data\" dataset using created* hard link \"Data_new\"");
    dataset = H5D.open2(file, "/Data_new/Compressed_Data", H5P_DEFAULT);
    if( dataset < 0) writefln(" Dataset is not found.");
    writefln("\"/Data_new/Compressed_Data\" dataset is open");

    writefln("* Close the dataset");
    H5D.close(dataset);

    writefln("* Use iterator to see the names of the objects in the root group");
    H5L.iterate(file, H5Index.Name, H5IterOrder.Inc, &file_info);

    writefln("* Unlink  name \"Data\" and use iterator to see the names of the objects in the file root directory");
    H5L.h5delete(file, "Data", H5P_DEFAULT);
    H5L.iterate(file, H5Index.Name, H5IterOrder.Inc, &file_info);
    
    writefln("* Use iterator to see the names of the objects in the group Data_new");
    H5L.iterate_by_name(grp, "/Data_new", H5Index.Name, H5IterOrder.Inc, &group_info, H5P_DEFAULT);
    
    writefln("* Close the file");
    H5G.close(grp);
    H5F.close(file);
    return 0;
}

extern(C) static herr_t file_info(hid_t loc_id, const char *name, const H5LInfo *linfo, void *opdata)
{
    writefln("\nName : %s", ZtoString(name));
    return 0;
}

extern(C) static herr_t group_info(hid_t loc_id, const char *name, const H5LInfo *linfo, void *opdata)
{
    hid_t did;  /* dataset identifier  */
    hid_t tid;  /* datatype identifier */
    H5TClass t_class;
    hid_t pid;  /* data_property identifier */
    hsize_t[2] chunk_dims_out;
    int  rank_chunk;
    string name_s=ZtoString(name);

    writefln("* Open the datasets using their names");
    did = H5D.open2(loc_id, name_s, H5P_DEFAULT);

    // * Display dataset name.
    writefln("\nName : %s", name_s);

    // Display dataset information.
    tid = H5D.get_type(did);  /* get datatype*/
    pid = H5D.get_create_plist(did); /* get creation property list */

    //  Check if dataset is chunked.
    if(H5DLayout.Chunked == H5P.get_layout(pid))
    {
        // get chunking information: rank and dimensions.
        rank_chunk = H5P.get_chunk(pid, chunk_dims_out[]);
        writefln("chunk rank %d, dimensions %s x %s", rank_chunk,chunk_dims_out[0],chunk_dims_out[1]);
    }
    else {
        t_class = H5T.get_class(tid);
        if(t_class < 0) {
            writefln(" Invalid datatype.");
        }
        else {
            if(t_class == H5TClass.Integer)
                writefln(" Datatype is 'H5T_NATIVE_INTEGER'.");
            if(t_class == H5TClass.Float)
                writefln(" Datatype is 'H5T_NATIVE_FLOAT'");
            if(t_class == H5TClass.String)
                writefln(" Datatype is 'H5T_NATIVE_STRING'.");
            if(t_class == H5TClass.Bitfield)
                writefln(" Datatype is 'H5T_NATIVE_BITFIELD'.");
            if(t_class == H5TClass.Opaque)
                writefln(" Datatype is 'H5T_NATIVE_OPAQUE'.");
            if(t_class == H5TClass.Compound)
                writefln(" Datatype is 'H5T_NATIVE_COMPOUND'.");
        }
    }
    H5D.close(did);
    H5P.close(pid);
    H5T.close(tid);
    return 0;
}