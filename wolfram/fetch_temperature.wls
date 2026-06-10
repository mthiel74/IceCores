#!/usr/bin/env wolframscript
(* ::Package:: *)

(* EPICA Dome C deuterium temperature reconstruction (Jouzel et al. 2007,
   Science) on the EDC3 age scale.
   Source: NOAA WDS Paleo, epica_domec/edc3deuttemp2007.txt
   Columns (whitespace-separated):
     Bag | ztop (m) | EDC3 age (yr before 1950) | dD (per mille) | dT (C)
   The temperature estimate dT is the Antarctic temperature anomaly
   relative to the mean of the last 1000 years, derived from deuterium
   (NOT delta-18-O), corrected for sea-water isotopic composition
   (Bintanja et al. 2005) and ice-sheet elevation (Parrenin et al. 2007).
   Top rows have only depth/age (no isotope yet) -> keep 5-column rows.
*)

Get[FileNameJoin[{DirectoryName[$InputFileName], "fetcher_common.wl"}]];

url     = "https://www.ncei.noaa.gov/pub/data/paleo/icecore/antarctica/epica_domec/edc3deuttemp2007.txt";
rawFile = FileNameJoin[{IceFetch`RawDir[], "edc3deuttemp2007.txt"}];
outCsv  = FileNameJoin[{IceFetch`DataDir[], "edc_temperature_800k.csv"}];

IceFetch`Banner["EPICA Dome C deuterium temperature (Jouzel et al. 2007)"];
res = IceFetch`FetchText[url, rawFile, 24];
Print["  raw: ", res["savedTo"], "  (", res["bytes"], " B, cached=", res["cached"], ", ok=", res["ok"], ")"];
If[!res["ok"], Print["  ERROR: ", res["error"]]; Exit[1]];

text  = Import[rawFile, "Text"];
lines = StringSplit[text, {"\r\n", "\n", "\r"}];

numQ[s_] := StringMatchQ[StringTrim[s], NumberString];
rows = {};
Do[
  Module[{parts = StringSplit[StringTrim[ln]]},
    (* full data rows: bag(int) ztop age dD dT  — all 5 numeric *)
    If[Length[parts] == 5 && AllTrue[parts, numQ],
      AppendTo[rows, ToExpression /@ parts]]],
  {ln, lines}];

(* keep age, depth, deuterium, temperature; drop bag index *)
rows = ({#[[3]], #[[2]], #[[4]], #[[5]]}) & /@ rows;
rows = SortBy[rows, First];
csv  = Prepend[rows, {"age_yrBP", "depth_m", "deuterium_permille", "temp_anomaly_C"}];
Export[outCsv, csv, "CSV"];

Print["  parsed: ", Length[rows], " rows"];
Print["  age span (kyr BP): ", N@Round[{First@rows[[All,1]], Last@rows[[All,1]]}/1000, 0.1]];
Print["  dT range (C):      ", N@Round[MinMax@rows[[All,4]], 0.1]];
Print["  tidy: ", outCsv];
