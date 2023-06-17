-- vscodeで利用すると黒い点が表示されるので、vscodeの場合は読み込まない
if not vim.g.vscode then 
    require("scrollbar").setup()
end