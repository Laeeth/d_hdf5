import std.file;
import std.path;
import std.stdio;
import std.string;
import std.exception;
import std.process;

void main(string[] args)
{
	string[] work;
	string[] desc;
	string[] file;
	writefln("*** building list of projects to build");
	foreach(entry;dirEntries(".",SpanMode.breadth))
	{
		if (!entry.isDir)
			continue;
		if (!exists(entry.name~"/"~"source"))
			continue;
		foreach(sourceFile;dirEntries(entry.name~"/"~"source",SpanMode.depth))
		{
			if ((sourceFile.isDir)||(!sourceFile.name.endsWith(".d")))
				continue;
			work~=sourceFile.name;
		}
	}
	foreach(string f;work)
	{
		auto i=f.lastIndexOf("/source/");
		f=f[0..i];
		writefln("*** building %s",f);
		chdir(f);
		auto ls=executeShell(("dub build");
		if (ls.status!=0)
		{
			writefln("**** %s failed to build",f);
		}
		chdir("..");
	}
}
