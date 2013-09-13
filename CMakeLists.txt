CMAKE_MINIMUM_REQUIRED (VERSION 2.8)
PROJECT (ATSWIRE C)

set (CMAKE_C_FLAGS "-I. -I/usr/local/include -DATS_MEMALLOC_LIBC")

FIND_PACKAGE (PATS REQUIRED)
IF (NOT PATS_FOUND)
	MESSAGE (FATAL_ERROR ”PATS Not Found!”)
ENDIF ()

PATS_COMPILE (TEST_SRC
              util/SATS/util.sats
              wire/SATS/atswire.sats
              wire/DATS/atswire.dats
              main_example.dats)

ADD_EXECUTABLE (atswire_example ${TEST_SRC})
