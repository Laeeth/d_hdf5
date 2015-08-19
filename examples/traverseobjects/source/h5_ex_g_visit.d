/************************************************************

  This example shows how to recursively traverse a file
  using H5Ovisit and H5Lvisit.  The program prints all of
  the objects in the file specified in FILE, then prints all
  of the links in that file.  

  This file is intended for use with HDF5 Library version 1.8

 ************************************************************/


import hdf5.hdf5;
import std.stdio;
import std.string;

//enum fname="h5ex_g_visit.h5";
enum fname="group.h5";
int main(string[] args)
{
    H5open();
    //open file
    //auto file = H5F.open(fname, H5F_ACC_RDONLY, H5P_DEFAULT);
    auto file = H5F.open(fname, H5F_ACC_RDONLY, H5P_DEFAULT);

    // Begin iteration using H5Ovisit
    writefln ("Objects in the file:");
    //H5O.visit (file, H5Index.Name, H5IterOrder.Native, &op_func, cast(void*)0);
    H5Ovisit (file, H5Index.Name, H5IterOrder.Native, &op_func, cast(void*)0);

    // Repeat the same process using H5Lvisit
    writefln  ("\nLinks in the file:");
    //H5L.visit(file, H5Index.Name, H5IterOrder.Native, &op_func_L, cast(void*)0);
    H5Lvisit(file, H5Index.Name, H5IterOrder.Native, &op_func_L, cast(void*)0);
    writefln("About to close");
    // Close and release resources.
    //H5F.close (file);
    H5Fclose (file);
    H5close();
    return 0;
}


//   Operator function for H5Ovisit.  This function prints the name and type of the object passed to it.
extern(C) herr_t op_func (hid_t loc_id, const (char *)name, const H5OInfo *info, void *operator_data)
{
    writef("/");               /* Print root group in object path */

    /*
     * Check if the current object is the root group, and if not print
     * the full path name and type.
     */
    if (name[0] == '.')         /* Root group, do not print '.' */
        writefln  ("  (Group)");
    else
    {
        auto namestring=ZtoString(name);
        switch (info.type) {
            case H5OType.Group:
                writefln  ("%s  (Group)", namestring);
                break;
            case H5OType.Dataset:
                writefln  ("%s  (Dataset)", namestring);
                break;
            case H5OType.NamedDataType:
                writefln  ("%s  (Datatype)", namestring);
                break;
            default:
                writefln  ("%s  (Unknown)", namestring);
        }
    }
    return 0;
}


/************************************************************

  Operator function for H5Lvisit.  This function simply
  retrieves the info for the object the current link points
  to, and calls the operator function for H5Ovisit.

 ************************************************************/
extern(C) herr_t op_func_L (hid_t loc_id, const (char *)name, const (H5LInfo*)info, void *operator_data)
{
    H5OInfo infobuf;
    /*
     * Get type of the object and display its name and type.
     * The name of the object is passed to this function by
     * the Library.
     */
    //H5O.get_info_by_name (loc_id, ZtoString(name), &infobuf, H5P_DEFAULT);
    H5Oget_info_by_name(loc_id,name, &infobuf, H5P_DEFAULT);
    //writefln("H5O: returning: name=%s",ZtoString(name));
    //writefln("H5O: returning: loc_id=%s, name=%s, infobuf=%s, operator_data=%s",loc_id,ZtoString(name),infobuf,operator_data);
    return 0; // op_func (loc_id, name, &infobuf, operator_data);
}
