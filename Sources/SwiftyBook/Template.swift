//
//  File.swift
//  
//
//  Created by Callum Boddy on 11/04/2022.
//

import Foundation
import XCTest

public protocol SwiftyBookTemplate {

    var stories: [SwiftyBook.Story] { get }

    /** The parent path at which the output SwiftBook directory will be created

     var root: String {
         return #filePath
     }
    */
    var root: String { get }

    var title: String { get }

    @MainActor
    func generate()

    @MainActor
    func testGenerateStoryBook()
}

public extension SwiftyBookTemplate where Self: XCTestCase {

    @MainActor
    func generate() {
        runAsyncTest {
            try await SwiftyBookCreator(configuration: .init(root: self.root))
                .create(from: Book(title: self.title, stories: self.stories))
        }
    }
}
