# Dice App

A simple iOS app that simulates rolling two dice with animations and sound effects.

## Features

- Two dice that roll simultaneously
- 3-second rolling animation
- Sound effects during rolling
- Support for both portrait and landscape orientations
- Modern UI with casino-inspired design

## Requirements

- iOS 15.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

## Setup

1. Open the project in Xcode
2. Add a dice rolling sound effect file named `dice_roll.mp3` to the project
3. Build and run the app on your iOS device or simulator

## How to Use

1. Tap the "Roll Dice" button to start rolling
2. The dice will animate for 3 seconds with sound effects
3. The final numbers will be displayed when the animation completes

## Project Structure

- `DiceApp.swift`: Main app entry point
- `ContentView.swift`: Main view containing the dice and roll button
- `DiceViewModel.swift`: Handles game logic and sound effects 