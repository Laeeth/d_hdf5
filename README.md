hdf5-d
========

D bindings for the parallel [HDF5 library](http://www.hdfgroup.org/HDF5/).

## License

These bindings are made available under the [Boost Software License 1.0](http://www.boost.org/LICENSE_1_0.txt).
HDF5 is subject to [its own license](COPYING).

## Limitations/Known issues

- This set of bindings is based on hdf5-1.8.13.

- Similarly to the FORTRAN bindings, it is required to call H5open() manually once before starting to use HDF5. It is recommended to also use H5check_version to check whether the version of these bindings matches the version of the HDF5 library.

- This is a work in progress tested only in the context of its use in [DLBC](https://github.com/SFrijters/DLBC).

- Pull requests to improve these bindings are welcomed!

