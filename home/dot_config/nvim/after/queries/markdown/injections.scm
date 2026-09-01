; extends
; MDX: override default markdown_inline/html injections for JS/TS/JSX regions.
; Gated with #mdx? so regular markdown is not injected as TSX.

((inline) @injection.content
  (#mdx? @injection.content)
  (#lua-match? @injection.content "^%s*import")
  (#set! injection.language "typescript")
  (#set! injection.priority 100))

((inline) @injection.content
  (#mdx? @injection.content)
  (#lua-match? @injection.content "^%s*export")
  (#set! injection.language "typescript")
  (#set! injection.priority 100))

; Inline JSX, e.g. `# Hello <Thing />`
((inline) @injection.content
  (#mdx? @injection.content)
  (#lua-match? @injection.content "^%s*<[A-Z!/]")
  (#set! injection.language "tsx")
  (#set! injection.priority 100))

; Block JSX is parsed as html_block, not inline
((html_block) @injection.content
  (#mdx? @injection.content)
  (#lua-match? @injection.content "<[A-Z!/]")
  (#set! injection.language "tsx")
  (#set! injection.combined)
  (#set! injection.include-children)
  (#set! injection.priority 100))
