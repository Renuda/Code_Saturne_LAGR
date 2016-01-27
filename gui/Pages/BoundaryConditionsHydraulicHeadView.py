# -*- coding: utf-8 -*-

#-------------------------------------------------------------------------------

# This file is part of Code_Saturne, a general-purpose CFD tool.
#
# Copyright (C) 1998-2015 EDF S.A.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA 02110-1301, USA.

#-------------------------------------------------------------------------------

"""
This module contains the following classes:
- BoundaryConditionsHydraulicHeadView
"""

#-------------------------------------------------------------------------------
# Standard modules
#-------------------------------------------------------------------------------

import string, logging

#-------------------------------------------------------------------------------
# Third-party modules
#-------------------------------------------------------------------------------

from PyQt4.QtCore import *
from PyQt4.QtGui  import *

#-------------------------------------------------------------------------------
# Application modules import
#-------------------------------------------------------------------------------

from code_saturne.Base.Toolbox import GuiParam
from code_saturne.Base.QtPage import DoubleValidator, ComboModel, from_qvariant, setGreenColor

from code_saturne.Pages.BoundaryConditionsHydraulicHeadForm import \
     Ui_BoundaryConditionsHydraulicHeadForm
from code_saturne.Pages.LocalizationModel import LocalizationModel, Zone
from code_saturne.Pages.Boundary import Boundary
from code_saturne.Pages.QMeiEditorView import QMeiEditorView

#-------------------------------------------------------------------------------
# log config
#-------------------------------------------------------------------------------

logging.basicConfig()
log = logging.getLogger("BoundaryConditionsHydraulicHeadView")
log.setLevel(GuiParam.DEBUG)

#-------------------------------------------------------------------------------
# Main class
#-------------------------------------------------------------------------------

class BoundaryConditionsHydraulicHeadView(QWidget, Ui_BoundaryConditionsHydraulicHeadForm):
    def __init__(self, parent):
        """
        Constructor
        """
        QWidget.__init__(self, parent)

        Ui_BoundaryConditionsHydraulicHeadForm.__init__(self)
        self.setupUi(self)


    def setup(self, case):
        """
        Setup the widget
        """
        self.__case = case
        self.__boundary = None

        self.__case.undoStopGlobal()

        # Validators
        validatorHh   = DoubleValidator(self.lineEditValueHydraulicHead)
        validatorExHh = DoubleValidator(self.lineEditExHydraulicHead)

        # Apply validators
        self.lineEditValueHydraulicHead.setValidator(validatorHh)
        self.lineEditExHydraulicHead.setValidator(validatorHh)

        self.modelTypeHydraulic = ComboModel(self.comboBoxTypeHydraulicHead, 1, 1)
        self.modelTypeHydraulic.addItem(self.tr("Prescribed value"), 'dirichlet')
        self.modelTypeHydraulic.addItem(self.tr("Prescribed value  (user law)"), 'dirichlet_formula')
        self.modelTypeHydraulic.addItem(self.tr("Prescribed flux"), 'neumann')

        # Connections
        self.connect(self.lineEditValueHydraulicHead,   SIGNAL("textChanged(const QString &)"), self.slotHydraulicHeadValue)
        self.connect(self.lineEditExHydraulicHead,      SIGNAL("textChanged(const QString &)"), self.slotHydraulicHeadFlux)
        self.connect(self.pushButtonHydraulicHead,      SIGNAL("clicked()"), self.slotHydraulicHeadFormula)
        self.connect(self.comboBoxTypeHydraulicHead,    SIGNAL("activated(const QString&)"), self.slotHydraulicHeadChoice)

        self.__case.undoStartGlobal()


    def showWidget(self, boundary):
        """
        Show the widget
        """
        label = boundary.getLabel()
        self.nature  = boundary.getNature()
        self.__boundary = Boundary(self.nature, label, self.__case)
        self.initialize()


    def initialize(self):
        self.labelValueHydraulicHead.hide()
        self.labelExHydraulicHead.hide()
        self.lineEditValueHydraulicHead.hide()
        self.lineEditExHydraulicHead.hide()
        self.pushButtonHydraulicHead.setEnabled(False)
        setGreenColor(self.pushButtonHydraulicHead, False)

        HydraulicChoice = self.__boundary.getHydraulicHeadChoice()
        if HydraulicChoice == 'dirichlet':
            self.labelValueHydraulicHead.show()
            self.lineEditValueHydraulicHead.show()
            pressure = self.__boundary.getHydraulicHeadValue()
            self.lineEditValueHydraulicHead.setText(str(pressure))
        elif HydraulicChoice == 'neumann':
            self.labelExHydraulicHead.show()
            self.lineEditExHydraulicHead.show()
            pressure = self.__boundary.getHydraulicHeadFlux()
            self.lineEditExHydraulicHead.setText(str(pressure))
        elif HydraulicChoice == 'dirichlet_formula':
            self.pushButtonHydraulicHead.setEnabled(True)
            setGreenColor(self.pushButtonHydraulicHead, True)

        self.show()


    def hideWidget(self):
        """
        Hide all
        """
        self.hide()


    @pyqtSignature("const QString&")
    def slotHydraulicHeadValue(self, text):
        """
        INPUT hydraulic head value
        """
        if self.sender().validator().state == QValidator.Acceptable:
            t = from_qvariant(text, float)
            self.__boundary.setHydraulicHeadValue(t)


    @pyqtSignature("const QString&")
    def slotHydraulicHeadFlux(self, text):
        """
        INPUT hydraulic head flux
        """
        if self.sender().validator().state == QValidator.Acceptable:
            t = from_qvariant(text, float)
            self.__boundary.setHydraulicHeadFlux(t)


    @pyqtSignature("")
    def slotHydraulicHeadFormula(self):
        """
        """
        exp = self.__boundary.getHydraulicHeadFormula()
        exa = """#example: """
        req = [("H", "hydraulic head")]

        sym = [('x', "X face's gravity center"),
               ('y', "Y face's gravity center"),
               ('z', "Z face's gravity center"),
               ('dt', 'time step'),
               ('t', 'current time'),
               ('iter', 'number of iteration')]

        dialog = QMeiEditorView(self,
                                check_syntax = self.__case['package'].get_check_syntax(),
                                expression = exp,
                                required   = req,
                                symbols    = sym,
                                examples   = exa)
        if dialog.exec_():
            result = dialog.get_result()
            log.debug("slotHydraulicHeadFormula -> %s" % str(result))
            self.__boundary.setHydraulicHeadFormula(result)
            setGreenColor(self.pushButtonHydraulicHead, False)


    @pyqtSignature("const QString&")
    def slotHydraulicHeadChoice(self, text):
        """
        INPUT label for choice of zone
        """
        HydraulicChoice = self.modelTypeHydraulic.dicoV2M[str(text)]
        self.__boundary.setHydraulicHeadChoice(HydraulicChoice)
        self.initialize()


    def tr(self, text):
        """
        Translation
        """
        return text

#-------------------------------------------------------------------------------
# End
#-------------------------------------------------------------------------------
