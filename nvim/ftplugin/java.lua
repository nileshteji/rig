local ok, jdtls = pcall(require, "jdtls")
if not ok then
    return
end

local root_markers = {
    "gradlew",
    "mvnw",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    ".git",
}

local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
    local bufname = vim.api.nvim_buf_get_name(0)
    root_dir = vim.fs.root(bufname, ".git") or vim.loop.cwd()
end

local project_name = vim.fn.fnamemodify(root_dir, ":t")
if project_name == "" then
    project_name = "default"
end
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

local mason_dir = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local launcher_path = vim.fn.glob(mason_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")

if launcher_path == "" then
    vim.notify("jdtls launcher not found. Run :MasonInstall jdtls", vim.log.levels.WARN)
    return
end

local os_name = vim.loop.os_uname().sysname
local arch = vim.loop.os_uname().machine

local config_dir
if os_name == "Darwin" then
    if arch == "arm64" then
        config_dir = mason_dir .. "/config_mac_arm"
    else
        config_dir = mason_dir .. "/config_mac"
    end
elseif os_name == "Linux" then
    if arch == "aarch64" or arch == "arm64" then
        config_dir = mason_dir .. "/config_linux_arm"
    else
        config_dir = mason_dir .. "/config_linux"
    end
else
    config_dir = mason_dir .. "/config_win"
end

local cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=WARN",
    "-javaagent:" .. mason_dir .. "/lombok.jar",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    launcher_path,
    "-configuration",
    config_dir,
    "-data",
    workspace_dir,
}

local config = {
    cmd = cmd,
    root_dir = root_dir,
    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            maven = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            format = {
                enabled = true,
            },
        },
    },
    init_options = {
        bundles = {},
    },
}

jdtls.start_or_attach(config)
