.. _UTILITY/RandomPkg:

Randomization Using RandomPkg
#############################

.. _UTILITY/RandomPkg/RandomPkgOverview:

RandomPkg Overview
******************

:vhdlcode:`RandomPkg` provides a set of utilities for randomizing a value in a range, a value in a set, or a value with
a weighted distribution.

OSVVM's constrained random capability uses these utilities to randomize a value, operation, or sequence that is valid in
a particular test environment. Since any constrained random methodology creates a significant amount of redundant
stimulus (5X or more for small problems), in OSVVM, we use Intelligent Coverage randomization as our main randomization
methodology, and constrained random as a refinement methodology in our tests.

These packages are updated from time to time and are freely available at https://github.com/OSVVM/OsvvmLibraries.

.. _UTILITY/RandomPkg/RandomizationUsingIEEEMathRealUniformYuck:

Randomization Using IEEE.math_real.uniform = Yuck!
**************************************************

A basic form of randomization can be accomplished by using the procedure :vhdlcode:`uniform` from the IEEE
:vhdlcode:`math_real` package. However, this always results in randomization being a multi-step process: call
:vhdlcode:`uniform` to randomize a value, scale the value, and then use the value.

.. code-block:: VHDL
   :force:

   RandomGenProc : process
     variable RandomVal : real ;                      -- Random value
     variable DataSent : integer ;
     variable seed1 : positive := 7 ;                 -- initialize seeds
     variable seed2 : positive := 1 ;
   begin
     for i in 0 to 255*6 loop
       uniform(seed1, seed2, RandomVal) ;             -- randomize 0.0 to 1.0
       DataSent := integer(trunc(RandomVal*256.0)) ;   -- scale to 0 to 255
       do_transaction(…, DataSent, …) ;
       . . .

Optimally we would like to be able to do this in one step with a function call. Unfortunately we cannot use a function
since we need to read and update the seed as well as return a randomized value.

.. _UTILITY/RandomPkg/SimplifyingRandomization:

Simplifying Randomization
*************************

:vhdlcode:`RandomPkg` uses a protected type, named :vhdlcode:`RandomPType`, to encapsulate the seed and randomization
methods. Within a protected type, impure functions can read and update the seed as well as return a randomized value. To
randomize values using the protected type, declare a variable of type :vhdlcode:`RandomPType`, initialize the seed, and
randomize values.

.. code-block:: VHDL
   :force:

   RandomGenProc : process
     variable RV : RandomPType ;                    -- protected type from RandomPkg
   begin
     RV.InitSeed (RV'instance_name)  ;               -- Generate initial seeds
     for i in 0 to 255*6 loop
       do_transaction(…, RV.RandInt(0, 255), …) ;   -- random value between 0 and 255

Note the calls to protected type methods (subprograms) include the protected type variable (:vhdlcode:`RV`) within the
call (such as :vhdlcode:`RV.RandInt(0, 255)`).

Randomization uses a regular variable rather than a shared variable. As a result, each process that does randomization
needs to declare its own variable. For a discussion of why not to use shared variables, see the
:ref:`Random Stability <UTILITY/RandomPkg/RandomStability>` section.

.. _UTILITY/RandomPkg/InitializingTheSeeds:

Initializing the Seeds
**********************

:vhdlcode:`InitSeed` is used to initialize the seed. Internal to the protected type, the seed has a valid initial value.
The seed needs to be initialized (with a different value) to ensure that each process that is doing randomization will
produce a unique sequence of values. If only one process is doing randomization, the seed does not need to be
initialized.

The :vhdlcode:`InitSeed` method supports either :vhdlcode:`string`, :vhdlcode:`integer`, :vhdlcode:`time`, or
:vhdlcode:`integer_vector` parameters and uses a hash function to convert these values to the internal seed
representation.

The overloading for the :vhdlcode:`InitSeed` is as follows.

.. code-block:: VHDL

   procedure InitSeed (
     S                 : string ;
     UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS ) ;
   procedure InitSeed (
     I                 : integer ;
     UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS) ;
   procedure InitSeed (
     T                 : time ;
     UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS) ;
   procedure InitSeed (
     IV                : integer_vector ;
     UseNewSeedMethods : boolean := RANDOM_USE_NEW_SEED_METHODS);

The preferred way to give each seed a unique value is to pass the string value, :vhdlcode:`RV'instance_name`. Be sure to
name the process when using this method.

.. code-block:: VHDL

   RV.InitSeed (RV'instance_name, TRUE)  ;

The value :vhdlcode:`RANDOM_USE_NEW_SEED_METHODS` is set to TRUE for all 2024 or later versions of OSVVM. See
:ref:`UTILITY/OsvvmSettings` for more on this setting. For new testbenches, set the :vhdlcode:`UseNewSeedMethods`
parameter to TRUE. For older tests for which you need to have the same sequence of values they are currently generating,
be sure to update calls to :vhdlcode:`InitSeed` to set :vhdlcode:`UseNewSeedMethods` to FALSE.

Why did we do this? With the old seed methods when the seeds were close together, it was not unusual to generate the
same first value. The rest of the sequence values were unique. The :vhdlcode:`NewSeedMethods` addresses this issue by
both using better hash functions and churning the seeds.

.. _UTILITY/RandomPkg/BasicRandomization:

Basic Randomization
*******************

The basic randomization generates a value that is either within some range or within a set of values. Optionally a set
of exclude values can be specified. The set of values and exclude values are all of type :vhdlcode:`integer_vector`
(VHDL-2008). The examples below show the basic randomization overloading. When a value of :vhdlcode:`integer_vector` is
specified, the extra set of parentheses denote that it is an aggregate value.

.. code-block:: VHDL

   RandomGenProc : process
     variable RV      : RandomPType ;         -- protected type from RandomPkg
     variable DataInt : integer ;
   begin
     RV.InitSeed (RV'instance_name)  ;         -- Generate initial seeds

     -- Generate a value in range 0 to 255
     DataInt := RV.RandInt(0, 255) ;
     . . .
     -- Generate a value in range 1 to 9 except exclude values 2,4,6,8
     DataInt := RV.RandInt(1, 9, (2,4,6,8)) ;
     . . .
     -- Generate a value in set 1,3,5,7,9
     DataInt := RV.RandInt( (1,3,5,7,9) ) ;  -- note two sets of parens required
     . . .
     -- Generate a value in set 1,3,5,7,9 except exclude values 3,7
     DataInt := RV.RandInt((1,3,5,7,9), (3,7) ) ;

The overloading for the :vhdlcode:`RandInt` functions is as follows.

.. code-block:: VHDL

   impure function RandInt (Min, Max : integer) return integer ;
   impure function RandInt (Min, Max: integer; Exclude: integer_vector)
       return integer ;
   impure function RandInt ( A : integer_vector ) return integer ;
   impure function RandInt ( A : integer_vector; Exclude: integer_vector)
       return integer ;

These same functions are available for types :vhdlcode:`std_logic_vector`\ (:vhdlcode:`RandSlv`), :vhdlcode:`unsigned`
(:vhdlcode:`RandUnsigned`) and :vhdlcode:`signed` (:vhdlcode:`RandSigned`). Note that parameter values are still
specified as integers and there is an additional value used to specify the size of the value to generate. For example,
the following call to :vhdlcode:`RandSlv` defines the array size to be 8 bits.

.. code-block:: VHDL

     variable DataSlv : std_logic_vector(7 downto 0) ;
   begin
     . . .
       DataSlv := RV.RandSlv(0, 255, 8) ; -- Generate a value in range 0 to 255

The overloading for :vhdlcode:`RandSlv` is as shown below. :vhdlcode:`RandUnsigned` and :vhdlcode:`RandSigned` have the
same overloading

.. code-block:: VHDL

   impure function RandSlv (
       Min, Max, Size : natural) return std_logic_vector ;
   impure function RandSlv (
       Min, Max : natural ;
       Exclude  : integer_vector ;
       Size     : natural)  return std_logic_vector ;
   impure function RandSlv (
       Min, Max : natural ;
       Exclude  : integer ;
       Size     : natural)  return std_logic_vector ;
   impure function RandSlv (
       A       : integer_vector ;
       size    : natural ) return std_logic_vector ;
   impure function RandSlv (
       A       : integer_vector ;
       Exclude : integer_vector ;
       Size    : natural)  return std_logic_vector ;
   impure function RandSlv (
       A       : integer_vector ;
       Exclude : integer ;
       Size    : natural)  return std_logic_vector ;

The function, :vhdlcode:`RandReal` supports randomization for type :vhdlcode:`real`. The function with a range, like the
procedure :vhdlcode:`Uniform`, never generates its end values. :vhdlcode:`RandReal` has the following overloading:

.. code-block:: VHDL

   impure function RandReal ( Min, Max : real ) return real ;
   impure function RandReal ( A : real_vector ) return real ;
   impure function RandReal ( A, Exclude : real_vector ) return real ;
   impure function RandReal ( A : real_vector; Exclude : real ) return real ;

The function, :vhdlcode:`RandTime` supports randomization for type :vhdlcode:`time`. :vhdlcode:`RandTime` supports the
same overloading as :vhdlcode:`RandInt`. These are shown below:

.. code-block:: VHDL

   impure function RandTime (Min, Max : time ; Unit : time := ns) return time ;
   impure function RandTime
      (Min, Max : time ; Exclude : time_vector ; Unit : time := ns) return time ;
   impure function RandTime
      (Min, Max : time ; Exclude : time ; Unit : time) return time ;
   impure function RandTime (A : time_vector) return time ;
   impure function RandTime (A, Exclude : time_vector) return time ;
   impure function RandTime (A : time_vector; Exclude : time) return time ;

The functions, :vhdlcode:`RandBool`, :vhdlcode:`RandSl`, :vhdlcode:`RandBit`, support randomization for types
:vhdlcode:`boolean`, :vhdlcode:`std_logic`, and :vhdlcode:`bit` respectively. These are shown below:

.. code-block:: VHDL

   impure function RandBool return boolean;
   impure function RandSl return std_logic;
   impure function RandBit return bit;

.. _UTILITY/RandomPkg/LargeVectorRandomization:

Large Vector Randomization
**************************

Integer randomization is only valid in the range of -2**31 to +2**31 - 1. Large vector randomization uses multiple
randomizations to create a value. The following overloading is available for :vhdlcode:`RandUnsigned`,
:vhdlcode:`RandSlv`, and :vhdlcode:`RandSigned`.

.. code-block:: VHDL

   impure function RandUnsigned (Size : natural) return unsigned ;
   impure function RandUnsigned (Max : unsigned) return unsigned ;
   impure function RandUnsigned (Min, Max : unsigned) return unsigned ;
   impure function RandUnsigned (Size : natural ;
       Exclude : uv_vector) return unsigned ;
   impure function RandUnsigned (Min, Max : unsigned ;
       Exclude : uv_vector) return unsigned ;

The :vhdlcode:`size` parameter specifies the number of bits in the vector. The :vhdlcode:`Max` parameter allows
randomization between 0 and :vhdlcode:`Max`. The :vhdlcode:`Min` and :vhdlcode:`Max` parameters allow randomizing a
range of values.

.. _UTILITY/RandomPkg/RandomizingSetsOfValues:

Randomizing Sets of Values
**************************

A set of values can be represented by :vhdlcode:`integer_vector`, :vhdlcode:`real_vector`, or :vhdlcode:`time_vector`.
The following illustrates the capability supported for :vhdlcode:`integer_vector`.

.. code-block:: VHDL

   RandomGenProc : process
     variable RV      : RandomPType ;         -- protected type from RandomPkg
     variable IntV : integer_vector(1 to 15) ;
   begin
     RV.InitSeed (RV'instance_name)  ;         -- Generate initial seeds

     -- Generate 10 integer values in the range 0 to 255
     IntV(1 to 10) := RV.RandIntV(0, 255, 10) ;
     . . .
     -- Generate 15 integer values in range 1 to 9 except exclude values 2,4,6,8
    IntV := RV.RandIntV(1, 9, (2,4,6,8), 15) ;
     . . .
     -- Generate 5 integer values in set 1,3,5,7,9
     IntV(1 to 5) := RV.RandIntV( (1,3,5,7,9), 5 ) ;
     . . .
     -- Generate 15 integer values in set 1,3,5,7,9 except exclude values 3,7
     IntV := RV.RandIntV((1,3,5,7,9), (3,7), 15) ;

     -- Generate 10 integer values in the range 0 to 99, do not repeat the last value
     IntV(1 to 10) := RV.RandIntV(0, 99, 1, 10) ;
     . . .
     -- Generate 15 integer values in range 1 to 9 except exclude values 2,4,6,8
     -- Do not repeat the last 3 values
    IntV:= RV.RandIntV(1, 9, (2,4,6,8), 3, 15) ;
     . . .
     -- Generate 5 integer values in the set 1,3,5,7,9, do not repeat the last value
     IntV(1 to 5) := RV.RandIntV( (1,3,5,7,9), 1, 5 ) ;
     . . .
     -- Generate 15 integer values in set 1,3,5,7,9 except exclude values 3,7
     -- Do not repeat last value
     IntV := RV.RandIntV((1,3,5,7,9), (3,7), 1, 15) ;

The overloading for :vhdlcode:`integer_vector`, :vhdlcode:`real_vector`, or :vhdlcode:`time_vector` are as follows.

.. code-block:: VHDL

   -- Range and Exclude
   impure function RandIntV (Min, Max : integer ; Size : natural) return
   integer_vector ;
   impure function RandIntV (Min, Max : integer ; Exclude : integer_vector ; Size :
   natural) return integer_vector ;
   -- Range, Exclude, and Unique
   impure function RandIntV (Min, Max : integer ; Unique : natural ; Size : natural)
   return integer_vector ;
   impure function RandIntV (Min, Max : integer ; Exclude : integer_vector ; Unique :
   natural ; Size : natural) return integer_vector ;
   impure function RandIntV (Min, Max : integer ; Exclude : integer ; Unique :
   natural ; Size : natural) return integer_vector ;
   -- Set and Exclude
   impure function RandIntV (A : integer_vector ; Size : natural) return
   integer_vector ;
   impure function RandIntV (A, Exclude : integer_vector ; Size : natural) return
   integer_vector ;
   -- Set, Exclude, and Unique
   impure function RandIntV (A : integer_vector ; Unique : natural ; Size : natural)
   return integer_vector ;
   impure function RandIntV (A, Exclude : integer_vector ; Unique : natural ; Size :
   natural) return integer_vector ;
   impure function RandIntV     (A : integer_vector ; Exclude : integer ; Unique :
   natural ; Size : natural) return integer_vector ;

Overloading for :vhdlcode:`time_vector`:

.. code-block:: VHDL

   impure function RandTimeV (Min, Max : time; Size : natural; Unit : time := ns)
   return time_vector;
   impure function RandTimeV  (Min, Max : time ; Exclude : time_vector; Size :
   natural) return time_vector ;
   impure function RandTimeV  (Min, Max : time ; Exclude : time; Size : natural)
   return time_vector ;
   impure function RandTimeV (Min, Max : time; Unique : natural; Size : natural; Unit
   : time := ns) return time_vector ;
   impure function RandTimeV (Min, Max : time; Exclude : time_vector; Unique :
   natural; Size : natural) return time_vector;
   impure function RandTimeV (Min, Max : time; Exclude : time; Unique : natural; Size
   : natural) return time_vector;
   impure function RandTimeV (A : time_vector; Size : natural) return time_vector ;
   impure function RandTimeV (A : time_vector; Unique : natural ; Size : natural)
   return time_vector;
   impure function RandTimeV (A, Exclude : time_vector; Size : natural) return
   time_vector ;
   impure function RandTimeV (A : time_vector; Exclude : time; Size : natural) return time_vector ;
   impure function RandTimeV (A, Exclude : time_vector; Unique : natural; Size :
   natural) return time_vector ;
   impure function RandTimeV (A : time_vector; Exclude : time; Unique : natural; Size : natural)
   return time_vector ;

Overloading :vhdlcode:`real_vector`

.. code-block:: VHDL

   impure function RandRealV (Min, Max : real ; Size : natural) return real_vector ;
   impure function RandRealV (A : real_vector ; Size : natural) return real_vector ;
   impure function RandRealV
       (A : real_vector ; Unique : natural ; Size : natural) return real_vector ;
   impure function RandRealV
       (A, Exclude : real_vector ; Size : natural) return real_vector ;
   impure function RandRealV
       (A : real_vector; Exclude : real; Size : natural) return real_vector ;
   impure function RandRealV (A, Exclude : real_vector; Unique : natural;
       Size : natural) return real_vector ;
   impure function RandRealV (A : real_vector; Exclude : real; Unique : natural ;
       Size : natural) return real_vector ;

.. _UTILITY/RandomPkg/WeightedRandomization:

Weighted Randomization
**********************

A weighted distribution randomly generates each of a set of values a specified percentage of the time.
:vhdlcode:`RandomPType` provides a weighted distribution that specifies a value and its weight (:vhdlcode:`DistValInt`)
and one that only specifies weights (:vhdlcode:`DistInt`).

:vhdlcode:`DistValInt` is called with an array of value pairs. The first item in the pair is the value and the second is
the weight. The frequency that each value will occur is weight/(sum of weights). As a result, in the following call to
:vhdlcode:`DistValInt`, the likelihood of a 1 to occur is 7/10 times or 70%. The likelihood of 3 is 20% and 5 is 10%.

.. code-block:: VHDL

   variable RV : RandomPType ;
   . . .
   DataInt := RV.DistValInt(  ((1, 7), (3, 2), (5, 1)) ) ;

:vhdlcode:`DistInt` is a simplified version of :vhdlcode:`DistValInt`. The input to :vhdlcode:`DistInt` is an
:vhdlcode:`integer_vector` of weights. The return value is the index of the selected weight. For a literal value, it
will return a value from 0 to N-1 where N is the number of weights specified. As a result, the following call to
:vhdlcode:`DistInt` the likelihood of a 0 is 70%, 1 is 20% and 2 is 10%.

.. code-block:: VHDL

   variable RV : RandomPType ;
   . . .
   DataInt := RV.DistInt( (7, 2, 1) ) ;

Simple weighted distributions are overloaded to also support the following forms:

.. code-block:: VHDL

   impure function DistSlv ( Weight : integer_vector ; Size  : natural ) return
   std_logic_vector ;
   impure function DistUnsigned ( Weight : integer_vector ; Size  : natural ) return
   unsigned ;
   impure function DistSigned ( Weight : integer_vector ; Size  : natural ) return
   signed ;
   impure function DistBool ( Weight : NaturalVBoolType ) return boolean ;
   impure function DistSl ( Weight : NaturalVSlType ) return std_logic ;
   impure function DistBit ( Weight : NaturalVBitType ) return bit ;

Simple weighted distributions are overloaded to support exclude values.

.. code-block:: VHDL

   impure function DistInt ( Weight : integer_vector ;
            Exclude : integer_vector ) return integer ;
   impure function DistInt ( Weight : integer_vector ;
            Exclude : integer ) return integer ;
   impure function DistSlv ( Weight : integer_vector ;
            Exclude : integer_vector ; Size  : natural ) return std_logic_vector ;
   impure function DistSlv ( Weight : integer_vector ;
            Exclude : integer ; Size  : natural ) return std_logic_vector ;
   impure function DistUnsigned ( Weight : integer_vector ;
            Exclude : integer_vector ; Size  : natural ) return unsigned ;
   impure function DistUnsigned ( Weight : integer_vector ;
            Exclude : integer ; Size  : natural ) return unsigned ;
   impure function DistSigned ( Weight : integer_vector ;
            Exclude : integer_vector ; Size  : natural ) return signed ;
   impure function DistSigned ( Weight : integer_vector ;
            Exclude : integer ; Size  : natural ) return signed ;

.. _UTILITY/RandomPkg/RandomSaltDifferentSeedsForDifferentRunsOfATestCase:

RandomSalt: Different Seeds for Different Runs of a Test Case
*************************************************************

Sometimes we want to rerun a test with different seed values. With OSVVM, we can set a salt that is added to each call
to :vhdlcode:`InitSeed`.

The Salt is set with a call to :vhdlcode:`SetRandomSalt`. The example below uses a constant string value, but it would
be more appropriate to use a generic.

.. code-block:: VHDL

   SetRandomSalt ("2022.1031") ; -- Today's salt

:vhdlcode:`SetRandomSalt` supports either a string or an integer parameter:

.. code-block:: VHDL

   procedure SetRandomSalt (I : integer) ;
   procedure SetRandomSalt (S : string) ;
   impure function GetRandomSalt return integer ;

.. _UTILITY/RandomPkg/Usage:

Usage
*****

Each randomization result is produced by a function and that result can be used directly in an expression. Hence, we can
randomize a delay that is between 3 and 10 clocks.

.. code-block:: VHDL

   wait for RV.RandInt(3, 10) * tperiod_Clk - tpd ;
   wait until Clk = '1' ;

The values can also be used directly inside a case statement. The following example uses :vhdlcode:`DistInt` to generate
the first case target 70% of the time, the second 20%, and the third 10%.

.. code-block:: VHDL

   variable RV : RandomPType ;
   . . .
   StimGen : while TestActive loop     -- Repeat until done
     case RV.DistInt( (7, 2, 1) ) is
       when 0 =>  -- Normal Handling   -- 70%
          . . .
       when 1 =>  -- Error Case 1      -- 20%
          . . .
       when 2 =>  -- Error Case 2      -- 10%
          . . .
       when others =>
         report "DistInt" severity failure ;  -- Signal bug in DistInt
     end case ;
   end loop ;

The following code segment generates the transactions for writing to :vhdlcode:`DMA_WORD_COUNT`,
:vhdlcode:`DMA_ADDR_HI`, and :vhdlcode:`DMA_ADDR_LO` in a random order that is different every time this code segment is
run. The sequence finishes with a write to :vhdlcode:`DMA_CTRL`. When :vhdlcode:`DistInt` is called with a weight of 0,
the corresponding value does not get generated. Hence by initializing all of the weights to 1 and then setting it to 0
when it is selected, each case target only occurs once. The "for loop" loops three times to allow each transaction to be
selected.

.. code-block:: VHDL

   variable RV : RandomPType ;
   . . .
   Wt0 := 1;  Wt1 := 1;  Wt2 := 1;  -- Initial Weights

   for i in 1 to 3 loop             -- Loop 1x per transaction

     case RV.DistInt( (Wt0, Wt1, Wt2) ) is  -- Select transaction

       when 0 =>                    -- Transaction 0
         CpuWrite(CpuRec, DMA_WORD_COUNT, DmaWcIn);
         Wt0 := 0 ;                 -- remove from randomization

       when 1 =>                    -- Transaction 1
         CpuWrite(CpuRec, DMA_ADDR_HI, DmaAddrHiIn);
         Wt1 := 0 ;                 -- remove from randomization

       when 2 =>                    -- Transaction 2
         CpuWrite(CpuRec, DMA_ADDR_LO, DmaAddrLoIn);
         Wt2 := 0 ;                 -- remove from randomization

       when others =>   report "DistInt" severity failure ;

     end case ;
   end loop ;

   CpuWrite(CpuRec, DMA_CTRL, START_DMA or DmaCycle);

The following code segment uses an exclude list to keep from repeating the last value. Note when passing an integer
value to an :vhdlcode:`integer_vector` parameter, an aggregate using named association ":vhdlcode:`(0=> LastDataInt)`"
is used to denote a single element array. Note that during the first execution of this process, :vhdlcode:`LastDataInt`
has the value :vhdlcode:`integer'left` (a very small number), which is outside the range 0 to 255, and as a result, has
no impact on the randomization.

.. code-block:: VHDL

   RandomGenProc : process
     variable RV : RandomPType ;
     variable DataInt, LastDataInt : integer ;
   begin
     . . .
     DataInt := RV.RandInt(0, 255, (0 => LastDataInt)) ;

     LastDataInt := DataInt;
     . . .

The following code segment uses an exclude list to keep from repeating the four previous values.

.. code-block:: VHDL

   RandProc : process
     variable RV : RandomPType ;
     variable DataInt : integer ;
     variable Prev4DataInt : integer_vector(3 downto 0) := (others => integer'low) ;
   begin
     . . .
     DataInt := RV.RandInt(0, 100, Prev4DataInt) ;

     Prev4DataInt := Prev4DataInt(2 downto 0) & DataInt ;
     . . .

.. _UTILITY/RandomPkg/CreatingATest:

Creating a Test
***************

Creating tests is all about methodology. SynthWorks' methodology marries randomization subprograms (from
:vhdlcode:`RandomPkg`) and functional coverage subprograms (from :vhdlcode:`CoveragePkg` - also freely available at
http://www.synthworks.com/downloads) with VHDL programming constructs. Each test sequence is derived by randomly
selecting either branches of code or values for operations. Randomization constraints are created using normal
sequential coding techniques (such as nesting of case, if, loop, and assignment statements). This approach is simple yet
powerful. Since all of the code is sequential, randomized sequences are readily mixed with directed and algorithmic
sequences.

A simple demonstration of randomizing is the following test which uses heuristics (guesses) at length of bursts of data
and delays between bursts of data to randomize traffic being sent to a FIFO.

.. code-block:: VHDL

   variable RV : RandomPType ;
   . . .
   TxStimGen : while TestActive loop
     -- Burst between 1 and 10 values
     BurstLen := RV.RandInt(Min => 1, Max => 10);
     for i in 1 to BurstLen loop
       DataSent := DataSent + 1 ;
       WriteToFifo(DataSent) ;
     end loop ;
      --  Delay between bursts: (BurstLen <=3: 1-6, >3: 3-10)
     if BurstLen <= 3 then
       BurstDelay := RV.RandInt(1, 6) ;  -- small burst, small delay
     else
       BurstDelay := RV.RandInt(3, 10) ; -- bigger burst, bigger delay
     end if ;
     wait for BurstDelay * tperiod_Clk - tpd ;
     wait until Clk = '1' ;
   end loop TxStimGen ;

Functional coverage counts which test cases have been generated and give engineers an indication of when testing is
done. This is essential when using randomization to create a test as otherwise there is no way to know what the test
actually did. Functional coverage can be implemented using subprogram calls (either custom or from the
:vhdlcode:`CoveragePkg`) or VHDL code. Functional coverage is stored in signals and can be used to change the
randomization (either directly as a constraint or indirectly as something that contributes to changing a constraint) to
generate missing coverage items.

With a FIFO, we need to see lots of write attempts while full and read attempts while empty. One thing we can do to
improve the previous test is to increase or decrease the burst length and delay based on the number of write attempts
while full or read attempts while empty we have seen. To explore how to generate the coverage, see the
:ref:`CoveragePkg documentation <UTILITY/CoveragePkg>`.

For a design which has numerous conditions we need to generate, we can do coverage on the input stimulus and then
randomly select one of the uncovered conditions as the next transaction to be generated.

Solutions for the two previous coverage driven randomization problems are provided in SynthWorks' VHDL Testbenches and
Verification class.

.. _UTILITY/RandomPkg/RandomStability:

Random Stability
****************

A protected type is always used with a variable object. If the object is declared in a process, it is a regular
variable. If the object is declared in an architecture, then it is declared as a shared variable.

All of the examples in this document show :vhdlcode:`RandomPType` being defined in a process as a regular variable. This
is done to ensure random stability. Random stability is the ability to re-run a test and get the same sequence. Random
stability is required for verification since if we find a failure and then fix it, if the same sequence is not
generated, we will not know the fix worked.

Random stability is lost when a randomization variable is declared as a shared variable in an architecture and shared
among multiple processes. When a randomization variable is shared, the seed is shared. Each randomization reads and
updates the seed. If the processes accessing the shared variable run during the same delta cycle, then the randomization
of the test depends on the order of which :vhdlcode:`RandomPType` is accessed. This order can change anytime the design
is optimized - which will happen after fixing bugs. As a result, the test is unstable.

To ensure stability, create a separate variable for randomization in each process.

.. _UTILITY/RandomPkg/ReadingAndWritingSeedValues:

Reading and Writing Seed Values
*******************************

For a long test, it may be advantageous to read the seed periodically and print it out. If a failure or other
interesting condition is generated, the seed may be restored to a value that was recorded near the failure with the
intent of generating the error quickly to assist with debug.

The methods :vhdlcode:`GetSeed` and :vhdlcode:`SetSeed` are used to read and restore a seed value. The declarations for
these are shown below.

.. code-block:: VHDL

   impure function GetSeed return RandomSeedType ;
   procedure SetSeed (RandomSeedIn : RandomSeedType ) ;

The function :vhdlcode:`to_string` and procedures :vhdlcode:`write` and :vhdlcode:`read` are used to write and read
values of type :vhdlcode:`RandomSeedType`. The declarations for these subprograms are shown below. Note these are in
:file:`RandomBasePkg.vhd` and are separate from the protected type.

.. code-block:: VHDL

   function  to_string(A : RandomSeedType) return string ;
   procedure write(L: inout line ; A : RandomSeedType ) ;
   procedure read (L: inout line ; A : out RandomSeedType ; good : out boolean ) ;
   procedure read (L: inout line ; A : out RandomSeedType ) ;

.. _UTILITY/RandomPkg/OtherDistributions:

Other Distributions
*******************

By default, all randomizations use a uniform distribution. In addition to uniform distributions, :vhdlcode:`RandomPType`
also provides distributions for :vhdlcode:`FavorSmall`, :vhdlcode:`FavorBig`, normal, and poisson. The following is the
overloading for these functions.

.. code-block:: VHDL

   -- Generate values, each with an equal probability
   impure function Uniform (Min, Max : in real) return real ;
   impure function Uniform (Min, Max : integer) return integer ;
   impure function Uniform (Min, Max : integer ; Exclude: integer_vector) return
   integer ;

   -- Generate more small numbers than big
   impure function FavorSmall (Min, Max : real) return real ;
   impure function FavorSmall (Min, Max : integer) return integer ;
   impure function FavorSmall(Min, Max: integer; Exclude: integer_vector) return
   integer ;

   -- Generate more big numbers than small
   impure function FavorBig (Min, Max : real) return real ;
   impure function FavorBig (Min, Max : integer) return integer ;
   impure function FavorBig (Min, Max : integer ; Exclude: integer_vector) return
   integer ;

   -- Generate normal = gaussian distribution
   impure function Normal (Mean, StdDeviation : real) return real ;
   impure function Normal (Mean, StdDeviation, Min, Max : real) return real ;
   impure function Normal (
         Mean          : real ;
         StdDeviation  : real ;
         Min           : integer ;
         Max           : integer ;
         Exclude       : integer_vector := NULL_INTV
   ) return integer ;

   -- Generate poisson distribution
   impure function Poisson (Mean : real) return real ;
   impure function Poisson (Mean, Min, Max : real) return real ;
   impure function Poisson (
         Mean          : real ;
         Min           : integer ;
         Max           : integer ;
         Exclude       : integer_vector := NULL_INTV
   ) return integer ;

The package also provides experimental mechanisms for changing the distributions used with functions
:vhdlcode:`RandInt`, :vhdlcode:`RandSlv`, :vhdlcode:`RandUnsigned`, and :vhdlcode:`RandSigned`.

.. _UTILITY/RandomPkg/SortingIntegerVector:

Sorting integer_vector
**********************

The package :vhdlcode:`SortListPkg_int` provides :vhdlcode:`Sort` and :vhdlcode:`RevSort` functions for sorting type
:vhdlcode:`integer_vector`. The following example uses :vhdlcode:`RandIntV` and :vhdlcode:`Sort` to create a random set
of 10 integer values between 0 and 255 that increase in value and do not repeat.

.. code-block:: VHDL

   IntV := Sort(RV.RandIntV(0, 255, 10, 10)) ;

The overloading for :vhdlcode:`Sort` and :vhdlcode:`RevSort` are as follows.

.. code-block:: VHDL

   impure function Sort (A : integer_vector) return integer_vector;
   impure function RevSort (A : integer_vector) return integer_vector ;

.. _UTILITY/RandomPkg/CompilingAndUsingOSVVMUtilityLibrary:

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
