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
string H5FILE_NAME = "marketdata.hdf5";
string DATASETNAME  ="AUD";
enum LENGTH =10LU;
enum RANK          =1;
debug=0;
    align(1):
    struct s1_t
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
    writefln("* First structure  and dataset");
    s1_t[LENGTH] s1;
    hid_t s1_tid; //  File datatype identifier

    /* Second structure (subset of s1_t)  and dataset*/
    struct s2_t {
    	double c;
    	int    a;
    };
    //s2_t[LENGTH] s2;
    hid_t      s2_tid;    /* Memory datatype handle */

    /* Third "structure" ( will be used to read float field of s1) */
    hid_t      s3_tid;   /* Memory datatype handle */
    float[LENGTH] s3;
    hid_t      file, dataset, space; /* Handles */
    herr_t     status;
    hsize_t[]  dim = [LENGTH];   /* Dataspace dimensions */


    writefln("* Initialize the data");
    /*
    foreach(i,ref s;s1)
    {
        s.year=to!short(1900+i);
        s.month=cast(ubyte)i;
        //s1//s1[i].a = to!int(i);
        //s1[i].b = i*i;
        //s1[i].c = 1./(i+1);
    }
    foreach(i,s;s1)
    	writefln("%s",s);
    writefln("result=%s",dumpDataSpaceVector("test.hdf5","test",s1));
*/
s1_t[] s2;
if (exists("test.hdf5"))
{
    s2=slurpDataSpaceVector!s1_t("test.hdf5","AUD");
    writefln("result=%s",s2);
    writefln("returned okay and new length is %s", s2.length);
    foreach(i,s;s2)
    	writefln("%s",s);
}
    auto app=appender(s2);
    s1_t temp;
    foreach(i;0..30)
    {
    	temp.year=to!short(2000+i);
    	temp.month=cast(ubyte)((i%12)+1);
    	app.put(temp);
    }
    writefln("result=%s",dumpDataSpaceVector("test.hdf5","AUD",app.data));
return 1;
    writefln("* Create the data space.");
    space = H5S.create_simple(dim);
    writefln("* Create the file");
    file = H5F.create(H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
    writefln("* Create the memory data type");
    //s1_tid = H5T.create (H5TClass.Compound, s1_t.sizeof);
    s1_tid = createDataType(s1[0]);
    writefln("tid=%s",s1_tid);

    /*H5T.insert(s1_tid, "year", s1_t.year.offsetof, H5T_NATIVE_INT);
    H5T.insert(s1_tid, "month", s1_t.year.offsetof, H5T_NATIVE_INT);
    H5T.insert(s1_tid, "day", s1_t.year.offsetof, H5T_NATIVE_INT);
    H5T.insert(s1_tid, "open", s1_t.year.offsetof, H5T_NATIVE_DOUBLE);
    H5T.insert(s1_tid, "high", s1_t.year.offsetof, H5T_NATIVE_DOUBLE);
    H5T.insert(s1_tid, "low", s1_t.year.offsetof, H5T_NATIVE_DOUBLE);
    H5T.insert(s1_tid, "close", s1_t.year.offsetof, H5T_NATIVE_DOUBLE);
*/
    writefln("* Create the dataset");
    dataset = H5D.create2(file, DATASETNAME, s1_tid, space, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
    writefln("* Write data to the dataset");
    H5D.write(dataset, s1_tid, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&s1);
    writefln("* Release resources");
    H5T.close(s1_tid);
    H5S.close(space);
    H5D.close(dataset);
    H5F.close(file);

    
    writefln("* Open the file and the dataset");
    file = H5F.open(H5FILE_NAME, H5F_ACC_RDONLY, H5P_DEFAULT);
    dataset = H5D.open2(file, DATASETNAME, H5P_DEFAULT);
    auto datatype  = H5D.get_type(dataset);     /* datatype handle */
    auto t_class     = H5T.get_class(datatype);
    auto order     = H5T.get_order(datatype);
    auto size  = H5T.get_size(datatype);
    auto dataspace = H5D.get_space(dataset);    /* dataspace handle */
    auto rank      = H5S.get_simple_extent_ndims(dataspace);
    hsize_t[2]     dims_out;
    auto status_n  = H5S.get_simple_extent_dims(dataspace, dims_out);
    writefln("datatype=%s",datatype);
    writefln("t_class=%s",t_class);
    writefln("order=%s",order);
    writefln("size=%s",size);
    writefln("datatype=%s",datatype);
    writefln("rank=%s",rank);
    writefln("status_n=%s",status_n);

    writefln("rank %d, dimensions %s x %s ", rank, dims_out[0],dims_out[1]);


    s2_tid = createDataType(s1[0]);
    H5D.read(dataset, s2_tid, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)&s2);
    foreach(i,s;s2)
    	writefln("%s",s);

/*
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
*/
    	writefln("* Release resources");
    	H5T.close(s2_tid);
  	//  H5T.close(s3_tid);
    	H5D.close(dataset);
    	H5F.close(file);   
	return 0;
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

hid_t dumpDataSpaceVector(T)(string filename,string datasetName, T[] data)
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
	return file;
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

/*

		pragma(msg,member);
		pragma(msg,typeof(__traits(getMember,T,member)));
		enum t=typeof(__traits(getMember,T,member)).sizeof;
		enum t2=typeof(__traits(getMember,T,member)).stringof;
		enum t3=dTypeToHDF5[t2];
		enum t4=to!string(offsetof!(T,member));
		//mixin(fullyQualifiedName!(typenfield) ~ ".offsetof"); //__traits(getMember,T,member).offsetof;

		pragma(msg,t);
		pragma(msg,t2);
		pragma(msg,t3);
		pragma(msg,"offsetof="~t4);
		//makes sure to only serialise members that make sense, i.e. data
		enum isMemberVariable = is(typeof(() {
			__traits(getMember, val, member) = __traits(getMember, val, member).init;
		}));
		static if(isMemberVariable) {
			pragma(__msg,val);
		}
	}
	return datatype;
}

*/