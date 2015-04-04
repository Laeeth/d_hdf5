/**
  Copyright by The HDF Group.                                               *
  Copyright by the Board of Trustees of the University of Illinois.         *
  All rights reserved.                                                      *
																			*
  This file is part of HDF5.  The full HDF5 copyright notice, including     *
  terms governing use, modification, and redistribution, is contained in    *
  the files COPYING and Copyright.html.  COPYING can be found at the root   *
  of the source code distribution tree; Copyright.html can be found at the  *
  root level of an installed copy of the electronic HDF5 document set and   *
  is linked from the top-level documents page.  It can also be found at     *
  http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          *
  access to either file, you may request a copy from help@hdfgroup.org.     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  Ported to the D Programming Language 2015 by Laeeth Isharc
*/

import hdf5.bindings.api;
import hdf5.bindings.enums;
import hdf5.wrap;

/**

 Table API example
 
  H5TBmake_table
  H5TBread_table
 
*/

enum hsize_t NumFields = 5;
enum hsize_t NumRecords = 8;
enum TableName = "table";


int main( string[] args)
{
	struct Particle
	{
		char[16]   name;
		int    lati;
		int    longi;
		float  pressure;
		double temperature;
	}

	Particle[NumRecords] dst_buf;

 // Calculate the size and the offsets of our struct members in memory

	size_t dst_size =  Particle.sizeof;
	size_t[NumFields] dst_offset = { HOFFSET( Particle, name ),
							HOFFSET( Particle, lati ),
							HOFFSET( Particle, longi ),
							HOFFSET( Particle, pressure ),
							HOFFSET( Particle, temperature )};

	size_t[NumFields] dst_sizes = { sizeof( dst_buf[0].name),
						   sizeof( dst_buf[0].lati),
						   sizeof( dst_buf[0].longi),
						   sizeof( dst_buf[0].pressure),
						   sizeof( dst_buf[0].temperature)};


	/* Define an array of Particles */
	Particle[NumRecords]  p_data = {
	{"zero",0,0, 0.0f, 0.0},
	{"one",10,10, 1.0f, 10.0},
	{"two",  20,20, 2.0f, 20.0},
	{"three",30,30, 3.0f, 30.0},
	{"four", 40,40, 4.0f, 40.0},
	{"five", 50,50, 5.0f, 50.0},
	{"six",  60,60, 6.0f, 60.0},
	{"seven",70,70, 7.0f, 70.0}
	};

	/* Define field information */
	const char *[NumFields] field_names  =
	{ "Name","Latitude", "Longitude", "Pressure", "Temperature" };
	hid_t[NumFields] field_type;
	hid_t      string_type;
	hid_t      file_id;
	hsize_t    chunk_size = 10;
	int        *fill_data = NULL;
	int        compress  = 0;
	herr_t     status;
	int        i;

	/* Initialize field_type */
	string_type = H5Tcopy( H5T_C_S1 );
	H5Tset_size( string_type, 16 );
	field_type[0] = string_type;
	field_type[1] = H5T_NATIVE_INT;
	field_type[2] = H5T_NATIVE_INT;
	field_type[3] = H5T_NATIVE_FLOAT;
	field_type[4] = H5T_NATIVE_DOUBLE;

	/* Create a new file using default properties. */
	file_id = H5Fcreate( "ex_table_01.h5", H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT );

	/*-------------------------------------------------------------------------
	* H5TBmake_table
	*-------------------------------------------------------------------------
	*/

	status=H5TBmake_table( "Table Title", file_id, TableName,NumFields,NumRecords,
					 dst_size,field_names, dst_offset, field_type,
					 chunk_size, fill_data, compress, p_data  );

	// H5TBread_table
	status=H5TBread_table( file_id, TableName, dst_size, dst_offset, dst_sizes, dst_buf );

	// print it by rows
	foreach(i;0..NumRecords)
		writefln("%-5s %-5d %-5d %-5f %-5f", dst_buf[i].name, dst_buf[i].lati, dst_buf[i].longi, dst_buf[i].pressure, dst_buf[i].temperature);


	H5Tclose( string_type ); // close type
	H5Fclose( file_id );	// close file

	return 0;
}
