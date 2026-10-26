# Baby Count

A simple SwiftUI app for babies and toddlers that teaches numbers one to ten and colors. It speaks every word out loud. It runs on iPhone and iPad with iOS 17 or later.

## Playing

Tap, swipe, or just move a finger on the screen. A colorful trail follows the finger, and lifting it moves to the next number or color.

## Parent settings

Press and hold the small lock in the top corner for two seconds. A quick tap does nothing, so a baby can't change settings.

- **Learn about:** Both, Numbers only, or Colors only.
- **Level:**
  - **Learn** shows the word and says it right away.
  - **Remember** shows no words. The app waits a moment for the baby to remember, then says the answer.
  - **Find it** asks "Where is red?" and shows 2, 3, or 4 big choices. A right answer gets a star celebration.
- **Colors:** the 3 primary colors, or 10 colors including green, orange, purple, pink, brown, black, and white.
- **Progress:** every Find it answer is saved on the device. The Progress screen shows how often each color and number is right on the first try. A daily chart compares the score with what random tapping would get, and the screen shows the change from the previous week.

## Keeping a baby in the app

The app hides the status bar, keeps the screen awake, and makes edge swipes harder to trigger by accident. Apple doesn't let an app lock itself, so for a full lock use Guided Access:

1. Open Settings, then Accessibility, then Guided Access. Turn it on and set a passcode.
2. Open Baby Count and triple-click the side button (or Home button). Tap Start.
3. To leave, triple-click again and enter the passcode.

The app has no ads, no purchases, no links, and no internet access.

## Build

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```
brew install xcodegen
xcodegen generate
open BabyCounting.xcodeproj
```

Pick an iPhone or iPad simulator and press Run.
