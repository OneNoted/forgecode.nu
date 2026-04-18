export def fail [message: string] {
  error make { msg: $message }
}

export def assert-true [value: bool, message: string] {
  if not $value { fail $message }
}

export def assert-eq [actual, expected, message: string] {
  if $actual != $expected {
    fail $'($message)\nexpected: ($expected | to nuon)\nactual:   ($actual | to nuon)'
  }
}

export def assert-contains [value: string, needle: string, message: string] {
  if not ($value | str contains $needle) {
    fail $'($message)\nvalue: ($value)'
  }
}

export def read-log [] {
  if not ($env.FORGE_STUB_LOG | path exists) {
    return []
  }
  open $env.FORGE_STUB_LOG | lines | each {|line| $line | from json }
}

export def clear-stub [] {
  ^python3 tests/stub-forge.py --reset | ignore
}

