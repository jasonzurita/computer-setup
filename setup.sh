#!/usr/bin/env zsh

echo "🚀 Starting setup"

# Dotfiles
printf "🖥  Configuring dotfiles..."
if [ -d "$HOME/Code/dotfiles" ]; then
    echo " already exists — skipping clone."
else
    echo " cloning..."
    git clone https://github.com/jasonzurita/dotfiles.git ../dotfiles
fi
cd $HOME/Code/dotfiles
sh setup.sh
cd $HOME/Code/computer-setup

# Homebrew
if test ! $(which brew); then
    echo "🍺 Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "🍺 Updating homebrew..."
brew update

PACKAGES=(
    swiftlint
    swiftformat
    swift-format
    black
    Ack
    yamllint
    postgres
    pyenv
    nvm
    rbenv
    xcodes
    xcodegen
    fastlane
    gh
    asdf
    swift-sh
    ffmpeg
    git-lfs
)

echo "🍺 Installing brew packages..."
for pkg in "${PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null; then
        echo "  ✓ $pkg (already installed)"
    else
        echo "  ↓ Installing $pkg..."
        brew install "$pkg"
    fi
done

echo "📦 Setting up Node and Claude Code..."
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
nvm install --lts

INSTALLED_CLAUDE=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
LATEST_CLAUDE=$(npm view @anthropic-ai/claude-code version 2>/dev/null)
if [ -z "$INSTALLED_CLAUDE" ]; then
    echo "  ↓ Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
elif [ "$INSTALLED_CLAUDE" != "$LATEST_CLAUDE" ]; then
    echo "  ↑ Updating Claude Code ($INSTALLED_CLAUDE → $LATEST_CLAUDE)..."
    npm install -g @anthropic-ai/claude-code
else
    echo "  ✓ Claude Code $INSTALLED_CLAUDE (up to date)"
fi

echo "💻 Setting up Xcode..."
if xcodes installed 2>/dev/null | grep -q .; then
    echo "  ✓ Already installed: $(xcodes installed 2>/dev/null | head -1)"
else
    echo "  ↓ Installing latest Xcode..."
    xcodes install --latest
fi

CASKS=(
    dropbox
    sourcetree
    google-chrome
    zoom
    slack
    android-studio
    bartender
    monodraw
    claude
)
echo "🍺 Installing cask apps..."
for cask in "${CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        echo "  ✓ $cask (already installed)"
    else
        output=$(brew install --cask "$cask" 2>&1)
        exit_code=$?
        if [ $exit_code -eq 0 ]; then
            echo "  ✓ $cask installed"
        elif echo "$output" | grep -qi "already"; then
            echo "  ✓ $cask (already installed outside brew)"
        else
            echo "  ✗ $cask: $(echo "$output" | tail -1)"
        fi
    fi
done

GEMS=(
    cocoapods
    bundler
)
echo "💎 Installing Ruby gems..."
sudo gem install ${GEMS[@]} -N

echo "🧼 Cleaning up homebrew..."
brew cleanup -s

echo "🛠  Configuring system preferences..."
mkdir -p $HOME/Code
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 3
defaults write com.apple.finder AppleShowAllFiles YES
defaults write -g com.apple.swipescrolldirection -bool FALSE

defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 1
defaults write com.apple.HIToolbox AppleFnUsageType -int 3

defaults write pbs NSServicesStatus '{
    "com.apple.Terminal - New Terminal at Folder - newTerminalAtFolder" = {
        "key_equivalent" = "@$j";
    };
}'

defaults write com.apple.dock tilesize -int 52
defaults write com.apple.Dock autohide -bool TRUE
defaults write com.apple.Dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.25
defaults write com.apple.Dock orientation -string left
killall Dock

cp -p ./com.manytricks.Moom.plist $HOME/Library/Preferences/

echo "🎨 Configuring Xcode color theme..."
mkdir -p $HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/
cp *.dvtcolortheme $HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/

echo "👯‍♀️ Cloning some projects..."
for repo in jasonzurita.github.io talks swift-website-dsl; do
    dir="$HOME/Code/$repo"
    if [ -d "$dir" ]; then
        echo "  ✓ $repo (already cloned)"
    else
        echo "  ↓ Cloning $repo..."
        git clone "https://github.com/jasonzurita/$repo.git" "$dir"
    fi
done

echo "📱 Cloning mobile projects..."
mkdir -p $HOME/Code/mobile
for repo in crema crease earwig GolfSwingAnalyzer james-sandbox set-hike-flag-football; do
    dir="$HOME/Code/mobile/$repo"
    if [ -d "$dir" ]; then
        echo "  ✓ $repo (already cloned)"
    else
        echo "  ↓ Cloning $repo..."
        git clone "https://github.com/jasonzurita/$repo.git" "$dir"
    fi
done

echo "⌨️  Importing Keyboard Maestro macros..."
KM_APP="/Applications/Keyboard Maestro.app"
KM_MACROS="$HOME/Code/computer-setup/keyboard-maestro-macros.kmmacros"
if [ ! -d "$KM_APP" ]; then
    echo "  ⚠️  Keyboard Maestro not installed — skipping macro import."
else
    open -a "Keyboard Maestro"
    sleep 2
    open "$KM_MACROS"
    echo "  ✓ Macros file sent to Keyboard Maestro for import."
fi

echo ""
echo "⚠️  Note: Some changes aren't applied until you log out and back in."

REMINDERS=()
[ ! -d "/Applications/Moom.app" ] && REMINDERS+=("Install Moom from the App Store")
[ ! -d "/Applications/CopyClip.app" ] && REMINDERS+=("Install CopyClip from the App Store")
[ ! -d "/Applications/Keyboard Maestro.app" ] && REMINDERS+=("Install Keyboard Maestro from the App Store")
if [ $(find ~/.ssh -maxdepth 1 -name "*.pub" 2>/dev/null | wc -l) -eq 0 ]; then
    REMINDERS+=("Generate a new SSH key and add it to GitHub")
fi
if ! gh auth status &>/dev/null; then
    REMINDERS+=("Run: gh auth login")
    REMINDERS+=("Set up a new GitHub Personal Access Token (PAT)")
fi

if [ ${#REMINDERS[@]} -gt 0 ]; then
    echo ""
    echo "😁 Remember to:"
    for reminder in "${REMINDERS[@]}"; do
        echo "   - $reminder"
    done
fi

echo ""
echo "🎉 Setup complete!"
