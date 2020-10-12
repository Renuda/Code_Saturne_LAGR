!-------------------------------------------------------------------------------

! This file is part of Code_Saturne, a general-purpose CFD tool.
!
! Copyright (C) 1998-2020 EDF S.A.
!
! This program is free software; you can redistribute it and/or modify it under
! the terms of the GNU General Public License as published by the Free Software
! Foundation; either version 2 of the License, or (at your option) any later
! version.
!
! This program is distributed in the hope that it will be useful, but WITHOUT
! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
! FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
! details.
!
! You should have received a copy of the GNU General Public License along with
! this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
! Street, Fifth Floor, Boston, MA 02110-1301, USA.

!-------------------------------------------------------------------------------

!===============================================================================
!> \file usatch.f90
!>
!> \brief Routines for user defined atmospheric chemical scheme
!>
!> \remarks
!>  These routines should be generated by SPACK
!>
!>  See CEREA: http://cerea.enpc.fr/polyphemus
!>             https://sshaerosol.wordpress.com/
!>             https://github.com/sshaerosol/ssh-aerosol/
!------------------------------------------------------------------------------

!===============================================================================
!
!> \brief kinetic_4
!>
!> \brief Computation of kinetic rates for atmospheric chemistry
!
!-------------------------------------------------------------------------------
! Arguments
!______________________________________________________________________________.
!  mode           name          role                                           !
!______________________________________________________________________________!
!> \param[in]     nr                total number of chemical reactions
!> \param[in]     option_photolysis flag to activate or not photolysis reactions
!> \param[in]     azi               solar zenith angle
!> \param[in]     att               atmospheric attenuation variable
!> \param[in]     temp              temperature
!> \param[in]     press             pressure
!> \param[in]     xlw               water massic fraction
!> \param[out]    rk(nr)            kinetic rates
!______________________________________________________________________________

subroutine kinetic_4(nr,rk,temp,xlw,press,azi,att,                  &
     option_photolysis)

use entsor

implicit none

! Arguments

integer nr
double precision rk(nr),temp,xlw,press
double precision azi, att
integer option_photolysis

! Dummy local variables required by SPACK

integer, parameter :: ns = 1
integer, parameter :: nbin = 1
integer, parameter :: iheter = 0
integer icld
double precision lwctmp
double precision granulo(nbin)
double precision WetDiam(nbin)
double precision dsf_aero(nbin)
integer ispeclost(4)
double precision Wmol(ns)
double precision LWCmin

call ssh_kinetic(ns,nbin,nr,iheter,icld,rk,temp,xlw, &
                 press,azi,att,lwctmp,granulo,WetDiam,dsf_aero,ispeclost, &
                 Wmol,LWCmin,option_photolysis)

return

!--------
! Formats
!--------

end subroutine kinetic_4

!===============================================================================
!> \brief fexchem_4
!>
!> \brief Computes the chemical production terms
!------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! Arguments
!______________________________________________________________________________.
!  mode           name          role                                           !
!______________________________________________________________________________!
!> \param[in]     nr                total number of chemical reactions
!> \param[in]     ns                total number of chemical species
!> \param[in]     y                 concentrations vector
!> \param[in]     rk                kinetic rates
!> \param[in]     zcsourc           source term
!> \param[in]     convers_factor    conversion factors
!> \param[out]    chem              chemical production terms for every species
!______________________________________________________________________________

subroutine fexchem_4(ns,nr,y,rk,zcsourc,convers_factor,chem)

use entsor

implicit none

! Arguments

integer nr,ns
double precision rk(nr),y(ns),chem(ns),zcsourc(ns)
double precision convers_factor(ns)

! Activate volumic source terms

integer, parameter :: nemis = 1

call ssh_fexchem(ns,nr,nemis,y,rk,zcsourc,convers_factor,chem)

return

!--------
! Formats
!--------

end subroutine fexchem_4

!===============================================================================
!> \brief ssh_jacdchemdc
!>
!> \brief Routine provided by SPACK. Computes the Jacobian matrix for chemistry
!------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! Arguments
!______________________________________________________________________________.
!  mode           name          role                                           !
!______________________________________________________________________________!
!> \param[in]     nr                 total number of chemical reactions
!> \param[in]     ns                 total number of chemical species
!> \param[in]     y                  concentrations vector
!> \param[in]     convers_factor     conversion factors of mug/m3 to
!>                                   molecules/cm3
!> \param[in]     convers_factor_jac conversion factors for the Jacobian matrix
!>                                   (Wmol(i)/Wmol(j))
!> \param[in]     rk                 kinetic rates
!> \param[out]    jacc               Jacobian matrix
!______________________________________________________________________________

subroutine ssh_jacdchemdc(ns,nr,y,convers_factor,                     &
                          convers_factor_jac,rk,jacc)

use entsor

implicit none

! Arguments

integer nr,ns
double precision rk(nr),y(ns),jacc(ns,ns)
double precision convers_factor(ns)
double precision convers_factor_jac(ns,ns)

return

!--------
! FORMATS
!--------

end subroutine ssh_jacdchemdc

!===============================================================================
!> \brief ssh_lu_decompose
!>
!> \brief Routine provided by SPACK. Computes LU factorization of matrix m
!------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! Arguments
!______________________________________________________________________________.
!  mode           name          role                                           !
!______________________________________________________________________________!
!> \param[in]     ns                 matrix row number from the chemical
!>                                   species number
!> \param[in,out] m                  on entry, an invertible matrix.
!>                                   On exit, an LU factorization of m
!______________________________________________________________________________

subroutine ssh_lu_decompose (ns,m)

use entsor

implicit none

! Arguments

integer ns
double precision m(ns,ns)

!--------
! FORMATS
!--------

return
end subroutine ssh_lu_decompose

!===============================================================================
!> \brief ssh_lu_solve
!>
!> \brief Resolution of MY=X where M is an LU factorization computed
!>        by lu_decompose. Routine provided by SPACK.
!------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! Arguments
!______________________________________________________________________________.
!  mode           name          role                                           !
!______________________________________________________________________________!
!> \param[in]     ns               matrix row number from the chemical
!>                                 species number
!> \param[in]     m                an LU factorization computed by lu_decompose
!> \param[in,out] x                on entry, the right-hand side of the equation
!                                  on exit, the solution of the equation
!______________________________________________________________________________

subroutine ssh_lu_solve (ns, m, x)

use entsor

implicit none

! Arguments

integer ns
double precision m(ns,ns)
double precision x(ns)

!--------
! FORMATS
!--------

return
end subroutine ssh_lu_solve

!===============================================================================
!> \brief ssh_dimensions
!>
!> \brief Rountine provided by SPACK. Return number of species / reactions
!------------------------------------------------------------------------------

subroutine ssh_dimensions(Ns, Nr, Nr_photolysis)

implicit none

! Arguments

integer Ns, Nr, Nr_photolysis

end subroutine ssh_dimensions

!===============================================================================
!> \brief ssh_kinetic
!>
!> \brief Routine provided by SPACK. Computes kinetic rates for the gas-phase.
!------------------------------------------------------------------------------

subroutine ssh_kinetic( &
    Ns,Nbin_aer,nr,IHETER,ICLD,rk,temp,xlw, &
    Press,azi,att,lwctmp,granulo,WetDiam,dsf_aero,ispeclost, &
    Wmol,LWCmin,option_photolysis)

implicit none

! Arguments

integer Ns,Nbin_aer,nr
double precision rk156,rk157,rk158,rk159
double precision lwctmp
double precision WetDiam(Nbin_aer)
double precision granulo(Nbin_aer)
double precision dsf_aero(Nbin_aer)
integer ICLD,IHETER
integer ispeclost(4)
double precision Wmol(Ns),LWCmin
double precision rk(nr),temp,xlw,Press
double precision Effko,Rapk,facteur,SumM,azi,att
double precision YlH2O
integer option_photolysis

end subroutine ssh_kinetic

!===============================================================================
!> \brief ssh_fexchem
!>
!> \brief Routine provided by SPACK. Computes the chemical production terms
!------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! Arguments
!______________________________________________________________________________.
!  mode           name          role                                           !
!______________________________________________________________________________!
!> \param[in]     nr                total number of chemical reactions
!> \param[in]     ns                total number of chemical species
!> \param[in]     nemis             flag to activate source terms
!> \param[in]     y                 concentrations vector
!> \param[in]     rk                kinetic rates
!> \param[in]     zcsourc           source term
!> \param[in]     convers_factor    conversion factors
!> \param[out]    chem              chemical production terms for every species
!______________________________________________________________________________

subroutine ssh_fexchem(NS,Nr,nemis,y,rk,ZCsourc,convers_factor,chem)

implicit none

integer nemis
integer nr,ns,i
double precision w(nr),rk(nr),y(ns),chem(ns),ZCsourc(ns)
double precision conc(ns), convers_factor(ns)

end subroutine ssh_fexchem

!===============================================================================
!> \brief hetrxn
!>
!> \brief Dummy function for compatibility with SPACK
!------------------------------------------------------------------------------

subroutine hetrxn(Ns,Nbin_aer,temp,press,ICLD,lwctmp, &
      WetDiam,granulo,rk156,rk157,rk158,rk159, &
      dsf_aero,ispeclost,Wmol,LWCmin)

implicit none

integer Ns,Nbin_aer
double precision rk156,rk157,rk158,rk159
double precision lwctmp
double precision WetDiam(Nbin_aer)
double precision granulo(Nbin_aer)
double precision dsf_aero(Nbin_aer)
integer ICLD
integer ispeclost(4)
double precision Wmol(Ns),LWCmin
double precision temp,Press

end subroutine hetrxn
