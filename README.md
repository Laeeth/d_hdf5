d_hdf5
=======

[![Join the chat at https://gitter.im/Laeeth/d_hdf5](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Laeeth/d_hdf5?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

D bindings and wrappers for the HDF5 scientific data format.  These differ from another project in being more C oriented and not exposing the Byzantine HDF5 class structure.  I think aldacron's version may be more object-oriented, although I have not looked at it.  Link [here](https://github.com/aldanor/h5d)

Relatively raw stage - there may be some bugs still, although it does work for my own projects.

Ported to D by Laeeth Isharc 2014, 2015.  Linux only I am afraid, although it should not be much work to port to Windows.

* Borrowed heavily from C API declarations in [Stefan Frijters bindings for D](https://github.com/SFrijters/hdf5-d)
* Three parts:
    1. Low-level C bindings: hdf5/bindings/api.d and hdf5/bindings/enum.d
    2. High-level D wrappers:  hdf5/wrap.d
            - currently these provide simple sugar such as accepting and returning D strings rather than char*.
            - over time I will work on developing these, but you can see code for dumping and retrieving an array of structs to/from an hdf5
                dataset in the file examples/traits.d.  Compile-time reflection is used to infer the format of the data set.  The mapping from D types
                to HDF5 dataset types is pretty basic, but usable.
    3. Ports of the example code from C to D.  Only some these have been finished, but they are enough to demonstrate the basic functionality.  See examples/*.d for the examples that work.  (To build run make or dub in the root directory).  Example C code that has not yet been ported is in the old/examples/notyetported/ directory

* To Do
    1.  Better exception handling that calls HDF5 to get error message and returns appropriate subclass of Exception
    2.  Unit tests (use example to build them)
    3.  Refinement of use of CTFE - better checking of types, allow tables of higher dimensions, allow reading tables where the record type is not known beforehand.
    4.  Integration with D dataframe library
    5.  I have started wrapping the high-level library.  The bindings are more or less done.  The wrappings I have only made a start on and for now the code is commented out.

Sample Use Code (Ported from the C example)
===========================================

```D
import hdf5.hdf5;
import std.stdio;
import std.exception;

enum filename="dset.h5";

int main(string[] args)
{

   int[600][1000] dset_data;

   H5open();
   // Initialize the dataset.
   foreach(i;0..dset_data.length)
      foreach(j;0..dset_data[0].length)
         dset_data[i][j] = cast(int)i * cast(int)dset_data.length + cast(int)j + 1;

   writefln("* opening %s",filename);
   // Open an existing file.
   auto file_id = H5F.open(filename, H5F_ACC_RDWR, H5P_DEFAULT);

   writefln("* opening /dset");
   // Open an existing dataset. 
   auto dataset_id = H5D.open2(file_id, "/dset", H5P_DEFAULT);

  // Write the dataset. 
   writefln("* writing dataset");
   H5D.write(dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)dset_data.ptr);
   writefln("* reading dataset");

   H5D.read(dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&dset_data).ptr;

   writefln("* closing dataset");
   /* Close the dataset. */
   H5D.close(dataset_id);
   writefln("* closing file");
   /* Close the file. */
   H5F.close(file_id);
   H5close();
  return 0;
}
```
Getting Started
===============

1.  Make sure you have the hdf5-1.8.15-patch1 version of the HDF5 C library - you should have libhdf5 and libhdf5_hl and check that /etd.dmd.conf knows where to find them.  The interface changes for HDF5 even with minor releases, and I do not have the manpower to maintain different versions of the bindings for different releases
2.  Build the examples
        cd examples
        dub build --force
        cd ..
4.  Type rdmd runexamples.d in the base directory to run the examples one by one.  Not all examples are finished or working


Pull requests welcomed, and I need to find a co-maintainer as I don't have time to do this consistently.
