staload "util/SATS/util.sats"

#define ATS_DYNLOADFLAG 0 // no need for dynloading at run-time

//  wire signature
// e : inhibit signal
// a : input
// b : output
absvtype wire_vt (e: vt0p, a: vt0p, b: vt0p) = ptr

// session signature
// keep track of current delta time
absvtype session_vt = ptr

castfn session_of_lc (f: lcfun0(@(time_t, session_vt))):<> session_vt
castfn lc_of_session (s: session_vt):<> lcfun0(@(time_t, session_vt))

castfn wire_of_lc {a, b, e: vt0p}
(f: lcfun2 (time_t, a, @(either_vt(e, b), wire_vt (e, a, b)))):<> wire_vt (e, a, b)

castfn lc_of_wire {a, b, e:vt0p}
(w: wire_vt (e, a, b)):<> lcfun2 (time_t, a, @(either_vt(e, b), wire_vt (e, a, b)))

fun{a,b,e: vt0p} atsw_step_wire(w: wire_vt(e, a, b), dt: time_t, x: a): @(either_vt(e, b), wire_vt (e, a, b))

fun{a,b,e: vt0p} atsw_step_session(w: wire_vt(e, a, b), s: session_vt, x: a): @(either_vt(e, b), wire_vt (e, a, b), session_vt)

fun{a,e: vt0p} atsw_time_from(t: time_t): wire_vt(e, a, time_t)

fun atsw_clock_session(): session_vt
