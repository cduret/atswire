#ifndef ATSCTRB_TIME_CATS
#define ATSCTRB_TIME_CATS

#include <time.h>

#define atsctrb_clock get_clock
#define atsctrb_elapsed get_elapsed
#define atsctrb_add add_time
#define atsctrb_sub sub_time

static double get_clock() {
  clock_t t = clock();
  return (double)t;
}

static double get_elapsed(double start, double end) {
  return (end - start) / CLOCKS_PER_SEC;
}

static double add_time(double t0, double t1) {
  return t0 + t1;
}

static double sub_time(double t0, double t1) {
  return t1 - t0;
}

#endif
