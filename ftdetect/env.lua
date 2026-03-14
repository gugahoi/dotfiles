vim.filetype.add({
    filename = {
        [".env"] = "sh",
    },
    pattern = {
        ["%.env%..*"] = "sh",
    },
})
