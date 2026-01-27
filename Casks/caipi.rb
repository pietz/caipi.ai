cask "caipi" do
  version "0.1.4"
  sha256 "0ee26d9dd4437856280b755c0ebbd1b600105f4b33b58b7fe3504681c136f77a"

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
