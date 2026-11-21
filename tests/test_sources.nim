## E tests for docs/specification.md MCLI-SRC-01 and MCLI-SRC-02 (ADR-MCLI-0004): every source the
## repository lists is under a licence that allows commercial use.

import std/[json, os, sets, unittest]
import free_books_catalog/licences

const root = currentSourcePath().parentDir.parentDir

proc catalogLines(): seq[JsonNode] =
  for line in lines(root / "catalog" / "sources.jsonl"):
    if line.len > 0: result.add parseJson(line)

suite "sources":
  # SPEC: MCLI-SRC-01
  test "MCLI-SRC-01 Given the catalog, when each source is read, then it states licences and every one allows commercial use":
    let allowed = commercialLicenses.toHashSet
    let sources = catalogLines()
    check sources.len > 0
    for s in sources:
      let lic = s{"licenses"}
      checkpoint s["id"].getStr & " " & s["url"].getStr
      check lic != nil and lic.len > 0
      if lic != nil:
        for l in lic:
          check l.getStr in allowed

  # SPEC: MCLI-SRC-02
  test "MCLI-SRC-02 Given the catalog config, when read, then free-programming-books and Hillside are off, commercialOnly is on and the catalog holds the listed sources only":
    let c = parseJson(readFile(root / "catalog" / "config.json"))
    check not c["fpb"].getBool
    check not c["hillside"].getBool
    check c["commercialOnly"].getBool
    var listed = initHashSet[string]()
    for x in c["listed"]: listed.incl x["url"].getStr
    var inCatalog = initHashSet[string]()
    for s in catalogLines(): inCatalog.incl s["url"].getStr
    check inCatalog == listed
