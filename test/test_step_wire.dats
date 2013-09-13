#include "share/atspre_staload_tmpdef.hats"

staload UN = "prelude/SATS/unsafe.sats"

vtypedef lcfun0 (a:vt0p) = () -<lin,cloptr1> a
vtypedef lcfun2 (a:vt0p, b:vt0p, c: vt0p) = (a,b) -<lin,cloptr1> c

dataviewtype either_vt (a: vt0p, b: vt0p) =
  Left(a,b) of (a)
  | Right(a,b) of (b)

//  --------- TIME -----------

typedef time_t = double

extern castfn time_of_double(x: double):<> time_t
extern castfn double_of_time(t: time_t):<> time_t

// ---------- SESSION -------

absvtype session_vt = ptr

extern castfn session_of_lc (f: lcfun0(@(time_t, session_vt))):<> session_vt
extern castfn lc_of_session (s: session_vt):<> lcfun0(@(time_t, session_vt))

//  --------- ERROR -----------

typedef error_t = int

extern castfn error_of_int(i: int):<> error_t
extern castfn int_of_error(e: error_t):<> int

//  --------- WIRE -----------

absvtype wire_vt (e: vt0p, a: vt0p, b: vt0p) = ptr

extern castfn wire_of_lc {a, b, e: vt0p}
(f: lcfun2 (time_t, a, @(either_vt(e, b), wire_vt (e, a, b)))):<> wire_vt (e, a, b)

extern castfn lc_of_wire {a, b, e:vt0p}
(w: wire_vt (e, a, b)):<> lcfun2 (time_t, a, @(either_vt(e, b), wire_vt (e, a, b)))

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

extern fun{a,b,e: vt0p} atsw_step_wire(w: wire_vt(e, a, b), dt: time_t, x: a): @(either_vt(e, b), wire_vt (e, a, b))
extern fun{a,b,e: vt0p} atsw_step_session(w: wire_vt(e, a, b), s: session_vt, x: a): @(either_vt(e, b), wire_vt (e, a, b), session_vt)

extern fun atsw_clock_session(): session_vt

extern fun{a,e: vt0p} atsw_time_from(t: time_t): wire_vt(e, a, time_t)

extern fun print_result(mx: either_vt(error_t, time_t)): void

extern fun test_app(): wire_vt(error_t, unit, time_t)

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

implement{a,b,e} atsw_step_wire(w, dt, x) = result where {
  val f = lc_of_wire{a,b,e}(w)
  val f = f: lcfun2(time_t, a, @(either_vt(e, b), wire_vt (e, a, b)))
  val result = f(dt, x)
  val () = cloptr_free ($UN.castvwtp0{cloptr0}(f))
}

implement{a,b,e} atsw_step_session(w, s, x) = result where {
  val update = lc_of_session(s)
  val (dt, s') = update()
  val (mx, w') = atsw_step_wire<a,b,e>(w, dt, x)
  val result = @(mx, w', s')
  val () = cloptr_free ($UN.castvwtp0{cloptr0}(update))
}

implement atsw_clock_session() = loop(tm_clock()) where {
  fun loop(t: time_t): session_vt = session_of_lc( llam () =<cloptr1> let
    val t' = tm_clock()
    val dt = tm_sub(t, t') // dela time is represented in CPU cycles (to be divided by CLOCKS_PER_SEC to obtain ms)
  in
    @(dt, loop t')
  end )
}

implement{a,e} atsw_time_from(t) = wire_of_lc{a,time_t,e}( llam (dt, _) =<cloptr1> let
  val t' = tm_add(t, dt)
in
  @(Right{e,time_t}(t'), atsw_time_from<a,e> t')
end )

implement print_result(mx) = case+ mx of
  | ~Left (i) => println! ("Inhibited -> ", int_of_error(i), " !")
  | ~Right (t) => println! ("Produced -> ", t, " !")

implement test_app() = let
  macdef T(x) = time_of_double(,(x))
in atsw_time_from<unit, error_t>(T 10.0) end

implement main0(argc, argv) = let
  extern praxi __leak {v:view} (pf: v):<> void

  val w = test_app()
  val s = atsw_clock_session()
  val (mx, w', s') = atsw_step_session<unit,time_t,error_t>(w, s, unit)
  prval () = __leak(w')
  prval () = __leak(s')
in case+ mx of
  | ~Left (e) => println! ("Inhibited -> ", int_of_error(e), " !")
  | ~Right (x) => println! ("Produced -> ", x, " ..")
end
(*
  macdef T(x) = time_of_double(,(x))
  // init dt value
  val dt0 = T 0.0
  // first step
  val t0 = tm_clock()
  val w0 = atsw_time_from<unit,error_t>(T 10.0)
  val (mx0, w1) = atsw_step_wire<unit,time_t,error_t>(w0, dt0, unit)
  val () = print_result mx0
  // second step
  val t1 = tm_clock()
  val dt1 = tm_sub(t0, t1)
  val (mx1, w2) = atsw_step_wire<unit,time_t,error_t>(w1, dt1, unit)
  val () = print_result mx1
  prval () = __leak(w2)
in end
*)
  
  
