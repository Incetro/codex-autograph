//
//  CodexEnumsImplementationComposer.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 16.04.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - CodexEnumsImplementationComposer

public final class CodexEnumsImplementationComposer {

    public init() {
    }

    // MARK: - Private

    /// Header comment
    /// - Parameters:
    ///   - fileName: current file name
    ///   - projectName: current project name
    ///   - imports: current imports
    /// - Returns: header comment from string
    private func headerComment(
        fileName: String,
        projectName: String,
        imports: [String]
    ) -> String {
        let imports = imports.map { "import \($0)" }.joined(separator: "\n")
        return """
        //
        //  \(fileName).swift
        //  \(projectName)
        //
        //  Generated automatically by codex-autograph
        //  https://github.com/Incetro/codex-autograph
        //
        //  Copyright © 2021 Incetro Inc. All rights reserved.
        //

        \(imports)

        """
    }

    /// Enum extension declaration
    /// - Parameters:
    ///   - enum: target enum
    ///   - specifications: Specifications instance
    /// - Returns: declaration from string
    private func declaration(
        fromEnum enum: EnumSpecification,
        forSpecifications specifications: Specifications
    ) -> String {
        let inheritedType = specifications
            .consolidatedEnums[`enum`]?
            .first { $0.isCodexAppropriate }
            .flatMap(\.codexType) ?? `enum`.codexType.unwrap()
        return """

        // MARK: - \(inheritedType)

        extension \(`enum`.name): \(inheritedType) {

        """
    }

    /// Enum of coding keys
    /// - Parameters:
    ///   - enum: target enum
    ///   - specifications: Specifications instance
    /// - Returns: coding keys enum from string
    private func codingKeys(
        fromEnum enum: EnumSpecification,
        forSpecifications specifications: Specifications
    ) -> String {
        let casesSequence = `enum`.cases.map { `case` -> String in
            return "case \(`case`.name)"
        }.joined(separator: "\n")
        return """
        // MARK: - CodingKeys

        enum CodingKeys: CodingKey, CaseIterable {

            // MARK: - Cases

        \(casesSequence.indent)
        }

        """.indent
    }

    /// Decode switch cases
    /// - Parameter enum: target enum
    /// - Returns: decode switch cases from string
    private func decodeSwitchCases(
        fromEnum enum: EnumSpecification
    ) -> String {
        `enum`
            .cases
            .map { `case` in
                var strCase = ""
                if `case`.arguments.count == 0 {
                    strCase = """
                    case .\(`case`.name):
                        self = .\(`case`.name)
                    """
                } else if `case`.arguments.count == 1 {
                    if `case`.arguments[0].bodyName == "" {
                    strCase = """
                    case .\(`case`.name):
                        self = .\(`case`.name)(try container.decode(\(`case`.arguments[0].type).self, forKey: .\(`case`.name)))
                    """
                    } else {
                        strCase = """
                        case .\(`case`.name):
                            self = .\(`case`.name)(\(`case`.arguments[0].bodyName): try container.decode(\(`case`.arguments[0].type).self, forKey: .\(`case`.name)))
                        """
                    }
                } else if `case`.arguments.count == 2 {
                    var argumentNames: [String] = []
                    var argumentTypes: [String] = []
                    var initializerArguments: [String] = []
                    var count = 1
                    for argument in `case`.arguments {
                        argumentTypes.append("\(argument.type)")
                        if let argumentName = makeVariableName(argument: argument) {
                            argumentNames.append(argumentName)
                            initializerArguments.append("\(argumentName): \(argumentName)")
                        } else {
                            argumentNames.append("value\(count)")
                            initializerArguments.append("value\(count)")
                        }
                        count += 1
                    }
                    strCase = """
                    case .\(`case`.name):
                        let (\(argumentNames.joined(separator: ", "))): (\(argumentTypes.joined(separator: ", "))) = try container.decodeValues(for: .\(`case`.name))
                        self = .\(`case`.name)(\(initializerArguments.joined(separator: ", ")))
                    """
                } else {
                    var argumentNames: [String] = []
                    var argumentTypes: [String] = []
                    var initializerArguments: [String] = []
                    var count = 1
                    for argument in `case`.arguments {
                        argumentTypes.append("\(argument.type)".indent.indent)
                        if let argumentName = makeVariableName(argument: argument) {
                            argumentNames.append(argumentName.indent.indent)
                            initializerArguments.append("\(argumentName): \(argumentName)".indent.indent)
                        } else {
                            argumentNames.append("value\(count)".indent.indent)
                            initializerArguments.append("value\(count)".indent.indent)
                        }
                        count += 1
                    }
                    strCase = """
                    case .\(`case`.name):
                        let (
                    \(argumentNames.joined(separator: ",\n"))
                        ): (
                    \(argumentTypes.joined(separator: ",\n"))
                        ) = try container.decodeValues(for: .\(`case`.name))
                        self = .\(`case`.name)(
                    \(initializerArguments.joined(separator: ",\n"))
                        )
                    """
                }
                return strCase
            }.joined(separator: "\n")
    }

    /// Decode initializer
    /// - Parameter enum: target enum
    /// - Returns: decode initializer from string
    private func decodeInitializer(
        fromEnum enum: EnumSpecification
    ) -> String {
        let switchCases = decodeSwitchCases(fromEnum: `enum`)
        return """
        // MARK: - \(Constants.decodable)

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let key = container.allKeys.first
            switch key {
        \(switchCases.indent)
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Unabled to decode enum."
                    )
                )
            }
        }
        """
    }

    /// Encode function
    /// - Parameter enum: target enum
    /// - Returns: needed encode function from string
    private func encode(
        fromEnum enum: EnumSpecification
    ) -> String {
        let casesSequence =
            `enum`
                .cases
                .map { `case` -> String in
                    var strCase = ""
                    if `case`.arguments.count == 0 {
                        strCase = """
                        case .\(`case`.name):
                            try container.encode("\(`case`.name)", forKey: .\(`case`.name))
                        """
                    } else if `case`.arguments.count == 1 {
                        strCase = """
                        case .\(`case`.name)(let \(`case`.name)):
                            try container.encode(\(`case`.name), forKey: .\(`case`.name))
                        """
                    } else if `case`.arguments.count == 2 {
                        let firstName = makeVariableName(argument: `case`.arguments[0]) ?? "value1"
                        let secondName = makeVariableName(argument: `case`.arguments[1]) ?? "value2"
                        strCase = """
                        case let .\(`case`.name)( \(firstName), \(secondName)):
                            try container.encodeValues(\(firstName), \(secondName), for: .\(`case`.name))
                        """
                    } else {
                        var argumentNames: [String] = []
                        var count = 1
                        for argument in `case`.arguments {
                            argumentNames.append((makeVariableName(argument: argument) ?? "value\(count)").indent)
                            count += 1
                        }
                        strCase = """
                        case let .\(`case`.name)(
                        \(argumentNames.joined(separator: ",\n"))
                        ):
                            try container.encodeValues(
                        \(argumentNames.joined(separator: ",\n")),
                            for: .\(`case`.name)
                        )
                        """
                    }
                    return strCase
                }.joined(separator: "\n")
        return """
        // MARK: - \(Constants.encodable)

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
        \(casesSequence.indent)
            }
        }
        """
    }

    /// Need to make variable name
    /// - Parameter argument: current argument
    /// - Returns: variable name from string
    private func makeVariableName(argument: ArgumentSpecification) -> String? {
        var variableName: String? = ""
        if argument.bodyName != "" {
            variableName = argument.bodyName
        } else {
            variableName = nil
        }
        return variableName
    }

    /// Template of current enum
    /// - Parameter enum: target enum
    /// - Returns: template of current enum
    private func template(
        fromEnum enum: EnumSpecification
    ) -> String {
        return EnumSpecification.template(
            comment: `enum`.comment,
            accessibility: `enum`.accessibility,
            attributes: `enum`.attributes,
            name: `enum`.name,
            inheritedTypes: `enum`.inheritedTypes.filter {
                !`enum`.unnecessaryInheritedTypes.contains($0)
            },
            cases: `enum`.cases,
            properties: `enum`.properties,
            methods: `enum`.methods
        ).verse
    }
}

// MARK: - ImplementationComposer

extension CodexEnumsImplementationComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        guard let enumsFolder = parameters[.enums] else {
            throw CodexAutographError.noEnumsFolder
        }
        return specifications
            .targetEnums()
            .map { `enum` in
                let rawObject = template(fromEnum: `enum`)
                let headerSequence = headerComment(
                    fileName: `enum`.name,
                    projectName: parameters.projectName,
                    imports: `enum`.declaration.imports
                )
                let declaredSequence = declaration(fromEnum: `enum`, forSpecifications: specifications)
                let codingKeySequence = codingKeys(fromEnum: `enum`, forSpecifications: specifications)
                var codableTypeSequence = ""
                if specifications.isCodable(`enum`) {
                    codableTypeSequence = decodeInitializer(fromEnum: `enum`).indent + "\n\n" + encode(fromEnum: `enum`).indent
                } else if specifications.isDecodable(`enum`) {
                    codableTypeSequence = decodeInitializer(fromEnum: `enum`).indent
                } else if specifications.isEncodable(`enum`) {
                    codableTypeSequence = encode(fromEnum: `enum`).indent
                }
                let sourceCode = """
                    \(headerSequence)
                    \(rawObject)
                    \(declaredSequence)
                    \(codingKeySequence)
                    \(codableTypeSequence)
                    }
                    """
                return AutographImplementation(
                    filePath: "\(enumsFolder)/\(`enum`.name).swift",
                    sourceCode: sourceCode
                )
            }
    }
}

