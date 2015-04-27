/*
 * cobyla.i -
 *
 * Yorick interface to COBYLA.
 *
 * Copyright (c) 2015, Éric Thiébaut
 *
 * This file is part of the `Algorithms` (https://github.com/emmt/Algorithms)
 * project.  Read the accompanying `LICENSE` file for details.
 */

if (is_func(plug_in)) plug_in, "ycobyla";

local COBYLA_SUCCESS, COBYLA_CALC_FC, COBYLA_ROUNDING_ERRORS;
local COBYLA_TOO_MANY_EVALUATIONS, COBYLA_BAD_ADDRESS;
local COBYLA_CORRUPTED;
extern cobyla_create;
extern cobyla_iterate;
/* DOCUMENT ctx = cobyla_create(n, m, rhobeg, rhoend, iprint, maxfun);
         or status = cobyla_iterate(ctx, f, x, c);

     The function `cobyla_create` makes a new instance for Mike Powell's COBYLA
     algorithm for  minimizing a function  of a  few variables.  The  method is
     "derivatives free" (only the function  values are needed) and accounts for
     constraints on  the variables.   N is  the number of  variables, M  is the
     number of (inequality) constraints, RHOBEG  and RHOEND are the initial and
     final size of the trust region, IPRINT control the verbosity of the method
     (see below) and MAXFUN is the maximum number of function evaluations.

     IPRINT  should be  set to  0, 1,  2  or 3,  which controls  the amount  of
     printing  during the  calculation.  Specifically,  there is  no output  if
     IPRINT=0  and there  is  output only  at  the end  of  the calculation  if
     IPRINT=1.  Otherwise each new value of RHO and SIGMA is printed.  Further,
     the vector  of variables  and some function  information are  given either
     when RHO  is reduced or  when each  new value of  F(X) is computed  in the
     cases IPRINT=2 or IPRINT=3 respectively.

     The function `cobyla_iterate` performs an iteration of the algorithm given
     F the function value at X the current variables and C the constraints.

     Typical usage is:

     >   ctx = cobyla_create(n, m, rhobeg, rhoend, iprint, maxfun);
     >   x = ...; // initial solution
     >   while (ctx.status == COBYLA_CALC_FC) {
     >     f = ...; // compute function value at X
     >     c = ...; // compute constraints at X, if any
     >     cobyla_iterate, ctx, f, x, c;
     >   }
     >   if (ctx.status != COBYLA_SUCCESS) {
     >     error, swrite(format="Something wrong occured in COBYLA: %s",
     >                   ctx.reason);

     If there are no constraints (M = 0), argument C must be [] (void)
     or can be omitted.

   REFERENCES
     The algorithm is described in:

         M.J.D. Powell, "A direct search optimization method that models the
             objective and constraint functions by linear interpolation," in
             Advances in Optimization and Numerical Analysis Mathematics and
             Its Applications, vol. 275 (eds. Susana Gomez and Jean-Pierre
             Hennart), Kluwer Academic Publishers, pp. 51-67 (1994).

   SEE ALSO: cobyla_restart, cobyla_reason.
 */

extern cobyla_restart;
/* DOCUMENT cobyla_restart(ctx);
     Restart COBYLA algorithm using the same parameters.  The return value is
     the new status of the algorithm, see `cobyla_get_status` for details.

   SEE ALSO: cobyla_create.
 */

extern cobyla_reason;
/* DOCUMENT cobyla_reason(status);
     Get a textual explanation of the status returned by COBYLA.
   SEE ALSO: cobyla_create.
 */

extern cobyla_init;
/* DOCUMENT cobyla_init;
     Initialize COBYLA interface.  It is automatically called when COBYLA
     plugin is loaded but it can safely be called again to reinitialze
     constants.
   SEE ALSO: cobyla_create.
 */
cobyla_init;

/*---------------------------------------------------------------------------*/
/* TESTING */

/* Minimization of a simple quadratic function of two variables. */
func cobyla_test1(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "Simple quadratic";
    n = 2;
    m = 0;
    xinit = array(1.0, n);
    xopt = [-1.0, 0.0];
  } else {
    r1 = x(1) + 1.0;
    r2 = x(2);
    fc = 10.0*(r1*r1) + (r2*r2);
    return fc;
  }
}

/* Easy two dimensional minimization in unit circle. */
func cobyla_test2(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "2D unit circle calculation";
    n = 2;
    m = 1;
    xinit = array(1.0, n);
    t = sqrt(0.5);
    xopt = [t, -t];
  } else {
    fc = x(1)*x(2);
    c(1) = 1.0 - x(1)*x(1) - x(2)*x(2);
    return fc;
  }
}

/* Easy three dimensional minimization in ellipsoid. */
func cobyla_test3(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "3D ellipsoid calculation";
    n = 3;
    m = 1;
    xinit = array(1.0, n);
    xopt = [1.0/sqrt(3.0), 1.0/sqrt(6.0), -0.33333333333333331];
  } else {
    fc = x(1)*x(2)*x(3);
    c(1) = (1.0 - (x(1)*x(1)) - 2.0*(x(2)*x(2))
            - 3.0*(x(3)*x(3)));
    return fc;
  }
}

/* Weak version of Rosenbrock's problem. */
func cobyla_test4(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "Weak Rosenbrock";
    n = 2;
    m = 0;
    xinit = array(1.0, n);
    xopt = [-1.0, 1.0];
  } else {
    r2 = x(1);
    r1 = r2*r2 - x(2);
    r3 = x(1) + 1.0;
    fc = r1*r1 + r3*r3;
    return fc;
  }
}

/* Intermediate version of Rosenbrock's problem. */
func cobyla_test5(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "Intermediate Rosenbrock";
    n = 2;
    m = 0;
    xinit = array(1.0, n);
    xopt = [-1.0, 1.0];
  } else {
    r2 = x(1);
    r1 = r2*r2 - x(2);
    r3 = x(1) + 1.0;
    fc = r1*r1*10.0 + r3*r3;
    return fc;
  }
}

/* This problem is taken from Fletcher's book Practical Methods of
   Optimization and has the equation number (9.1.15). */
func cobyla_test6(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "Equation (9.1.15) in Fletcher";
    n = 2;
    m = 2;
    t = sqrt(0.5);
    xopt = [t, t];
    xinit = array(1.0, n);
  } else {
    fc = -x(1) - x(2);
    r1 = x(1);
    c(1) = x(2) - r1*r1;
    r1 = x(1);
    r2 = x(2);
    c(2) = 1.0 - r1*r1 - r2*r2;
    return fc;
  }
}

/* This problem is taken from Fletcher's book Practical Methods of
   Optimization and has the equation number (14.4.2). */
func cobyla_test7(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "Equation (14.4.2) in Fletcher";
    n = 3;
    m = 3;
    xinit = array(1.0, n);
    xopt = [0.0, -3.0, -3.0];
   } else {
    fc = x(3);
    c(1) = x(1)*5.0 - x(2) + x(3);
    r1 = x(1);
    r2 = x(2);
    c(2) = x(3) - r1*r1 - r2*r2 - x(2)*4.0;
    c(3) = x(3) - x(1)*5.0 - x(2);
    return fc;
  }
}

/* This problem is taken from page 66 of Hock and Schittkowski's book Test
   Examples for Nonlinear Programming Codes. It is their test problem
   Number 43, and has the name Rosen-Suzuki. */
func cobyla_test8(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "Rosen-Suzuki";
    n = 4;
    m = 3;
    xinit = array(1.0, n);
    xopt = [ 0.0, 1.0, 2.0, -1.0];
  } else {
    r1 = x(1);
    r2 = x(2);
    r3 = x(3);
    r4 = x(4);
    fc = (r1*r1 + r2*r2 + r3*r3*2.0 + r4*r4 - x(1)*5.0 - x(2)*5.0
          - x(3)*21.0 + x(4)*7.0);
    r1 = x(1);
    r2 = x(2);
    r3 = x(3);
    r4 = x(4);
    c(1) = 8.0 - r1*r1 - r2*r2 - r3*r3 - r4*r4 - x(1) + x(2) - x(3) + x(4);
    r1 = x(1);
    r2 = x(2);
    r3 = x(3);
    r4 = x(4);
    c(2) = 10.0 - r1*r1 - r2*r2*2.0 - r3*r3 - r4*r4*2.0 + x(1) + x(4);
    r1 = x(1);
    r2 = x(2);
    r3 = x(3);
    c(3) = 5.0 - r1*r1*2.0 - r2*r2 - r3*r3 - x(1)*2.0 + x(2) + x(4);
    return fc;
  }
}

/* This problem is taken from page 111 of Hock and Schittkowski's book Test
   Examples for Nonlinear Programming Codes. It is their test problem
   Number 100. */
func cobyla_test9(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "Hock and Schittkowski 100";
    n = 7;
    m = 4;
    xinit = array(1.0, n);
    xopt = [ 2.330499, 1.951372, -0.4775414, 4.365726, -0.624487,
             1.038131, 1.594227];
  } else {
    r1 = x(1) - 10.0;
    r2 = x(2) - 12.0;
    r3 = x(3);
    r3 *= r3;
    r4 = x(4) - 11.0;
    r5 = x(5);
    r5 *= r5;
    r6 = x(6);
    r7 = x(7);
    r7 *= r7;
    fc = (r1*r1 + r2*r2*5.0 + r3*r3 + r4*r4*3.0 + r5*(r5*r5)*10.0
          + r6*r6*7.0 + r7*r7 - x(6)*4.0*x(7) - x(6)*10.0 - x(7)*8.0);
    r1 = x(1);
    r2 = x(2);
    r2 *= r2;
    r3 = x(4);
    c(1) = (127.0 - r1*r1*2.0 - r2*r2*3.0 - x(3) - r3*r3*4.0
            - x(5)*5.0);
    r1 = x(3);
    c(2) = 282.0 - x(1)*7.0 - x(2)*3.0 - r1*r1*10.0 - x(4) + x(5);
    r1 = x(2);
    r2 = x(6);
    c(3) = 196.0 - x(1)*23.0 - r1*r1 - r2*r2*6.0 + x(7)*8.0;
    r1 = x(1);
    r2 = x(2);
    r3 = x(3);
    c(4) = (r1*r1*-4.0 - r2*r2 + x(1)*3.0*x(2) - r3*r3*2.0
            - x(6)*5.0 + x(7)*11.0);
    return fc;
  }
}
/* This problem is taken from page 415 of Luenberger's book Applied
   Nonlinear Programming. It is to maximize the area of a hexagon of unit
   diameter. */
func cobyla_test10(x, c)
{
  if (is_void(x)) {
    extern n, m, xinit, xopt, name;
    name = "Hexagon area";
    n = 9;
    m = 14;
    xinit = array(1.0, n);
    xopt = [];
  } else {
    fc = -0.5*(x(1)*x(4) - x(2)*x(3) + x(3)*x(9) - x(5)*x(9) + x(5)*x(8)
               - x(6)*x(7));
    r1 = x(3);
    r2 = x(4);
    c(1) = 1.0 - r1*r1 - r2*r2;
    r1 = x(9);
    c(2) = 1.0 - r1*r1;
    r1 = x(5);
    r2 = x(6);
    c(3) = 1.0 - r1*r1 - r2*r2;
    r1 = x(1);
    r2 = x(2) - x(9);
    c(4) = 1.0 - r1*r1 - r2*r2;
    r1 = x(1) - x(5);
    r2 = x(2) - x(6);
    c(5) = 1.0 - r1*r1 - r2*r2;
    r1 = x(1) - x(7);
    r2 = x(2) - x(8);
    c(6) = 1.0 - r1*r1 - r2*r2;
    r1 = x(3) - x(5);
    r2 = x(4) - x(6);
    c(7) = 1.0 - r1*r1 - r2*r2;
    r1 = x(3) - x(7);
    r2 = x(4) - x(8);
    c(8) = 1.0 - r1*r1 - r2*r2;
    r1 = x(7);
    r2 = x(8) - x(9);
    c(9) = 1.0 - r1*r1 - r2*r2;
    c(10) = x(1)*x(4) - x(2)*x(3);
    c(11) = x(3)*x(9);
    c(12) = -x(5)*x(9);
    c(13) = x(5)*x(8) - x(6)*x(7);
    c(14) = x(9);
    return fc;
  }
}

func cobyla_test10_xopt(x)
{
  xopt = array(double, dimsof(x));
  tempa = x(1) + x(3) + x(5) + x(7);
  tempb = x(2) + x(4) + x(6) + x(8);
  tempc = 0.5/sqrt(tempa * tempa + tempb * tempb);
  tempd = tempc*sqrt(3.0);
  xopt(1) = tempd*tempa + tempc*tempb;
  xopt(2) = tempd*tempb - tempc*tempa;
  xopt(3) = tempd*tempa - tempc*tempb;
  xopt(4) = tempd*tempb + tempc*tempa;
  xopt(5) = xopt(1);
  xopt(6) = xopt(2);
  xopt(7) = xopt(3);
  xopt(8) = xopt(4);
  return xopt;
}

func cobyla_test(prob)
{
  if (is_void(prob)) prob = indgen(1:10);
  iprint = 1;
  maxfun = 2000;

  for (i = 1; i <= numberof(prob); ++i) {
    /* Problem number and driver. */
    p = prob(i);
    fn = symbol_def(swrite(format="cobyla_test%d", p));

    /* Query problem size, initial and true solution. */
    local n, m, xinit, xopt, name;
    fn;
    write, format = "\n       Output from test problem %d (%s)\n", p, name;

    for (icase = 1; icase <= 2; ++icase) {
      rhobeg = 0.5;
      rhoend = ((icase == 2) ? 1e-4 : 0.001);

      /* Solve problem. */
      c = (m ? array(double, m) : []);
      x = xinit;
      ctx = cobyla_create(n, m, rhobeg, rhoend, iprint, maxfun);
      while (ctx.status == COBYLA_CALC_FC) {
        f = fn(x, c);
        cobyla_iterate, ctx, f, x, c;
      }
      if (ctx.status != COBYLA_SUCCESS) {
        error, swrite(format="Something wrong occured in COBYLA: %s",
                      ctx.reason);
      }
      if (p == 10) xopt = cobyla_test10_xopt(x);
      r = x - xopt;
      write, format="\n     Least squares error in variables =%16.6E\n",
        sqrt(sum(r*r));
    }
    write, format="  %s\n",
      "------------------------------------------------------------------";
  }
}

/*
 * Local Variables:
 * mode: Yorick
 * tab-width: 8
 * indent-tabs-mode: nil
 * c-basic-offset: 2
 * fill-column: 79
 * coding: utf-8
 * ispell-local-dictionary: "american"
 * End:
 */
