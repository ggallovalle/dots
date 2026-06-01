# shellcheck shell=sh

Describe 'homepath'
  Example 'defaults to shortened output'
    When run zsh functions/homepath /home/kbroom/dots/src
    The status should eq 0
    The output should eq '$HOME/dots/src'
  End

  Example 'format typ keeps shortened label'
    When run zsh functions/homepath --format typ /home/kbroom/dots/src
    The status should eq 0
    The output should eq 'link("$HOME/dots/src")[$HOME/dots/src]'
  End

  Example 'full forces absolute output'
    When run zsh functions/homepath -f --format typ /home/kbroom/dots/src
    The status should eq 0
    The output should eq 'link("/home/kbroom/dots/src")[/home/kbroom/dots/src]'
  End

  Example 'clustered short flags are additive'
    When run zsh functions/homepath -cfu --format typ /home/kbroom/dots/toml-lang/toml-test
    The status should eq 0
    The output should eq 'link("file:///home/kbroom/dots/toml-lang/toml-test")[/home/kbroom/dots/toml-lang/toml-test]'
  End

  Example 'multiple paths preserve order'
    When run zsh functions/homepath -u /home/kbroom/dots/src/SchemaAST.ts /home/kbroom/dots/src/Schema.ts
    The status should eq 0
    The output should eq 'file://$HOME/dots/src/SchemaAST.ts
file://$HOME/dots/src/Schema.ts'
  End
End
