/**
  Ported to D Language by Laeeth Isharc 2014, 2015

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
  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
*/

import hdf5.wrap;
import hdf5.bindings.api;
import hdf5.bindings.enums;

/**

 This program reads binary output from h5dump (-b option).
 To use change the following 3 symbols accordingly.
 For example, to read 2 elements of a float type , define

  enum NELMTS = 2
  alias TYPE       float
  enum FORMAT = "%f ";
*/

enum NELMTS =      6;
alias TYPE     =int;
enum FORMAT     ="%d ";

/*-------------------------------------------------------------------------
 * Function: usage
 *
 * Purpose: Prints a usage message on stderr and then returns.
 *
 * Return: void
 *
 * Programmer:  Pedro Vicente Nunes
 *
 * Modifications:
 *
 *-------------------------------------------------------------------------
 */
void usage()
{
  stderr.writefln("\tusage: binread FILE_NAME\n");
}

/*-------------------------------------------------------------------------
 * Function: main
 *
 * Purpose: main program.
 *
 *-------------------------------------------------------------------------
 */

int main (string[] args_
{
 FILE  *stream;
 int    numread;
 TYPE   buf[NELMTS];
 size_t i, nelmts = NELMTS;
 char  *fname=NULL;

 if (args.length != 2)
 {
  usage();
  exit(1);
 }

 fname = strdup(argv[1]);

 if( (stream = fopen(fname, "rb" )) != NULL )
 {
  numread = fread( buf, sizeof( TYPE ), nelmts, stream );
  printf( "Number of items read = %d\n", numread );

  for (i = 0; i < nelmts; i++)
  {
   printf(FORMAT,buf[i]);
  }
  printf("\n");

  fclose( stream );
 }
 else
  printf( "File %s could not be opened\n",fname );

 free(fname);

 return 0;
}

