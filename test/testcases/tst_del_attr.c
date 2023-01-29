/*
 *  Copyright (C) 2015, Northwestern University and Argonne National Laboratory
 *  See COPYRIGHT notice in top-level directory.
 *
 *  $Id$
 */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * This program tests conflicted in-memory data types against external data
 * types and see if the correct error codes were returned.
 *
 * The compile and run commands are given below.
 *
 *    % mpicc -g -o check_type check_type.c -lpnetcdf
 *
 *    % mpiexec -l -n 1 check_type testfile.nc
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h> /* strcasecmp() */
#include <libgen.h> /* basename() */
#include <pnetcdf.h>

#include <testutils.h>

#define ATTR_EXP_ERR(expect_err,name) { \
    if (err != expect_err) { \
        printf("Error at line %d in %s: attr=%s err=%s\n", \
               __LINE__,__FILE__,name,ncmpi_strerrno(err)); \
        nerrs++; \
    }  \
}

static int
tst_fmt(char *filename, int cmode)
{
    char *attr_name[12] = {"attr_NC_NAT",
                           "attr_NC_BYTE",
                           "attr_NC_CHAR",
                           "attr_NC_SHORT",
                           "attr_NC_INT",
                           "attr_NC_FLOAT",
                           "attr_NC_DOUBLE",
                           "attr_NC_UBYTE",
                           "attr_NC_USHORT",
                           "attr_NC_UINT",
                           "attr_NC_INT64",
                           "attr_NC_UINT64"};
    char buf[1024];
    int i, j, err, nerrs=0, ncid, max_type;

    if (cmode == 0 || cmode == NC_64BIT_OFFSET || cmode & NC_CLASSIC_MODEL)
        max_type = NC_DOUBLE;
    else
        max_type = NC_UINT64;

    for (i=0; i<1024; i++) buf[i]=0;

    for (i=NC_BYTE; i<=max_type; i++) {
        /* create a new file (or truncate it to 0 length) */
        cmode |= NC_CLOBBER;
        err = ncmpi_create(MPI_COMM_WORLD, filename, cmode, MPI_INFO_NULL, &ncid); CHECK_ERR

        if (i == NC_CHAR) {
            for (j=0; j<3; j++) buf[j]='a'+j;
            err = ncmpi_put_att_text(ncid, NC_GLOBAL, attr_name[i], 3, buf); CHECK_ERR
        }
        else
            err = ncmpi_put_att(ncid, NC_GLOBAL, attr_name[i], i, 3, buf); CHECK_ERR
        ATTR_EXP_ERR(NC_NOERR, attr_name[i])

        err = ncmpi_close(ncid); CHECK_ERR

        /* reopen the file */
        err = ncmpi_open(MPI_COMM_WORLD, filename, NC_WRITE, MPI_INFO_NULL, &ncid); CHECK_ERR
        err = ncmpi_redef(ncid); CHECK_ERR

        err = ncmpi_del_att(ncid, NC_GLOBAL, attr_name[i]); CHECK_ERR
        ATTR_EXP_ERR(NC_NOERR, attr_name[i])

        err = ncmpi_close(ncid); CHECK_ERR

        /* This deletion of attribute will make the file size larger than
         * expected, i.e. larger than if no attribute is ever created. It is
         * not a fatal error. The file is still a valid NetCDF file. We should
         * expect running ncvalidator to print a warning message, such as
         * "file size (80) is larger than expected (48)!"
         */
    }
    return nerrs;
}

int main(int argc, char* argv[])
{
    char filename[256], *hint_value;
    int err, nerrs=0, rank, bb_enabled=0;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (argc > 2) {
        if (!rank) printf("Usage: %s [filename]\n",argv[0]);
        MPI_Finalize();
        return 1;
    }
    if (argc == 2) snprintf(filename, 256, "%s", argv[1]);
    else           strcpy(filename, "testfile.nc");
    MPI_Bcast(filename, 256, MPI_CHAR, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        char *cmd_str = (char*)malloc(strlen(argv[0]) + 256);
        sprintf(cmd_str, "*** TESTING C   %s for testing delete attr ", basename(argv[0]));
        printf("%-66s ------ ", cmd_str); fflush(stdout);
        free(cmd_str);
    }

    /* check whether burst buffering is enabled */
    if (inq_env_hint("nc_burst_buf", &hint_value)) {
        if (strcasecmp(hint_value, "enable") == 0) bb_enabled = 1;
        free(hint_value);
    }

    nerrs += tst_fmt(filename, 0);
    nerrs += tst_fmt(filename, NC_64BIT_OFFSET);
    if (!bb_enabled) {
#ifdef ENABLE_NETCDF4
        nerrs += tst_fmt(filename, NC_NETCDF4);
        nerrs += tst_fmt(filename, NC_NETCDF4 | NC_CLASSIC_MODEL);
#endif
    }
    nerrs += tst_fmt(filename, NC_64BIT_DATA);

    /* check if PnetCDF freed all internal malloc */
    MPI_Offset malloc_size, sum_size;
    err = ncmpi_inq_malloc_size(&malloc_size);
    if (err == NC_NOERR) {
        MPI_Reduce(&malloc_size, &sum_size, 1, MPI_OFFSET, MPI_SUM, 0, MPI_COMM_WORLD);
        if (rank == 0 && sum_size > 0)
            printf("heap memory allocated by PnetCDF internally has %lld bytes yet to be freed\n",
                   sum_size);
        if (malloc_size > 0) ncmpi_inq_malloc_list();
    }

    MPI_Allreduce(MPI_IN_PLACE, &nerrs, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    if (rank == 0) {
        if (nerrs) printf(FAIL_STR,nerrs);
        else       printf(PASS_STR);
    }

    MPI_Finalize();

    return (nerrs > 0);
}
