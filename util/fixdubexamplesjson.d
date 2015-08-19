import std.file;
import std.path;
import std.stdio;
import std.string;
import std.exception;

void main(string[] args)
{
	string[] work;
	string[] desc;
	string[] file;
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
	foreach(name;work)
		writefln("%s",name);
	foreach(string f;work)
	{
		auto text=cast(string)read(f);
		text=text.replace("import hdf5;","");
		text=text.replace("import hdf5.wrap;","");
		text=text.replace("import hdf5.bindings.enums;","import hdf5.hdf5;");
		text=text.replace("import hdf5.bindings.api;","");
		//writefln("%s",text);
		std.file.write(f,text);
	}
}

string extractPackageName(string s)
{
	auto i=s.indexOf("/source/");
	s=s[0..i];
	i=s.lastIndexOf("/");
	return s[i+1..$];
}
string makePackageRootPath(string s)
{
	auto i=s.indexOf("/source/");
	return s[0..i]~"/";
}

string makeJsonPath(string s)
{
	auto i=s.indexOf("/source/");
	return s[0..i]~"/dub.json";
}

string replaceField(string json, string field, string newValue)
{
	field ="\"" ~field~"\":";
	auto i=json.indexOf(field);
	auto oldValueBegin=json[i+field.length..$].indexOf("\"");
	enforce(oldValueBegin!=-1);
	oldValueBegin+=i+field.length;
	auto oldValueEnd=json[oldValueBegin+1..$].indexOf("\"");
	enforce(oldValueEnd!=-1);
	oldValueEnd+=oldValueBegin+1;
	return json[0..oldValueBegin]~"\""~newValue~"\""~json[oldValueEnd+1..$];
}