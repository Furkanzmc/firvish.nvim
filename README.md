# firvish.nvim

This plug-in is heavily inspired by [vim-dirvish](https://github.com/justinmk/vim-dirvish).
It tries to use buffers, as opposed to terminal, to do job control and show open buffers and history.
It doesn't really rely on Lua, but I wanted to practice Lua and NeoVim plug-in development so I started
with Lua, so sadly, it only works on NeoVim.

# TODO

- [ ] Add the ability to stop jobs.
- [ ] Add the ability to remove jobs from history.
- [ ] Add support to add the output of a job to the quickfix or locallist.
- [ ] Fix the problem where the buffer lines are not updated when the focus is lost.
