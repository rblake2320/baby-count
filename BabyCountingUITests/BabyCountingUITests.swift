import XCTest

final class BabyCountingUITests: XCTestCase {
    private func launch(mode: String, level: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-mode", mode, "-level", level, "-choices", "3"]
        app.launch()
        return app
    }

    func testSwipeAndTapAdvance() {
        let app = launch(mode: "Colors", level: "Learn")
        let screen = app.otherElements["Red!"]
        XCTAssertTrue(screen.waitForExistence(timeout: 5))
        app.swipeLeft()                                   // finger lift advances
        XCTAssertTrue(app.otherElements["Yellow!"].waitForExistence(timeout: 3))
        sleep(1)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7)).tap()
        XCTAssertTrue(app.otherElements["Blue!"].waitForExistence(timeout: 3))
    }

    func testFindItRightAnswerAsksNewQuestion() {
        let app = launch(mode: "Colors", level: "Find it")
        let prompt = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Where is'")).firstMatch
        XCTAssertTrue(prompt.waitForExistence(timeout: 5))
        let color = prompt.label.replacingOccurrences(of: "Where is ", with: "").replacingOccurrences(of: "?", with: "")
        app.buttons[color].tap()
        // After the celebration a new question appears.
        let next = NSPredicate(format: "exists == true AND label != %@", prompt.label)
        let newPrompt = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Where is'")).firstMatch
        expectation(for: next, evaluatedWith: newPrompt)
        waitForExpectations(timeout: 6)
    }

    func testQuickTapDoesNotOpenSettingsButLongPressDoes() {
        let app = launch(mode: "Both", level: "Learn")
        let lock = app.buttons["Parent settings"].exists ? app.buttons["Parent settings"] : app.images["Parent settings"]
        XCTAssertTrue(lock.waitForExistence(timeout: 5))
        lock.tap()
        XCTAssertFalse(app.navigationBars["Parent Settings"].waitForExistence(timeout: 2))
        lock.press(forDuration: 2.5)
        XCTAssertTrue(app.navigationBars["Parent Settings"].waitForExistence(timeout: 3))
    }
}
