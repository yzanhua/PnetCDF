dnl Process this m4 file to produce 'C' language file.
dnl
dnl If you see this line, you can ignore the next one.
/* Do not edit this file. It is produced from the corresponding .m4 source */
dnl
/*
 *  Copyright (C) 2003, Northwestern University and Argonne National Laboratory
 *  See COPYRIGHT notice in top-level directory.
 */
/* $Id: bput_var.m4 1299 2013-06-11 19:54:50Z wkliao $ */

#if HAVE_CONFIG_H
# include <ncconfig.h>
#endif

#include "nc.h"
#include "ncx.h"
#include <mpi.h>
#include <stdio.h>
#include <unistd.h>
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#include <assert.h>

#include "ncmpidtype.h"
#include "macro.h"


/*----< ncmpi_bput_var() >----------------------------------------------------*/
int
ncmpi_bput_var(int           ncid,
               int           varid,
               const void   *buf,
               MPI_Offset    bufcount,
               MPI_Datatype  buftype,
               int          *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *start, *count;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    GET_FULL_DIMENSIONS(start, count)

    /* bput_var is a special case of bput_vara */
    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, bufcount, buftype, reqid,
                                 WRITE_REQ, 1);
    if (varp->ndims > 0) NCI_Free(start);

    return status;
}


dnl
dnl BPUT_VAR_TYPE(ncid, varid, op, reqid)
dnl
define(`BPUT_VAR_TYPE',dnl
`dnl
/*----< ncmpi_bput_var_$1() >-------------------------------------------------*/
int
ncmpi_bput_var_$1(int       ncid,
                  int       varid,
                  const $2 *op,
                  int      *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems, *start, *count;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    GET_TOTAL_NUM_ELEMENTS(nelems)
    GET_FULL_DIMENSIONS(start, count)

    /* bput_var is a special case of bput_varm */
    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)op, nelems, $3, reqid,
                                 WRITE_REQ, 1);
    if (varp->ndims > 0) NCI_Free(start);

    return status;
}
')dnl

BPUT_VAR_TYPE(text,      char,               MPI_CHAR)
BPUT_VAR_TYPE(schar,     schar,              MPI_BYTE)
BPUT_VAR_TYPE(uchar,     uchar,              MPI_UNSIGNED_CHAR)
BPUT_VAR_TYPE(short,     short,              MPI_SHORT)
BPUT_VAR_TYPE(ushort,    ushort,             MPI_UNSIGNED_SHORT)
BPUT_VAR_TYPE(int,       int,                MPI_INT)
BPUT_VAR_TYPE(uint,      uint,               MPI_UNSIGNED)
BPUT_VAR_TYPE(long,      long,               MPI_LONG)
BPUT_VAR_TYPE(float,     float,              MPI_FLOAT)
BPUT_VAR_TYPE(double,    double,             MPI_DOUBLE)
BPUT_VAR_TYPE(longlong,  long long,          MPI_LONG_LONG_INT)
BPUT_VAR_TYPE(ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)
dnl BPUT_VAR_TYPE(string, char*,             MPI_CHAR)
dnl string is not yet supported


/*----< ncmpi_bput_var1() >---------------------------------------------------*/
int
ncmpi_bput_var1(int               ncid,
                int               varid,
                const MPI_Offset *start,
                const void       *buf,
                MPI_Offset        bufcount,
                MPI_Datatype      buftype,
                int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *count;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    status = NCcoordck(ncp, varp, start);
    if (status != NC_NOERR) return status;
    GET_ONE_COUNT(count)

    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, bufcount, buftype, reqid,
                                 WRITE_REQ, 1);
    if (varp->ndims > 0) NCI_Free(count);
    return status;
}

dnl
dnl BPUT_VAR1_TYPE(ncid, varid, start, op, reqid)
dnl
define(`BPUT_VAR1_TYPE',dnl
`dnl
/*----< ncmpi_bput_var1_$1() >------------------------------------------------*/
int
ncmpi_bput_var1_$1(int               ncid,
                   int               varid,
                   const MPI_Offset  start[],
                   const $2         *op,
                   int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *count;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    status = NCcoordck(ncp, varp, start);
    if (status != NC_NOERR) return status;
    GET_ONE_COUNT(count)

    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)op, 1, $3, reqid,
                                 WRITE_REQ, 1);
    if (varp->ndims > 0) NCI_Free(count);
    return status;
}
')dnl

BPUT_VAR1_TYPE(text,      char,               MPI_CHAR)
BPUT_VAR1_TYPE(schar,     schar,              MPI_BYTE)
BPUT_VAR1_TYPE(uchar,     uchar,              MPI_UNSIGNED_CHAR)
BPUT_VAR1_TYPE(short,     short,              MPI_SHORT)
BPUT_VAR1_TYPE(ushort,    ushort,             MPI_UNSIGNED_SHORT)
BPUT_VAR1_TYPE(int,       int,                MPI_INT)
BPUT_VAR1_TYPE(uint,      uint,               MPI_UNSIGNED)
BPUT_VAR1_TYPE(long,      long,               MPI_LONG)
BPUT_VAR1_TYPE(float,     float,              MPI_FLOAT)
BPUT_VAR1_TYPE(double,    double,             MPI_DOUBLE)
BPUT_VAR1_TYPE(longlong,  long long,          MPI_LONG_LONG_INT)
BPUT_VAR1_TYPE(ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)
dnl BPUT_VAR1_TYPE(string, char*,             MPI_CHAR)
dnl string is not yet supported


/*----< ncmpi_bput_vara() >---------------------------------------------------*/
int
ncmpi_bput_vara(int               ncid,
                int               varid,
                const MPI_Offset *start,
                const MPI_Offset *count,
                const void       *buf,
                MPI_Offset        bufcount,
                MPI_Datatype      buftype,
                int              *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    status = NCcoordck(ncp, varp, start);
    if (status != NC_NOERR) return status;
    status = NCedgeck(ncp, varp, start, count);
    if (status != NC_NOERR) return status;

    return ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                               (void*)buf, bufcount, buftype, reqid,
                               WRITE_REQ, 1);
}

dnl
dnl BPUT_VARA_TYPE(ncid, varid, start, count, op, reqid)
dnl
define(`BPUT_VARA_TYPE',dnl
`dnl
/*----< ncmpi_bput_vara_$1() >------------------------------------------------*/
int
ncmpi_bput_vara_$1(int               ncid,
                   int               varid,
                   const MPI_Offset  start[],
                   const MPI_Offset  count[],
                   const $2         *op,
                   int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    status = NCcoordck(ncp, varp, start);
    if (status != NC_NOERR) return status;
    status = NCedgeck(ncp, varp, start, count);
    if (status != NC_NOERR) return status;
    GET_NUM_ELEMENTS(nelems)

    return ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                               (void*)op, nelems, $3, reqid,
                               WRITE_REQ, 1);
}
')dnl

BPUT_VARA_TYPE(text,      char,               MPI_CHAR)
BPUT_VARA_TYPE(schar,     schar,              MPI_BYTE)
BPUT_VARA_TYPE(uchar,     uchar,              MPI_UNSIGNED_CHAR)
BPUT_VARA_TYPE(short,     short,              MPI_SHORT)
BPUT_VARA_TYPE(ushort,    ushort,             MPI_UNSIGNED_SHORT)
BPUT_VARA_TYPE(int,       int,                MPI_INT)
BPUT_VARA_TYPE(uint,      uint,               MPI_UNSIGNED)
BPUT_VARA_TYPE(long,      long,               MPI_LONG)
BPUT_VARA_TYPE(float,     float,              MPI_FLOAT)
BPUT_VARA_TYPE(double,    double,             MPI_DOUBLE)
BPUT_VARA_TYPE(longlong,  long long,          MPI_LONG_LONG_INT)
BPUT_VARA_TYPE(ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)
dnl BPUT_VARA_TYPE(string, char*,             MPI_CHAR)
dnl string is not yet supported


/*----< ncmpi_bput_vars() >---------------------------------------------------*/
int
ncmpi_bput_vars(int               ncid,
                int               varid,
                const MPI_Offset  start[],
                const MPI_Offset  count[],
                const MPI_Offset  stride[],
                const void       *buf,
                MPI_Offset        bufcount,
                MPI_Datatype      buftype,
                int              *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    status = NCcoordck(ncp, varp, start);
    if (status != NC_NOERR) return status;
    status = NCstrideedgeck(ncp, varp, start, count, stride);
    if (status != NC_NOERR) return status;

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, NULL,
                               (void*)buf, bufcount, buftype, reqid,
                               WRITE_REQ, 1);
}

dnl
dnl BPUT_VARS_TYPE(ncid, varid, start, count, stride, op, reqid)
dnl
define(`BPUT_VARS_TYPE',dnl
`dnl
/*----< ncmpi_bput_vars_$1() >------------------------------------------------*/
int
ncmpi_bput_vars_$1(int               ncid,
                   int               varid,
                   const MPI_Offset  start[],
                   const MPI_Offset  count[],
                   const MPI_Offset  stride[],
                   const $2         *op,
                   int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    status = NCcoordck(ncp, varp, start);
    if (status != NC_NOERR) return status;
    status = NCstrideedgeck(ncp, varp, start, count, stride);
    if (status != NC_NOERR) return status;
    GET_NUM_ELEMENTS(nelems)

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, NULL,
                               (void*)op, nelems, $3, reqid,
                               WRITE_REQ, 1);
}
')dnl

BPUT_VARS_TYPE(text,      char,               MPI_CHAR)
BPUT_VARS_TYPE(schar,     schar,              MPI_BYTE)
BPUT_VARS_TYPE(uchar,     uchar,              MPI_UNSIGNED_CHAR)
BPUT_VARS_TYPE(short,     short,              MPI_SHORT)
BPUT_VARS_TYPE(ushort,    ushort,             MPI_UNSIGNED_SHORT)
BPUT_VARS_TYPE(int,       int,                MPI_INT)
BPUT_VARS_TYPE(uint,      uint,               MPI_UNSIGNED)
BPUT_VARS_TYPE(long,      long,               MPI_LONG)
BPUT_VARS_TYPE(float,     float,              MPI_FLOAT)
BPUT_VARS_TYPE(double,    double,             MPI_DOUBLE)
BPUT_VARS_TYPE(longlong,  long long,          MPI_LONG_LONG_INT)
BPUT_VARS_TYPE(ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)
dnl BPUT_VARS_TYPE(string, char*,             MPI_CHAR)
dnl string is not yet supported

/*----< ncmpi_bput_varm() >---------------------------------------------------*/
int
ncmpi_bput_varm(int               ncid,
                int               varid,
                const MPI_Offset  start[],
                const MPI_Offset  count[],
                const MPI_Offset  stride[],
                const MPI_Offset  imap[],
                const void       *buf,
                MPI_Offset        bufcount,
                MPI_Datatype      buftype,
                int              *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    status = NCcoordck(ncp, varp, start);
    if (status != NC_NOERR) return status;
    status = NCstrideedgeck(ncp, varp, start, count, stride);
    if (status != NC_NOERR) return status;

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, imap,
                               (void*)buf, bufcount, buftype, reqid,
                               WRITE_REQ, 1);
}

dnl
dnl BPUT_VARM_TYPE(ncid, varid, start, count, stride, imap, op, reqid)
dnl
define(`BPUT_VARM_TYPE',dnl
`dnl
/*----< ncmpi_bput_varm_$1() >------------------------------------------------*/
int
ncmpi_bput_varm_$1(int               ncid,
                   int               varid,
                   const MPI_Offset  start[],
                   const MPI_Offset  count[],
                   const MPI_Offset  stride[],
                   const MPI_Offset  imap[],
                   const $2         *op,
                   int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems;

    *reqid = NC_REQ_NULL;
    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, INDEP_COLL_IO, status)

    if (ncp->abuf == NULL) return NC_ENULLABUF;
    status = NCcoordck(ncp, varp, start);
    if (status != NC_NOERR) return status;
    status = NCstrideedgeck(ncp, varp, start, count, stride);
    if (status != NC_NOERR) return status;
    GET_NUM_ELEMENTS(nelems)

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, imap,
                               (void*)op, nelems, $3, reqid,
                               WRITE_REQ, 1);
}
')dnl

BPUT_VARM_TYPE(text,      char,               MPI_CHAR)
BPUT_VARM_TYPE(schar,     schar,              MPI_BYTE)
BPUT_VARM_TYPE(uchar,     uchar,              MPI_UNSIGNED_CHAR)
BPUT_VARM_TYPE(short,     short,              MPI_SHORT)
BPUT_VARM_TYPE(ushort,    ushort,             MPI_UNSIGNED_SHORT)
BPUT_VARM_TYPE(int,       int,                MPI_INT)
BPUT_VARM_TYPE(uint,      uint,               MPI_UNSIGNED)
BPUT_VARM_TYPE(long,      long,               MPI_LONG)
BPUT_VARM_TYPE(float,     float,              MPI_FLOAT)
BPUT_VARM_TYPE(double,    double,             MPI_DOUBLE)
BPUT_VARM_TYPE(longlong,  long long,          MPI_LONG_LONG_INT)
BPUT_VARM_TYPE(ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)
dnl BPUT_VARM_TYPE(string, char*,             MPI_CHAR)
dnl string is not yet supported

