/**
	Simple example of using D reflection to create datasets.  Pre-alpha and use at your own risk

	(c) Laeeth Isharc 2015.  Released under the Boost license (same version as D's Phobos)

	Many opportunities to improve this.  Should recursive serialize data structure (at the moment it works on flat C-style structs).
	Probably should use saved dataset type rather than creating a new one each time (or at least delete the old ones).
	Not sure if I close all resources opened - this is a short-running process, so I have not yet bothered.

	userBlock functions not yet tested - friendlyCreate (will change the name later) was supposed to help create files with user block
	at the beginning to store metadata.  I got bogged down in updating the API and fixing bugs, so have not had time to get this fully
	working.

	Note that this code works but won't compile without my other libraries for dates (which I do not plan on releasing for now).
	It should be easy to change the data type.

	Pull requests welcomed.
*/


	module reflection;
import std.stdio;
import std.exception;
import std.string;
import std.conv;
import std.traits;
import std.file;
import std.range;
import std.array;
import hdf5.wrap;
import hdf5.bindings.api;
import hdf5.bindings.enums;
import kprop.dates.dates;

struct HDFPriceBar
{
   ushort year;
   ubyte month;
   ubyte day;
   ubyte hour;
   ubyte minute;
   float second;
   double open;
   double high;
   double low;
   double close;
   long volume;
   long openInterest;
}

PriceBar toPriceBar(HDFPriceBar hdfBar)
{
	PriceBar ret;
	ret.date=KPDateTime(hdfBar.year,hdfbar.month,hdfbar.day,hdfbar.hour,hdfBar.minute,hdfBar.second);
	ret.open=hdfBar.open;
	ret.high=hdfBar.high;
	ret.low=hdfBar.low;
	ret.close=hdfBar.close;
	ret.volume=hdfBar.volume;
	ret.openinterest=hdfBar.openInterest
	return ret;
}

PriceBar[] toPriceBars(HDFPriceBar[] hdfBars)
{
	PriceBar[] ret;
	ret.reserve(hdfBars.length);
	foreach(bar;hdfBars)
		ret~=bar.toPriceBar;
	return ret;
}

alias hid_t = int;
enum LENGTH =10LU;
enum RANK          =1;
enum CHUNKSIZE=260;
debug=0;
align(1):

hid_t createDataType(T)(T datatype)
{
	auto tid=H5T.create(H5TClass.Compound,datatype.sizeof);
	enum offsetof(alias type, string field) = mixin(type.stringof ~"."~field~".offsetof");

	foreach(member; __traits(derivedMembers, T))
	{
		// debug(5) writefln("member: %s: offset=%s",member,offsetof!(T,member));
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

enum DumpMode
{
	unlink,
	truncate,
	append,
}

void dumpDataSpaceVector(T)(string filename,string datasetName, T[] data,DumpMode mode=DumpMode.append)
{
	enforce((mode==DumpMode.unlink)||(mode==DumpMode.truncate)||(mode==DumpMode.append));
	bool fileExists=false;
	hid_t file;
	T junk;

	debug writefln("dumpDataSpaceVector called");
	hsize_t[1] chunk_dims =[CHUNKSIZE];
	hsize_t[]  dim = [data.length];
	auto space = H5S.create_simple(dim);
    auto dataType = createDataType(data[0]);
    fileExists=exists(filename);
	if ((fileExists) && (H5L.exists((file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT)),datasetName,H5P_DEFAULT)))
	{
		auto dataset = H5D.open2(file, datasetName, H5P_DEFAULT);
		if ((mode==DumpMode.append) || (mode==DumpMode.truncate))
		{
			// we should check here that it is an extensible dataset
			//debug writefln("DumpMode: %s",mode);
			file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT);
			auto dataTypeData  = H5D.get_type(dataset);     /* datatype handle */
			auto t_class     = H5T.get_class(dataTypeData);
			auto order     = H5T.get_order(dataTypeData);
			auto size  = H5T.get_size(dataTypeData);
			auto dataspace = H5D.get_space(dataset);    /* dataspace handle */
			auto rank      = H5S.get_simple_extent_ndims(dataspace);
			hsize_t[1]     dims_out,   offset;
			auto status_n  = H5S.get_simple_extent_dims(dataspace, dims_out);
			//debug writefln("dims_out[0]=%s; data.length=%s",dims_out[0],data.length);
			switch(mode)
			{
				case DumpMode.append:	dim=[dims_out[0]+data.length];
								offset[0] = dims_out[0];
	    							break;
				case DumpMode.truncate:	dim=[data.length];
								offset[0]=0;
								break;
				default:				assert(0);
			}
			H5D.set_extent(dataset, dim);
			//debug writefln("*set extent succeeded");
			
			auto filespace = H5D.get_space(dataset); 
			//debug writefln("*set filespace");
	    		auto dim2=[data.length];
			H5S.select_hyperslab(filespace, H5SSeloper.Set, offset, dim2);
			//debug writefln("*selected hyperslab");
			auto dataspace2 = H5S.create_simple(dim2);
			//debug writefln("*create simple dim2");
			H5D.write(dataset, dataType, dataspace2, filespace, H5P_DEFAULT, cast(ubyte*)data.ptr);
			H5T.close(dataType);
		    	H5S.close(space);
			H5D.close(dataset);
			H5F.close(file);
			return;

		}
		else // file exists, contains our dataset but not append -> need to destroy dataset but keep others in this file
		{
			enforce(mode==DumpMode.unlink);
			static if (false) debug writefln("* file exists and dataset unlink mode -> destroy dataset and keep other sets in file");
			file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT);
			static if (false) debug writefln("* file opened - now destroying dataset; keeping others");
			H5L.h5delete(file,datasetName,H5P_DEFAULT);
			static if (false) debug writefln("* destroyed");
		}  
			
	}
	else { // either file exists but doesnt contain our dataset, or it doesnt exist
		if (!fileExists)
		{
			static if (false) debug writefln("* file does not exist, so creating it");
			file = H5F.create(filename, H5F_ACC_TRUNC , H5P_DEFAULT, H5P_DEFAULT);
		}
		else {
			static if (false) debug writefln("* file exists but does not contain our dataset");
			file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT);
		}

	}
			
	hsize_t[1] maxdims = [H5S_UNLIMITED];
	debug writefln("* about to create data set"); stdout.flush;
	auto dataspace = H5S.create_simple(dim, maxdims);
	debug writefln("* dataspace created"); stdout.flush;
	auto cparms = H5P.create(H5P_DATASET_CREATE); // Modify dataset creation properties, i.e. enable chunking.
    H5P.set_chunk( cparms, chunk_dims);
    H5P.set_fill_value (cparms, dataType, cast(void*)&junk);
    debug writefln("* creating dataset"); stdout.flush;
    auto dataset = H5D.create2(file, datasetName, dataType, dataspace, H5P_DEFAULT, cparms, H5P_DEFAULT);
	auto filespace = H5D.get_space(dataset); 
	debug writefln("* writing data"); stdout.flush;
    H5D.write(dataset, dataType, dataspace,filespace, H5P_DEFAULT, cast(ubyte*)data.ptr);
    debug writefln("* finished writing data");
	H5T.close(dataType);
    	H5S.close(space);
	H5D.close(dataset);
	H5F.close(file);
	debug writefln("* finished closing files");
}


void dumpDataSpaceVector(T)(hid_t file,string datasetName, T[] data,DumpMode mode=DumpMode.append)
{
	enforce((mode==DumpMode.unlink)||(mode==DumpMode.truncate)||(mode==DumpMode.append));
	bool fileExists=false;
	T junk;

	hsize_t[1] chunk_dims =[CHUNKSIZE];
	hsize_t[]  dim = [data.length];
	debug writefln("* entered dumpDataSpaceVector"); stdout.flush;
	auto space = H5S.create_simple(dim);
	debug writefln("* created H5S"); stdout.flush;
    auto dataType = createDataType(data[0]);
	debug writefln("* datatype created"); stdout.flush;
    if ((H5L.exists(file,datasetName,H5P_DEFAULT)))
	{
		debug writefln("* H5L exists"); stdout.flush;
		auto dataset = H5D.open2(file, datasetName, H5P_DEFAULT);
		debug writefln("* H5D opened"); stdout.flush;
		if ((mode==DumpMode.append) || (mode==DumpMode.truncate))
		{
			debug writefln("* mode=append or truncate"); stdout.flush;
			// we should check here that it is an extensible dataset
			debug writefln("DumpMode: %s",mode);
			auto dataTypeData  = H5D.get_type(dataset);     /* datatype handle */
			debug writefln("* got datatype"); stdout.flush;
			auto t_class     = H5T.get_class(dataTypeData);
			debug writefln("* got class"); stdout.flush;
			auto order     = H5T.get_order(dataTypeData);
			debug writefln("* got order"); stdout.flush;
			auto size  = H5T.get_size(dataTypeData);
			debug writefln("* got size"); stdout.flush;
			auto dataspace = H5D.get_space(dataset);    /* dataspace handle */
			debug writefln("* got dataspace"); stdout.flush;
			auto rank      = H5S.get_simple_extent_ndims(dataspace);
			debug writefln("* got rank"); stdout.flush;
			hsize_t[1]     dims_out,   offset;
			auto status_n  = H5S.get_simple_extent_dims(dataspace, dims_out);
			debug writefln("dims_out[0]=%s; data.length=%s",dims_out[0],data.length);
			switch(mode)
			{
				case DumpMode.append:	dim=[dims_out[0]+data.length];
								offset[0] = dims_out[0];
	    							break;
				case DumpMode.truncate:	dim=[data.length];
								offset[0]=0;
								break;
				default:				assert(0);
			}
			H5D.set_extent(dataset, dim);
			debug writefln("*set extent succeeded");
			
			auto filespace = H5D.get_space(dataset); 
			debug writefln("*set filespace");
	    	auto dim2=[data.length];
			H5S.select_hyperslab(filespace, H5SSeloper.Set, offset, dim2);
			debug writefln("*selected hyperslab");
			auto dataspace2 = H5S.create_simple(dim2);
			debug writefln("*create simple dim2");
			H5D.write(dataset, dataType, dataspace2, filespace, H5P_DEFAULT, cast(ubyte*)data.ptr);
			H5T.close(dataType);
		    H5S.close(space);
			H5D.close(dataset);
			return;

		}
		else // need to destroy dataset but keep others in this file
		{
			enforce(mode==DumpMode.unlink);
			static if (false) debug writefln("* file exists and dataset unlink mode -> destroy dataset and keep other sets in file");
			static if (false) debug writefln("* file opened - now destroying dataset; keeping others");
			H5L.h5delete(file,datasetName,H5P_DEFAULT);
			static if (false) debug writefln("* destroyed");
		}  
			
	}
	else
	{
		 // file exists but doesnt contain our dataset
		debug writefln("* file exists but does not contain our dataset");
	}
			
	hsize_t[1] maxdims = [H5S_UNLIMITED];
	auto dataspace = H5S.create_simple(dim, maxdims);
	debug writefln("* h5s simple created"); stdout.flush;
	
	auto cparms = H5P.create(H5P_DATASET_CREATE); // Modify dataset creation properties, i.e. enable chunking.
    debug writefln("* h5p simple created"); stdout.flush;
	H5P.set_chunk( cparms, chunk_dims);

    debug writefln("* h5p set chunk"); stdout.flush;
    //cparms = H5P.create(H5P_DATASET_CREATE); // Modify dataset creation properties, i.e. enable chunking.
    H5P.set_fill_value (cparms, dataType, cast(void*)&junk);
    debug writefln("* creating dataset");
    auto dataset = H5D.create2(file, datasetName, dataType, dataspace, H5P_DEFAULT, cparms, H5P_DEFAULT);
    // tried to disable the above - what follows on this line is wrong auto dataset = H5D.create2(file, datasetName, dataType, dataspace, H5P_DEFAULT,H5P_DEFAULT, H5P_DEFAULT);
    debug writefln("* dataset created");
	auto filespace = H5D.get_space(dataset); 
	debug writefln("* writing data");
    H5D.write(dataset, dataType, dataspace,filespace, H5P_DEFAULT, cast(ubyte*)data.ptr);
    debug writefln("* finished writing data");
	H5T.close(dataType);
    H5S.close(space);
	H5D.close(dataset);
	debug writefln("* finished closing objects");
}

T[] slurpDataSpaceVector(T)(hid_t filehandle,string datasetName)
{
	T junk;
	T[] data;
	data.length=1;
	auto file = filehandle;
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
	//writefln("%s",dataSpaceContents(buf, dataTypeData,dataspace));

	/*debug
	{
		writefln("datatype=%s",dataTypeData);
		writefln("t_class=%s",t_class);
		writefln("order=%s",order);
		writefln("size=%s",size);
		writefln("status_n=%s",status_n);
		writefln("rank %d, dimensions %s x %s ", rank, dims_out[0],dims_out[1]);
	}*/
	if (rank!=1)
		throw new Exception("only handle vector ie rank 1 tables currently and rank="~to!string(rank));
	data = new T[dims_out[0]];
	H5D.read(dataset, dataTypeNative, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)data.ptr);
	//debug writefln("%s", "read passed");
	H5T.close(dataTypeData);
	H5T.close(dataTypeNative);
	H5S.close(dataspace);
	H5D.close(dataset);
	return data;
}

T[] slurpDataSpaceVector(T)(string filename,string datasetName)
{
	auto file = H5F.open(filename, H5F_ACC_RDONLY, H5P_DEFAULT);
	auto ret= slurpDataSpaceVector!T(filename,datasetName);
	H5F.close(file);
	return ret;
}

bool dataSetExists(string filename, string datasetName)
{
    	bool ret=false;
    	bool fileExists=exists(filename);
	if (fileExists)
	{
		auto file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT);
		ret=(H5L.exists(file,datasetName,H5P_DEFAULT)!=0)?true:false;
		H5F.close(file);
	}
	return ret;
}

bool dataSetExists(hid_t file, string datasetName)
{
	return (H5L.exists(file,datasetName,H5P_DEFAULT)!=0)?true:false;
}

string[] contentsOfHDF5(string filename)
{
	string[] ret;
	auto file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT);
	ret= cast(string[])objectList(file);
	H5F.close(file);
	return ret;
}

/**
	Function:	compute_user_block_size
 		Purpose:	Find the offset of the HDF5 header after the user block:
				align at 0, 512, 1024, etc.
 				ublock_size: the size of the user block (bytes).
 
 		 Return:	Success:    the location of the header == the size of the
 				padded user block.
 		Failure:    	none
 
		Return:		Success:    last byte written in the output.
		Failure:		Exits program with EXIT_FAILURE value.
 */

hsize_t computeUserBlockSize (hsize_t ublock_size)
{
	hsize_t where = 512;
	if (ublock_size == 0)
		return 0;
	while (where < ublock_size)
		where *= 2;
	return (where);
}



hsize_t getUserBlockSize(string filename)
{
	hsize_t usize;
	auto testval = H5F.is_hdf5(filename);
	enforce(testval>0, new Exception("Input HDF5 file is not HDF: "~filename));
	auto ifile = H5F.open (filename, H5F_ACC_RDONLY, H5P_DEFAULT);
	enforce(ifile>=0, new Exception("Cannot open input HDF5 file: "~filename));
	auto  plist = H5F.get_create_plist (ifile);
  	enforce(plist>=0, new Exception("Cannot get file creation plist for file "~filename));
	H5P.get_userblock (plist, &usize);
	H5P.close (plist);
  	H5F.close (ifile);
  	return usize;
  }

void setUserBlock(string filename, ubyte[] buf)
{
	auto usize=getUserBlockSize(filename);
	if (usize<buf.length)
		throw new Exception("Attempted to set user block for file: "~ filename~ " but user block is only "~
			to!string(usize) ~ " bytes long and buffer is "~to!string(buf.length)~" bytes long");
	auto f=File(filename,"wb+");
	f.rewind();
	f.rawWrite(buf);
	f.flush();
	f.close();
}

ubyte[] getUserBlock(string filename)
{
	ubyte[] buf;
	auto usize=getUserBlockSize(filename);
	buf.length=cast(size_t) usize;
	auto f=File(filename,"rb+");
	f.rewind();
	auto numbytes=f.rawRead(buf);
	buf.length=numbytes.length;
	f.close();
	return buf;
}


hid_t friendlyH5Create(string filename, hsize_t userBlockSize, bool truncateNotThrow )
{
	if ((!truncateNotThrow)&&exists(filename))
		throw new Exception("friendlyH5Create: attempt to create file that already exists: "~filename);
	//userBlockSize=computeUserBlockSize(userBlockSize);
	//writefln("%s userblock size",userBlockSize);
	//auto plist = H5P.create(H5P_DEFAULT); //H5P_FILE_CREATE);
	//H5P.set_userblock(plist, userBlockSize) ;
	//auto plist=H5P_DEFAULT;
	//auto file_id = H5F.create(filename, H5F_ACC_TRUNC, plist, H5P_DEFAULT);
	auto file_id = H5F.create(filename, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
	//H5P.close(plist);
	return file_id;
}


void createGroup(string filename,string groupname)
{
	auto file=H5F.open(filename,H5F_ACC_RDWR, H5P_DEFAULT);
	auto group=H5G.create2(file,groupname, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
	H5G.close(group);
	H5F.close(file);
}
