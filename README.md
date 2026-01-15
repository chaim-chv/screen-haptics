# ScreenHaptics

A lightweight macOS menu bar utility that provides haptic feedback when your mouse cursor moves between displays.

## Features
- **Haptic Feedback:** Feel a subtle "bump" on your trackpad when moving between screens.
- **Adjustable Strength:** Choose between Light, Medium, and Strong haptic feedback.

## Requirements
- macOS 10.15 or later.
- A MacBook with a Force Touch trackpad or a Magic Trackpad.

## Installation & Usage

Download the latest release and follow the instructions from the [Releases](https://github.com/chaim-chv/screen-haptics/releases/latest) page.

### Hide Status Bar Item (Like [Here](https://github.com/artginzburg/MiddleClick#hide-status-bar-item))

1. Holding `⌘`, drag it away from the status bar until you see a :heavy_multiplication_x: (cross icon)
2. Let it go

> To recover the item, just open ScreenHaptics when it's already running

## For Development

You can build the app using just Command Line Tools:

```bash
swift main.swift -o ScreenHaptics
```

Then run the app:

```bash
./ScreenHaptics
```

Or you can use the build script:

```bash
sh build.sh
```

You can provide an optional version string as an argument:

```bash
sh build.sh 1.0.0
```

Run the generated `ScreenHaptics.app`.

## Reason and Inspiration

I recently saw the feature in the MX Master 4 mouse that provides haptic feedback when moving between screens (only if you have the Logi Options+ bloatware installed). I found it quite useful and wanted to have a similar feature for my MacBook's trackpad. So comes this 100% Vibe-coded utility.

## License
MIT License @ [chaim-chv](https://github.com/chaim-chv/) 2026
