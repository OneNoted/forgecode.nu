export def split-porcelain-line [line: string] {
  $line
  | parse --regex '(?P<c1>\S.*?)(?:\s{2,}(?P<c2>\S.*?))?(?:\s{2,}(?P<c3>\S.*?))?(?:\s{2,}(?P<c4>\S.*?))?(?:\s{2,}(?P<c5>\S.*?))?(?:\s{2,}(?P<c6>\S.*?))?(?:\s{2,}(?P<c7>\S.*?))?$'
  | first
  | default {}
  | values
  | where {|value| $value != null }
  | each {|value| $value | str trim }
}

export def parse-porcelain [text: string] {
  let lines = ($text | lines)
  if ($lines | is-empty) { return [] }

  let header = (split-porcelain-line ($lines | first))
  let body = ($lines | skip 1)

  $body | each {|line|
    let columns = (split-porcelain-line $line)
    mut row = {}
    for idx in (0..(($header | length) - 1)) {
      let key = ($header | get $idx | str downcase | str replace -a ' ' '_' | str replace -a '-' '_')
      let value = ($columns | get -o $idx)
      $row = ($row | upsert $key $value)
    }
    $row
  }
}
