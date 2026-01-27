cask "caipi" do
  version "0.1.6"
  sha256 "51cf5e4d3dcb8178f75bf00451008d3da5c949b5e97f22c55fefca4f21310af1"

  url "https://github.com/pietz/caipi.ai/releases/download/v#{version}/caipi_aarch64.dmg"
  name "Caipi"
  desc "Friendly chat UI for Claude Code"
  homepage "https://caipi.ai"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64

  app "caipi.app"

  zap trash: [
    "~/Library/Application Support/com.pietz.caipi",
    "~/Library/Caches/com.pietz.caipi",
    "~/Library/Preferences/com.pietz.caipi.plist",
    "~/Library/Saved Application State/com.pietz.caipi.savedState",
  ]
end
