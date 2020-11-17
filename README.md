# firvish.nvim

This plug-in is heavily inspired by [vim-dirvish](https://github.com/justinmk/vim-dirvish).

firvish.nvim is a buffer centric job control plug-in. It provides mappings
for handling buffer list, history, NeoVim and external commands. All the
output of these commands are streamed to a dedicated buffer.

The main goal of firvish.nvim is to provide a single way of interacting with
external commands, and internal commands of NeoVim: Buffers. They are used
to interact with the output of commands, and the input is sent to external
commands to interactively communicate with them.

See the documentation for more details.

## Example Use Cases

### Use `:Buffers`

[![asciicast](https://asciinema.org/a/6QM9VIN9LzJieCt4BQTDgSKRX.svg)](https://asciinema.org/a/6QM9VIN9LzJieCt4BQTDgSKRX)

### Use `:Fhdo`

[![asciicast](https://asciinema.org/a/GAiUnzS9YGcBGM4UEyrvPsgmo.svg)](https://asciinema.org/a/GAiUnzS9YGcBGM4UEyrvPsgmo)

# TODO

- [ ] Improve the `I` mapping.
- [ ] Add support to add the output of a job to the quickfix or locallist.
- [ ] Fix the problem where the buffer lines are not updated when the focus is lost.
