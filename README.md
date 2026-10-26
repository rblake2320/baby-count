# Baby Count

A tiny SwiftUI app for babies and toddlers. It counts from one to ten and shows the three primary colors: red, yellow, and blue.

Tap anywhere on the screen to go to the next step. The app speaks each one out loud. After the last step it starts over.

Buttons at the top switch between three modes:

- **Both**: numbers one to ten on a red, yellow, or blue screen. It says "Two! Yellow!"
- **Numbers**: just the numbers one to ten on a plain light screen. It says "Two!"
- **Colors**: just red, yellow, and blue. It says "Yellow!"

The app remembers the last mode you picked.

Runs on iPhone and iPad, iOS 17 or later.

## Build

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```
brew install xcodegen
xcodegen generate
open BabyCounting.xcodeproj
```

Then pick an iPhone or iPad simulator and press Run.
