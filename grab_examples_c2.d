import std.stdio;
import std.net.curl;
import std.utf;
import std.range;
import std.algorithm;
import std.string;

string f_url="www.hdfgroup.org/HDF5/examples/api18-c.html";
string f_home="www.hdfgroup.org/HDF5/examples/";

string nohttp(string s)
{
	auto i=indexOf(s,"http://");
	if (i>0)
		return s[i+7..$];
	else
		return s;
}
string nameonly(string s)
{
	auto i=lastIndexOf(s,"/");
	if (i>0)
		return s[i+1..$];
	else
		return s;
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
		if (a>0) {
			long b=indexOf(line[a+6..$],"\"");
			if (b>0)
			{
				//writefln("%s",line);
				if ((indexOf(line,".h5")>0)||(indexOf(line,".tst")>0)||(indexOf(line,".ddl")>0))
				{
					urls~=cast(string)(line[a+6..a+6+b]);
				}
			}
		}
	}
	foreach(url;urls)
	{
		writefln("%s", url);
		if (url[0..2]=="./")
			url=url[2..$];
		try
		{
			std.net.curl.download(cast(char[])(nohttp(url)),nameonly(url));
		}
		catch
		{
			writefln("%s failed",url);
		}
	}
}


