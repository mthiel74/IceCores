(* ::Package:: *)

(* Shared helpers for the Wolfram-Language live-data fetchers.
   Pure Wolfram Language — no Python anywhere in the project.
   Pattern adapted from the ENSO-emergence project (ENSOFetch`).
*)

BeginPackage["IceFetch`"];

RepoRoot::usage   = "RepoRoot[] returns the absolute path of the repo root.";
DataDir::usage    = "DataDir[] / RawDir[] absolute paths.";
RawDir::usage     = "DataDir[] / RawDir[] absolute paths.";
Banner::usage     = "Banner[msg] prints a section banner.";
FetchText::usage  = "FetchText[url, dest, maxAgeHours] downloads URL as text, with caching.";
FetchBytes::usage = "FetchBytes[url, dest, maxAgeHours] downloads URL as bytes, with caching.";

Begin["`Private`"];

RepoRoot[] := ParentDirectory @ DirectoryName[$InputFileName];
DataDir[]  := FileNameJoin[{RepoRoot[], "data"}];
RawDir[]   := FileNameJoin[{DataDir[], "raw"}];

ensureDir[p_] := If[! DirectoryQ[p],
   CreateDirectory[p, CreateIntermediateDirectories -> True]];

ensureDir[DataDir[]]; ensureDir[RawDir[]];

Banner[msg_] := Print["\n=== ", msg, " ==="];

fileAgeHours[path_] := If[FileExistsQ[path],
   QuantityMagnitude @ DateDifference[
     FileDate[path, "Modification"], Now, "Hour"], Infinity];

fetchWith[url_, dest_, mode_, maxAgeHours_] := Module[
   {age, resp, status, body},
   ensureDir[DirectoryName[dest]];
   age = fileAgeHours[dest];
   If[NumericQ[maxAgeHours] && age < maxAgeHours && FileExistsQ[dest],
     Return[<|"ok" -> True, "url" -> url, "savedTo" -> dest,
        "bytes" -> FileByteCount[dest], "cached" -> True, "error" -> ""|>]];
   (* La2004 lives behind a 302 redirect — follow it. *)
   resp = Quiet @ URLRead @ HTTPRequest[url, <|"FollowRedirects" -> True|>];
   If[FailureQ[resp],
     Return[<|"ok" -> False, "url" -> url, "savedTo" -> dest, "bytes" -> 0,
        "cached" -> False, "error" -> ToString[resp]|>]];
   status = resp["StatusCode"];
   If[!IntegerQ[status] || status < 200 || status >= 300,
     Return[<|"ok" -> False, "url" -> url, "savedTo" -> dest, "bytes" -> 0,
        "cached" -> False, "error" -> "HTTP " <> ToString[status]|>]];
   body = Switch[mode, "Text", resp["Body"], "Bytes", resp["BodyBytes"]];
   If[mode === "Text",
     Export[dest, body, "Text"],
     BinaryWrite[dest, body]; Close[dest]];
   <|"ok" -> True, "url" -> url, "savedTo" -> dest,
     "bytes" -> FileByteCount[dest], "cached" -> False, "error" -> ""|>];

FetchText[url_, dest_, maxAge_:6]  := fetchWith[url, dest, "Text", maxAge];
FetchBytes[url_, dest_, maxAge_:6] := fetchWith[url, dest, "Bytes", maxAge];

End[];
EndPackage[];
