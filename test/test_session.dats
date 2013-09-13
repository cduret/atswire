#include "share/atspre_staload_tmpdef.hats"

staload UN = "prelude/SATS/unsafe.sats"

vtypedef lcfun0 (a:vt0p) = () -<lin,cloptr1> a

// ---------- SESSION -------

absvtype session_vt(a: vt0p) = ptr

extern castfn session_of_lc{a: vt0p} (f: lcfun0(@(a, session_vt a))):<> session_vt a
extern castfn lc_of_session{a: vt0p} (s: session_vt a):<> lcfun0(@(a, session_vt a))

//  --------- TIME -----------

typedef time_t = double

extern castfn time_of_double(x: double):<> time_t
extern castfn double_of_time(t: time_t):<> time_t

%{^
#include <time.h>

#define atsctrb_clock get_clock

static double get_clock() {
  clock_t t = clock();
  return (double)t;
}
%}

extern fun tm_clock(): time_t = "mac#atsctrb_clock"
extern fun tm_add(t0: time_t, t1: time_t): time_t
extern fun tm_sub(t0: time_t, t1: time_t): time_t

extern fun atsw_clock_session(): session_vt time_t

implement tm_add(t0: time_t, t1: time_t): time_t = result where {
  val t0d = double_of_time t0
  val t1d = double_of_time t1
  val result = time_of_double( t0d + t1d )
}

implement tm_sub(t0: time_t, t1: time_t): time_t = result where {
  val t0d = double_of_time t0
  val t1d = double_of_time t1
  val result = time_of_double( t1d - t0d )
}

implement atsw_clock_session() = loop(tm_clock()) where {
  fun loop(t: time_t): session_vt time_t = session_of_lc{time_t}( llam () =<cloptr1> let
    val t' = tm_clock()
    val dt = tm_sub(t, t') // dela time is represented in CPU cycles (to be divided by CLOCKS_PER_SEC to obtain ms)
  in
    @(dt, loop t')
  end )
}

implement main0(argc, argv) = let
  extern praxi __leak {v:view} (pf: v):<> void

  val s0 = atsw_clock_session()
  val update = lc_of_session{time_t}(s0)
  val (dt, s1) = update()
  val () = println! ("-> ", dt)
  val () = cloptr_free ($UN.castvwtp0{cloptr0}(update))
  prval () = __leak(s1)
in end
