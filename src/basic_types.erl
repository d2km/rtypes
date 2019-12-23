-module(basic_types).

%% Define types for testing which can not be (?) expressed in Elixir
-export_type([type_band/0,
             type_bor/0,
             type_bxor/0,
             type_bsl/0,
             type_bsr/0,
             type_div/0,
             type_rem/0,
             type_plus/0,
             type_minus/0,
             type_mult/0,
             type_bnot/0,
             type_uplus/0,
             type_uminus/0]).

-type type_band() :: 1 band 2.
-type type_bor() :: 1 bor 2.
-type type_bxor() :: 1 bxor 2.
-type type_bsl() :: 1 bsl 2.
-type type_bsr() :: 1 bsr 2.
-type type_div() :: 2 div 1.
-type type_rem() :: 2 rem 1.
-type type_plus() :: 1 + 2.
-type type_minus() :: 1 - 2.
-type type_mult() :: 1 * 2.
-type type_bnot() :: bnot 1.
-type type_uplus() :: +1.
-type type_uminus() :: -1.
