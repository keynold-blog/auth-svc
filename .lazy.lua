vim.env.PGHOST = "localhost"
return {
  {
    "folke/lazy.nvim",
    opts = {
      spec = {
        {
          import = "lazyvim.plugins.extras.lang.ruby",
        }
      },
    }
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rubocop = { mason = false, },
        ruby_lsp = { mason = false, },
        codebook = { enabled = false },
        harper_ls = {enabled = false },
      }
    }
  },
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>ff", function()
        require("snacks").picker.files({
          exclude = {
            "tmp",
            "bin",
            "jest",
            "types",
            "coverage",
            "node_modules",
            ".cache",
            ".devenv",
            "gengo",
            -- "public",
            "static-font-icomoon",
          },
        })
      end, desc = "Find Files (Root Dir)" },
      { "<leader>fw", function()
        require("snacks").picker.grep({
          regex = false,
          args = {
            "--glob=!coverage/**",
            "--glob=!node_modules/**",
            "--glob=!dist/**",
            "--glob=!build/**",
            "--glob=!gengo/**",
            "--glob=!types/**",
            "--glob=!.cache/**",
            "--glob=!.slicemachine/**",
            "--glob=!__tests__/**",
            "--glob=!__mocks__/**",
            "--glob=!static-font-icomoon/**",
            "--glob=!customtypes/**",
            "--glob=!public/**",
            "--glob=!public/**",
            "--glob=!pnpm-lock.yaml",
          },
        })
      end, desc = "Find Files (Root Dir)" },
    },
    opts = {
    }
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "olimorris/neotest-rspec",
    },
    opts = {
      adapters = {
        ["neotest-rspec"] = {
          -- NOTE: By default neotest-rspec uses the system wide rspec gem instead of the one through bundler
          rspec_cmd = function()
            return vim.tbl_flatten({
              "bin/rspec",
            })
          end,
        },
      },
    },
    config = function(opts)
      require("neotest").setup({
        adapters = {
          require("neotest-rspec")({
            rspec_cmd = function()
              return vim.tbl_flatten({
                "bin/rspec",
              })
            end,
          }),
        },
      })
    end,

  },
}
