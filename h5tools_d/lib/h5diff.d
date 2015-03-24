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


/* Send from manager to workers */
enum MPI_TAG_ARGS            =1;
enum MPI_TAG_PRINT_TOK       =2;

/*Sent from workers to manager */
enum MPI_TAG_TOK_REQUEST     =3;
enum MPI_TAG_DONE            =4;
enum MPI_TAG_TOK_RETURN      =5;
enum MPI_TAG_PRINT_DATA      =6;

/* Operational tags used to init and complete diff */
enum MPI_TAG_END             =7;
enum MPI_TAG_PARALLEL        =8;

struct diff_mpi_args
{
    char[256] name1;
    char[256]  name2;
    diff_opt_t  options;
    diff_args_t argdata;  /* rest args */
};

struct diffs_found
{
    hsize_t nfound;
    int      not_cmp;
};

// static if H5_HAVE_PARALLEL
// #include <mpi.h>
/*
 * Purpose:  This file is included by all HDF5 library source files to
 *    define common things which are not defined in the HDF5 API.
 *    The configuration constants like H5_HAVE_UNISTD_H etc. are
 *    defined in H5config.h which is included by H5public.h.
 *
 */


enum F_OK =00;
W_OK=02;
R_OK=04;

/*
 * MPE Instrumentation support
 */
static if H5_HAVE_MPE
{
    /*------------------------------------------------------------------------
     * Purpose:    Begin to collect MPE log information for a function. It should
     *             be ahead of the actual function's process.
     *
     * Programmer: Long Wang
     *
     *------------------------------------------------------------------------
     */
    #include "mpe.h"
    /*
     * enum eventa(func_name)   h5_mpe_ ## func_name ## _a
     * enum eventb(func_name)   h5_mpe_ ## func_name ## _b
     */
    enum eventa(func_name)   h5_mpe_eventa
    enum eventb(func_name)   h5_mpe_eventb
    enum MPE_LOG_VARS                                                    \
        static int h5_mpe_eventa = -1;                                      \
        static int h5_mpe_eventb = -1;                                      \
        static char p_event_start[128];                                     \
        static char p_event_end[128];

    /* Hardwire the color to "red", since that's what all the routines are using
     * now.  In the future, if we want to change that color for a given routine,
     * we should define a "FUNC_ENTER_API_COLOR" macro which takes an extra 'color'
     * parameter and then make additional FUNC_ENTER_<foo>_COLOR macros to get that
     * color information down to the BEGIN_MPE_LOG macro (which should have a new
     * BEGIN_MPE_LOG_COLOR variant). -QAK
     */
    enum BEGIN_MPE_LOG                                                   \
      if(H5_MPEinit_g) {                                                    \
        if(h5_mpe_eventa == -1 && h5_mpe_eventb == -1) {                    \
             const char *p_color = "red";                                   \
                                                                            \
             h5_mpe_eventa = MPE_Log_get_event_number();                    \
             h5_mpe_eventb = MPE_Log_get_event_number();                    \
             HDsnprintf(p_event_start, sizeof(p_event_start) - 1, "start_%s", FUNC); \
             HDsnprintf(p_event_end, sizeof(p_event_end) - 1, "end_%s", FUNC); \
             MPE_Describe_state(h5_mpe_eventa, h5_mpe_eventb, (char *)FUNC, (char *)p_color); \
        }                                                                   \
        MPE_Log_event(h5_mpe_eventa, 0, p_event_start);                     \
      }


    /*------------------------------------------------------------------------
     * Purpose:   Finish the collection of MPE log information for a function.
     *            It should be after the actual function's process.
     *
     * Programmer: Long Wang
     */
    enum FINISH_MPE_LOG                                                  \
        if(H5_MPEinit_g) {                                                  \
            MPE_Log_event(h5_mpe_eventb, 0, p_event_end);                   \
        }

}   else {/* H5_HAVE_MPE */
    enum MPE_LOG_VARS =0;/* void */
    enum BEGIN_MPE_LOG =0;/* void */
    enum FINISH_MPE_LOG =0;  /* void */
} /* H5_HAVE_MPE */


/*
 * Status return values for the `herr_t' type.
 * Since some unix/c routines use 0 and -1 (or more precisely, non-negative
 * vs. negative) as their return code, and some assumption had been made in
 * the code about that, it is important to keep these constants the same
 * values.  When checking the success or failure of an integer-valued
 * function, remember to compare against zero and not one of these two
 * values.
 */
enum SUCCEED    =0;
enum FAIL    =-1;
enum UFAIL    cast(uint)(-1);

/* number of members in an array */
mixin template NELMTS(T)(T X)
{
    X.sizeof/X[0].sizeof;
}

template MIN(T)(T a,T b)
{
    return (((a)<(b)) ? (a) : (b));
}
template MIN2(T)(T a,T b)
{
    return MIN(a,b);
}
template MIN3(T)(T a,T b,T c)
{
    return MIN(a,MIN(b,c));
}

template MIN4(T)(T a,T b,T c,T d)
{
    return MIN(MIN(a,b),MIN(c,d));
}

/* maximum of two, three, or four values */
#undef MAX
enum MAX(a,b)    (((a)>(b)) ? (a) : (b))
enum MAX2(a,b)    MAX(a,b)
enum MAX3(a,b,c)    MAX(a,MAX(b,c))
enum MAX4(a,b,c,d)    MAX(MAX(a,b),MAX(c,d))

/* limit the middle value to be within a range (inclusive) */
enum RANGE(LO,X,HI)    MAX(LO,MIN(X,HI))

/* absolute value */
#ifndef ABS
#   define ABS(a)    (((a)>=0) ? (a) : -(a))
#endif

/* sign of argument */
#ifndef SIGN
#   define SIGN(a)    ((a)>0 ? 1 : (a)<0 ? -1 : 0)
#endif

/* test for number that is a power of 2 */
/* (from: http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2) */
mixin template POWER_OF_TWO(T)(T n)
{
    return(!(n & (n - 1)) && n);
}


/*
 * Numeric data types.  Some of these might be defined in Posix.1g, otherwise
 * we define them with the closest available type which is at least as large
 * as the number of bits indicated in the type name.  The `int8' types *must*
 * be exactly one byte wide because we use it for pointer calculations to
 * void* memory.
 */
#if H5_SIZEOF_INT8_T==0
    typedef signed char int8_t;
#   undef H5_SIZEOF_INT8_T
#   define H5_SIZEOF_INT8_T H5_SIZEOF_CHAR
#elif H5_SIZEOF_INT8_T==1
#else
#   error "the int8_t type must be 1 byte wide"
#endif

#if H5_SIZEOF_UINT8_T==0
    alias uint8_t=ubyte;
#   undef H5_SIZEOF_UINT8_T
#   define H5_SIZEOF_UINT8_T H5_SIZEOF_CHAR
#elif H5_SIZEOF_UINT8_T==1
#else
#   error "the uint8_t type must be 1 byte wide"
#endif

#if H5_SIZEOF_INT16_T>=2
#elif H5_SIZEOF_SHORT>=2
    typedef short int16_t;
#   undef H5_SIZEOF_INT16_T
#   define H5_SIZEOF_INT16_T H5_SIZEOF_SHORT
#elif H5_SIZEOF_INT>=2
    typedef int int16_t;
#   undef H5_SIZEOF_INT16_T
#   define H5_SIZEOF_INT16_T H5_SIZEOF_INT
#else
#   error "nothing appropriate for int16_t"
#endif

#if H5_SIZEOF_UINT16_T>=2
#elif H5_SIZEOF_SHORT>=2
    typedef unsigned short uint16_t;
#   undef H5_SIZEOF_UINT16_T
#   define H5_SIZEOF_UINT16_T H5_SIZEOF_SHORT
#elif H5_SIZEOF_INT>=2
    typedef unsigned uint16_t;
#   undef H5_SIZEOF_UINT16_T
#   define H5_SIZEOF_UINT16_T H5_SIZEOF_INT
#else
#   error "nothing appropriate for uint16_t"
#endif

#if H5_SIZEOF_INT32_T>=4
#elif H5_SIZEOF_SHORT>=4
    typedef short int32_t;
#   undef H5_SIZEOF_INT32_T
#   define H5_SIZEOF_INT32_T H5_SIZEOF_SHORT
#elif H5_SIZEOF_INT>=4
    typedef int int32_t;
#   undef H5_SIZEOF_INT32_T
#   define H5_SIZEOF_INT32_T H5_SIZEOF_INT
#elif H5_SIZEOF_LONG>=4
    typedef long int32_t;
#   undef H5_SIZEOF_INT32_T
#   define H5_SIZEOF_INT32_T H5_SIZEOF_LONG
#else
#   error "nothing appropriate for int32_t"
#endif

/*
 * Maximum and minimum values.  These should be defined in <limits.h> for the
 * most part.
 */
#ifndef LLONG_MAX
#   define LLONG_MAX  ((long long)(((unsigned long long)1          \
              <<(8*sizeof(long long)-1))-1))
#   define LLONG_MIN    ((long long)(-LLONG_MAX)-1)
#endif
#ifndef ULLONG_MAX
#   define ULLONG_MAX  ((unsigned long long)((long long)(-1)))
#endif
#ifndef SIZET_MAX
#   define SIZET_MAX  ((size_t)(ssize_t)(-1))
#   define SSIZET_MAX  ((ssize_t)(((size_t)1<<(8*sizeof(ssize_t)-1))-1))
#endif

/*
 * Maximum & minimum values for our typedefs.
 */
enum HSIZET_MAX   ((hsize_t)ULLONG_MAX)
enum HSSIZET_MAX  ((hssize_t)LLONG_MAX)
enum HSSIZET_MIN  (~(HSSIZET_MAX))

/*
 * Types and max sizes for POSIX I/O.
 * OS X (Darwin) is odd since the max I/O size does not match the types.
 */
#if defined(H5_HAVE_WIN32_API)
#   define h5_posix_io_t                unsigned int
#   define h5_posix_io_ret_t            int
#   define H5_POSIX_MAX_IO_BYTES        INT_MAX
#elif defined(H5_HAVE_DARWIN)
#   define h5_posix_io_t                size_t
#   define h5_posix_io_ret_t            ssize_t
#   define H5_POSIX_MAX_IO_BYTES        INT_MAX
#else
#   define h5_posix_io_t                size_t
#   define h5_posix_io_ret_t            ssize_t
#   define H5_POSIX_MAX_IO_BYTES        SSIZET_MAX
#endif

/*
 * A macro to portably increment enumerated types.
 */
#ifndef H5_INC_ENUM
#  define H5_INC_ENUM(TYPE,VAR) (VAR)=((TYPE)((VAR)+1))
#endif

/*
 * A macro to portably decrement enumerated types.
 */
#ifndef H5_DEC_ENUM
#  define H5_DEC_ENUM(TYPE,VAR) (VAR)=((TYPE)((VAR)-1))
#endif

/*
 * Data types and functions for timing certain parts of the library.
 */
struct H5_timer_t
{
    double  utime;    /*user time      */
    double  stime;    /*system time      */
    double  etime;    /*elapsed wall-clock time  */
}

H5_DLL void H5_timer_reset (H5_timer_t *timer);
H5_DLL void H5_timer_begin (H5_timer_t *timer);
H5_DLL void H5_timer_end (H5_timer_t *sum/*in,out*/,
         H5_timer_t *timer/*in,out*/);
H5_DLL void H5_bandwidth(char *buf/*out*/, double nbytes, double nseconds);
H5_DLL time_t H5_now(void);

/* Depth of object copy */
enum H5_copy_depth_t {
    H5_COPY_SHALLOW,    /* Shallow copy from source to destination, just copy field pointers */
    H5_COPY_DEEP        /* Deep copy from source to destination, including duplicating fields pointed to */
}

/* Common object copying udata (right now only used for groups and datasets) */
struct H5O_copy_file_ud_common_t {
    struct H5O_pline_t *src_pline;      /* Copy of filter pipeline for object */
}

/* Unique object "position" */
struct H5_obj_t
{
    unsigned long fileno;       /* The unique identifier for the file of the object */
    haddr_t addr;               /* The unique address of the object's header in that file */
} 
alias HDabort=abort();
alias HDabs=abs;
(X)    abs(X)
#endif /* HDabs */
#ifndef HDaccess
    enum HDaccess(F,M)    access(F, M)
#endif /* HDaccess */
#ifndef HDacos
    enum HDacos(X)    acos(X)
#endif /* HDacos */
#ifndef HDalarm
    #ifdef H5_HAVE_ALARM
        enum HDalarm(N)              alarm(N)
    #else /* H5_HAVE_ALARM */
        enum HDalarm(N)              (0)
    #endif /* H5_HAVE_ALARM */
#endif /* HDalarm */
#ifndef HDasctime
    enum HDasctime(T)    asctime(T)
#endif /* HDasctime */
#ifndef HDasin
    enum HDasin(X)    asin(X)
#endif /* HDasin */
#ifndef HDasprintf
    enum HDasprintf    asprintf /*varargs*/
#endif /* HDasprintf */
#ifndef HDassert
    enum HDassert(X)    assert(X)
#endif /* HDassert */
#ifndef HDatan
    enum HDatan(X)    atan(X)
#endif /* HDatan */
#ifndef HDatan2
    enum HDatan2(X,Y)    atan2(X,Y)
#endif /* HDatan2 */
#ifndef HDatexit
    enum HDatexit(F)    atexit(F)
#endif /* HDatexit */
#ifndef HDatof
    enum HDatof(S)    atof(S)
#endif /* HDatof */
#ifndef HDatoi
    enum HDatoi(S)    atoi(S)
#endif /* HDatoi */
#ifndef HDatol
    enum HDatol(S)    atol(S)
#endif /* HDatol */
#ifndef HDBSDgettimeofday
    enum HDBSDgettimeofday(S,P)  BSDgettimeofday(S,P)
#endif /* HDBSDgettimeofday */
#ifndef HDbsearch
    enum HDbsearch(K,B,N,Z,F)  bsearch(K,B,N,Z,F)
#endif /* HDbsearch */
#ifndef HDcalloc
    enum HDcalloc(N,Z)    calloc(N,Z)
#endif /* HDcalloc */
#ifndef HDceil
    enum HDceil(X)    ceil(X)
#endif /* HDceil */
#ifndef HDcfgetispeed
    enum HDcfgetispeed(T)  cfgetispeed(T)
#endif /* HDcfgetispeed */
#ifndef HDcfgetospeed
    enum HDcfgetospeed(T)  cfgetospeed(T)
#endif /* HDcfgetospeed */
#ifndef HDcfsetispeed
    enum HDcfsetispeed(T,S)  cfsetispeed(T,S)
#endif /* HDcfsetispeed */
#ifndef HDcfsetospeed
    enum HDcfsetospeed(T,S)  cfsetospeed(T,S)
#endif /* HDcfsetospeed */
#ifndef HDchdir
    enum HDchdir(S)    chdir(S)
#endif /* HDchdir */
#ifndef HDchmod
    enum HDchmod(S,M)    chmod(S,M)
#endif /* HDchmod */
#ifndef HDchown
    enum HDchown(S,O,G)    chown(S,O,G)
#endif /* HDchown */
#ifndef HDclearerr
    enum HDclearerr(F)    clearerr(F)
#endif /* HDclearerr */
#ifndef HDclock
    enum HDclock()    clock()
#endif /* HDclock */
#ifndef HDclose
    enum HDclose(F)    close(F)
#endif /* HDclose */
#ifndef HDclosedir
    enum HDclosedir(D)    closedir(D)
#endif /* HDclosedir */
#ifndef HDcos
    enum HDcos(X)    cos(X)
#endif /* HDcos */
#ifndef HDcosh
    enum HDcosh(X)    cosh(X)
#endif /* HDcosh */
#ifndef HDcreat
    enum HDcreat(S,M)    creat(S,M)
#endif /* HDcreat */
#ifndef HDctermid
    enum HDctermid(S)    ctermid(S)
#endif /* HDctermid */
#ifndef HDctime
    enum HDctime(T)    ctime(T)
#endif /* HDctime */
#ifndef HDcuserid
    enum HDcuserid(S)    cuserid(S)
#endif /* HDcuserid */
#ifndef HDdifftime
    #ifdef H5_HAVE_DIFFTIME
        enum HDdifftime(X,Y)    difftime(X,Y)
    #else /* H5_HAVE_DIFFTIME */
        enum HDdifftime(X,Y)    ((double)(X)-(double)(Y))
    #endif /* H5_HAVE_DIFFTIME */
#endif /* HDdifftime */
#ifndef HDdiv
    enum HDdiv(X,Y)    div(X,Y)
#endif /* HDdiv */
#ifndef HDdup
    enum HDdup(F)    dup(F)
#endif /* HDdup */
#ifndef HDdup2
    enum HDdup2(F,I)    dup2(F,I)
#endif /* HDdup2 */
/* execl() variable arguments */
/* execle() variable arguments */
/* execlp() variable arguments */
#ifndef HDexecv
    enum HDexecv(S,AV)    execv(S,AV)
#endif /* HDexecv */
#ifndef HDexecve
    enum HDexecve(S,AV,E)  execve(S,AV,E)
#endif /* HDexecve */
#ifndef HDexecvp
    enum HDexecvp(S,AV)    execvp(S,AV)
#endif /* HDexecvp */
#ifndef HDexit
    enum HDexit(N)    exit(N)
#endif /* HDexit */
#ifndef HD_exit
    enum HD_exit(N)    _exit(N)
#endif /* HD_exit */
#ifndef HDexp
    enum HDexp(X)    exp(X)
#endif /* HDexp */
#ifndef HDfabs
    enum HDfabs(X)    fabs(X)
#endif /* HDfabs */
/* use ABS() because fabsf() fabsl() are not common yet. */
#ifndef HDfabsf
    enum HDfabsf(X)    ABS(X)
#endif /* HDfabsf */
#ifndef HDfabsl
    enum HDfabsl(X)    ABS(X)
#endif /* HDfabsl */
#ifndef HDfclose
    enum HDfclose(F)    fclose(F)
#endif /* HDfclose */
/* fcntl() variable arguments */
#ifndef HDfdopen
    enum HDfdopen(N,S)    fdopen(N,S)
#endif /* HDfdopen */
#ifndef HDfeof
    enum HDfeof(F)    feof(F)
#endif /* HDfeof */
#ifndef HDferror
    enum HDferror(F)    ferror(F)
#endif /* HDferror */
#ifndef HDfflush
    enum HDfflush(F)    fflush(F)
#endif /* HDfflush */
#ifndef HDfgetc
    enum HDfgetc(F)    fgetc(F)
#endif /* HDfgetc */
#ifndef HDfgetpos
    enum HDfgetpos(F,P)    fgetpos(F,P)
#endif /* HDfgetpos */
#ifndef HDfgets
    enum HDfgets(S,N,F)    fgets(S,N,F)
#endif /* HDfgets */
#ifndef HDfileno
    enum HDfileno(F)    fileno(F)
#endif /* HDfileno */
#ifndef HDfloor
    enum HDfloor(X)    floor(X)
#endif /* HDfloor */
#ifndef HDfmod
    enum HDfmod(X,Y)    fmod(X,Y)
#endif /* HDfmod */
#ifndef HDfopen
    enum HDfopen(S,M)    fopen(S,M)
#endif /* HDfopen */
#ifndef HDfork
    enum HDfork()    fork()
#endif /* HDfork */
#ifndef HDfpathconf
    enum HDfpathconf(F,N)  fpathconf(F,N)
#endif /* HDfpathconf */
H5_DLL int HDfprintf (FILE *stream, const char *fmt, ...);
#ifndef HDfputc
    enum HDfputc(C,F)    fputc(C,F)
#endif /* HDfputc */
#ifndef HDfputs
    enum HDfputs(S,F)    fputs(S,F)
#endif /* HDfputs */
#ifndef HDfread
    enum HDfread(M,Z,N,F)  fread(M,Z,N,F)
#endif /* HDfread */
#ifndef HDfree
    enum HDfree(M)    free(M)
#endif /* HDfree */
#ifndef HDfreopen
    enum HDfreopen(S,M,F)  freopen(S,M,F)
#endif /* HDfreopen */
#ifndef HDfrexp
    enum HDfrexp(X,N)    frexp(X,N)
#endif /* HDfrexp */
/* Check for Cray-specific 'frexpf()' and 'frexpl()' routines */
#ifndef HDfrexpf
    #ifdef H5_HAVE_FREXPF
        enum HDfrexpf(X,N)    frexpf(X,N)
    #else /* H5_HAVE_FREXPF */
        enum HDfrexpf(X,N)    frexp(X,N)
    #endif /* H5_HAVE_FREXPF */
#endif /* HDfrexpf */
#ifndef HDfrexpl
    #ifdef H5_HAVE_FREXPL
        enum HDfrexpl(X,N)    frexpl(X,N)
    #else /* H5_HAVE_FREXPL */
        enum HDfrexpl(X,N)    frexp(X,N)
    #endif /* H5_HAVE_FREXPL */
#endif /* HDfrexpl */
/* fscanf() variable arguments */
#ifndef HDfseek
    #ifdef H5_HAVE_FSEEKO
             enum HDfseek(F,O,W)  fseeko(F,O,W)
    #else /* H5_HAVE_FSEEKO */
             enum HDfseek(F,O,W)  fseek(F,O,W)
    #endif /* H5_HAVE_FSEEKO */
#endif /* HDfseek */
#ifndef HDfsetpos
    enum HDfsetpos(F,P)    fsetpos(F,P)
#endif /* HDfsetpos */
/* definitions related to the file stat utilities.
 * For Unix, if off_t is not 64bit big, try use the pseudo-standard
 * xxx64 versions if available.
 */
#if !defined(HDfstat) || !defined(HDstat) || !defined(HDlstat)
    #if H5_SIZEOF_OFF_T!=8 && H5_SIZEOF_OFF64_T==8 && defined(H5_HAVE_STAT64)
        #ifndef HDfstat
            enum HDfstat(F,B)        fstat64(F,B)
        #endif /* HDfstat */
        #ifndef HDlstat
            enum HDlstat(S,B)    lstat64(S,B)
        #endif /* HDlstat */
        #ifndef HDstat
            enum HDstat(S,B)    stat64(S,B)
        #endif /* HDstat */
        typedef struct stat64       h5_stat_t;
        typedef off64_t             h5_stat_size_t;
        enum H5_SIZEOF_H5_STAT_SIZE_T H5_SIZEOF_OFF64_T
    #else /* H5_SIZEOF_OFF_T!=8 && ... */
        #ifndef HDfstat
            enum HDfstat(F,B)        fstat(F,B)
        #endif /* HDfstat */
        #ifndef HDlstat
            enum HDlstat(S,B)    lstat(S,B)
        #endif /* HDlstat */
        #ifndef HDstat
            enum HDstat(S,B)    stat(S,B)
        #endif /* HDstat */
        typedef struct stat         h5_stat_t;
        typedef off_t               h5_stat_size_t;
        enum H5_SIZEOF_H5_STAT_SIZE_T H5_SIZEOF_OFF_T
    #endif /* H5_SIZEOF_OFF_T!=8 && ... */
#endif /* !defined(HDfstat) || !defined(HDstat) */

#ifndef HDftell
    enum HDftell(F)    ftell(F)
#endif /* HDftell */
#ifndef HDftruncate
  #ifdef H5_HAVE_FTRUNCATE64
    enum HDftruncate(F,L)        ftruncate64(F,L)
  #else
    enum HDftruncate(F,L)        ftruncate(F,L)
  #endif
#endif /* HDftruncate */
#ifndef HDfwrite
    enum HDfwrite(M,Z,N,F)  fwrite(M,Z,N,F)
#endif /* HDfwrite */
#ifndef HDgetc
    enum HDgetc(F)    getc(F)
#endif /* HDgetc */
#ifndef HDgetchar
    enum HDgetchar()    getchar()
#endif /* HDgetchar */
#ifndef HDgetcwd
    enum HDgetcwd(S,Z)    getcwd(S,Z)
#endif /* HDgetcwd */
#ifndef HDgetdcwd
    enum HDgetdcwd(D,S,Z)  getcwd(S,Z)
#endif /* HDgetdcwd */
#ifndef HDgetdrive
    enum HDgetdrive()    0
#endif /* HDgetdrive */
#ifndef HDgetegid
    enum HDgetegid()    getegid()
#endif /* HDgetegid() */
#ifndef HDgetenv
    enum HDgetenv(S)    getenv(S)
#endif /* HDgetenv */
#ifndef HDgeteuid
    enum HDgeteuid()    geteuid()
#endif /* HDgeteuid */
#ifndef HDgetgid
    enum HDgetgid()    getgid()
#endif /* HDgetgid */
#ifndef HDgetgrgid
    enum HDgetgrgid(G)    getgrgid(G)
#endif /* HDgetgrgid */
#ifndef HDgetgrnam
    enum HDgetgrnam(S)    getgrnam(S)
#endif /* HDgetgrnam */
#ifndef HDgetgroups
    enum HDgetgroups(Z,G)  getgroups(Z,G)
#endif /* HDgetgroups */
#ifndef HDgethostname
    enum HDgethostname(N,L)    gethostname(N,L)
#endif /* HDgetlogin */
#ifndef HDgetlogin
    enum HDgetlogin()    getlogin()
#endif /* HDgetlogin */
#ifndef HDgetpgrp
    enum HDgetpgrp()    getpgrp()
#endif /* HDgetpgrp */
#ifndef HDgetpid
    enum HDgetpid()    getpid()
#endif /* HDgetpid */
#ifndef HDgetppid
    enum HDgetppid()    getppid()
#endif /* HDgetppid */
#ifndef HDgetpwnam
    enum HDgetpwnam(S)    getpwnam(S)
#endif /* HDgetpwnam */
#ifndef HDgetpwuid
    enum HDgetpwuid(U)    getpwuid(U)
#endif /* HDgetpwuid */
#ifndef HDgetrusage
    enum HDgetrusage(X,S)  getrusage(X,S)
#endif /* HDgetrusage */
#ifndef HDgets
    enum HDgets(S)    gets(S)
#endif /* HDgets */
#ifndef HDgettimeofday
    enum HDgettimeofday(S,P)  gettimeofday(S,P)
#endif /* HDgettimeofday */
#ifndef HDgetuid
    enum HDgetuid()    getuid()
#endif /* HDgetuid */
#ifndef HDgmtime
    enum HDgmtime(T)    gmtime(T)
#endif /* HDgmtime */
#ifndef HDisalnum
    enum HDisalnum(C)    isalnum((int)(C)) /*cast for solaris warning*/
#endif /* HDisalnum */
#ifndef HDisalpha
    enum HDisalpha(C)    isalpha((int)(C)) /*cast for solaris warning*/
#endif /* HDisalpha */
#ifndef HDisatty
    enum HDisatty(F)    isatty(F)
#endif /* HDisatty */
#ifndef HDiscntrl
    enum HDiscntrl(C)    iscntrl((int)(C)) /*cast for solaris warning*/
#endif /* HDiscntrl */
#ifndef HDisdigit
    enum HDisdigit(C)    isdigit((int)(C)) /*cast for solaris warning*/
#endif /* HDisdigit */
#ifndef HDisgraph
    enum HDisgraph(C)    isgraph((int)(C)) /*cast for solaris warning*/
#endif /* HDisgraph */
#ifndef HDislower
    enum HDislower(C)    islower((int)(C)) /*cast for solaris warning*/
#endif /* HDislower */
#ifndef HDisprint
    enum HDisprint(C)    isprint((int)(C)) /*cast for solaris warning*/
#endif /* HDisprint */
#ifndef HDispunct
    enum HDispunct(C)    ispunct((int)(C)) /*cast for solaris warning*/
#endif /* HDispunct */
#ifndef HDisspace
    enum HDisspace(C)    isspace((int)(C)) /*cast for solaris warning*/
#endif /* HDisspace */
#ifndef HDisupper
    enum HDisupper(C)    isupper((int)(C)) /*cast for solaris warning*/
#endif /* HDisupper */
#ifndef HDisxdigit
    enum HDisxdigit(C)    isxdigit((int)(C)) /*cast for solaris warning*/
#endif /* HDisxdigit */
#ifndef HDkill
    enum HDkill(P,S)    kill(P,S)
#endif /* HDkill */
#ifndef HDlabs
    enum HDlabs(X)    labs(X)
#endif /* HDlabs */
#ifndef HDldexp
    enum HDldexp(X,N)    ldexp(X,N)
#endif /* HDldexp */
#ifndef HDldiv
    enum HDldiv(X,Y)    ldiv(X,Y)
#endif /* HDldiv */
#ifndef HDlink
    enum HDlink(OLD,NEW)    link(OLD,NEW)
#endif /* HDlink */
#ifndef HDlocaleconv
    enum HDlocaleconv()    localeconv()
#endif /* HDlocaleconv */
#ifndef HDlocaltime
    enum HDlocaltime(T)    localtime(T)
#endif /* HDlocaltime */
#ifndef HDlog
    enum HDlog(X)    log(X)
#endif /* HDlog */
#ifndef HDlog10
    enum HDlog10(X)    log10(X)
#endif /* HDlog10 */
#ifndef HDlongjmp
    enum HDlongjmp(J,N)    longjmp(J,N)
#endif /* HDlongjmp */
/* HDlseek and HDoff_t must be defined together for consistency. */
#ifndef HDlseek
    #ifdef H5_HAVE_LSEEK64
        enum HDlseek(F,O,W)  lseek64(F,O,W)
        enum HDoff_t    off64_t
    #else
        enum HDlseek(F,O,W)  lseek(F,O,W)
  enum HDoff_t    off_t
    #endif
#endif /* HDlseek */
#ifndef HDmalloc
    enum HDmalloc(Z)    malloc(Z)
#endif /* HDmalloc */
#ifndef HDposix_memalign
    enum HDposix_memalign(P,A,Z) posix_memalign(P,A,Z)
#endif /* HDposix_memalign */
#ifndef HDmblen
    enum HDmblen(S,N)    mblen(S,N)
#endif /* HDmblen */
#ifndef HDmbstowcs
    enum HDmbstowcs(P,S,Z)  mbstowcs(P,S,Z)
#endif /* HDmbstowcs */
#ifndef HDmbtowc
    enum HDmbtowc(P,S,Z)    mbtowc(P,S,Z)
#endif /* HDmbtowc */
#ifndef HDmemchr
    enum HDmemchr(S,C,Z)    memchr(S,C,Z)
#endif /* HDmemchr */
#ifndef HDmemcmp
    enum HDmemcmp(X,Y,Z)    memcmp(X,Y,Z)
#endif /* HDmemcmp */
/*
 * The (char*) casts are required for the DEC when optimizations are turned
 * on and the source and/or destination are not aligned.
 */
#ifndef HDmemcpy
    enum HDmemcpy(X,Y,Z)    memcpy((char*)(X),(const char*)(Y),Z)
#endif /* HDmemcpy */
#ifndef HDmemmove
    enum HDmemmove(X,Y,Z)  memmove((char*)(X),(const char*)(Y),Z)
#endif /* HDmemmove */
#ifndef HDmemset
    enum HDmemset(X,C,Z)    memset(X,C,Z)
#endif /* HDmemset */
#ifndef HDmkdir
    enum HDmkdir(S,M)    mkdir(S,M)
#endif /* HDmkdir */
#ifndef HDmkfifo
    enum HDmkfifo(S,M)    mkfifo(S,M)
#endif /* HDmkfifo */
#ifndef HDmktime
    enum HDmktime(T)    mktime(T)
#endif /* HDmktime */
#ifndef HDmodf
    enum HDmodf(X,Y)    modf(X,Y)
#endif /* HDmodf */
#ifndef HDopen
    #ifdef _O_BINARY
        enum HDopen(S,F,M)    open(S,F|_O_BINARY,M)
    #else
        enum HDopen(S,F,M)    open(S,F,M)
    #endif
#endif /* HDopen */
#ifndef HDopendir
    enum HDopendir(S)    opendir(S)
#endif /* HDopendir */
#ifndef HDpathconf
    enum HDpathconf(S,N)    pathconf(S,N)
#endif /* HDpathconf */
#ifndef HDpause
    enum HDpause()    pause()
#endif /* HDpause */
#ifndef HDperror
    enum HDperror(S)    perror(S)
#endif /* HDperror */
#ifndef HDpipe
    enum HDpipe(F)    pipe(F)
#endif /* HDpipe */
#ifndef HDpow
    enum HDpow(X,Y)    pow(X,Y)
#endif /* HDpow */
/* printf() variable arguments */
#ifndef HDputc
    enum HDputc(C,F)    putc(C,F)
#endif /* HDputc*/
#ifndef HDputchar
    enum HDputchar(C)    putchar(C)
#endif /* HDputchar */
#ifndef HDputs
    enum HDputs(S)    puts(S)
#endif /* HDputs */
#ifndef HDqsort
    enum HDqsort(M,N,Z,F)  qsort(M,N,Z,F)
#endif /* HDqsort*/
#ifndef HDraise
    enum HDraise(N)    raise(N)
#endif /* HDraise */

#ifdef H5_HAVE_RAND_R
    #ifndef HDrandom
        enum HDrandom()    HDrand()
    #endif /* HDrandom */
    H5_DLL int HDrand(void);
#elif H5_HAVE_RANDOM
    #ifndef HDrand
        enum HDrand()    random()
    #endif /* HDrand */
    #ifndef HDrandom
        enum HDrandom()    random()
    #endif /* HDrandom */
#else /* H5_HAVE_RANDOM */
    #ifndef HDrand
        enum HDrand()    rand()
    #endif /* HDrand */
    #ifndef HDrandom
        enum HDrandom()    rand()
    #endif /* HDrandom */
#endif /* H5_HAVE_RANDOM */

#ifndef HDread
    enum HDread(F,M,Z)    read(F,M,Z)
#endif /* HDread */
#ifndef HDreaddir
    enum HDreaddir(D)    readdir(D)
#endif /* HDreaddir */
#ifndef HDrealloc
    enum HDrealloc(M,Z)    realloc(M,Z)
#endif /* HDrealloc */
#ifndef HDrealpath
    enum HDrealpath(F1,F2)    realpath(F1,F2)
#endif /* HDrealloc */
#ifdef H5_VMS
    #ifdef __cplusplus
        extern "C" {
    #endif /* __cplusplus */
    int HDremove_all(const char * fname);
    #ifdef __cplusplus
        }
    #endif /* __cplusplus */
    #ifndef HDremove
        enum HDremove(S)     HDremove_all(S)
    #endif /* HDremove */
#else /* H5_VMS */
    #ifndef HDremove
        enum HDremove(S)    remove(S)
    #endif /* HDremove */
#endif /*H5_VMS*/
#ifndef HDrename
    enum HDrename(OLD,NEW)  rename(OLD,NEW)
#endif /* HDrename */
#ifndef HDrewind
    enum HDrewind(F)    rewind(F)
#endif /* HDrewind */
#ifndef HDrewinddir
    enum HDrewinddir(D)    rewinddir(D)
#endif /* HDrewinddir */
#ifndef HDrmdir
    enum HDrmdir(S)    rmdir(S)
#endif /* HDrmdir */
/* scanf() variable arguments */
#ifndef HDsetbuf
    enum HDsetbuf(F,S)    setbuf(F,S)
#endif /* HDsetbuf */
#ifndef HDsetgid
    enum HDsetgid(G)    setgid(G)
#endif /* HDsetgid */
#ifndef HDsetjmp
    enum HDsetjmp(J)    setjmp(J)
#endif /* HDsetjmp */
#ifndef HDsetlocale
    enum HDsetlocale(N,S)  setlocale(N,S)
#endif /* HDsetlocale */
#ifndef HDsetpgid
    enum HDsetpgid(P,PG)    setpgid(P,PG)
#endif /* HDsetpgid */
#ifndef HDsetsid
    enum HDsetsid()    setsid()
#endif /* HDsetsid */
#ifndef HDsetuid
    enum HDsetuid(U)    setuid(U)
#endif /* HDsetuid */
#ifndef HDsetvbuf
    enum HDsetvbuf(F,S,M,Z)  setvbuf(F,S,M,Z)
#endif /* HDsetvbuf */
#ifndef HDsigaddset
    enum HDsigaddset(S,N)  sigaddset(S,N)
#endif /* HDsigaddset */
#ifndef HDsigdelset
    enum HDsigdelset(S,N)  sigdelset(S,N)
#endif /* HDsigdelset */
#ifndef HDsigemptyset
    enum HDsigemptyset(S)  sigemptyset(S)
#endif /* HDsigemptyset */
#ifndef HDsigfillset
    enum HDsigfillset(S)    sigfillset(S)
#endif /* HDsigfillset */
#ifndef HDsigismember
    enum HDsigismember(S,N)  sigismember(S,N)
#endif /* HDsigismember */
#ifndef HDsiglongjmp
    enum HDsiglongjmp(J,N)  siglongjmp(J,N)
#endif /* HDsiglongjmp */
#ifndef HDsignal
    enum HDsignal(N,F)    signal(N,F)
#endif /* HDsignal */
#ifndef HDsigpending
    enum HDsigpending(S)    sigpending(S)
#endif /* HDsigpending */
#ifndef HDsigprocmask
    enum HDsigprocmask(H,S,O)  sigprocmask(H,S,O)
#endif /* HDsigprocmask */
#ifndef HDsigsetjmp
    enum HDsigsetjmp(J,N)  sigsetjmp(J,N)
#endif /* HDsigsetjmp */
#ifndef HDsigsuspend
    enum HDsigsuspend(S)    sigsuspend(S)
#endif /* HDsigsuspend */
#ifndef HDsin
    enum HDsin(X)    sin(X)
#endif /* HDsin */
#ifndef HDsinh
    enum HDsinh(X)    sinh(X)
#endif /* HDsinh */
#ifndef HDsleep
    enum HDsleep(N)    sleep(N)
#endif /* HDsleep */
#ifndef HDsnprintf
    enum HDsnprintf    snprintf /*varargs*/
#endif /* HDsnprintf */
/* sprintf() variable arguments */
#ifndef HDsqrt
    enum HDsqrt(X)    sqrt(X)
#endif /* HDsqrt */
#ifdef H5_HAVE_RAND_R
    H5_DLL void HDsrand(unsigned int seed);
    #ifndef HDsrandom
        enum HDsrandom(S)    HDsrand(S)
    #endif /* HDsrandom */
#elif H5_HAVE_RANDOM
    #ifndef HDsrand
        enum HDsrand(S)    srandom(S)
    #endif /* HDsrand */
    #ifndef HDsrandom
        enum HDsrandom(S)    srandom(S)
    #endif /* HDsrandom */
#else /* H5_HAVE_RAND_R */
    #ifndef HDsrand
        enum HDsrand(S)    srand(S)
    #endif /* HDsrand */
    #ifndef HDsrandom
        enum HDsrandom(S)    srand(S)
    #endif /* HDsrandom */
#endif /* H5_HAVE_RAND_R */
/* sscanf() variable arguments */

#ifndef HDstrcat
    enum HDstrcat(X,Y)    strcat(X,Y)
#endif /* HDstrcat */
#ifndef HDstrchr
    enum HDstrchr(S,C)    strchr(S,C)
#endif /* HDstrchr */
#ifndef HDstrcmp
    enum HDstrcmp(X,Y)    strcmp(X,Y)
#endif /* HDstrcmp */
#ifndef HDstrcasecmp
    enum HDstrcasecmp(X,Y)       strcasecmp(X,Y)
#endif /* HDstrcasecmp */
#ifndef HDstrcoll
    enum HDstrcoll(X,Y)    strcoll(X,Y)
#endif /* HDstrcoll */
#ifndef HDstrcpy
    enum HDstrcpy(X,Y)    strcpy(X,Y)
#endif /* HDstrcpy */
#ifndef HDstrcspn
    enum HDstrcspn(X,Y)    strcspn(X,Y)
#endif /* HDstrcspn */
#ifndef HDstrerror
    enum HDstrerror(N)    strerror(N)
#endif /* HDstrerror */
#ifndef HDstrftime
    enum HDstrftime(S,Z,F,T)  strftime(S,Z,F,T)
#endif /* HDstrftime */
#ifndef HDstrlen
    enum HDstrlen(S)    strlen(S)
#endif /* HDstrlen */
#ifndef HDstrncat
    enum HDstrncat(X,Y,Z)  strncat(X,Y,Z)
#endif /* HDstrncat */
#ifndef HDstrncmp
    enum HDstrncmp(X,Y,Z)  strncmp(X,Y,Z)
#endif /* HDstrncmp */
#ifndef HDstrncpy
    enum HDstrncpy(X,Y,Z)  strncpy(X,Y,Z)
#endif /* HDstrncpy */
#ifndef HDstrpbrk
    enum HDstrpbrk(X,Y)    strpbrk(X,Y)
#endif /* HDstrpbrk */
#ifndef HDstrrchr
    enum HDstrrchr(S,C)    strrchr(S,C)
#endif /* HDstrrchr */
#ifndef HDstrspn
    enum HDstrspn(X,Y)    strspn(X,Y)
#endif /* HDstrspn */
#ifndef HDstrstr
    enum HDstrstr(X,Y)    strstr(X,Y)
#endif /* HDstrstr */
#ifndef HDstrtod
    enum HDstrtod(S,R)    strtod(S,R)
#endif /* HDstrtod */
#ifndef HDstrtok
    enum HDstrtok(X,Y)    strtok(X,Y)
#endif /* HDstrtok */
#ifndef HDstrtol
    enum HDstrtol(S,R,N)    strtol(S,R,N)
#endif /* HDstrtol */
H5_DLL int64_t HDstrtoll (const char *s, const char **rest, int base);
#ifndef HDstrtoul
    enum HDstrtoul(S,R,N)  strtoul(S,R,N)
#endif /* HDstrtoul */
#ifndef HDstrtoull
    enum HDstrtoull(S,R,N)  strtoull(S,R,N)
#endif /* HDstrtoul */
#ifndef HDstrxfrm
    enum HDstrxfrm(X,Y,Z)  strxfrm(X,Y,Z)
#endif /* HDstrxfrm */
#ifdef H5_HAVE_SYMLINK
    #ifndef HDsymlink
        enum HDsymlink(F1,F2)  symlink(F1,F2)
    #endif /* HDsymlink */
#endif /* H5_HAVE_SYMLINK */
#ifndef HDsysconf
    enum HDsysconf(N)    sysconf(N)
#endif /* HDsysconf */
#ifndef HDsystem
    enum HDsystem(S)    system(S)
#endif /* HDsystem */
#ifndef HDtan
    enum HDtan(X)    tan(X)
#endif /* HDtan */
#ifndef HDtanh
    enum HDtanh(X)    tanh(X)
#endif /* HDtanh */
#ifndef HDtcdrain
    enum HDtcdrain(F)    tcdrain(F)
#endif /* HDtcdrain */
#ifndef HDtcflow
    enum HDtcflow(F,A)    tcflow(F,A)
#endif /* HDtcflow */
#ifndef HDtcflush
    enum HDtcflush(F,N)    tcflush(F,N)
#endif /* HDtcflush */
#ifndef HDtcgetattr
    enum HDtcgetattr(F,T)  tcgetattr(F,T)
#endif /* HDtcgetattr */
#ifndef HDtcgetpgrp
    enum HDtcgetpgrp(F)    tcgetpgrp(F)
#endif /* HDtcgetpgrp */
#ifndef HDtcsendbreak
    enum HDtcsendbreak(F,N)  tcsendbreak(F,N)
#endif /* HDtcsendbreak */
#ifndef HDtcsetattr
    enum HDtcsetattr(F,O,T)  tcsetattr(F,O,T)
#endif /* HDtcsetattr */
#ifndef HDtcsetpgrp
    enum HDtcsetpgrp(F,N)  tcsetpgrp(F,N)
#endif /* HDtcsetpgrp */
#ifndef HDtime
    enum HDtime(T)    time(T)
#endif /* HDtime */
#ifndef HDtimes
    enum HDtimes(T)    times(T)
#endif /* HDtimes*/
#ifndef HDtmpfile
    enum HDtmpfile()    tmpfile()
#endif /* HDtmpfile */
#ifndef HDtmpnam
    enum HDtmpnam(S)    tmpnam(S)
#endif /* HDtmpnam */
#ifndef HDtolower
    enum HDtolower(C)    tolower(C)
#endif /* HDtolower */
#ifndef HDtoupper
    enum HDtoupper(C)    toupper(C)
#endif /* HDtoupper */
#ifndef HDttyname
    enum HDttyname(F)    ttyname(F)
#endif /* HDttyname */
#ifndef HDtzset
    enum HDtzset()    tzset()
#endif /* HDtzset */
#ifndef HDumask
    enum HDumask(N)    umask(N)
#endif /* HDumask */
#ifndef HDuname
    enum HDuname(S)    uname(S)
#endif /* HDuname */
#ifndef HDungetc
    enum HDungetc(C,F)    ungetc(C,F)
#endif /* HDungetc */
#ifndef HDunlink
    enum HDunlink(S)    unlink(S)
#endif /* HDunlink */
#ifndef HDutime
    enum HDutime(S,T)    utime(S,T)
#endif /* HDutime */
#ifndef HDva_arg
    enum HDva_arg(A,T)    va_arg(A,T)
#endif /* HDva_arg */
#ifndef HDva_end
    enum HDva_end(A)    va_end(A)
#endif /* HDva_end */
#ifndef HDva_start
    enum HDva_start(A,P)    va_start(A,P)
#endif /* HDva_start */
#ifndef HDvasprintf
    enum HDvasprintf(RET,FMT,A)  vasprintf(RET,FMT,A)
#endif /* HDvasprintf */
#ifndef HDvfprintf
    enum HDvfprintf(F,FMT,A)  vfprintf(F,FMT,A)
#endif /* HDvfprintf */
#ifndef HDvprintf
    enum HDvprintf(FMT,A)  vprintf(FMT,A)
#endif /* HDvprintf */
#ifndef HDvsprintf
    enum HDvsprintf(S,FMT,A)  vsprintf(S,FMT,A)
#endif /* HDvsprintf */
#ifndef HDvsnprintf
    enum HDvsnprintf(S,N,FMT,A) vsnprintf(S,N,FMT,A)
#endif /* HDvsnprintf */
#ifndef HDwait
    enum HDwait(W)    wait(W)
#endif /* HDwait */
#ifndef HDwaitpid
    enum HDwaitpid(P,W,O)  waitpid(P,W,O)
#endif /* HDwaitpid */
#ifndef HDwcstombs
    enum HDwcstombs(S,P,Z)  wcstombs(S,P,Z)
#endif /* HDwcstombs */
#ifndef HDwctomb
    enum HDwctomb(S,C)    wctomb(S,C)
#endif /* HDwctomb */
#ifndef HDwrite
    enum HDwrite(F,M,Z)    write(F,M,Z)
#endif /* HDwrite */

/*
 * And now for a couple non-Posix functions...  Watch out for systems that
 * define these in terms of macros.
 */
#if !defined strdup && !defined H5_HAVE_STRDUP
extern char *strdup(const char *s);
#endif

#ifndef HDstrdup
    enum HDstrdup(S)     strdup(S)
#endif /* HDstrdup */

#ifndef HDpthread_self
    enum HDpthread_self()    pthread_self()
#endif /* HDpthread_self */

/* Use this version of pthread_self for printing the thread ID */
#ifndef HDpthread_self_ulong
    enum HDpthread_self_ulong()    ((unsigned long)pthread_self())
#endif /* HDpthread_self_ulong */

/*
 * A macro for detecting over/under-flow when casting between types
 */
#ifndef NDEBUG
enum H5_CHECK_OVERFLOW(var, vartype, casttype) \
{                                                 \
    casttype _tmp_overflow = (casttype)(var);     \
    assert((var) == (vartype)_tmp_overflow);      \
}
#else /* NDEBUG */
enum H5_CHECK_OVERFLOW(var, vartype, casttype)
#endif /* NDEBUG */

/*
 * A macro for detecting over/under-flow when assigning between types
 */
#ifndef NDEBUG
enum ASSIGN_TO_SMALLER_SIZE(dst, dsttype, src, srctype)       \
{                                                       \
    srctype _tmp_src = (srctype)(src);  \
    dsttype _tmp_dst = (dsttype)(_tmp_src);  \
    assert(_tmp_src == (srctype)_tmp_dst);   \
    (dst) = _tmp_dst;                             \
}

enum ASSIGN_TO_LARGER_SIZE_SAME_SIGNED(dst, dsttype, src, srctype)       \
    (dst) = (dsttype)(src);

enum ASSIGN_TO_LARGER_SIZE_SIGNED_TO_UNSIGNED(dst, dsttype, src, srctype)       \
{                                                       \
    srctype _tmp_src = (srctype)(src);  \
    dsttype _tmp_dst = (dsttype)(_tmp_src);  \
    assert(_tmp_src >= 0);   \
    assert(_tmp_src == _tmp_dst);   \
    (dst) = _tmp_dst;                             \
}

enum ASSIGN_TO_LARGER_SIZE_UNSIGNED_TO_SIGNED(dst, dsttype, src, srctype)       \
    (dst) = (dsttype)(src);

enum ASSIGN_TO_SAME_SIZE_UNSIGNED_TO_SIGNED(dst, dsttype, src, srctype)       \
{                                                       \
    srctype _tmp_src = (srctype)(src);  \
    dsttype _tmp_dst = (dsttype)(_tmp_src);  \
    assert(_tmp_dst >= 0);   \
    assert(_tmp_src == (srctype)_tmp_dst);   \
    (dst) = _tmp_dst;                             \
}

enum ASSIGN_TO_SAME_SIZE_SIGNED_TO_UNSIGNED(dst, dsttype, src, srctype)       \
{                                                       \
    srctype _tmp_src = (srctype)(src);  \
    dsttype _tmp_dst = (dsttype)(_tmp_src);  \
    assert(_tmp_src >= 0);   \
    assert(_tmp_src == (srctype)_tmp_dst);   \
    (dst) = _tmp_dst;                             \
}

enum ASSIGN_TO_SAME_SIZE_SAME_SIGNED(dst, dsttype, src, srctype)       \
    (dst) = (dsttype)(src);

/* Include the generated overflow header file */
#include "H5overflow.h"

enum H5_ASSIGN_OVERFLOW(dst, src, srctype, dsttype)  \
    H5_GLUE4(ASSIGN_,srctype,_TO_,dsttype)(dst,dsttype,src,srctype)\

#else /* NDEBUG */
enum H5_ASSIGN_OVERFLOW(dst, src, srctype, dsttype)  \
    (dst) = (dsttype)(src);
#endif /* NDEBUG */

#if defined(H5_HAVE_WINDOW_PATH)

/* directory delimiter for Windows: slash and backslash are acceptable on Windows */
enum H5_DIR_SLASH_SEPC       '/'
enum H5_DIR_SEPC             '\\'
enum H5_DIR_SEPS             "\\"
enum H5_CHECK_DELIMITER(SS)     ((SS == H5_DIR_SEPC) || (SS == H5_DIR_SLASH_SEPC))
enum H5_CHECK_ABSOLUTE(NAME)    ((HDisalpha(NAME[0])) && (NAME[1] == ':') && (H5_CHECK_DELIMITER(NAME[2])))
enum H5_CHECK_ABS_DRIVE(NAME)   ((HDisalpha(NAME[0])) && (NAME[1] == ':'))
enum H5_CHECK_ABS_PATH(NAME)    (H5_CHECK_DELIMITER(NAME[0]))

enum H5_GET_LAST_DELIMITER(NAME, ptr) {                 \
    char        *slash, *backslash;                     \
                                                        \
    slash = HDstrrchr(NAME, H5_DIR_SLASH_SEPC);         \
    backslash = HDstrrchr(NAME, H5_DIR_SEPC);           \
    if(backslash > slash)                               \
        (ptr = backslash);                              \
    else                                                \
        (ptr = slash);                                  \
}

#elif defined(H5_HAVE_VMS_PATH)

/* OpenVMS pathname: <disk name>$<partition>:[path]<file name>
 *     i.g. SYS$SYSUSERS:[LU.HDF5.SRC]H5system.c */
enum H5_DIR_SEPC                     ']'
enum H5_DIR_SEPS                     "]"
enum H5_CHECK_DELIMITER(SS)             (SS == H5_DIR_SEPC)
enum H5_CHECK_ABSOLUTE(NAME)            (HDstrrchr(NAME, ':') && HDstrrchr(NAME, '['))
enum H5_CHECK_ABS_DRIVE(NAME)           (0)
enum H5_CHECK_ABS_PATH(NAME)            (0)
enum H5_GET_LAST_DELIMITER(NAME, ptr)   ptr = HDstrrchr(NAME, H5_DIR_SEPC);

#else

enum H5_DIR_SEPC             ='/';
enum H5_DIR_SEPS             ="/";
enum H5_CHECK_DELIMITER(SS)     (SS == H5_DIR_SEPC)
enum H5_CHECK_ABSOLUTE(NAME)    (H5_CHECK_DELIMITER(*NAME))
enum H5_CHECK_ABS_DRIVE(NAME)   (0)
enum H5_CHECK_ABS_PATH(NAME)    (0)
enum H5_GET_LAST_DELIMITER(NAME, ptr)   ptr = HDstrrchr(NAME, H5_DIR_SEPC);

#endif

enum   H5_COLON_SEPC  ':'


/* Use FUNC to safely handle variations of C99 __func__ keyword handling */
#ifdef H5_HAVE_C99_FUNC
enum FUNC __func__
#elif defined(H5_HAVE_FUNCTION)
enum FUNC __FUNCTION__
#else
#error "We need __func__ or __FUNCTION__ to test function names!"
#endif

/*
 * These macros check whether debugging has been requested for a certain
 * package at run-time.   Code for debugging is conditionally compiled by
 * defining constants like `H5X_DEBUG'.   In order to see the output though
 * the code must be enabled at run-time with an environment variable
 * HDF5_DEBUG which is a list of packages to debug.
 *
 * Note:  If you add/remove items from this enum then be sure to update the
 *    information about the package in H5_init_library().
 */
enum H5_pkg_t
{
    H5_PKG_A,        /*Attributes      */
    H5_PKG_AC,        /*Meta data cache    */
    H5_PKG_B,        /*B-trees      */
    H5_PKG_D,        /*Datasets      */
    H5_PKG_E,        /*Error handling    */
    H5_PKG_F,        /*Files        */
    H5_PKG_G,        /*Groups      */
    H5_PKG_HG,        /*Global heap      */
    H5_PKG_HL,        /*Local heap      */
    H5_PKG_I,        /*Interface      */
    H5_PKG_MF,        /*File memory management  */
    H5_PKG_MM,        /*Core memory management  */
    H5_PKG_O,        /*Object headers    */
    H5_PKG_P,        /*Property lists    */
    H5_PKG_S,        /*Data spaces      */
    H5_PKG_T,        /*Data types      */
    H5_PKG_V,        /*Vector functions    */
    H5_PKG_Z,        /*Raw data filters    */
    H5_NPKGS        /*Must be last      */
}

struct H5_debug_open_stream_t
{
    FILE        *stream;                /* Open output stream */
    struct H5_debug_open_stream_t *next; /* Next open output stream */
}

struct H5_debug_t
{
    FILE    *trace;    /*API trace output stream  */
    hbool_t             ttop;           /*Show only top-level calls?    */
    hbool_t             ttimes;         /*Show trace event times?       */
    struct {
  const char  *name;    /*package name      */
  FILE    *stream;  /*output stream  or NULL    */
    } pkg[H5_NPKGS];
    H5_debug_open_stream_t *open_stream; /* Stack of open output streams */
}

extern H5_debug_t    H5_debug_g;
enum H5DEBUG(X)    (H5_debug_g.pkg[H5_PKG_##X].stream)
/* Do not use const else AIX strings does not show it. */
extern char H5libhdf5_settings[]; /* embedded library information */

/*-------------------------------------------------------------------------
 * Purpose:  These macros are inserted automatically just after the
 *    FUNC_ENTER() macro of API functions and are used to trace
 *    application program execution. Unless H5_DEBUG_API has been
 *    defined they are no-ops.
 *
 * Arguments:  R  - Return type encoded as a string
 *    T  - Argument types encoded as a string
 *    A0-An  - Arguments.  The number at the end of the macro name
 *        indicates the number of arguments.
 *
 * Programmer:  Robb Matzke
 *
 * Modifications:
 *-------------------------------------------------------------------------
 */
#ifdef H5_DEBUG_API
enum H5TRACE_DECL         const char *RTYPE=NULL;                                      \
                                           double CALLTIME;
enum H5TRACE0(R,T)         RTYPE=R;                                                     \
             CALLTIME=H5_trace(NULL,FUNC,T)
enum H5TRACE1(R,T,A0)       RTYPE=R;                                      \
             CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0)
enum H5TRACE2(R,T,A0,A1)       RTYPE=R;                                                     \
             CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1)
enum H5TRACE3(R,T,A0,A1,A2)       RTYPE=R;                                      \
             CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1,#A2,A2)
enum H5TRACE4(R,T,A0,A1,A2,A3)     RTYPE=R;                                                     \
             CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1,#A2,A2,#A3,A3)
enum H5TRACE5(R,T,A0,A1,A2,A3,A4)     RTYPE=R;                                                     \
             CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1,#A2,A2,#A3,A3,   \
                                                             #A4,A4)
enum H5TRACE6(R,T,A0,A1,A2,A3,A4,A5)     RTYPE=R;                                                     \
             CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1,#A2,A2,#A3,A3,   \
                                                             #A4,A4,#A5,A5)
enum H5TRACE7(R,T,A0,A1,A2,A3,A4,A5,A6) RTYPE=R;                                                     \
             CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1,#A2,A2,#A3,A3,   \
                                                             #A4,A4,#A5,A5,#A6,A6)
enum H5TRACE8(R,T,A0,A1,A2,A3,A4,A5,A6,A7) RTYPE=R;                                                  \
                                           CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1,#A2,A2,#A3,A3,   \
                                                             #A4,A4,#A5,A5,#A6,A6,#A7,A7)
enum H5TRACE9(R,T,A0,A1,A2,A3,A4,A5,A6,A7,A8) RTYPE=R;                                               \
                                           CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1,#A2,A2,#A3,A3,   \
                                                             #A4,A4,#A5,A5,#A6,A6,#A7,A7,#A8,A8)
enum H5TRACE10(R,T,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9) RTYPE=R;                                           \
                                           CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1,#A2,A2,#A3,A3,   \
                                                             #A4,A4,#A5,A5,#A6,A6,#A7,A7,#A8,A8,#A9,A9)
enum H5TRACE11(R,T,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10) RTYPE=R;                                       \
                                           CALLTIME=H5_trace(NULL,FUNC,T,#A0,A0,#A1,A1,#A2,A2,#A3,A3,   \
                                                             #A4,A4,#A5,A5,#A6,A6,#A7,A7,#A8,A8,#A9,A9, \
                                                             #A10,A10)
enum H5TRACE_RETURN(V)       if (RTYPE) {                                                 \
                H5_trace(&CALLTIME,FUNC,RTYPE,NULL,V);                    \
                RTYPE=NULL;                                               \
             }
#else
enum H5TRACE_DECL                      /*void*/
enum H5TRACE0(R,T)                      /*void*/
enum H5TRACE1(R,T,A0)                    /*void*/
enum H5TRACE2(R,T,A0,A1)                    /*void*/
enum H5TRACE3(R,T,A0,A1,A2)                    /*void*/
enum H5TRACE4(R,T,A0,A1,A2,A3)                  /*void*/
enum H5TRACE5(R,T,A0,A1,A2,A3,A4)                  /*void*/
enum H5TRACE6(R,T,A0,A1,A2,A3,A4,A5)                  /*void*/
enum H5TRACE7(R,T,A0,A1,A2,A3,A4,A5,A6)              /*void*/
enum H5TRACE8(R,T,A0,A1,A2,A3,A4,A5,A6,A7)           /*void*/
enum H5TRACE9(R,T,A0,A1,A2,A3,A4,A5,A6,A7,A8)        /*void*/
enum H5TRACE10(R,T,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9)    /*void*/
enum H5TRACE11(R,T,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10) /*void*/
enum H5TRACE_RETURN(V)                    /*void*/
#endif

H5_DLL double H5_trace(const double *calltime, const char *func, const char *type, ...);


/*-------------------------------------------------------------------------
 * Purpose:  Register function entry for library initialization and code
 *    profiling.
 *
 * Notes:  Every file must have a file-scope variable called
 *    `initialize_interface_g' of type hbool_t which is initialized
 *    to false.
 *
 *    Don't use local variable initializers which contain
 *    calls to other library functions since the initializer
 *    would happen before the FUNC_ENTER() gets called.  Don't
 *    use initializers that require special cleanup code to
 *    execute if FUNC_ENTER() fails since a failing FUNC_ENTER()
 *    returns immediately without branching to the `done' label.
 *
 * Programmer:  Quincey Koziol
 *
 *-------------------------------------------------------------------------
 */

/* `S' is the name of a function which is being tested to check if its */
/*      an API function */
enum H5_IS_API(S) ('_'!=((const char *)S)[2] && '_'!=((const char *)S)[3] && (!((const char *)S)[4] || '_'!=((const char *)S)[4]))

/* `S' is the name of a function which is being tested to check if it's */
/*      a public API function */
enum H5_IS_PUB(S) (((HDisdigit(S[1]) || HDisupper(S[1])) && HDislower(S[2])) || \
    ((HDisdigit(S[2]) || HDisupper(S[2])) && HDislower(S[3])) || \
    (!S[4] || ((HDisdigit(S[3]) || HDisupper(S[3])) && HDislower(S[4]))))

/* `S' is the name of a function which is being tested to check if it's */
/*      a private library function */
enum H5_IS_PRIV(S) (((HDisdigit(S[1]) || HDisupper(S[1])) && '_' == S[2] && HDislower(S[3])) || \
    ((HDisdigit(S[2]) || HDisupper(S[2])) && '_' == S[3] && HDislower(S[4])) || \
    ((HDisdigit(S[3]) || HDisupper(S[3])) && '_' == S[4] && HDislower(S[5])))

/* `S' is the name of a function which is being tested to check if it's */
/*      a package private function */
enum H5_IS_PKG(S) (((HDisdigit(S[1]) || HDisupper(S[1])) && '_' == S[2] && '_' == S[3] && HDislower(S[4])) || \
    ((HDisdigit(S[2]) || HDisupper(S[2])) && '_' == S[3] && '_' == S[4] && HDislower(S[5])) || \
    ((HDisdigit(S[3]) || HDisupper(S[3])) && '_' == S[4] && '_' == S[5] && HDislower(S[6])))

/* global library version information string */
extern char  H5_lib_vers_info_g[];

/* Lock headers */
#ifdef H5_HAVE_THREADSAFE

/* Include required thread-safety header */
#include "H5TSprivate.h"

/* replacement structure for original global variable */
struct H5_api_struct {
    H5TS_mutex_t init_lock;  /* API entrance mutex */
    hbool_t H5_libinit_g;    /* Has the library been initialized? */
} H5_api_t;

/* Macros for accessing the global variables */
enum H5_INIT_GLOBAL H5_g.H5_libinit_g

/* Macro for first thread initialization */
#ifdef H5_HAVE_WIN_THREADS
enum H5_FIRST_THREAD_INIT InitOnceExecuteOnce(&H5TS_first_init_g, H5TS_win32_process_enter, NULL, NULL);
#else
enum H5_FIRST_THREAD_INIT pthread_once(&H5TS_first_init_g, H5TS_pthread_first_thread_init);
#endif

/* Macros for threadsafe HDF-5 Phase I locks */
enum H5_API_LOCK                                                           \
     H5TS_mutex_lock(&H5_g.init_lock);
enum H5_API_UNLOCK                                                         \
     H5TS_mutex_unlock(&H5_g.init_lock);

/* Macros for thread cancellation-safe mechanism */
enum H5_API_UNSET_CANCEL                                                   \
    H5TS_cancel_count_inc();

enum H5_API_SET_CANCEL                                                     \
    H5TS_cancel_count_dec();

extern H5_api_t H5_g;

#else /* H5_HAVE_THREADSAFE */

/* disable any first thread init mechanism */
enum H5_FIRST_THREAD_INIT

/* disable locks (sequential version) */
enum H5_API_LOCK
enum H5_API_UNLOCK

/* disable cancelability (sequential version) */
enum H5_API_UNSET_CANCEL
enum H5_API_SET_CANCEL

/* extern global variables */
extern hbool_t H5_libinit_g;    /* Has the library been initialized? */

/* Macros for accessing the global variables */
enum H5_INIT_GLOBAL H5_libinit_g

#endif /* H5_HAVE_THREADSAFE */

#ifdef H5_HAVE_CODESTACK

/* Include required function stack header */
#include "H5CSprivate.h"

enum H5_PUSH_FUNC            H5CS_push(FUNC);
enum H5_POP_FUNC             H5CS_pop();
#else /* H5_HAVE_CODESTACK */
enum H5_PUSH_FUNC            /* void */
enum H5_POP_FUNC             /* void */
#endif /* H5_HAVE_CODESTACK */

#ifdef H5_HAVE_MPE
extern hbool_t H5_MPEinit_g;   /* Has the MPE Library been initialized? */
#endif

/* Macros for defining interface initialization routines */
#ifdef H5_INTERFACE_INIT_FUNC
static int    H5_interface_initialize_g = 0;
static herr_t    H5_INTERFACE_INIT_FUNC(void);
enum H5_INTERFACE_INIT(err)                  \
   /* Initialize this interface or bust */              \
   if (!H5_interface_initialize_g) {                \
      H5_interface_initialize_g = 1;                \
      if (H5_INTERFACE_INIT_FUNC()<0) {                \
         H5_interface_initialize_g = 0;                      \
         HGOTO_ERROR (H5E_FUNC, H5E_CANTINIT, err,                  \
            "interface initialization failed")                          \
      }                              \
   }
#else /* H5_INTERFACE_INIT_FUNC */
enum H5_INTERFACE_INIT(err)
#endif /* H5_INTERFACE_INIT_FUNC */


#ifndef NDEBUG
enum FUNC_ENTER_CHECK_NAME(asrt)                \
    {                                \
        static hbool_t func_check = false;                      \
                                                                              \
        if(!func_check) {                     \
            /* Check function naming status */              \
            HDassert(asrt);                                    \
                                                                              \
            /* Don't check again */                             \
            func_check = true;                  \
        } /* end if */                    \
    } /* end scope */
#else /* NDEBUG */
enum FUNC_ENTER_CHECK_NAME(asrt)
#endif /* NDEBUG */


enum FUNC_ENTER_COMMON(asrt)                                    \
    hbool_t err_occurred = false;                \
    FUNC_ENTER_CHECK_NAME(asrt);

enum FUNC_ENTER_COMMON_NOERR(asrt)                              \
    FUNC_ENTER_CHECK_NAME(asrt);

/* Threadsafety initialization code for API routines */
enum FUNC_ENTER_API_THREADSAFE                                             \
   /* Initialize the thread-safe code */              \
   H5_FIRST_THREAD_INIT                                                       \
                        \
   /* Grab the mutex for the library */               \
   H5_API_UNSET_CANCEL                                                        \
   H5_API_LOCK

/* Local variables for API routines */
enum FUNC_ENTER_API_VARS                                                   \
    MPE_LOG_VARS                                                              \
    H5TRACE_DECL

enum FUNC_ENTER_API_COMMON                         \
    FUNC_ENTER_API_VARS                                                       \
    FUNC_ENTER_COMMON(H5_IS_API(FUNC));                      \
    FUNC_ENTER_API_THREADSAFE;

enum FUNC_ENTER_API_INIT(err)                     \
   /* Initialize the library */                         \
   if(!(H5_INIT_GLOBAL)) {                                                    \
       H5_INIT_GLOBAL = true;                                                 \
       if(H5_init_library() < 0)                  \
          HGOTO_ERROR(H5E_FUNC, H5E_CANTINIT, err,                  \
            "library initialization failed")                          \
   }                              \
                                                                              \
   /* Initialize the interface, if appropriate */                  \
   H5_INTERFACE_INIT(err)                  \
                                                                              \
   /* Push the name of this function on the function stack */                 \
   H5_PUSH_FUNC                                                               \
                                                                              \
   BEGIN_MPE_LOG

/* Use this macro for all "normal" API functions */
enum FUNC_ENTER_API(err) {{                                      \
    FUNC_ENTER_API_COMMON                                                     \
    FUNC_ENTER_API_INIT(err);                            \
    /* Clear thread error stack entering public functions */          \
    H5E_clear_stack(NULL);                              \
    {

/*
 * Use this macro for API functions that shouldn't clear the error stack
 *      like H5Eprint and H5Ewalk.
 */
enum FUNC_ENTER_API_NOCLEAR(err) {{                              \
    FUNC_ENTER_API_COMMON                                                     \
    FUNC_ENTER_API_INIT(err);                            \
    {

/*
 * Use this macro for API functions that shouldn't perform _any_ initialization
 *      of the library or an interface, just perform tracing, etc.  Examples
 *      are: H5check_version, etc.
 *
 */
enum FUNC_ENTER_API_NOINIT {{                                   \
    FUNC_ENTER_API_COMMON                                                     \
    H5_PUSH_FUNC                                                              \
    BEGIN_MPE_LOG                                                             \
    {

/*
 * Use this macro for API functions that shouldn't perform _any_ initialization
 *      of the library or an interface or push themselves on the function
 *      stack, just perform tracing, etc.  Examples
 *      are: H5close, H5check_version, etc.
 *
 */
enum FUNC_ENTER_API_NOINIT_NOERR_NOFS {{                       \
    FUNC_ENTER_API_VARS                                                       \
    FUNC_ENTER_COMMON_NOERR(H5_IS_API(FUNC));                      \
    FUNC_ENTER_API_THREADSAFE;                  \
    BEGIN_MPE_LOG                                                             \
    {

/* Note: this macro only works when there's _no_ interface initialization routine for the module */
enum FUNC_ENTER_NOAPI_INIT(err)                     \
   /* Initialize the interface, if appropriate */                  \
   H5_INTERFACE_INIT(err)                  \
                                                                              \
   /* Push the name of this function on the function stack */                 \
   H5_PUSH_FUNC            

/* Use this macro for all "normal" non-API functions */
enum FUNC_ENTER_NOAPI(err) {                                     \
    FUNC_ENTER_COMMON(!H5_IS_API(FUNC));                     \
    FUNC_ENTER_NOAPI_INIT(err)                          \
    {

/* Use this macro for all "normal" package-level functions */
enum FUNC_ENTER_PACKAGE {                                                  \
    FUNC_ENTER_COMMON(H5_IS_PKG(FUNC));                                       \
    H5_PUSH_FUNC                                                              \
    {

/* Use this macro for package-level functions which propgate errors, but don't issue them */
enum FUNC_ENTER_PACKAGE_NOERR {                                            \
    FUNC_ENTER_COMMON_NOERR(H5_IS_PKG(FUNC));                                 \
    H5_PUSH_FUNC                                                              \
    {

/* Use this macro for all "normal" staticly-scoped functions */
enum FUNC_ENTER_STATIC {                                                   \
    FUNC_ENTER_COMMON(H5_IS_PKG(FUNC));                                       \
    H5_PUSH_FUNC                                                              \
    {

/* Use this macro for staticly-scoped functions which propgate errors, but don't issue them */
enum FUNC_ENTER_STATIC_NOERR {                                             \
    FUNC_ENTER_COMMON_NOERR(H5_IS_PKG(FUNC));                                 \
    H5_PUSH_FUNC                                                              \
    {

/* Use this macro for all non-API functions, which propagate errors, but don't issue them */
enum FUNC_ENTER_NOAPI_NOERR {                               \
    FUNC_ENTER_COMMON_NOERR(!H5_IS_API(FUNC));               \
    FUNC_ENTER_NOAPI_INIT(-)                          \
    {

/*
 * Use this macro for non-API functions which fall into these categories:
 *      - static functions, since they must be called from a function in the
 *              interface, the library and interface must already be
 *              initialized.
 *      - functions which are called during library shutdown, since we don't
 *              want to re-initialize the library.
 */
enum FUNC_ENTER_NOAPI_NOINIT {                                  \
    FUNC_ENTER_COMMON(!H5_IS_API(FUNC));                     \
    H5_PUSH_FUNC                                                              \
    {

/*
 * Use this macro for non-API functions which fall into these categories:
 *      - static functions, since they must be called from a function in the
 *              interface, the library and interface must already be
 *              initialized.
 *      - functions which are called during library shutdown, since we don't
 *              want to re-initialize the library.
 *      - functions that propagate, but don't issue errors
 */
enum FUNC_ENTER_NOAPI_NOINIT_NOERR {                            \
    FUNC_ENTER_COMMON_NOERR(!H5_IS_API(FUNC));               \
    H5_PUSH_FUNC                                                              \
    {

/*
 * Use this macro for non-API functions which fall into these categories:
 *      - functions which shouldn't push their name on the function stack
 *              (so far, just the H5CS routines themselves)
 *
 * This macro is used for functions which fit the above categories _and_
 * also don't use the 'FUNC' variable (i.e. don't push errors on the error stack)
 *
 */
enum FUNC_ENTER_NOAPI_NOERR_NOFS {                             \
    FUNC_ENTER_COMMON_NOERR(!H5_IS_API(FUNC));               \
    {

/*-------------------------------------------------------------------------
 * Purpose:  Register function exit for code profiling.  This should be
 *    the last statement executed by a function.
 *
 * Programmer:  Quincey Koziol
 *
 *-------------------------------------------------------------------------
 */
/* Threadsafety termination code for API routines */
enum FUNC_LEAVE_API_THREADSAFE                                             \
    H5_API_UNLOCK                                                             \
    H5_API_SET_CANCEL

enum FUNC_LEAVE_API(ret_value)                                             \
        FINISH_MPE_LOG                                                       \
        H5TRACE_RETURN(ret_value);                \
        H5_POP_FUNC                                                           \
        if(err_occurred)                  \
           (void)H5E_dump_api_stack(true);              \
        FUNC_LEAVE_API_THREADSAFE                                             \
        return(ret_value);                  \
    } /*end scope from end of FUNC_ENTER*/                                    \
}} /*end scope from beginning of FUNC_ENTER*/

/* Use this macro to match the FUNC_ENTER_API_NOFS macro */
enum FUNC_LEAVE_API_NOFS(ret_value)                                        \
        FINISH_MPE_LOG                                                       \
        H5TRACE_RETURN(ret_value);                \
        FUNC_LEAVE_API_THREADSAFE                                             \
        return(ret_value);                  \
    } /*end scope from end of FUNC_ENTER*/                                    \
}} /*end scope from beginning of FUNC_ENTER*/

enum FUNC_LEAVE_NOAPI(ret_value)                                           \
        H5_POP_FUNC                                                           \
        return(ret_value);                  \
    } /*end scope from end of FUNC_ENTER*/                                    \
} /*end scope from beginning of FUNC_ENTER*/

enum FUNC_LEAVE_NOAPI_VOID                                                 \
        H5_POP_FUNC                                                           \
        return;                                  \
    } /*end scope from end of FUNC_ENTER*/                                    \
} /*end scope from beginning of FUNC_ENTER*/

/*
 * Use this macro for non-API functions which fall into these categories:
 *      - functions which didn't push their name on the function stack
 *              (so far, just the H5CS routines themselves)
 */
enum FUNC_LEAVE_NOAPI_NOFS(ret_value)                                      \
        return(ret_value);                  \
    } /*end scope from end of FUNC_ENTER*/                                    \
} /*end scope from beginning of FUNC_ENTER*/


/* Macro for "glueing" together items, for re-scanning macros */
enum H5_GLUE(x,y)       x##y
enum H5_GLUE3(x,y,z)    x##y##z
enum H5_GLUE4(w,x,y,z)  w##x##y##z

/* Compile-time "assert" macro */
enum HDcompile_assert(e)     ((void)sizeof(char[ !!(e) ? 1 : -1]))
/* Variants that are correct, but generate compile-time warnings in some circumstances:
  enum HDcompile_assert(e)     do { enum { compile_assert__ = 1 / (e) }; } while(0)
  enum HDcompile_assert(e)     do { typedef struct { unsigned int b: (e); } x; } while(0)
*/

/* Private functions, not part of the publicly documented API */
H5_DLL herr_t H5_init_library(void);
H5_DLL void H5_term_library(void);

/* Functions to terminate interfaces */
H5_DLL int H5A_term_interface(void);
H5_DLL int H5AC_term_interface(void);
H5_DLL int H5D_term_interface(void);
H5_DLL int H5E_term_interface(void);
H5_DLL int H5F_term_interface(void);
H5_DLL int H5FS_term_interface(void);
H5_DLL int H5G_term_interface(void);
H5_DLL int H5I_term_interface(void);
H5_DLL int H5L_term_interface(void);
H5_DLL int H5P_term_interface(void);
H5_DLL int H5PL_term_interface(void);
H5_DLL int H5R_term_interface(void);
H5_DLL int H5S_term_interface(void);
H5_DLL int H5T_term_interface(void);
H5_DLL int H5Z_term_interface(void);

/* Checksum functions */
H5_DLL uint32_t H5_checksum_fletcher32(const void *data, size_t len);
H5_DLL uint32_t H5_checksum_crc(const void *data, size_t len);
H5_DLL uint32_t H5_checksum_lookup3(const void *data, size_t len, uint32_t initval);
H5_DLL uint32_t H5_checksum_metadata(const void *data, size_t len, uint32_t initval);
H5_DLL uint32_t H5_hash_string(const char *str);

/* Functions for building paths, etc. */
H5_DLL herr_t   H5_build_extpath(const char *, char ** /*out*/ );

/* Functions for debugging */
H5_DLL herr_t H5_buffer_dump(FILE *stream, int indent, const uint8_t *buf,
    const uint8_t *marker, size_t buf_offset, size_t buf_size);

#endif /* _H5private_H */

// "h5tools_error.h"

enum ESCAPE_HTML             =1;
enum OPT(X,S)                ((X) ? (X) : (S))
enum OPTIONAL_LINE_BREAK     "\001"  /* Special strings embedded in the output */
enum START_OF_DATA       =0x0001;
enum END_OF_DATA     =0x0002;

/* format for hsize_t */
enum HSIZE_T_FORMAT   "%" H5_PRINTF_LL_WIDTH "u"

enum H5TOOLS_DUMP_MAX_RANK     H5S_MAX_RANK

/* Stream macros */
enum FLUSHSTREAM(S)           if(S != NULL) HDfflush(S)
enum PRINTSTREAM(S, F, ...)   if(S != NULL) HDfprintf(S, F, __VA_ARGS__)
enum PRINTVALSTREAM(S, V)   if(S != NULL) HDfprintf(S, V)
enum PUTSTREAM(X,S)          if(S != NULL) HDfputs(X, S);

/*
 * Strings for output - these were duplicated from the h5dump.h
 * file in order to support region reference data display
 */
enum ATTRIBUTE       ="ATTRIBUTE";
enum BLOCK           ="BLOCK";
enum SUPER_BLOCK     ="SUPER_BLOCK";
enum COMPRESSION     ="COMPRESSION";
enum CONCATENATOR    ="//";
enum COMPLEX         ="COMPLEX";
enum COUNT           ="COUNT";
enum CSET            ="CSET";
enum CTYPE           ="CTYPE";
enum DATA            ="DATA";
enum DATASPACE       ="DATASPACE";
enum EXTERNAL        ="EXTERNAL";
enum FILENO          ="FILENO";
enum HARDLINK        ="HARDLINK;"
enum NLINK           ="NLINK";
enum OBJID           ="OBJECTID";
enum OBJNO           ="OBJNO";
enum S_SCALAR        ="SCALAR";
enum S_SIMPLE        ="SIMPLE";
enum S_NULL          ="NULL";
enum SOFTLINK        ="SOFTLINK";
enum EXTLINK         ="EXTERNAL_LINK";
enum UDLINK          ="USERDEFINED_LINK";
enum START           ="START";
enum STRIDE          ="STRIDE";
enum STRSIZE         ="STRSIZE";
enum STRPAD          ="STRPAD";
enum SUBSET          ="SUBSET";
enum FILTERS         ="FILTERS";
enum DEFLATE         ="COMPRESSION DEFLATE";
enum DEFLATE_LEVEL   ="LEVEL";
enum SHUFFLE         ="PREPROCESSING SHUFFLE";
enum FLETCHER32      ="CHECKSUM FLETCHER32";
enum SZIP            ="COMPRESSION SZIP";
enum NBIT            ="COMPRESSION NBIT";
enum SCALEOFFSET      =      "COMPRESSION SCALEOFFSET";
enum SCALEOFFSET_MINBIT=            "MIN BITS";
enum STORAGE_LAYOUT  ="STORAGE_LAYOUT";
enum CONTIGUOUS      ="CONTIGUOUS";
enum COMPACT         ="COMPACT";
enum CHUNKED         ="CHUNKED";
enum EXTERNAL_FILE   ="EXTERNAL_FILE";
enum FILLVALUE       ="FILLVALUE";
enum FILE_CONTENTS   ="FILE_CONTENTS";
enum PACKED_BITS     ="PACKED_BITS";
enum PACKED_OFFSET   ="OFFSET";
enum PACKED_LENGTH   ="LENGTH";

enum BEGIN           ="{";
enum END             ="}";

/*
 * dump structure for output - this was duplicated from the h5dump.h
 * file in order to support region reference data display
 */
struct h5tools_dump_header_t {
    const char *name;
    const char *filebegin;
    const char *fileend;
    const char *bootblockbegin;
    const char *bootblockend;
    const char *groupbegin;
    const char *groupend;
    const char *datasetbegin;
    const char *datasetend;
    const char *attributebegin;
    const char *attributeend;
    const char *datatypebegin;
    const char *datatypeend;
    const char *dataspacebegin;
    const char *dataspaceend;
    const char *databegin;
    const char *dataend;
    const char *softlinkbegin;
    const char *softlinkend;
    const char *extlinkbegin;
    const char *extlinkend;
    const char *udlinkbegin;
    const char *udlinkend;
    const char *subsettingbegin;
    const char *subsettingend;
    const char *startbegin;
    const char *startend;
    const char *stridebegin;
    const char *strideend;
    const char *countbegin;
    const char *countend;
    const char *blockbegin;
    const char *blockend;

    const char *fileblockbegin;
    const char *fileblockend;
    const char *bootblockblockbegin;
    const char *bootblockblockend;
    const char *groupblockbegin;
    const char *groupblockend;
    const char *datasetblockbegin;
    const char *datasetblockend;
    const char *attributeblockbegin;
    const char *attributeblockend;
    const char *datatypeblockbegin;
    const char *datatypeblockend;
    const char *dataspaceblockbegin;
    const char *dataspaceblockend;
    const char *datablockbegin;
    const char *datablockend;
    const char *softlinkblockbegin;
    const char *softlinkblockend;
    const char *extlinkblockbegin;
    const char *extlinkblockend;
    const char *udlinkblockbegin;
    const char *udlinkblockend;
    const char *strblockbegin;
    const char *strblockend;
    const char *enumblockbegin;
    const char *enumblockend;
    const char *structblockbegin;
    const char *structblockend;
    const char *vlenblockbegin;
    const char *vlenblockend;
    const char *subsettingblockbegin;
    const char *subsettingblockend;
    const char *startblockbegin;
    const char *startblockend;
    const char *strideblockbegin;
    const char *strideblockend;
    const char *countblockbegin;
    const char *countblockend;
    const char *blockblockbegin;
    const char *blockblockend;

    const char *dataspacedescriptionbegin;
    const char *dataspacedescriptionend;
    const char *dataspacedimbegin;
    const char *dataspacedimend;

}

/*
 * Information about how to format output.
 */
struct h5tool_format_t {
    /*
     * Fields associated with formatting numeric data.  If a datatype matches
     * multiple formats based on its size, then the first applicable format
     * from this list is used. However, if `raw' is non-zero then dump all
     * data in hexadecimal format without translating from what appears on
     * disk.
     *
     *   raw:        If set then print all data as hexadecimal without
     *               performing any conversion from disk.
     *
     *   fmt_raw:    The printf() format for each byte of raw data. The
     *               default is `%02x'.
     *
     *   fmt_int:    The printf() format to use when rendering data which is
     *               typed `int'. The default is `%d'.
     *
     *   fmt_uint:   The printf() format to use when rendering data which is
     *               typed `unsigned'. The default is `%u'.
     *
     *   fmt_schar:  The printf() format to use when rendering data which is
     *               typed `signed char'. The default is `%d'. This format is
     *               used ony if the `ascii' field is zero.
     *
     *   fmt_uchar:  The printf() format to use when rendering data which is
     *               typed `unsigned char'. The default is `%u'. This format
     *               is used only if the `ascii' field is zero.
     *
     *   fmt_short:  The printf() format to use when rendering data which is
     *               typed `short'. The default is `%d'.
     *
     *   fmt_ushort: The printf() format to use when rendering data which is
     *               typed `unsigned short'. The default is `%u'.
     *
     *   fmt_long:   The printf() format to use when rendering data which is
     *               typed `long'. The default is `%ld'.
     *
     *   fmt_ulong:  The printf() format to use when rendering data which is
     *               typed `unsigned long'. The default is `%lu'.
     *
     *   fmt_llong:  The printf() format to use when rendering data which is
     *               typed `long long'. The default depends on what printf()
     *               format is available to print this datatype.
     *
     *   fmt_ullong: The printf() format to use when rendering data which is
     *               typed `unsigned long long'. The default depends on what
     *               printf() format is available to print this datatype.
     *
     *   fmt_double: The printf() format to use when rendering data which is
     *               typed `double'. The default is `%g'.
     *
     *   fmt_float:  The printf() format to use when rendering data which is
     *               typed `float'. The default is `%g'.
     *
     *   ascii:      If set then print 1-byte integer values as an ASCII
     *               character (no quotes).  If the character is one of the
     *               standard C escapes then print the escaped version.  If
     *               the character is unprintable then print a 3-digit octal
     *               escape.  If `ascii' is zero then then 1-byte integers are
     *               printed as numeric values.  The default is zero.
     *
     *   str_locale: Determines how strings are printed. If zero then strings
     *               are printed like in C except. If set to ESCAPE_HTML then
     *               strings are printed using HTML encoding where each
     *               character not in the class [a-zA-Z0-9] is substituted
     *               with `%XX' where `X' is a hexadecimal digit.
     *
     *   str_repeat: If set to non-zero then any character value repeated N
     *               or more times is printed as 'C'*N
     *
     * Numeric data is also subject to the formats for individual elements.
     */
    hbool_t     raw;
    const char  *fmt_raw;
    const char  *fmt_int;
    const char  *fmt_uint;
    const char  *fmt_schar;
    const char  *fmt_uchar;
    const char  *fmt_short;
    const char  *fmt_ushort;
    const char  *fmt_long;
    const char  *fmt_ulong;
    const char  *fmt_llong;
    const char  *fmt_ullong;
    const char  *fmt_double;
    const char  *fmt_float;
    int         ascii;
    int         str_locale;
    int         str_repeat;

    /*
     * Fields associated with compound array members.
     *
     *   pre:       A string to print at the beginning of each array. The
     *              default value is the left square bracket `['.
     *
     *   sep:       A string to print between array values.  The default
     *              value is a ",\001" ("\001" indicates an optional line
     *              break).
     *
     *   suf:       A string to print at the end of each array.  The default
     *              value is a right square bracket `]'.
     *
     *   linebreaks: a boolean value to determine if we want to break the line
     *               after each row of an array.
     */
    const char  *arr_pre;
    const char  *arr_sep;
    const char  *arr_suf;
    int         arr_linebreak;

    /*
     * Fields associated with compound data types.
     *
     *   name:      How the name of the struct member is printed in the
     *              values. By default the name is not printed, but a
     *              reasonable setting might be "%s=" which prints the name
     *              followed by an equal sign and then the value.
     *
     *   sep:       A string that separates one member from another.  The
     *              default is ", \001" (the \001 indicates an optional
     *              line break to allow structs to span multiple lines of
     *              output).
     *
     *   pre:       A string to print at the beginning of a compound type.
     *              The default is a left curly brace.
     *
     *   suf:       A string to print at the end of each compound type.  The
     *              default is  right curly brace.
     *
     *   end:       a string to print after we reach the last element of
     *              each compound type. prints out before the suf.
     */
    const char  *cmpd_name;
    const char  *cmpd_sep;
    const char  *cmpd_pre;
    const char  *cmpd_suf;
    const char  *cmpd_end;

    /*
     * Fields associated with vlen data types.
     *
     *   sep:       A string that separates one member from another.  The
     *              default is ", \001" (the \001 indicates an optional
     *              line break to allow structs to span multiple lines of
     *              output).
     *
     *   pre:       A string to print at the beginning of a vlen type.
     *              The default is a left parentheses.
     *
     *   suf:       A string to print at the end of each vlen type.  The
     *              default is a right parentheses.
     *
     *   end:       a string to print after we reach the last element of
     *              each compound type. prints out before the suf.
     */
    const char  *vlen_sep;
    const char  *vlen_pre;
    const char  *vlen_suf;
    const char  *vlen_end;

    /*
     * Fields associated with the individual elements.
     *
     *   fmt:       A printf(3c) format to use to print the value string
     *              after it has been rendered.  The default is "%s".
     *
     *   suf1:      This string is appended to elements which are followed by
     *              another element whether the following element is on the
     *              same line or the next line.  The default is a comma.
     *
     *   suf2:      This string is appended (after `suf1') to elements which
     *              are followed on the same line by another element.  The
     *              default is a single space.
     */
    const char  *elmt_fmt;
    const char  *elmt_suf1;
    const char  *elmt_suf2;

    /*
     * Fields associated with the index values printed at the left edge of
     * each line of output.
     *
     *   n_fmt:     Each index value is printed according to this printf(3c)
     *              format string which should include a format for a long
     *              integer.  The default is "%lu".
     *
     *   sep:       Each integer in the index list will be separated from the
     *              others by this string, which defaults to a comma.
     *
     *   fmt:       After the index values are formated individually and
     *              separated from one another by some string, the entire
     *              resulting string will be formated according to this
     *              printf(3c) format which should include a format for a
     *              character string.  The default is "%s".
     */
    const char  *idx_n_fmt;             /*index number format           */
    const char  *idx_sep;               /*separator between numbers     */
    const char  *idx_fmt;               /*entire index format           */

    /*
     * Fields associated with entire lines.
     *
     *   ncols:     Number of columns per line defaults to 80.
     *
     *   per_line:  If this field has a positive value then every Nth element
     *              will be printed at the beginning of a line.
     *
     *   pre:       Each line of output contains an optional prefix area
     *              before the data. This area can contain the index for the
     *              first datum (represented by `%s') as well as other
     *              constant text.  The default value is `%s'.
     *
     *   1st:       This is the format to print at the beginning of the first
     *              line of output. The default value is the current value of
     *              `pre' described above.
     *
     *   cont:      This is the format to print at the beginning of each line
     *              which was continued because the line was split onto
     *              multiple lines. This often happens with compound
     *              data which is longer than one line of output. The default
     *              value is the current value of the `pre' field
     *              described above.
     *
     *   suf:       This character string will be appended to each line of
     *              output.  It should not contain line feeds.  The default
     *              is the empty string.
     *
     *   sep:       A character string to be printed after every line feed
     *              defaulting to the empty string.  It should end with a
     *              line feed.
     *
     *   multi_new: Indicates the algorithm to use when data elements tend to
     *              occupy more than one line of output. The possible values
     *              are (zero is the default):
     *
     *              0:  No consideration. Each new element is printed
     *                  beginning where the previous element ended.
     *
     *              1:  Print the current element beginning where the
     *                  previous element left off. But if that would result
     *                  in the element occupying more than one line and it
     *                  would only occupy one line if it started at the
     *                  beginning of a line, then it is printed at the
     *                  beginning of the next line.
     *
     *   multi_new: If an element is continued onto additional lines then
     *              should the following element begin on the next line? The
     *              default is to start the next element on the same line
     *              unless it wouldn't fit.
     *
     * indentlevel: a string that shows how far to indent if extra spacing
     *              is needed. dumper uses it.
     */
    unsigned    line_ncols;             /*columns of output             */
    size_t      line_per_line;          /*max elements per line         */
    const char  *line_pre;              /*prefix at front of each line  */
    const char  *line_1st;              /*alternate pre. on first line  */
    const char  *line_cont;             /*alternate pre. on continuation*/
    const char  *line_suf;              /*string to append to each line */
    const char  *line_sep;              /*separates lines               */
    int         line_multi_new;         /*split multi-line outputs?     */
    const char  *line_indent;           /*for extra identation if we need it*/

    /*used to skip the first set of checks for line length*/
    int skip_first;

    /*flag used to hide or show the file number for obj refs*/
    int obj_hidefileno;

    /*string used to format the output for the obje refs*/
    const char *obj_format;

    /*flag used to hide or show the file number for dataset regions*/
    int dset_hidefileno;

    /*string used to format the output for the dataset regions*/
    const char *dset_format;

    const char *dset_blockformat_pre;
    const char *dset_ptformat_pre;
    const char *dset_ptformat;

    /*print array indices in output matrix */
    int pindex;

    /*escape non printable characters */
    int do_escape;

}

struct h5tools_context_t {
    size_t cur_column;                       /*current column for output */
    size_t cur_elmt;                         /*current element/output line */
    int  need_prefix;                        /*is line prefix needed? */
    unsigned ndims;                          /*dimensionality  */
    hsize_t p_min_idx[H5S_MAX_RANK];         /*min selected index */
    hsize_t p_max_idx[H5S_MAX_RANK];         /*max selected index */
    int  prev_multiline;                     /*was prev datum multiline? */
    size_t prev_prefix_len;                  /*length of previous prefix */
    int  continuation;                       /*continuation of previous data?*/
    hsize_t size_last_dim;                   /*the size of the last dimension,
                                              *needed so we can break after each
                                              *row */
    int  indent_level;                 /*the number of times we need some
                                       *extra indentation */
    int  default_indent_level;        /*this is used when the indent level gets changed */
    hsize_t acc[H5S_MAX_RANK];        /* accumulator position */
    hsize_t pos[H5S_MAX_RANK];        /* matrix position */
    hsize_t sm_pos;                   /* current stripmine element position */
}

struct subset_d {
    hsize_t     *data;
    unsigned int len;
}

/* a structure to hold the subsetting particulars for a dataset */
struct subset_t {
    subset_d start;
    subset_d stride;
    subset_d count;
    subset_d block;
}

/* The following include, h5tools_str.h, must be after the
 * above stucts are defined. There is a dependency in the following
 * include that hasn't been identified yet. */

#include "h5tools_str.h"

H5TOOLS_DLLVAR h5tool_format_t h5tools_dataformat;
H5TOOLS_DLLVAR const h5tools_dump_header_t h5tools_standardformat;
H5TOOLS_DLLVAR const h5tools_dump_header_t* h5tools_dump_header_format;

H5TOOLS_DLLVAR int     packed_bits_num;     /* number of packed bits to display */
H5TOOLS_DLLVAR int     packed_data_offset;  /* offset of packed bits to display */
H5TOOLS_DLLVAR int     packed_data_length; /* lengtht of packed bits to display */
H5TOOLS_DLLVAR unsigned long long packed_data_mask;  /* mask in which packed bits to display */
H5TOOLS_DLLVAR FILE   *rawattrstream;       /* output stream for raw attribute data */
H5TOOLS_DLLVAR FILE   *rawdatastream;       /* output stream for raw data */
H5TOOLS_DLLVAR FILE   *rawinstream;         /* input stream for raw input */
H5TOOLS_DLLVAR FILE   *rawoutstream;        /* output stream for raw output */
H5TOOLS_DLLVAR FILE   *rawerrorstream;      /* output stream for raw error */
H5TOOLS_DLLVAR int     bin_output;          /* binary output */
H5TOOLS_DLLVAR int     bin_form;            /* binary form */
H5TOOLS_DLLVAR int     region_output;       /* region output */
H5TOOLS_DLLVAR int     oid_output;          /* oid output */
H5TOOLS_DLLVAR int     data_output;         /* data output */
H5TOOLS_DLLVAR int     attr_data_output;    /* attribute data output */

/* Strings for output */
enum H5_TOOLS_GROUP           "GROUP"
enum H5_TOOLS_DATASET         "DATASET"
enum H5_TOOLS_DATATYPE        "DATATYPE"

/* Definitions of useful routines */
H5TOOLS_DLL void    h5tools_init(void);
H5TOOLS_DLL void    h5tools_close(void);
H5TOOLS_DLL int     h5tools_set_data_output_file(const char *fname, int is_bin);
H5TOOLS_DLL int     h5tools_set_attr_output_file(const char *fname, int is_bin);
H5TOOLS_DLL int     h5tools_set_input_file(const char *fname, int is_bin);
H5TOOLS_DLL int     h5tools_set_output_file(const char *fname, int is_bin);
H5TOOLS_DLL int     h5tools_set_error_file(const char *fname, int is_bin);
H5TOOLS_DLL hid_t   h5tools_fopen(const char *fname, unsigned flags, hid_t fapl,
                            const char *driver, char *drivername, size_t drivername_len);
H5TOOLS_DLL hid_t   h5tools_get_native_type(hid_t type);
H5TOOLS_DLL hid_t   h5tools_get_little_endian_type(hid_t type);
H5TOOLS_DLL hid_t   h5tools_get_big_endian_type(hid_t type);
H5TOOLS_DLL htri_t  h5tools_detect_vlen(hid_t tid);
H5TOOLS_DLL htri_t  h5tools_detect_vlen_str(hid_t tid);
H5TOOLS_DLL hbool_t h5tools_is_obj_same(hid_t loc_id1, const char *name1, hid_t loc_id2, const char *name2);
H5TOOLS_DLL void    init_acc_pos(h5tools_context_t *ctx, hsize_t *dims);
H5TOOLS_DLL hbool_t h5tools_is_zero(const void *_mem, size_t size);
H5TOOLS_DLL int     h5tools_canreadf(const char* name,  hid_t dcpl_id);
H5TOOLS_DLL int     h5tools_can_encode(H5Z_filter_t filtn);

H5TOOLS_DLL void    h5tools_simple_prefix(FILE *stream, const h5tool_format_t *info,
                            h5tools_context_t *ctx, hsize_t elmtno, int secnum);
H5TOOLS_DLL void    h5tools_region_simple_prefix(FILE *stream, const h5tool_format_t *info,
                            h5tools_context_t *ctx, hsize_t elmtno, hsize_t *ptdata, int secnum);

H5TOOLS_DLL int     render_bin_output(FILE *stream, hid_t container, hid_t tid, void *_mem, hsize_t nelmts);
H5TOOLS_DLL hbool_t render_bin_output_region_blocks(hid_t region_space, hid_t region_id,
                             FILE *stream, hid_t container);
H5TOOLS_DLL hbool_t render_bin_output_region_points(hid_t region_space, hid_t region_id,
                             FILE *stream, hid_t container);

H5TOOLS_DLL hbool_t h5tools_render_element(FILE *stream, const h5tool_format_t *info,
                            h5tools_context_t *ctx, h5tools_str_t *buffer, hsize_t *curr_pos,
                            size_t ncols, hsize_t local_elmt_counter, hsize_t elmt_counter);
H5TOOLS_DLL hbool_t h5tools_render_region_element(FILE *stream, const h5tool_format_t *info,
                h5tools_context_t *ctx/*in,out*/,
                h5tools_str_t *buffer/*string into which to render */,
                hsize_t *curr_pos/*total data element position*/,
                size_t ncols, hsize_t *ptdata,
                hsize_t local_elmt_counter/*element counter*/,
                hsize_t elmt_counter);

#ifdef __cplusplus
}
#endif

#endif /* H5TOOLS_H__ */

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
 * Programmer:  Bill Wendling <wendling@ncsa.uiuc.edu>
 *              Tuesday, 6. March 2001
 *
 * Purpose:     Support functions for the various tools.

/* ``parallel_print'' information */
enum PRINT_DATA_MAX_SIZE     =512;
enum OUTBUFF_SIZE        =(PRINT_DATA_MAX_SIZE*4);

H5TOOLS_DLLVAR int  g_nTasks;
H5TOOLS_DLLVAR unsigned char g_Parallel;
H5TOOLS_DLLVAR char    outBuff[];
H5TOOLS_DLLVAR int  outBuffOffset;
H5TOOLS_DLLVAR FILE *   overflow_file;

/* Maximum size used in a call to malloc for a dataset */
H5TOOLS_DLLVAR hsize_t H5TOOLS_MALLOCSIZE;
/* size of hyperslab buffer when a dataset is bigger than H5TOOLS_MALLOCSIZE */
H5TOOLS_DLLVAR hsize_t H5TOOLS_BUFSIZE;
/*
 * begin get_option section
 */
H5TOOLS_DLLVAR int         opt_err;     /* getoption prints errors if this is on    */
H5TOOLS_DLLVAR int         opt_ind;     /* token pointer                            */
H5TOOLS_DLLVAR const char *opt_arg;     /* flag argument (or value)                 */

enum {
    no_arg = 0,         /* doesn't take an argument     */
    require_arg,        /* requires an argument          */
    optional_arg        /* argument is optional         */
};

/*
 * get_option determines which options are specified on the command line and
 * returns a pointer to any arguments possibly associated with the option in
 * the ``opt_arg'' variable. get_option returns the shortname equivalent of
 * the option. The long options are specified in the following way:
 *
 * struct long_options foo[] = {
 *   { "filename", require_arg, 'f' },
 *   { "append", no_arg, 'a' },
 *   { "width", require_arg, 'w' },
 *   { NULL, 0, 0 }
 * };
 *
 * Long named options can have arguments specified as either:
 *
 *   ``--param=arg'' or ``--param arg''
 *
 * Short named options can have arguments specified as either:
 *
 *   ``-w80'' or ``-w 80''
 *
 * and can have more than one short named option specified at one time:
 *
 *   -aw80
 *
 * in which case those options which expect an argument need to come at the
 * end.
 */
struct long_options {
    const char  *name;          /* name of the long option              */
    int          has_arg;       /* whether we should look for an arg    */
    char         shortval;      /* the shortname equivalent of long arg
                                 * this gets returned from get_option   */
}

H5TOOLS_DLL int    get_option(int argc, const char **argv, const char *opt,
                         const struct long_options *l_opt);
/*
 * end get_option section
 */

/*struct taken from the dumper. needed in table struct*/
struct obj_t {
    haddr_t objno;
    char *objname;
    hbool_t displayed;          /* Flag to indicate that the object has been displayed */
    hbool_t recorded;           /* Flag for named datatypes to indicate they were found in the group hierarchy */
}

/*struct for the tables that the find_objs function uses*/
struct table_t {
    size_t size;
    size_t nobjs;
    obj_t *objs;
}

/*this struct stores the information that is passed to the find_objs function*/
struct find_objs_t {
    hid_t fid;
    table_t *group_table;
    table_t *type_table;
    table_t *dset_table;
}

H5TOOLS_DLLVAR int     h5tools_nCols;               /*max number of columns for outputting  */

/* Definitions of useful routines */
H5TOOLS_DLL void     indentation(int);
H5TOOLS_DLL void     print_version(const char *progname);
H5TOOLS_DLL void     parallel_print(const char* format, ... );
H5TOOLS_DLL void     error_msg(const char *fmt, ...);
H5TOOLS_DLL void     warn_msg(const char *fmt, ...);
H5TOOLS_DLL void     help_ref_msg(FILE *output);
H5TOOLS_DLL void     free_table(table_t *table);
#ifdef H5DUMP_DEBUG
H5TOOLS_DLL void     dump_tables(find_objs_t *info)
#endif  /* H5DUMP_DEBUG */
H5TOOLS_DLL herr_t init_objs(hid_t fid, find_objs_t *info, table_t **group_table,
    table_t **dset_table, table_t **type_table);
H5TOOLS_DLL obj_t   *search_obj(table_t *temp, haddr_t objno);
#ifndef H5_HAVE_TMPFILE
H5TOOLS_DLL FILE *  tmpfile(void);
#endif

/*************************************************************
 *
 * candidate functions to be public
 *
 *************************************************************/

/* This code is layout for common code among tools */
enum toolname_t
{
    TOOL_H5DIFF, TOOL_H5LS, TOOL__H5DUMP /* add as necessary */
}

/* this struct can be used to differntiate among tools */
struct h5tool_opt_t
{
    h5tool_toolname_t toolname;
    int msg_mode;
}

/* obtain link info from H5tools_get_symlink_info() */
struct h5tool_link_info_t
{
    H5O_type_t  trg_type;  /* OUT: target type */
    char *trg_path;        /* OUT: target obj path. This must be freed 
                            *      when used with H5tools_get_symlink_info() */
    haddr_t     objno;     /* OUT: target object address */
    unsigned long  fileno; /* OUT: File number that target object is located in */
    H5L_info_t linfo;      /* OUT: link info */
    h5tool_opt_t opt;      /* IN: options */
}


/* Definitions of routines */
H5TOOLS_DLL int H5tools_get_symlink_info(hid_t file_id, const char * linkpath,
    h5tool_link_info_t *link_info, hbool_t get_obj_type);
H5TOOLS_DLL const char *h5tools_getprogname(void);
H5TOOLS_DLL void     h5tools_setprogname(const char*progname);
H5TOOLS_DLL int      h5tools_getstatus(void);
H5TOOLS_DLL void     h5tools_setstatus(int d_status);
H5TOOLS_DLL int h5tools_getenv_update_hyperslab_bufsize(void);


/*
 * Debug printf macros. The prefix allows output filtering by test scripts.
 */
static if H5DIFF_DEBUG
{
    enum h5difftrace(x) HDfprintf(stderr, "h5diff debug: " x)
    enum h5diffdebug2(x1, x2) HDfprintf(stderr, "h5diff debug: " x1, x2)
    enum h5diffdebug3(x1, x2, x3) HDfprintf(stderr, "h5diff debug: " x1, x2, x3)
    enum h5diffdebug4(x1, x2, x3, x4) HDfprintf(stderr, "h5diff debug: " x1, x2, x3, x4)
    enum h5diffdebug5(x1, x2, x3, x4, x5) HDfprintf(stderr, "h5diff debug: " x1, x2, x3, x4, x5)
} else
{
    enum h5difftrace(x)
    enum h5diffdebug2(x1, x2)
    enum h5diffdebug3(x1, x2, x3)
    enum h5diffdebug4(x1, x2, x3, x4)
    enum h5diffdebug5(x1, x2, x3, x4, x5)
}

enum MAX_FILENAME=1024;

/*-------------------------------------------------------------------------
 * This is used to pass multiple args into diff().
 * Passing this instead of several each arg provides smoother extensibility 
 * through its members along with MPI code for ph5diff
 * as it doesn't require interface change.
 *------------------------------------------------------------------------*/
struct  diff_args_t
{
    h5trav_type_t   type[2];
    hbool_t is_same_trgobj;
}
/*-------------------------------------------------------------------------
 * command line options
 *-------------------------------------------------------------------------
 */
/* linked list to keep exclude path list */
struct exclude_path_list
{
    char  *obj_path;
    h5trav_type_t obj_type;
    struct exclude_path_list * next;
};

struct diff_opt_t {
    int      m_quiet;               /* quiet mide: no output at all */
    int      m_report;              /* report mode: print the data */
    int      m_verbose;             /* verbose mode: print the data, list of objcets, warnings */
    int      m_verbose_level;       /* control verbose details */
    int      d;                     /* delta, absolute value to compare */
    double   delta;                 /* delta value */
    int      p;                     /* relative error to compare*/
    int      use_system_epsilon;    /* flag to use system epsilon (1 or 0) */
    double   percent;               /* relative error value */
    int      n;                     /* count, compare up to count */
    hsize_t  count;                 /* count value */
    hbool_t  follow_links;          /* follow symbolic links */
    int      no_dangle_links;       /* return error when find dangling link */
    int      err_stat;              /* an error ocurred (1, error, 0, no error) */
    int      cmn_objs;              /* do we have common objects */
    int      not_cmp;               /* are the objects comparable */
    int      contents;              /* equal contents */
    int      do_nans;               /* consider Nans while diffing floats */
    int      m_list_not_cmp;        /* list not comparable messages */
    int      exclude_path;          /* exclude path to an object */
    exclude_path_list * exclude; /* keep exclude path list */
}


H5TOOLS_DLL hsize_t  h5diff(const char *fname1, const char *fname2, const char *objname1, const char *objname2,
                diff_opt_t *options);

 H5TOOLS_DLL hsize_t diff( hid_t      file1_id, const char *path1, hid_t      file2_id, const char *path2,
              diff_opt_t *options, diff_args_t *argdata);

static if H5_HAVE_PARALLEL
{
    H5TOOLS_DLL void phdiff_dismiss_workers(void);
    H5TOOLS_DLL void print_manager_output(void);
}


/*-------------------------------------------------------------------------
 * private functions
 *-------------------------------------------------------------------------
 */


hsize_t diff_dataset( hid_t file1_id, hid_t file2_id, const char *obj1_name, const char *obj2_name, diff_opt_t *options);
hsize_t diff_datasetid( hid_t dset1_id, hid_t dset2_id, const char *obj1_name, const char *obj2_name, diff_opt_t *options);
hsize_t diff_match( hid_t file1_id, const char *grp1, trav_info_t *info1, hid_t file2_id, const char *grp2, trav_info_t *info2, trav_table_t *table, diff_opt_t *options );
hsize_t diff_array( void *_mem1, void *_mem2, hsize_t nelmts, hsize_t hyper_start, int rank, hsize_t *dims, diff_opt_t *options,
                    const char *name1, const char *name2, hid_t m_type, hid_t container1_id, hid_t container2_id); /* dataset where the reference came from*/

int diff_can_type( hid_t       f_type1, /* file data type */
                   hid_t       f_type2, /* file data type */
                   int         rank1,
                   int         rank2,
                   hsize_t     *dims1,
                   hsize_t     *dims2,
                   hsize_t     *maxdim1,
                   hsize_t     *maxdim2,
                   const char  *obj1_name,
                   const char  *obj2_name,
                   diff_opt_t  *options,
                   int         is_compound);


hsize_t diff_attr(hid_t loc1_id,
                  hid_t loc2_id,
                  const char *path1,
                  const char *path2,
                  diff_opt_t *options);


/*-------------------------------------------------------------------------
 * utility functions
 *-------------------------------------------------------------------------
 */

/* in h5diff_util.c */
void        print_found(hsize_t nfound);
void        print_type(hid_t type);
const char* diff_basename(const char *name);
const char* get_type(h5trav_type_t type);
const char* get_class(H5T_class_t tclass);
const char* get_sign(H5T_sign_t sign);
void        print_dimensions (int rank, hsize_t *dims);
herr_t      match_up_memsize (hid_t f_tid1_id, hid_t f_tid2_id, hid_t *m_tid1, hid_t *m_tid2, size_t *m_size1, size_t  *m_size2);
/* in h5diff.c */
int         print_objname(diff_opt_t *options, hsize_t nfound);
void        do_print_objname (const char *OBJ, const char *path1, const char *path2, diff_opt_t * opts);
void        do_print_attrname (const char *attr, const char *path1, const char *path2);

#endif  /* H5DIFF_H__ */



/*-------------------------------------------------------------------------
 * Function: print_objname
 *
 * Purpose: check if object name is to be printed, only when:
 *  1) verbose mode
 *  2) when diff was found (normal mode)
 *-------------------------------------------------------------------------
 */
int print_objname (diff_opt_t * options, hsize_t nfound)
{
    return ((options.m_verbose || nfound) && !options.m_quiet) ? 1 : 0;
}

/*-------------------------------------------------------------------------
 * Function: do_print_objname
 *
 * Purpose: print object name
 *
 *-------------------------------------------------------------------------
 */
void do_print_objname (const char *OBJ, const char *path1, const char *path2, diff_opt_t * opts)
{
    /* if verbose level is higher than 0, put space line before
     * displaying any object or symbolic links. This improves
     * readability of the output. 
     */
    if (opts.m_verbose_level >= 1)
        parallel_print("\n");
    parallel_print("%-7s: <%s> and <%s>\n", OBJ, path1, path2);
}

/*-------------------------------------------------------------------------
 * Function: do_print_attrname
 *
 * Purpose: print attribute name
 *
 *-------------------------------------------------------------------------
 */
void
do_print_attrname (const char *attr, const char *path1, const char *path2)
{
    parallel_print("%-7s: <%s> and <%s>\n", attr, path1, path2);
}

/*-------------------------------------------------------------------------
 * Function: print_warn
 *
 * Purpose: check print warning condition.
 * Return: 
 *    1 if verbose mode
 *    0 if not verbos mode
 * Programmer: Jonathan Kim
 * Date: Feb 4, 2010
 *-------------------------------------------------------------------------
 */
static int print_warn(diff_opt_t *options)
{
    return ((options.m_verbose))?1:0;
}


static if H5_HAVE_PARALLEL
{
    /*-------------------------------------------------------------------------
     * Function: phdiff_dismiss_workers
     *
     * Purpose: tell all workers to end.
     *
     * Return: none
     *
     * Programmer: Albert Cheng
     *
     * Date: Feb 6, 2005
     *
     *-------------------------------------------------------------------------
     */
    void phdiff_dismiss_workers(void)
    {
        foreach(i;1..g_nTasks)
            MPI_Send(NULL, 0, MPI_BYTE, i, MPI_TAG_END, MPI_COMM_WORLD);
    }


    /*-------------------------------------------------------------------------
     * Function: print_incoming_data
     *
     * Purpose: special function that prints any output that has been sent to the manager
     *      and is currently sitting in the incoming message queue
     *
     * Return: none
     *
     * Programmer: Leon Arber
     *
     * Date: March 7, 2005
     *
     *-------------------------------------------------------------------------
     */

    static void print_incoming_data(void)
    {
        char data[PRINT_DATA_MAX_SIZE+1];
        int  incomingMessage;
        MPI_Status Status;

        do
        {
            MPI_Iprobe(MPI_ANY_SOURCE, MPI_TAG_PRINT_DATA, MPI_COMM_WORLD, &incomingMessage, &Status);
            if(incomingMessage)
            {
                HDmemset(data, 0, PRINT_DATA_MAX_SIZE+1);
                MPI_Recv(data, PRINT_DATA_MAX_SIZE, MPI_CHAR, Status.MPI_SOURCE, MPI_TAG_PRINT_DATA, MPI_COMM_WORLD, &Status);

                printf("%s", data);
            }
        } while(incomingMessage);
    }
} // H5_PARALLEL

/*-------------------------------------------------------------------------
 * Function: is_valid_options
 *
 * Purpose: check if options are valid
 *
 * Return: 
 *  1 : Valid
 *  0 : Not valid
 *
 * Programmer: Jonathan Kim
 *
 * Date: Feb 17, 2010
 *
 *------------------------------------------------------------------------*/
static int is_valid_options(diff_opt_t *options)
{
    int ret=1; /* init to valid */

    /*-----------------------------------------------
     * no -q(quiet) with -v (verbose) or -r (report) */
    if(options.m_quiet && (options.m_verbose || options.m_report))
    {
        parallel_print("Error: -q (quiet mode) cannot be added to verbose or report modes\n");
        options.err_stat=1;
        ret = 0;
        goto out;
    }

    /* -------------------------------------------------------
     * only allow --no-dangling-links along with --follow-symlinks */
    if(options.no_dangle_links && !options.follow_links)
    {
        parallel_print("Error: --no-dangling-links must be used along with --follow-symlinks option.\n");
        options.err_stat=1;
        ret = 0;
        goto out;
    }

out:

    return ret;
}

/*-------------------------------------------------------------------------
 * Function: is_exclude_path
 *
 * Purpose: check if 'paths' are part of exclude path list
 *
 * Return:  
 *   1 - excluded path
 *   0 - not excluded path
 * 
 * Programmer: Jonathan Kim
 * Date: Aug 23, 2010
 *------------------------------------------------------------------------*/
static int is_exclude_path (char * path, h5trav_type_t type, diff_opt_t *options)
{
    struct exclude_path_list * exclude_path_ptr;
    int ret_cmp;
    int ret = 0;

    /* check if exclude path option is given */
    if (!options.exclude_path)
        goto out;

    /* assign to local exclude list pointer */
    exclude_path_ptr = options.exclude;

    /* search objects in exclude list */
    while (NULL != exclude_path_ptr)
    {
        /* if exclude path is is group, exclude its members as well */
        if (exclude_path_ptr.obj_type == H5TRAV_TYPE_GROUP)
        {
            ret_cmp = HDstrncmp(exclude_path_ptr.obj_path, path,
                                HDstrlen(exclude_path_ptr.obj_path));
            if (ret_cmp == 0)  /* found matching members */
            {
                size_t len_grp;

                /* check if given path belong to an excluding group, if so 
                 * exclude it as well.
                 * This verifies if “/grp1/dset1” is only under “/grp1”, but
                 * not under “/grp1xxx/” group.  
                 */ 
                len_grp = HDstrlen(exclude_path_ptr.obj_path);
                if (path[len_grp] == '/')
                {
                    /* belong to excluded group! */
                    ret = 1;
                    break;  /* while */
                }
            }
        }
        /* exclude target is not group, just exclude the object */
        else  
        {
            ret_cmp = HDstrcmp(exclude_path_ptr.obj_path, path);
            if (ret_cmp == 0)  /* found matching object */
            {
                /* excluded non-group object */
                ret = 1;
                /* remember the type of this maching object. 
                 * if it's group, it can be used for excluding its member 
                 * objects in this while() loop */
                exclude_path_ptr.obj_type = type;
                break; /* while */
            }
        }
        exclude_path_ptr = exclude_path_ptr.next;
    }

out:
    return  ret;
}


/*-------------------------------------------------------------------------
 * Function: free_exclude_path_list
 *
 * Purpose: free exclud object list from diff options
 *
 * Programmer: Jonathan Kim
 * Date: Aug 23, 2010
 *------------------------------------------------------------------------*/
static void free_exclude_path_list(diff_opt_t *options)
{
    struct exclude_path_list * curr = options.exclude;
    struct exclude_path_list * next;

    while (NULL != curr)
    {
        next = curr.next;
        HDfree(curr);
        curr = next;
    }
}

/*-------------------------------------------------------------------------
 * Function: build_match_list
 *
 * Purpose: get list of matching path_name from info1 and info2
 *
 * Note:
 *  Find common objects; the algorithm used for this search is the
 *  cosequential match algorithm and is described in
 *  Folk, Michael; Zoellick, Bill. (1992). File Structures. Addison-Wesley.
 *  Moved out from diff_match() to make code more flexible.
 *
 * Parameter:
 *  table_out [OUT] : return the list
 *
 * Programmer: Jonathan Kim
 *
 * Date: Aug 18, 2010
 *------------------------------------------------------------------------*/
static void build_match_list (const char *objname1, trav_info_t *info1, const char *objname2, trav_info_t *info2, trav_table_t ** table_out, diff_opt_t *options)
{
    size_t curr1 = 0;
    size_t curr2 = 0;
    unsigned infile[2];
    char * path1_lp;
    char * path2_lp;
    h5trav_type_t type1_l;
    h5trav_type_t type2_l;
    size_t path1_offset = 0;
    size_t path2_offset = 0;
    int cmp;
    trav_table_t *table;
    size_t  idx;

    /* init */
    trav_table_init( &table );

    /*
     * This is necessary for the case that given objects are group and
     * have different names (ex: obj1 is /grp1 and obj2 is /grp5).
     * All the objects belong to given groups are the cadidates.
     * So prepare to compare paths without the group names.
     */

    /* if obj1 is not root */
    if (HDstrcmp (objname1,"/") != 0)
        path1_offset = HDstrlen(objname1);
    /* if obj2 is not root */
    if (HDstrcmp (objname2,"/") != 0)
        path2_offset = HDstrlen(objname2);

    /*--------------------------------------------------
    * build the list
    */
    while(curr1 < info1.nused && curr2 < info2.nused)
    {
        path1_lp = (info1.paths[curr1].path) + path1_offset;
        path2_lp = (info2.paths[curr2].path) + path2_offset;
        type1_l = info1.paths[curr1].type;
        type2_l = info2.paths[curr2].type;
        
        /* criteria is string compare */
        cmp = HDstrcmp(path1_lp, path2_lp);

        if(cmp == 0)
        {
            if(!is_exclude_path(path1_lp, type1_l, options))
            {
                infile[0] = 1;
                infile[1] = 1;
                trav_table_addflags(infile, path1_lp, info1.paths[curr1].type, table);
                /* if the two point to the same target object,
                 * mark that in table */
                if (info1.paths[curr1].fileno == info2.paths[curr2].fileno &&
                    info1.paths[curr1].objno == info2.paths[curr2].objno )
                {
                    idx = table.nobjs - 1;
                    table.objs[idx].is_same_trgobj = 1;
                }
            }
            curr1++;
            curr2++;
        } /* end if */
        else if(cmp < 0)
        {
            if(!is_exclude_path(path1_lp, type1_l, options))
            {
                infile[0] = 1;
                infile[1] = 0;
                trav_table_addflags(infile, path1_lp, info1.paths[curr1].type, table);
            }
            curr1++;
        } /* end else-if */
        else
        {
            if (!is_exclude_path(path2_lp, type2_l, options))
            {
                infile[0] = 0;
                infile[1] = 1;
                trav_table_addflags(infile, path2_lp, info2.paths[curr2].type, table);
            }
            curr2++;
        } /* end else */
    } /* end while */

    /* list1 did not end */
    infile[0] = 1;
    infile[1] = 0;
    while(curr1 < info1.nused)
    {
        path1_lp = (info1.paths[curr1].path) + path1_offset;
        type1_l = info1.paths[curr1].type;

        if(!is_exclude_path(path1_lp, type1_l, options))
        {
            trav_table_addflags(infile, path1_lp, info1.paths[curr1].type, table);
        }
        curr1++;
    } /* end while */

    /* list2 did not end */
    infile[0] = 0;
    infile[1] = 1;
    while(curr2 < info2.nused)
    {
        path2_lp = (info2.paths[curr2].path) + path2_offset;
        type2_l = info2.paths[curr2].type;

        if (!is_exclude_path(path2_lp, type2_l, options))
        {
            trav_table_addflags(infile, path2_lp, info2.paths[curr2].type, table);
        } 
        curr2++;
    } /* end while */

    free_exclude_path_list (options);

    *table_out = table;
}


/*-------------------------------------------------------------------------
 * Function: trav_grp_objs
 *
 * Purpose: 
 *  Call back function from h5trav_visit(). 
 *
 * Programmer: Jonathan Kim
 *
 * Date: Aug 16, 2010
 *------------------------------------------------------------------------*/
static herr_t trav_grp_objs(const char *path, const H5O_info_t *oinfo,
    const char *already_visited, void *udata)
{
    trav_info_visit_obj(path, oinfo, already_visited, udata);

    return 0;
} 

/*-------------------------------------------------------------------------
 * Function: trav_grp_symlinks
 *
 * Purpose: 
 *  Call back function from h5trav_visit(). 
 *  Track and extra checkings while visiting all symbolic-links.
 *
 * Programmer: Jonathan Kim
 *
 * Date: Aug 16, 2010
 *------------------------------------------------------------------------*/
static herr_t trav_grp_symlinks(const char *path, const H5L_info_t *linfo, 
                               void *udata)
{                               
    trav_info_t *tinfo = (trav_info_t *)udata;
    diff_opt_t *opts = (diff_opt_t *)tinfo.opts;
    int ret;
    h5tool_link_info_t lnk_info;
    const char *ext_fname;
    const char *ext_path;

    /* init linkinfo struct */
    HDmemset(&lnk_info, 0, sizeof(h5tool_link_info_t));

    if (!opts.follow_links)
    {
        trav_info_visit_lnk(path, linfo, tinfo);
        goto done;
    }

    switch(linfo.type)
    {
        case H5L_TYPE_SOFT:
            ret = H5tools_get_symlink_info(tinfo.fid, path, &lnk_info, opts.follow_links);
            /* error */
            if (ret < 0)
                goto done;
            /* no dangling link option given and detect dangling link */
            else if (ret == 0)
            {
                tinfo.symlink_visited.dangle_link = true;
                trav_info_visit_lnk(path, linfo, tinfo);
                if (opts.no_dangle_links)
                    opts.err_stat = 1; /* make dgangling link is error */
                goto done;
            }

            /* check if already visit the target object */        
            if(symlink_is_visited( &(tinfo.symlink_visited), linfo.type, NULL, lnk_info.trg_path)) 
                goto done;

            /* add this link as visited link */
            if(symlink_visit_add( &(tinfo.symlink_visited), linfo.type, NULL, lnk_info.trg_path) < 0) 
                goto done;
                    
            if(h5trav_visit(tinfo.fid, path, true, true,
                         trav_grp_objs,trav_grp_symlinks, tinfo) < 0)
            {
                parallel_print("Error: Could not get file contents\n");
                opts.err_stat = 1;
                goto done;
            }
            break;
        
        case H5L_TYPE_EXTERNAL:    
            ret = H5tools_get_symlink_info(tinfo.fid, path, &lnk_info, opts.follow_links);
            /* error */
            if (ret < 0)
                goto done;
            /* no dangling link option given and detect dangling link */
            else if (ret == 0)
            {
                tinfo.symlink_visited.dangle_link = true;
                trav_info_visit_lnk(path, linfo, tinfo);
                if (opts.no_dangle_links)
                    opts.err_stat = 1; /* make dgangling link is error */
                goto done;
            }

            if(H5Lunpack_elink_val(lnk_info.trg_path, linfo.u.val_size, NULL, &ext_fname, &ext_path) < 0) 
                goto done;

            /* check if already visit the target object */        
            if(symlink_is_visited( &(tinfo.symlink_visited), linfo.type, ext_fname, ext_path)) 
                goto done;

            /* add this link as visited link */
            if(symlink_visit_add( &(tinfo.symlink_visited), linfo.type, ext_fname, ext_path) < 0) 
                goto done;
                    
            if(h5trav_visit(tinfo.fid, path, true, true,
                            trav_grp_objs,trav_grp_symlinks, tinfo) < 0)
            {
                parallel_print("Error: Could not get file contents\n");
                opts.err_stat = 1;
                goto done;
            }
            break;

        case H5L_TYPE_HARD:
        case H5L_TYPE_MAX:
        case H5L_TYPE_ERROR:
        default:
            parallel_print("Error: Invalid link type\n");
            opts.err_stat = 1;
            goto done;
            break;
    } /* end of switch */

done:    
    if (lnk_info.trg_path)
        HDfree((char *)lnk_info.trg_path);
    return 0;
}    


/*-------------------------------------------------------------------------
 * Function: h5diff
 *
 * Purpose: public function, can be called in an application program.
 *   return differences between 2 HDF5 files
 *
 * Return: Number of differences found.
 *
 * Programmer: Pedro Vicente, pvn@ncsa.uiuc.edu
 *
 * Date: October 22, 2003
 *
 *-------------------------------------------------------------------------
 */
hsize_t h5diff(const char *fname1,
               const char *fname2,
               const char *objname1,
               const char *objname2,
               diff_opt_t *options)
{
    hid_t        file1_id = (-1);
    hid_t        file2_id = (-1);
    char         filenames[2][MAX_FILENAME];
    hsize_t      nfound = 0;
    int l_ret1 = -1;
    int l_ret2 = -1;
    char * obj1fullname = NULL;
    char * obj2fullname = NULL;
    int both_objs_grp = 0;
    /* init to group type */
    h5trav_type_t obj1type = H5TRAV_TYPE_GROUP;
    h5trav_type_t obj2type = H5TRAV_TYPE_GROUP;
    /* for single object */
    H5O_info_t oinfo1, oinfo2; /* object info */
    trav_info_t  *info1_obj = NULL;
    trav_info_t  *info2_obj = NULL;
    /* for group object */
    trav_info_t  *info1_grp = NULL;
    trav_info_t  *info2_grp = NULL;
    /* local pointer */
    trav_info_t  *info1_lp;
    trav_info_t  *info2_lp;
    /* link info from specified object */
    H5L_info_t src_linfo1;
    H5L_info_t src_linfo2;
    /* link info from member object */
    h5tool_link_info_t trg_linfo1;
    h5tool_link_info_t trg_linfo2;
    /* list for common objects */
    trav_table_t *match_list = NULL;

    /* init filenames */
    HDmemset(filenames, 0, MAX_FILENAME * 2);
    /* init link info struct */
    HDmemset(&trg_linfo1, 0, sizeof(h5tool_link_info_t));
    HDmemset(&trg_linfo2, 0, sizeof(h5tool_link_info_t));

   /*-------------------------------------------------------------------------
    * check invalid combination of options
    *-----------------------------------------------------------------------*/
    if(!is_valid_options(options))
        goto out;

    options.cmn_objs = 1; /* eliminate warning */

    /*-------------------------------------------------------------------------
    * open the files first; if they are not valid, no point in continuing
    *-------------------------------------------------------------------------
    */

    /* disable error reporting */
    H5E_BEGIN_TRY
    {
        /* open file 1 */
        if((file1_id = h5tools_fopen(fname1, H5F_ACC_RDONLY, H5P_DEFAULT, NULL, NULL, (size_t)0)) < 0) 
        {
            parallel_print("h5diff: <%s>: unable to open file\n", fname1);
            options.err_stat = 1;
            goto out;
        } /* end if */


        /* open file 2 */
        if((file2_id = h5tools_fopen(fname2, H5F_ACC_RDONLY, H5P_DEFAULT, NULL, NULL, (size_t)0)) < 0) 
        {
            parallel_print("h5diff: <%s>: unable to open file\n", fname2);
            options.err_stat = 1;
            goto out;
        } /* end if */
    /* enable error reporting */
    } H5E_END_TRY;

    /*-------------------------------------------------------------------------
    * Initialize the info structs
    *-------------------------------------------------------------------------
    */
    trav_info_init(fname1, file1_id, &info1_obj);
    trav_info_init(fname2, file2_id, &info2_obj);

    /* if any object is specified */
    if (objname1)
    {
        /* make the given object1 fullpath, start with "/"  */
        if (HDstrncmp(objname1, "/", 1))
        {
#ifdef H5_HAVE_ASPRINTF
            /* Use the asprintf() routine, since it does what we're trying to do below */
            HDasprintf(&obj1fullname, "/%s", objname1);
#else /* H5_HAVE_ASPRINTF */
            /* (malloc 2 more for "/" and end-of-line) */
            obj1fullname = (char*)HDmalloc(HDstrlen(objname1) + 2);
            HDstrcpy(obj1fullname, "/");
            HDstrcat(obj1fullname, objname1);
#endif /* H5_HAVE_ASPRINTF */
        }
        else
            obj1fullname = HDstrdup(objname1);

        /* make the given object2 fullpath, start with "/" */
        if (HDstrncmp(objname2, "/", 1))
        {
#ifdef H5_HAVE_ASPRINTF
            /* Use the asprintf() routine, since it does what we're trying to do below */
            HDasprintf(&obj2fullname, "/%s", objname2);
#else /* H5_HAVE_ASPRINTF */
            /* (malloc 2 more for "/" and end-of-line) */
            obj2fullname = (char*)HDmalloc(HDstrlen(objname2) + 2);
            HDstrcpy(obj2fullname, "/");
            HDstrcat(obj2fullname, objname2);
#endif /* H5_HAVE_ASPRINTF */
        }
        else
            obj2fullname = HDstrdup(objname2);

        /*----------------------------------------------------------
         * check if obj1 is root, group, single object or symlink
         */
        if(!HDstrcmp(obj1fullname, "/"))
        {
            obj1type = H5TRAV_TYPE_GROUP;
        }
        else
        {
            /* check if link itself exist */
            if(H5Lexists(file1_id, obj1fullname, H5P_DEFAULT) <= 0) 
            {
                parallel_print ("Object <%s> could not be found in <%s>\n", obj1fullname, fname1);
                options.err_stat = 1;
                goto out;
            }
            /* get info from link */
            if(H5Lget_info(file1_id, obj1fullname, &src_linfo1, H5P_DEFAULT) < 0) 
            {
                parallel_print("Unable to get link info from <%s>\n", obj1fullname);
                goto out;
            }

            info1_lp = info1_obj;

            /* 
             * check the type of specified path for hard and symbolic links
             */
            if(src_linfo1.type == H5L_TYPE_HARD)
            {
                size_t idx;

                /* optional data pass */
                info1_obj.opts = (diff_opt_t*)options;

                if(H5Oget_info_by_name(file1_id, obj1fullname, &oinfo1, H5P_DEFAULT) < 0)
                {
                    parallel_print("Error: Could not get file contents\n");
                    options.err_stat = 1;
                    goto out;
                }
                obj1type = (h5trav_type_t)oinfo1.type;
                trav_info_add(info1_obj, obj1fullname, obj1type);
                idx = info1_obj.nused - 1;
                info1_obj.paths[idx].objno = oinfo1.addr;
                info1_obj.paths[idx].fileno = oinfo1.fileno;
            }
            else if (src_linfo1.type == H5L_TYPE_SOFT)
            {
                obj1type = H5TRAV_TYPE_LINK;
                trav_info_add(info1_obj, obj1fullname, obj1type);
            }
            else if (src_linfo1.type == H5L_TYPE_EXTERNAL)
            {
                obj1type = H5TRAV_TYPE_UDLINK;
                trav_info_add(info1_obj, obj1fullname, obj1type);
            }
        }

        /*----------------------------------------------------------
         * check if obj2 is root, group, single object or symlink
         */
        if(!HDstrcmp(obj2fullname, "/"))
        {
            obj2type = H5TRAV_TYPE_GROUP;
        }
        else
        {
            /* check if link itself exist */
            if(H5Lexists(file2_id, obj2fullname, H5P_DEFAULT) <= 0) 
            {
                parallel_print ("Object <%s> could not be found in <%s>\n", obj2fullname, fname2);
                options.err_stat = 1;
                goto out;
            }
            /* get info from link */
            if(H5Lget_info(file2_id, obj2fullname, &src_linfo2, H5P_DEFAULT) < 0) 
            {
                parallel_print("Unable to get link info from <%s>\n", obj2fullname);
                goto out;
            }

            info2_lp = info2_obj;

            /* 
             * check the type of specified path for hard and symbolic links
             */
            if(src_linfo2.type == H5L_TYPE_HARD)
            {
                size_t idx;

                /* optional data pass */
                info2_obj.opts = (diff_opt_t*)options;

                if(H5Oget_info_by_name(file2_id, obj2fullname, &oinfo2, H5P_DEFAULT) < 0)
                {
                    parallel_print("Error: Could not get file contents\n");
                    options.err_stat = 1;
                    goto out;
                }
                obj2type = (h5trav_type_t)oinfo2.type;
                trav_info_add(info2_obj, obj2fullname, obj2type);
                idx = info2_obj.nused - 1;
                info2_obj.paths[idx].objno = oinfo2.addr;
                info2_obj.paths[idx].fileno = oinfo2.fileno;
            }
            else if (src_linfo2.type == H5L_TYPE_SOFT)
            {
                obj2type = H5TRAV_TYPE_LINK;
                trav_info_add(info2_obj, obj2fullname, obj2type);
            }
            else if (src_linfo2.type == H5L_TYPE_EXTERNAL)
            {
                obj2type = H5TRAV_TYPE_UDLINK;
                trav_info_add(info2_obj, obj2fullname, obj2type);
            }
        }           
    }
    /* if no object specified */
    else
    {
        /* set root group */
        obj1fullname = (char*)HDstrdup("/");
        obj1type = H5TRAV_TYPE_GROUP;
        obj2fullname = (char*)HDstrdup("/");
        obj2type = H5TRAV_TYPE_GROUP;
    }


    /* get any symbolic links info */
    l_ret1 = H5tools_get_symlink_info(file1_id, obj1fullname, &trg_linfo1, options.follow_links);
    l_ret2 = H5tools_get_symlink_info(file2_id, obj2fullname, &trg_linfo2, options.follow_links);

    /*---------------------------------------------
     * check for following symlinks 
     */
    if (options.follow_links)
    {
        /* pass how to handle printing warning to linkinfo option */
        if(print_warn(options))
            trg_linfo1.opt.msg_mode = trg_linfo2.opt.msg_mode = 1;

        /*-------------------------------
         * check symbolic link (object1)
         */
        /* dangling link */
        if (l_ret1 == 0)
        {
            if (options.no_dangle_links)
            {
                /* treat dangling link is error */
                if(options.m_verbose)
                    parallel_print("Warning: <%s> is a dangling link.\n", obj1fullname);
                options.err_stat = 1;
                goto out;
            }
            else
            {
                if(options.m_verbose)
                    parallel_print("obj1 <%s> is a dangling link.\n", obj1fullname);
                if (l_ret1 != 0 ||  l_ret2 != 0)
                {
                    nfound++;
                    print_found(nfound);
                    goto out;
                }
            }
        }
        else if(l_ret1 < 0) /* fail */
        {
            parallel_print ("Object <%s> could not be found in <%s>\n", obj1fullname, fname1);
            options.err_stat = 1;
            goto out;
        }
        else if(l_ret1 != 2) /* symbolic link */
        {
            obj1type = (h5trav_type_t)trg_linfo1.trg_type;
            if (info1_lp != NULL) {
                size_t idx = info1_lp.nused - 1;

                info1_lp.paths[idx].type = (h5trav_type_t)trg_linfo1.trg_type;
                info1_lp.paths[idx].objno = trg_linfo1.objno;
                info1_lp.paths[idx].fileno = trg_linfo1.fileno;
            }
        }

        /*-------------------------------
         * check symbolic link (object2)
         */

        /* dangling link */
        if (l_ret2 == 0)
        {
            if (options.no_dangle_links)
            {
                /* treat dangling link is error */
                if(options.m_verbose)
                    parallel_print("Warning: <%s> is a dangling link.\n", obj2fullname);
                options.err_stat = 1;
                goto out;
            }
            else
            {
                if(options.m_verbose)
                    parallel_print("obj2 <%s> is a dangling link.\n", obj2fullname);
                if (l_ret1 != 0 ||  l_ret2 != 0)
                {
                    nfound++;
                    print_found(nfound);
                    goto out;
                }
            }
        }
        else if(l_ret2 < 0) /* fail */ 
        {
            parallel_print ("Object <%s> could not be found in <%s>\n", obj2fullname, fname2);
            options.err_stat = 1;
            goto out;
        }
        else if(l_ret2 != 2)  /* symbolic link */
        {
            obj2type = (h5trav_type_t)trg_linfo2.trg_type;
            if (info2_lp != NULL) {
                size_t idx = info2_lp.nused - 1;

                info2_lp.paths[idx].type = (h5trav_type_t)trg_linfo2.trg_type;
                info2_lp.paths[idx].objno = trg_linfo2.objno;
                info2_lp.paths[idx].fileno = trg_linfo2.fileno;
            }
        }
    } /* end of if follow symlinks */

   /* 
    * If verbose options is not used, don't need to traverse through the list
    * of objects in the group to display objects information,
    * So use h5tools_is_obj_same() to improve performance by skipping 
    * comparing details of same objects. 
    */

    if(!(options.m_verbose || options.m_report))
    {
        /* if no danglink links */
        if ( l_ret1 > 0 && l_ret2 > 0 )
            if (h5tools_is_obj_same(file1_id, obj1fullname, file2_id, obj2fullname)!=0)
                goto out;
    }

    both_objs_grp = (obj1type == H5TRAV_TYPE_GROUP && obj2type == H5TRAV_TYPE_GROUP);
    if (both_objs_grp)
    {
        /*
         * traverse group1
         */
        trav_info_init(fname1, file1_id, &info1_grp);
        /* optional data pass */
        info1_grp.opts = (diff_opt_t*)options;

        if(h5trav_visit(file1_id, obj1fullname, true, true,
                        trav_grp_objs, trav_grp_symlinks, info1_grp) < 0)
        {
            parallel_print("Error: Could not get file contents\n");
            options.err_stat = 1;
            goto out;
        }
        info1_lp = info1_grp;

        /*
         * traverse group2
         */
        trav_info_init(fname2, file2_id, &info2_grp);
        /* optional data pass */
        info2_grp.opts = (diff_opt_t*)options;

        if(h5trav_visit(file2_id, obj2fullname, true, true,
                        trav_grp_objs, trav_grp_symlinks, info2_grp) < 0)
        {
            parallel_print("Error: Could not get file contents\n");
            options.err_stat = 1;
            goto out;
        } /* end if */
        info2_lp = info2_grp;
    }

static if H5_HAVE_PARALLEL
{
    if(g_Parallel)
    {
        int i;

        if((HDstrlen(fname1) > MAX_FILENAME) || (HDstrlen(fname2) > MAX_FILENAME))
        {
            HDfprintf(stderr, "The parallel diff only supports path names up to %d characters\n", MAX_FILENAME);
            MPI_Abort(MPI_COMM_WORLD, 0);
        } /* end if */

        HDstrcpy(filenames[0], fname1);
        HDstrcpy(filenames[1], fname2);

        /* Alert the worker tasks that there's going to be work. */
        foreach(i;1.. g_nTasks)
            MPI_Send(filenames, (MAX_FILENAME * 2), MPI_CHAR, i, MPI_TAG_PARALLEL, MPI_COMM_WORLD);
    } /* end if */
} // H5_HAVE_PARALLEL

    /* process the objects */
    build_match_list (obj1fullname, info1_lp, obj2fullname, info2_lp,
                     &match_list, options);
    if (both_objs_grp)
    {
        /*------------------------------------------------------
         * print the list
         */
         if(options.m_verbose)
         {
             parallel_print("\n");
             /* if given objects is group under root */
             if (HDstrcmp (obj1fullname,"/") || HDstrcmp (obj2fullname,"/"))
                 parallel_print("group1   group2\n");
             else
                 parallel_print("file1     file2\n");
             parallel_print("---------------------------------------\n");
             foreach(u;0.. match_list.nobjs)
             {
                 char c1, c2;
                 c1 = (match_list.objs[u].flags[0]) ? 'x' : ' ';
                 c2 = (match_list.objs[u].flags[1]) ? 'x' : ' ';
                 parallel_print("%5c %6c    %-15s\n", c1, c2, match_list.objs[u].name);
             } /* end for */
             parallel_print ("\n");
         } /* end if */
    }
    nfound = diff_match(file1_id, obj1fullname, info1_lp,
                        file2_id, obj2fullname, info2_lp,
                        match_list, options);

out:
static if H5_HAVE_PARALLEL
{
    if(g_Parallel)
        /* All done at this point, let tasks know that they won't be needed */
        phdiff_dismiss_workers();
}
    /* free buffers in trav_info structures */
    if (info1_obj)
        trav_info_free(info1_obj);
    if (info2_obj)
        trav_info_free(info2_obj);

    if (info1_grp)
        trav_info_free(info1_grp);
    if (info2_grp)
        trav_info_free(info2_grp);

    /* free buffers */
    if (obj1fullname)
        HDfree(obj1fullname);
    if (obj2fullname)
        HDfree(obj2fullname);

    /* free link info buffer */
    if (trg_linfo1.trg_path)
        HDfree((char *)trg_linfo1.trg_path);
    if (trg_linfo2.trg_path)
        HDfree((char *)trg_linfo2.trg_path);

    /* close */
    H5E_BEGIN_TRY
    {
        H5Fclose(file1_id);
        H5Fclose(file2_id);
    } H5E_END_TRY;

    return nfound;
}



/*-------------------------------------------------------------------------
 * Function: diff_match
 *
 * Purpose: 
 *  Compare common objects in given groups according to table structure. 
 *  The table structure has flags which can be used to find common objects 
 *  and will be compared. 
 *  Common object means same name (absolute path) objects in both location.
 *
 * Return: Number of differences found
 *
 * Programmer: Pedro Vicente, pvn@ncsa.uiuc.edu
 *
 * Date: May 9, 2003
 *
 * Modifications: Jan 2005 Leon Arber, larber@uiuc.edu
 *    Added support for parallel diffing
 *
 * Pedro Vicente, pvn@hdfgroup.org, Nov 4, 2008
 *    Compare the graph and make h5diff return 1 for difference if
 * 1) the number of objects in file1 is not the same as in file2
 * 2) the graph does not match, i.e same names (absolute path)
 * 3) objects with the same name are not of the same type
 *-------------------------------------------------------------------------
 */
hsize_t diff_match(hid_t file1_id, const char *grp1, trav_info_t *info1,
                   hid_t file2_id, const char *grp2, trav_info_t *info2,
                   trav_table_t *table, diff_opt_t *options)
{
    hsize_t      nfound = 0;
    
    const char * grp1_path = "";
    const char * grp2_path = "";
    char * obj1_fullpath = NULL;
    char * obj2_fullpath = NULL;
    diff_args_t argdata;
    size_t idx1 = 0;
    size_t idx2 = 0;


    /* 
     * if not root, prepare object name to be pre-appended to group path to
     * make full path
     */
    if(HDstrcmp(grp1, "/"))
        grp1_path = grp1;
    if(HDstrcmp(grp2, "/"))
        grp2_path = grp2;

    /*-------------------------------------------------------------------------
    * regarding the return value of h5diff (0, no difference in files, 1 difference )
    * 1) the number of objects in file1 must be the same as in file2
    * 2) the graph must match, i.e same names (absolute path)
    * 3) objects with the same name must be of the same type
    *-------------------------------------------------------------------------
    */     
       
    /* not valid compare used when --exclude-path option is used */
    if (!options.exclude_path)
    {
        /* number of different objects */
        if ( info1.nused != info2.nused )
        {
            options.contents = 0;
        }
    }
    
    /* objects in one file and not the other */
    foreach(i;0..table.nobjs)
    {
        if( table.objs[i].flags[0] != table.objs[i].flags[1] )
        {
            options.contents = 0;
            break;
        }
    }


    /*-------------------------------------------------------------------------
    * do the diff for common objects
    *-------------------------------------------------------------------------
    */
static if H5_HAVE_PARALLEL
{
    {
    char *workerTasks = (char*)HDmalloc((g_nTasks - 1) * sizeof(char));
    int n;
    int busyTasks = 0;
    struct diffs_found nFoundbyWorker;
    struct diff_mpi_args args;
    int havePrintToken = 1;
    MPI_Status Status;

    /*set all tasks as free */
    HDmemset(workerTasks, 1, (g_nTasks - 1));
}

    foreach(i;0..table.nobjs)
    {
        if( table.objs[i].flags[0] && table.objs[i].flags[1])
        {
            /* make full path for obj1 */
#ifdef H5_HAVE_ASPRINTF
            /* Use the asprintf() routine, since it does what we're trying to do below */
            HDasprintf(&obj1_fullpath, "%s%s", grp1_path, table.objs[i].name);
#else /* H5_HAVE_ASPRINTF */
            obj1_fullpath = (char*)HDmalloc(HDstrlen(grp1_path) + HDstrlen(table.objs[i].name) + 1);
            HDstrcpy(obj1_fullpath, grp1_path);
            HDstrcat(obj1_fullpath, table.objs[i].name);
#endif /* H5_HAVE_ASPRINTF */

            /* make full path for obj2 */
#ifdef H5_HAVE_ASPRINTF
            /* Use the asprintf() routine, since it does what we're trying to do below */
            HDasprintf(&obj2_fullpath, "%s%s", grp2_path, table.objs[i].name);
#else /* H5_HAVE_ASPRINTF */
            obj2_fullpath = (char*)HDmalloc(HDstrlen(grp2_path) + HDstrlen(table.objs[i].name) + 1);
            HDstrcpy(obj2_fullpath, grp2_path);
            HDstrcat(obj2_fullpath, table.objs[i].name);
#endif /* H5_HAVE_ASPRINTF */

            /* get index to figure out type of the object in file1 */
            while(info1.paths[idx1].path && 
                    (HDstrcmp(obj1_fullpath, info1.paths[idx1].path) != 0))
                idx1++;
            /* get index to figure out type of the object in file2 */
            while(info2.paths[idx2].path &&
                    (HDstrcmp(obj2_fullpath, info2.paths[idx2].path) != 0))
                idx2++;

            /* Set argdata to pass other args into diff() */
            argdata.type[0] = info1.paths[idx1].type;
            argdata.type[1] = info2.paths[idx2].type;
            argdata.is_same_trgobj = table.objs[i].is_same_trgobj;

            options.cmn_objs = 1;
            if(!g_Parallel)
            {
                nfound += diff(file1_id, obj1_fullpath,
                               file2_id, obj2_fullpath, 
                               options, &argdata);
            } /* end if */
static if H5_HAVE_PARALLEL
{
            else
            {
                int workerFound = 0;

                /* We're in parallel mode */
                /* Since the data type of diff value is hsize_t which can
                * be arbitary large such that there is no MPI type that
                * matches it, the value is passed between processes as
                * an array of bytes in order to be portable.  But this
                * may not work in non-homogeneous MPI environments.
                */

                /*Set up args to pass to worker task. */
                if(HDstrlen(obj1_fullpath) > 255 || 
                   HDstrlen(obj2_fullpath) > 255)
                {
                    printf("The parallel diff only supports object names up to 255 characters\n");
                    MPI_Abort(MPI_COMM_WORLD, 0);
                } /* end if */

                /* set args struct to pass */
                HDstrcpy(args.name1, obj1_fullpath);
                HDstrcpy(args.name2, obj2_fullpath);
                args.options = *options;
                args.argdata.type[0] = info1.paths[idx1].type;
                args.argdata.type[1] = info2.paths[idx2].type;
                args.argdata.is_same_trgobj = table.objs[i].is_same_trgobj;

                /* if there are any outstanding print requests, let's handle one. */
                if(busyTasks > 0)
                {
                    int incomingMessage;

                    /* check if any tasks freed up, and didn't need to print. */
                    MPI_Iprobe(MPI_ANY_SOURCE, MPI_TAG_DONE, MPI_COMM_WORLD, &incomingMessage, &Status);

                    /* first block*/
                    if(incomingMessage)
                    {
                        workerTasks[Status.MPI_SOURCE - 1] = 1;
                        MPI_Recv(&nFoundbyWorker, sizeof(nFoundbyWorker), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_DONE, MPI_COMM_WORLD, &Status);
                        nfound += nFoundbyWorker.nfound;
                        options.not_cmp = options.not_cmp | nFoundbyWorker.not_cmp;
                        busyTasks--;
                    } /* end if */

                    /* check to see if the print token was returned. */
                    if(!havePrintToken)
                    {
                        /* If we don't have the token, someone is probably sending us output */
                        print_incoming_data();

                        /* check incoming queue for token */
                        MPI_Iprobe(MPI_ANY_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &incomingMessage, &Status);

                        /* incoming token implies free task. */
                        if(incomingMessage) {
                            workerTasks[Status.MPI_SOURCE - 1] = 1;
                            MPI_Recv(&nFoundbyWorker, sizeof(nFoundbyWorker), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &Status);
                            nfound += nFoundbyWorker.nfound;
                            options.not_cmp = options.not_cmp | nFoundbyWorker.not_cmp;
                            busyTasks--;
                            havePrintToken = 1;
                        } /* end if */
                    } /* end if */

                    /* check to see if anyone needs the print token. */
                    if(havePrintToken)
                    {
                        /* check incoming queue for print token requests */
                        MPI_Iprobe(MPI_ANY_SOURCE, MPI_TAG_TOK_REQUEST, MPI_COMM_WORLD, &incomingMessage, &Status);
                        if(incomingMessage)
                        {
                            MPI_Recv(NULL, 0, MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_TOK_REQUEST, MPI_COMM_WORLD, &Status);
                            MPI_Send(NULL, 0, MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_PRINT_TOK, MPI_COMM_WORLD);
                            havePrintToken = 0;
                        } /* end if */
                    } /* end if */
                } /* end if */

                /* check array of tasks to see which ones are free.
                * Manager task never does work, so freeTasks[0] is really
                * worker task 0. */
                for(n = 1; (n < g_nTasks) && !workerFound; n++)
                {
                    if(workerTasks[n-1])
                    {
                        /* send file id's and names to first free worker */
                        MPI_Send(&args, sizeof(args), MPI_BYTE, n, MPI_TAG_ARGS, MPI_COMM_WORLD);

                        /* increment counter for total number of prints. */
                        busyTasks++;

                        /* mark worker as busy */
                        workerTasks[n - 1] = 0;
                        workerFound = 1;
                    } /* end if */
                } /* end for */

                if(!workerFound)
                {
                    /* if they were all busy, we've got to wait for one free up
                     *  before we can move on.  If we don't have the token, some
                     * task is currently printing so we'll wait for that task to
                     * return it.
                     */

                    if(!havePrintToken)
                    {
                        while(!havePrintToken)
                        {
                            int incomingMessage;

                            print_incoming_data();
                            MPI_Iprobe(MPI_ANY_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &incomingMessage, &Status);
                            if(incomingMessage)
                            {
                                MPI_Recv(&nFoundbyWorker, sizeof(nFoundbyWorker), MPI_BYTE, MPI_ANY_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &Status);
                                havePrintToken = 1;
                                nfound += nFoundbyWorker.nfound;
                                options.not_cmp = options.not_cmp | nFoundbyWorker.not_cmp;
                                /* send this task the work unit. */
                                MPI_Send(&args, sizeof(args), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_ARGS, MPI_COMM_WORLD);
                            } /* end if */
                        } /* end while */
                    } /* end if */
                    /* if we do have the token, check for task to free up, or wait for a task to request it */
                    else
                    {
                        /* But first print all the data in our incoming queue */
                        print_incoming_data();
                        MPI_Probe(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &Status);
                        if(Status.MPI_TAG == MPI_TAG_DONE)
                        {
                            MPI_Recv(&nFoundbyWorker, sizeof(nFoundbyWorker), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_DONE, MPI_COMM_WORLD, &Status);
                            nfound += nFoundbyWorker.nfound;
                            options.not_cmp = options.not_cmp | nFoundbyWorker.not_cmp;
                            MPI_Send(&args, sizeof(args), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_ARGS, MPI_COMM_WORLD);
                        } /* end if */
                        else if(Status.MPI_TAG == MPI_TAG_TOK_REQUEST)
                        {
                            int incomingMessage;

                            MPI_Recv(NULL, 0, MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_TOK_REQUEST, MPI_COMM_WORLD, &Status);
                            MPI_Send(NULL, 0, MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_PRINT_TOK, MPI_COMM_WORLD);

                            do
                            {
                                MPI_Iprobe(MPI_ANY_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &incomingMessage, &Status);

                                print_incoming_data();
                            } while(!incomingMessage);

                            MPI_Recv(&nFoundbyWorker, sizeof(nFoundbyWorker), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &Status);
                            nfound += nFoundbyWorker.nfound;
                            options.not_cmp = options.not_cmp | nFoundbyWorker.not_cmp;
                            MPI_Send(&args, sizeof(args), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_ARGS, MPI_COMM_WORLD);
                        } /* end else-if */
                        else
                        {
                            printf("ERROR: Invalid tag (%d) received \n", Status.MPI_TAG);
                            MPI_Abort(MPI_COMM_WORLD, 0);
                            MPI_Finalize();
                        } /* end else */
                    } /* end else */
                } /* end if */
            } /* end else */
} H5_HAVE_PARALLEL
            if(obj1_fullpath)
                HDfree(obj1_fullpath);
            if(obj2_fullpath)                
                HDfree(obj2_fullpath);
        } /* end if */
    } /* end for */

static if H5_HAVE_PARALLEL
{
    if(g_Parallel)
    {
        /* make sure all tasks are done */
        while(busyTasks > 0)
        {
            MPI_Probe(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &Status);
            if(Status.MPI_TAG == MPI_TAG_DONE)
            {
                MPI_Recv(&nFoundbyWorker, sizeof(nFoundbyWorker), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_DONE, MPI_COMM_WORLD, &Status);
                nfound += nFoundbyWorker.nfound;
                options.not_cmp = options.not_cmp | nFoundbyWorker.not_cmp;
                busyTasks--;
            } /* end if */
            else if(Status.MPI_TAG == MPI_TAG_TOK_REQUEST)
            {
                MPI_Recv(NULL, 0, MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_TOK_REQUEST, MPI_COMM_WORLD, &Status);
                if(havePrintToken)
                {
                    int incomingMessage;

                    MPI_Send(NULL, 0, MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_PRINT_TOK, MPI_COMM_WORLD);

                    do {
                        MPI_Iprobe(MPI_ANY_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &incomingMessage, &Status);

                        print_incoming_data();
                    } while(!incomingMessage);

                    MPI_Recv(&nFoundbyWorker, sizeof(nFoundbyWorker), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &Status);
                    nfound += nFoundbyWorker.nfound;
                    options.not_cmp = options.not_cmp | nFoundbyWorker.not_cmp;
                    busyTasks--;
                } /* end if */
                /* someone else must have it...wait for them to return it, then give it to the task that just asked for it. */
                else
                {
                    int source = Status.MPI_SOURCE;
                    int incomingMessage;

                    do
                    {
                        MPI_Iprobe(MPI_ANY_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &incomingMessage, &Status);

                        print_incoming_data();
                    } while(!incomingMessage);


                    MPI_Recv(&nFoundbyWorker, sizeof(nFoundbyWorker), MPI_BYTE, MPI_ANY_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &Status);
                    nfound += nFoundbyWorker.nfound;
                    options.not_cmp = options.not_cmp | nFoundbyWorker.not_cmp;
                    busyTasks--;
                    MPI_Send(NULL, 0, MPI_BYTE, source, MPI_TAG_PRINT_TOK, MPI_COMM_WORLD);
                } /* end else */
            } /* end else-if */
            else if(Status.MPI_TAG == MPI_TAG_TOK_RETURN)
            {
                MPI_Recv(&nFoundbyWorker, sizeof(nFoundbyWorker), MPI_BYTE, Status.MPI_SOURCE, MPI_TAG_TOK_RETURN, MPI_COMM_WORLD, &Status);
                nfound += nFoundbyWorker.nfound;
                options.not_cmp = options.not_cmp | nFoundbyWorker.not_cmp;
                busyTasks--;
                havePrintToken = 1;
            } /* end else-if */
            else if(Status.MPI_TAG == MPI_TAG_PRINT_DATA)
            {
                char  data[PRINT_DATA_MAX_SIZE + 1];
                HDmemset(data, 0, PRINT_DATA_MAX_SIZE + 1);

                MPI_Recv(data, PRINT_DATA_MAX_SIZE, MPI_CHAR, Status.MPI_SOURCE, MPI_TAG_PRINT_DATA, MPI_COMM_WORLD, &Status);

                printf("%s", data);
            } /* end else-if */
            else
            {
                printf("ph5diff-manager: ERROR!! Invalid tag (%d) received \n", Status.MPI_TAG);
                MPI_Abort(MPI_COMM_WORLD, 0);
            } /* end else */
        } /* end while */

        foreach(i;1..g_nTasks)
            MPI_Send(NULL, 0, MPI_BYTE, i, MPI_TAG_END, MPI_COMM_WORLD);

        /* Print any final data waiting in our queue */
        print_incoming_data();
    } /* end if */

    HDfree(workerTasks);
    }
}

    /* free table */
    if (table)
        trav_table_free(table);

    return nfound;
}


/*-------------------------------------------------------------------------
 * Function: diff
 *
 * Purpose: switch between types and choose the diff function
 * TYPE is either
 *  H5G_GROUP         Object is a group
 *  H5G_DATASET       Object is a dataset
 *  H5G_TYPE          Object is a named data type
 *  H5G_LINK          Object is a symbolic link
 *
 * Return: Number of differences found
 *
 * Programmer: Jonathan Kim
 *  - Move follow symlinks code toward top. (March 2812)
 *  - Add following symlinks feature (Feb 11,2010)
 *  - Change to use diff_args_t to pass the rest of args.
 *    Passing through it instead of individual args provides smoother
 *    extensibility through its members along with MPI code update for ph5diff
 *    as it doesn't require interface change.
 *    (May 6,2011)
 *
 * Programmer: Pedro Vicente, pvn@ncsa.uiuc.edu
 * Date: May 9, 2003
 *-------------------------------------------------------------------------
 */

hsize_t diff(hid_t file1_id, const char *path1, hid_t file2_id, const char *path2, diff_opt_t * options, diff_args_t *argdata)
{
    hid_t   dset1_id = (-1);
    hid_t   dset2_id = (-1);
    hid_t   type1_id = (-1);
    hid_t   type2_id = (-1);
    hid_t   grp1_id = (-1);
    hid_t   grp2_id = (-1);
    int     ret;
    hbool_t     is_dangle_link1 = false;
    hbool_t     is_dangle_link2 = false;
    hbool_t     is_hard_link = false;
    hsize_t nfound = 0;
    h5trav_type_t object_type;

    /* to get link info */
    h5tool_link_info_t linkinfo1;
    h5tool_link_info_t linkinfo2;

    /*init link info struct */
    HDmemset(&linkinfo1,0,sizeof(h5tool_link_info_t));
    HDmemset(&linkinfo2,0,sizeof(h5tool_link_info_t));

    /* pass how to handle printing warnings to linkinfo option */
    if(print_warn(options))
        linkinfo1.opt.msg_mode = linkinfo2.opt.msg_mode = 1;

    /* for symbolic links, take care follow symlink and no dangling link 
     * options */
    if (argdata.type[0] == H5TRAV_TYPE_LINK || 
        argdata.type[0] == H5TRAV_TYPE_UDLINK ||
        argdata.type[1] == H5TRAV_TYPE_LINK || 
        argdata.type[1] == H5TRAV_TYPE_UDLINK )
    {
        /* 
         * check dangling links for path1 and path2
         */

        /* target object1 - get type and name */
        ret = H5tools_get_symlink_info(file1_id, path1, &linkinfo1, options.follow_links);
        /* dangling link */
        if (ret == 0)
        {
            if (options.no_dangle_links)
            {
                /* gangling link is error */
                if(options.m_verbose)
                    parallel_print("Warning: <%s> is a dangling link.\n", path1);
                goto out;
            }
            else
                is_dangle_link1 = true;
        }
        else if (ret < 0)
            goto out;

        /* target object2 - get type and name */
        ret = H5tools_get_symlink_info(file2_id, path2, &linkinfo2, options.follow_links );
        /* dangling link */
        if (ret == 0)
        {
            if (options.no_dangle_links)
            {
                /* gangling link is error */
                if(options.m_verbose)
                    parallel_print("Warning: <%s> is a dangling link.\n", path2);
                goto out;
            }
            else
                is_dangle_link2 = true;
        }
        else if (ret < 0)
            goto out;
                    
        /* found dangling link */
        if (is_dangle_link1 || is_dangle_link2)
            goto out2;

        /* follow symbolic link option */
        if (options.follow_links)
        {
            if (linkinfo1.linfo.type == H5L_TYPE_SOFT ||
                    linkinfo1.linfo.type == H5L_TYPE_EXTERNAL)
                argdata.type[0] = (h5trav_type_t)linkinfo1.trg_type;

            if (linkinfo2.linfo.type == H5L_TYPE_SOFT ||
                    linkinfo2.linfo.type == H5L_TYPE_EXTERNAL)
                argdata.type[1] = (h5trav_type_t)linkinfo2.trg_type;
        }
    }
    /* if objects are not the same type */
    if (argdata.type[0] != argdata.type[1])
    {
        if (options.m_verbose||options.m_list_not_cmp)
        {
            parallel_print("Not comparable: <%s> is of type %s and <%s> is of type %s\n",
            path1, get_type(argdata.type[0]), 
            path2, get_type(argdata.type[1]));
        }
        options.not_cmp=1;
        /* TODO: will need to update non-comparable is different
         * options.contents = 0;
         */
        goto out2;
    }
    else /* now both object types are same */
        object_type = argdata.type[0];
  
    /* 
     * If both points to the same target object, skip comparing details inside
     * of the objects to improve performance.
     * Always check for the hard links, otherwise if follow symlink option is 
     * specified.
     *
     * Perform this to match the outputs as bypassing.
     */
     if (argdata.is_same_trgobj)
     {
        is_hard_link = (object_type == H5TRAV_TYPE_DATASET ||
                        object_type == H5TRAV_TYPE_NAMED_DATATYPE ||
                        object_type == H5TRAV_TYPE_GROUP);
        if (options.follow_links || is_hard_link)
        {
            /* print information is only verbose option is used */
            if(options.m_verbose || options.m_report)
            {
                switch(object_type)
                {
                    case H5TRAV_TYPE_DATASET:
                        do_print_objname("dataset", path1, path2, options);
                        break; 
                    case H5TRAV_TYPE_NAMED_DATATYPE:
                        do_print_objname("datatype", path1, path2, options);
                        break;
                    case H5TRAV_TYPE_GROUP:
                        do_print_objname("group", path1, path2, options);
                        break;
                    case H5TRAV_TYPE_LINK:
                        do_print_objname("link", path1, path2, options);
                        break;
                    case H5TRAV_TYPE_UDLINK:
                        if(linkinfo1.linfo.type == H5L_TYPE_EXTERNAL && linkinfo2.linfo.type == H5L_TYPE_EXTERNAL)
                            do_print_objname("external link", path1, path2, options);
                        else
                            do_print_objname ("user defined link", path1, path2, options);
                        break; 
                    case H5TRAV_TYPE_UNKNOWN:
                    default:
                        parallel_print("Comparison not supported: <%s> and <%s> are of type %s\n",
                            path1, path2, get_type(object_type) );
                        options.not_cmp = 1;
                        break;
                } /* switch(type)*/

                print_found(nfound);
            } /* if(options.m_verbose || options.m_report) */

            /* exact same, so comparison is done */
            goto out2;
        }
    }

    switch(object_type)
    {
       /*----------------------------------------------------------------------
        * H5TRAV_TYPE_DATASET
        *----------------------------------------------------------------------
        */
        case H5TRAV_TYPE_DATASET:
            if((dset1_id = H5Dopen2(file1_id, path1, H5P_DEFAULT)) < 0)
                goto out;
            if((dset2_id = H5Dopen2(file2_id, path2, H5P_DEFAULT)) < 0)
                goto out;
      /* verbose (-v) and report (-r) mode */
            if(options.m_verbose || options.m_report)
            {
                do_print_objname("dataset", path1, path2, options);
                nfound = diff_dataset(file1_id, file2_id, path1, path2, options);
                print_found(nfound);
            }
            /* quiet mode (-q), just count differences */
            else if(options.m_quiet)
            {
                nfound = diff_dataset(file1_id, file2_id, path1, path2, options);
            }
      /* the rest (-c, none, ...) */
            else
            {
                nfound = diff_dataset(file1_id, file2_id, path1, path2, options);
                /* print info if difference found  */
                if (nfound)
                {
                    do_print_objname("dataset", path1, path2, options);
                    print_found(nfound);  
                }
            }


            /*---------------------------------------------------------
             * compare attributes
             * if condition refers to cases when the dataset is a 
             * referenced object
             *---------------------------------------------------------
             */
            if(path1)
                nfound += diff_attr(dset1_id, dset2_id, path1, path2, options);


            if(H5Dclose(dset1_id) < 0)
                goto out;
            if(H5Dclose(dset2_id) < 0)
                goto out;
            break;

       /*----------------------------------------------------------------------
        * H5TRAV_TYPE_NAMED_DATATYPE
        *----------------------------------------------------------------------
        */
        case H5TRAV_TYPE_NAMED_DATATYPE:
            if((type1_id = H5Topen2(file1_id, path1, H5P_DEFAULT)) < 0)
                goto out;
            if((type2_id = H5Topen2(file2_id, path2, H5P_DEFAULT)) < 0)
                goto out;

            if((ret = H5Tequal(type1_id, type2_id)) < 0)
                goto out;

            /* if H5Tequal is > 0 then the datatypes refer to the same datatype */
            nfound = (ret > 0) ? 0 : 1;

            if(print_objname(options,nfound))
                do_print_objname("datatype", path1, path2, options);

            /* always print the number of differences found in verbose mode */
            if(options.m_verbose)
                print_found(nfound);

            /*-----------------------------------------------------------------
             * compare attributes
             * the if condition refers to cases when the dataset is a 
             * referenced object
             *-----------------------------------------------------------------
             */
            if(path1)
                nfound += diff_attr(type1_id, type2_id, path1, path2, options);

            if(H5Tclose(type1_id) < 0)
                goto out;
            if(H5Tclose(type2_id) < 0)
                goto out;
            break;

       /*----------------------------------------------------------------------
        * H5TRAV_TYPE_GROUP
        *----------------------------------------------------------------------
        */
        case H5TRAV_TYPE_GROUP:
            if(print_objname(options, nfound))
                do_print_objname("group", path1, path2, options);

            /* always print the number of differences found in verbose mode */
            if(options.m_verbose)
                print_found(nfound);

            if((grp1_id = H5Gopen2(file1_id, path1, H5P_DEFAULT)) < 0)
                goto out;
            if((grp2_id = H5Gopen2(file2_id, path2, H5P_DEFAULT)) < 0)
                goto out;

            /*-----------------------------------------------------------------
             * compare attributes
             * the if condition refers to cases when the dataset is a 
             * referenced object
             *-----------------------------------------------------------------
             */
            if(path1)
                nfound += diff_attr(grp1_id, grp2_id, path1, path2, options);

            if(H5Gclose(grp1_id) < 0)
                goto out;
            if(H5Gclose(grp2_id) < 0)
                goto out;
            break;


       /*----------------------------------------------------------------------
        * H5TRAV_TYPE_LINK
        *----------------------------------------------------------------------
        */
        case H5TRAV_TYPE_LINK:
            {
            ret = HDstrcmp(linkinfo1.trg_path, linkinfo2.trg_path);

            /* if the target link name is not same then the links are "different" */
            nfound = (ret != 0) ? 1 : 0;

            if(print_objname(options, nfound))
                do_print_objname("link", path1, path2, options);

            /* always print the number of differences found in verbose mode */
            if(options.m_verbose)
                print_found(nfound);

            }
            break;

       /*----------------------------------------------------------------------
        * H5TRAV_TYPE_UDLINK
        *----------------------------------------------------------------------
        */
        case H5TRAV_TYPE_UDLINK:
            {
            /* Only external links will have a query function registered */
            if(linkinfo1.linfo.type == H5L_TYPE_EXTERNAL && linkinfo2.linfo.type == H5L_TYPE_EXTERNAL) 
            {
                /* If the buffers are the same size, compare them */
                if(linkinfo1.linfo.u.val_size == linkinfo2.linfo.u.val_size) 
                {
                    ret = HDmemcmp(linkinfo1.trg_path, linkinfo2.trg_path, linkinfo1.linfo.u.val_size);
                }
                else
                    ret = 1;

                /* if "linkinfo1.trg_path" != "linkinfo2.trg_path" then the links
                 * are "different" extlinkinfo#.path is combination string of 
                 * file_name and obj_name
                 */
                nfound = (ret != 0) ? 1 : 0;

                if(print_objname(options, nfound))
                    do_print_objname("external link", path1, path2, options);

            } /* end if */
            else 
            {
                /* If one or both of these links isn't an external link, we can only
                 * compare information from H5Lget_info since we don't have a query
                 * function registered for them.
                 *
                 * If the link classes or the buffer length are not the
                 * same, the links are "different"
                 */
                if((linkinfo1.linfo.type != linkinfo2.linfo.type) || 
                   (linkinfo1.linfo.u.val_size != linkinfo2.linfo.u.val_size))
                    nfound = 1;
                else
                    nfound = 0;

                if (print_objname (options, nfound))
                    do_print_objname ("user defined link", path1, path2, options);
            } /* end else */

            /* always print the number of differences found in verbose mode */
            if(options.m_verbose)
                print_found(nfound);
            }
            break;

        case H5TRAV_TYPE_UNKNOWN:
        default:
            if(options.m_verbose)
                parallel_print("Comparison not supported: <%s> and <%s> are of type %s\n",
                    path1, path2, get_type(object_type) );
            options.not_cmp = 1;
            break;
     }

    /* free link info buffer */
    if (linkinfo1.trg_path)
        HDfree((char *)linkinfo1.trg_path);
    if (linkinfo2.trg_path)
        HDfree((char *)linkinfo2.trg_path);

    return nfound;

out:
    options.err_stat = 1;

out2:
    /*-----------------------------------
     * handle dangling link(s) 
     */
    /* both path1 and path2 are dangling links */
    if(is_dangle_link1 && is_dangle_link2)
    {
        if(print_objname(options, nfound))
        {
            do_print_objname("dangling link", path1, path2, options);
            print_found(nfound);
        }
    }
    /* path1 is dangling link */
    else if (is_dangle_link1)
    {
        if(options.m_verbose)
           parallel_print("obj1 <%s> is a dangling link.\n", path1);
        nfound++;
        if(print_objname(options, nfound))
            print_found(nfound);
    }
    /* path2 is dangling link */
    else if (is_dangle_link2)
    {
        if(options.m_verbose)
            parallel_print("obj2 <%s> is a dangling link.\n", path2);
        nfound++;
        if(print_objname(options, nfound))
            print_found(nfound);
    }

    /* free link info buffer */
    if (linkinfo1.trg_path)
        HDfree((char *)linkinfo1.trg_path);
    if (linkinfo2.trg_path)
        HDfree((char *)linkinfo2.trg_path);

    /* close */
    /* disable error reporting */
    H5E_BEGIN_TRY {
        H5Tclose(type1_id);
        H5Tclose(type2_id);
        H5Gclose(grp1_id);
        H5Tclose(grp2_id);
        /* enable error reporting */
    } H5E_END_TRY;

    return nfound;
}

