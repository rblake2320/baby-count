# Baby Count

A tiny SwiftUI app for babies and toddlers. It counts from one to ten and cycles through the three primary colors: red, yellow, and blue.

Tap anywhere on the screen to go to the next number. Each tap speaks the number and the color out loud, for example "Two! Yellow!". After ten it starts again at one.

Runs on iPhone and iPad, iOS 17 or later.

## Build

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```
brew install xcodegen
xcodegen generate
open BabyCounting.xcodeproj
```

Then pick an iPhone or iPad simulator and press Run.
