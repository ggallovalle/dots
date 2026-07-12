require("kbinit").setup()
-- Im gerson, or am I
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  pattern = "*",
  callback = function()
    if vim.fn.getline(1):match("^#!.*uv%s+run%s+--script") then
      vim.bo.filetype = "python"
    end
  end,
})
