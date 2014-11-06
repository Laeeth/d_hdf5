import std.stdio;
import std.net.curl;
import std.utf;
import std.range;
import std.algorithm;
import std.string;

string f_url="www.hdfgroup.org/ftp/HDF5/examples/examples-by-api/api16-c.html";
string f_home="www.hdfgroup.org/ftp/HDF5/examples/examples-by-api/";

string nameonly(string s)
{
	auto i=lastIndexOf(s,"/");
	return s[i+1..$];
}

void main()
{
	char[] s_url;
	s_url=cast(char[])f_url;
	char[] webpage;
	webpage=std.net.curl.get(cast(char[])s_url);
	string[] urls;
	//writefln("%s",webpage);
	auto buf=webpage.split("\n");
	foreach(line;buf)
	{
		auto a=indexOf(line,"href=\"");
		if (a>0)
		{
			auto b=indexOf(line[a+6..$],"\"");
			if (b>0)
				if (indexOf(line,".c\"")>0)
					urls~=cast(string)(line[a+6..a+6+b]);
		}
	}
	foreach(url;urls)
	{
		writefln("%s",f_home~ url);
		if (url[0..2]=="./")
			url=url[2..$];
		std.net.curl.download(cast(char[])(f_home ~ url),nameonly(url));
	}
}


