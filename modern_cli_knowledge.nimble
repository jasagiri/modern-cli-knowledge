# Package
version       = "0.1.0"
author        = "jasagiri"
description   = "Modern Unix command-line tools (rg, fd, sd, bat, eza, jq, yq, ...) as tested agent skills and a training dataset, with when to keep the classic command"
license       = "Apache-2.0"
srcDir        = "src"
installExt    = @["nim"]

# Dependencies
requires "nim >= 2.4.2"

task test, "Run the test suite":
  exec "nim test"
