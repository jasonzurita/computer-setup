#!/usr/bin/env bash

echo "🚀 Starting setup"

echo -n "🖥 Configuring dotfiles..."
cd $HOME/code/dotfiles
git clone https://github.com/jasonzurita/dotfiles.git ../dotfiles
sh setup.sh
cd $HOME/computer-setup
echo "done."

# Install Homebrew if not already installed
if test ! $(which brew); then
    echo "🍺 Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "🍺 Updating homebrew..."
brew update

PACKAGES=(
    carthage
    cocoapods
    swiftlint
    swiftformat
    go
    black
    Ack
    yamllint
    proselint
    flake8
    postgres
    pyenv
    nvm
)

echo "🍺 Installing brew packages..."
brew install ${PACKAGES[@]}

CASKS=(
    dropbox
    sourcetree
    fastlane
    docker
)
echo "🍺 Installing cask apps..."
brew install --cask ${CASKS[@]}

GEMS=(
    cocoapods
    bundler
    jekyll
)
echo "💎 Installing Ruby gems..."
sudo gem install ${GEMS[@]} -N

echo "🧼 Cleaning up home-brew..."
brew cleanup -s

echo "🛠 Configuring System..."
mkdir $HOME/Library/Preferences
mkdir -p $HOME/{Code,Notes,Learn}
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 3
defaults write com.apple.finder AppleShowAllFiles YES
defaults write -g com.apple.swipescrolldirection -bool FALSE # Turn off natural scrolling

# Dock
defaults write com.apple.dock tilesize -int 52 # make the dock size feel just right
defaults write com.apple.Dock autohide -bool TRUE # turn on autohide dock
defaults write com.apple.Dock autohide-delay -float 0 # turn off dock show/hide delay
defaults write com.apple.dock autohide-time-modifier -float 0.25 # speed up show/hide animation
killall Dock # restart the dock to pick up the above modifications

# Menu bar
defaults write com.apple.menuextra.battery ShowPercent YES # show battery percent
killall SystemUIServer

cp -p ./com.manytricks.Moom.plist $HOME/Library/Preferences/

echo "🎨 Configuring Xcode color theme..."
mkdir -p $HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/
cp *.dvtcolortheme $HOME/Library/Developer/Xcode/UserData/FontAndColorThemes/

echo "👯‍♀️ Cloning some projects..."
cd $HOME/code
git clone https://github.com/jasonzurita/dotfiles.git ../dotfiles
git clone https://github.com/XVimProject/XVim2.git ../XVim2
git clone https://github.com/jasonzurita/jasonzurita.github.io.git ../jasonzurita.github.io
git clone https://github.com/jasonzurita/StandingDeskTimer ../StandingDeskTimer


echo "⚠️  Some changes aren't applied until you log out and back in."

echo "😁 Remember to: Install Moom from the App Store & setup a new GitHub Personal access token"

echo "🎉 Setup complete!"
