.. _UTILITY/CoveragePkgQuickRef:

CoveragePkg Quick Reference
###########################

.. _UTILITY/CoveragePkgQuickRef/ItemCoverage:

Item Coverage
*************

Item coverage tracks relationships within a single object. For example, tracking bins of values for a transfer may look
at the ranges, 1, 2, 3, 4 to 127, 128 to 252, 253, 254, and 255. The steps to model coverage are:

* Reference packages
* Declare the coverage ID
* Construct the Coverage Model
* Model coverage
* Accumulate coverage
* Detecting when done
* Print Results

.. _UTILITY/CoveragePkgQuickRef/ReferencePackages:

Reference Packages
******************

Using :vhdlcode:`CoveragePkg` requires the following references.

.. code-block:: VHDL

   library osvvm ;
   use osvvm.CoveragePkg.all ;

.. _UTILITY/CoveragePkgQuickRef/DeclareTheCovergeID:

Declare the Coverage ID
***********************

A :vhdlcode:`CoverageID` is a handle to the coverage object that is created internal to :vhdlcode:`CoveragePkg`. The
object can be a signal or a variable.

.. code-block:: VHDL

   signal Cov1 : CoverageIDType ;

.. _UTILITY/CoveragePkgQuickRef/ConstructTheCoverageModel:

Construct the Coverage Model
****************************

.. code-block:: VHDL

   Cov1 <= NewID("Cov1") ;
   wait for 0 ns ; -- Update Cov1

.. _UTILITY/CoveragePkgQuickRef/ModelCoverageItemCoverage:

Model Coverage: Item Coverage
*****************************

Coverage items are added to a coverage model by calling procedure :vhdlcode:`AddBins` and function :vhdlcode:`GenBin`
one or more times. :vhdlcode:`GenBin` transforms a bin descriptor into a set of bins. :vhdlcode:`AddBins` inserts these
bins into the coverage data structure. The version of :vhdlcode:`GenBin` shown below has three parameters: min value,
max value, and number of bins. The call, :vhdlcode:`GenBin(1,3,3)`, breaks the range 1 to 3 into the 3 separate bins
with ranges 1 to 1, 2 to 2, 3 to 3.

.. code-block:: VHDL

   AddBins(Cov1, GenBin(1, 3, 3)) ;

Additional calls to :vhdlcode:`AddBins` appends bins to the data structure. As a result, the call,
:vhdlcode:`GenBin(4, 252, 2)`, appends two bins with the ranges 4 to 127 and 128 to 252 respectively to the coverage
model.

.. code-block:: VHDL

   AddBins(Cov1, GenBin(  4, 252, 2)) ;

:vhdlcode:`GenBin` with two parameters, min value and max value, creates one bin per value. As a result, the call
:vhdlcode:`GenBin(253, 255)` appends three bins with the ranges 253 to 253, 254 to 254, and 255 to 255.

.. code-block:: VHDL

   AddBins(Cov1, GenBin(253, 255)) ;

.. _UTILITY/CoveragePkgQuickRef/AccumulateCoverageItemCoverage:

Accumulate Coverage: Item Coverage
**********************************

Coverage is accumulated using the method :vhdlcode:`ICover`.

.. code-block:: VHDL

   ICover(Cov1, to_integer(Data_slv)) ;

.. _UTILITY/CoveragePkgQuickRef/DetectingWhenDone:

Detecting when Done
*******************

The method :vhdlcode:`IsCovered` returns true when the functional coverage reaches 100%. Generally used in a loop:

.. code-block:: VHDL

   exit when IsCovered(Cov1); -- done?

.. _UTILITY/CoveragePkgQuickRef/PrintResults:

Print Results
*************

:vhdlcode:`WriteBin` and :vhdlcode:`WriteCovHoles` print the coverage results.

.. code-block:: VHDL

   WriteBin(Cov1) ; -- Print All Bins
   WriteCovHoles(Cov1) ; -- Print Holes

.. _UTILITY/CoveragePkgQuickRef/ItemCoverageCompleteExample:

Item Coverage, Complete Example
*******************************

.. code-block:: VHDL

   library osvvm ;
   use osvvm.CoveragePkg.all ;
   architecture Test1 of tb is
     signal Cov1 : CoverageIDType ;
   begin
     TestProc : process
     begin
       Cov1 <= NewID("Cov1") ;
       wait for 0 ns ; -- update Cov1
       AddBins(Cov1, GenBin(1, 3)) ;
       AddBins(Cov1, GenBin(4, 252, 2)) ;
       AddBins(Cov1, GenBin(253, 255 )) ;
       loop
         wait until rising_edge(Clk) ;
         ICover(Cov1, to_integer(RxData)) ;
         exit when IsCovered(Cov1); -- done?
       end loop ;
       WriteBin(Cov1) ; -- Print Results
       wait ;
     end process ;

.. _UTILITY/CoveragePkgQuickRef/CrossCoverage:

Cross Coverage
**************

Cross coverage examines the relationships between different objects, such as making sure that each register source has
been used with an ALU.

Collecting cross coverage only differs from item coverage in the model and accumulate steps.

.. _UTILITY/CoveragePkgQuickRef/ModelCoverageCrossCoverage:

Model Coverage: Cross Coverage
******************************

The method :vhdlcode:`AddCross` creates the cross product of the set of bins (created by :vhdlcode:`GenBin`) on its
inputs. The code below creates an 8 x 8 cross. Each call to :vhdlcode:`GenBin(0,7)` creates the 8 bins: 0, 1, 2, 3, 4,
5, 6, 7. The :vhdlcode:`AddCross` creates the 64 bin cross product of these bins.

.. code-block:: VHDL

   AddCross(Cov, GenBin(0,7), GenBin(0,7) );

:vhdlcode:`AddCross` supports crossing from 2 to 20 items.

.. _UTILITY/CoveragePkgQuickRef/AccumulateCoverageCrossCoverage:

Accumulate Coverage: Cross Coverage
***********************************

To accumulate cross coverage the :vhdlcode:`ICover` parameter becomes an :vhdlcode:`integer_vector`, with one integer
value per element in the cross product.

.. code-block:: VHDL

   ICover(Cov, (Src1, Src2) ) ;

.. _UTILITY/CoveragePkgQuickRef/CrossCoverageCompleteExample:

Cross Coverage, Complete Example
********************************

In the following example, coverage is accumulated on a transaction basis.

.. code-block:: VHDL

   architecture Test2 of tb is
     signal Cov : CoverageIDType ;
   begin
     TestProc : process
       variable Src1, Src2 : integer ;
     begin
      Cov <= NewID("Cov") ;
      wait for 0 ns ; -- update Cov
      AddCross(Cov,GenBin(0,7),GenBin(0,7));
      loop
        -- Randomize test values,
        -- see Intelligent Coverage
        (Src1, Src2) := GetRandPoint(Cov) ;
        DoAluOp(TRec, Src1, Src2) ;
        ICover(Cov, (Src1, Src2) ) ;
        exit when IsCovered(Cov); -- done?
       end loop ;
       WriteBin(Cov) ; -- Print Results
       ReportAlerts ;
     end process ;

.. _UTILITY/CoveragePkgQuickRef/ConstrainedRandomIsSlower:

Constrained Random is Slower
****************************

Constrained random uses uniform randomization to generate tests. For example in the last example, we could have used two
calls to :vhdlcode:`RandInt` to generate the test values.

.. code-block:: VHDL

   Src1 := RV.RandInt(0, 7) ;
   Src2 := RV.RandInt(0, 7) ;

Unfortunately, constrained random tests repeat numerous test cases before generating all test cases. In general, to
generate N cases, it takes "N \* log N" randomizations. The "log N" represents repeated test cases and significantly
adds to simulation run times. The above calls result in around 5X redundant vectors.

.. _UTILITY/CoveragePkgQuickRef/IntelligentCoverage:

Intelligent Coverage
********************

Ideally when we randomize a test we would like to only generate the N test cases we need. Intelligent Coverage does this
by doing a random walk across the coverage model.

The method :vhdlcode:`GetRandPoint` randomly selects a hole in the coverage model and passes this to the stimulus
generation. For item coverage it returns an integer value and for cross coverage it returns an
:vhdlcode:`integer_vector` value. The previous cross coverage example uses the following call to generate stimulus.

.. code-block:: VHDL

   (Src1, Src2) := GetRandPoint(Cov) ;

.. _UTILITY/CoveragePkgQuickRef/WeightedIntelligentCoverage:

Weighted Intelligent Coverage
*****************************

By default, the coverage goal is 1. :vhdlcode:`AddBins` and :vhdlcode:`AddCross` are overloaded to support coverage
goals larger than 1. For example, the following sets each bin in the cross to have a coverage goal of 10.

.. code-block:: VHDL

   AddCross(Cov,10,GenBin(0,7),GenBin(0,7));

The coverage goal is specified as the first parameter to :vhdlcode:`AddBins` or :vhdlcode:`AddCross`.

The coverage goal is also used as the randomization weight. Hence, bins with larger coverage goals are generated more
often. This can be used to generate some conditions, transactions, or sequences more than others. Such as more normal
transactions than error transactions. The following generates the value 0 70% of the time, a 1 20% of the time, and a 2
10% of the time.

.. code-block:: VHDL

   AddBins(Cov1, 70, GenBin(0) ) ;
   AddBins(Cov1, 20, GenBin(1) ) ;
   AddBins(Cov1, 10, GenBin(2) ) ;

.. _UTILITY/CoveragePkgQuickRef/RandomizationWeightMode:

Randomization Weight Mode
*************************

Weight Mode controls whether randomization uses the coverage goal for a bin as the randomization weight
(:vhdlcode:`AT_LEAST` mode) or the remaining coverage for a bin as the randomization weight (:vhdlcode:`REMAIN` mode =
coverage goal – current coverage = default).

.. code-block:: VHDL

   SetWeightMode (Cov, REMAIN);

.. _UTILITY/CoveragePkgQuickRef/Thresholds:

Thresholds
**********

Rather than randomly selecting any bin whose coverage < 100%, only randomly select bins whose coverage is <=
(:vhdlcode:`MinCov` + Threshold).

.. code-block:: VHDL

   SetCovThreshold(Cov, 30.0);

Use :vhdlcode:`SetThresholding` to disable or enable Thresholding.

.. code-block:: VHDL

   SetThresholding(Cov, FALSE);

.. _UTILITY/CoveragePkgQuickRef/IncreasingDecreasingRunLength:

Increasing / Decreasing run length
**********************************

By default the coverage target is 100.0. Changing the coverage target changes the coverage goals by that amount. The
following increases coverage goals (and hence run length) by 10X:

.. code-block:: VHDL

   SetCovTarget(Cov, 1000.0 ); -- = 100 * 10

The following decreases coverage goals by 10X:

.. code-block:: VHDL

   SetCovTarget(Cov, 10.0 ); -- = 100 / 10

.. _UTILITY/CoveragePkgQuickRef/IllegalBins:

Illegal Bins
************

Illegal bins signal the receipt of illegal (invalid) values. Illegal bins are not for handled errors (such as parity
errors). Illegal bins are never generated by Intelligent Coverage.

The method :vhdlcode:`IllegalBin` (similar to :vhdlcode:`GenBin`) designates a bin to be an illegal bin. The following
creates the range 1 to 9 in a single illegal bin.

.. code-block:: VHDL

   IllegalBin(1,9)

The method :vhdlcode:`SetIllegalMode` controls signaling when a value is in an illegal bin. See the
:ref:`CoveragePkg User Guide <UTILITY/CoveragePkg>` for details

Errors detected by the coverage model are reported as alerts and are reported by :vhdlcode:`ReportAlerts`.

.. _UTILITY/CoveragePkgQuickRef/GetCov:

GetCov
******

Returns the total coverage for all coverage models:

.. code-block:: VHDL

   TotalCov := GetCov ;

.. _UTILITY/CoveragePkgQuickRef/SettingCoverageWeights:

Setting Coverage Weights
************************

The coverage weight is a multiplying factor in determining the total coverage. :vhdlcode:`CovWeight` is 1 by default.
Set it to 0 to ignore the coverage model in total coverage calculations

.. code-block:: VHDL

   SetCovWeight (Cov, 0);

.. _UTILITY/CoveragePkgQuickRef/SetGetTheInternalAlertLogID:

Set / Get the Internal AlertLogID
*********************************

The internal :vhdlcode:`AlertLogID` is set using the name specified by :vhdlcode:`NewID`. Read it with
:vhdlcode:`GetAlertLogID`.

.. code-block:: VHDL

   Cov <= NewID("Cov") ;
   . . .

   CovAlertID <= GetAlertLogID(Cov) ;

.. _UTILITY/CoveragePkgQuickRef/ConstantsCoverageType:

Constants Coverage Type
***********************

The return value from :vhdlcode:`GenBin` is of type :vhdlcode:`CovBinType`. It is defined as follows.

.. code-block:: VHDL

   type CovBinType is array
     (natural range <>) of CovBinBaseType;

This allows the definition of constants.

.. code-block:: VHDL

   constant REG_COV : CovBinType :=
       GenBin(0,7) & GenBin(9) ;

.. _UTILITY/CoveragePkgQuickRef/NamingIndividualBins:

Naming Individual Bins
**********************

Individual bin names are specified as follows:

.. code-block:: VHDL

   AddBins(Cov1, "PARITY_ERROR", . . .) ;
   AddCross(Cov2, "S1 -> S2", . . .) ;

.. _UTILITY/CoveragePkgQuickRef/ItemBinNamesColumnsInTheReport:

Item Bin Names (Columns in the report)
**************************************

Specify one name per item bin.

.. code-block:: VHDL

   SetItemBinNames(Cov1,"Bin1", . . .) ;

.. _UTILITY/CoveragePkgQuickRef/TestCaseDetailedReports:

Test Case Detailed Reports
**************************

Call :vhdlcode:`EndOfTestReports` (see :ref:`AlertLogPkg <UTILITY/AlertLogPkg>`) at the end of a test to get a report
for each coverage model in the test case in :file:`Reports/<TestName>.html`.

.. _UTILITY/CoveragePkgQuickRef/MoreDetailedInformation:

More Detailed Information
*************************

See: :ref:`UTILITY/CoveragePkg`.
