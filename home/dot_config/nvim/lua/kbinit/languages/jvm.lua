return {
  lsp = {
    kotlin_lsp = {
      filetypes = { "kotlin" },
      root_markers = { ".git", "build.gradle", "build.gradle.kts", "pom.xml", "settings.gradle", "settings.gradle.kts" },
    },
    jdtls = {
      filetypes = { "java" },
      root_markers = { ".git", "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts" },
    },
  },
  mason = { "kotlin_lsp", "jdtls" },
  treesitter = { "java", "kotlin" },
}
