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

  Ported by Laeeth Isharc 2014 to the D Programming Language
  Use at your own risk!

  This example shows how to read and write a complex
  compound datatype to a dataset.  The program first writes
  complex compound structures to a dataset with a dataspace
  of DIM0, then closes the file.  Next, it reopens the file,
  reads back selected fields in the structure, and outputs
  them to the screen.

  Unlike the other datatype examples, in this example we
  save to the file using native datatypes to simplify the
  type definitions here.  To save using standard types you
  must manually calculate the sizes and offsets of compound
  types as shown in h5ex_t_cmpd.c, and convert enumerated
  values as shown in h5ex_t_enum.c.

  The datatype defined here consists of a compound
  containing a variable-length list of compound types, as
  well as a variable-length string, enumeration, double
  array, object reference and region reference.  The nested
  compound type contains an int, variable-length string and
  two doubles.
*/

import hdf5.wrap;
import hdf5.bindings.enums;
import std.stdio;
import std.exception;
import std.string;
 
enum filename="h5/h5ex_t_cpxcmpd.h5";
enum DATASET         ="DS1";
enum DIM0            =2;

struct sensor_t {
    int     serial_no;
    char    *location;
    double  temperature;
    double  pressure;
}                             /* Nested compound type */

enum color_t {
    RED,
    GREEN,
    BLUE
}                                /* Enumerated type */

struct vehicle_t
{
    hvl_t               sensors;
    char                *name;
    color_t             color;
    double              location[3];
    hobj_ref_t          group;
    hdset_reg_ref_t     surveyed_areas;
}

struct rvehicle_t {
    hvl_t       sensors;
    char        *name;
}                               /* Read type */

int main (string[] args)
{
    hid_t       file, vehicletype, colortype, sensortype, sensorstype, loctype,
                strtype, rvehicletype, rsensortype, rsensorstype, space, dset,
                group;
                                            /* Handles */
    herr_t      status;
    hsize_t[1]  dims = [DIM0],
                adims = [3];
    hsize_t[2]  adims2 = [32, 32],
                start = [8, 26],
                count = [4, 3];
    hsize_t[2][3] coords = [    [3, 2],
                                 [3, 3],
                                 [4, 4] ];
    vehicle_t[2]   wdata;                   /* Write buffer */
    rvehicle_t  *rdata;                     /* Read buffer */
    color_t     val;
    sensor_t[]    ptr;
    double[32][32]      wdata2;
    int         ndims;

    /*
     * Create a new file using the default properties.
     */
    file = H5F.create (FILE, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    /*
     * Create dataset to use for region references.
     */
    for (i=0; i<32; i++)
        for (j=0; j<32; j++)
            wdata2[i][j]= 70. + 0.1 * (i - 16.) + 0.1 * (j - 16.);
    space = H5S.create_simple (2, adims2, NULL);
    dset = H5D.create (file, "Ambient_Temperature", H5T_NATIVE_DOUBLE, space,
                H5P_DEFAULT);
     H5Dwrite (dset, H5T_NATIVE_DOUBLE, H5S_ALL, H5S_ALL, H5P_DEFAULT,
                cast(ubyte*)wdata2.ptr);
     H5D.close (dset);

    /*
     * Create groups to use for object references.
     */
    group = H5G.create (file, "Land_Vehicles", H5P_DEFAULT);
     H5G.close (group);
    group = H5G.create (file, "Air_Vehicles", H5P_DEFAULT);
     H5G.close (group);

    /*
     * Initialize variable-length compound in the first data element.
     */
    wdata[0].sensors.len = 4;
    ptr.length=wdata[0].sensors.len;
    ptr[0].serial_no = 1153;
    ptr[0].location = "Exterior (static)";
    ptr[0].temperature = 53.23;
    ptr[0].pressure = 24.57;
    ptr[1].serial_no = 1184;
    ptr[1].location = "Intake";
    ptr[1].temperature = 55.12;
    ptr[1].pressure = 22.95;
    ptr[2].serial_no = 1027;
    ptr[2].location = "Intake manifold";
    ptr[2].temperature = 103.55;
    ptr[2].pressure = 31.23;
    ptr[3].serial_no = 1313;
    ptr[3].location = "Exhaust manifold";
    ptr[3].temperature = 1252.89;
    ptr[3].pressure = 84.11;
    wdata[0].sensors.p = (void *) ptr;

    /*
     * Initialize other fields in the first data element.
     */
    wdata[0].name = "Airplane";
    wdata[0].color = GREEN;
    wdata[0].location[0] = -103234.21;
    wdata[0].location[1] = 422638.78;
    wdata[0].location[2] = 5996.43;
     H5Rcreate (&wdata[0].group, file, "Air_Vehicles", H5R_OBJECT, -1);
     H5Sselect_elements (space, H5S_SELECT_SET, 3, coords[0]);
     H5Rcreate (&wdata[0].surveyed_areas, file, "Ambient_Temperature",
                H5R_DATASET_REGION, space);

    /*
     * Initialize variable-length compound in the second data element.
     */
    wdata[1].sensors.len = 1;
    ptr = (sensor_t *) malloc (wdata[1].sensors.len * sizeof (sensor_t));
    ptr[0].serial_no = 3244;
    ptr[0].location = "Roof";
    ptr[0].temperature = 83.82;
    ptr[0].pressure = 29.92;
    wdata[1].sensors.p = cast(void *) ptr;

    /*
     * Initialize other fields in the second data element.
     */
    wdata[1].name = "Automobile";
    wdata[1].color = RED;
    wdata[1].location[0] = 326734.36;
    wdata[1].location[1] = 221568.23;
    wdata[1].location[2] = 432.36;
     H5Rcreate (&wdata[1].group, file, "Land_Vehicles", H5R_OBJECT, -1);
     H5Sselect_hyperslab (space, H5S_SELECT_SET, start, NULL, count,
                NULL);
     H5Rcreate (&wdata[1].surveyed_areas, file, "Ambient_Temperature",
                H5R_DATASET_REGION, space);

     H5Sclose (space);

    /*
     * Create variable-length string datatype.
     */
    strtype = H5Tcopy (H5T_C_S1);
     H5Tset_size (strtype, H5T_VARIABLE);

    /*
     * Create the nested compound datatype.
     */
    sensortype = H5T.create  (H5T_COMPOUND, sizeof (sensor_t));
     H5T.insert  (sensortype, "Serial number",
                HOFFSET (sensor_t, serial_no), H5T_NATIVE_INT);
     H5T.insert  (sensortype, "Location", HOFFSET (sensor_t, location),
                strtype);
     H5T.insert  (sensortype, "Temperature (F)",
                HOFFSET (sensor_t, temperature), H5T_NATIVE_DOUBLE);
     H5T.insert  (sensortype, "Pressure (inHg)",
                HOFFSET (sensor_t, pressure), H5T_NATIVE_DOUBLE);

    /*
     * Create the variable-length datatype.
     */
    sensorstype = H5T.vlen_create (sensortype);

    /*
     * Create the enumerated datatype.
     */
    colortype = H5T.enum_create (H5T_NATIVE_INT);
    val = cast(color_t) RED;
     H5T.enum_insert (colortype, "Red", &val);
    val = cast(color_t) GREEN;
     H5T.enum_insert (colortype, "Green", &val);
    val = cast(color_t) BLUE;
     H5T.enum_insert (colortype, "Blue", &val);

    /*
     * Create the array datatype.
     */
    loctype = H5T.array_create (H5T_NATIVE_DOUBLE, 1, adims, NULL);

    /*
     * Create the main compound datatype.
     */
    vehicletype = H5T.create  (H5T_COMPOUND, sizeof (vehicle_t));
     H5T.insert  (vehicletype, "Sensors", HOFFSET (vehicle_t, sensors),
                sensorstype);
     H5T.insert  (vehicletype, "Name", HOFFSET (vehicle_t, name),
                strtype);
     H5T.insert  (vehicletype, "Color", HOFFSET (vehicle_t, color),
                colortype);
     H5T.insert  (vehicletype, "Location", HOFFSET (vehicle_t, location),
                loctype);
     H5T.insert  (vehicletype, "Group", HOFFSET (vehicle_t, group),
                H5T_STD_REF_OBJ);
     H5T.insert  (vehicletype, "Surveyed areas",
                HOFFSET (vehicle_t, surveyed_areas), H5T_STD_REF_DSETREG);

    /*
     * Create dataspace.  Setting maximum size to NULL sets the maximum
     * size to be the current size.
     */
    space = H5S.create_simple(dims);

    /*
     * Create the dataset and write the compound data to it.
     */
    dset = H5D.create (file, DATASET, vehicletype, space, H5P_DEFAULT);
     H5D.write (dset, vehicletype, H5S_ALL, H5S_ALL, H5P_DEFAULT, wdata);

    /*
     * Close and release resources.  Note that we cannot use
     * H5Dvlen_reclaim as it would attempt to free() the string
     * constants used to initialize the name fields in wdata.  We must
     * therefore manually free() only the data previously allocated
     * through malloc().
     */
     H5D.close (dset);
     H5S.close (space);
     H5T.close (strtype);
     H5T.close (sensortype);
     H5T.close (sensorstype);
     H5T.close (colortype);
     H5T.close (loctype);
     H5T.close (vehicletype);
     H5F.close (file);


    /*
     * Now we begin the read section of this example.  Here we assume
     * the dataset has the same name and rank, but can have any size.
     * Therefore we must allocate a new array to read in data using
     * malloc().  We will only read back the variable length strings.
     */

    /*
     * Open file and dataset.
     */
    file = H5F.open (FILE, H5F_ACC_RDONLY, H5P_DEFAULT);
    dset = H5D.open (file, DATASET);

    /*
     * Create variable-length string datatype.
     */
    strtype = H5T.copy (H5T_C_S1);
     H5T.set_size (strtype, H5T_VARIABLE);

    /*
     * Create the nested compound datatype for reading.  Even though it
     * has only one field, it must still be defined as a compound type
     * so the library can match the correct field in the file type.
     * This matching is done by name.  However, we do not need to
     * define a structure for the read buffer as we can simply treat it
     * as a char *.
     */
    rsensortype = H5T.create  (H5T_COMPOUND, (char *).sizeof);
     H5T.insert  (rsensortype, "Location", 0, strtype);

    /*
     * Create the variable-length datatype for reading.
     */
    rsensorstype = H5Tvlen_create (rsensortype);

    /*
     * Create the main compound datatype for reading.
     */
    rvehicletype = H5T.create  (H5T_COMPOUND, sizeof (rvehicle_t));
     H5T.insert  (rvehicletype, "Sensors", HOFFSET (rvehicle_t, sensors),
                rsensorstype);
     H5T.insert  (rvehicletype, "Name", HOFFSET (rvehicle_t, name),
                strtype);

    /*
     * Get dataspace and allocate memory for read buffer.
     */
    space = H5D.get_space(dset);
    ndims = H5S.get_simple_extent_dims(dims);
    rdata.length=dims[0]*rvehicle_t.sizeof;

    /*
     * Read the data.
     */
     H5Dread (dset, rvehicletype, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(ubyte*)rdata);

    /*
     * Output the data to the screen.
     */
    foreach(i;0..dims[0])
    {
        writefln("%s[%d]:", DATASET, i);
        writefln("   Vehicle name :\n      %s", rdata[i].name);
        writefln("   Sensor locations :");
        foreach(j;0..rdata[i].sensors.len)
            writefln("      %s", to!string(rdata[i*rvehicle_t.sizeof].sensors.p )[j] );
    }

    /*
     * Close and release resources.  H5Dvlen_reclaim will automatically
     * traverse the structure and free any vlen data (including
     * strings).
     */
     H5D.vlen_reclaim (rvehicletype, space, H5P_DEFAULT, rdata);
     H5D.close (dset);
     H5S.close (space);
     H5T.close (strtype);
     H5T.close (rsensortype);
     H5T.close (rsensorstype);
     H5T.close (rvehicletype);
     H5F.close (file);

    return 0;
}
