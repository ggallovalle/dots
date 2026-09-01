; extends
; Keep spell checker off import/export lines in MDX.

((inline) @_inline
  (#lua-match? @_inline "^%s*import")) @nospell

((inline) @_inline
  (#lua-match? @_inline "^%s*export")) @nospell
