//
//  File.swift
//  
//
//  Created by Callum Boddy on 17/01/2022.
//

import Foundation
import UIKit

public protocol MarkdownPresentable {
    var content: String { get }
}

public func +(lhs: MarkdownPresentable, rhs: MarkdownPresentable) -> Markdown.Text {
    let content = lhs.content + "\n\n" + rhs.content
    return Markdown.Text(content: content)
}

public struct MarkdownFileGenerator {

    public let directory: URL
    public var content: [String]

    public init(directory: URL, markdown: [MarkdownPresentable]) {
        self.directory = directory
        self.content = markdown.compactMap { $0.content }
    }

    public var writePath: URL {
        return directory.appendingPathComponent("SwiftyBook.md")
    }

    public func write() throws {
        let output = content.joined(separator: "\n\n")
        do {
            try output.write(toFile: writePath.path, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
}

public struct Markdown {}

extension Markdown {

    public struct Text: MarkdownPresentable {
        public var content: String

        public init(content: String) {
            self.content = content
        }
    }

    public struct Header: MarkdownPresentable {

        internal enum Level: Int {
            case h1 = 1
            case h2
            case h3
            case h4
            case h5
            case h6
        }

        public var content: String

        init(level: Level, header: String) {
            let content: String = .init(repeating: "#", count: level.rawValue) + " " + header
            self.content = content
        }
    }

    public struct CodeBlock: MarkdownPresentable {

        internal enum Level: Int {
            case h1 = 1
            case h2
            case h3
            case h4
            case h5
            case h6
        }

        public var content: String

        internal init(level: Level, header: String) {
            let content: String = .init(repeating: "#", count: level.rawValue) + " " + header
            self.content = content
        }
    }

    public struct Image: MarkdownPresentable {

        let path: URL
        let width: CGFloat
        let height: CGFloat

        init(path: URL, width: CGFloat, height: CGFloat) {
            self.path = path
            self.width = width
            self.height = height
        }

        public var content: String {
            "<img src=\"\(path.path)\" width=\"\(width)\" height=\"\(height)\">"
        }
    }
}
