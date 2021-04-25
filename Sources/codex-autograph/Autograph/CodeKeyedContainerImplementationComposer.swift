//
//  CodexEnumsImplementationComposer.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 22.04.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - CodeKeyedContainerImplementationComposer

public final class CodeKeyedContainerImplementationComposer {

    public init() {
    }

    // MARK: - Private

    /// Header comment
    /// - Parameter projectName: current project name
    /// - Returns: header comment from string
    private func headerComment(projectName: String) -> String {
        """
        //
        //  KeyedContainer.swift
        //  \(projectName)
        //
        //  Generated automatically by codex-autograph
        //  https://github.com/Incetro/codex-autograph
        //
        //  Copyright © 2021 Incetro Inc. All rights reserved.
        //

        """
    }

    /// Encode methods sequence
    /// - Parameter valuesCount: needed values count
    /// - Returns: encode methods sequence from string
    private func encodeValuesSequence(valuesCount: Int) -> [String] {
        (1...valuesCount).map {
            let (genericTypes, arguments, encodes) = (
                (1...$0).map { "V\($0): Encodable" },
                (1...$0).map { "_ v\($0): V\($0)".indent },
                (1...$0).map { "try container.encode(v\($0))".indent }
            )
            return """
            mutating func encodeValues<\(genericTypes.joined(separator: ", "))>(
            \(arguments.joined(separator: ",\n")),
                for key: Key
            ) throws {
                var container = self.nestedUnkeyedContainer(forKey: key)
            \(encodes.joined(separator: "\n"))
            }
            """.indent
        }
    }

    /// Keyed encoding container declaration
    /// - Parameter count: needed values count
    /// - Returns: keyed encoding container declaration from string
    private func keyedEncodingContainerDeclaration(count: Int) -> String {
        """
        // MARK: - KeyedEncodingContainer

        extension KeyedEncodingContainer {

        \(encodeValuesSequence(valuesCount: count).joined(separator: "\n\n"))
        }
        """
    }

    /// Decode methods sequence
    /// - Parameter valuesCount: needed values count
    /// - Returns: decode methods sequence from string
    private func decodeValuesSequence(valuesCount: Int) -> [String] {
        (1...valuesCount).map {
            let (genericTypes, returns, decodes) = (
                (1...$0).map { "V\($0): Decodable" },
                (1...$0).map { "V\($0)" },
                (1...$0).map { "try container.decode(V\($0).self)".indent.indent }
            )
            return """
            func decodeValues<\(genericTypes.joined(separator: ", "))>(
                for key: Key
            ) throws -> (\(returns.joined(separator: ", "))) {
                var container = self.nestedUnkeyedContainer(forKey: key)
                return (
            \(decodes.joined(separator: ",\n"))
                )
            }
            """.indent
        }
    }

    /// Keyed encoding container declaration
    /// - Parameter count: needed values count
    /// - Returns: declaration from string
    private func keyedDecodingContainerDeclaration(count: Int) -> String {
        """
        // MARK: - KeyedDecodingContainer

        extension KeyedDecodingContainer {

        \(decodeValuesSequence(valuesCount: count).joined(separator: "\n\n"))
        }
        """
    }
}

// MARK: - ImplementationComposer

extension CodeKeyedContainerImplementationComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        guard let enumsFolder = parameters[.enums] else {
            throw CodexAutographError.noEnumsFolder
        }
        let header = headerComment(projectName: parameters.projectName)
        var sourceCode = ""
        if let valuesCount = parameters[.keyedContainerValuesCount] {
            sourceCode = """
            \(header)
            \(keyedEncodingContainerDeclaration(count: Int(valuesCount) ?? Constants.keyedContainerValuesCount))
            \(keyedEncodingContainerDeclaration(count: Int(valuesCount) ?? Constants.keyedContainerValuesCount))
            """
        } else {
            sourceCode = """
            \(header)
            \(keyedEncodingContainerDeclaration(count: Constants.keyedContainerValuesCount))
            \(keyedEncodingContainerDeclaration(count: Constants.keyedContainerValuesCount))
            """
        }
        return [
            AutographImplementation(
                filePath: "\(enumsFolder)/KeyedContainer.swift",
                sourceCode: sourceCode
            )
        ]
    }
}
