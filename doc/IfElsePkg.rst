.. _UTILITY/IfElsePkg:

IfElsePkg
#########

.. _UTILITY/IfElsePkg/IfElsePkgOverview:

IfElsePkg Overview
******************

:vhdlcode:`IfElsePkg` provides a function that returns one of two input values based on a conditional. It is a stand in
for the "when else" language capability that is in VHDL-2019 (but is not currently supported by all simulators).

.. _UTILITY/IfElsePkg/IfElseFunction:

IfElse Function
***************

:vhdlcode:`IfElse` function returns the value from parameter :vhdlcode:`A` when the expression is true, otherwise, it
returns the value from parameter :vhdlcode:`B`. :vhdlcode:`AType` can be :vhdlcode:`string`, :vhdlcode:`std_logic`,
:vhdlcode:`std_logic_vector`, :vhdlcode:`integer`, or :vhdlcode:`boolean`.

.. code-block:: VHDL

   function IfElse(Expr : boolean ; A, B : AType) return AType ;

The targeted use of :vhdlcode:`IfElse` is in a constant expression, such as shown below.

.. code-block:: VHDL

   constant MODEL_INSTANCE_NAME : string := IfElse(MODEL_ID_NAME /= "",
         MODEL_ID_NAME, to_lower(PathTail(Axi4Manager'PATH_NAME))) ;

.. _UTILITY/IfElsePkg/CompilingAndUsingOSVVMUtilityLibrary:

Compiling and Using OSVVM Utility Library
*****************************************

Reference all packages in the OSVVM Utility library by using the context declaration:

.. code-block:: VHDL

   library OSVVM ;
     context osvvm.OsvvmContext ;

Compilation order for OSVVM Utility Library is in :osvvmdoc:`OSVVM_release_notes.pdf <osvvm_release_notes>`. Rather than
learning this, we recommend using the OSVVM compilation scripts.

OSVVM Utility library is released under the Apache open source license. It is free (both to download and use - there are
no license fees). You can download it from osvvm.org or from our development area on GitHub
(https://github.com/OSVVM/OSVVM).

If you add features to the package, please donate them back under the same license as candidates to be added to the
standard version of the package. If you need features, be sure to contact us.

We also support the OSVVM user community and blogs through http://www.osvvm.org. Interested in sharing about your
experience using OSVVM? Let us know, you can blog about it at osvvm.org.
