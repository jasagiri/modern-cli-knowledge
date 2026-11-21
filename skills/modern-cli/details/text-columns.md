# Sort, count and cut lines of text: sort, uniq, cut, tr, awk, wc, head, tail, nl, comm, join, paste

## Intent

Order, deduplicate, count, slice and join lines and columns of text with the classic filters,
knowing what each one assumes about its input (sorted, one character delimiter, a locale) and where
the BSD (macOS) tools differ from GNU.

## Classic and modern

| classic | modern |
|---|---|
| `sort`, `uniq`, `cut`, `tr`, `awk`, `wc`, `head`, `tail`, `nl`, `comm`, `join`, `paste` | none (keep the classic tool) |

## Commands

All examples read a few lines made by `printf`, so the input is visible. `sort` compares bytes in
the locale of the example (`C.UTF-8`), where `10` comes before `9` and capital letters before
small ones. `-n` compares numbers, `-f` ignores case:

```sh
# spec: CLI-TEXT-01
printf '10\n9\n100\n' | sort
echo --
printf '10\n9\n100\n' | sort -n
echo --
printf 'b\nB\na\nA\n' | sort
echo --
printf 'b\nB\na\nA\n' | sort -f
```
```text
10
100
9
--
9
10
100
--
A
B
a
b
--
A
a
B
b
```

`-k2,2n` sorts by the second field only, as a number; `-t` sets the field separator. Lines whose
key is equal are then put in the order of the whole line, unless `-s` keeps the order of the input.
`-u` keeps one line of each run of equal lines (equal keys when `-k` is given):

```sh
# spec: CLI-TEXT-02
printf 'b 1\na 1\nc 0\n' | sort -k2,2n
echo --
printf 'b 1\na 1\nc 0\n' | sort -s -k2,2n
echo --
printf 'k:b\nk:a\n' | sort -t: -k2,2
echo --
printf 'b\na\nb\n' | sort -u
```
```text
c 0
a 1
b 1
--
c 0
b 1
a 1
--
k:a
k:b
--
a
b
```

`uniq` collapses only neighbouring equal lines, so it needs sorted input; `-c` prefixes the count
(BSD pads it to a width of 4), `-d` prints one line of each repeated run, `-u` only the lines that
occur once. The count of each distinct line, most frequent first, is `sort | uniq -c | sort -rn`.
`-rn` leaves the order of equal counts to the implementation; name the tie-break as a second key
(`sort -k1,1nr -k2,2`) when the order must be the same everywhere, for example for the top N words:

```sh
# spec: CLI-TEXT-03
printf 'b\na\nb\n' | uniq -c
echo --
printf 'b\na\nb\n' | sort | uniq -c
echo --
printf 'b\na\nb\n' | sort | uniq -c | sort -rn
echo --
printf 'b\na\nc\nb\nc\n' | sort | uniq -c | sort -k1,1nr -k2,2
echo --
printf 'a\na\nb\n' | uniq -d
printf 'a\na\nb\n' | uniq -u
```
```text
   1 b
   1 a
   1 b
--
   1 a
   2 b
--
   2 b
   1 a
--
   2 b
   2 c
   1 a
--
a
b
```

`cut -d, -f2,3` takes fields 2 and 3 split at a single character (the default is a tab). A line
without the delimiter is printed whole unless `-s` is given. Several adjacent spaces are several
delimiters, so the field between them is empty, where `awk` treats a run of blanks as one:

```sh
# spec: CLI-TEXT-04
printf 'a,b,c\n1,2,3\n' | cut -d, -f2,3
printf 'a,b\nc\n' | cut -d, -f2
echo --
printf 'a,b\nc\n' | cut -s -d, -f2
echo --
printf 'a  b\n' | cut -d' ' -f2
printf 'a  b\n' | awk '{print $2}'
```
```text
b,c
2,3
b
c
--
b
--

b
```

`cut -c` counts characters in the locale of the process (a UTF-8 locale: the character, `C`: one
byte, which breaks a multibyte character), and `-b` always counts bytes. `あ` is three bytes in
UTF-8, so `-b1-3` is the first character, and in the `C` locale `-c1` is only its first byte, `e3`,
followed by the newline `0a` (shown in hex by `od`):

```sh
# spec: CLI-TEXT-05
printf 'あい\n' | cut -c1
printf 'あい\n' | cut -b1-3
printf 'あい\n' | LC_ALL=C cut -c1 | od -An -tx1 | tr -d ' \n'; echo
```
```text
あ
あ
e30a
```

`tr` reads standard input only and works on single characters: `a-y b-z` maps a range onto a
range, `-d` deletes the characters of the set and `-s` squeezes each run of a character in the set
to one. It never takes a file name:

```sh
# spec: CLI-TEXT-06
printf 'hello\n' | tr a-y b-z
printf 'a1b2\n' | tr -d 0-9
printf 'a   b\n' | tr -s ' '
printf 'AbC\n' | tr '[:upper:]' '[:lower:]'
printf 'a b\n' | tr ' ' '\n'
```
```text
ifmmp
ab
a b
abc
a
b
```

`awk` splits each line into fields `$1`, `$2`, … at runs of blanks (`-F` sets another separator,
`-F,` for commas), `NF` is the number of fields and `END` runs after the last line, which is how
a column is summed:

```sh
# spec: CLI-TEXT-07
printf 'a 1\nb 2\nc 3\n' | awk '{s += $2} END {print s}'
printf 'a:b\n' | awk -F: '{print $2}'
printf 'x y z\n' | awk '{print $NF, NF}'
printf 'a,b\n' | awk -F, -v OFS=';' '{print $2, $1}'
```
```text
6
b
z 3
b;a
```

`wc -l` counts newline characters, so a last line without a newline is not counted. BSD `wc` pads
its numbers with spaces; reading from standard input still pads, and `tr -d ' '` removes it. `-c`
counts bytes and `-m` characters:

```sh
# spec: CLI-TEXT-08
printf 'a\nb' | wc -l
printf 'a\nb' | wc -l | tr -d ' '
printf 'あい\n' | wc -m | tr -d ' '
printf 'あい\n' | wc -c | tr -d ' '
```
```text
       1
1
3
7
```

`head -n N` and `tail -n N` take the first or last N lines, and `tail -n +K` starts at line K
(`+2` skips a header). A negative count for `head` (`head -n -1`, all but the last line) is GNU
only: BSD `head` fails with `illegal line count` and prints nothing:

```sh
# spec: CLI-TEXT-09
printf '1\n2\n3\n4\n' | head -n 2
printf '1\n2\n3\n4\n' | tail -n 2
printf '1\n2\n3\n4\n' | tail -n +3
```
```text
1
2
3
4
3
4
```

```sh
# spec: CLI-TEXT-09
# exit: 1
head -n -1 notes/todo.txt
```
```text
```

The portable way to print all but the last line is `sed '$d'`:

```sh
# spec: CLI-TEXT-18
sed '$d' notes/todo.txt
```
```text
TODO: buy milk
done: call Alice
```

`comm` and `join` read two files that are sorted by the same rule. `comm -12` prints the lines in
both files, `-23` those only in the first and `-13` those only in the second. `join` pairs lines by
the first field, and `-a1` keeps the lines of the first file that have no partner, `-v1` only those.
Input that is not sorted gives a wrong result without an error (here `join` loses the partner of
`b`):

```sh
# spec: CLI-TEXT-10
printf 'a\nb\nb\nc\n' > x; printf 'b\nc\nd\n' > y
comm -12 x y
comm -23 x y
comm -13 x y
echo --
printf '1 a\n2 b\n3 c\n' > p; printf '1 X\n3 Y\n' > q
join p q
join -a1 p q
join -v1 p q
echo --
printf 'b 1\na 2\n' > u; printf 'a X\nb Y\n' > v
join u v
```
```text
b
c
a
b
d
--
1 a X
3 c Y
1 a X
2 b
3 c Y
2 b
--
b 1 Y
```

`nl` numbers the lines: by default only the lines that are not empty (`-ba` numbers all of
them); an empty line is not numbered but still gets the separator. `paste` puts lines side by side with a tab, and `paste - -` takes two lines at a time from
standard input; `-d` sets the delimiter and `-s` puts one file on a single line:

```sh
# spec: CLI-TEXT-11 CLI-TEXT-12
printf 'a\n\nb\n' | nl -w1 -s:
printf 'a\n\nb\n' | nl -ba -w1 -s:
printf 'a\nb\nc\nd\n' | paste - -
printf 'a\nb\nc\n' | paste -s -d, -
```
```text
1:a
 :
2:b
1:a
2:
3:b
a	b
c	d
a,b,c
```

## Differences that change results

- **Sort order and the locale.** `sort` compares by the collation of the locale, so `10` precedes
  `9` without `-n`, and in `C`/`C.UTF-8` all capital letters precede small ones; in a locale such
  as `en_US.UTF-8` the order is different. Fix the locale (`LC_ALL=C sort`) when two machines must
  agree, and pass `-n` for numbers.
- **Ties and `-s`.** Without `-s`, lines with an equal key are ordered by the whole line (the
  "last resort" comparison), so `-k` alone does not keep the input order; `-s` does. `sort -u -k2`
  keeps one line per key, and which of the equal lines survives is not specified.
- **`uniq` needs sorted input.** It removes only adjacent duplicates, so `uniq` without `sort`
  looks as if it worked on data that happens to be grouped. `sort -u` removes duplicates in one
  step but cannot count; `sort | uniq -c` counts. BSD `uniq -c` pads the count to 4 columns, GNU to
  7.
- **`cut` is one character, not a pattern.** The delimiter is a single character, repeated
  spaces make empty fields, and a line without it is printed whole (`-s` drops it). For columns
  separated by runs of blanks use `awk`.
- **Bytes versus characters.** `cut -c` and `wc -m` follow the locale, `cut -b` and `wc -c` count
  bytes, so for text with Japanese characters they disagree. `awk`'s `length` counts bytes in the
  `awk` of macOS (`one-true-awk`, version 20200816) and characters in `gawk` in a UTF-8 locale;
  macOS `awk` printed `6` for `あい` here.
- **`tr` sets and files.** `tr` takes no file, only standard input, and its sets are lists of
  characters or ranges, not patterns; `tr -d` and `-s` act on the characters of the first set, and
  a class such as `[:upper:]` stands for a set of characters.
- **`awk` flavours.** macOS ships the one-true-awk; Linux usually has `gawk` or `mawk`. Fields,
  `-F`, `-v`, `NF`, `END` and `printf` are the same, but `gensub`, `asort`, `--version` and the
  character handling are `gawk` features, so a one-liner that uses them fails on macOS.
- **`wc` padding.** BSD `wc` pads its numbers with spaces even from standard input, GNU `wc` does
  not when reading standard input; `wc -l < file | tr -d ' '` is the same on both. `-l` counts
  newline characters, so an unterminated last line is not counted.
- **`head` and `tail`.** `tail -n +K` starts at line K on both. `head -n -K` (all but the last K
  lines) is a GNU extension; BSD `head` exits 1 with `illegal line count`.
  Portable: count the lines with `wc -l` and use `head -n` with the difference, or use `sed '$d'`.
- **`comm` and `join` need sorted input.** Both read two files in step and produce a wrong result
  without an error when a file is not sorted by the same key and locale (`join` has `--check-order`
  on GNU only). Sort both files with the same `LC_ALL`.
- **`nl` and `paste`.** `nl` numbers non-empty lines only (`-ba` for all lines), its width and
  separator default to a 6-column right-aligned number and a tab, `-w` and `-s` change them.
  `paste` joins lines with a tab; with `-s` one file per line, with several `-` operands one input
  line per operand.

## When to keep the classic command

- POSIX scripts, CI images and servers: these twelve tools are all there, which a modern
  replacement is not. Stay inside the POSIX options (`sort -n -k -t -u`, `uniq -c -d -u`,
  `cut -b -c -d -f`, `head -n`, `tail -n`, `tr -d -s`, `wc -l -w -c -m`); `sort -V`, `head -n -K`
  and `sort -h` are not portable.
- JSON or YAML: do not slice them with `cut` or `awk`; use `jq` (`json.md`) or `yq`
  (`yaml.md`), which read the structure.
- Searching for a pattern in files: use `rg` (`search-text.md`) rather than `awk '/re/'` or
  `grep | cut`, which have to be told about ignored files, hidden files and recursion.
- Counting the files or lines of a tree: `fd` and `dust` (`find-files.md`, `disk-usage.md`) know
  which files to skip; `wc -l *` counts everything it is given.
- CSV with quoted fields that contain the delimiter: neither `cut` nor `awk -F,` can read it; use a
  CSV-aware tool.

## Pitfalls

`sort | uniq -c` is right, but `uniq -c` alone counts only neighbouring lines and silently reports
`1` for repeats that are apart, so the numbers look plausible and are wrong:

```sh bad
printf 'b\na\nb\n' | uniq -c
```
```sh
# spec: CLI-TEXT-03
printf 'b\na\nb\n' | sort | uniq -c
```
```text
   1 a
   2 b
```

## Sources

None in the catalog: to be cited by the lead.
