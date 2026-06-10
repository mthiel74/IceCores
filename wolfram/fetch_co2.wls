#!/usr/bin/env wolframscript
(* ::Package:: *)

(* Antarctic ice-core 800 kyr CO2 composite (Bereiter et al. 2015, GRL).
   Source: NOAA WDS Paleo study 17975.
   Columns (tab-separated, data lines have no #):
     age_gas_calBP   co2_ppm   co2_1s_ppm
   Age unit: gas-age calendar years before present (present = 1950 AD,
   AICC2012 chronology except Law Dome / WAIS / Siple Dome).
*)

Get[FileNameJoin[{DirectoryName[$InputFileName], "fetcher_common.wl"}]];

url     = "https://www.ncei.noaa.gov/pub/data/paleo/icecore/antarctica/antarctica2015co2composite.txt";
rawFile = FileNameJoin[{IceFetch`RawDir[], "antarctica2015co2composite.txt"}];
outCsv  = FileNameJoin[{IceFetch`DataDir[], "co2_composite_800k.csv"}];

IceFetch`Banner["CO2 composite 800 kyr (Bereiter et al. 2015)"];
res = IceFetch`FetchText[url, rawFile, 24];
Print["  raw: ", res["savedTo"], "  (", res["bytes"], " B, cached=", res["cached"], ", ok=", res["ok"], ")"];
If[!res["ok"], Print["  ERROR: ", res["error"]]; Exit[1]];

text  = Import[rawFile, "Text"];
lines = StringSplit[text, {"\r\n", "\n", "\r"}];

(* A data line is three numeric fields separated by whitespace. *)
numQ[s_] := StringMatchQ[StringTrim[s], NumberString];
rows = {};
Do[
  Module[{parts = StringSplit[StringTrim[ln]]},
    If[Length[parts] == 3 && AllTrue[parts, numQ],
      AppendTo[rows, ToExpression /@ parts]]],
  {ln, lines}];

rows = SortBy[rows, First];
csv  = Prepend[rows, {"age_yrBP", "co2_ppm", "co2_sigma_ppm"}];
Export[outCsv, csv, "CSV"];

Print["  parsed: ", Length[rows], " rows"];
Print["  age span (kyr BP): ", N@Round[{First@rows[[All,1]], Last@rows[[All,1]]}/1000, 0.1]];
Print["  CO2 range (ppm):   ", N@Round[MinMax@rows[[All,2]], 0.1]];
Print["  tidy: ", outCsv];
