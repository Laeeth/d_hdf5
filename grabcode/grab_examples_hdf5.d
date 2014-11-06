import std.stdio;
import std.net.curl;
import std.utf;
import std.range;
import std.algorithm;
import std.string;

string f_url="www.hdfgroup.org/ftp/HDF5/examples/files/exbyapi/";
string f_home;
void main()
{
	f_home=f_url;
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
				if (indexOf(line,".h5")>0)
					urls~=cast(string)(line[a+6..a+6+b]);
		}
	}
	foreach(url;urls)
	{
		writefln("%s",f_home~ url);
		std.net.curl.download(cast(char[])(f_home ~ url),url);
	}
}


