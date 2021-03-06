(**************************************************************************)
(*                                                                        *)
(*  Menhir                                                                *)
(*                                                                        *)
(*  François Pottier, INRIA Paris-Rocquencourt                            *)
(*  Yann Régis-Gianas, PPS, Université Paris Diderot                      *)
(*                                                                        *)
(*  Copyright 2005-2015 Institut National de Recherche en Informatique    *)
(*  et en Automatique. All rights reserved. This file is distributed      *)
(*  under the terms of the Q Public License version 1.0, with the change  *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(**************************************************************************)

module Make
(M : Fix.IMPERATIVE_MAPS)
(P : sig
  include Fix.PROPERTY
  val union: property -> property -> property
end)
: sig

  (* Variables and constraints. A constraint is an inequality between
     a constant or a variable, on the left-hand side, and a variable,
     on the right-hand side. *)

  type variable =
    M.key

  type property =
    P.property

  (* An imperative interface, where we create a new constraint system,
     and are given three functions to add constraints and (once we are
     done adding) to solve the system. *)

  val create: unit ->
    (property -> variable -> unit) *
    (variable -> variable -> unit) *
    (unit -> (variable -> property))

end

