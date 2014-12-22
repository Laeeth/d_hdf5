hdf5-d
========

Ported to D by Laeeth Isharc 2014

* Borrowed heavily in terms of C API declarations from [https://github.com/SFrijters/hdf5-d](Stefan Frijters bindings for D)
* Motivation: Frijters work not yet complete, and I wished to have a higher level D interface.
* Initially just using strings instead of chars, for example.  And exceptionsinstead of checking status code each time.  Later will add a higher level interface similarly to how it is done in h5py.

* Consider this not even alpha stage.  It probably isn't so far away from being useful though. This is written for Linux and will need modification to work on other platforms.


To Do
- 1. Better exception handling that calls HDF5 to get error and returns appropriate Throwable object
- 2. Unit tests
- 3. Thoughtfulness about using D CFTE/reflection/templating to make it work better - also variants etc.  Should be able to pass the data structure not cast(ubyte*); should automatically use reflection to deal with structs etc

The one file you need is hdf5.d in the bindings folder
See some of the example .d files in the d_examples folder for how to use.
Not all of these are finished yet.
