//
//  MorningBearDateFormatterTests.swift
//  MorningBearKitTests
//
//  Created by 이영빈 on 2023/01/05.
//  Copyright © 2023 com.dache. All rights reserved.
//

import XCTest
@testable import MorningBearKit

final class MorningBearDateFormatterTests: XCTestCase {
    private var formatter: DateFormatter!

    override func setUpWithError() throws {
        formatter = MorningBearDateFormatter.default
    }

    override func tearDownWithError() throws {
        formatter = nil
    }
    
    func test__time_format_success() throws {
        formatter = MorningBearDateFormatter.timeFormatter
        
        let dateStrings = ["오전 3시 30분", "오전 8시 3분", "오후 3시 39분", "오후 3시 9분"]
        
        for dateString in dateStrings {
            guard let date = formatter.date(from: dateString) else {
                XCTFail("String에서 Date 값으로 변환 실패")
                return
            }
            
            let stringFromDate = formatter.string(from: date)
            XCTAssertEqual(dateString, stringFromDate)
        }
    }
    
    func test__time_format_error() throws {
        formatter = MorningBearDateFormatter.timeFormatter
        
        let dateStrings = ["오전 13시 30분", "오전 8시 93분", "오후 23시 39분"]
        
        for dateString in dateStrings {
            guard formatter.date(from: dateString) != nil else {
                continue
            }
            
            XCTFail("Date값으로 변환되어서는 안됨")
        }
    }
    
    func test__day_format() {
        formatter = MorningBearDateFormatter.dayFormatter
        
        let dateStrings = ["2022년 3월 12일", "2022년 12월 1일", "2022년 3월 2일", "2022년 12월 12일"]
        
        for dateString in dateStrings {
            guard let date = formatter.date(from: dateString) else {
                XCTFail("String에서 Date 값으로 변환 실패")
                return
            }
            
            let stringFromDate = formatter.string(from: date)
            XCTAssertEqual(dateString, stringFromDate)
        }
    }
    
    func test__shortime_format() {
        formatter = MorningBearDateFormatter.shortimeFormatter
        
        let dateStrings = ["0130", "1202", "0302", "1139"]

        for dateString in dateStrings {
            guard let date = formatter.date(from: dateString) else {
                XCTFail("String에서 Date 값으로 변환 실패")
                return
            }
            
            let stringFromDate = formatter.string(from: date)
            XCTAssertEqual(dateString, stringFromDate)
        }
    }
    
    func test__calling_formatter_affects_other_formatter() throws {
        let timeFormatter = MorningBearDateFormatter.timeFormatter
        let _ = MorningBearDateFormatter.dayFormatter
        
        XCTAssertEqual(timeFormatter.dateFormat, MorningBearDateFormatter.timeFormatter.dateFormat)
    }
}
