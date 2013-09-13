#include "share/atspre_staload_tmpdef.hats"

staload "wire/SATS/atswire.sats"
staload "util/SATS/util.sats"


staload _ = "wire/DATS/atswire.dats"

typedef error_t = int

extern castfn error_of_int(i: int):<> error_t
extern castfn int_of_error(e: error_t):<> int

extern fun test_app(): wire_vt(error_t, unit, time_t)

implement test_app() = let
  macdef T(x) = time_of_double(,(x))
in atsw_time_from<unit, error_t>(T 10.0) end

implement main0(argc, argv) = loop(test_app(), atsw_clock_session()) where {
  fun loop(w: wire_vt(error_t, unit, time_t), s: session_vt): void = let
    val (mx, w', s') = atsw_step_session<unit,time_t,error_t>(w, s, unit)
    val () = ( case+ mx of
      | ~Left (e) => println! ("Inhibited -> ", int_of_error(e), " !")
      | ~Right (x) => println! ("Produced -> ", x, " ..") ): void
  in loop(w', s') end
}

