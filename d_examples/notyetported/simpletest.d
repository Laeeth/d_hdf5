import std.stdio;
import hdf5.hdf5;
import hdf5.H5Dpublic;
import std.exception;
import std.string;
import std.utf;

char *f_work;
enum NULL=0;

int main()
{
	long[6][4] dset_data;

	/* Initialize the dataset. */
	foreach(i;0..4)
		foreach(j;0..6)
			dset_data[i][j] = i * 6 + j + 1;


	f_work=toUTFz!(char*)("dset.h5");
	auto e=H5open();
	if ((cast(long)(e))!=0L)
		throw new Exception("H5open non zero");
	uint majnum, minnum, relnum;
	H5get_libversion(&majnum, &minnum, &relnum);
	H5check_version(majnum, minnum, relnum);
	writefln("%s %s",majnum,relnum);
	hsize_t dims[2];
	
	
  // Create a new file using default properties. 
  auto file_id = H5Fcreate(f_work, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
  

	dims[0]=5;
	dims[1]=6;
	auto dataspace_id=H5Screate_simple(2,cast(const ulong*)dims.ptr,cast(const ulong*)NULL);
	//auto  dataset_id = H5Dcreate2(file_id, "/dset", H5T_STD_I32BE, dataspace_id, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  /* Open an existing file. */
  file_id = H5Fopen(f_work, H5F_ACC_RDWR, H5P_DEFAULT);

  /* Open an existing dataset. */
  auto dataset_id = H5Dopen2(file_id, "/dset", H5P_DEFAULT);



   	/* Write the dataset. */
   	auto status = H5Dwrite(dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(const void *) dset_data);
	writefln("write status=%s",status);
	foreach(i;0..4)
		foreach(j;0..6)
			dset_data[i][j]=0;
	status = H5Dread(dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(void *)dset_data);
	foreach(i;0..4)
		foreach(j;0..6)
			writefln("%s,%s:%s",i,j,dset_data[i][j]);
	writefln("read status=%s",status);

	/* End access to the dataset and release resources used by it. */
	status = H5Dclose(dataset_id);
	writefln("status 1=%s",status);
	/* Terminate access to the data space. */ 
	status = H5Sclose(dataspace_id);
	writefln("status 2=%s",status);
   	/* Close the file. */
 	status = H5Fclose(file_id);
	H5close();
	
	return 1;
}

int createattrib()
{
   const FILE="testfile";
   hid_t       file_id, dataset_id, attribute_id, dataspace_id;  /* identifiers */
   hsize_t     dims;
   int         attr_data[2];
   herr_t      status;

   /* Initialize the attribute data. */
   attr_data[0] = 100;
   attr_data[1] = 200;

   /* Open an existing file. */
   file_id = H5Fopen(cast(const char*)FILE, H5F_ACC_RDWR, H5P_DEFAULT);

   /* Open an existing dataset. */
   dataset_id = H5Dopen2(file_id, "/dset", H5P_DEFAULT);

   /* Create the data space for the attribute. */
   dims = 2;
   dataspace_id = H5Screate_simple(1, &dims, cast(const ulong*)NULL);

   /* Create a dataset attribute. */
   attribute_id = H5Acreate2 (dataset_id, "Units", H5T_STD_I32BE, dataspace_id, 
                             H5P_DEFAULT, H5P_DEFAULT);

   /* Write the attribute data. */
   status = H5Awrite(attribute_id, H5T_NATIVE_INT, cast(const ulong*)attr_data);

   /* Close the attribute. */
   status = H5Aclose(attribute_id);

   /* Close the dataspace. */
   status = H5Sclose(dataspace_id);

   /* Close to the dataset. */
   status = H5Dclose(dataset_id);

   /* Close the file. */
   status = H5Fclose(file_id);
   return status;
}

int creategroup(string FILE)
{

   hid_t       file_id, group_id;  /* identifiers */
   herr_t      status;

   /* Create a new file using default properties. */
   file_id = H5Fcreate(cast(const char*)FILE, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

   /* Create a group named "/MyGroup" in the file. */
   group_id = H5Gcreate2(file_id, "/MyGroup", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

   /* Close the group. */
   status = H5Gclose(group_id);

   /* Terminate access to the file. */
   status = H5Fclose(file_id);
   return status;
}


/*
 *  This example illustrates the creation of groups using absolute and 
 *  relative names.  It is used in the HDF5 Tutorial.
 */

int creategroupsinfile(string FILE)
{

   hid_t       file_id, group1_id, group2_id, group3_id;  /* identifiers */
   herr_t      status;

   /* Create a new file using default properties. */
   file_id = H5Fcreate(cast(const char *)FILE, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

   /* Create group "MyGroup" in the root group using absolute name. */
   group1_id = H5Gcreate2(file_id, "/MyGroup", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

   /* Create group "Group_A" in group "MyGroup" using absolute name. */
   group2_id = H5Gcreate2(file_id, "/MyGroup/Group_A", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

   /* Create group "Group_B" in group "MyGroup" using relative name. */
   group3_id = H5Gcreate2(group1_id, "Group_B", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

   /* Close groups. */
   status = H5Gclose(group1_id);
   status = H5Gclose(group2_id);
   status = H5Gclose(group3_id);

   /* Close the file. */
   status = H5Fclose(file_id);
   return status;
}


/*
 *  This example illustrates how to create a dataset in a group.
 *  It is used in the HDF5 Tutorial.
 */

int createdatasetingroup(string FILE)
{

   hid_t       file_id, group_id, dataset_id, dataspace_id;  /* identifiers */
   hsize_t     dims[2];
   herr_t      status;
   int         dset1_data[3][3];
   int         dset2_data[2][10];

   /* Initialize the first dataset. */
   foreach(i;0.. 3)
      foreach (j;0.. 3)
         dset1_data[i][j] = j + 1;

   /* Initialize the second dataset. */
   foreach(i;0.. 2)
      foreach(j;0..10)
         dset2_data[i][j] = j + 1;

   /* Open an existing file. */
   file_id = H5Fopen(cast(const char*)FILE, H5F_ACC_RDWR, H5P_DEFAULT);

   /* Create the data space for the first dataset. */
   dims[0] = 3;
   dims[1] = 3;
   dataspace_id = H5Screate_simple(2, cast(const ulong*)dims, cast(const ulong*)NULL);

   /* Create a dataset in group "MyGroup". */
   dataset_id = H5Dcreate2(file_id, "/MyGroup/dset1", H5T_STD_I32BE, dataspace_id,
                          H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

   /* Write the first dataset. */
   status = H5Dwrite(dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT,cast(const void*)dset1_data);

   /* Close the data space for the first dataset. */
   status = H5Sclose(dataspace_id);

   /* Close the first dataset. */
   status = H5Dclose(dataset_id);

   /* Open an existing group of the specified file. */
   group_id = H5Gopen2(file_id, "/MyGroup/Group_A", H5P_DEFAULT);

   /* Create the data space for the second dataset. */
   dims[0] = 2;
   dims[1] = 10;
   dataspace_id = H5Screate_simple(2, cast(const ulong*)dims, cast(const ulong*)NULL);

   /* Create the second dataset in group "Group_A". */
   dataset_id = H5Dcreate2(group_id, "dset2", H5T_STD_I32BE, dataspace_id, 
                          H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

   /* Write the second dataset. */
   status = H5Dwrite(dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT,cast(const void*)dset2_data);

   /* Close the data space for the second dataset. */
   status = H5Sclose(dataspace_id);

   /* Close the second dataset */
   status = H5Dclose(dataset_id);

   /* Close the group. */
   status = H5Gclose(group_id);

   /* Close the file. */
   status = H5Fclose(file_id);
   return status;
}

/* 
 *  This example illustrates how to read/write a subset of data (a slab) 
 *  from/to a dataset in an HDF5 file.  It is used in the HDF5 Tutorial.
 */
 


int readwriteslabmain ()
{
    enum
    {
      FILE="subset.h5",
      DATASETNAME="IntArray",
      RANK=2,
      DIM0_SUB=3,                         /* subset dimensions */ 
      DIM1_SUB=4,
      DIM0 =8,                          /* size of dataset */       
      DIM1 = 10,
    }
    hsize_t     dims[2];
    hsize_t     dimsm[2];   
    int         data[DIM0][DIM1];           /* data to write */
    int         sdata[DIM0_SUB][DIM1_SUB];  /* subset to write */
    int         rdata[DIM0][DIM1];          /* buffer for read */
 
    hid_t       file_id, dataset_id;        /* handles */
    hid_t       dataspace_id, memspace_id; 

    herr_t      status;                             
   
    hsize_t     count[2];              /* size of subset in the file */
    hsize_t     offset[2];             /* subset offset in the file */
    hsize_t     stride[2];
    hsize_t     block[2];

    
    /*****************************************************************
     * Create a new file with default creation and access properties.*
     * Then create a dataset and write data to it and close the file *
     * and dataset.                                                  *
     *****************************************************************/

    file_id = H5Fcreate (FILE, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    dims[0] = DIM0;
    dims[1] = DIM1;
    dataspace_id = H5Screate_simple (RANK, cast(ulong*)dims, cast(ulong*)NULL); 

    dataset_id = H5Dcreate2 (file_id, DATASETNAME, H5T_STD_I32BE, dataspace_id,
                            H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);


    foreach(j;0..DIM0) {
	     foreach(i;0..DIM1)
            if (i< (DIM1/2))
	             data[j][i] = 1;
            else
               data[j][i] = 2;
    }     

    status = H5Dwrite (dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL,H5P_DEFAULT,cast(const void*) data);

    writefln("\nData Written to File:");
    foreach(i;0..DIM0){
       foreach(j;0..DIM1)
           writefln(" %i", data[i][j]);
       writefln("");
    }
    status = H5Sclose (dataspace_id);
    status = H5Dclose (dataset_id);
    status = H5Fclose (file_id);


    /*****************************************************
     * Reopen the file and dataset and write a subset of *
     * values to the dataset. 
     *****************************************************/

    file_id = H5Fopen (FILE, H5F_ACC_RDWR, H5P_DEFAULT);
    dataset_id = H5Dopen2 (file_id, DATASETNAME, H5P_DEFAULT);

    /* Specify size and shape of subset to write. */

    offset[0] = 1;
    offset[1] = 2;

    count[0]  = DIM0_SUB;  
    count[1]  = DIM1_SUB;

    stride[0] = 1;
    stride[1] = 1;

    block[0] = 1;
    block[1] = 1;

    /* Create memory space with size of subset. Get file dataspace 
       and select subset from file dataspace. */

    dimsm[0] = DIM0_SUB;
    dimsm[1] = DIM1_SUB;
    memspace_id = H5Screate_simple (RANK, cast(const ulong*)dimsm, cast(ulong*)0); 

    dataspace_id = H5Dget_space (dataset_id);
    status = H5Sselect_hyperslab (dataspace_id, cast(H5S_seloper_t) H5S_SELECT_SET, cast(const ulong*)offset,cast(const ulong*)stride, cast(const ulong*)count, cast(const ulong*)block);

    /* Write a subset of data to the dataset, then read the 
       entire dataset back from the file.  */

    writefln("\nWrite subset to file specifying:");
    writefln("    offset=1x2 stride=1x1 count=3x4 block=1x1");
    foreach(j;0..DIM0_SUB) {
	foreach(i;0.. DIM1_SUB)
	   sdata[j][i] = 5;
    }     

    status = H5Dwrite (dataset_id, H5T_NATIVE_INT, memspace_id,dataspace_id, H5P_DEFAULT, cast(const void*)sdata);
    
    status = H5Dread (dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL,H5P_DEFAULT, cast(void*)rdata);

    writefln("\nData in File after Subset is Written:");
    foreach(i;0..DIM0){
       foreach(j;0..DIM1)
           writefln(" %i", rdata[i][j]);
       writefln("");
    }

    status = H5Sclose (memspace_id);
    status = H5Sclose (dataspace_id);
    status = H5Dclose (dataset_id);
    status = H5Fclose (file_id);
    return status;
}


/*
 *  This example how to work with extendible datasets. The dataset 
 *  must be chunked in order to be extendible.
 * 
 *  It is used in the HDF5 Tutorial.
 */



int createextendibeldatasetmain ()
{
    enum
    {
      FILENAME ="extend.h5",
      DATASETNAME= "ExtendibleArray",
      RANK         =2,
    }
    hid_t        file;                          /* handles */
    hid_t        dataspace, dataset;  
    hid_t        filespace, memspace;
    hid_t        prop;                     

    hsize_t      dims[2]  = [3, 3];           /* dataset dimensions at creation time */		
    hsize_t      maxdims[2] = [H5S_UNLIMITED, H5S_UNLIMITED];
    herr_t       status;                             
    hsize_t      chunk_dims[2] = [2, 5];
    int          data[3][3] = [ [1, 1, 1],    /* data to write */
                                [1, 1, 1],
                                [1, 1, 1] ];      

    /* Variables used in extending and writing to the extended portion of dataset */
    hsize_t      size[2];
    hsize_t      offset[2];
    hsize_t      dimsext[2] = [7, 3];         /* extend dimensions */
    int          dataext[7][3] = [ [2, 3, 4], 
                                   [2, 3, 4], 
                                   [2, 3, 4], 
                                   [2, 3, 4], 
                                   [2, 3, 4], 
                                   [2, 3, 4], 
                                   [2, 3, 4] ];

    /* Variables used in reading data back */
    hsize_t      chunk_dimsr[2];
    hsize_t      dimsr[2];
    int          rdata[10][3];
    herr_t       status_n;                             
    int          rank, rank_chunk;

    /* Create the data space with unlimited dimensions. */
    dataspace = H5Screate_simple (RANK, cast(const ulong*)dims, cast(const ulong*)maxdims); 

    /* Create a new file. If file exists its contents will be overwritten. */
    file = H5Fcreate (FILENAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    /* Modify dataset creation properties, i.e. enable chunking  */
    prop = H5Pcreate (H5P_DATASET_CREATE);
    status = H5Pset_chunk (prop, RANK,cast(const ulong*) chunk_dims);

    /* Create a new dataset within the file using chunk 
       creation properties.  */
    dataset = H5Dcreate2 (file, DATASETNAME, H5T_NATIVE_INT, dataspace,
                         H5P_DEFAULT, prop, H5P_DEFAULT);

    /* Write data to dataset */
    status = H5Dwrite (dataset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL,H5P_DEFAULT, cast(const void*)data);

    /* Extend the dataset. Dataset becomes 10 x 3  */
    size[0] = dims[0]+ dimsext[0];
    size[1] = dims[1];
    status = H5Dset_extent (dataset, size);

    /* Select a hyperslab in extended portion of dataset  */
    filespace = H5Dget_space (dataset);
    offset[0] = 3;
    offset[1] = 0;
    status = H5Sselect_hyperslab (filespace, cast(H5S_seloper_t) H5S_SELECT_SET, cast(ulong*)offset, cast(ulong*)NULL,cast(ulong*)dimsext, cast(ulong*)NULL);  

    /* Define memory space */
    memspace = H5Screate_simple (RANK, cast(ulong*)dimsext, cast(ulong*) NULL); 

    /* Write the data to the extended portion of dataset  */
    status = H5Dwrite (dataset, H5T_NATIVE_INT, memspace, filespace,H5P_DEFAULT,cast(const void*) dataext);

    /* Close resources */
    status = H5Dclose (dataset);
    status = H5Pclose (prop);
    status = H5Sclose (dataspace);
    status = H5Sclose (memspace);
    status = H5Sclose (filespace);
    status = H5Fclose (file);

    /********************************************
     * Re-open the file and read the data back. *
     ********************************************/

    file = H5Fopen (FILENAME, H5F_ACC_RDONLY, H5P_DEFAULT);
    dataset = H5Dopen2 (file, DATASETNAME, H5P_DEFAULT);

    filespace = H5Dget_space (dataset);
    rank = H5Sget_simple_extent_ndims (filespace);
    status_n = H5Sget_simple_extent_dims (filespace, cast(ulong*)dimsr, cast(ulong*)NULL);

    prop = H5Dget_create_plist (dataset);

    if (H5D_layout_t.H5D_CHUNKED == H5Pget_layout (prop)) 
       rank_chunk = H5Pget_chunk (prop, rank, cast(ulong*)chunk_dimsr);

    memspace = H5Screate_simple (rank, cast(const ulong*)dimsr, cast(const ulong*)NULL);
    status = H5Dread (dataset, H5T_NATIVE_INT, memspace, filespace,H5P_DEFAULT, cast(void*)rdata);

    writefln("");
    writefln("Dataset: ");
    foreach(j;0..dimsr[0])
    {
       foreach(i;0..dimsr[1])
           writefln("%d ", rdata[j][i]);
       writefln("");
    }

    status = H5Pclose (prop);
    status = H5Dclose (dataset);
    status = H5Sclose (filespace);
    status = H5Sclose (memspace);
    status = H5Fclose (file);
    return status;
}


/* 
 *  This example illustrates how to create a compressed dataset.
 *  It is used in the HDF5 Tutorial.
 */ 

 
int createcompresseddataset()
{
    enum
    {
      FILE  ="cmprss.h5",
      RANK    =2,
      DIM0    =100,
      DIM1    =20,
    }
    hid_t    file_id, dataset_id, dataspace_id; /* identifiers */
    hid_t    plist_id; 

    size_t   nelmts;
    uint flags, filter_info;
    H5Z_filter_t filter_type;

    herr_t   status;
    hsize_t  dims[2];
    hsize_t  cdims[2];
 
    int      idx;
    int      numfilt;
    int      buf[DIM0][DIM1];
    int      rbuf [DIM0][DIM1];

    /* Uncomment these variables to use SZIP compression 
    unsigned szip_options_mask;
    unsigned szip_pixels_per_block;
    */

    /* Create a file.  */
    file_id = H5Fcreate (FILE, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);


    /* Create dataset "Compressed Data" in the group using absolute name.  */
    dims[0] = DIM0;
    dims[1] = DIM1;
    dataspace_id = H5Screate_simple (RANK, cast(const ulong*)dims, cast(const ulong*)NULL);

    plist_id  = H5Pcreate (H5P_DATASET_CREATE);

    /* Dataset must be chunked for compression */
    cdims[0] = 20;
    cdims[1] = 20;
    status = H5Pset_chunk (plist_id, 2, cast(ulong*)cdims);

    /* Set ZLIB / DEFLATE Compression using compression level 6.
     * To use SZIP Compression comment out these lines. 
    */ 
    status = H5Pset_deflate (plist_id, 6); 

    /* Uncomment these lines to set SZIP Compression 
    szip_options_mask = H5_SZIP_NN_OPTION_MASK;
    szip_pixels_per_block = 16;
    status = H5Pset_szip (plist_id, szip_options_mask, szip_pixels_per_block);
    */
    
    dataset_id = H5Dcreate2 (file_id, "Compressed_Data", H5T_STD_I32BE, dataspace_id, H5P_DEFAULT, plist_id, cast(ulong*)H5P_DEFAULT); 

    foreach(i;0..DIM0) 
        foreach(j;0..DIM1)
           buf[i][j] = i+j;

    status = H5Dwrite (dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT,cast(void*) buf);

    status = H5Sclose (dataspace_id);
    status = H5Dclose (dataset_id);
    status = H5Pclose (plist_id);
    status = H5Fclose (file_id);

    /* Now reopen the file and dataset in the file. */
    file_id = H5Fopen (FILE, H5F_ACC_RDWR, H5P_DEFAULT);
    dataset_id = H5Dopen2 (file_id, "Compressed_Data", H5P_DEFAULT);

    /* Retrieve filter information. */
    plist_id = H5Dget_create_plist (dataset_id);
    
    numfilt = H5Pget_nfilters (plist_id);
    writefln("Number of filters associated with dataset: %i", numfilt);
     
    foreach(i;0..numfilt) {
       nelmts = 0;
       filter_type = H5Pget_filter2 (plist_id, cast(uint)0, cast(int*)&flags, &nelmts,cast(uint[]) [0], cast(ulong)0L, cast(char[])"",&filter_info);
       writefln("Filter Type: ");
       switch (filter_type) {
         case H5Z_FILTER_DEFLATE:
              writefln("H5Z_FILTER_DEFLATE");
              break;
         case H5Z_FILTER_SZIP:
              writefln("H5Z_FILTER_SZIP");
              break;
         default:
              writefln("Other filter type included.");
         }
    }

    status = H5Dread (dataset_id, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, cast(void*)rbuf); 
    
    status = H5Dclose (dataset_id);
    status = H5Pclose (plist_id);
    status = H5Fclose (file_id);
    return status;
}

