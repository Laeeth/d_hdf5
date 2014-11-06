/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright by The HDF Group.                                               *
 * Copyright by the Board of Trustees of the University of Illinois.         *
 * All rights reserved.                                                      *
 *                                                                           *
 * This file is part of HDF5.  The full HDF5 copyright notice, including     *
 * terms governing use, modification, and redistribution, is contained in    *
 * the files COPYING and Copyright.html.  COPYING can be found at the root   *
 * of the source code distribution tree; Copyright.html can be found at the  *
 * root level of an installed copy of the electronic HDF5 document set and   *
 * is linked from the top-level documents page.  It can also be found at     *
 * http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          *
 * access to either file, you may request a copy from help@hdfgroup.org.     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/*
 * This is the main public HDF5 include file.  Put further information in
 * a particular header file and include that here, don't fill this file with
 * lots of gunk...
 */

module hdf5.hdf5;

/++ HEADERS
#include "H5Apublic.h"		/* Attributes				*/
#include "H5ACpublic.h"		/* Metadata cache			*/
#include "H5Epublic.h"		/* Errors				*/
#include "H5FDpublic.h"		/* File drivers				*/
#include "H5Gpublic.h"		/* Groups				*/
#include "H5Lpublic.h"		/* Links				*/
#include "H5MMpublic.h"		/* Memory management			*/
#include "H5Opublic.h"		/* Object headers			*/
#include "H5Rpublic.h"		/* References				*/
+/

public import hdf5.H5public;
public import hdf5.H5Apublic;
// public import hdf5.H5ACpublic;
public import hdf5.H5Dpublic;
// public import hdf5.H5Epublic;
public import hdf5.H5Fpublic;
// public import hdf5.H5FDpublic;
public import hdf5.H5Gpublic;
public import hdf5.H5Ipublic;
public import hdf5.H5Lpublic;
// public import hdf5.H5MMpublic;
public import hdf5.H5Opublic;
public import hdf5.H5Ppublic;
// public import hdf5.H5Rpublic;
public import hdf5.H5Spublic;
public import hdf5.H5Tpublic;
public import hdf5.H5Zpublic;

/++ HEADERS
/* Predefined file drivers */
#include "H5FDcore.h"		/* Files stored entirely in memory	*/
#include "H5FDfamily.h"		/* File families 			*/
#include "H5FDlog.h"        	/* sec2 driver with I/O logging (for debugging) */
#include "H5FDmulti.h"		/* Usage-partitioned file family	*/
#include "H5FDsec2.h"		/* POSIX unbuffered file I/O		*/
#include "H5FDstdio.h"		/* Standard C buffered I/O		*/
#ifdef H5_HAVE_WINDOWS
#include "H5FDwindows.h"        /* Windows buffered I/O     */
#endif
#include "H5FDdirect.h"     	/* Linux direct I/O			*/
+/

public import hdf5.H5FDmpio;

