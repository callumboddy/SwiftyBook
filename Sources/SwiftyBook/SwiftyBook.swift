
import SwiftUI
import Foundation
import UIKit
import XCTest

public class SwiftyBook {

    let configuration: SwiftyBook.Configuration

    public init(configuration: SwiftyBook.Configuration) {
        self.configuration = configuration
    }

    public func create(from book: Book) throws {
        let title = [Markdown.Header(level: .h1, header: "SwiftyBook Design System")]
        let content = try snapshot(stories: book.stories)
        try MarkdownFileGenerator(directory: configuration.directory, markdown: title + content).write()
    }

    private func snapshot(stories: [Story]) throws -> [MarkdownPresentable] {
        let dictionary: [String: [Story]] = Dictionary(grouping: stories, by: \.category)
        let output = try dictionary.map { chapter, inner -> [MarkdownPresentable] in
            let title = Markdown.Header(level: .h2, header: chapter)
            let content = try inner.compactMap { try snapshot(story: $0) }.flatMap { $0 }
            return [title] + content
        }
        return output.flatMap { $0 }
    }

    func snapshot(story: Story) throws -> [MarkdownPresentable] {
        let content: [MarkdownPresentable] = try story.previews.enumerated().map { index, preview in
            do {
                let fileName = story.name(for: preview, at: index)
                let savedImage = try store(imageOf: preview.content, with: fileName)
                let size = CGRect(origin: .zero, size: savedImage.size).integral.size
                let path = URL(string: "Images")!.appendingPathComponent("\(fileName)" + configuration.format.extension)
                return Markdown.Header(level: .h3, header: story.name) + Markdown.Image(path: path, width: size.width, height: size.height) + story.documentation
            } catch {
                throw SwiftyBookError.snapshotError(name: story.name)
            }
        }
        return content
    }

    private func store(imageOf view: AnyView, with name: String) throws -> UIImage {
        if let image: UIImage = view.convertedToImage().trimmingTransparentPixels(), let data = image.pngData() {
            let saveDir = URL(fileURLWithPath: configuration.imagesDirectory.path, isDirectory: true)
            let filePath = saveDir.appendingPathComponent("\(name)\(configuration.format.extension)")
            try data.write(to: filePath)
            return image
        } else {
            throw SwiftyBookError.failedToSaveImage(name: name)
        }
    }
}

extension SwiftyBook {

    public enum ImageExportFileFormat {
        case png
        case jpeg

        var `extension`: String {
            switch self {
            case .png: return ".png"
            case .jpeg: return ".jpg"
            }
        }
    }

    public struct Configuration {

        public let directory: URL

        let format: ImageExportFileFormat

        public init(root: String, format: ImageExportFileFormat = .png) {
            let directory = URL(fileURLWithPath: root).deletingLastPathComponent().deletingLastPathComponent()
            self.directory = directory.appendingPathComponent("SwiftyBook")
            self.format = format
            try! FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        var imagesDirectory: URL {
            return directory.appendingPathComponent("Images")
        }
    }
}

public struct Book {

    let title: String
    let stories: [Story]

    public init(title: String, stories: [Story]) {
        self.title = title
        self.stories = stories
    }
}

public struct Story {

    let name: String
    let category: String
    let previews: [_Preview]
    let documentation: MarkdownPresentable

    public init(name: String, category: String = "", previews: [_Preview], documentation: (() -> MarkdownPresentable) = { Markdown.Text(content: "") }){
        self.name = name
        self.category = category
        self.previews = previews
        self.documentation = documentation()
    }

    func name(for preview: _Preview, at index: Int = 0) -> String {
        var name = "\(name)"
        if let displayName = preview.displayName {
            name += "-\(displayName)"
        }
        if index > 0 {
            name += "-\(index)"
        }
        return name
    }
}

public enum SwiftyBookError: Error, LocalizedError {

    case snapshotError(name: String)
    case failedToSaveImage(name: String)

    public var errorDescription: String {
        switch self {
        case .snapshotError(let name):
            return "Failed to create snapshot for \(name)"
        case .failedToSaveImage(let name):
            return "Failed to create and store image for \(name)"
        }
    }
}
