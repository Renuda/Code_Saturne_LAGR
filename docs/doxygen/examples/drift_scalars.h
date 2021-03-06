/*============================================================================
 * Code_Saturne documentation page
 *============================================================================*/

/*
  This file is part of Code_Saturne, a general-purpose CFD tool.

  Copyright (C) 1998-2021 EDF S.A.

  This program is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free Software
  Foundation; either version 2 of the License, or (at your option) any later
  version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  You should have received a copy of the GNU General Public License along with
  this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
  Street, Fifth Floor, Boston, MA 02110-1301, USA.
*/

/*-----------------------------------------------------------------------------*/

/*!
  \page drift_scalars Data setting for drift scalars
 

  \section drift_scalars_intro Introduction

  This page provides an example of code blocks that may be used
  to perform a calculation with drift scalars.


  \section cs_user_physical_properties-scalar_drift Physical properties

  \subsection drift_scalars_loc_var Local variables to be added

  The following local variables need to be defined for the examples
  in this section:

  \snippet cs_user_physical_properties-scalar_drift.f90 loc_var_dec

  \subsection drift_scalars_init Initialization and finalization

  The following initialization block needs to be added for the following examples:

  \snippet cs_user_physical_properties-scalar_drift.f90 init

  In theory Fortran 95 deallocates locally-allocated arrays automatically,
  but deallocating arrays in a symmetric manner to their allocation is good
  practice, and it avoids using a different logic for C and Fortran.

  \subsection drift_scalars_body Body

  This example set the scalar laminar diffusivity (for Brownian motion)
  to take thermophoresis into account.
  
  Here is the corresponding code:
  
  \snippet cs_user_physical_properties-scalar_drift.f90 example_1
  
*/
