return {
	"tadaa/vimade",
	opts = {
		recipe = { "default", { animate = true } },
		fadelevel = 0.4,
		blocklist = {
			codediff = {
				win_vars = { codediff_restore = { 1 } },
			},
		},
	},
}
