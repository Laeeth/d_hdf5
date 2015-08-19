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
		auto i=text.indexOf("This example");
		if(i==-1)
		{
			writefln("skipping %s",f);
			continue;
		}
		auto j=text[i+20..$].indexOf("*/");
		if(j==-1)
		{
			writefln("skipping %s",f);
			continue;
		}
		desc~=text[i..i+j+20];
	}
	foreach(i,item;desc)
	{
		auto sdlPath=work[i].makePackageRootPath~"dub.sdl";
		if (sdlPath.exists)
			sdlPath.remove;
		auto jsonPath=work[i].makeJsonPath;
		auto json=cast(string)read(jsonPath);
		auto newJson=json.replaceField("name",work[i].extractPackageName)
						.replaceField("description","\n"~item~"\n");
		std.file.write(jsonPath,json);
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