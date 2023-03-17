import XCTest
@testable import MovieQuiz

final class ArrayTest: XCTestCase{
    func testGetValueInRange() throws{
        //Given
        let array = [1, 7, 2, 3, 5]
        //When
        let value = array[safe: 2]
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    func testGetValueOutOfRange() throws{
        //Given
        let array = [1, 7, 2, 3, 5]
        //When
        let value = array[safe: 20]
        //Then
        XCTAssertNil(value)
    }
}
