!-------------------------------------------------------------------------------

!     This file is part of the Code_Saturne Kernel, element of the
!     Code_Saturne CFD tool.

!     Copyright (C) 1998-2008 EDF S.A., France

!     contact: saturne-support@edf.fr

!     The Code_Saturne Kernel is free software; you can redistribute it
!     and/or modify it under the terms of the GNU General Public License
!     as published by the Free Software Foundation; either version 2 of
!     the License, or (at your option) any later version.

!     The Code_Saturne Kernel is distributed in the hope that it will be
!     useful, but WITHOUT ANY WARRANTY; without even the implied warranty
!     of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!     GNU General Public License for more details.

!     You should have received a copy of the GNU General Public License
!     along with the Code_Saturne Kernel; if not, write to the
!     Free Software Foundation, Inc.,
!     51 Franklin St, Fifth Floor,
!     Boston, MA  02110-1301  USA

!-------------------------------------------------------------------------------

subroutine csccel &
!================

 ( idbia0 , idbra0 ,                                              &
   ndim   , ncelet , ncel   , nfac   , nfabor , nfml   , nprfml , &
   nnod   , lndfac , lndfbr , ncelbr ,                            &
   nvar   , nscal  , nphas  ,                                     &
   nideve , nrdeve , nituse , nrtuse ,                            &
   ivar   , iphas  ,                                              &
   ifacel , ifabor , ifmfbr , ifmcel , iprfml ,                   &
   ipnfac , nodfac , ipnfbr , nodfbr ,                            &
   idevel , ituser , ia    ,                                      &
   xyzcen , surfac , surfbo , cdgfac , cdgfbo , xyznod , volume , &
   dt     , rtpa   , propce , propfa , propfb ,                   &
   coefa  , coefb  ,                                              &
   crvexp , crvimp ,                                              &
   dam    , xam    ,                                              &
   w1     , w2     , w3     , w4     , w5     , w6     ,          &
   rdevel , rtuser , ra     )

!===============================================================================
! FONCTION :
! --------

! ECHANGE DES VARIABLES POUR UN COUPLAGE
!   ENTRE DEUX INSTANCES DE CODE_SATURNE VIA LES FACES DE BORD

!-------------------------------------------------------------------------------
!ARGU                             ARGUMENTS
!__________________.____._____.________________________________________________.
!    nom           !type!mode !                   role                         !
!__________________!____!_____!________________________________________________!
! idbia0           ! e  ! <-- ! numero de la 1ere case libre dans ia           !
! idbra0           ! e  ! <-- ! numero de la 1ere case libre dans ra           !
! ndim             ! e  ! <-- ! dimension de l'espace                          !
! ncelet           ! e  ! <-- ! nombre d'elements halo compris                 !
! ncel             ! e  ! <-- ! nombre d'elements actifs                       !
! nfac             ! e  ! <-- ! nombre de faces internes                       !
! nfabor           ! e  ! <-- ! nombre de faces de bord                        !
! nfml             ! e  ! <-- ! nombre de familles d entites                   !
! nprfml           ! e  ! <-- ! nombre de proprietese des familles             !
! nnod             ! e  ! <-- ! nombre de sommets                              !
! lndfac           ! e  ! <-- ! longueur du tableau nodfac (optionnel          !
! lndfbr           ! e  ! <-- ! longueur du tableau nodfbr (optionnel          !
! ncelbr           ! e  ! <-- ! nombre d'elements ayant au moins une           !
!                  !    !     ! face de bord                                   !
! nvar             ! e  ! <-- ! nombre total de variables                      !
! nscal            ! e  ! <-- ! nombre total de scalaires                      !
! nphas            ! e  ! <-- ! nombre de phases                               !
! nideve nrdeve    ! e  ! <-- ! longueur de idevel rdevel                      !
! nituse nrtuse    ! e  ! <-- ! longueur de ituser rtuser                      !
! ivar             ! e  ! <-- ! numero de variable                             !
! iphas            ! e  ! <-- ! numero de phase                                !
! ifacel           ! te ! <-- ! elements voisins d'une face interne            !
! (2, nfac)        !    !     !                                                !
! ifabor           ! te ! <-- ! element  voisin  d'une face de bord            !
! (nfabor)         !    !     !                                                !
! ifmfbr           ! te ! <-- ! numero de famille d'une face de bord           !
! (nfabor)         !    !     !                                                !
! ifmcel           ! te ! <-- ! numero de famille d'une cellule                !
! (ncelet)         !    !     !                                                !
! iprfml           ! te ! <-- ! proprietes d'une famille                       !
! nfml  ,nprfml    !    !     !                                                !
! ipnfac           ! te ! <-- ! position du premier noeud de chaque            !
!   (lndfac)       !    !     !  face interne dans nodfac (optionnel)          !
! nodfac           ! te ! <-- ! connectivite faces internes/noeuds             !
!   (nfac+1)       !    !     !  (optionnel)                                   !
! ipnfbr           ! te ! <-- ! position du premier noeud de chaque            !
!   (lndfbr)       !    !     !  face de bord dans nodfbr (optionnel)          !
! nodfbr           ! te ! <-- ! connectivite faces de bord/noeuds              !
!   (nfabor+1)     !    !     !  (optionnel)                                   !
! idevel(nideve    ! te ! <-- ! tab entier complementaire developemt           !
! ituser(nituse    ! te ! <-- ! tab entier complementaire utilisateur          !
! ia(*)            ! tr ! --- ! macro tableau entier                           !
! xyzcen           ! tr ! <-- ! point associes aux volumes de control          !
! (ndim,ncelet     !    !     !                                                !
! surfac           ! tr ! <-- ! vecteur surface des faces internes             !
! (ndim,nfac)      !    !     !                                                !
! surfbo           ! tr ! <-- ! vecteur surface des faces de bord              !
! (ndim,nfabor)    !    !     !                                                !
! cdgfac           ! tr ! <-- ! centre de gravite des faces internes           !
! (ndim,nfac)      !    !     !                                                !
! cdgfbo           ! tr ! <-- ! centre de gravite des faces de bord            !
! (ndim,nfabor)    !    !     !                                                !
! xyznod           ! tr ! <-- ! coordonnes des noeuds (optionnel)              !
! (ndim,nnod)      !    !     !                                                !
! volume           ! tr ! <-- ! volume d'un des ncelet elements                !
! (ncelet          !    !     !                                                !
! dt(ncelet)       ! tr ! <-- ! pas de temps                                   !
! rtpa             ! tr ! <-- ! variables de calcul au centre des              !
! (ncelet,*)       !    !     !    cellules (instant            prec)          !
! propce           ! tr ! <-- ! proprietes physiques au centre des             !
! (ncelet,*)       !    !     !    cellules                                    !
! propfa           ! tr ! <-- ! proprietes physiques au centre des             !
!  (nfac,*)        !    !     !    faces internes                              !
! propfb           ! tr ! <-- ! proprietes physiques au centre des             !
!  (nfabor,*)      !    !     !    faces de bord                               !
! coefa, coefb     ! tr ! <-- ! conditions aux limites aux                     !
!  (nfabor,*)      !    !     !    faces de bord                               !
! crvexp(ncelet    ! tr ! --> ! tableau de travail pour part explicit          !
! crvimp(ncelet    ! tr ! --> ! tableau de travail pour part implicit          !
! dam(ncelet       ! tr ! --- ! tableau de travail pour matrice                !
! xam(nfac,*)      ! tr ! --- ! tableau de travail pour matrice                !
! w1...6(ncelet    ! tr ! --- ! tableau de travail                             !
! rdevel(nrdeve    ! tr ! <-- ! tab reel complementaire developemt             !
! rtuser(nrtuse    ! tr ! <-- ! tab reel complementaire utilisateur            !
! ra(*)            ! tr ! --- ! macro tableau reel                             !
!__________________!____!_____!________________________________________________!

!     TYPE : E (ENTIER), R (REEL), A (ALPHANUMERIQUE), T (TABLEAU)
!            L (LOGIQUE)   .. ET TYPES COMPOSES (EX : TR TABLEAU REEL)
!     MODE : <-- donnee, --> resultat, <-> Donnee modifiee
!            --- tableau de travail
!-------------------------------------------------------------------------------
!===============================================================================

implicit none

!===============================================================================
!     DONNEES EN COMMON
!===============================================================================

include "paramx.h"
include "pointe.h"
include "numvar.h"
include "entsor.h"
include "optcal.h"
include "cstphy.h"
include "cstnum.h"
include "parall.h"
include "period.h"
include "cplsat.h"

!===============================================================================

! Arguments

integer          idbia0 , idbra0
integer          ndim   , ncelet , ncel   , nfac   , nfabor
integer          nfml   , nprfml
integer          nnod   , lndfac , lndfbr , ncelbr
integer          nvar   , nscal  , nphas
integer          nideve , nrdeve , nituse , nrtuse
integer          ivar   , iphas

integer          ifacel(2,nfac)  , ifabor(nfabor)
integer          ifmfbr(nfabor)  , ifmcel(ncelet)
integer          iprfml(nfml,nprfml)
integer          ipnfac(nfac+1)  , nodfac(lndfac)
integer          ipnfbr(nfabor+1), nodfbr(lndfbr)
integer          idevel(nideve), ituser(nituse), ia(*)

double precision xyzcen(ndim,ncelet)
double precision surfac(ndim,nfac), surfbo(ndim,nfabor)
double precision cdgfac(ndim,nfac), cdgfbo(ndim,nfabor)
double precision xyznod(ndim,nnod), volume(ncelet)
double precision dt(ncelet), rtpa(ncelet,*)
double precision propce(ncelet,*)
double precision propfa(nfac,*), propfb(nfabor,*)
double precision coefa(nfabor,*), coefb(nfabor,*)
double precision crvexp(ncelet), crvimp(ncelet)
double precision dam(ncelet ),xam(nfac ,2)
double precision w1(ncelet),w2(ncelet),w3(ncelet)
double precision w4(ncelet),w5(ncelet),w6(ncelet)
double precision rdevel(nrdeve), rtuser(nrtuse), ra(*)

! VARIABLES LOCALES

integer          idebia , idebra , ifinia , ifinra
integer          numcpl , iun
integer          ncesup , nfbsup
integer          ncecpl , nfbcpl , ncencp , nfbncp
integer          ncedis , nfbdis
integer          ncecpg , ncedig
integer          ilfbsu , ilcesu
integer          ilcecp , ilfbcp , ilcenc , ilfbnc
integer          ilocpt , icoopt , idjppt , idofpt , ipndpt
integer          irvdis , irvcel , ipndcp , idofcp
integer          ityloc , ityvar

!====================================================================================

idebia = idbia0
idebra = idbra0

do numcpl = 1, nbrcpl

!======================================================================================
! 1.  DEFINITION DE CHAQUE COUPLAGE
!======================================================================================

  call nbecpl                                                     &
  !==========
 ( numcpl ,                                                       &
   ncesup , nfbsup ,                                              &
   ncecpl , nfbcpl , ncencp , nfbncp )

  call memcs1                                                     &
  !==========
 ( idebia , idebra ,                                              &
   ncesup , nfbsup , ncecpl , nfbcpl , ncencp , nfbncp ,          &
   ilcesu , ilfbsu , ilcecp , ilfbcp , ilcenc , ilfbnc ,          &
   ifinia , ifinra )

  call lelcpl                                                     &
  !==========
 ( numcpl ,                                                       &
   ncecpl , nfbcpl ,                                              &
   ia(ilcecp) , ia(ilfbcp) )


!====================================================================================
! 2.  PREPARATION DES VARIABLES A ENVOYER SUR LES CELLULES
!====================================================================================

  ityvar = 1

! --- Informations g�om�triques de localisation

  call npdcpl(numcpl, ncedis, nfbdis)
  !==========

!       On n'�changera qu'une composante de la vitesse � la fois
  iun = 1

  call memcs2                                                     &
  !==========
 ( ifinia , ifinra ,                                              &
   ncecpl , ncedis , iun    ,                                     &
   irvcel , ipndcp , idofcp ,                                     &
   irvdis , ilocpt , icoopt , idjppt , idofpt , ipndpt ,          &
   ifinia , ifinra )

  call coocpl(numcpl, ncedis, ityvar,                             &
  !==========
              ityloc, ia(ilocpt), ra(icoopt),                     &
              ra(idjppt), ra(idofpt), ra(ipndpt) )

  if (ityloc.eq.2) then
    write(nfecra,1000)
    call csexit(1)
    !==========
  endif

!       On v�rifie qu'il faut bien �changer quelque chose
!       de mani�re globale (� cause des appels � GRDCEL notamment)
  ncecpg = ncecpl
  ncedig = ncedis
  if (irangp.ge.0) then
    call parcpt(ncecpg)
    !==========
    call parcpt(ncedig)
    !==========
  endif


! --- Transfert des variables proprement dit.

  if (ncedig.gt.0) then

    call cscpce                                                   &
    !==========
  ( ifinia , ifinra ,                                             &
    ndim   , ncelet , ncel   , nfac   , nfabor , nfml   , nprfml, &
    nnod   , lndfac , lndfbr , ncelbr ,                           &
    nvar   , nscal  , nphas  ,                                    &
    ncedis , ityloc ,                                             &
    nideve , nrdeve , nituse , nrtuse ,                           &
    ivar   , iphas  ,                                             &
    ifacel , ifabor , ifmfbr , ifmcel , iprfml ,                  &
    ipnfac , nodfac , ipnfbr , nodfbr ,                           &
    ia(ilocpt) ,                                                  &
    idevel , ituser , ia     ,                                    &
    xyzcen , surfac , surfbo , cdgfac , cdgfbo , xyznod , volume ,&
    dt     , rtpa   , propce , propfa , propfb ,                  &
    coefa  , coefb  ,                                             &
    w1     , w2     , w3     , w4     , w5     , w6     ,         &
    ra(icoopt)      , ra(irvdis)      ,                           &
    rdevel , rtuser , ra     )

  endif

!       Cet appel est sym�trique, donc on teste sur NCEDIG et NCECPG
!       (rien a envoyer, rien a recevoir)
  if (ncedig.gt.0.or.ncecpg.gt.0) then

    call varcpl                                                   &
    !==========
  ( numcpl , ncedis , ncecpl , ityvar ,                           &
    ra(irvdis) ,                                                  &
    ra(irvcel) )

  endif


!====================================================================================
! 3.  TRADUCTION DU COUPLAGE EN TERME DE TERMES SOURCES
!====================================================================================

  if (ncecpg.gt.0) then

    call csc2ts                                                   &
    !==========
  ( ifinia , ifinra ,                                             &
    ndim   , ncelet , ncel   , nfac   , nfabor , nfml   , nprfml ,&
    nnod   , lndfac , lndfbr , ncelbr ,                           &
    nvar   , nscal  , nphas  ,                                    &
    nideve , nrdeve , nituse , nrtuse ,                           &
    ncecpl ,                                                      &
    ivar   , iphas  ,                                             &
    ifacel , ifabor , ifmfbr , ifmcel , iprfml ,                  &
    ipnfac , nodfac , ipnfbr , nodfbr ,                           &
    ia(ilcecp)      ,                                             &
    idevel , ituser , ia     ,                                    &
    xyzcen , surfac , surfbo , cdgfac , cdgfbo , xyznod , volume ,&
    dt     , rtpa   , propce , propfa , propfb ,                  &
    coefa  , coefb  ,                                             &
    crvexp , crvimp ,                                             &
!         ------   ------
    dam    , xam    ,                                             &
    ra(irvcel)      ,                                             &
    w1     , w2     , w3     , w4     , w5     , w6     ,         &
    rdevel , rtuser , ra     )

  endif

enddo
!     Fin de la boucle sur les couplages


!--------
! FORMATS
!--------
 1000 format(                                                           &
'@                                                            ',/,&
'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@',/,&
'@                                                            ',/,&
'@ @@ ATTENTION :                                             ',/,&
'@    =========                                               ',/,&
'@    LE COUPLAGE VIA LES FACES EN TANT QU''ELEMENTS          ',/,&
'@    SUPPORTS N''EST PAS ENCORE GERE PAR LE NOYAU.           ',/,&
'@                                                            ',/,&
'@  Le calcul ne peut etre execute.                           ',/,&
'@                                                            ',/,&
'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@',/,&
'@                                                            ',/)
!----
! FIN
!----

return
end
