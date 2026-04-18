// Derived from Space Trader by Pieter Spronck, GPLv2.

import XCTest
@testable import SpaceTraderCore

final class SmokeTests: XCTestCase {
    func testPortVersionIsPopulated() {
        XCTAssertFalse(SpaceTraderCore.portVersion.isEmpty)
    }
}
