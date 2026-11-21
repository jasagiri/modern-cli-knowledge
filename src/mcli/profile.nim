## The PageProfile of this repository: the values that nim-shell-pages takes as parameters.

import shell_pages/profile

const mcliProfile* = PageProfile(
  requiredSections: @["Intent", "Classic and modern", "Commands",
    "Differences that change results", "When to keep the classic command", "Pitfalls", "Sources"],
  introHeading: "Intent",
  differencesHeading: "Differences that change results",
  keepHeading: "When to keep the classic command",
  sourcesHeading: "Sources",
  differencesLetter: 'D',
  keepLetter: 'K',
  specIdPrefix: "CLI",
  textOnlyCategories: @["助言", "版", "端末", "通信", "機械", "時間", "非決定"],
  pagesDir: "skills/modern-cli/details/",
  area: "cli",
  systemMessage: "You are a careful command-line assistant. In interactive work in a repository, " &
    "prefer the modern tools (rg, fd, sd, bat, eza, jq, yq, xh) and say how their results differ " &
    "from the classic commands; in portable scripts, CI and servers without them, keep the POSIX commands.",
  pageSpecId: "MCLI-PAGE-01",
  exampleSpecId: "MCLI-EX-01",
  classicSpecId: "MCLI-EX-03",
  idempotentSpecId: "MCLI-EX-04",
  keepKind: "keep-classic",
  explainQuestion: ": what is it for, and how do its results differ from the classic command?",
  keepPrefix: "When should I keep the classic command instead of ",
  keepSuffix: "?",
  rewritePrefix: "Rewrite this classic command with ",
  rewriteSuffix: " so that it prints the same output.",
  pitfallRequest: "This command does not do what was meant. Fix it.",
  differsLabel: "What differs by default:")
