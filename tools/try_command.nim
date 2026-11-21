## try_command '<shell command>'
##
## Runs one command the way the tests run an example (MCLI-EX-01): in a fresh copy of
## fixtures/tree under the fixed environment. Prints standard output exactly, then standard
## error and the status on standard error. Standard input is /dev/null. For writing pages: paste the output into the
## ```text block only after checking that it is what the command should print.
## Exit 0 when the command ran, 2 on a usage error.

import std/os
import shell_pages/runner

proc main() =
  if paramCount() != 1:
    stderr.writeLine "usage: try_command '<shell command>'"
    quit 2
  let root = getAppDir().parentDir
  let fixture = (if dirExists(root / "fixtures" / "tree"): root / "fixtures" / "tree"
                 else: getCurrentDir() / "fixtures" / "tree")
  let work = getTempDir() / "mcli-try-" & $getCurrentProcessId()
  copyFixture(fixture, work)
  let r = run(work, paramStr(1))
  stdout.write r.stdout
  stderr.writeLine "--- stderr"
  stderr.write r.stderr
  stderr.writeLine "--- exit " & $r.exitCode
  removeDir(work)

main()
