# firvish.nvim

This plug-in is heavily inspired by [vim-dirvish](https://github.com/justinmk/vim-dirvish).
It tries to use buffers, as opposed to terminal, to do job control and show open buffers and history.
It doesn't really rely on Lua, but I wanted to practice Lua and NeoVim plug-in development so I started
with Lua, so sadly, it only works on NeoVim.

# TODO

- [ ] Add support for listing and stopping running jobs.
    List them in a preview window, and use the same shortcuts in buffers to review the current output.
- [ ] Ability to run background jobs that exposes the output on-demand.
    + Maybe using the preview window.
