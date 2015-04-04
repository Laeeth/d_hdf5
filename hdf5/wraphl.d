/**

	Copyright by The HDF Group.                                               
	Copyright by the Board of Trustees of the University of Illinois.         
	All rights reserved.                                                      
	                                                                        
	This file is part of HDF5.  The full HDF5 copyright notice, including     
	terms governing use, modification, and redistribution, is contained in    
	the files COPYING and Copyright.html.  COPYING can be found at the root   
	of the source code distribution tree; Copyright.html can be found at the  
	root level of an installed copy of the electronic HDF5 document set and   
	is linked from the top-level documents page.  It can also be found at     
	http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          
	access to either file, you may request a copy from help@hdfgroup.org.     

	Ported 2015 to the D Programming Language by Laeeth Isharc
*/

/**
	hdf5.hlwrap - D wrappers for 'high level' C API for HDF5
*/

module hdf5.wraphl;
import hdf5.hl;

/**
	Helper Functions
*/

char** toCPointerArray(string[] inp)
{
	char **ret=gc.calloc((char *).sizeof);
	foreach(i, item;inp)
		*(ret+i)=(to!string(item)~"\0").ptr;
	return ret;
}

/**
	H5DOpublic.h
*/

	herr_t H5DOwrite_chunk(hid_t dset_id, hid_t dxpl_id, uint filters, const hsize_t *offset, size_t data_size, const (void*) buf);

/**
	H5DSpublic
*/
	enum DimensionScaleClass =		"DIMENSION_SCALE";
	enum DimensionList = 			"DIMENSION_LIST";
	enum ReferenceList =        	"REFERENCE_LIST";
	enum DimensionLabels =       	"DIMENSION_LABELS";

	alias DIMENSION_SCALE_CLASS =	DimensionScaleClass;
	alias DIMENSION_LIST =			DimensionList;
	alias REFERENCE_LIST =			ReferenceList;
	alias DIMENSION_LABELS =		DimensionLabels;


	alias H5DS_iterate_t = herr_t  function(hid_t dset, unsigned dim, hid_t scale, void *visitor_data);
	herr_t  H5DSattach_scale( hid_t did, hid_t dsid, uint idx);
	herr_t  H5DSdetach_scale( hid_t did, hid_t dsid, uint idx);
	herr_t  H5DSset_scale( hid_t dsid, const (char*) dimname);
	int H5DSget_num_scales( hid_t did, uint dim);
	herr_t  H5DSset_label( hid_t did, uint idx, const (char*) label);
	ssize_t H5DSget_label( hid_t did, uint idx, char *label, size_t size);
	ssize_t H5DSget_scale_name( hid_t did, char *name, size_t size);
	htri_t H5DSis_scale( hid_t did);
	herr_t  H5DSiterate_scales( hid_t did, uint dim, int *idx, H5DS_iterate_t visitor, void *visitor_data);
	htri_t H5DSis_attached( hid_t did, hid_t dsid, uint idx);

/**
	H5IMpublic
*/
struct H5Image
{

	void makeImage8Bit(
	herr_t  H5IMmake_image_8bit( hid_t loc_id, const (char*) dset_name, hsize_t width, hsize_t height, const (ubyte*) buffer );
	herr_t  H5IMmake_image_24bit( hid_t loc_id, const (char*) dset_name, hsize_t width, hsize_t height, const (char*) interlace,
		const (ubyte*) buffer );
	herr_t  H5IMget_image_info( hid_t loc_id, const (char*) dset_name, hsize_t *width, hsize_t *height, hsize_t *planes, char *interlace,
	                     hssize_t *npals );
	herr_t  H5IMread_image( hid_t loc_id, const (char*) dset_name, ubyte *buffer );
	herr_t  H5IMmake_palette( hid_t loc_id, const (char*) pal_name, const hsize_t *pal_dims, const (ubyte*) pal_data );
	herr_t  H5IMlink_palette( hid_t loc_id, const (char*) image_name, const (char*) pal_name );
	herr_t  H5IMunlink_palette( hid_t loc_id, const (char*) image_name, const (char*) pal_name );
	herr_t  H5IMget_npalettes( hid_t loc_id, const (char*) image_name, hssize_t *npals );
	herr_t  H5IMget_palette_info( hid_t loc_id, const (char*) image_name, int pal_number, hsize_t *pal_dims );
	herr_t  H5IMget_palette( hid_t loc_id, const (char*) image_name, int pal_number, ubyte *pal_data );
	herr_t  H5IMis_image( hid_t loc_id, const (char*) dset_name );
	herr_t  H5IMis_palette( hid_t loc_id, const (char*) dset_name );

/**
	H5LPTpublic
*/

	// Flag definitions for H5LTopen_file_image()
	enum H5LT_FILE_IMAGE_OPEN_RW	=	0x0001 	// Open image for read-write
	enum H5LT_FILE_IMAGE_DONT_COPY  =	0x0002; // The HDF5 lib won't copy user supplied image buffer. The same image is open with the
												// core driver.
	enum H5LT_FILE_IMAGE_DONT_RELEASE=	0x0004; // The HDF5 lib won't deallocate user supplied image buffer. The user application is responsible.
	enum H5LT_FILE_IMAGE_ALL		=	0x0007;

	enum H5LT_lang_t
	{
	    H5LT_LANG_ERR = -1, /*this is the first*/
	    H5LT_DDL      = 0,  /*for DDL*/
	    H5LT_C        = 1,  /*for C*/
	    H5LT_FORTRAN  = 2,  /*for Fortran*/
	    H5LT_NO_LANG  = 3   /*this is the last*/
	}

/**

	Make dataset functions

*/

struct H5Lite
{
	void make(T)(hid_t locID,string datasetName, hsize_t[] dims, hid_t typeID, in T[] data)
	{
		enforce(H5LTmake_dataset(locID,datasetName.toStringz,cast(int)dims.length,dims.ptr,typeID,data.ptr)>=0,
			new Exception("H5Lite.make error"));
	}

	void make(hid_t locID,string datasetName, hsize_t[] dims, hid_t typeID, in char[] data)
	{
		enforce(H5LTmake_dataset_char(locID,datasetName.toStringz,cast(int)dims.length,dims.ptr,data.ptr)>=0,
			new Exception("H5Lite.make!char error"));		
	}

	void make(hid_t locID,string datasetName, hsize_t[] dims, hid_t typeID, in short[] data)
	{
		enforce(H5LTmake_dataset_short(locID,datasetName.toStringz,cast(int)dims.length,dims.ptr,data.ptr)>=0,
			new Exception("H5Lite.make!short error"));		
	}

	void make(hid_t locID,string datasetName, hsize_t[] dims, hid_t typeID, in int[] data)
	{
		enforce(H5LTmake_dataset_int(locID,datasetName.toStringz,cast(int)dims.length,dims.ptr,data.ptr)>=0,
			new Exception("H5Lite.make!int error"));		
	}
	void make(hid_t locID,string datasetName, hsize_t[] dims, hid_t typeID, in long[] data)
	{
		enforce(H5LTmake_dataset_long(locID,datasetName.toStringz,cast(int)dims.length,dims.ptr,data.ptr)>=0,
			new Exception("H5Lite.make!long error"));		
	}
	void make(hid_t locID,string datasetName, hsize_t[] dims, hid_t typeID, in float[] data)
	{
		enforce(H5LTmake_dataset_float(locID,datasetName.toStringz,cast(int)dims.length,dims.ptr,data.ptr)>=0,
			new Exception("H5Lite.make!float error"));		
	}
	void make(hid_t locID,string datasetName, hsize_t[] dims, hid_t typeID, in double[] data)
	{
		enforce(H5LTmake_dataset_double(locID,datasetName.toStringz,cast(int)dims.length,dims.ptr,data.ptr)>=0,
			new Exception("H5Lite.make!double error"));		
	}
	void make(hid_t locID,string datasetName, hsize_t[] dims, hid_t typeID, in string data)
	{
		enforce(H5LTmake_dataset_string(locID,datasetName.toStringz,data.ptr)>=0,
			new Exception("H5Lite.make!string error"));		
	}

/**

	Read dataset functions
 
*/

	herr_t  H5LTread_dataset( hid_t loc_id, const (char*) dset_name, hid_t type_id, void *buffer );
	
	void read(hid_t loc_id, string datasetName,char* buf)
	{
		enforce(H5LT_read_dataset_char(loc_id,datasetName.toStringz,buf)>=0,new Exception("H5Lite.read!char error"));
	}

	void read(hid_t loc_id, string datasetName, short* buf)
	{
		enforce(H5LT_read_dataset_short(loc_id,datasetName.toStringz,buf)>=0,new Exception("H5Lite.read!short error"));
	}

	void read(hid_t loc_id, string datasetName, int* buf)
	{
		enforce(H5LT_read_dataset_int(loc_id,datasetName.toStringz,buf)>=0,new Exception("H5Lite.read!int error"));
	}

	void read(hid_t loc_id, string datasetName, long* buf)
	{
		enforce(H5LT_read_dataset_long(loc_id,datasetName.toStringz,buf)>=0,new Exception("H5Lite.read!long error"));
	}

	void read(hid_t loc_id, string datasetName, long* buf)
	{
		enforce(H5LT_read_dataset_long(loc_id,datasetName.toStringz,buf)>=0,new Exception("H5Lite.read!long error"));
	}

	void read(hid_t loc_id, string datasetName, float* buf)
	{
		enforce(H5LT_read_dataset_float(loc_id,datasetName.toStringz,buf)>=0,new Exception("H5Lite.read!float error"));
	}

	void read(hid_t loc_id, string datasetName, double* buf)
	{
		enforce(H5LT_read_dataset_double(loc_id,datasetName.toStringz,buf)>=0,new Exception("H5Lite.read!double error"));
	}

	void read(hid_t loc_id, string datasetName, char* buf)
	{
		enforce(H5LT_read_dataset_string(loc_id,datasetName.toStringz,buf)>=0,new Exception("H5Lite.read!char error"));
	}

/**
	
	Query dataset functions

*/
 
	int getDataSetNumDims(hid_t locID, string datasetName)
	{
		int ret;
		enforce(H5LTget_dataset_ndims(locID,datasetName.toStringz,&ret)>=0,new ExceptioN("H5Lite.getDataSetNumDims error"));
		return ret;
	}
	
	int getDataSetSize(hid_t locID, string datasetName)
	{
		hsize_t dims,
		H5T_class_t typeClass;
		size_t typeSize;
		enforce(H5LTget_dataset_info(locID,datasetName.toStringz,&dims,&typeClass,&typeSize );
		return typeSize;
	}

	H5T_class_t getDataSetClass(hid_t loc_id, string datasetName)
	{
		hsize_t dims,
		H5T_class_t typeClass;
		size_t typeSize;
		enforce(H5LTget_dataset_info(locID,datasetName.toStringz,&dims,&typeClass,&typeSize );
		return typeClass;
	}

	alias H5LiteInfo=Tuple!(dims,"dims",H5T_class_t,"typeClass",size_t,"typeSize");
	H5LiteInfo getDataSetInfo(hid_t loc_id, string datasetName)
	{
		hsize_t dims,
		H5T_class_t typeClass;
		size_t typeSize;
		enforce(H5LTget_dataset_info(locID,datasetName.toStringz,&dims,&typeClass,&typeSize );
		return H5LiteInfo(dims,typeClass,typeSize);
	}

	bool canFindDataset(hid_t locID, string datasetName)
	{
		return (H5LTfind_dataset(locID, datasetName.toStringz)==1);
	}

/**

	Set attribute functions

*/

	void setAttribute(hid_t locID, string objectName, string attributeName, in char* data)
	{
		enforce(H5LTset_attribute_string(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.setAttribute!char error"));
	}
	void setAttribute(hid_t locID, string objectName, string attributeName, in uchar* data)
	{
		enforce(H5LTset_attribute_uchar(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.setAttribute!uchar error"));
	}
	void setAttribute(hid_t locID, string objectName, string attributeName, in short[] data)
	{
		enforce(H5LTset_attribute_short(locID,objectName.toStringz,attributeName.toStringz,data.ptr,data.length)>=0,
			new Exception("H5Lite.setAttribute!short[] error"));
	}
	void setAttribute(hid_t locID, string objectName, string attributeName, in ushort[] data)
	{
		enforce(H5LTset_attribute_ushort(locID,objectName.toStringz,attributeName.toStringz,data.ptr,data.length)>=0,
			new Exception("H5Lite.setAttribute!ushort[] error"));
	}
	void setAttribute(hid_t locID, string objectName, string attributeName, in int[] data)
	{
		enforce(H5LTset_attribute_int(locID,objectName.toStringz,attributeName.toStringz,data.ptr,data.length)>=0,
			new Exception("H5Lite.setAttribute!int[] error"));
	}
	void setAttribute(hid_t locID, string objectName, string attributeName, in uint[] data)
	{
		enforce(H5LTset_attribute_uint(locID,objectName.toStringz,attributeName.toStringz,data.ptr,data.length)>=0,
			new Exception("H5Lite.setAttribute!uint[] error"));
	}
	void setAttribute(hid_t locID, string objectName, string attributeName, in long[] data)
	{
		enforce(H5LTset_attribute_long(locID,objectName.toStringz,attributeName.toStringz,data.ptr,data.length)>=0,
			new Exception("H5Lite.setAttribute!long[] error"));
	}
	void setAttribute(hid_t locID, string objectName, string attributeName, in ulong[] data)
	{
		enforce(H5LTset_attribute_ulong(locID,objectName.toStringz,attributeName.toStringz,data.ptr,data.length)>=0,
			new Exception("H5Lite.setAttribute!uint[] error"));
	}
	void setAttribute(hid_t locID, string objectName, string attributeName, in float[] data)
	{
		enforce(H5LTset_attribute_float(locID,objectName.toStringz,attributeName.toStringz,data.ptr,data.length)>=0,
			new Exception("H5Lite.setAttribute!float[] error"));
	}
	void setAttribute(hid_t locID, string objectName, string attributeName, in double[] data)
	{
		enforce(H5LTset_attribute_double(locID,objectName.toStringz,attributeName.toStringz,data.ptr,data.length)>=0,
			new Exception("H5Lite.setAttribute!double[] error"));
	}

/**

	Get attribute functions

*/

	herr_t  H5LTget_attribute( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, hid_t mem_type_id, void *data );
	herr_t  H5LTget_attribute_string( hid_t loc_id, const (char*) obj_name, const (char*) attr_name, char *data );
	
	void getAttribute(hid_t locID, string objectName, string attributeName, char* data)
	{
		enforce(H5LTget_attribute_char(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!char"));
	}

	void getAttribute(hid_t locID, string objectName, string attributeName, uchar* data)
	{
		enforce(H5LTget_attribute_uchar(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!uchar"));
	}
	void getAttribute(hid_t locID, string objectName, string attributeName, short* data)
	{
		enforce(H5LTget_attribute_short(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!short"));
	}
	void getAttribute(hid_t locID, string objectName, string attributeName, ushort* data)
	{
		enforce(H5LTget_attribute_ushort(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!ushort"));
	}
	void getAttribute(hid_t locID, string objectName, string attributeName, int* data)
	{
		enforce(H5LTget_attribute_int(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!int"));
	}
	void getAttribute(hid_t locID, string objectName, string attributeName, uint* data)
	{
		enforce(H5LTget_attribute_uint(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!uint"));
	}
	void getAttribute(hid_t locID, string objectName, string attributeName, long* data)
	{
		enforce(H5LTget_attribute_long(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!long"));
	}
	void getAttribute(hid_t locID, string objectName, string attributeName, ulong* data)
	{
		enforce(H5LTget_attribute_ulong(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!ulong"));
	}
	void getAttribute(hid_t locID, string objectName, string attributeName, float* data)
	{
		enforce(H5LTget_attribute_float(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!float"));
	}
	void getAttribute(hid_t locID, string objectName, string attributeName, double* data)
	{
		enforce(H5LTget_attribute_double(locID,objectName.toStringz,attributeName.toStringz,data)>=0,
			new Exception("H5Lite.getAttribute!double"));
	}


/**

	Query attribute functions

*/

	int getAttributeNumDims(hid_t locID, string objectName, string attributeName)
	{
		int numDims;
		enforce(H5LT_get_attribute_ndims(locID,objectName.toStringz, attributeName.toStringz,&numDims)>=0,
			new Exception("H5Lite.getAttributeNumDims error"));
		return numDims;
	}

	H5T_class_t getAttributeClassType(hid_t locID, string objectName, string attributeName)
	{
		int numDims;
		H5T_class_t classType;
		size_t typeSize;
		enforce(H5LT_get_attribute_info(locID,objectName.toStringz, attributeName.toStringz,&numDims,&classType,&typeSize)>=0,
			new Exception("H5Lite.getAttributeNumDims error"));
		return classType;
	}

	H5T_class_t getAttributeTypeSize(hid_t locID, string objectName, string attributeName)
	{
		int numDims;
		H5T_class_t classType;
		size_t typeSize;
		enforce(H5LT_get_attribute_info(locID,objectName.toStringz, attributeName.toStringz,&numDims,&classType,&typeSize)>=0,
			new Exception("H5Lite.getAttributeNumDims error"));
		return typeSize;
	}

	H5LiteInfo getAttributeInfo(hid_t locID, string objectName, string attributeName)
	{
		int numDims;
		H5T_class_t classType;
		size_t typeSize;
		enforce(H5LT_get_attribute_info(locID,objectName.toStringz, attributeName.toStringz,&numDims,&classType,&typeSize)>=0,
			new Exception("H5Lite.getAttributeNumDims error"));
		return H5LiteInfo(numDims,classType,typeSize);
	}


/**

	General functions

*/

	hid_t H5LTtext_to_dtype(const (char*) text, H5LT_lang_t lang_type);
	herr_t H5LTdtype_to_text(hid_t dtype, char *str, H5LT_lang_t lang_type, size_t *len);

/**

	Utility functions

*/

	bool canFindAttribute(hid_t locID,string name)
	{
		return (H5LTfind_attribute(locID,name.toStringz)==1);
	}

	bool isPathValid(hid_t locID, string path, bool checkObjectValid)
	{
		auto ret=H5LTpath_valid(locID,path.toStringz,checkObjectValid?1:0);
		enforce(ret>=0, new Exception("H5Lite.isPathValid error");
		return (ret!=0);
	}

/**
	
	File image operations functions
 
*/

	hid_t openFileImage(ubyte[] buf,bool readOnly,bool dontCopy)
	{
		auto ret=H5LTopen_file_image(buf.ptr,buf.length,	(!readOnly?H5LT_FILE_IMAGE_OPEN_RW:0) | 
															(!dontCopy?H5LT_FILE_IMAGE_DONT_COPY:0) |
															H5LT_FILE_IMAGE_DONT_RELEASE );
		enforce(ret>=0, new Exception("H5Lite.openFileImage error");
		return ret;
	}

/**
	H5PTpublic
*/

/**
	
	Create/Open/Close functions

*/

	hid_t H5PTcreate_fl ( hid_t loc_id, const (char*) dset_name, hid_t dtype_id, hsize_t chunk_size, int compression );
	static if (VLPT_REMOVED)
		hid_t H5PTcreate_vl ( hid_t loc_id, const (char*) dset_name, hsize_t chunk_size );

	hid_t H5PTopen( hid_t loc_id, const (char*) dset_name );
	herr_t  H5PTclose( hid_t table_id );

/**

	Write functions

*/

herr_t  H5PTappend( hid_t table_id, size_t nrecords, const (void*) data );

/**

	Read functions

*/

herr_t  H5PTget_next( hid_t table_id, size_t nrecords, void * data );
herr_t  H5PTread_packets( hid_t table_id, hsize_t start, size_t nrecords, void *data );

/**

	Inquiry functions

*/


	herr_t  H5PTget_num_packets( hid_t table_id, hsize_t *nrecords );
	herr_t  H5PTis_valid( hid_t table_id );
	static if (VLPT_REMOVED)
		herr_t  H5PTis_varlen( hid_t table_id );

/**

	Packet Table "current index" functions

*/

	herr_t  H5PTcreate_index( hid_t table_id );
	herr_t  H5PTset_index( hid_t table_id, hsize_t pt_index );
	herr_t  H5PTget_index( hid_t table_id, hsize_t *pt_index );

/**

	Memory Management functions

*/

	static if (VLPT_REMOVED)
		herr_t  H5PTfree_vlen_readbuff( hid_t table_id, size_t bufflen, void * buff );

/**
	H5TBpublic
*/

struct H5Table
{

	string tableTitle;
	string datasetName;
	hid_t locID;
	string[] fieldNames;
	size_t[] fieldOffsets;
	hid_t[] fieldTypes;
	size_t[] fieldSizes;
	size_t typeSize;
	bool compress=false;
/**

	Create functions

*/
	this(string tableTitle,string datasetName,hid_t locID, string[] fieldNames, size_t[] fieldOffsets, hid_t[] fieldTypes, size_t typeSize,
			 size_t[] fieldSizes,bool compress=false)
	{
		this.tableTitle=tableTitle;
		this.datasetName=datasetName;
		this.locID=locID;
		this.fieldNames=fieldNames;
		this.fieldOffsets=fieldOffsets;
		this.fieldTypes=fieldTypes;
		this.typeSize=typeSize;
		this.fieldSizes=fieldSizes
		this.compress=compress;
	}

	void makeTable(T)(hsize_t chunkSize, bool compress=false, T data)
	{
		ubyte[] fillData;
		fillData.length=this.typeSize;
		makeTable!T(chunkSize,fillData,compress,data);
	}

	void makeTable(T)(hsize_t chunkSize, ubyte[] fillData, bool compress=false, T data)
	{
		auto numFields=fieldNames.length;
		auto numRecords=data.length;
		enforce(numFields==fieldOffsets.length,new Exception("H5Table.makeTable: fieldNames must have same length as fieldOffsets");
		enforce(numFields==fieldTypes.length,new Exception("H5Table.makeTable: fieldNames must have same length as fieldTypes");

		enforce(H5TBmake_table(toStringz(tableTitle),locID,toStringz(datasetName),numFields,numRecords,typeSize,names.toCPointerArray,
			fieldOffsets.ptr,fieldTypes.ptr,chunkSize,fillData.ptr,compress?-1:0, buf.ptr)>=0,new Exception("H5Table.makeTable error"));
	}


/**

	Write functions

*/

	void appendRecords(T)(in T[] data)
	{
		auto numRecords=data.length;
		enforce(H5TBappend_records(locID,datasetName.toStringz, numRecords, typeSize, fieldOffsets.ptr,fieldSizes.ptr,data.ptr)>=0,
				new Exception("H5Table.appendRecords error"));
	}
	
	void writeRecords(T)(hsize_t start, in T[] data)
	{
		auto numRecords=data.length;
		enforce(H5TB_write_records(locID,datasetName.toStringz, start, numRecords,typeSize,fieldOffsets.ptr,fieldSizes.ptr,data.ptr)>=0,
				new Exception("H5Table.writeRecords error"));
	}

	
	void writeFieldsName(T)(hsize_t start, in T[] data)
	{
		auto numRecords=data.length
		enforce(H5TB_write_fields_name(locID,datasetName.ptr,fieldNames.toCPointerArray,start,numRecords,typeSize,fieldOffsets.ptr,
						fieldSizes.ptr,data.ptr)>=0, new Exception("H5Table.writeFieldsName error"));
	}

	void writeFieldsIndex(T)(in int[] fieldIndex, hsize_t start, in T[] data)
	{
		auto numRecords=data.length;
		enforce(H5TBwrite_fields_index(locID,datasetName.toStringz,numFields,fieldIndex.ptr,start,numRecords,typeSize,fieldOffsets.ptr,
							destSizes.ptr,data.ptr)>=0,new Exception("H5Table.writeFieldsIndex error"));
	}

/**

	Read functions

*/

	void readTable(T)(size_t destSize, in size_t[] destOffset, in size_t[] destSizes, ubyte[] buf)
	{
		enforce(H5TBread_table(locID,datasetName.toStringz,fieldSizes,fieldOffsets.ptr,fieldSizes.ptr,data.ptr)>=0,
				new Exception("H5Table.readTable error"));
	}

	void readFieldsName(T)(string[] fieldNames, hsize_t start, hsize_t numRecords,in T[] data)
	{
		auto numRecords=data.length;
		enforce(H5TBread_fields_name(locID,datasetName.toStringz,fieldNames.toCPointerArray,start,numRecords,typeSize,fieldOffsets.ptr,
				destSizes.ptr,buf.ptr)>=0,new Exception("H5Table.readFieldsName error"));
	}

	void readFieldsIndex(hid_t locID, string datasetName, hsize_t numFields)







	herr_t  H5TBread_fields_index( hid_t loc_id, const (char*) dset_name, hsize_t nfields, const int *field_index, hsize_t start,
                        hsize_t nrecords, size_t type_size, const size_t *field_offset, const size_t *dst_sizes, void *buf );


	herr_t  H5TBread_records( hid_t loc_id, const (char*) dset_name, hsize_t start, hsize_t nrecords, size_t type_size,
						const size_t *dst_offset, const size_t *dst_sizes, void *buf );


/**

	Inquiry functions

*/

	herr_t  H5TBget_table_info ( hid_t loc_id, const (char*) dset_name, hsize_t *nfields, hsize_t *nrecords );
	herr_t  H5TBget_field_info( hid_t loc_id, const (char*) dset_name, char *field_names[], size_t *field_sizes, size_t *field_offsets,
						size_t *type_size );


/**

	Manipulation functions
 
*/

	void deleteRecord(hsize_t start, hsize_t numRecords)
	{
		enforce(H5TB_delete_record(locID,datasetName.toStringz,start,numRecords)>=0,new Exception("H5Table.deleteRecord error"));
	}

	void insertRecord(T)(hsize_t start, T data)
	{
		enforce(H5TBinsert_record(locID,datasetName.toStringz, start,data.length, fieldSizes.ptr, fieldOffsets.ptr,fieldSizes.ptr,data.ptr)
			>=0, new Exception("H5Table.insertRecord error"));
	}

	void addRecordsFrom(hsize_t start1, hsize_t numRecords, hsize_t start2, H5Table dataset2)
	{
		enforce H5TB_add_records_from(locID,datasetName.toStringz,start1,numRecords,dataset2.datasetName,start2)>=0,
				new Exception("H5Table.addRecordsFrom error");
	}

	void combineTables(H5Table dataset2
	herr_t  H5TBcombine_tables( hid_t loc_id1, const (char*) dset_name1, hid_t loc_id2, const (char*) dset_name2, const (char*) dset_name3 );
	herr_t  H5TBinsert_field( hid_t loc_id, const (char*) dset_name, const (char*) field_name, hid_t field_type, hsize_t position,
	                         const (void*) fill_data, const (void*) buf );
	herr_t  H5TBdelete_field( hid_t loc_id, const (char*) dset_name, const (char*) field_name );


/**

	Table attribute functions

*/

	string getTableTitle(hid_t locID)
	{
		string
	}
	herr_t  H5TBAget_title( hid_t loc_id, char *table_title );
	htri_t  H5TBAget_fill(hid_t loc_id, const (char*) dset_name, hid_t dset_id, ubyte *dst_buf);

} // end extern(C)