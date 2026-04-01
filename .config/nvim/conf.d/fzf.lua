vim.cmd([[
command! -bang -nargs=? -complete=dir FzfFiles
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \ 'git grep --line-number -- '.fzf#shellescape(<q-args>),
  \ fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}),
  \ <bang>0)
]])
