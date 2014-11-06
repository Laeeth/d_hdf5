module hdf5.H5mpistub;

extern(C):

alias MPI_Datatype = int;
alias MPI_Comm = int;
alias MPI_Info = int;

enum MPI_LONG_LONG_INT = cast(MPI_Datatype) 0x4c000809;

