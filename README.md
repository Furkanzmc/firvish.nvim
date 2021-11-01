# firvish.nvim

This plug-in is heavily inspired by [vim-dirvish](https://github.com/justinmk/vim-dirvish).

firvish.nvim is a buffer centric job control plug-in. It provides mappings for handling buffer
list, history, NeoVim and external commands. All the output of these commands are streamed to a
dedicated buffer.

The main goal of firvish.nvim is to provide a single way of interacting with external commands, and
internal commands of NeoVim through the use of buffers.
They are used to interact with the output of commands, and the input is sent to external commands
to interactively communicate with them.

See the documentation for more details.

# Installation

Install using your favoriate plugin manager. There's no required dependancies. Optionally, you can
install [option.nvim](https://github.com/furkanzmc/options.nvim) for customization. If it's not
installed, you'll see a warning but you can ignore it.

# Example Use Cases

## Use as an asynchronous git command

```vim
lua << EOF
function _G.run_git(args, is_background_job)
    local cmd = fn.split(args, " ");
    table.insert(cmd, 1, "git")
    require "firvish.job_control".start_job({
        cmd = cmd,
        filetype = "job-output",
        title = "Git",
        is_background_job = is_background_job,
        cwd = vim.fn.FugitiveGitDir(),
        listed = true
    })
end
EOF

command! -bang -complete=customlist,fugitive#Complete -nargs=* -range FGit :lua _G.run_git(<q-args>, <q-bang> ~= '!')
```

## Set up a CMake build system

```lua
function G.setup_cmake(opts)
    if vim.o.loadplugins == false then return end

    opts.env = opts.env or {}

    assert(opts.env, "env is required.")
    assert(opts.name, "name is required.")
    assert(opts.program, "program is required.")
    assert(opts.cwd, "cwd is required.")
    assert(opts.project_path, "project_path is required.")
    assert(opts.build_dir, "build_dir is required.")

    opts.test_cwd = opts.test_cwd or ""

    require"dap".configurations.cpp = {
        {
            type = "cpp",
            request = "launch",
            name = opts.name,
            program = opts.program,
            symbolSearchPath = opts.cwd,
            cwd = opts.cwd,
            debuggerRoot = opts.cwd,
            env = opts.env
        }
    }

    local functions = {}
    functions.build_project = function(output_qf)
        require"firvish.job_control".start_job({
            cmd = {"cmake", "--build", opts.build_dir, "--parallel"},
            filetype = "log",
            title = "Build",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.project_path
        })
    end

    functions.run_tests = function(output_qf)
        require"firvish.job_control".start_job({
            cmd = {"ctest", "--output-on-failure"},
            filetype = "log",
            title = "Tests",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.test_cwd
        })
    end

    local configure_opts = {"cmake", "-DCMAKE_BUILD_TYPE=Debug", opts.project_path}
    if opts.generator ~= nil then
        table.insert(configure_opts, "-G")
        table.insert(configure_opts, opts.generator)
    end

    functions.run_cmake = function(output_qf, cmake_options)
        local cmd = configure_opts
        if cmake_options ~= nil then table.extend(cmd, cmake_options) end

        require"firvish.job_control".start_job({
            cmd = cmd,
            filetype = "log",
            title = "CMake",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.build_dir
        })
    end

    functions.run_project = function(output_qf, args)
        local cmd = {opts.program}
        if args ~= nil then table.extend(cmd, args) end

        require"firvish.job_control".start_job({
            cmd = cmd,
            filetype = "log",
            title = "Run",
            listed = true,
            output_qf = output_qf,
            is_background_job = true,
            cwd = opts.cwd
        })
    end

    _G.cmake_functions = functions

    cmd [[command! -bang CMake :lua _G.cmake_functions.run_cmake("<bang>" ~= "!")]]
    cmd [[command! -bang Run :lua _G.cmake_functions.run_project("<bang>" ~= "!")]]
    cmd [[command! -bang Build :lua _G.cmake_functions.build_project("<bang>" ~= "!")]]
    cmd [[command! -bang RunTests :lua _G.cmake_functions.run_tests("<bang>" ~= "!")]]
end

-- In .nvimrc file
_G.setup_cmake({
    env = {},
    name = "CMake Project",
    program = vim.fn.expand("$PROJECT_BUILD_DIR"),
    cwd = vim.fn.expand("$PROJECT_BUILD_DIR"),
    project_path = vim.fn.expand("%:p:h"),
    build_dir = vim.fn.expand("$PROJECT_BUILD_DIR"),
    test_cwd = vim.fn.expand("$PROJECT_BUILD_DIR") .. "/test/",
    generator = "Ninja"
})
```

Now you can run any of the following commands:

- `:CMake`
- `:Build`
- `:RunTests`
- `:Run`

The output of each command will be redirected to the quickfix list.

## Run the server for a Django project

```vim
command! RunServer :lua require"firvish.job_control".start_job({
            \ cmd={"python", "manage.py", "runserver"},
            \ filetype="firvish-job",
            \ is_background_job=true, " So that we only see the job out put in :FirvishJobs window.
            \ listed=false,
            \ cwd="/path/to/project",
            \ title="Server"})
```
