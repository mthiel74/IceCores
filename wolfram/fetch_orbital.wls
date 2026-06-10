#!/usr/bin/env wolframscript
(* ::Package:: *)

(* Laskar et al. (2004) La2004 orbital solution for the Earth.
   Source: IMCCE (vo.imcce.fr), file INSOLN.LA2004.BTL.ASC
   Columns (whitespace separated, Fortran D-exponent notation):
     time (kyr; 0 = J2000, negative = past)
     eccentricity (dimensionless)
     obliquity (radians)
     longitude of perihelion from moving equinox (radians)
   We keep the most recent 800 kyr (0 .. -800), convert obliquity and
   perihelion to degrees, and store the classical precession parameter
   e*sin(perihelion). These are the orbital "pacemakers" of the ice ages:
   ~100 kyr eccentricity, ~41 kyr obliquity, ~19-23 kyr precession.
*)

Get[FileNameJoin[{DirectoryName[$InputFileName], "fetcher_common.wl"}]];

url     = "https://vo.imcce.fr/insola/earth/online/earth/La2004/INSOLN.LA2004.BTL.ASC";
rawFile = FileNameJoin[{IceFetch`RawDir[], "INSOLN.LA2004.BTL.ASC"}];
outCsv  = FileNameJoin[{IceFetch`DataDir[], "orbital_la2004_800k.csv"}];

IceFetch`Banner["Orbital solution La2004 (Laskar et al. 2004)"];
res = IceFetch`FetchText[url, rawFile, 168];
Print["  raw: ", res["savedTo"], "  (", res["bytes"], " B, cached=", res["cached"], ", ok=", res["ok"], ")"];
If[!res["ok"], Print["  ERROR: ", res["error"]]; Exit[1]];

text  = Import[rawFile, "Text"];
lines = Select[StringSplit[text, {"\r\n", "\n", "\r"}], StringTrim[#] =!= "" &];

(* Fortran "0.123D-01" -> machine number *)
parseD[s_] := ToExpression@StringReplace[StringTrim[s], {"D" -> "*^", "d" -> "*^"}];

rows = {};
Do[
  Module[{p = StringSplit[StringTrim[ln]]},
    If[Length[p] >= 4,
      AppendTo[rows, parseD /@ p[[1 ;; 4]]]]],
  {ln, lines}];

(* time in kyr; keep 0 .. -800 inclusive, store positive age in kyr BP *)
rows = Select[rows, -800 <= #[[1]] <= 0 &];
rows = SortBy[rows, First];          (* -800 .. 0 *)
out = Table[
  With[{t = r[[1]], ecc = r[[2]], obl = r[[3]], peri = r[[4]]},
    {-t,                              (* age kyr BP (positive) *)
     ecc,
     obl/Degree,                      (* obliquity deg *)
     Mod[peri/Degree, 360],           (* perihelion deg *)
     ecc*Sin[peri]}],                 (* climatic precession parameter *)
  {r, rows}];
out = SortBy[out, First];             (* age 0 .. 800 kyr BP *)

csv = Prepend[out,
  {"age_kyrBP", "eccentricity", "obliquity_deg", "perihelion_deg", "precession_esinw"}];
Export[outCsv, csv, "CSV"];

Print["  parsed: ", Length[out], " rows (1 kyr steps)"];
Print["  ecc range:       ", N@Round[MinMax@out[[All,2]], 0.001]];
Print["  obliquity range: ", N@Round[MinMax@out[[All,3]], 0.01], " deg"];
Print["  tidy: ", outCsv];
