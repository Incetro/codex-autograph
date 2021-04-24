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
        var encodeSequence: [String] = []
        for valueCount in 1...valuesCount {
            var genericTypes: [String] = []
            var arguments: [String] = []
            var encodes: [String] = []
            for count in 1...valueCount {
                genericTypes.append("V\(count): Encodable")
                arguments.append("_ v\(count): V\(count)".indent)
                encodes.append("try container.encode(v\(count))".indent)
            }
            encodeSequence.append(
            """
            mutating func encodeValues<\(genericTypes.joined(separator: ", "))>(
            \(arguments.joined(separator: ",\n")),
                for key: Key
            ) throws {
                var container = self.nestedUnkeyedContainer(forKey: key)
            \(encodes.joined(separator: "\n"))
            }
            """.indent
            )
        }
        return encodeSequence
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
        var decodeSequence: [String] = []
        for valueCount in 1...valuesCount {
            var genericTypes: [String] = []
            var returns: [String] = []
            var decodes: [String] = []
            for count in 1...valueCount {
                genericTypes.append("V\(count): Decodable")
                returns.append("V\(count)")
                decodes.append("try container.decode(V\(count).self)".indent.indent)
            }
            decodeSequence.append(
            """
            func decodeValues<\(genericTypes.joined(separator: ", "))>(
                for key: Key
            ) throws -> (\(returns.joined(separator: ", "))) {
                var container = self.nestedUnkeyedContainer(forKey: key)
                return (
            \(decodes.joined(separator: ",\n"))
                )
            }
            """.indent
            )
        }
        return decodeSequence
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
        var encodeDeclaration = ""
        var decodeDeclaration = ""
        if let valuesCount = parameters[.keyedContainerValuesCount] {
            encodeDeclaration = keyedEncodingContainerDeclaration(count: Int(valuesCount) ?? 0)
            decodeDeclaration = keyedEncodingContainerDeclaration(count: Int(valuesCount) ?? 0)
        } else {
            encodeDeclaration = keyedEncodingContainerDeclaration(count: Constants.valuesCount)
            decodeDeclaration = keyedEncodingContainerDeclaration(count: Constants.valuesCount)
        }
        let sourceCode = """
        \(header)
        \(encodeDeclaration)
        \(decodeDeclaration)
        """
        return [
            AutographImplementation(
                filePath: "\(enumsFolder)/KeyedContainer.swift",
                sourceCode: sourceCode
            )
        ]
    }
}
