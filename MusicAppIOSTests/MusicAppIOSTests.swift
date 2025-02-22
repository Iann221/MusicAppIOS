//
//  MusicAppIOSTests.swift
//  MusicAppIOSTests
//
//  Created by Vincentius Ian Widi Nugroho on 22/02/25.
//

import XCTest
import RxSwift
@testable import MusicAppIOS

final class MusicAppIOSTests: XCTestCase {
    var viewModelFail: MainViewModel!
    var viewModelSuccess: MainViewModel!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        viewModelFail = MainViewModel(audioFileName: "", apiURL: "https:// ")
        viewModelSuccess = MainViewModel(audioFileName: "Elevator-music", apiURL: "https://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=")
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        viewModelFail = nil
        viewModelSuccess = nil
        disposeBag = nil
    }

    func testFetchTracks_invalidURL() {
        let expectation = self.expectation(description: "Invalid URL Error Triggered")

        viewModelFail.error.subscribe(onNext: { error in
            XCTAssertEqual(error, .invalidURL)
            expectation.fulfill()
        }).disposed(by: disposeBag)

        viewModelFail.fetchTracks(with: "")

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchTracks_parsingError() {
        let expectation = self.expectation(description: "Parsing Error Triggered")

        viewModelSuccess.error.subscribe(onNext: { error in
            XCTAssertEqual(error, .parsingError)
            expectation.fulfill()
        }).disposed(by: disposeBag)

        viewModelSuccess.fetchTracks(with: "") // Should trigger parsing error

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchTracks_success() {
        let expectation = self.expectation(description: "Parsing Error Triggered")
        var first = true
        viewModelSuccess.cellViewModels.subscribe(onNext: { cells in
            if(first){
                XCTAssertTrue(cells.isEmpty)
                first = false
            } else {
                XCTAssertFalse(cells.isEmpty)
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)

        viewModelSuccess.fetchTracks(with: "Queen") // Should trigger parsing error

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPlayAudioFromTime() {
        viewModelSuccess.setupAudioPlayer()
        XCTAssertNotNil(viewModelSuccess.audioPlayer)
        viewModelSuccess.playAudioFrom(0.5) // Seek to 50% of track
        XCTAssertEqual(self.viewModelSuccess.audioPlayer!.currentTime, (self.viewModelSuccess.audioPlayer?.duration ?? 0) * 0.5, accuracy: 1.0)
    }
    
    func testPlayAudioWithoutAudioPlayer() {
        viewModelSuccess.resetAudioPlayer()
        let expectation = self.expectation(description: "Audio Error Triggered")
        viewModelSuccess.error.subscribe(onNext: { error in
            XCTAssertEqual(error, .audioError)
            expectation.fulfill()
        }).disposed(by: disposeBag)

        viewModelSuccess.playAudioFrom(0.5)

        waitForExpectations(timeout: 5, handler: nil)
    }
}
