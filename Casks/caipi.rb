cask "caipi" do
  version "0.1.9"
  sha256 "ff4741ba7db280d5082685037d17a203354380afeba68bae96662d2046b81d5c"

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
