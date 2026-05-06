#!/usr/bin/env zsh

echo "🚀 Starting setup"

echo -n "🖥 Configuring dotfiles..."
git clone https://github.com/jasonzurita/dotfiles.git ../dotfiles
cd $HOME/Code/dotfiles
sh setup.sh
cd $HOME/Code/computer-setup
echo "done."

# Install Homebrew if not already installed
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
)

echo "🍺 Installing brew packages..."
brew install ${PACKAGES[@]}

CASKS=(
    dropbox
    sourcetree
    docker
    google-chrome
    zoom
    slack
)
echo "🍺 Installing cask apps..."
brew install --cask ${CASKS[@]}

GEMS=(
    cocoapods
    bundler
)
echo "💎 Installing Ruby gems..."
sudo gem install ${GEMS[@]} -N

echo "🧼 Cleaning up home-brew..."
brew cleanup -s

echo "🛠 Configuring system preferences..."
mkdir $HOME/Library/Preferences
mkdir -p $HOME/{Code}
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 3
defaults write com.apple.finder AppleShowAllFiles YES
defaults write -g com.apple.swipescrolldirection -bool FALSE # Turn off natural scrolling

# Dock
defaults write com.apple.dock tilesize -int 52 # make the dock size feel just right
defaults write com.apple.Dock autohide -bool TRUE # turn on auto hide dock
defaults write com.apple.Dock autohide-delay -float 0 # turn off dock show/hide delay
defaults write com.apple.dock autohide-time-modifier -float 0.25 # speed up show/hide animation
defaults write com.apple.Dock orientation -string left
killall Dock # restart the dock to pick up the above modifications

cp -p ./com.manytricks.Moom.plist $HOME/Library/Preferences/

echo "🎨 Configuring Xcode color theme..."
mkdir -p $HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/
cp *.dvtcolortheme $HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/

echo "👯‍♀️ Cloning some projects..."
cd $HOME/code
git clone https://github.com/jasonzurita/jasonzurita.github.io.git
git clone https://github.com/jasonzurita/talks.git
git clone https://github.com/jasonzurita/swiftynotes.git
git clone https://github.com/jasonzurita/swift-website-dsl.git

echo "⚠️  Note: Some changes aren't applied until you log out and back in."

echo "😁 Remember to: Install Moom & Clip copy from the App Store, keyboard maestro, & setup a new GitHub Personal Access Token (PAT)"

echo "🎉 Setup complete!"
