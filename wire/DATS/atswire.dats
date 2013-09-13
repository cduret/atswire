staload "wire/SATS/atswire.sats"

staload "util/SATS/util.sats"

staload UN = "prelude/SATS/unsafe.sats"

#define ATS_DYNLOADFLAG 0 // no need for dynloading at run-time

implement{a,b,e} atsw_step_wire(w, dt, x) = result where {
  val f = lc_of_wire{a,b,e}(w)
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

implement atsw_clock_session() = init where {
  macdef T(x) = time_of_double(,(x))
  fun loop(t: time_t): session_vt = session_of_lc( llam () =<cloptr1> let
    val t' = tm_clock()
    val dt = tm_sub(t, t') // dt is in CPU cycles (to be divided by CLOCKS_PER_SEC to obtain ms)
  in
    @(dt, loop t')
  end )
  val init = session_of_lc( llam () =<cloptr1> let
    val t0 = tm_clock()
  in
    @(T 0.0, loop t0)
  end )
}

implement{a,e} atsw_time_from(t) = wire_of_lc{a,time_t,e}( llam (dt, _) =<cloptr1> let
  val t' = tm_add(t, dt)
in
  @(Right{e,time_t}(t'), atsw_time_from<a,e> t')
end )
