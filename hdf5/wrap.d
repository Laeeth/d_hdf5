/**
  hdf5.wrap

  D Language wrappers for the HDF5 Library.  (Paired with a set of lower-level bindings)
  https://github.com/Laeeth/d_hdf5

  No restriction on use beyond those applying from HDF5 and the original C API by Stefan Frijters
  However, if you use them, I would not mind knowing your application and suggestions for
  improvement if you feel like sharing.  laeeth@laeeth.com

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
  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Ported to D by Laeeth Isharc 2014
  Borrowed heavily in terms of C API declarations from https://github.com/SFrijters/hdf5-d
  Stefan Frijters bindings for D

  I do not think these are complete, and I also wanted to begin to work on a higher level D
  interface.  Initially just using strings instead of chars, for example.  And exceptions
  instead of checking status code each time.  Later will add a higher level interface similarly
  to how it is done in h5py.

  Consider this not even alpha stage.  It probably isn't so far away from being useful though.
  This is written for Linux and will need modification to work on other platforms.


  To Do:
    1. Better exception handling that calls HDF5 to get error and returns appropriate Throwable object
    2. Unit tests
    3. Thoughtfulness about using D CFTE/reflection/templating to make it work better - also variants etc
          should be able to pass the data structure not cast(ubyte*)
          should automatically use reflection to deal with structs etc
*/

module hdf5.wrap;
public import core.stdc.stdint;
public import core.sys.posix.sys.types: off_t;
public import core.stdc.time;
public import core.stdc.stdint;
import std.conv;
import std.string;
import std.array;
import std.stdio;
import hdf5.bindings.enums;
import hdf5.bindings.api;
import hdf5.wrap;

void throwOnError(int status)
{
	if (status>=0)
		return;
	else
		throw new Exception("HDF5 error - check message");
}

string ZtoString(const char[] c)
{
    return to!string(fromStringz(cast(char*)c));
}

string ZtoString(const char* c)
{
    return to!string(fromStringz(c));
}

struct H5A
{
  static {
  hid_t create2(hid_t loc_id, string attr_name, hid_t type_id, hid_t space_id, hid_t acpl_id, hid_t aapl_id)
  {
    return H5Acreate2(loc_id,toStringz(attr_name),type_id,space_id,acpl_id,aapl_id);
  }
 
 
  hid_t create_by_name(hid_t loc_id, string obj_name, string attr_name,hid_t type_id, hid_t space_id, hid_t acpl_id, hid_t aapl_id, hid_t lapl_id)

  {
    return H5Acreate_by_name(loc_id,toStringz(obj_name),toStringz(attr_name),type_id,space_id,acpl_id,aapl_id,lapl_id);
  }
 
  hid_t open(hid_t obj_id, string attr_name, hid_t aapl_id)
  {
    return H5Aopen(obj_id,toStringz(attr_name),aapl_id);
  }
 
 
  hid_t open_by_name(hid_t loc_id, string obj_name, string attr_name, hid_t aapl_id, hid_t lapl_id)
  {
    return H5Aopen_by_name(loc_id,toStringz(obj_name), toStringz(attr_name),aapl_id,lapl_id);
  }
 
 
  hid_t open_by_idx(hid_t loc_id, string obj_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t aapl_id, hid_t lapl_id)
  {
    return H5Aopen_by_idx(loc_id,toStringz(obj_name),idx_type,order,n,aapl_id,lapl_id);
  }
 
 
  void write(hid_t attr_id, hid_t type_id, const (ubyte*) buf)
  {
    throwOnError(H5Awrite(attr_id,type_id,buf));
  }
 
 
  void read(hid_t attr_id, hid_t type_id, ubyte* buf)
  {
    throwOnError(H5Aread(attr_id,type_id,buf));
  }
 
 
  void close(hid_t attr_id)
  {
    throwOnError( H5Aclose(attr_id));
  }
 
 
  hid_t get_space(hid_t attr_id)
  {
    return H5Aget_space(attr_id);
  }
 
 
  hid_t get_type(hid_t attr_id)
  {
    return H5Aget_type(attr_id);
  }
 
 
  hid_t get_create_plist(hid_t attr_id)
  {
    return   H5Aget_create_plist(attr_id);
  }
 
 
  string get_name(hid_t attr_id)
  {
    char[2048] buf;
    if (H5Aget_name(attr_id,buf.length,cast(char*)buf)<=0)
      return "";
    else
      return ZtoString(buf[]);
  }
 
 
  string get_name_by_idx(hid_t loc_id, string obj_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id)
  {
    char[2048] buf;
    if (H5Aget_name_by_idx(loc_id,toStringz(obj_name),idx_type,order,n,cast(char*)buf,buf.length,lapl_id)<=0)
      return "";
    else
      return ZtoString(buf[]);
  }
 
 
  hsize_t get_storage_size(hid_t attr_id)
  {
    return H5Aget_storage_size(attr_id);
  }
 
 
  void get_info(hid_t attr_id, H5A_info_t *ainfo /*out*/)
  {
    throwOnError( H5Aget_info(attr_id,ainfo));
  }
 
 
  void get_info_by_name(hid_t loc_id, string obj_name, string attr_name, H5A_info_t *ainfo /*out*/, hid_t lapl_id)
  {
    throwOnError( H5Aget_info_by_name(loc_id,toStringz(obj_name),toStringz(attr_name),ainfo,lapl_id));
  }
 
 
  void get_info_by_idx(hid_t loc_id, string obj_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5A_info_t *ainfo /*out*/, hid_t lapl_id)
  {
    throwOnError( H5Aget_info_by_idx(loc_id,toStringz(obj_name),idx_type,order,n,ainfo,lapl_id));
  }
 
 
  void rename(hid_t loc_id, string old_name, string new_name)
  {
    throwOnError( H5Arename(loc_id,toStringz(old_name),toStringz(new_name)));
  }
 
 
  void rename_by_name(hid_t loc_id, string obj_name, string old_attr_name, string new_attr_name, hid_t lapl_id)
  {
    throwOnError( H5Arename_by_name(loc_id,toStringz(obj_name),toStringz(old_attr_name),toStringz(new_attr_name),lapl_id));
  }
 
 
  void iterate2(hid_t loc_id, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5A_operator2_t op, void *op_data)
  {
    throwOnError(H5Aiterate2(loc_id,idx_type,order,idx,op,op_data));
  }
 
  void iterate_by_name(hid_t loc_id, string obj_name, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5A_operator2_t op, void *op_data, hid_t lapd_id)
  {
    throwOnError(H5Aiterate_by_name(loc_id, toStringz(obj_name),idx_type,order,idx, op,op_data,lapd_id));
  }
 
  void h5delete(hid_t loc_id, string name)
  {
    throwOnError( H5Adelete(loc_id,toStringz(name)));
  }
 
 
  void delete_by_name(hid_t loc_id, string obj_name, string attr_name, hid_t lapl_id)
  {
    throwOnError( H5Adelete_by_name(loc_id,toStringz(obj_name),toStringz(attr_name),lapl_id));
  }
 
 
  void delete_by_idx(hid_t loc_id, string obj_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id)
  {
    throwOnError( H5Adelete_by_idx(loc_id,toStringz(obj_name),idx_type,order,n,lapl_id));
  }
 
 
  htri_t exists(hid_t obj_id, string attr_name)
  {
    return H5Aexists(obj_id,toStringz(attr_name));
  }
 
 
  htri_t exists_by_name(hid_t obj_id, string obj_name, string attr_name, hid_t lapl_id)
  {
    return H5Aexists_by_name(obj_id,toStringz(obj_name),toStringz(attr_name),lapl_id);
  }
  } // static
}


struct H5D
{
  static
  {
// alias - hope it is correct!
  hid_t create2(hid_t loc_id, string name, hid_t type_id, hid_t space_id, hid_t lcpl_id, hid_t dcpl_id, hid_t dapl_id)
  {
    return H5Dcreate2(loc_id, toStringz(name), type_id,  space_id,  lcpl_id,  dcpl_id, dapl_id);
  }

  hid_t create_anon(hid_t file_id, hid_t type_id, hid_t space_id, hid_t plist_id, hid_t dapl_id)
  {
    return H5Dcreate_anon( file_id,  type_id,  space_id,  plist_id,  dapl_id);
  }
  hid_t open2(hid_t file_id, string name, hid_t dapl_id)
  {
    return H5Dopen2( file_id, toStringz(name), dapl_id);
  }
  void close(hid_t dset_id)
  {
    throwOnError(H5Dclose(dset_id));    
  }
  hid_t get_space(hid_t dset_id)
  {
      return H5Dget_space(dset_id);
  }
  H5DSpaceStatus get_space_status(hid_t dset_id)
  {
    H5DSpaceStatus allocation;
    throwOnError(H5Dget_space_status(dset_id, &allocation));
    return allocation;
  }
  hid_t get_type(hid_t dset_id)
  {
    return H5Dget_type(dset_id);
  }
  
  hid_t get_create_plist(hid_t dset_id)
  {
      return H5Dget_create_plist(dset_id);
  }
  hid_t get_access_plist(hid_t dset_id)
  {
      return H5Dget_access_plist(dset_id);
  }
  hsize_t get_storage_size(hid_t dset_id)
  {
    return H5Dget_storage_size(dset_id);
  }
  haddr_t get_offset(hid_t dset_id)
  {
      return H5Dget_offset(dset_id);
  }
  void read(hid_t dset_id, hid_t mem_type_id, hid_t mem_space_id, hid_t file_space_id, hid_t plist_id, ubyte* buf/*out*/)
  {
      throwOnError(H5Dread(dset_id, mem_type_id, mem_space_id, file_space_id, plist_id,cast(void*)buf/*out*/));
  }
  void write(hid_t dset_id, hid_t mem_type_id, hid_t mem_space_id, hid_t file_space_id, hid_t plist_id, ubyte* buf)
  {
    throwOnError(H5Dwrite(dset_id, mem_type_id, mem_space_id, file_space_id, plist_id,cast(void*)buf));
  }

  void iterate(void *buf, hid_t type_id, hid_t space_id, H5D_operator_t op, void *operator_data)
  {
    throwOnError(H5Diterate(buf,type_id,  space_id, op,operator_data));
  }
  void vlen_reclaim(hid_t type_id, hid_t space_id, hid_t plist_id, void *buf)
  {
      throwOnError(H5Dvlen_reclaim(type_id,  space_id, plist_id, buf));
  }
  void vlen_get_buf_size(hid_t dataset_id, hid_t type_id, hid_t space_id, hsize_t *size)
  {
      throwOnError(H5Dvlen_get_buf_size( dataset_id, type_id, space_id,size));
  }      
  void fill(const void *fill, hid_t fill_type, void *buf, hid_t buf_type, hid_t space)
  {
    throwOnError(H5Dfill(fill, fill_type, buf, buf_type, space));
  }

  void set_extent(hid_t dset_id, const hsize_t[] size)
  {
      throwOnError(H5Dset_extent(dset_id, cast(hsize_t*)size));
  }
  void scatter(H5D_scatter_func_t op, void *op_data, hid_t type_id, hid_t dst_space_id, void *dst_buf)
  {
    throwOnError(H5Dscatter(op, op_data, type_id,  dst_space_id, dst_buf));
  }
  void gather(hid_t src_space_id, const void *src_buf, hid_t type_id, size_t dst_buf_size, void *dst_buf, H5D_gather_func_t op, void *op_data)
  {
       throwOnError(H5Dgather(src_space_id, src_buf, type_id, dst_buf_size,dst_buf, op, op_data));
  }
  void h5debug(hid_t dset_id)
  {
    throwOnError(H5Ddebug(dset_id));
  }
  }// static
}

struct H5F
{
  static
  {
  htri_t is_hdf5(string filename)
  {
    return H5Fis_hdf5(toStringz(filename));
  }

  hid_t create(string filename, uint flags, hid_t create_plist, hid_t access_plist)
  {
    return H5Fcreate(toStringz(filename),flags,create_plist,access_plist);
  }

  hid_t open(string filename, uint flags, hid_t access_plist)
  {
    return H5Fopen(toStringz(filename),flags,access_plist);
  }


  hid_t reopen(hid_t file_id)
  {
    return H5Freopen(file_id);
  }


  void flush(hid_t object_id, H5F_scope_t _scope)
  {
    throwOnError(H5Fflush(object_id,_scope));
  }


  void close(hid_t file_id)
  {
    throwOnError(H5Fclose(file_id));
  }


  hid_t get_create_plist(hid_t file_id)
  {
    return H5Fget_create_plist(file_id);
  }


  hid_t get_access_plist(hid_t file_id)
  {
    return H5Fget_access_plist(file_id);
  }


  void get_intent(hid_t file_id, uint * intent)
  {
    throwOnError(H5Fget_intent(file_id,intent));
  }


  ssize_t get_obj_count(hid_t file_id, uint types)
  {
    return H5Fget_obj_count(file_id,types);
  }


  ssize_t get_obj_ids(hid_t file_id, uint types, size_t max_objs, hid_t *obj_id_list)
  {
    return H5Fget_obj_ids(file_id,types,max_objs,obj_id_list);
  }


  void get_vfd_handle(hid_t file_id, hid_t fapl, void **file_handle)
  {
    throwOnError(H5Fget_vfd_handle(file_id,fapl,file_handle));
  }


  void mount(hid_t loc, string name, hid_t child, hid_t plist)
  {
    throwOnError(H5Fmount(loc,toStringz(name),child,plist));
  }


  void unmount(hid_t loc, string name)
  {
    throwOnError(H5Funmount(loc,toStringz(name)));
  }


  hssize_t get_freespace(hid_t file_id)
  {
    return H5Fget_freespace(file_id);
  }


  void get_filesize(hid_t file_id, hsize_t *size)
  {
    throwOnError(H5Fget_filesize(file_id,size));
  }


  ssize_t get_file_image(hid_t file_id, void * buf_ptr, size_t buf_len)
  {
    return H5Fget_file_image(file_id,buf_ptr,buf_len);
  }


  void get_mdc_hit_rate(hid_t file_id, double * hit_rate_ptr)
  {
    throwOnError(H5Fget_mdc_hit_rate(file_id,hit_rate_ptr));
  }


  void get_mdc_size(hid_t file_id, size_t * max_size_ptr, size_t * min_clean_size_ptr, size_t * cur_size_ptr, int * cur_num_entries_ptr)
  {
    throwOnError(H5Fget_mdc_size(file_id,max_size_ptr,min_clean_size_ptr,cur_size_ptr,cur_num_entries_ptr));
  }


  void reset_mdc_hit_rate_stats(hid_t file_id)
  {
    throwOnError(H5Freset_mdc_hit_rate_stats(file_id));
  }


  ssize_t get_name(hid_t obj_id, char *name, size_t size)
  {
    return H5Fget_name(obj_id,name,size);
  }


  void get_info(hid_t obj_id, H5F_info_t *bh_info)
  {
    throwOnError(H5Fget_info(obj_id,bh_info));
  }


  void clear_elink_file_cache(hid_t file_id)
  {
    throwOnError(H5Fclear_elink_file_cache(file_id));
  }


  version(h5parallel)
  {
    void set_mpi_atomicity(hid_t file_id, hbool_t flag)
    {
      throwOnError(H5Fset_mpi_atomicity(file_id,flag));
    }


    void get_mpi_atomicity(hid_t file_id, hbool_t *flag)
    {
      throwOnError(H5Fget_mpi_atomicity(file_id,flag));
    }
  }
  }// static
}

struct H5G
{
  static
  {
  hid_t create2(hid_t loc_id, string name, hid_t lcpl_id, hid_t gcpl_id, hid_t gapl_id)
  {
    return H5Gcreate2(loc_id,toStringz(name),lcpl_id,gcpl_id,gapl_id);
  }
 
  hid_t create_anon(hid_t loc_id, hid_t gcpl_id, hid_t gapl_id)
  {
    return H5Gcreate_anon(loc_id,gcpl_id,gapl_id);
  }
 
 
  hid_t open2(hid_t loc_id, string name, hid_t gapl_id)
  {
    return H5Gopen2(loc_id,toStringz(name),gapl_id);
  }
 
 
  hid_t get_create_plist(hid_t group_id)
  {
    return H5Gget_create_plist(group_id);
  }
 
 
  void get_info(hid_t loc_id, H5GInfo *ginfo)
  {
    throwOnError(H5Gget_info(loc_id,ginfo));
  }
 
 
  void get_info_by_name(hid_t loc_id, string name, H5GInfo *ginfo, hid_t lapl_id)
  {
    throwOnError(H5Gget_info_by_name(loc_id,toStringz(name),ginfo,lapl_id));
  }
 
 
  void get_info_by_idx(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5GInfo *ginfo, hid_t lapl_id)
  {
    throwOnError(H5Gget_info_by_idx(loc_id,toStringz(group_name),idx_type,order,n,ginfo,lapl_id));
  }
 
 
  void close(hid_t group_id)
  {
    throwOnError(H5Gclose(group_id));
  }
  }//static
}
 
struct H5I
{
  static
  {
  hid_t register(H5IType type, const void *object)
  {
    return H5Iregister(type,object);
  }
 
 
  void *object_verify(hid_t id, H5IType id_type)
  {
    return H5Iobject_verify(id,id_type);
  }
 
 
  void *remove_verify(hid_t id, H5IType id_type)
  {
    return H5Iremove_verify(id,id_type);
  }
 
 
  H5IType get_type(hid_t id)
  {
    return H5Iget_type(id);
  }
 
 
  hid_t get_file_id(hid_t id)
  {
    return H5Iget_file_id(id);
  }
 
 
  string get_name(hid_t id)
  {
    char[2048] buf;
    if(H5Iget_name(id,cast(char*)buf,buf.length)<=0)
      return "";
    else
      return ZtoString(buf[]);
  }
 
 
  int inc_ref(hid_t id)
  {
    return H5Iinc_ref(id);
  }
 
 
  int dec_ref(hid_t id)
  {
    return H5Idec_ref(id);
  }
 
 
  int get_ref(hid_t id)
  {
    return H5Iget_ref(id);
  }
 
 
  H5IType register_type(size_t hash_size, uint reserved, H5I_free_t free_func)
  {
    return H5Iregister_type(hash_size,reserved,free_func);
  }
 
 
  void clear_type(H5IType type, hbool_t force)
  {
    throwOnError(H5Iclear_type(type,force));
  }
 
 
  void destroy_type(H5IType type)
  {
    throwOnError(H5Idestroy_type(type));
  }
 
 
  int inc_type_ref(H5IType type)
  {
    return H5Iinc_type_ref(type);
  }
 
 
  int dec_type_ref(H5IType type)
  {
    return H5Idec_type_ref(type);
  }
 
 
  int get_type_ref(H5IType type)
  {
    return H5Iget_type_ref(type);
  }
 
 
  void *H5Isearch(H5IType type, H5I_search_func_t func, void *key)
  {
    return H5Isearch(type,func,key);
  }
 
 
  void nmembers(H5IType type, hsize_t *num_members)
  {
    throwOnError(H5Inmembers(type,num_members));
  }
 
 
  htri_t type_exists(H5IType type)
  {
    return H5Itype_exists(type);
  }
 
 
  htri_t is_valid(hid_t id)
  {
    return H5Iis_valid(id);
  }
  }//static
}
struct H5L
{
  static {
  void move(hid_t src_loc, string src_name, hid_t dst_loc, string dst_name, hid_t lcpl_id, hid_t lapl_id)
  {
    throwOnError(H5Lmove(src_loc,toStringz(src_name),dst_loc,toStringz(dst_name),lcpl_id,lapl_id));
  }
 
 
  void copy(hid_t src_loc, string src_name, hid_t dst_loc, string dst_name, hid_t lcpl_id, hid_t lapl_id)
  {
    throwOnError(H5Lcopy(src_loc,toStringz(src_name),dst_loc,toStringz(dst_name),lcpl_id,lapl_id));
  }
 
 
  void create_hard(hid_t cur_loc, string cur_name, hid_t dst_loc, string dst_name, hid_t lcpl_id, hid_t lapl_id)
  {
    throwOnError(H5Lcreate_hard(cur_loc,toStringz(cur_name),dst_loc,toStringz(dst_name),lcpl_id,lapl_id));
  }
 
 
  void create_soft(string link_target, hid_t link_loc_id, string link_name, hid_t lcpl_id, hid_t lapl_id)
  {
    throwOnError(H5Lcreate_soft(toStringz(link_target),link_loc_id,toStringz(link_name),lcpl_id,lapl_id));
  }
 
 
  void h5delete(hid_t loc_id, string name, hid_t lapl_id)
  {
    throwOnError(H5Ldelete(loc_id,toStringz(name),lapl_id));
  }
 
 
  void delete_by_idx(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id)
  {
    throwOnError(H5Ldelete_by_idx(loc_id,toStringz(group_name), idx_type,order,n,lapl_id));
  }
 
 
  void get_val(hid_t loc_id, string name, void *buf/*out*/, size_t size, hid_t lapl_id)
  {
    throwOnError(H5Lget_val( loc_id,toStringz(name), buf/*out*/,  size, lapl_id));
  }
 
 
  void get_val_by_idx(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, hsize_t n, void *buf/*out*/, size_t size, hid_t lapl_id)
  {
    throwOnError(H5Lget_val_by_idx(loc_id,toStringz(group_name),idx_type,order,n,buf/*out*/,size,lapl_id));
  }
 
 
  htri_t exists(hid_t loc_id, string name, hid_t lapl_id)
  {
    return H5Lexists(loc_id,toStringz(name),lapl_id);
  }
 
 
  void get_info_by_idx(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5LInfo *linfo /*out*/, hid_t lapl_id)
  {
    throwOnError(H5Lget_info_by_idx(loc_id,toStringz(group_name),idx_type,order,n,linfo,lapl_id));
  }
 
 
  string get_name_by_idx(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id)
  {
    char[2048] buf;
    if (H5Lget_name_by_idx(loc_id,toStringz(group_name),idx_type,order,n,cast(char*)buf,buf.length,lapl_id)<=0)
      return "";
    else
    {
      return ZtoString(buf[]);
    }
  }
 
  void iterate(hid_t grp_id, H5Index idx_type, H5IterOrder order,H5L_iterate_t op)
  {
    throwOnError(H5Literate(grp_id,idx_type,order,cast(hsize_t*)0,op,cast(void*)0));
  }
 
  void iterate(hid_t grp_id, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5L_iterate_t op, void *op_data)
  {
    throwOnError(H5Literate(grp_id,idx_type,order,idx,op,op_data));
  }
 
  void iterate_by_name(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, H5L_iterate_t op, hid_t lapl_id)
  {
    throwOnError(H5Literate_by_name(loc_id,toStringz(group_name),idx_type,order,cast(hsize_t*)0,op,cast(void*)0,lapl_id));
  }

 
  void iterate_by_name(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, hsize_t *idx, H5L_iterate_t op, void *op_data, hid_t lapl_id)
  {
    throwOnError(H5Literate_by_name(loc_id,toStringz(group_name),idx_type,order,idx,op,op_data,lapl_id));
  }

  void visit(hid_t grp_id, H5Index idx_type, H5IterOrder order, H5L_iterate_t op, void *op_data)
  {
    throwOnError(H5Lvisit(grp_id, idx_type, order,op, op_data));
  }
  
  void visit_by_name(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, H5L_iterate_t op, void *op_data, hid_t lapl_id)
  {
    throwOnError(H5Lvisit_by_name(loc_id,toStringz(group_name),idx_type,order,op,op_data,lapl_id));
  }
 
  void create_ud(hid_t link_loc_id, string link_name, H5LType link_type, const void *udata, size_t udata_size, hid_t lcpl_id, hid_t lapl_id)
  {
    throwOnError(H5Lcreate_ud(link_loc_id,toStringz(link_name),link_type,udata,udata_size,lcpl_id,lapl_id));
  }
 
 
  void register(const H5L_class_t *cls)
  {
    throwOnError(H5Lregister(cls));
  }
 
 
  void unregister(H5LType id)
  {
    throwOnError(H5Lunregister(id));
  }
 
 
  htri_t is_registered(H5LType id)
  {
    return H5Lis_registered(id);
  }
 
 
  string[2] unpack_elink_val(const void *ext_linkval/*in*/, size_t link_size, uint *flags)
  {
    char *filename;
    char *obj_path;
    throwOnError(H5Lunpack_elink_val(ext_linkval, link_size,flags,&filename,&obj_path));
    return [ZtoString(filename),ZtoString(obj_path)];
  }
 
 
  void create_external(string file_name, string obj_name, hid_t link_loc_id, string link_name, hid_t lcpl_id, hid_t lapl_id)
  {
    throwOnError(H5Lcreate_external(toStringz(file_name),toStringz(obj_name),link_loc_id,toStringz(link_name),lcpl_id,lapl_id));
  }
  }//static
}
 
struct H5O
{
  static
  {
  hid_t open(hid_t loc_id, string name, hid_t lapl_id)
  {
    return H5Oopen(loc_id,toStringz(name),lapl_id);
  }
 
  hid_t open_by_addr(hid_t loc_id, haddr_t addr)
  {
    return H5Oopen_by_addr(loc_id,addr);
  }
 
  hid_t open_by_idx(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, hsize_t n, hid_t lapl_id)
  {
    return H5Oopen_by_idx(loc_id,toStringz(group_name),idx_type,order,n,lapl_id);
  }
 
  htri_t exists_by_name(hid_t loc_id, string name, hid_t lapl_id)
  {
    return H5Oexists_by_name(loc_id,toStringz(name),lapl_id);
  }
 
  void get_info(hid_t loc_id, H5OInfo  *oinfo)
  {
    throwOnError(H5Oget_info(loc_id,oinfo));
  }
 
  void get_info_by_name(hid_t loc_id, string name, H5OInfo  *oinfo, hid_t lapl_id)
  {
    //writefln("getinfobyname: %s",name);
    throwOnError(H5Oget_info_by_name(loc_id,toStringz(name),oinfo,lapl_id));
    //writefln("passed throw");
  }
 
 
  void get_info_by_idx(hid_t loc_id, string group_name, H5Index idx_type, H5IterOrder order, hsize_t n, H5OInfo  *oinfo, hid_t lapl_id)
  {
    throwOnError(H5Oget_info_by_idx(loc_id,toStringz(group_name),idx_type,order,n,oinfo,lapl_id));
  }
 
  void link(hid_t obj_id, hid_t new_loc_id, string new_name, hid_t lcpl_id, hid_t lapl_id)
  {
    throwOnError(H5Olink(obj_id,new_loc_id,toStringz(new_name),lcpl_id,lapl_id));
  }
 
 
  void incr_refcount(hid_t object_id)
  {
    throwOnError(H5Oincr_refcount(object_id));
  }
 
 
  void decr_refcount(hid_t object_id)
  {
    throwOnError(H5Odecr_refcount(object_id));
  }
 
 
  void copy(hid_t src_loc_id, string src_name, hid_t dst_loc_id, string dst_name, hid_t ocpypl_id, hid_t lcpl_id)
  {
    throwOnError(H5Ocopy(src_loc_id,toStringz(src_name),dst_loc_id,toStringz(dst_name),ocpypl_id,lcpl_id));
  }
 
 
  void set_comment(hid_t obj_id, string comment)
  {
    throwOnError(H5Oset_comment(obj_id,toStringz(comment)));
  }
 
 
  void set_comment_by_name(hid_t loc_id, string name, string comment, hid_t lapl_id)
  {
    throwOnError(H5Oset_comment_by_name(loc_id,toStringz(name),toStringz(comment),lapl_id));
  }
 
 
  string get_comment(hid_t obj_id)
  {
    char[2048] buf;
    if (H5Oget_comment(obj_id,cast(char*)buf,buf.length)<=0)
      return "";
    else
      return ZtoString(buf[]);
  }
 
 
  string get_comment_by_name(hid_t loc_id, string name, hid_t lapl_id)
  {
    char[2048] buf;
    if (H5Oget_comment_by_name(loc_id,toStringz(name),cast(char*)buf,buf.length,lapl_id)<=0)
      return "";
    else
      return ZtoString(buf[]);
  }
 
 
  void visit(hid_t obj_id, H5Index idx_type, H5IterOrder order, H5O_iterate_t op, void *op_data)
  {
    throwOnError(H5Ovisit(obj_id,idx_type,order,op,op_data));
  }
 
 
  void visit_by_name(hid_t loc_id, string obj_name, H5Index idx_type, H5IterOrder order, H5O_iterate_t op, void *op_data, hid_t lapl_id)
  {
    throwOnError(H5Ovisit_by_name(loc_id,toStringz(obj_name),idx_type,order,op,op_data,lapl_id));
  }
 
 
  void close(hid_t object_id)
  {
    throwOnError(H5Oclose(object_id));
  }
  }//static
}
 
struct H5P
{
  static
  {
    hid_t create_class(hid_t parent, string name, H5P_cls_create_func_t cls_create, void *create_data, H5P_cls_copy_func_t cls_copy, void *copy_data, H5P_cls_close_func_t cls_close, void *close_data)
  {
    return H5Pcreate_class(parent,toStringz(name),cls_create,create_data,cls_copy,copy_data,cls_close,close_data);
  }
 
 
  string get_class_name(hid_t pclass_id)
  {
    return ZtoString(H5Pget_class_name(pclass_id));
  }
 
 
  hid_t create(hid_t cls_id)
  {
    return H5Pcreate(cls_id);
  }
 
 
  void register2(hid_t cls_id, string name, size_t size, void *def_value, H5P_prp_create_func_t prp_create, H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get, H5P_prp_delete_func_t prp_del, H5P_prp_copy_func_t prp_copy, H5P_prp_compare_func_t prp_cmp, H5P_prp_close_func_t prp_close)
  {
    throwOnError(H5Pregister2(cls_id,toStringz(name),size,def_value,prp_create,prp_set,prp_get,prp_del,prp_copy,prp_cmp,prp_close));
  }
 
 
  void insert2(hid_t plist_id, string name, size_t size, void *value, H5P_prp_set_func_t prp_set, H5P_prp_get_func_t prp_get, H5P_prp_delete_func_t prp_delete, H5P_prp_copy_func_t prp_copy, H5P_prp_compare_func_t prp_cmp, H5P_prp_close_func_t prp_close)
  {
    throwOnError(H5Pinsert2(plist_id,toStringz(name),size,value,prp_set,prp_get,prp_delete,prp_copy,prp_cmp,prp_close));
  }
 
 
  void set(hid_t plist_id, string name, string value)
  {
    void *buf=cast(void*)toStringz(value);
    throwOnError(H5Pset(plist_id,toStringz(name),buf));
  }
 
 
  htri_t exist(hid_t plist_id, string name)
  {
    return H5Pexist(plist_id,toStringz(name));
  }
 
 
  size_t get_size(hid_t id, string name)
  {
    size_t size;
    throwOnError(H5Pget_size(id,toStringz(name),&size));
    return size;
  }
 
 
  size_t get_nprops(hid_t id)
  {
    size_t nprop;
    throwOnError(H5Pget_nprops(id,&nprop));
    return nprop;
  }
 
 
  hid_t get_class(hid_t plist_id)
  {
    return H5Pget_class(plist_id);
  }
 
 
  hid_t get_class_parent(hid_t pclass_id)
  {
    return H5Pget_class_parent(pclass_id);
  }
 
 
  void get(hid_t plist_id, string name, void * value)
  {
    throwOnError(H5Pget(plist_id,toStringz(name),value));
  }
 
 
  htri_t equal(hid_t id1, hid_t id2)
  {
    return H5Pequal(id1,id2);
  }
 
 
  htri_t isa_class(hid_t plist_id, hid_t pclass_id)
  {
    return H5Pisa_class(plist_id,pclass_id);
  }
 
 
  int iterate(hid_t id, int *idx, H5P_iterate_t iter_func, void *iter_data)
  {
    return H5Piterate(id,idx,iter_func,iter_data);
  }
 
 
  void copy_prop(hid_t dst_id, hid_t src_id, string name)
  {
    throwOnError(H5Pcopy_prop(dst_id,src_id,toStringz(name)));
  }
 
 
  void remove(hid_t plist_id, string name)
  {
    throwOnError(H5Premove(plist_id,toStringz(name)));
  }
 
 
  void unregister(hid_t pclass_id, string name)
  {
    throwOnError(H5Punregister(pclass_id,toStringz(name)));
  }
 
 
  void close_class(hid_t plist_id)
  {
    throwOnError(H5Pclose_class(plist_id));
  }
 
 
  void close(hid_t plist_id)
  {
    throwOnError(H5Pclose(plist_id));
  }
 
 
  hid_t copy(hid_t plist_id)
  {
    return H5Pcopy(plist_id);
  }
 
 
  void set_attr_phase_change(hid_t plist_id, uint max_compact, uint min_dense)
  {
    throwOnError(H5Pset_attr_phase_change(plist_id,max_compact,min_dense));
  }
 
 
  void get_attr_phase_change(hid_t plist_id, uint *max_compact, uint *min_dense)
  {
    throwOnError(H5Pget_attr_phase_change(plist_id,max_compact,min_dense));
  }
 
 
  void set_attr_creation_order(hid_t plist_id, uint crt_order_flags)
  {
    throwOnError(H5Pset_attr_creation_order(plist_id,crt_order_flags));
  }
 
 
  void get_attr_creation_order(hid_t plist_id, uint *crt_order_flags)
  {
    throwOnError(H5Pget_attr_creation_order(plist_id,crt_order_flags));
  }
 
 
  void set_obj_track_times(hid_t plist_id, hbool_t track_times)
  {
    throwOnError(H5Pset_obj_track_times(plist_id,track_times));
  }
 
 
  hbool_t get_obj_track_times(hid_t plist_id)
  {
    hbool_t track_times;
    throwOnError(H5Pget_obj_track_times(plist_id,&track_times));
    return track_times;
  }
 
 
  void modify_filter(hid_t plist_id, H5ZFilter filter, uint flags, size_t cd_nelmts, const uint[] cd_values)
  {
    throwOnError(H5Pmodify_filter(plist_id,filter,flags,cd_nelmts,cast(const uint*)&cd_values));
  }
 
 
  void set_filter(hid_t plist_id, H5ZFilter filter, uint flags, size_t cd_nelmts, const uint[] c_values)
  {
    throwOnError(H5Pset_filter(plist_id,filter,flags,cd_nelmts,cast(const uint*)&c_values));
  }
 
 
  int get_nfilters(hid_t plist_id)
  {
    return H5Pget_nfilters(plist_id);
  }
 
 
  H5ZFilter get_filter2(hid_t plist_id, uint filter, uint *flags/*out*/, size_t *cd_nelmts/*out*/, uint[] cd_values/*out*/, size_t namelen, char[] name, uint *filter_config /*out*/)
  {
    return H5Pget_filter2(plist_id,filter,flags/*out*/,cd_nelmts/*out*/,cast(uint*)&cd_values/*out*/,namelen,cast(char*)&name,filter_config);
  }
 
 
  void get_filter_by_id2(hid_t plist_id, H5ZFilter id, uint *flags/*out*/, size_t *cd_nelmts/*out*/, uint[] cd_values/*out*/, size_t namelen, char[] name/*out*/, uint *filter_config/*out*/)
  {
    throwOnError(H5Pget_filter_by_id2(plist_id,id,flags/*out*/,cd_nelmts/*out*/,cast(uint*)&cd_values/*out*/,namelen,cast(char*)&name/*out*/,filter_config));
  }
 
 
  htri_t all_filters_avail(hid_t plist_id)
  {
    return H5Pall_filters_avail(plist_id);
  }
 
 
  void remove_filter(hid_t plist_id, H5ZFilter filter)
  {
    throwOnError(H5Premove_filter(plist_id,filter));
  }
 
 
  void set_deflate(hid_t plist_id, int aggression)
  {
    throwOnError(H5Pset_deflate(plist_id,aggression));
  }
 
 
  void set_fletcher32(hid_t plist_id)
  {
    throwOnError(H5Pset_fletcher32(plist_id));
  }
 
 
  void get_version(hid_t plist_id, uint *boot/*out*/, uint *freelist/*out*/, uint *stab/*out*/, uint *shhdr/*out*/)
  {
    throwOnError(H5Pget_version(plist_id,boot/*out*/,freelist/*out*/,stab/*out*/,shhdr/*out*/));
  }
 
 
  void set_userblock(hid_t plist_id, hsize_t size)
  {
    throwOnError(H5Pset_userblock(plist_id,size));
  }
 
 
  void get_userblock(hid_t plist_id, hsize_t *size)
  {
    throwOnError(H5Pget_userblock(plist_id,size));
  }
 
 
  void set_sizes(hid_t plist_id, size_t sizeof_addr, size_t sizeof_size)
  {
    throwOnError(H5Pset_sizes(plist_id,sizeof_addr,sizeof_size));
  }
 
 
  void get_sizes(hid_t plist_id, size_t *sizeof_addr/*out*/, size_t *sizeof_size/*out*/)
  {
    throwOnError(H5Pget_sizes(plist_id,sizeof_addr/*out*/,sizeof_size/*out*/));
  }
 
 
  void set_sym_k(hid_t plist_id, uint ik, uint lk)
  {
    throwOnError(H5Pset_sym_k(plist_id,ik,lk));
  }
 
 
  void get_sym_k(hid_t plist_id, uint *ik/*out*/, uint *lk/*out*/)
  {
    throwOnError(H5Pget_sym_k(plist_id,ik/*out*/,lk/*out*/));
  }
 
 
  void set_istore_k(hid_t plist_id, uint ik)
  {
    throwOnError(H5Pset_istore_k(plist_id,ik));
  }
 
 
  void get_istore_k(hid_t plist_id, uint *ik/*out*/)
  {
    throwOnError(H5Pget_istore_k(plist_id,ik/*out*/));
  }
 
 
  void set_shared_mesg_nindexes(hid_t plist_id, uint nindexes)
  {
    throwOnError(H5Pset_shared_mesg_nindexes(plist_id,nindexes));
  }
 
 
  void get_shared_mesg_nindexes(hid_t plist_id, uint *nindexes)
  {
    throwOnError(H5Pget_shared_mesg_nindexes(plist_id,nindexes));
  }
 
 
  void set_shared_mesg_index(hid_t plist_id, uint index_num, uint mesg_type_flags, uint min_mesg_size)
  {
    throwOnError(H5Pset_shared_mesg_index(plist_id,index_num,mesg_type_flags,min_mesg_size));
  }
 
 
  void get_shared_mesg_index(hid_t plist_id, uint index_num, uint *mesg_type_flags, uint *min_mesg_size)
  {
    throwOnError(H5Pget_shared_mesg_index(plist_id,index_num,mesg_type_flags,min_mesg_size));
  }
 
 
  void set_shared_mesg_phase_change(hid_t plist_id, uint max_list, uint min_btree)
  {
    throwOnError(H5Pset_shared_mesg_phase_change(plist_id,max_list,min_btree));
  }
 
 
  void get_shared_mesg_phase_change(hid_t plist_id, uint *max_list, uint *min_btree)
  {
    throwOnError(H5Pget_shared_mesg_phase_change(plist_id,max_list,min_btree));
  }
 
 
  void set_alignment(hid_t fapl_id, hsize_t threshold, hsize_t alignment)
  {
    throwOnError(H5Pset_alignment(fapl_id,threshold,alignment));
  }
 
 
  void get_alignment(hid_t fapl_id, hsize_t *threshold/*out*/, hsize_t *alignment/*out*/)
  {
    throwOnError(H5Pget_alignment(fapl_id,threshold/*out*/,alignment/*out*/));
  }
 
 
  void set_driver(hid_t plist_id, hid_t driver_id, const void *driver_info)
  {
    throwOnError(H5Pset_driver(plist_id,driver_id,driver_info));
  }
 
 
  hid_t get_driver(hid_t plist_id)
  {
    return H5Pget_driver(plist_id);
  }
 
 
  void *get_driver_info(hid_t plist_id)
  {
    return H5Pget_driver_info(plist_id);
  }
 
 
  void set_family_offset(hid_t fapl_id, hsize_t offset)
  {
    throwOnError(H5Pset_family_offset(fapl_id,offset));
  }
 
 
  void get_family_offset(hid_t fapl_id, hsize_t *offset)
  {
    throwOnError(H5Pget_family_offset(fapl_id,offset));
  }
 
 
  void set_cache(hid_t plist_id, int mdc_nelmts, size_t rdcc_nslots, size_t rdcc_nbytes, double rdcc_w0)
  {
    throwOnError(H5Pset_cache(plist_id,mdc_nelmts,rdcc_nslots,rdcc_nbytes,rdcc_w0));
  }
 
 
  void get_cache(hid_t plist_id, int *mdc_nelmts, /* out */ size_t *rdcc_nslots/*out*/, size_t *rdcc_nbytes/*out*/, double *rdcc_w0)
  {
    throwOnError(H5Pget_cache(plist_id,mdc_nelmts,rdcc_nslots,rdcc_nbytes/*out*/,rdcc_w0));
  }
 
 
  void set_gc_references(hid_t fapl_id, uint gc_ref)
  {
    throwOnError(H5Pset_gc_references(fapl_id,gc_ref));
  }
 
 
  void get_gc_references(hid_t fapl_id, uint *gc_ref/*out*/)
  {
    throwOnError(H5Pget_gc_references(fapl_id,gc_ref/*out*/));
  }
 
 
  void set_fclose_degree(hid_t fapl_id, H5F_close_degree_t degree)
  {
    throwOnError(H5Pset_fclose_degree(fapl_id,degree));
  }
 
 
  void get_fclose_degree(hid_t fapl_id, H5F_close_degree_t *degree)
  {
    throwOnError(H5Pget_fclose_degree(fapl_id,degree));
  }
 
 
  void set_meta_block_size(hid_t fapl_id, hsize_t size)
  {
    throwOnError(H5Pset_meta_block_size(fapl_id,size));
  }
 
 
  void get_meta_block_size(hid_t fapl_id, hsize_t *size/*out*/)
  {
    throwOnError(H5Pget_meta_block_size(fapl_id,size/*out*/));
  }
 
 
  void set_sieve_buf_size(hid_t fapl_id, size_t size)
  {
    throwOnError(H5Pset_sieve_buf_size(fapl_id,size));
  }
 
 
  void get_sieve_buf_size(hid_t fapl_id, size_t *size/*out*/)
  {
    throwOnError(H5Pget_sieve_buf_size(fapl_id,size/*out*/));
  }
 
 
  void set_small_data_block_size(hid_t fapl_id, hsize_t size)
  {
    throwOnError(H5Pset_small_data_block_size(fapl_id,size));
  }
 
 
  void get_small_data_block_size(hid_t fapl_id, hsize_t *size/*out*/)
  {
    throwOnError(H5Pget_small_data_block_size(fapl_id,size/*out*/));
  }
 
 
  void set_libver_bounds(hid_t plist_id, H5F_libver_t low, H5F_libver_t high)
  {
    throwOnError(H5Pset_libver_bounds(plist_id,low,high));
  }
 
 
  void get_libver_bounds(hid_t plist_id, H5F_libver_t *low, H5F_libver_t *high)
  {
    throwOnError(H5Pget_libver_bounds(plist_id,low,high));
  }
 
 
  void set_elink_file_cache_size(hid_t plist_id, uint efc_size)
  {
    throwOnError(H5Pset_elink_file_cache_size(plist_id,efc_size));
  }
 
 
  void get_elink_file_cache_size(hid_t plist_id, uint *efc_size)
  {
    throwOnError(H5Pget_elink_file_cache_size(plist_id,efc_size));
  }
 
 
  void set_file_image(hid_t fapl_id, void *buf_ptr, size_t buf_len)
  {
    throwOnError(H5Pset_file_image(fapl_id,buf_ptr,buf_len));
  }
 
 
  void get_file_image(hid_t fapl_id, void **buf_ptr_ptr, size_t *buf_len_ptr)
  {
    throwOnError(H5Pget_file_image(fapl_id,buf_ptr_ptr,buf_len_ptr));
  }
 
 
  version(h5parallel)
  {
    void set_core_write_tracking(hid_t fapl_id, hbool_t is_enabled, size_t page_size)
    {
      throwOnError(H5Pset_core_write_tracking(fapl_id,is_enabled,page_size));
    }
   
   
    void get_core_write_tracking(hid_t fapl_id, hbool_t *is_enabled, size_t *page_size)
    {
      throwOnError(H5Pget_core_write_tracking(fapl_id,is_enabled,page_size));
    }
  }   
 
  void set_layout(hid_t plist_id, H5DLayout layout)
  {
    throwOnError(H5Pset_layout(plist_id,layout));
  }
 
 
  H5DLayout get_layout(hid_t plist_id)
  {
    return H5Pget_layout(plist_id);
  }
 
 
  void set_chunk(hid_t plist_id, in hsize_t[] dims)
  {
    int ndims=cast(int)dims.length;
    throwOnError(H5Pset_chunk(plist_id,ndims,cast(const hsize_t*)dims));
  }
 
 
  int get_chunk(hid_t plist_id, hsize_t[] dim/*out*/)
  {
    int max_ndims=to!int(dim.length);
    writefln("*MAX_ndims: %s",max_ndims);
    return H5Pget_chunk(plist_id,max_ndims,cast(hsize_t*)dim/*out*/);
  }
 
 
  void set_external(hid_t plist_id, string name, off_t offset, hsize_t size)
  {
    throwOnError(H5Pset_external(plist_id,toStringz(name),offset,size));
  }
 
 
  int get_external_count(hid_t plist_id)
  {
    return H5Pget_external_count(plist_id);
  }
 
 
  void get_external(hid_t plist_id, uint idx, size_t name_size, char *name/*out*/, off_t *offset/*out*/, hsize_t *size/*out*/)
  {
    throwOnError(H5Pget_external(plist_id,idx,name_size,name/*out*/,offset/*out*/,size/*out*/));
  }
 
 
  void set_szip(hid_t plist_id, uint options_mask, uint pixels_per_block)
  {
    throwOnError(H5Pset_szip(plist_id,options_mask,pixels_per_block));
  }
 
 
  void set_shuffle(hid_t plist_id)
  {
    throwOnError(H5Pset_shuffle(plist_id));
  }
 
 
  void set_nbit(hid_t plist_id)
  {
    throwOnError(H5Pset_nbit(plist_id));
  }
 
 
  void set_scaleoffset(hid_t plist_id, H5Z_SO_scale_type_t scale_type, int scale_factor)
  {
    throwOnError(H5Pset_scaleoffset(plist_id,scale_type,scale_factor));
  }
 
 
  void set_fill_value(hid_t plist_id, hid_t type_id, const void *value)
  {
    throwOnError(H5Pset_fill_value(plist_id,type_id,value));
  }
 
 
  void get_fill_value(hid_t plist_id, hid_t type_id, void *value/*out*/)
  {
    throwOnError(H5Pget_fill_value(plist_id,type_id,value/*out*/));
  }
 
 
  void fill_value_defined(hid_t plist, H5D_fill_value_t *status)
  {
    throwOnError(H5Pfill_value_defined(plist,status));
  }
 
 
  void set_alloc_time(hid_t plist_id, H5DAllocTime alloc_time)
  {
    throwOnError(H5Pset_alloc_time(plist_id,alloc_time));
  }
 
 
  void get_alloc_time(hid_t plist_id, H5DAllocTime *alloc_time/*out*/)
  {
    throwOnError(H5Pget_alloc_time(plist_id,alloc_time/*out*/));
  }
 
 
  void set_fill_time(hid_t plist_id, H5D_fill_time_t fill_time)
  {
    throwOnError(H5Pset_fill_time(plist_id,fill_time));
  }
 
 
  void get_fill_time(hid_t plist_id, H5D_fill_time_t *fill_time/*out*/)
  {
    throwOnError(H5Pget_fill_time(plist_id,fill_time/*out*/));
  }
 
 
  void set_chunk_cache(hid_t dapl_id, size_t rdcc_nslots, size_t rdcc_nbytes, double rdcc_w0)
  {
    throwOnError(H5Pset_chunk_cache(dapl_id,rdcc_nslots,rdcc_nbytes,rdcc_w0));
  }
 
 
  void get_chunk_cache(hid_t dapl_id, size_t *rdcc_nslots/*out*/, size_t *rdcc_nbytes/*out*/, double *rdcc_w0/*out*/)
  {
    throwOnError(H5Pget_chunk_cache(dapl_id,rdcc_nslots/*out*/,rdcc_nbytes/*out*/,rdcc_w0/*out*/));
  }
 
 
  void set_data_transform(hid_t plist_id, string expression)
  {
    throwOnError(H5Pset_data_transform(plist_id,toStringz(expression)));
  }
 
 
  string get_data_transform(hid_t plist_id)
  {
    char[2048] buf;
    if (H5Pget_data_transform(plist_id,cast(char*)buf,buf.length)<=0)
      return "";
    else
      return ZtoString(buf[]);
  }
 
 
  void set_buffer(hid_t plist_id, size_t size, void *tconv, void *bkg)
  {
    throwOnError(H5Pset_buffer(plist_id,size,tconv,bkg));
  }
 
 
  size_t get_buffer(hid_t plist_id, void **tconv/*out*/, void **bkg/*out*/)
  {
    return H5Pget_buffer(plist_id,tconv/*out*/,bkg/*out*/);
  }
 
 
  void set_preserve(hid_t plist_id, hbool_t status)
  {
    throwOnError(H5Pset_preserve(plist_id,status));
  }
 
 
  int get_preserve(hid_t plist_id)
  {
    return H5Pget_preserve(plist_id);
  }
 
 
  void set_edc_check(hid_t plist_id, H5Z_EDC_t check)
  {
    throwOnError(H5Pset_edc_check(plist_id,check));
  }
 
 
  H5Z_EDC_t get_edc_check(hid_t plist_id)
  {
    return H5Pget_edc_check(plist_id);
  }
 
 
  void set_filter_callback(hid_t plist_id, H5Z_filter_func_t func, void* op_data)
  {
    throwOnError(H5Pset_filter_callback(plist_id,func,op_data));
  }
 
 
  void set_btree_ratios(hid_t plist_id, double left, double middle, double right)
  {
    throwOnError(H5Pset_btree_ratios(plist_id,left,middle,right));
  }
 
 
  void get_btree_ratios(hid_t plist_id, double *left/*out*/, double *middle/*out*/, double *right/*out*/)
  {
    throwOnError(H5Pget_btree_ratios(plist_id,left/*out*/,middle/*out*/,right/*out*/));
  }
 
 
  void set_hyper_vector_size(hid_t fapl_id, size_t size)
  {
    throwOnError(H5Pset_hyper_vector_size(fapl_id,size));
  }
 
 
  void get_hyper_vector_size(hid_t fapl_id, size_t *size/*out*/)
  {
    throwOnError(H5Pget_hyper_vector_size(fapl_id,size/*out*/));
  }
 
 
  void set_type_conv_cb(hid_t dxpl_id, H5T_conv_except_func_t op, void* operate_data)
  {
    throwOnError(H5Pset_type_conv_cb(dxpl_id,op,operate_data));
  }
 
 
  void get_type_conv_cb(hid_t dxpl_id, H5T_conv_except_func_t *op, void** operate_data)
  {
    throwOnError(H5Pget_type_conv_cb(dxpl_id,op,operate_data));
  }
 
 
  version(h5parallel)
  {
    void get_mpio_actual_chunk_opt_mode(hid_t plist_id, H5D_mpio_actual_chunk_opt_mode_t *actual_chunk_opt_mode)
    {
      throwOnError(H5Pget_mpio_actual_chunk_opt_mode(plist_id,actual_chunk_opt_mode));
    }
   
   
    void get_mpio_actual_io_mode(hid_t plist_id, H5D_mpio_actual_io_mode_t *actual_io_mode)
    {
      throwOnError(H5Pget_mpio_actual_io_mode(plist_id,actual_io_mode));
    }
   
   
    void get_mpio_no_collective_cause(hid_t plist_id, uint32_t *local_no_collective_cause, uint32_t *global_no_collective_cause)
    {
      throwOnError(H5Pget_mpio_no_collective_cause(plist_id,local_no_collective_cause,global_no_collective_cause));
    }
  }   
 
  void set_create_intermediate_group(hid_t plist_id, uint crt_intmd)
  {
    throwOnError(H5Pset_create_intermediate_group(plist_id,crt_intmd));
  }
 
 
  void get_create_intermediate_group(hid_t plist_id, uint *crt_intmd /*out*/)
  {
    throwOnError(H5Pget_create_intermediate_group(plist_id,crt_intmd));
  }
 
 
  void set_local_heap_size_hint(hid_t plist_id, size_t size_hint)
  {
    throwOnError(H5Pset_local_heap_size_hint(plist_id,size_hint));
  }
 
 
  void get_local_heap_size_hint(hid_t plist_id, size_t *size_hint /*out*/)
  {
    throwOnError(H5Pget_local_heap_size_hint(plist_id,size_hint));
  }
 
 
  void set_link_phase_change(hid_t plist_id, uint max_compact, uint min_dense)
  {
    throwOnError(H5Pset_link_phase_change(plist_id,max_compact,min_dense));
  }
 
 
  void get_link_phase_change(hid_t plist_id, uint *max_compact /*out*/, uint *min_dense /*out*/)
  {
    throwOnError(H5Pget_link_phase_change(plist_id,max_compact,min_dense));
  }
 
 
  void set_est_link_info(hid_t plist_id, uint est_num_entries, uint est_name_len)
  {
    throwOnError(H5Pset_est_link_info(plist_id,est_num_entries,est_name_len));
  }
 
 
  void get_est_link_info(hid_t plist_id, uint *est_num_entries /* out */, uint *est_name_len /* out */)
  {
    throwOnError(H5Pget_est_link_info(plist_id,est_num_entries,est_name_len));
  }
 
 
  void set_link_creation_order(hid_t plist_id, uint crt_order_flags)
  {
    throwOnError(H5Pset_link_creation_order(plist_id,crt_order_flags));
  }
 
 
  void get_link_creation_order(hid_t plist_id, uint *crt_order_flags /* out */)
  {
    throwOnError(H5Pget_link_creation_order(plist_id,crt_order_flags));
  }
 
 
  void set_char_encoding(hid_t plist_id, H5TCset encoding)
  {
    throwOnError(H5Pset_char_encoding(plist_id,encoding));
  }
 
 
  void get_char_encoding(hid_t plist_id, H5TCset *encoding /*out*/)
  {
    throwOnError(H5Pget_char_encoding(plist_id,encoding));
  }
 
 
  void set_nlinks(hid_t plist_id, size_t nlinks)
  {
    throwOnError(H5Pset_nlinks(plist_id,nlinks));
  }
 
 
  void get_nlinks(hid_t plist_id, size_t *nlinks)
  {
    throwOnError(H5Pget_nlinks(plist_id,nlinks));
  }
 
 
  void set_elink_prefix(hid_t plist_id, string prefix)
  {
    throwOnError(H5Pset_elink_prefix(plist_id,toStringz(prefix)));
  }
 
 
  string get_elink_prefix(hid_t plist_id)
  {
    char[2048] buf;
    if (H5Pget_elink_prefix(plist_id,cast(char*)buf,buf.length)<=0)
      return "";
    else
      return ZtoString(buf[]);
  }
 
 
  hid_t get_elink_fapl(hid_t lapl_id)
  {
    return H5Pget_elink_fapl(lapl_id);
  }
 
 
  void set_elink_fapl(hid_t lapl_id, hid_t fapl_id)
  {
    throwOnError(H5Pset_elink_fapl(lapl_id,fapl_id));
  }
 
 
  void set_elink_acc_flags(hid_t lapl_id, uint flags)
  {
    throwOnError(H5Pset_elink_acc_flags(lapl_id,flags));
  }
 
 
  void get_elink_acc_flags(hid_t lapl_id, uint *flags)
  {
    throwOnError(H5Pget_elink_acc_flags(lapl_id,flags));
  }
 
 
  void set_copy_object(hid_t plist_id, uint crt_intmd)
  {
    throwOnError(H5Pset_copy_object(plist_id,crt_intmd));
  }
 
 
  void get_copy_object(hid_t plist_id, uint *crt_intmd /*out*/)
  {
    throwOnError(H5Pget_copy_object(plist_id,crt_intmd));
  }
 
 
  void add_merge_committed_dtype_path(hid_t plist_id, string path)
  {
    throwOnError(H5Padd_merge_committed_dtype_path(plist_id,toStringz(path)));
  }
 
 
  void free_merge_committed_dtype_paths(hid_t plist_id)
  {
    throwOnError(H5Pfree_merge_committed_dtype_paths(plist_id));
  }
  }//static
}

struct H5R
{
  static
  {
    void create(void *_ref, hid_t loc_id, string name, H5RType ref_type, hid_t space_id)
    {
      throwOnError(H5Rcreate(_ref, loc_id, toStringz(name),ref_type,space_id));
    }
   hid_t dereference(hid_t dataset, H5RType ref_type, const void *_ref)
   {
      return H5Rdereference(dataset, ref_type, _ref);
   }
   hid_t get_region(hid_t dataset, H5RType ref_type, const void *_ref)
   {
      return  H5Rget_region(dataset, ref_type, _ref);
   }
   string get_name(hid_t loc_id, H5RType ref_type, const void *_ref)
   {
      char[2048] buf;
      if (H5Rget_name(loc_id, ref_type,_ref,cast(char*)buf,buf.length-1)<=0)
        return "";
      else
        return ZtoString(buf[]);
    }
    void get_obj_type2(hid_t id, H5RType ref_type, const void *_ref, H5OType *obj_type)
    {
      throwOnError(H5Rget_obj_type2( id, ref_type,_ref,  obj_type));
    }
  } // static
}

struct H5S
{
  static {
  hid_t create(H5SClass type)
  {
    return H5Screate(type);
  }
 
  hid_t create_simple(in hsize_t[] dims)
  {
    auto maxdims=dims;
    return H5S.create_simple(dims, maxdims);
  }
 
  hid_t create_simple(in hsize_t[] dims, in hsize_t[] maxdims)
  {
    if (maxdims.length!=dims.length)
      throw new Exception("H5S create_simple: maxdims="~to!string(maxdims.length)~" must be of same rank as dims="~to!string(dims.length));
    return H5Screate_simple(cast(int)dims.length, cast(const hsize_t*) dims,cast(const hsize_t*) maxdims);
  }
 
  void set_extent_simple(hid_t space_id, in hsize_t[] dims)
  {
    set_extent_simple(space_id,dims,dims);
  }
  
  void set_extent_simple(hid_t space_id, in hsize_t[] dims,in hsize_t[] max)
  {
    const(hsize_t)[] maxarg=max;
    int rank=to!int(dims.length);
    if ((max.length==0) && (dims.length>0))
      maxarg=dims;
    else
    {
      if (maxarg.length!=dims.length)
        throw new Exception("H5S: max dims "~to!string(maxarg.length)~" must be of same ranks as dims="~to!string(dims.length));
    }
    throwOnError(H5Sset_extent_simple(space_id,to!int(dims.length),cast(const hsize_t*)dims,cast(const hsize_t*)maxarg));
  }
 
 
  hid_t copy(hid_t space_id)
  {
    return H5Scopy(space_id);
  }
 
 
  void close(hid_t space_id)
  {
    throwOnError(H5Sclose(space_id));
  }
 
 
  void encode(hid_t obj_id, void *buf, size_t *nalloc)
  {
    throwOnError(H5Sencode(obj_id,buf,nalloc));
  }
 
 
  hid_t decode(const void *buf)
  {
    return H5Sdecode(buf);
  }
 
 
  hssize_t get_simple_extent_npoints(hid_t space_id)
  {
    return H5Sget_simple_extent_npoints(space_id);
  }
 
 
  int get_simple_extent_ndims(hid_t space_id)
  {
    return H5Sget_simple_extent_ndims(space_id);
  }

  int get_simple_extent_dims(hid_t space_id, hsize_t[] dims)
  {
    hsize_t[] maxdims;
    maxdims.length=dims.length;
    return H5Sget_simple_extent_dims(space_id,cast(hsize_t*)dims,cast(hsize_t*)maxdims);
  }
 
 
  int get_simple_extent_dims(hid_t space_id, hsize_t[] dims, hsize_t[] maxdims)
  {
    return H5Sget_simple_extent_dims(space_id,cast(hsize_t*)dims,cast(hsize_t*)maxdims);
  }
 
 
  htri_t is_simple(hid_t space_id)
  {
    return H5Sis_simple(space_id);
  }
 
 
  hssize_t get_select_npoints(hid_t spaceid)
  {
    return H5Sget_select_npoints(spaceid);
  }
 
 
  void select_hyperslab(hid_t filespace, H5SSeloper op, in hsize_t[] start,  in hsize_t[] count)
  {
     select_hyperslab(filespace, op, start, cast(hsize_t[])[], count, cast(hsize_t[])[]);
  }

  void select_hyperslab(hid_t space_id, H5SSeloper op, in hsize_t[] start, in hsize_t[] _stride, in hsize_t[] count, in hsize_t[] _block)
  {
    throwOnError(H5Sselect_hyperslab(space_id,op,cast(const hsize_t*)start,cast(const hsize_t*) _stride,cast(const hsize_t*)count,cast(const hsize_t*)_block));
  }
 
 
  version(h5parallel)
  {
    hid_t combine_hyperslab(hid_t space_id, H5SSeloper op, const hsize_t *start, const hsize_t *_stride, const hsize_t *count, const hsize_t *_block)
    {
      return H5Scombine_hyperslab(space_id,op,start,_stride,count,_block);
    }
   
   
    void select_select(hid_t space1_id, H5SSeloper op, hid_t space2_id)
    {
      throwOnError(H5Sselect_select(space1_id,op,space2_id));
    }
   
   
    hid_t combine_select(hid_t space1_id, H5SSeloper op, hid_t space2_id)
    {
      return H5Scombine_select(space1_id,op,space2_id);
    }
  } 
 
  void select_elements(hid_t space_id, H5SSeloper op, size_t num_elem, const hsize_t *coord)
  {
    throwOnError(H5Sselect_elements(space_id,op,num_elem,coord));
  }
 
 
  H5SClass get_simple_extent_type(hid_t space_id)
  {
    return H5Sget_simple_extent_type(space_id);
  }
 
 
  void set_extent_none(hid_t space_id)
  {
    throwOnError(H5Sset_extent_none(space_id));
  }
 
 
  void extent_copy(hid_t dst_id,hid_t src_id)
  {
    throwOnError(H5Sextent_copy(dst_id,src_id));
  }
 
 
  htri_t extent_equal(hid_t sid1, hid_t sid2)
  {
    return H5Sextent_equal(sid1,sid2);
  }
 
 
  void select_all(hid_t spaceid)
  {
    throwOnError(H5Sselect_all(spaceid));
  }
 
 
  void select_none(hid_t spaceid)
  {
    throwOnError(H5Sselect_none(spaceid));
  }
 
 
  void offset_simple(hid_t space_id, const hssize_t *offset)
  {
    throwOnError(H5Soffset_simple(space_id,offset));
  }
 
 
  htri_t select_valid(hid_t spaceid)
  {
    return H5Sselect_valid(spaceid);
  }
 
 
  hssize_t get_select_hyper_nblocks(hid_t spaceid)
  {
    return H5Sget_select_hyper_nblocks(spaceid);
  }
 
 
  hssize_t get_select_elem_npoints(hid_t spaceid)
  {
    return H5Sget_select_elem_npoints(spaceid);
  }
 
 
  void get_select_hyper_blocklist(hid_t spaceid, hsize_t startblock, hsize_t numblocks, hsize_t *buf)
  {
    throwOnError(H5Sget_select_hyper_blocklist(spaceid,startblock,numblocks,buf));
  }
 
 
  void get_select_elem_pointlist(hid_t spaceid, hsize_t startpoint, hsize_t numpoints, hsize_t *buf)
  {
    throwOnError(H5Sget_select_elem_pointlist(spaceid,startpoint,numpoints,buf));
  }
 
 
  void get_select_bounds(hid_t spaceid, hsize_t *start, hsize_t *end)
  {
    throwOnError(H5Sget_select_bounds(spaceid,start,end));
  }
 
 
  H5S_sel_type get_select_type(hid_t spaceid)
  {
    return H5Sget_select_type(spaceid);
  }
  }// static
}
 
struct H5T
{
  static hid_t create(H5TClass type, size_t size)
  {
    return H5Tcreate(type,size);
  }
 
 
  static hid_t copy(hid_t type_id)
  {
    return H5Tcopy(type_id);
  }
 
 
  static void close(hid_t type_id)
  {
    throwOnError(H5Tclose(type_id));
  }
 
 
  static htri_t equal(hid_t type1_id, hid_t type2_id)
  {
    return H5Tequal(type1_id,type2_id);
  }
 
 
  static void lock(hid_t type_id)
  {
    throwOnError(H5Tlock(type_id));
  }
 
 
  static void commit2(hid_t loc_id, string name, hid_t type_id, hid_t lcpl_id, hid_t tcpl_id, hid_t tapl_id)
  {
    throwOnError(H5Tcommit2(loc_id,toStringz(name),type_id,lcpl_id,tcpl_id,tapl_id));
  }
 
 
  static hid_t open2(hid_t loc_id, string name, hid_t tapl_id)
  {
    return H5Topen2(loc_id,toStringz(name),tapl_id);
  }
 
 
  static void commit_anon(hid_t loc_id, hid_t type_id, hid_t tcpl_id, hid_t tapl_id)
  {
    throwOnError(H5Tcommit_anon(loc_id,type_id,tcpl_id,tapl_id));
  }
 
 
  static hid_t get_create_plist(hid_t type_id)
  {
    return H5Tget_create_plist(type_id);
  }
 
 
  static htri_t committed(hid_t type_id)
  {
    return H5Tcommitted(type_id);
  }
 
 
  static void encode(hid_t obj_id, void *buf, size_t *nalloc)
  {
    throwOnError(H5Tencode(obj_id,buf,nalloc));
  }
 
 
  static hid_t decode(const void *buf)
  {
    return H5Tdecode(buf);
  }
 
 
  static void insert(hid_t parent_id, string name, size_t offset, hid_t member_id)
  {
    throwOnError(H5Tinsert(parent_id,toStringz(name),offset,member_id));
  }
 
 
  static void pack(hid_t type_id)
  {
    throwOnError(H5Tpack(type_id));
  }
 
 
  static hid_t enum_create(hid_t base_id)
  {
    return H5Tenum_create(base_id);
  }
 
 
  static void enum_insert(hid_t type, string name, const void *value)
  {
    throwOnError(H5Tenum_insert(type,toStringz(name),value));
  }
 
 
  static string enum_nameof(hid_t type, const void *value)
  {
    char[2048] buf;
    throwOnError(H5Tenum_nameof(type,value,cast(char*)buf,buf.length));
    return ZtoString(buf[]);
  }
 
 
  static void enum_valueof(hid_t type, string name, void *value/*out*/)
  {
    throwOnError(H5Tenum_valueof(type,toStringz(name),value/*out*/));
  }
 
 
  static hid_t vlen_create(hid_t base_id)
  {
    return H5Tvlen_create(base_id);
  }
 
 
  static hid_t array_create2(hid_t base_id, uint ndims, const hsize_t[] dim)
  {
    return H5Tarray_create2(base_id,ndims,cast(hsize_t*)dim.ptr);
  }
 
 
  static int get_array_ndims(hid_t type_id)
  {
    return H5Tget_array_ndims(type_id);
  }
 
 
  static int get_array_dims2(hid_t type_id, hsize_t[] dims)
  {
    return H5Tget_array_dims2(type_id,cast(hsize_t*)&dims);
  }
 
 
  static void set_tag(hid_t type, string tag)
  {
    throwOnError(H5Tset_tag(type,toStringz(tag)));
  }
 
 
  static string get_tag(hid_t type_id)
  {
    return ZtoString(H5Tget_tag(type_id));
  }
 
 
  static hid_t get_super(hid_t type_id)
  {
    return H5Tget_super(type_id);
  }
 
 
  static H5TClass get_class(hid_t type_id)
  {
    return H5Tget_class(type_id);
  }
 
 
  static htri_t detect_class(hid_t type_id, H5TClass cls)
  {
    return H5Tdetect_class(type_id,cls);
  }
 
 
  static size_t get_size(hid_t type_id)
  {
   return H5Tget_size(type_id);
  }
 
 
  static H5TByteOrder get_order(hid_t type_id)
  {
   return H5Tget_order(type_id);
  }
 
 
  static size_t get_precision(hid_t type_id)
  {
   return H5Tget_precision(type_id);
  }
 
 
  static int get_offset(hid_t type_id)
  {
    return H5Tget_offset(type_id);
  }
 
 
  static void get_pad(hid_t type_id, H5T_pad_t *lsb/*out*/, H5T_pad_t *msb/*out*/)
  {
    throwOnError(H5Tget_pad(type_id,lsb/*out*/,msb/*out*/));
  }
 
 
  static H5T_sign_t get_sign(hid_t type_id)
  {
    return H5Tget_sign(type_id);
  }
 
 
  static void get_fields(hid_t type_id, size_t *spos/*out*/, size_t *epos/*out*/, size_t *esize/*out*/, size_t *mpos/*out*/, size_t *msize/*out*/)
  {
    throwOnError(H5Tget_fields(type_id,spos/*out*/,epos/*out*/,esize/*out*/,mpos/*out*/,msize/*out*/));
  }
 
 
  static size_t get_ebias(hid_t type_id)
  {
    return H5Tget_ebias(type_id);
  }
 
 
  static H5T_norm_t get_norm(hid_t type_id)
  {
    return H5Tget_norm(type_id);
  }
 
 
  static H5T_pad_t get_inpad(hid_t type_id)
  {
    return H5Tget_inpad(type_id);
  }
 
 
  static H5TString get_strpad(hid_t type_id)
  {
    return H5Tget_strpad(type_id);
  }
 
 
  static int get_nmembers(hid_t type_id)
  {
    return H5Tget_nmembers(type_id);
  }
 
 
  static string get_member_name(hid_t type_id, uint membno)
  {
    return ZtoString(H5Tget_member_name(type_id,membno));
  }
 
 
  static int get_member_index(hid_t type_id, string name)
  {
    return H5Tget_member_index(type_id,toStringz(name));
  }
 
 
  static size_t get_member_offset(hid_t type_id, uint membno)
  {
    return H5Tget_member_offset(type_id,membno);
  }
 
 
  static H5TClass get_member_class(hid_t type_id, uint membno)
  {
    return H5Tget_member_class(type_id,membno);
  }
 
 
  static hid_t get_member_type(hid_t type_id, uint membno)
  {
    return H5Tget_member_type(type_id,membno);
  }
 
 
  static void get_member_value(hid_t type_id, uint membno, void *value/*out*/)
  {
    throwOnError(H5Tget_member_value(type_id,membno,value/*out*/));
  }
 
 
  static H5TCset get_cset(hid_t type_id)
  {
    return H5Tget_cset(type_id);
  }
 
 
  static htri_t is_variable_str(hid_t type_id)
  {
  return H5Tis_variable_str(type_id);
  }
 
 
  static hid_t get_native_type(hid_t type_id, H5TDirection direction)
  {
  return H5Tget_native_type(type_id,direction);
  }
 
 
  static void set_size(hid_t type_id, size_t size)
  {
    throwOnError(H5Tset_size(type_id,size));
  }
 
 
  static void set_order(hid_t type_id, H5TByteOrder order)
  {
    throwOnError(H5Tset_order(type_id,order));
  }
 
 
  static void set_precision(hid_t type_id, size_t prec)
  {
    throwOnError(H5Tset_precision(type_id,prec));
  }
 
 
  static void set_offset(hid_t type_id, size_t offset)
  {
    throwOnError(H5Tset_offset(type_id,offset));
  }
 
 
  static void set_pad(hid_t type_id, H5T_pad_t lsb, H5T_pad_t msb)
  {
    throwOnError(H5Tset_pad(type_id,lsb,msb));
  }
 
 
  static void set_sign(hid_t type_id, H5T_sign_t sign)
  {
    throwOnError(H5Tset_sign(type_id,sign));
  }
 
 
  static void set_fields(hid_t type_id, size_t spos, size_t epos, size_t esize, size_t mpos, size_t msize)
  {
    throwOnError(H5Tset_fields(type_id,spos,epos,esize,mpos,msize));
  }
 
 
  static void set_ebias(hid_t type_id, size_t ebias)
  {
    throwOnError(H5Tset_ebias(type_id,ebias));
  }
 
 
  static void set_norm(hid_t type_id, H5T_norm_t norm)
  {
    throwOnError(H5Tset_norm(type_id,norm));
  }
 
 
  static void set_inpad(hid_t type_id, H5T_pad_t pad)
  {
    throwOnError(H5Tset_inpad(type_id,pad));
  }
 
 
  static void set_cset(hid_t type_id, H5TCset cset)
  {
    throwOnError(H5Tset_cset(type_id,cset));
  }
 
 
  static void set_strpad(hid_t type_id, H5TString strpad)
  {
    throwOnError(H5Tset_strpad(type_id,strpad));
  }
 
 
  static void register(H5T_pers_t pers, string name, hid_t src_id, hid_t dst_id, H5T_conv_t func)
  {
    throwOnError(H5Tregister(pers,toStringz(name),src_id,dst_id,func));
  }
 
 
  static void unregister(H5T_pers_t pers, string name, hid_t src_id, hid_t dst_id, H5T_conv_t func)
  {
    throwOnError(H5Tunregister(pers,toStringz(name),src_id,dst_id,func));
  }
 
 
  static H5T_conv_t find(hid_t src_id, hid_t dst_id, H5T_cdata_t **pcdata)
  {
    return H5Tfind(src_id,dst_id,pcdata);
  }
 
 
  static htri_t compiler_conv(hid_t src_id, hid_t dst_id)
  {
    return H5Tcompiler_conv(src_id,dst_id);
  }
 
 
  static void convert(hid_t src_id, hid_t dst_id, size_t nelmts, void *buf, void *background, hid_t plist_id)
  {
    throwOnError(H5Tconvert(src_id,dst_id,nelmts,buf,background,plist_id));
  }
}

struct H5Z
{
    static void register(const void *cls)
    {
      throwOnError(H5Zregister(cls));
    }

    static void unregister(H5ZFilter id)
    {
      throwOnError(id);
    }

    static htri_t filter_avail(H5ZFilter id)
    {
      return H5Zfilter_avail(id);
    }
    static void get_filter_info(H5ZFilter filter, uint *filter_config_flags)
    {
      throwOnError(H5Zget_filter_info(filter, filter_config_flags));
    }
}


string[] findAttributes(hid_t obj_id)
{
    hsize_t idx=0;
    string[] ret;
    H5A.iterate2(obj_id, H5Index.Name, H5IterOrder.Inc,  &idx, &myAttributeIterator, &ret);
    return ret;
}

extern(C) herr_t  myAttributeIterator( hid_t location_id/*in*/, const char *attr_name/*in*/, const H5A_info_t *ainfo/*in*/, void *op_data/*in,out*/)
{
    auto attrib=cast(string[]*)op_data;
    (*attrib)~=ZtoString(attr_name);    
    return 0;
} 

string[] findLinks(hid_t group_id)
{
    hsize_t idx=0;
    string[] ret;
    H5L.iterate(group_id, H5Index.Name, H5IterOrder.Inc,  &idx, &myLinkIterator, &ret);
    return ret;
}

extern(C) herr_t  myLinkIterator( hid_t g_id/*in*/, const char *name/*in*/, const H5LInfo* info/*in*/, void *op_data/*in,out*/)
{
    auto linkstore=cast(string[]*)op_data;
    (*linkstore)~=ZtoString(name);    
    return 0;
} 


string[] dataSpaceContents(ubyte[] buf, hid_t type_id,hid_t space_id)
{
    hsize_t idx=0;
    dataSpaceDescriptor[] ret;
    string[] rets;
    H5D.iterate(cast(void*)buf,type_id,space_id,&dataSpaceIterator,&ret);
    foreach(item;ret)
    {
        rets~=to!string(item.elemtype) ~ " " ~ to!string(item.ndim) ~ " " ~ to!string(item.point);
    }
    return rets;
}

struct dataSpaceDescriptor
{
    hid_t elemtype;
    uint ndim;
    hsize_t point;
}

extern(C) herr_t  dataSpaceIterator(void* elem, hid_t type_id, int ndim, const hsize_t *point, void *op_data) 
{
    auto store=cast(dataSpaceDescriptor[]*)op_data;
    dataSpaceDescriptor ret_elem;
    ret_elem.elemtype=type_id;
    ret_elem.ndim=ndim;
    ret_elem.point=*point;
    (*store)~=ret_elem;
    return 0;
} 

string[] propertyList(hid_t id) 
{
    int idx=0;
    string[] ret;
    H5P.iterate(id, &idx, &myPropertyIterator, &ret);
    return ret;
}

extern(C) herr_t myPropertyIterator( hid_t id, const char *name, void *op_data )
{
    auto namestore=cast(string[]*)op_data;
    (*namestore)~=ZtoString(name);    
    return 0;
} 

string[] objectList(hid_t id)
{
    hsize_t idx=0;
    string[] ret;
    H5O.visit( id, H5Index.Name, H5IterOrder.Inc,&myObjectIterator,&ret );
    return ret;
}

extern(C) herr_t  myObjectIterator( hid_t g_id/*in*/, const char *name/*in*/, const H5OInfo* info/*in*/, void *op_data/*in,out*/)
{
    auto linkstore=cast(string[]*)op_data;
    (*linkstore)~=ZtoString(name);    
    return 0;
} 
