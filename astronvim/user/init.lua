return {
  lsp = {
    servers = {
      "mypy"
    },
    config = {
      mypy = function()
        local python_executable = io.popen('which python'):read('*line')
        return {
          cmd = {
            "mypy",
            "--python-executable", python_executable
          }
        }
      end
    }
  }
}
