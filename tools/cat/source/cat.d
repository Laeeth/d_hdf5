import hdf5.wrap;
import hdf5.bindings.enums;
import hdf5.bindings.api;
import std.stdio;
import std.file;


void main(string[] args)
{
	if (args.length!=2)
	{
		stderr.writefln("syntax is hdf5_cat <filename>");
		return;
	}
	auto fn=args[1];

	if (!exists(fn))
	{
		stderr.writefln("file does not exist; quitting");
		return;
	}
	auto file=H5F.open(fn,H5F_ACC_RDWR, H5P_DEFAULT);
	auto files=cast(string[])objectList(file);
	H5F.close(file);
	foreach(i,filename;files)
	{
		writef("%s\t",filename);
		if (i%4==0)
			write("\n");
	}
	writefln("\n\n* done");
	return;
}