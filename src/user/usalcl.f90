!-------------------------------------------------------------------------------

!VERS

! This file is part of Code_Saturne, a general-purpose CFD tool.
!
! Copyright (C) 1998-2013 EDF S.A.
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
! Function:
! ---------

!> \file usalcl.f90
!>
!> \brief User subroutine dedicated the use of ALE (Arbitrary Lagrangian
!> Eulerian) Method:
!>  - Fills boundary conditions (ialtyb, icodcl, rcodcl) for mesh velocity.
!>  - This subroutine also enables one to fix displacement on nodes.
!>
!> \section intro Introduction
!>
!> Here one defines boundary conditions on a per-face basis.
!>
!> Boundary faces may be identified using the \ref getfbr subroutine.
!> The syntax of this subroutine is described in
!> cs_user_boundary_conditions.f90 subroutine,
!> but a more thorough description can be found in the user guide.
!>
!> Boundary conditions setup for standard variables (pressure, velocity,
!> turbulence, scalars) is described precisely in
!> cs_user_boundary_conditions.f90 subroutine.
!>
!> Detailed explanation will be found in the theory guide.
!>
!> \section bc_types Boundary condition types
!>
!> Boundary conditions may be assigned in two ways.
!>
!>
!> \subsection std_bcs For "standard" boundary conditions
!>
!> One defines a code in the \c ialtyb array (of dimensions number of
!> boundary faces). The available codes are:
!>
!>  - \c ialtyb(ifac) = \c ibfixe: the face \c ifac is considered to be motionless.
!>           A zero Dirichlet boundary condition is automatically imposed on mesh
!>           velocity. Moreover the displacement of corresponding nodes will
!>           automatically be set to 0 (for further information please
!>           read the paragraph dedicated to the description of \c impale array in the
!>           usalcl.f90 subroutine), unless the USER has modified the condition of
!>           at least one  component of mesh velocity (modification of \c icodcl array,
!>           please read the following paragraph \ref non_std_bc)
!>
!>  - \c ialtyb(ifac) = \c igliss: The mesh slides on corresponding face \c ifac.
!>           The normal component of mesh velocity is automatically set to 0.
!>           A homogeneous Neumann condition is automatically prescribed for the
!>           other components, as it's the case for 'Symmetry' fluid condition
!>           (Please note that homogeneous Neumann condition is only partially
!>           implicit in case of boudary face that is not aligned with axis
!>           if \c ivelco=0).
!>
!>  - \c ialtyb(ifac) = \c ivimpo: the mesh velocity is imposed on face \c ifac. Thus,
!>           the users needs to specify the mesh velocity values filling \c rcodcl
!>           arrays as follows:
!>            - \c rcodcl(ifac,iuma,1) = mesh velocity in 'x' direction
!>            - \c rcodcl(ifac,ivma,1) = mesh velocity in 'y' direction
!>            - \c rcodcl(ifac,iwma,1) = mesh velocity in 'z' direction
!>            .
!>           Components of \c rcodcl(.,i.ma,1) arrays that are not specified by user
!>           will automatically be set to 0, meaning that user only needs to specify
!>           non zero mesh velocity components.
!>
!>
!> \subsection non_std_bc For "non-standard" conditions
!>
!> Other than (fixed boundary, sliding mesh boundary, fixed velocity), one
!> defines for each face and each component \c IVAR = IUMA, IVMA, IWMA:
!>  - a code
!>    - \c icodcl(ifac, ivar)
!>  - three real values:
!>    - \c rcodcl(ifac, ivar, 1)
!>    - \c rcodcl(ifac, ivar, 2)
!>    - \c rcodcl(ifac, ivar, 3)
!>
!> The value of \c icodcl is taken from the following:
!>  - 1: Dirichlet
!>  - 3: Neumann
!>  - 4: Symmetry
!>
!> The values of the 3 \c rcodcl components are:
!>  - \c rcodcl(ifac, ivar, 1):
!>     Dirichlet for the variable if \c icodcl(ifac, ivar) = 1
!>     The dimension of \c rcodcl(ifac, ivar, 1) is in m/s
!>  - \c rcodcl(ifac, ivar, 2):
!>    "exterior" exchange coefficient (between the prescribed value
!>                      and the value at the domain boundary)
!>                      rinfin = infinite by default
!>    \c  rcodcl(ifac,ivar,2) =  (VISCMA) / d
!>          (D has the dimension of a distance in m, VISCMA stands for
!>          the mesh viscosity)
!>    \remark the definition of \c rcodcl(.,.,2) is based on the manner
!>            other standard variables are managed in the same case.
!>            This type of boundary condition appears nonsense
!>            concerning mesh in that context.
!>
!>  - \c rcodcl(ifac,ivar,3) :
!>    Flux density (in kg/m s2) = J if icodcl(ifac, ivar) = 3
!>                 (<0 if gain, n outwards-facing normal)
!>    \c rcodcl(ifac,ivar,3) = -(VISCMA)* (grad Um).n
!>              (Um represents mesh velocity)
!>    \remark note that the definition of condition \c rcodcl(ifac,ivar,3)
!>            is based on the manner other standard variables are
!>            managed in the same case.
!>            \c rcodcl(.,.,3) = 0.d0 enables one to specify a homogeneous
!>            Neuman condition on mesh velocity. Any other value will be
!>            physically nonsense in that context.
!>
!> Note that if the user assigns a value to \c ialtyb equal to \c ibfixe, \c igliss,
!> or \c ivimpo and does not modify \c icodcl (zero value by
!> default), \c ialtyb will define the boundary condition type.
!>
!> To the contrary, if the user prescribes \c icodcl(ifac, ivar) (nonzero),
!> the values assigned to rcodcl will be used for the considered face
!> and variable (if rcodcl values are not set, the default values will
!> be used for the face and variable, so:
!>                         - \c rcodcl(ifac, ivar, 1) = 0.d0
!>                         - \c rcodcl(ifac, ivar, 2) = rinfin
!>                         - \c rcodcl(ifac, ivar, 3) = 0.d0)
!>
!> If the user decides to prescribe his own non-standard boundary conditions
!> it will be necessary to assign values to \c icodcl AND to rcodcl for ALL
!> mesh velocity components. Thus, the user does not need to assign values
!> to \c IALTYB for each associated face, as it will not be taken into account
!> in the code.
!>
!>
!> \subsection cons_rul Consistency rules
!>
!> A consistency rules between \c icodcl codes for variables with
!> non-standard boundary conditions:
!>  - If a symmetry code (\c icodcl=4) is imposed for one mesh velocity
!>    component, one must have the same condition for all other mesh
!>    velocity components.
!>
!>
!> \subsection fix_nod Fixed displacement on nodes
!>
!> For a better precision concerning mesh displacement, one can also assign values
!> of displacement to certain internal and/or boundary nodes. Thus, one
!> need to fill \c DEPALE and \c impale arrays :
!>  - \c depale(inod,1) = displacement of node inod in 'x' direction
!>  - \c depale(inod,2) = displacement of node inod in 'y' direction
!>  - \c depale(inod,3) = displacement of node inod in 'z' direction
!> This array is defined as the total displacement of the node compared
!> its initial position in initial mesh.
!> \c impale(inod) = 1 indicates that the displacement of node inod is imposed
!> \note Note that \c impale array is initialized to the value of 0; if its value
!>       is not modified, corresponding value in \c DEPALE array will not be
!>       taken into account
!>
!> During mesh's geometry re-calculation at each time step, the position of the
!> nodes, which displacement is fixed (i.e. \c impale=1), is not calculated
!> using the value of mesh velocity at the center of corresponding cell, but
!> directly filled using the values of \c DEPALE.
!>
!> If the displacement is fixed for all nodes of a boundary face it's not
!> necessary to prescribe boundary conditions at this face on mesh velocity.
!> \c icodcl and \c rcodcl values will be overwritten:
!>  - \c icodcl is automatically set to 1 (Dirichlet)
!>  - \c rcodcl value will be automatically set to face's mean mesh velocity
!>    value, that is calculated using \c DEPALE array.
!>
!> If a fixed boundary condition (\c ialtyb(ifac)=ibfixe) is imposed to the face
!> \c ifac, the displacement of each node inod belonging to ifac is considered
!> to be fixed, meaning that \c impale(inod) = 1 and \c depale(inod,.) = 0.d0.
!>
!>
!> \subsubsection nod_des Description of nodes
!>
!> \c nnod gives the total (internal and boundary) number of nodes.
!> Vertices coordinates are given by \c xyznod(3, nnod) array. This table is
!> updated at each time step of the calculation.
!> \c xyzno0(3,nnod) gives the coordinates of initial mesh at the beginning
!> of the calculation.
!>
!> The faces - nodes connectivity is stored by means of four integer arrays :
!> \c ipnfac, \c nodfac, \c ipnfbr, \c nodfbr.
!>
!> \c nodfac(nodfbr) stores sequentially the index-numbers of the nodes of each
!> internal (boundary) face.
!> \c ipnfac(ipnfbr) gives the position of the first node of each internal
!> (boundary) face in the array \c nodfac(nodfbr).
!>
!> For example, in order to get all nodes of internal face \c ifac, one can
!> use the following loop:
!>
!> \code
!> do ii = ipnfac(ifac), ipnfac(ifac+1)-1 !! index number of nodfac array
!>                                        !! corresponding to ifac
!>
!>   inod = nodfac(ii)                    !! index-number iith node of face ifac.
!>   !! ...
!> enddo
!> \endcode
!>
!>
!> \subsection flui_bc Influence on boundary conditions related to fluid velocity
!>
!> The effect of fluid velocity and ALE modeling on boundary faces that
!> are declared as walls (\c itypfb = \c iparoi or \c iparug) really depends on
!> the physical nature of this interface.
!>
!> Indeed when studying an immersed structure the motion of corresponding
!> boundary faces is the one of the structure, meaning that it leads to
!> fluid motion. On the other hand when studying a piston the motion of vertices
!> belonging to lateral boundaries has no physical meaning therefore it has
!> no influence on fluid motion.
!>
!> Whatever the case, mesh velocity component that is normal to the boundary
!> face is always taken into account
!> (\f$ \vect{u}_{fluid} \cdot \vect{n} = \vect{w}_{mesh} \cdot \vect{n} \f$).
!>
!> The modeling of tangential mesh velocity component differs from one case
!> to another.
!>
!> The influence of mesh velocity on boundary conditions for fluid modeling is
!> managed and modeled in Code_Saturne as follows:
!>  - If \c ialtyb(ifac) = ibfixe: mesh velocity equals 0. (In case of 'fluid sliding
!>  wall' modeling corresponding condition will be specified in Code_Saturne
!>  Interface or in cs_user_boundary_conditions.f90 subroutine.)
!>  - If \c ialtyb(ifac) = ivimpo: tangential mesh velocity is modeled as a sliding
!>  wall velocity in fluid boundary conditions unless a value for fluid sliding
!>  wall velocity has been specified by USER in Code_Saturne Interface
!>  or in cs_user_boundary_conditions.f90 subroutine.
!>  - If \c ialtyb(ifac) = igliss: tangential mesh velocity is not taken into account
!>  in fluid boundary conditions (In case of 'fluid sliding wall' modeling
!>  corresponding condition will be specified in Code_Saturne Interface
!>  or in cs_user_boundary_conditions.f90 subroutine.)
!>  - If \c impale(inod) = 1 for all vertices of a boundary face: tangential mesh
!>  velocity value that has been derived from nodes displacement is modeled as a
!>  sliding wall velocity in fluid boundary conditions unless a value for fluid
!>  sliding wall velocity has been specified by USER in Code_Saturne Interface or
!>  in 'cs_user_boundary_conditions' subroutine.
!>
!> Note that mesh velocity has no influence on modeling of
!> boundary faces with 'inlet' or 'free outlet' fluid boundary condition.
!>
!> For "non standard" conditions USER has to manage the influence of boundary
!> conditions for ALE method (i.e. mesh velocity) on the ones for Navier Stokes
!> equations(i.e. fluid velocity). (Note that fluid boundary conditions can be
!> specified in this subroutine.)
!>
!>
!>\subsubsection cell_id Cells identification
!>
!> Cells may be identified using the getcel subroutine.
!> The syntax of this subroutine is described in the
!> cs_user_boundary_conditions.f90 subroutine,
!> but a more thorough description can be found in the user guide.
!>
!>
!> \subsubsection fac_id Faces identification
!>
!> Faces may be identified using the \ref getfbr subroutine.
!> The syntax of this subroutine is described in the
!> cs_user_boundary_conditions.f90 subroutine,
!> but a more thorough description can be found in the user guide.

!-------------------------------------------------------------------------------

!-------------------------------------------------------------------------------
! Arguments
!______________________________________________________________________________.
!  mode           name          role                                           !
!______________________________________________________________________________!
!> \param[in]     itrale        number of iterations for ALE method
!> \param[in]     nvar          total number of variables
!> \param[in]     nscal         total number of scalars
!> \param[out]    icodcl        boundary condition code:
!>                               - 1 Dirichlet
!>                               - 2 Radiative outlet
!>                               - 3 Neumann
!>                               - 4 sliding and
!>                                 \f$ \vect{u} \cdot \vect{n} = 0 \f$
!>                               - 5 smooth wall and
!>                                 \f$ \vect{u} \cdot \vect{n} = 0 \f$
!>                               - 6 rought wall and
!>                                 \f$ \vect{u} \cdot \vect{n} = 0 \f$
!>                               - 9 free inlet/outlet
!>                                 (input mass flux blocked to 0)
!> \param[in,out] itypfb        boundary face types
!> \param[out]    ialtyb        boundary face types for mesh velocity
!> \param[in]     impale        indicator for fixed node displacement
!> \param[in]     dt            time step (per cell)
!> \param[in]     rtp, rtpa     calculated variables at cell centers
!> \param[in]                    (at current and previous time steps)
!> \param[in]     propce        physical properties at cell centers
!> \param[in]     propfa        physical properties at interior face centers
!> \param[in]     propfb        physical properties at boundary face centers
!> \param[in,out] rcodcl        boundary condition values:
!>                               - rcodcl(1) value of the dirichlet
!>                               - rcodcl(2) value of the exterior exchange
!>                                 coefficient (infinite if no exchange)
!>                               - rcodcl(3) value flux density
!>                                 (negative if gain) in w/m2 or roughtness
!>                                 in m if icodcl=6
!>                                 -# for the velocity \f$ (\mu+\mu_T)
!>                                    \gradv \vect{u} \cdot \vect{n}  \f$
!>                                 -# for the pressure \f$ \Delta t
!>                                    \grad P \cdot \vect{n}  \f$
!>                                 -# for a scalar \f$ cp \left( K +
!>                                     \dfrac{K_T}{\sigma_T} \right)
!>                                     \grad T \cdot \vect{n} \f$
!> \param[in,out] depale        nodes displacement
!> \param[in]     xyzno0        vertex coordinates of initial mesh
!_______________________________________________________________________________

subroutine usalcl &
 ( itrale ,                                                       &
   nvar   , nscal  ,                                              &
   icodcl , itypfb , ialtyb , impale ,                            &
   dt     , rtp    , rtpa   , propce , propfa , propfb ,          &
   rcodcl , xyzno0 , depale )

!===============================================================================

!===============================================================================
! Module files
!===============================================================================

use paramx
use numvar
use optcal
use cstphy
use cstnum
use entsor
use parall
use period
use ihmpre
use mesh

!===============================================================================

implicit none

! Arguments

integer          itrale
integer          nvar   , nscal

integer          icodcl(nfabor,nvarcl)
integer          itypfb(nfabor), ialtyb(nfabor)
integer          impale(nnod)

double precision dt(ncelet), rtp(ncelet,*), rtpa(ncelet,*)
double precision propce(ncelet,*)
double precision propfa(nfac,*), propfb(nfabor,*)
double precision rcodcl(nfabor,nvarcl,3)
double precision depale(nnod,3), xyzno0(3,nnod)

! Local variables

integer          ifac, iel, ii
integer          inod
integer          ilelt, nlelt

double precision delta, deltaa

integer, allocatable, dimension(:) :: lstelt

!===============================================================================

! TEST_TO_REMOVE_FOR_USE_OF_SUBROUTINE_START
!===============================================================================
! 0.  This test allows the user to ensure that the version of this subroutine
!       used is that from his case definition, and not that from the library.
!     If a file from the GUI is used, this subroutine may not be mandatory,
!       thus the default (library reference) version returns immediately.
!===============================================================================
if(iihmpr.eq.1) then
  return
else
  write(nfecra,9000)
  call csexit (1)
endif

 9000 format(                                                           &
'@                                                            ',/,&
'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@',/,&
'@                                                            ',/,&
'@ @@ ATTENTION : stop in definition of boundary conditions   ',/,&
'@    =========                                               ',/,&
'@     ALE Method has been activated                          ',/,&
'@     User subroutine ''usalcl'' must be completed           ',/,&
'@                                                            ',/,&
'@  The calculation will not be run                           ',/,&
'@                                                            ',/,&
'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@',/,&
'@                                                            ',/)


! TEST_TO_REMOVE_FOR_USE_OF_SUBROUTINE_END

!===============================================================================
! 1.  Initialization
!===============================================================================

! Allocate a temporary array for boundary faces selection
allocate(lstelt(nfabor))

!===============================================================================
! 2.  Assign boundary conditions to boundary faces here

!     One may use selection criteria to filter boundary case subsets
!       Loop on faces from a subset
!         Set the boundary condition for each face
!===============================================================================


! Calculation of displacement at current time step
deltaa = sin(3.141596d0*(ntcabs-1)/50.d0)
delta  = sin(3.141596d0*ntcabs/50.d0)


! Example: For boundary faces of color 4 assign a fixed velocity

if (.false.) then

  call getfbr('4', nlelt, lstelt)
  !==========

  do ilelt = 1, nlelt

    ifac = lstelt(ilelt)
    ! Element adjacent a la face de bord
    iel = ifabor(ifac)

    ialtyb(ifac) = ivimpo
    rcodcl(ifac,iuma,1) = 0.d0
    rcodcl(ifac,ivma,1) = 0.d0
    rcodcl(ifac,iwma,1) = (delta-deltaa)/dt(iel)

  enddo

endif

! Example: For boundary faces of color 5 assign a fixed displacement on nodes

if (.false.) then

  call getfbr('5', nlelt, lstelt)
  !==========

  do ilelt = 1, nlelt

    ifac = lstelt(ilelt)

    do ii = ipnfbr(ifac), ipnfbr(ifac+1)-1
      inod = nodfbr(ii)
      if (impale(inod).eq.0) then
        depale(inod,1) = 0.d0
        depale(inod,2) = 0.d0
        depale(inod,3) = delta
        impale(inod) = 1
      endif
    enddo

  enddo

endif

! Example: For boundary faces of color 6 assign a sliding boundary

if (.false.) then

  call getfbr('6', nlelt, lstelt)
  !==========

  do ilelt = 1, nlelt

    ifac = lstelt(ilelt)

    ialtyb(ifac) = igliss

  enddo

endif

! Example: prescribe elsewhere a fixed boundary

if (.false.) then

  call getfbr('not (4 or 5 or 6)', nlelt, lstelt)
  !==========

  do ilelt = 1, nlelt

    ifac = lstelt(ilelt)

    ialtyb(ifac) = ibfixe

  enddo

endif

!--------
! Formats
!--------

!----
! End
!----

! Deallocate the temporary array
deallocate(lstelt)

return
end subroutine usalcl
