module increasecache;
import hdf5.bindings.api;
import hdf5.bindings.enums;
import std.stdio;
import std.exception;
import std.file;
import std.conv;
import std.string;

int main(string[] args)
{
	if (args.length!=3)
		throw new Exception("syntax: <filename> <new cache size in meg>");
	if (!exists(args[1]))
		throw new Exception("syntax: <filename> <new cache size in meg> -- file not found:"~args[1]);

	hid_t file;
	H5GInfo grp_info;
	H5AC_cache_config_t config;
	int i;

	file = H5Fopen(toStringz(args[1]), H5F_ACC_RDONLY, H5P_DEFAULT);
/* Adjust the size of metadata cache */
 config.version_ = H5AC__CURR_CACHE_CONFIG_VERSION;
 H5Fget_mdc_config(file, &config);
 config.set_initial_size = 1;
 config.initial_size = to!int(args[2])*1024*1024;
 config.max_size = 4*to!int(args[2])*1024*1024;
 H5Fset_mdc_config(file, &config);
 H5Fclose(file);
 return 0;
}