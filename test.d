import std.stdio;
import hdf5.hdf5;
import std.exception;

alias FILE="dset.h5"

void main()
{
	writefln("hello");
	auto e=H5open();
	if (e!=0)
		throw new Exception("H5open non zero");
	uint majnum, minnum, relnum;
	H5get_libversion(&majnum, &minnum, &relnum);
	H5check_version(majnum, minnum, relnum);
	writefln("%s %s",majnum,relnum);
	hsize_t dims[2];
	
	/* Create a new file using default properties. */
	file_id = H5Fcreate(FILE, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

	dims[0]=4;
	dims[1]=5;
	auto dataspaceid=H5Screate_simple(2,dims,NULL);
	auto  dataset_id = H5Dcreate2(file_id, "/dset", H5T_STD_I32BE, dataspace_id, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

	/* End access to the dataset and release resources used by it. */
	auto status = H5Dclose(dataset_id);

	/* Terminate access to the data space. */ 
	auto status = H5Sclose(dataspace_id);
	H5close();
	return;
}


/**
This template function returns an HDF5 data type identifier based on the type T.
If T is an array, the base type is returned.
Params:
T = a type
Returns: the corresponding HDF5 data type identifier
*/
hid_t hdf5Typeof(T)() @property {
import dlbc.range;
import std.traits;
static if ( isArray!T ) {
return hdf5Typeof!(BaseElementType!T);
}
else {
static if ( is(T : int) ) {
return H5T_NATIVE_INT;
}
else static if ( is(T == double) ) {
return H5T_NATIVE_DOUBLE;
}
else {
static assert(0, "Datatype not implemented for HDF5.");
}
}
}
/**
This template function returns the length of a static array of type T or 1 if
the type is not an array.
Params:
T = a type
Returns: the corresponding length
*/
hsize_t hdf5LengthOf(T)() @property {
import dlbc.range;
return LengthOf!T;
}
/**
Write a field to disk using HDF5.
Params:
field = field to be written
name = name of the field, to be used in the file name
time = current timestep
isCheckpoint = whether this is checkpoint-related (different file name, write globals)
*/
void dumpFieldHDF5(T)(ref T field, const string name, const uint time = 0, const bool isCheckpoint = false) if ( isField!T ) {
hsize_t[] dimsg;
hsize_t[] dimsl;
hsize_t[] count;
hsize_t[] stride;
hsize_t[] block;
hsize_t[] start;
hsize_t[] arrstart;
immutable type_id = hdf5Typeof!(T.type);
immutable typeLen = hdf5LengthOf!(T.type);
if ( field.size <= 1 ) return;
auto dim = field.dimensions;
static if ( field.dimensions == 3 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], gn[1], gn[2], typeLen ];
dimsl = [ field.nH[0], field.nH[1], field.nH[2], typeLen ];
count = [ 1, 1, 1, 1 ];
stride = [ 1, 1, 1, 1 ];
block = [ field.n[0], field.n[1], field.n[2], typeLen ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], M.c[2]*field.n[2], 0 ];
arrstart = [ field.haloSize, field.haloSize, field.haloSize, 0 ];
}
else {
dimsg = [ gn[0], gn[1], gn[2] ];
dimsl = [ field.nH[0], field.nH[1], field.nH[2] ];
count = [ 1, 1, 1 ];
stride = [ 1, 1, 1 ];
block = [ field.n[0], field.n[1], field.n[2] ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], M.c[2]*field.n[2] ];
arrstart = [ field.haloSize, field.haloSize, field.haloSize ];
}
}
else static if ( field.dimensions == 2 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], gn[1], typeLen ];
dimsl = [ field.nH[0], field.nH[1], typeLen ];
count = [ 1, 1, 1 ];
stride = [ 1, 1, 1 ];
block = [ field.n[0], field.n[1], typeLen ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], 0 ];
arrstart = [ field.haloSize, field.haloSize, 0 ];
}
else {
dimsg = [ gn[0], gn[1] ];
dimsl = [ field.nH[0], field.nH[1] ];
count = [ 1, 1 ];
stride = [ 1, 1 ];
block = [ field.n[0], field.n[1] ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1] ];
arrstart = [ field.haloSize, field.haloSize ];
}
}
else static if ( field.dimensions == 1 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], typeLen ];
dimsl = [ field.nH[0], typeLen ];
count = [ 1, 1 ];
stride = [ 1, 1 ];
block = [ field.n[0], typeLen ];
start = [ M.c[0]*field.n[0], 0 ];
arrstart = [ field.haloSize, 0 ];
}
else {
dimsg = [ gn[0] ];
dimsl = [ field.nH[0] ];
count = [ 1 ];
stride = [ 1 ];
block = [ field.n[0] ];
start = [ M.c[0]*field.n[0] ];
arrstart = [ field.haloSize ];
}
}
else {
static assert(0, "dumpFieldHDF5 not implemented for dimensions > 3.");
}
MPI_Info info = MPI_INFO_NULL;
string fileNameString;
if ( isCheckpoint ) {
fileNameString = makeFilenameCpOutput!(FileFormat.HDF5)(name, time);
writeLogRI("HDF writing to checkpoint file '%s'.", fileNameString);
}
else {
fileNameString = makeFilenameOutput!(FileFormat.HDF5)(name, time);
writeLogRI("HDF writing to file '%s'.", fileNameString);
}
auto fileName = fileNameString.toStringz();
// if (hdf_use_ibm_largeblock_io) then
// if (dbg_report_hdf5) call log_msg("HDF using IBM_largeblock_io")
// call MPI_Info_create(info, err)
// call MPI_Info_set(info, "IBM_largeblock_io", "true", err)
// end if
// Create the file collectively.
auto fapl_id = H5Pcreate(H5P_FILE_ACCESS);
H5Pset_fapl_mpio(fapl_id, M.comm, info);
auto file_id = H5Fcreate(fileName, H5F_ACC_TRUNC, H5P_DEFAULT, fapl_id);
H5Pclose(fapl_id);
// Create the data spaces for the dataset, using global and local size
// (including halo!), respectively.
auto filespace = H5Screate_simple(dim, dimsg.ptr, null);
auto memspace = H5Screate_simple(dim, dimsl.ptr, null);
hid_t dcpl_id;
if ( writeChunked ) {
dcpl_id = H5Pcreate(H5P_DATASET_CREATE);
H5Pset_chunk(dcpl_id, dim, block.ptr);
}
else {
dcpl_id = H5P_DEFAULT;
}
auto datasetName = defaultDatasetName.toStringz();
auto dataset_id = H5Dcreate2(file_id, datasetName, type_id, filespace, H5P_DEFAULT, dcpl_id, H5P_DEFAULT);
H5Sclose(filespace);
H5Pclose(dcpl_id);
filespace = H5Dget_space(dataset_id);
// In the filespace, we have an offset to make sure we write in the correct chunk.
H5Sselect_hyperslab(filespace, H5S_seloper_t.H5S_SELECT_SET, start.ptr, stride.ptr, count.ptr, block.ptr);
// In the memspace, we cut off the halo region.
H5Sselect_hyperslab(memspace, H5S_seloper_t.H5S_SELECT_SET, arrstart.ptr, stride.ptr, count.ptr, block.ptr);
// Set up for collective IO.
auto dxpl_id = H5Pcreate(H5P_DATASET_XFER);
H5Pset_dxpl_mpio(dxpl_id, H5FD_mpio_xfer_t.H5FD_MPIO_COLLECTIVE);
H5Dwrite(dataset_id, type_id, memspace, filespace, dxpl_id, field.arr._data.ptr);
// Close all remaining handles.
H5Sclose(filespace);
H5Sclose(memspace);
H5Dclose(dataset_id);
H5Pclose(dxpl_id);
H5Fclose(file_id);
// Only root writes the attributes
if ( M.isRoot() ) {
file_id = H5Fopen(fileName, H5F_ACC_RDWR, H5P_DEFAULT);
auto root_id = H5Gopen2(file_id, "/", H5P_DEFAULT);
// Write the input file
dumpInputFileAttributes(root_id);
// Write the metadata
dumpMetadata(root_id);
H5Gclose(root_id);
H5Fclose(file_id);
// Write the global state
if ( isCheckpoint ) {
dumpCheckpointGlobals(fileName);
}
}
}
/**
Write metadata as attributes.
*/
/+
void dumpMetadata(const hid_t root_id) {
import dlbc.revision;
auto group_id = H5Gcreate2(root_id, "metadata", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
dumpAttributeHDF5(revisionHash, "revisionHash", group_id);
dumpAttributeHDF5(revisionDesc, "revisionDesc", group_id);
dumpAttributeHDF5(revisionBranch, "revisionBranch", group_id);
dumpAttributeHDF5(revisionChanged, "revisionChanged", group_id);
dumpAttributeHDF5(revisionChanges, "revisionChanges", group_id);
H5Gclose(group_id);
}
+/
/**
Read a field from disk using HDF5.
Params:
field = field to be read
fileNameString = name of the file to be read from
isCheckpoint = whether this is checkpoint related (reads checkpoint globals)
*/
void readFieldHDF5(T)(ref T field, const string fileNameString, const bool isCheckpoint = false) if ( isField!T ) {
hsize_t[] dimsg;
hsize_t[] dimsl;
hsize_t[] count;
hsize_t[] stride;
hsize_t[] block;
hsize_t[] start;
hsize_t[] arrstart;
immutable type_id = hdf5Typeof!(T.type);
immutable typeLen = hdf5LengthOf!(T.type);
if ( field.size <= 1 ) return;
auto dim = field.dimensions;
static if ( field.dimensions == 3 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], gn[1], gn[2], typeLen ];
dimsl = [ field.nH[0], field.nH[1], field.nH[2], typeLen ];
count = [ 1, 1, 1, 1 ];
stride = [ 1, 1, 1, 1 ];
block = [ field.n[0], field.n[1], field.n[2], typeLen ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], M.c[2]*field.n[2], 0 ];
arrstart = [ field.haloSize, field.haloSize, field.haloSize, 0 ];
}
else {
dimsg = [ gn[0], gn[1], gn[2] ];
dimsl = [ field.nH[0], field.nH[1], field.nH[2] ];
count = [ 1, 1, 1 ];
stride = [ 1, 1, 1 ];
block = [ field.n[0], field.n[1], field.n[2] ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], M.c[2]*field.n[2] ];
arrstart = [ field.haloSize, field.haloSize, field.haloSize ];
}
}
else static if ( field.dimensions == 2 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], gn[1], typeLen ];
dimsl = [ field.nH[0], field.nH[1], typeLen ];
count = [ 1, 1, 1 ];
stride = [ 1, 1, 1 ];
block = [ field.n[0], field.n[1], typeLen ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], 0 ];
arrstart = [ field.haloSize, field.haloSize, 0 ];
}
else {
dimsg = [ gn[0], gn[1] ];
dimsl = [ field.nH[0], field.nH[1] ];
count = [ 1, 1 ];
stride = [ 1, 1 ];
block = [ field.n[0], field.n[1] ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1] ];
arrstart = [ field.haloSize, field.haloSize ];
}
}
else static if ( field.dimensions == 1 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], typeLen ];
dimsl = [ field.nH[0], typeLen ];
count = [ 1, 1 ];
stride = [ 1, 1 ];
block = [ field.n[0], typeLen ];
start = [ M.c[0]*field.n[0], 0 ];
arrstart = [ field.haloSize, 0 ];
}
else {
dimsg = [ gn[0] ];
dimsl = [ field.nH[0] ];
count = [ 1 ];
stride = [ 1 ];
block = [ field.n[0] ];
start = [ M.c[0]*field.n[0] ];
arrstart = [ field.haloSize ];
}
}
else {
static assert(0, "readFieldHDF5 not implemented for dimensions > 3.");
}
MPI_Info info = MPI_INFO_NULL;
auto fileName = fileNameString.toStringz();
writeLogRI("HDF reading from file '%s'.", fileNameString);
// if (hdf_use_ibm_largeblock_io) then
// if (dbg_report_hdf5) call log_msg("HDF using IBM_largeblock_io")
// call MPI_Info_create(info, err)
// call MPI_Info_set(info, "IBM_largeblock_io", "true", err)
// end if
// Create the file collectively.
auto fapl_id = H5Pcreate(H5P_FILE_ACCESS);
H5Pset_fapl_mpio(fapl_id, M.comm, info);
auto file_id = H5Fopen(fileName, H5F_ACC_RDONLY, fapl_id);
H5Pclose(fapl_id);
auto datasetName = defaultDatasetName.toStringz();
auto dataset_id = H5Dopen2(file_id, datasetName, H5P_DEFAULT);
auto filespace = H5Dget_space(dataset_id);
// In the filespace, we have an offset to make sure we write in the correct chunk.
H5Sselect_hyperslab(filespace, H5S_seloper_t.H5S_SELECT_SET, start.ptr, stride.ptr, count.ptr, block.ptr);
// In the memspace, we cut off the halo region.
auto memspace = H5Screate_simple(dim, dimsl.ptr, null);
H5Sselect_hyperslab(memspace, H5S_seloper_t.H5S_SELECT_SET, arrstart.ptr, stride.ptr, count.ptr, block.ptr);
// Set up for collective IO.
auto dxpl_id = H5Pcreate(H5P_DATASET_XFER);
H5Pset_dxpl_mpio(dxpl_id, H5FD_mpio_xfer_t.H5FD_MPIO_COLLECTIVE);
auto e = H5Dread(dataset_id, type_id, memspace, filespace, dxpl_id, field.arr._data.ptr);
if ( e != 0 ) {
writeLogF("Unable to open '%s'.", fileNameString);
}
// Close all remaining handles.
H5Sclose(filespace);
H5Sclose(memspace);
H5Dclose(dataset_id);
H5Pclose(dxpl_id);
H5Fclose(file_id);
// Only root reads the attributes
if ( isCheckpoint ) {
if ( M.isRoot() ) {
readCheckpointGlobals(fileName);
}
broadcastCheckpointGlobals();
}
}
/**
Dump a single piece of data as an attribute to an HDF5 file.
Params:
data = data to write
name = name of the attribute
loc_id = id of the location to attach to
*/
void dumpAttributeHDF5(T)(const T data, const string name, hid_t loc_id) {
auto attrname = name.toStringz();
hid_t sid, aid, type;
static if ( is (T == string ) ) {
hsize_t[] length = [ 1 ];
auto attrdata = data.toStringz();
type = H5Tcopy (H5T_C_S1);
H5Tset_size (type, H5T_VARIABLE);
sid = H5Screate_simple(1, length.ptr, null);
aid = H5Acreate2(loc_id, attrname, type, sid, H5P_DEFAULT, H5P_DEFAULT);
H5Awrite(aid, type, &attrdata);
H5Tclose(type);
}
else {
hsize_t[] length = [ 1 ];
sid = H5Screate_simple(1, length.ptr, null);
aid = H5Acreate2(loc_id, attrname, hdf5Typeof!T, sid, H5P_DEFAULT, H5P_DEFAULT);
H5Awrite(aid, hdf5Typeof!T, &data);
}
H5Aclose(aid);
H5Sclose(sid);
}
/**
Read a single piece of data from an attribute of an HDF5 file.
Params:
name = name of the attribute
loc_id = id of the group
*/
T readAttributeHDF5(T)(const string name, hid_t loc_id) {
import std.conv: to;
auto attrname = name.toStringz();
hid_t sid, aid;
static if ( is (T == string ) ) {
auto type = H5Tcopy (H5T_C_S1);
H5Tset_size (type, H5T_VARIABLE);
auto att = H5Aopen_by_name(loc_id, ".", attrname, H5P_DEFAULT, H5P_DEFAULT);
auto ftype = H5Aget_type(att);
// auto type_class = H5Tget_class (ftype);
auto dataspace = H5Aget_space(att);
hsize_t[] dims;
dims.length = 1;
H5Sget_simple_extent_dims(dataspace, dims.ptr, null);
char*[] chars;
chars.length = dims[0];
type = H5Tget_native_type(ftype, H5T_direction_t.H5T_DIR_ASCEND);
H5Aread(att, type, chars.ptr);
H5Sclose(dataspace);
H5Tclose(ftype);
H5Aclose(att);
H5Tclose(type);
return to!string(chars[0]);
}
else {
hsize_t[] length = [ 1 ];
T result;
sid = H5Screate_simple(1, length.ptr, null);
aid = H5Aopen_by_name(loc_id, ".", attrname, H5P_DEFAULT, H5P_DEFAULT);
H5Aread(aid, hdf5Typeof!T, &result);
H5Aclose(aid);
H5Sclose(sid);
return result;
}
}
/**
Dump the contents of the input file as an attribute.
Params:
loc_id = id of the locataion to attach to
*/
void dumpInputFileAttributes(hid_t loc_id) {
import dlbc.parameters: inputFileData;
hid_t sid, aid, type;
auto attrname = defaultInputFileAName.toStringz();
hsize_t[] length = [ inputFileData.length ];
immutable(char)*[] stringz;
stringz.length = inputFileData.length;
foreach(immutable i, e; inputFileData) {
stringz[i] = e.toStringz();
}
type = H5Tcopy(H5T_C_S1);
H5Tset_size(type, H5T_VARIABLE);
sid = H5Screate_simple(1, length.ptr, null);
aid = H5Acreate2(loc_id, attrname, type, sid, H5P_DEFAULT, H5P_DEFAULT);
H5Awrite(aid, type, stringz.ptr);
H5Tclose(type);
H5Aclose(aid);
H5Sclose(sid);
}
/**
Read the contents of the input file attribute into strings.
Params:
fileNameString = name of the file to read from
Returns: array of strings corresponding to lines of the input file.
*/
string[] readInputFileAttributes(const string fileNameString) {
import dlbc.parameters: inputFileData;
import std.conv;
auto attrname = defaultInputFileAName.toStringz();
auto fileName = fileNameString.toStringz();
auto dsetName = defaultDatasetName.toStringz();
auto file = H5Fopen(fileName, H5F_ACC_RDONLY, H5P_DEFAULT);
auto type = H5Tcopy (H5T_C_S1);
H5Tset_size (type, H5T_VARIABLE);
auto root = H5Gopen2(file, "/", H5P_DEFAULT);
auto att = H5Aopen_by_name(root, ".", attrname, H5P_DEFAULT, H5P_DEFAULT);
auto ftype = H5Aget_type(att);
// auto type_class = H5Tget_class (ftype);
auto dataspace = H5Aget_space(att);
hsize_t[] dims;
dims.length = 1;
H5Sget_simple_extent_dims(dataspace, dims.ptr, null);
char*[] chars;
chars.length = to!size_t(dims[0]);
type = H5Tget_native_type(ftype, H5T_direction_t.H5T_DIR_ASCEND);
H5Aread(att, type, chars.ptr);
H5Sclose(dataspace);
H5Tclose(ftype);
H5Aclose(att);
H5Gclose(root);
H5Tclose(type);
H5Fclose(file);
string[] strings;
foreach(e; chars) {
strings ~= to!string(e);
}
return strings;
}/**
This template function returns an HDF5 data type identifier based on the type T.
If T is an array, the base type is returned.
Params:
T = a type
Returns: the corresponding HDF5 data type identifier
*/
hid_t hdf5Typeof(T)() @property {
import dlbc.range;
import std.traits;
static if ( isArray!T ) {
return hdf5Typeof!(BaseElementType!T);
}
else {
static if ( is(T : int) ) {
return H5T_NATIVE_INT;
}
else static if ( is(T == double) ) {
return H5T_NATIVE_DOUBLE;
}
else {
static assert(0, "Datatype not implemented for HDF5.");
}
}
}
/**
This template function returns the length of a static array of type T or 1 if
the type is not an array.
Params:
T = a type
Returns: the corresponding length
*/
hsize_t hdf5LengthOf(T)() @property {
import dlbc.range;
return LengthOf!T;
}
/**
Write a field to disk using HDF5.
Params:
field = field to be written
name = name of the field, to be used in the file name
time = current timestep
isCheckpoint = whether this is checkpoint-related (different file name, write globals)
*/
void dumpFieldHDF5(T)(ref T field, const string name, const uint time = 0, const bool isCheckpoint = false) if ( isField!T ) {
hsize_t[] dimsg;
hsize_t[] dimsl;
hsize_t[] count;
hsize_t[] stride;
hsize_t[] block;
hsize_t[] start;
hsize_t[] arrstart;
immutable type_id = hdf5Typeof!(T.type);
immutable typeLen = hdf5LengthOf!(T.type);
if ( field.size <= 1 ) return;
auto dim = field.dimensions;
static if ( field.dimensions == 3 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], gn[1], gn[2], typeLen ];
dimsl = [ field.nH[0], field.nH[1], field.nH[2], typeLen ];
count = [ 1, 1, 1, 1 ];
stride = [ 1, 1, 1, 1 ];
block = [ field.n[0], field.n[1], field.n[2], typeLen ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], M.c[2]*field.n[2], 0 ];
arrstart = [ field.haloSize, field.haloSize, field.haloSize, 0 ];
}
else {
dimsg = [ gn[0], gn[1], gn[2] ];
dimsl = [ field.nH[0], field.nH[1], field.nH[2] ];
count = [ 1, 1, 1 ];
stride = [ 1, 1, 1 ];
block = [ field.n[0], field.n[1], field.n[2] ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], M.c[2]*field.n[2] ];
arrstart = [ field.haloSize, field.haloSize, field.haloSize ];
}
}
else static if ( field.dimensions == 2 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], gn[1], typeLen ];
dimsl = [ field.nH[0], field.nH[1], typeLen ];
count = [ 1, 1, 1 ];
stride = [ 1, 1, 1 ];
block = [ field.n[0], field.n[1], typeLen ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], 0 ];
arrstart = [ field.haloSize, field.haloSize, 0 ];
}
else {
dimsg = [ gn[0], gn[1] ];
dimsl = [ field.nH[0], field.nH[1] ];
count = [ 1, 1 ];
stride = [ 1, 1 ];
block = [ field.n[0], field.n[1] ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1] ];
arrstart = [ field.haloSize, field.haloSize ];
}
}
else static if ( field.dimensions == 1 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], typeLen ];
dimsl = [ field.nH[0], typeLen ];
count = [ 1, 1 ];
stride = [ 1, 1 ];
block = [ field.n[0], typeLen ];
start = [ M.c[0]*field.n[0], 0 ];
arrstart = [ field.haloSize, 0 ];
}
else {
dimsg = [ gn[0] ];
dimsl = [ field.nH[0] ];
count = [ 1 ];
stride = [ 1 ];
block = [ field.n[0] ];
start = [ M.c[0]*field.n[0] ];
arrstart = [ field.haloSize ];
}
}
else {
static assert(0, "dumpFieldHDF5 not implemented for dimensions > 3.");
}
MPI_Info info = MPI_INFO_NULL;
string fileNameString;
if ( isCheckpoint ) {
fileNameString = makeFilenameCpOutput!(FileFormat.HDF5)(name, time);
writeLogRI("HDF writing to checkpoint file '%s'.", fileNameString);
}
else {
fileNameString = makeFilenameOutput!(FileFormat.HDF5)(name, time);
writeLogRI("HDF writing to file '%s'.", fileNameString);
}
auto fileName = fileNameString.toStringz();
// if (hdf_use_ibm_largeblock_io) then
// if (dbg_report_hdf5) call log_msg("HDF using IBM_largeblock_io")
// call MPI_Info_create(info, err)
// call MPI_Info_set(info, "IBM_largeblock_io", "true", err)
// end if
// Create the file collectively.
auto fapl_id = H5Pcreate(H5P_FILE_ACCESS);
H5Pset_fapl_mpio(fapl_id, M.comm, info);
auto file_id = H5Fcreate(fileName, H5F_ACC_TRUNC, H5P_DEFAULT, fapl_id);
H5Pclose(fapl_id);
// Create the data spaces for the dataset, using global and local size
// (including halo!), respectively.
auto filespace = H5Screate_simple(dim, dimsg.ptr, null);
auto memspace = H5Screate_simple(dim, dimsl.ptr, null);
hid_t dcpl_id;
if ( writeChunked ) {
dcpl_id = H5Pcreate(H5P_DATASET_CREATE);
H5Pset_chunk(dcpl_id, dim, block.ptr);
}
else {
dcpl_id = H5P_DEFAULT;
}
auto datasetName = defaultDatasetName.toStringz();
auto dataset_id = H5Dcreate2(file_id, datasetName, type_id, filespace, H5P_DEFAULT, dcpl_id, H5P_DEFAULT);
H5Sclose(filespace);
H5Pclose(dcpl_id);
filespace = H5Dget_space(dataset_id);
// In the filespace, we have an offset to make sure we write in the correct chunk.
H5Sselect_hyperslab(filespace, H5S_seloper_t.H5S_SELECT_SET, start.ptr, stride.ptr, count.ptr, block.ptr);
// In the memspace, we cut off the halo region.
H5Sselect_hyperslab(memspace, H5S_seloper_t.H5S_SELECT_SET, arrstart.ptr, stride.ptr, count.ptr, block.ptr);
// Set up for collective IO.
auto dxpl_id = H5Pcreate(H5P_DATASET_XFER);
H5Pset_dxpl_mpio(dxpl_id, H5FD_mpio_xfer_t.H5FD_MPIO_COLLECTIVE);
H5Dwrite(dataset_id, type_id, memspace, filespace, dxpl_id, field.arr._data.ptr);
// Close all remaining handles.
H5Sclose(filespace);
H5Sclose(memspace);
H5Dclose(dataset_id);
H5Pclose(dxpl_id);
H5Fclose(file_id);
// Only root writes the attributes
if ( M.isRoot() ) {
file_id = H5Fopen(fileName, H5F_ACC_RDWR, H5P_DEFAULT);
auto root_id = H5Gopen2(file_id, "/", H5P_DEFAULT);
// Write the input file
dumpInputFileAttributes(root_id);
// Write the metadata
dumpMetadata(root_id);
H5Gclose(root_id);
H5Fclose(file_id);
// Write the global state
if ( isCheckpoint ) {
dumpCheckpointGlobals(fileName);
}
}
}
/**
Write metadata as attributes.
*/
void dumpMetadata(const hid_t root_id) {
import dlbc.revision;
auto group_id = H5Gcreate2(root_id, "metadata", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
dumpAttributeHDF5(revisionHash, "revisionHash", group_id);
dumpAttributeHDF5(revisionDesc, "revisionDesc", group_id);
dumpAttributeHDF5(revisionBranch, "revisionBranch", group_id);
dumpAttributeHDF5(revisionChanged, "revisionChanged", group_id);
dumpAttributeHDF5(revisionChanges, "revisionChanges", group_id);
H5Gclose(group_id);
}
/**
Read a field from disk using HDF5.
Params:
field = field to be read
fileNameString = name of the file to be read from
isCheckpoint = whether this is checkpoint related (reads checkpoint globals)
*/
void readFieldHDF5(T)(ref T field, const string fileNameString, const bool isCheckpoint = false) if ( isField!T ) {
hsize_t[] dimsg;
hsize_t[] dimsl;
hsize_t[] count;
hsize_t[] stride;
hsize_t[] block;
hsize_t[] start;
hsize_t[] arrstart;
immutable type_id = hdf5Typeof!(T.type);
immutable typeLen = hdf5LengthOf!(T.type);
if ( field.size <= 1 ) return;
auto dim = field.dimensions;
static if ( field.dimensions == 3 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], gn[1], gn[2], typeLen ];
dimsl = [ field.nH[0], field.nH[1], field.nH[2], typeLen ];
count = [ 1, 1, 1, 1 ];
stride = [ 1, 1, 1, 1 ];
block = [ field.n[0], field.n[1], field.n[2], typeLen ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], M.c[2]*field.n[2], 0 ];
arrstart = [ field.haloSize, field.haloSize, field.haloSize, 0 ];
}
else {
dimsg = [ gn[0], gn[1], gn[2] ];
dimsl = [ field.nH[0], field.nH[1], field.nH[2] ];
count = [ 1, 1, 1 ];
stride = [ 1, 1, 1 ];
block = [ field.n[0], field.n[1], field.n[2] ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], M.c[2]*field.n[2] ];
arrstart = [ field.haloSize, field.haloSize, field.haloSize ];
}
}
else static if ( field.dimensions == 2 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], gn[1], typeLen ];
dimsl = [ field.nH[0], field.nH[1], typeLen ];
count = [ 1, 1, 1 ];
stride = [ 1, 1, 1 ];
block = [ field.n[0], field.n[1], typeLen ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1], 0 ];
arrstart = [ field.haloSize, field.haloSize, 0 ];
}
else {
dimsg = [ gn[0], gn[1] ];
dimsl = [ field.nH[0], field.nH[1] ];
count = [ 1, 1 ];
stride = [ 1, 1 ];
block = [ field.n[0], field.n[1] ];
start = [ M.c[0]*field.n[0], M.c[1]*field.n[1] ];
arrstart = [ field.haloSize, field.haloSize ];
}
}
else static if ( field.dimensions == 1 ) {
if ( typeLen > 1 ) {
dim++; // One more dimension to store the vector component.
dimsg = [ gn[0], typeLen ];
dimsl = [ field.nH[0], typeLen ];
count = [ 1, 1 ];
stride = [ 1, 1 ];
block = [ field.n[0], typeLen ];
start = [ M.c[0]*field.n[0], 0 ];
arrstart = [ field.haloSize, 0 ];
}
else {
dimsg = [ gn[0] ];
dimsl = [ field.nH[0] ];
count = [ 1 ];
stride = [ 1 ];
block = [ field.n[0] ];
start = [ M.c[0]*field.n[0] ];
arrstart = [ field.haloSize ];
}
}
else {
static assert(0, "readFieldHDF5 not implemented for dimensions > 3.");
}
MPI_Info info = MPI_INFO_NULL;
auto fileName = fileNameString.toStringz();
writeLogRI("HDF reading from file '%s'.", fileNameString);
// if (hdf_use_ibm_largeblock_io) then
// if (dbg_report_hdf5) call log_msg("HDF using IBM_largeblock_io")
// call MPI_Info_create(info, err)
// call MPI_Info_set(info, "IBM_largeblock_io", "true", err)
// end if
// Create the file collectively.
auto fapl_id = H5Pcreate(H5P_FILE_ACCESS);
H5Pset_fapl_mpio(fapl_id, M.comm, info);
auto file_id = H5Fopen(fileName, H5F_ACC_RDONLY, fapl_id);
H5Pclose(fapl_id);
auto datasetName = defaultDatasetName.toStringz();
auto dataset_id = H5Dopen2(file_id, datasetName, H5P_DEFAULT);
auto filespace = H5Dget_space(dataset_id);
// In the filespace, we have an offset to make sure we write in the correct chunk.
H5Sselect_hyperslab(filespace, H5S_seloper_t.H5S_SELECT_SET, start.ptr, stride.ptr, count.ptr, block.ptr);
// In the memspace, we cut off the halo region.
auto memspace = H5Screate_simple(dim, dimsl.ptr, null);
H5Sselect_hyperslab(memspace, H5S_seloper_t.H5S_SELECT_SET, arrstart.ptr, stride.ptr, count.ptr, block.ptr);
// Set up for collective IO.
auto dxpl_id = H5Pcreate(H5P_DATASET_XFER);
H5Pset_dxpl_mpio(dxpl_id, H5FD_mpio_xfer_t.H5FD_MPIO_COLLECTIVE);
auto e = H5Dread(dataset_id, type_id, memspace, filespace, dxpl_id, field.arr._data.ptr);
if ( e != 0 ) {
writeLogF("Unable to open '%s'.", fileNameString);
}
// Close all remaining handles.
H5Sclose(filespace);
H5Sclose(memspace);
H5Dclose(dataset_id);
H5Pclose(dxpl_id);
H5Fclose(file_id);
// Only root reads the attributes
if ( isCheckpoint ) {
if ( M.isRoot() ) {
readCheckpointGlobals(fileName);
}
broadcastCheckpointGlobals();
}
}
/**
Dump a single piece of data as an attribute to an HDF5 file.
Params:
data = data to write
name = name of the attribute
loc_id = id of the location to attach to
*/
void dumpAttributeHDF5(T)(const T data, const string name, hid_t loc_id) {
auto attrname = name.toStringz();
hid_t sid, aid, type;
static if ( is (T == string ) ) {
hsize_t[] length = [ 1 ];
auto attrdata = data.toStringz();
type = H5Tcopy (H5T_C_S1);
H5Tset_size (type, H5T_VARIABLE);
sid = H5Screate_simple(1, length.ptr, null);
aid = H5Acreate2(loc_id, attrname, type, sid, H5P_DEFAULT, H5P_DEFAULT);
H5Awrite(aid, type, &attrdata);
H5Tclose(type);
}
else {
hsize_t[] length = [ 1 ];
sid = H5Screate_simple(1, length.ptr, null);
aid = H5Acreate2(loc_id, attrname, hdf5Typeof!T, sid, H5P_DEFAULT, H5P_DEFAULT);
H5Awrite(aid, hdf5Typeof!T, &data);
}
H5Aclose(aid);
H5Sclose(sid);
}
/**
Read a single piece of data from an attribute of an HDF5 file.
Params:
name = name of the attribute
loc_id = id of the group
*/
T readAttributeHDF5(T)(const string name, hid_t loc_id) {
import std.conv: to;
auto attrname = name.toStringz();
hid_t sid, aid;
static if ( is (T == string ) ) {
auto type = H5Tcopy (H5T_C_S1);
H5Tset_size (type, H5T_VARIABLE);
auto att = H5Aopen_by_name(loc_id, ".", attrname, H5P_DEFAULT, H5P_DEFAULT);
auto ftype = H5Aget_type(att);
// auto type_class = H5Tget_class (ftype);
auto dataspace = H5Aget_space(att);
hsize_t[] dims;
dims.length = 1;
H5Sget_simple_extent_dims(dataspace, dims.ptr, null);
char*[] chars;
chars.length = dims[0];
type = H5Tget_native_type(ftype, H5T_direction_t.H5T_DIR_ASCEND);
H5Aread(att, type, chars.ptr);
H5Sclose(dataspace);
H5Tclose(ftype);
H5Aclose(att);
H5Tclose(type);
return to!string(chars[0]);
}
else {
hsize_t[] length = [ 1 ];
T result;
sid = H5Screate_simple(1, length.ptr, null);
aid = H5Aopen_by_name(loc_id, ".", attrname, H5P_DEFAULT, H5P_DEFAULT);
H5Aread(aid, hdf5Typeof!T, &result);
H5Aclose(aid);
H5Sclose(sid);
return result;
}
}
/**
Dump the contents of the input file as an attribute.
Params:
loc_id = id of the locataion to attach to
*/
void dumpInputFileAttributes(hid_t loc_id) {
import dlbc.parameters: inputFileData;
hid_t sid, aid, type;
auto attrname = defaultInputFileAName.toStringz();
hsize_t[] length = [ inputFileData.length ];
immutable(char)*[] stringz;
stringz.length = inputFileData.length;
foreach(immutable i, e; inputFileData) {
stringz[i] = e.toStringz();
}
type = H5Tcopy(H5T_C_S1);
H5Tset_size(type, H5T_VARIABLE);
sid = H5Screate_simple(1, length.ptr, null);
aid = H5Acreate2(loc_id, attrname, type, sid, H5P_DEFAULT, H5P_DEFAULT);
H5Awrite(aid, type, stringz.ptr);
H5Tclose(type);
H5Aclose(aid);
H5Sclose(sid);
}
/**
Read the contents of the input file attribute into strings.
Params:
fileNameString = name of the file to read from
Returns: array of strings corresponding to lines of the input file.
*/
string[] readInputFileAttributes(const string fileNameString) {
import dlbc.parameters: inputFileData;
import std.conv;
auto attrname = defaultInputFileAName.toStringz();
auto fileName = fileNameString.toStringz();
auto dsetName = defaultDatasetName.toStringz();
auto file = H5Fopen(fileName, H5F_ACC_RDONLY, H5P_DEFAULT);
auto type = H5Tcopy (H5T_C_S1);
H5Tset_size (type, H5T_VARIABLE);
auto root = H5Gopen2(file, "/", H5P_DEFAULT);
auto att = H5Aopen_by_name(root, ".", attrname, H5P_DEFAULT, H5P_DEFAULT);
auto ftype = H5Aget_type(att);
// auto type_class = H5Tget_class (ftype);
auto dataspace = H5Aget_space(att);
hsize_t[] dims;
dims.length = 1;
H5Sget_simple_extent_dims(dataspace, dims.ptr, null);
char*[] chars;
chars.length = to!size_t(dims[0]);
type = H5Tget_native_type(ftype, H5T_direction_t.H5T_DIR_ASCEND);
H5Aread(att, type, chars.ptr);
H5Sclose(dataspace);
H5Tclose(ftype);
H5Aclose(att);
H5Gclose(root);
H5Tclose(type);
H5Fclose(file);
string[] strings;
foreach(e; chars) {
strings ~= to!string(e);
}
return strings;
}
