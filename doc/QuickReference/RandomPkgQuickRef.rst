.. _UTILITY/RandomPkgQuickRef:

RandomPkg Quick Reference
#########################

.. _UTILITY/RandomPkgQuickRef/PackageReferences:

Package References
******************

Using :vhdlcode:`RandomPkg` requires the following references:

.. code-block:: VHDL

   library osvvm ;
   use osvvm.RandomPkg.all ;

.. _UTILITY/RandomPkgQuickRef/RandomizationObject:

Randomization Object
********************

Randomization requires a variable of protected type :vhdlcode:`RandomPType`.

.. code-block:: VHDL

   process
     variable RV : RandomPType ;

.. _UTILITY/RandomPkgQuickRef/InitializingTheSeed:

Initializing the Seed
*********************

Initialize the internal seed with :vhdlcode:`InitSeed`:

.. code-block:: VHDL

   RV.InitSeed(RV'instance_name) ;

.. _UTILITY/RandomPkgQuickRef/RandomizationWithARange:

Randomization with a Range
**************************

Randomly generate a value in a range, here 1 to 15.

.. code-block:: VHDL

   DataInt := RV.RandInt(1, 15) ;

Overloading for :vhdlcode:`std_logic_vector`, :vhdlcode:`unsigned` and :vhdlcode:`signed` require a size parameter
(last). Overloading for :vhdlcode:`real` produces an open range.

.. code-block:: VHDL

   DataReal := RV.RandReal(5.5, 99.3) ;
   DataSlv8 := RV.RandSlv(1, 15, 8) ;
   DataUv8  := RV.RandUnsigned(1, 15, 8) ;
   DataSv8  := RV.RandSigned(-8, 7, 8) ;

Overloading for :vhdlcode:`time` requires specification of time units.

.. code-block:: VHDL

   dTime := RV.RandTime(5 ns, 10 ns, 1 ns) ;

.. _UTILITY/RandomPkgQuickRef/RandomizationWithARangeExclude:

Randomization with a Range + Exclude
************************************

Randomly generate a value within a range (here 1 to 15) and exclude specified values (:vhdlcode:`integer_vector`), here
3, 5, and 7.

.. code-block:: VHDL

   dInt := RV.RandInt(1, 15, (3, 5, 7));

Exclude values are supported for :vhdlcode:`std_logic_vector`, :vhdlcode:`unsigned`, and :vhdlcode:`signed`, and are not
supported for type :vhdlcode:`time` or :vhdlcode:`real`.

.. code-block:: VHDL

   Slv8 := RV.RandSlv(1, 15, (3, 5, 7), 8);

.. _UTILITY/RandomPkgQuickRef/RandomizationOfASet:

Randomization of a Set
**********************

Randomly generate a set (:vhdlcode:`integer_vector`), here 1, 3, 5, 7, and 9.

.. code-block:: VHDL

   dInt := RV.RandInt( (1,3,5,7,9) ) ;

Overloading for :vhdlcode:`std_logic_vector`, :vhdlcode:`unsigned` and :vhdlcode:`signed` require a size parameter
(last). Also supported for type :vhdlcode:`time` and :vhdlcode:`real`.

.. code-block:: VHDL

   DataSlv8 := RV.RandSlv( (1,3,5,7,9), 8) ;
   dTime := RV.RandTime((1 ns, 3 ns, 5 ns));
   dReal := RV.RandReal( (1.1, 1.4, 2.1) );

.. _UTILITY/RandomPkgQuickRef/RandomizationOfASetExclude:

Randomization of a Set + Exclude
********************************

Randomly generate a set (:vhdlcode:`integer_vector`), here 1, 3, 5, 7, and 9 and exclude specified values
(:vhdlcode:`integer_vector`), here 3 and 7.

.. code-block:: VHDL

   dInt := RV.RandInt((1,3,5,7,9), (3,7)) ;

Overloading for :vhdlcode:`std_logic_vector`, :vhdlcode:`unsigned` and :vhdlcode:`signed` require a size parameter
(last). Also supported for type :vhdlcode:`time` and :vhdlcode:`real`.

.. _UTILITY/RandomPkgQuickRef/LargerThanIntegerRanges:

Larger than Integer Ranges
**************************

For :vhdlcode:`std_logic_vector`, :vhdlcode:`unsigned`, and :vhdlcode:`signed`, the following forms of functions
generate values larger than 32 bits. In the first example, 40 is the size of the vector. In the next examples,
:vhdlcode:`MIN_VAL_40` and :vhdlcode:`MAX_VAL_40` are a 40 bit :vhdlcode:`std_logic_vectors` that specify the minimum
and maximum values.

.. code-block:: VHDL

   dSlv40 := RV.RandSlv(40) ;
   dSlv40 := RV.RandSlv(MAX_VAL_V40) ;
   dSlv40 := RV.RandSlv(MIN_V40,MAX_V40) ;

.. _UTILITY/RandomPkgQuickRef/WeightedRandomization:

Weighted Randomization
**********************

Specify an array of values and weights and randomly select one of the values with a probability of the weight divided by
the sum of weights. In the following the first parameter is the value and the second is the weight. Hence values are 1,
3, and 5 and the weights 7, 2, and 1. As a result, the probability of 1 is (7/10) or 70%, 3 is (2/10) or 20%, and 5 is
10 %. Generally it is easiest if the weights sum up to either 10 or 100.

.. code-block:: VHDL

   dInt :=
      RV.DistValInt( ((1,7),(3,2),(5,1)) );

There is also a :vhdlcode:`DistValSlv`, :vhdlcode:`DistValUnsigned`, and :vhdlcode:`DistValSigned`. All of the functions
also support an exclude vector.

.. _UTILITY/RandomPkgQuickRef/SimpleWeightedRandomization:

Simple Weighted Randomization
*****************************

Specify N weights as an :vhdlcode:`integer_vector` (weights 7, 2, and 1) and randomly select a value in the range of the
weight parameter (for a literal, 0 to N-1 – here 0 to 2). The probability of each value being generated is the weight
divided by the sum of weights. Here the probability of 0 is (7/10) or 70%, 1 is (2/10) or 20%, and 2 is 10 %. Generally
it is easiest if the weights sum up to either 10 or 100.

.. code-block:: VHDL

   dInt := RV.DistInt( (7,2,1) ) ;

There is also a :vhdlcode:`DistSlv`, :vhdlcode:`DistUnsigned`, and :vhdlcode:`DistSigned`. All of the functions also
support an exclude vector.

.. _UTILITY/RandomPkgQuickRef/NormalAkaGaussianDistribution:

Normal, aka Gaussian Distribution
*********************************

A function :vhdlcode:`normal` receives a Mean (here 1.0) and Standard Deviation (here 0.025) and returns a random value
with a normal or Gaussian distribution.

.. code-block:: VHDL

   dReal := RV.normal(1.0, 0.025);

When the value is outside of the range specified by the optional minimum (here 0.9) or maximum (here 1.1), the value is
re-randomized.

.. code-block:: VHDL

   dReal := RV.normal(1.0, 0.025, 0.9, 1.1);

:vhdlcode:`Normal` is also overloaded to have :vhdlcode:`integer` return and minimum and maximum parameters as shown
below.

.. code-block:: VHDL

   dInt := RV.normal(100.0, 0.025, 90, 110);

.. _UTILITY/RandomPkgQuickRef/RandomSalt:

RandomSalt
**********

Salt is a value added to every call to :vhdlcode:`InitSeed` to allow different runs of a test to produce different
values. Set it with :vhdlcode:`SetRandomSalt`

.. code-block:: VHDL

   SetRandomSalt("2022.1031");

.. _UTILITY/RandomPkgQuickRef/OtherDistributions:

Other Distributions
*******************

See :ref:`RandomPkg Users Guide <UTILITY/RandomPkg>` for details.

.. _UTILITY/RandomPkgQuickRef/RandomizeVectorsOfIntegerRealTime:

Randomize vectors of Integer, Real, Time
****************************************

See :ref:`RandomPkg Users Guide <UTILITY/RandomPkg>` for details.

.. _UTILITY/RandomPkgQuickRef/Packages:

Packages
********

The following files are required for randomization, :file:`RandomPkg.vhd`, :file:`RandomBasePkg.vhd`, and
:file:`SortListPkg_int.vhd`. Generally we create an OSVVM library and compile these files into it. Note that some of the
simulator vendors have done this for you.
