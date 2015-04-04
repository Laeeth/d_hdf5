/**

  Ported to the D Programming Language 2014, 2015 by Laeeth Isharc

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
*/

import hdf5.wrap;
import hdf5.bindings.enums;
import hdf5.bindings.api;
import std.stdio;
import std.conv;
import std.exception;
/* Name of tool */
enum PROGRAMNAME="h5jam";

hsize_t writePad (int, hsize_t);
hsize_t computeUserBlockSize (hsize_t);
hsize_t copySomeToFile (int, int, hsize_t, hsize_t, ssize_t);
void parseCommandLine (int, const char *[]);

bool doClobber = false;
string outputFile = null;
string inputFile = null;
string ubFile = null;

/*
 * Command-line options: The user can specify short or long-named
 * parameters. The long-named ones can be partially spelled. When
 * adding more, make sure that they don't clash with each other.
 */
static const char *s_opts = "hi:u:o:c:V";  /* add more later ? */
static struct LongOptions l_opts[] = {
  {"help", no_arg, 'h'},
  {"hel", no_arg, 'h'},
  {"i", require_arg, 'i'},  /* input file */
  {"u", require_arg, 'u'},  /* user block file */
  {"o", require_arg, 'o'},  /* output file */
  {"clobber", no_arg, 'c'},  /* clobber existing UB */
  {"clobbe", no_arg, 'c'},
  {"clobb", no_arg, 'c'},
  {"clob", no_arg, 'c'},
  {"clo", no_arg, 'c'},
  {"cl", no_arg, 'c'},
  {null, 0, '\0'}
};

/*-------------------------------------------------------------------------
 * Function:    usage
 *
 * Purpose:     Print the usage message
 *
 * Return:      void
 *
 * Programmer:
 *
 * Modifications:
 *
 *-------------------------------------------------------------------------
 */
void usage (string prog)
{
    stdout.flush;
    writefln("usage: %s -i <in_file.h5> -u <in_user_file> [-o <out_file.h5>] [--clobber]", prog);
    writefln("Adds user block to front of an HDF5 file and creates a new concatenated file.");
    writefln("OPTIONS");
    writefln("  -i in_file.h5    Specifies the input HDF5 file.");
    writefln("  -u in_user_file  Specifies the file to be inserted into the user block.");
    writefln("                   Can be any file format except an HDF5 format.");
    writefln("  -o out_file.h5   Specifies the output HDF5 file.");
    writefln("                   If not specified, the user block will be concatenated in");
    writefln("                   place to the input HDF5 file.");
    writefln("  --clobber        Wipes out any existing user block before concatenating");
    writefln("                   the given user block.");
    writefln("                   The size of the new user block will be the larger of;");
    writefln("                    - the size of existing user block in the input HDF5 file");
    writefln("                    - the size of user block required by new input user file");
    writefln("                   (size = 512 x 2N,  N is positive integer.)");
    writefln( "\n");
    writefln("  -h               Prints a usage message and exits.");
    writefln("  -V               Prints the HDF5 library version and exits.");
    writefln( "\n");
    writefln("Exit Status:");
    writefln("   0   Succeeded.");
    writefln("   >0  An error occurred.");
}


/*-------------------------------------------------------------------------
 * Function:    leave
 *
 * Purpose:     Shutdown and call exit()
 *
 * Return:      Does not return
 *
 *-------------------------------------------------------------------------
 */
void leave(int ret)
{
    if (ubFile)
        HDfree (ubFile);
    if (inputFile)
        HDfree (inputFile);
    if (outputFile)
        HDfree (outputFile);

    h5tools_close();

    HDexit(ret);
}

/*-------------------------------------------------------------------------
 * Function:    parseCommandLine
 *
 * Purpose:     Parse the command line for the h5dumper.
 *
 * Return:      Success:
 *
 *              Failure:    Exits program with EXIT_FAILURE value.
 *
 * Programmer:
 *
 * Modifications:
 *
 *-------------------------------------------------------------------------
 */

void parseCommandLine(string[] args)
{
  int opt = false;

  /* parse command line options */
  while ((opt = get_option (argc, argv, s_opts, l_opts)) != EOF)
    {
      switch ((char) opt)
      {
      case 'o':
          outputFile = HDstrdup (opt_arg);
          break;
      case 'i':
          inputFile = HDstrdup (opt_arg);
          break;
      case 'u':
          ubFile = HDstrdup (opt_arg);
          break;
      case 'c':
          doClobber = true;
          break;
      case 'h':
          usage (h5tools_getprogname());
          leave (EXIT_SUCCESS);
      case 'V':
          print_version (h5tools_getprogname());
          leave (EXIT_SUCCESS);
      case '?':
      default:
          usage (h5tools_getprogname());
          leave (EXIT_FAILURE);
      }
    }
}

/*-------------------------------------------------------------------------
 * Function:    main
 *
 * Purpose:     HDF5 user block jammer
 *
 * Return:      Success:    0
 *              Failure:    1
 *
 * Programmer:
 *
 * Modifications:
 *
 *-------------------------------------------------------------------------
 */
int main (string[] args)
{
    int         ufid = -1;
    int         h5fid = -1;
    int         ofid = -1;
    void       *edata;
    H5E_auto2_t func;
    hid_t       ifile = -1;
    hid_t       plist = -1;
    herr_t      status;
    htri_t      testval;
    hsize_t     usize;
    hsize_t     h5fsize;
    hsize_t     startub;
    hsize_t     where;
    hsize_t     newubsize;
    off_t       fsize;
    h5_stat_t   sbuf;
    h5_stat_t   sbuf2;
    int         res;

    h5tools_setprogname(PROGRAMNAME);
    h5tools_setstatus(EXIT_SUCCESS);

    /* Disable error reporting */
    H5Eget_auto2(H5E_DEFAULT, &func, &edata);
    H5Eset_auto2(H5E_DEFAULT, null, null);

    /* Initialize h5tools lib */
    h5tools_init();
    parseCommandLine (argc, argv);
    enforce(ubFile!=null, new Exception("missing arguemnt for -u <user_file>.\n"));
    enforce(H5Fis_hdf5(ubFile)<= 0,new Exception("-u <user_file> cannot be HDF5 file, but it appears to be an HDF5 file.\n"));
    enforce(inputFile != null, new Exception("missing argument for -i <HDF5 file>.\n"));
    enforce(H5Fis_hdf5(inputFile)<0, new Exception(format("Input HDF5 file \"%s\" is not HDF5 format.\n", inputFile));
    ifile = H5Fopen (inputFile, H5F_ACC_RDONLY, H5P_DEFAULT);
    enforce(ifile <= 0, new Exception(format("Can't open input HDF5 file \"%s\"\n", inputFile));

    { // new scope for H5F
      scope(exit)
        H5Fclose(ifile);
      plist = H5Fget_create_plist (ifile);
      enforce(plist>=0,new Exception(format("Can't get file creation plist for file \"%s\"\n", inputFile));
      status = H5Pget_userblock (plist, &usize);
      enforce(status >=0,new Exception(format("Can't get user block for file \"%s\"\n", inputFile));

      } // end scope for H5F
      H5Pclose(plist);
    }
    H5Fclose(ifile);

    ufid = HDopen(ubFile, O_RDONLY, 0);
    enforce(ufid >= 0,new Exception(format("unable to open user block file \"%s\"\n", ubFile));
    {
      scope(exit)
        HDclose(ufid);
      res = HDfstat(ufid, &sbuf);
      enforce(res<=0,new Exception(format"Can't stat file \"%s\"\n", ubFile));
      fsize = (off_t)sbuf.st_size;
      h5fid = HDopen(inputFile, O_RDONLY, 0);
      enforce(h5fid >=0,new Exception(format("unable to open HDF5 file for read \"%s\"\n", inputFile));
      scope(exit)
        HDclose(h5fid);
     
      res = HDfstat(h5fid, &sbuf2);
      enforce(res>=0,new Exception(format("Can't stat file \"%s\"\n", inputFile)));
     
      h5fsize = (hsize_t)sbuf2.st_size;

      if (outputFile == null)
      {
        ofid = HDopen (inputFile, O_WRONLY, 0);
        enforce(oid>=0,new Exception(format("unable to open output file \"%s\"\n", outputFile)));
      }
      else
      {
        ofid = HDopen (outputFile, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        enforce(oid>=0,new Exception(format("unable to create output file \"%s\"\n", outputFile)));
      }

      newubsize = computeUserBlockSize ((hsize_t) fsize);
      startub = usize;

      if (usize > 0)
      {
          if (doClobber)
          {
              /* where is max of the current size or the new UB */
              if (usize > newubsize)
                  newubsize = usize;
              startub = 0;    /*blast the old */
          }
          else
          {
              /* add new ub to current ublock, pad to new offset */
              newubsize += usize;
              newubsize = computeUserBlockSize (cast(hsize_t) newubsize);
          }
      }

      /* copy the HDF5 from starting at usize to starting at newubsize:
       *  makes room at 'from' for new ub */
      /* if no current ub, usize is 0 */
      copySomeToFile (h5fid, ofid, usize, newubsize, cast(ssize_t) (h5fsize - usize));

      /* copy the old ub to the beginning of the new file */
      if (!doClobber)
          where = copySomeToFile (h5fid, ofid, (hsize_t) 0, (hsize_t) 0, (ssize_t) usize);

      /* copy the new ub to the end of the ub */
      where = copySomeToFile (ufid, ofid, (hsize_t) 0, startub, (ssize_t) - 1);

      /* pad the ub */
      where = writePad (ofid, where);
  }
  if(ubFile)
      HDfree (ubFile);
  if(inputFile)
      HDfree (inputFile);
  if(outputFile)
      HDfree (outputFile);
  
  if(ufid >= 0)
      HDclose (ufid);
  if(h5fid >= 0)
      HDclose (h5fid);
  if(ofid >= 0)
      HDclose (ofid);

  return h5tools_getstatus();
}

/**
  Function:   copySomeToFile
 
  Purpose:    Copy part of the input file to output.
                infid: fd of file to read
                outfid: fd of file to write
                startin: offset of where to read from infid
                startout: offset of where to write to outfid
                limit: bytes to read/write

              If limit is < 0, the entire input file is copied.

              Note: this routine can be used to copy within
              the same file, i.e., infid and outfid can be the
              same file.
 
  Return:      Success:    last byte written in the output.
               Failure:    Exits program with EXIT_FAILURE value.
 
  Programmer:

  Modifications:
*/
hsize_t copySomeToFile (int infid, int outfid, hsize_t startin, hsize_t startout, ssize_t limit)
{
  char[1024] buf;
  h5_stat_t sbuf;
  int res;
  ssize_t tot = 0;
  ssize_t howMuch = 0;
  ssize_t nchars = -1;
/* used in assertion check
  ssize_t ncw = -1;
*/
  ssize_t to;
  ssize_t from;
  ssize_t toend;
  ssize_t fromend;

  enforce(startin<=startout,new Exception("copySomeToFile: panic: startin > startout?\n"));

  if(limit < 0)
  {
      res = HDfstat(infid, &sbuf);
      enforce(res>= 0, new Exception("Can't stat file \n"));
      howMuch = cast(ssize_t)sbuf.st_size;
  }
  else
      howMuch = limit;

  if(howMuch == 0)
      return 0;

  /* assert (howMuch > 0) */

  toend = cast(ssize_t) startout + howMuch;
  fromend = cast(ssize_t) startin + howMuch;

  if (howMuch > 512)
  {
    to = toend - 512;
    from = fromend - 512;
  }
  else
  {
    to = toend - howMuch;
    from = fromend - howMuch;
  }

  while (howMuch > 0)
  {
    HDlseek (outfid, (off_t) to, SEEK_SET);
    HDlseek (infid, (off_t) from, SEEK_SET);

    if (howMuch > 512)
      nchars = HDread (infid, buf, (unsigned) 512);
    else
      nchars = HDread (infid, buf, (unsigned)howMuch);
  
    enforce(nchars>0,new Exception("huh? \n"));
    /*ncw = */ HDwrite (outfid, buf, (unsigned) nchars);

    debug assert(ncw == nchars);
    tot += nchars;
    howMuch -= nchars;
    if (howMuch > 512)
    {
      to -= nchars;
      from -= nchars;
    }
    else
    {
      to -= howMuch;
      from -= howMuch;
    }
  }

  debug
  {
    assert(howMuch==0);
    assert(tot==limit);
  }
  return ((hsize_t) tot + (hsize_t) startout);
}


/**
  Function:    computeUserBlockSize

  Purpose:     Find the offset of the HDF5 header after the user block:
                 align at 0, 512, 1024, etc.
      ublock_size: the size of the user block (bytes).

  Return:      Success:    the location of the header == the size of the
        padded user block.
              Failure:    none

  Return:      Success:    last byte written in the output.
              Failure:    Exits program with EXIT_FAILURE value.

  Programmer:

  Modifications:
*/

hsize_t computeUserBlockSize (hsize_t ublock_size)
{
  hsize_t where = 512;

  if (ublock_size == 0)
    return 0;

  while (where < ublock_size)
    where *= 2;
  return (where);
}

/**
  Write zeroes to fill the file from 'where' to 512, 1024, etc. bytes.

  Returns the size of the padded file.
*/
hsize_t writePad(int ofile, hsize_t where)
{
    unsigned int i;
    char buf[1];
    hsize_t psize;

    buf[0] = '\0';

    HDlseek(ofile, (off_t) where, SEEK_SET);

    psize = computeUserBlockSize (where);
    psize -= where;

    for(i = 0; i < psize; i++)
        HDwrite (ofile, buf, 1);

    return(where + psize);  /* the new size of the file. */
}

