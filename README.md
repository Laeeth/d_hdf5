hdf5-d
========

Ported to D by Laeeth Isharc 2014, 2015.  Linux only I am afraid, although it should not be much work to port to Windows.

* Borrowed heavily from C API declarations in [https://github.com/SFrijters/hdf5-d](Stefan Frijters bindings for D)
* Three parts:
    1. Low-level C bindings: hdf5/bindings/api.d and hdf5/bindings/enum.d
    2. High-level D wrappers:  hdf5/wrap.d
            - currently these provide simple sugar such as accepting and returning D strings rather than char*.
            - over time I will work on developing these, but you can see code for dumping and retrieving an array of structs to/from an hdf5
                dataset in the file examples/traits.d.  Compile-time reflection is used to infer the format of the data set.  The mapping from D types
                to HDF5 dataset types is pretty basic, but usable.
    3. Ports of the example code from C to D.  Only a few of these have been finished, but they are enough to demonstrate the basic
        functionality.  See d_examples/*.d for the examples that work.  (To build run make or dub in the root directory).  Example code that
        has not yet been ported is in the examples/toport/ directory

To Do
- 1. Better exception handling that calls HDF5 to get error message and returns appropriate subclass of Exception
- 2. Unit tests
- 3. Refinement of use of CTFE - better checking of types, allow tables of higher dimensions, allow reading tables where the record type is
         not known beforehand.

To Get Started.
- Make sure you have the HDF5 C library - regular and high level - installed and path set up eg LD_LIBRARY_PATH
- In your project import hdf5.bindings.d and import hd5.wrap.d
- Low level interface name structure eg H5Oopen.
- High level interface name structure eg H5O.open

Sample Code

import hdf5.wrap;
import hdf5.bindings.enums;
import std.stdio;
import std.exception;
import std.string;
import std.conv;
import std.traits;
import std.file;
import std.range;
import std.array;

alias hid_t = int;
enum LENGTH =10LU;
enum RANK          =1;
debug=0;
align(1):
struct PriceBar
{
   short year;
   ubyte month;
   ubyte day;
   double open;
   double high;
   double low;
   double close;
   long volume;
   long openInterest;
}


int main(string[] args)
{
    PriceBar[LENGTH] s1;
    hid_t PriceBarid; //  File datatype identifier

    PriceBar[] s2;
    if (exists("test.hdf5"))
    {
    s2=slurpDataSpaceVector!PriceBar("test.hdf5","AUD");
    writefln("result=%s",s2);
    writefln("returned okay and new length is %s", s2.length);
    foreach(i,s;s2)
    writefln("%s",s);
    }
    auto app=appender(s2);
    PriceBar temp;
    foreach(i;0..30)
    {
    temp.year=to!short(2000+i);
    temp.month=cast(ubyte)((i%12)+1);
    app.put(temp);
    }
    writefln("result=%s",dumpDataSpaceVector("test.hdf5","AUD",app.data));
    return 1;
}

hid_t createDataType(T)(T datatype)
{
    auto tid=H5T.create(H5TClass.Compound,datatype.sizeof);
    enum offsetof(alias type, string field) = mixin(type.stringof ~"."~field~".offsetof");

    foreach(member; __traits(derivedMembers, T))
    {
        debug writefln("member: %s: offset=%s",member,offsetof!(T,member));
        H5T.insert(tid, member, offsetof!(T,member), mapDtoHDF5Type(typeof(__traits(getMember,T,member)).stringof));
    }
    return tid;
}

hid_t mapDtoHDF5Type(string dType)
{
    switch(dType)
    {
        case "int":
            return H5T_NATIVE_INT;
        case "long":
            return H5T_NATIVE_LLONG;
        case "ubyte":
            return H5T_NATIVE_UCHAR;
        case "char":
            return H5T_NATIVE_SCHAR;
        case "ushort":
            return H5T_NATIVE_USHORT;
        case "short":
            return H5T_NATIVE_SHORT;
        case "float":
            return H5T_NATIVE_FLOAT;
        case "double":
            return H5T_NATIVE_DOUBLE;
        default:
            throw new Exception("unknown type: "~ dType);
    }
}

void dumpDataSpaceVector(T)(string filename,string datasetName, T[] data)
{
    hsize_t[]  dim = [data.length];
    auto space = H5S.create_simple(dim);
    hid_t file = H5F.create(filename, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
        auto dataType = createDataType(data[0]);
        auto dataset = H5D.create2(file, datasetName, dataType, space, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
        H5D.write(dataset, dataType, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)data.ptr);
    H5T.close(dataType);
        H5S.close(space);
    H5D.close(dataset);
    H5F.close(file);
}

T[] slurpDataSpaceVector(T)(string filename,string datasetName)
{
    T junk;
    T[] data;
    data.length=1;
    auto file = H5F.open(filename, H5F_ACC_RDONLY, H5P_DEFAULT);
    auto dataset = H5D.open2(file, datasetName, H5P_DEFAULT);
    auto dataTypeData  = H5D.get_type(dataset);     /* datatype handle */
    auto dataTypeNative  = createDataType(junk);
    auto t_class     = H5T.get_class(dataTypeData);
    auto order     = H5T.get_order(dataTypeData);
    auto size  = H5T.get_size(dataTypeData);
    auto dataspace = H5D.get_space(dataset);    /* dataspace handle */
    auto rank      = H5S.get_simple_extent_ndims(dataspace);
    hsize_t[2]     dims_out;
    auto status_n  = H5S.get_simple_extent_dims(dataspace, dims_out);
    debug
    {
        writefln("datatype=%s",dataTypeData);
        writefln("t_class=%s",t_class);
        writefln("order=%s",order);
        writefln("size=%s",size);
        writefln("status_n=%s",status_n);
        writefln("rank %d, dimensions %s x %s ", rank, dims_out[0],dims_out[1]);
    }
    if (rank!=1)
        throw new Exception("only handle vector ie rank 1 tables currently");
    data = new T[dims_out[0]];
    H5D.read(dataset, dataTypeNative, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)data.ptr);
    debug writefln("%s", "read passed");
    H5T.close(dataTypeData);
    H5T.close(dataTypeNative);
    H5S.close(dataspace);
    H5D.close(dataset);
    H5F.close(file);
    return data;
}
