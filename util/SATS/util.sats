%{#
#include "util/CATS/time.cats"
%}

#define ATS_DYNLOADFLAG 0 // no need for dynloading at run-time

vtypedef lcfun0 (a:vt0p) = () -<lin,cloptr1> a
vtypedef lcfun1 (a:vt0p, b:vt0p) = (a) -<lin,cloptr1> b
vtypedef lcfun2 (a:vt0p, b:vt0p, c: vt0p) = (a,b) -<lin,cloptr1> c
vtypedef cfun1 (a:vt0p, b:vt0p) = (a) -<cloptr1> b
vtypedef cfun2 (a:vt0p, b:vt0p, c: vt0p) = (a,b) -<cloptr1> c

dataviewtype either_vt (a: vt0p, b: vt0p) =
  Left(a,b) of (a) |
  Right(a,b) of (b)

typedef time_t = double

castfn time_of_double(x: double):<> time_t
castfn double_of_time(t: time_t):<> time_t

fun tm_clock(): time_t = "mac#atsctrb_clock"
// result in ms
fun tm_elapsed(t0: time_t, t1: time_t): double = "mac#atsctrb_elapsed"
fun tm_add(t0: time_t, t1: time_t): time_t = "mac#atsctrb_add"
fun tm_sub(t0: time_t, t1: time_t): time_t = "mac#atsctrb_sub"
