import hdf5.wrap;
import hdf5.bindings.enums;
import hdf5.bindings.api;
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
	dumpDataSpaceVector("test.hdf5","AUD",app.data,true);
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

void dumpDataSpaceVector(T)(string filename,string datasetName, T[] data,bool append)
{
	hid_t file;
	T junk;

	hsize_t[1] chunk_dims =[260];
	hsize_t[]  dim = [data.length];
	auto space = H5S.create_simple(dim);
    	auto dataType = createDataType(data[0]);
	if ((exists(filename)) && (H5L.exists((file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT)),datasetName,H5P_DEFAULT)))
	{
		auto dataset = H5D.open2(file, datasetName, H5P_DEFAULT);
		if(append)
		{
			writefln("***APPEND");
			file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT);
			auto dataTypeData  = H5D.get_type(dataset);     /* datatype handle */
			auto t_class     = H5T.get_class(dataTypeData);
			auto order     = H5T.get_order(dataTypeData);
			auto size  = H5T.get_size(dataTypeData);
			auto dataspace = H5D.get_space(dataset);    /* dataspace handle */
			auto rank      = H5S.get_simple_extent_ndims(dataspace);
			hsize_t[1]     dims_out,   offset;
			auto status_n  = H5S.get_simple_extent_dims(dataspace, dims_out);
			dim=[dims_out[0]+data.length];
			H5D.set_extent(dataset, dim);
			auto filespace = H5D.get_space(dataset); 
	    		offset[0] = dims_out[0];
	    		auto dim2=[data.length];
			H5S.select_hyperslab(filespace, H5SSeloper.Set, offset, dim2);
			auto dataspace2 = H5S.create_simple(dim2);
			H5D.write(dataset, dataType, dataspace, filespace, H5P_DEFAULT, cast(ubyte*)data.ptr);
			H5T.close(dataType);
		    	H5S.close(space);
			H5D.close(dataset);
			H5F.close(file);
			return;

		}
		else // file exists and not append -> need to destroy dataset but keep others in this file
		{
			file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT);
			H5L.h5delete(file,datasetName,H5P_DEFAULT);
		}  
			
	}
	else {
		file = H5F.create(filename, H5F_ACC_TRUNC , H5P_DEFAULT, H5P_DEFAULT);
	}
	hsize_t[1] maxdims = [H5S_UNLIMITED];
	auto dataspace = H5S.create_simple(dim, maxdims);
	auto cparms = H5P.create(H5P_DATASET_CREATE); // Modify dataset creation properties, i.e. enable chunking.
    	H5P.set_chunk( cparms, chunk_dims);
    	H5P.set_fill_value (cparms, dataType, cast(void*)&junk);
    	auto dataset = H5D.create2(file, datasetName, dataType, space, H5P_DEFAULT, cparms, H5P_DEFAULT);
	auto filespace = H5D.get_space(dataset); 
    	H5D.write(dataset, dataType, dataspace,filespace, H5P_DEFAULT, cast(ubyte*)data.ptr);
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

	ubyte[100*1024] buf;

	auto dataTypeData  = H5D.get_type(dataset);     /* datatype handle */
	auto dataTypeNative  = createDataType(junk);
	auto t_class     = H5T.get_class(dataTypeData);
	auto order     = H5T.get_order(dataTypeData);
	auto size  = H5T.get_size(dataTypeData);
	auto dataspace = H5D.get_space(dataset);    /* dataspace handle */
	auto rank      = H5S.get_simple_extent_ndims(dataspace);
	hsize_t[2]     dims_out;
	auto status_n  = H5S.get_simple_extent_dims(dataspace, dims_out);
	writefln("%s",dataSpaceContents(buf, dataTypeData,dataspace));

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
