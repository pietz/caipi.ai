cask "caipi" do
  version "0.1.8"
  sha256 "80e827bd09ec29f84e60a4bab5d967ab24ec86728db571f30b59d568e8106dd8"

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
