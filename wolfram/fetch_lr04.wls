#!/usr/bin/env wolframscript
(* ::Package:: *)

(* LR04 global benthic d18O stack (Lisiecki & Raymo 2005, Paleoceanography).
   A 5.3-Myr stack of 57 globally distributed benthic foraminiferal d18O
   records — the standard proxy for global ice volume / deep-ocean
   temperature, and the record that shows the Mid-Pleistocene Transition
   from a 41-kyr to a 100-kyr world.
   Source: NOAA WDS Paleo (Lisiecki contribution).
   Columns: Time (kyr BP) | benthic d18O (per mil) | std error.
   Higher d18O = colder / more ice. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "fetcher_common.wl"}]];

url     = "https://www.ncei.noaa.gov/pub/data/paleo/contributions_by_author/lisiecki2005/lisiecki2005.txt";
rawFile = FileNameJoin[{IceFetch`RawDir[], "lisiecki2005.txt"}];
outCsv  = FileNameJoin[{IceFetch`DataDir[], "lr04_benthic_5myr.csv"}];

IceFetch`Banner["LR04 benthic d18O stack (Lisiecki & Raymo 2005)"];
res = IceFetch`FetchText[url, rawFile, 168];
Print["  raw: ", res["savedTo"], "  (", res["bytes"], " B, cached=", res["cached"], ", ok=", res["ok"], ")"];
If[!res["ok"], Print["  ERROR: ", res["error"]]; Exit[1]];

text  = Import[rawFile, "Text"];
lines = StringSplit[text, {"\r\n", "\n", "\r"}];
numQ[s_] := StringMatchQ[StringTrim[s], NumberString];

rows = {};
Do[Module[{p = StringSplit[StringTrim[ln]]},
   (* data lines: time(0..5320 integer) d18O error — 3 numerics, col1 integer 0-6000 *)
   If[Length[p] == 3 && AllTrue[p, numQ] &&
      IntegerQ[ToExpression[p[[1]]]] && 0 <= ToExpression[p[[1]]] <= 6000,
     AppendTo[rows, ToExpression /@ p]]],
  {ln, lines}];
(* The file appends a second table (same time column) after the main stack;
   keep only the leading monotonically non-decreasing-age block. *)
rows = Module[{out = {rows[[1]]}, last = rows[[1, 1]]},
   Do[If[rows[[i, 1]] >= last, AppendTo[out, rows[[i]]]; last = rows[[i, 1]], Break[]], {i, 2, Length[rows]}];
   out];
rows = SortBy[rows, First];

Export[outCsv, Prepend[rows, {"age_kyr", "d18O_permil", "error_permil"}], "CSV"];
Print["  parsed: ", Length[rows], " rows"];
Print["  age span (kyr): ", {First@rows[[All,1]], Last@rows[[All,1]]}];
Print["  d18O range:     ", N@Round[MinMax@rows[[All,2]], 0.01]];
Print["  tidy: ", outCsv];
