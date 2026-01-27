cask "caipi" do
  version "0.1.3"
  sha256 "a23f5ed580181bd56b0359e10e17996ec855eb0b35540fe789c444f9f38acd00"

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
