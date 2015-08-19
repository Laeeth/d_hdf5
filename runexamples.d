#!/usr/bin/rdmd
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
	writefln("*** building list of projects to run");
	chdir("data");
	foreach(entry;dirEntries("../build",SpanMode.breadth))
	{
		if ((entry.isDir)||(entry.name.baseName.indexOf(".")!=-1))
			continue;
		else
			work~=entry.name;
	}
	foreach(entry;work)
	{
		writefln("*** about to run %s; press enter",entry.baseName);
		auto line=readln();
		auto ret=executeShell(entry);
		if (ret.status==0)
			writefln("*** results:\n%s",ret.output);
		else
		{
			writefln("**************failed");
			writefln("output: %s", ret.output);			
		}
		writefln("\n");
	}
	chdir("..");
}