// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceHelpTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Insurance.HelpType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "none":
                return .success(.none)
            case "file":
                return .success(.openFile)
            case "html_tree":
                return .success(.blocks)
            case "html_tree_and_file":
                return .success(.blocksWithFile)
            default:
                return .success(.none)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .none:
                return transformer.transform(destination: "none")
            case .openFile:
                return transformer.transform(destination: "file")
            case .blocks:
                return transformer.transform(destination: "html_tree")
            case .blocksWithFile:
                return transformer.transform(destination: "html_tree_and_file")
        }
    }
}
