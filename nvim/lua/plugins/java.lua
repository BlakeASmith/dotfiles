local jdtls_plugin = {
	"mfussenegger/nvim-jdtls",
	opts = function()
		-- Assuming we've installed jdtls using Mason.nvim
		-- If this is not the case for you, change this to your jdtls binary path
		local cmd = { vim.fn.expand("$MASON/bin/jdtls") }
		-- Assuming we've installed lombok-nightly using Mason.vim
		-- If not, you can replace this with the path to your lombok.jar file
		local lombok_jar = vim.fn.expand("$MASON/share/lombok-nightly/lombok.jar")
		table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))

		return {
			cmd = cmd,
		}
	end,
	config = function(_, opts)
		local attach_jdtls = function()
			require("jdtls").start_or_attach({
				cmd = opts.cmd,
			})
		end

		-- attach the LSP for any java file
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = attach_jdtls,
		})

		-- Autocommand may not fire when opening .java file directly
		-- Calling it once for this case
		attach_jdtls()
	end,
}

return {
	jdtls_plugin,
}
