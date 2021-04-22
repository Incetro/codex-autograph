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
    public func headerComment(
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

    /// Imports
    /// - Parameter enum: target enum
    /// - Returns: imports from string
    private func imports(
        fromEnum enum: EnumSpecification
    ) -> [String] {
        var imports = `enum`.declaration.imports
        if !imports.contains("Codex") {
            imports.append("Codex")
        }
        return imports.filter { $0 != "Foundation" }
    }

    /// Declaration
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

    /// Coding keys enum
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
            \(casesSequence)
        }
        """
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
                    strCase = """
                    case .\(`case`.name):
                        self = .\(`case`.name)(try container.decode(\(`case`.arguments[0].type).self, forKey: .\(`case`.name))
                    """
                } else if `case`.arguments.count == 2 {
                    let firstName = makeVariableName(argument: `case`.arguments[0])
                    let secondName = makeVariableName(argument: `case`.arguments[1])
                    if let firstName = firstName, let secondName = secondName {
                        strCase = """
                        case .\(`case`.name):
                            let (\(firstName), \(secondName)): (\(`case`.arguments[0].type), \(`case`.arguments[1].type)) = try container.decodeValues(for: .\(`case`.name)
                            self = .\(`case`.name)(\(firstName): \(firstName), \(secondName): \(secondName))
                        """
                    } else {
                        strCase = """
                        case .\(`case`.name):
                            let (value1, value2): (\(`case`.arguments[0].type), \(`case`.arguments[1].type)) = try container.decodeValues(for: .\(`case`.name)
                            self = .\(`case`.name)(value1, value2)
                        """
                    }
                } else if `case`.arguments.count == 3 {
                    let firstName = makeVariableName(argument: `case`.arguments[0])
                    let secondName = makeVariableName(argument: `case`.arguments[1])
                    let thirdName = makeVariableName(argument: `case`.arguments[2])
                    if let firstName = firstName, let secondName = secondName, let thirdName = thirdName {
                        strCase = """
                        case .\(`case`.name):
                            let (
                                \(firstName),
                                \(secondName),
                                \(thirdName)
                            ): (
                                \(`case`.arguments[0].type),
                                \(`case`.arguments[1].type),
                                \(`case`.arguments[2].type)
                            ) = try container.decodeValues(for: .\(`case`.name)
                            self = .\(`case`.name)(
                                \(firstName): \(firstName),
                                \(secondName): \(secondName),
                                \(thirdName): \(thirdName)
                            )
                        """
                    } else {
                        strCase = """
                        case .\(`case`.name):
                            let (
                                value1,
                                value2,
                                value3
                            ): (
                                \(`case`.arguments[0].type),
                                \(`case`.arguments[1].type),
                                \(`case`.arguments[2].type)
                            ) = try container.decodeValues(for: .\(`case`.name)
                            self = .\(`case`.name)(value1, value2, value3)
                        """
                    }
                } else if `case`.arguments.count == 4 {
                    let firstName = makeVariableName(argument: `case`.arguments[0])
                    let secondName = makeVariableName(argument: `case`.arguments[1])
                    let thirdName = makeVariableName(argument: `case`.arguments[2])
                    let fourthName = makeVariableName(argument: `case`.arguments[3])
                    if let firstName = firstName,
                       let secondName = secondName,
                       let thirdName = thirdName,
                       let fourthName = fourthName
                    {
                        strCase = """
                        case .\(`case`.name):
                            let (
                                \(firstName),
                                \(secondName),
                                \(thirdName),
                                \(fourthName)
                            ): (
                                \(`case`.arguments[0].type),
                                \(`case`.arguments[1].type),
                                \(`case`.arguments[2].type),
                                \(`case`.arguments[3].type)
                            ) = try container.decodeValues(for: .\(`case`.name)
                            self = .\(`case`.name)(
                                \(firstName): \(firstName),
                                \(secondName): \(secondName),
                                \(thirdName): \(thirdName),
                                \(fourthName): \(fourthName)
                            )
                        """
                    } else {
                        strCase = """
                        case .\(`case`.name):
                            let (
                                value1,
                                value2,
                                value3,
                                value4
                            ): (
                                \(`case`.arguments[0].type),
                                \(`case`.arguments[1].type),
                                \(`case`.arguments[2].type),
                                \(`case`.arguments[3].type)
                            ) = try container.decodeValues(for: .\(`case`.name)
                            self = .\(`case`.name)(value1, value2, value3, value4)
                        """
                    }
                } else if `case`.arguments.count == 5 {
                    let firstName = makeVariableName(argument: `case`.arguments[0])
                    let secondName = makeVariableName(argument: `case`.arguments[1])
                    let thirdName = makeVariableName(argument: `case`.arguments[2])
                    let fourthName = makeVariableName(argument: `case`.arguments[3])
                    let fifthName = makeVariableName(argument: `case`.arguments[4])
                    if let firstName = firstName,
                       let secondName = secondName,
                       let thirdName = thirdName,
                       let fourthName = fourthName,
                       let fifthName = fifthName
                    {
                        strCase = """
                        case .\(`case`.name):
                            let (
                                \(firstName),
                                \(secondName),
                                \(thirdName),
                                \(fourthName),
                                \(fifthName)
                            ): (
                                \(`case`.arguments[0].type),
                                \(`case`.arguments[1].type),
                                \(`case`.arguments[2].type),
                                \(`case`.arguments[3].type),
                                \(`case`.arguments[4].type)
                            ) = try container.decodeValues(for: .\(`case`.name)
                            self = .\(`case`.name)(
                                \(firstName): \(firstName),
                                \(secondName): \(secondName),
                                \(thirdName): \(thirdName),
                                \(fourthName): \(fourthName),
                                \(fifthName): \(fifthName)
                            )
                        """
                    } else {
                        strCase = """
                        case .\(`case`.name):
                            let (
                                value1,
                                value2,
                                value3,
                                value4,
                                value5
                            ): (
                                \(`case`.arguments[0].type),
                                \(`case`.arguments[1].type),
                                \(`case`.arguments[2].type),
                                \(`case`.arguments[3].type),
                                \(`case`.arguments[4].type)
                            ) = try container.decodeValues(for: .\(`case`.name)
                            self = .\(`case`.name)(value1, value2, value3, value4, value5)
                        """
                    }
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
            \(switchCases)
            default:
                throw DecodingError.valueNotFound(
                    Self.self,
                    DecodingError.Context(codingPath: CodingKeys.allCases, debugDescription: "\(`enum`.name)/not found")
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
                        case .\(`case`.name)(let \(firstName), let \(secondName)):
                            try container.encodeValues(\(firstName), \(secondName), for: .\(`case`.name))
                        """
                    } else if `case`.arguments.count == 3 {
                        let firstName = makeVariableName(argument: `case`.arguments[0]) ?? "value1"
                        let secondName = makeVariableName(argument: `case`.arguments[1]) ?? "value2"
                        let thirdName = makeVariableName(argument: `case`.arguments[2]) ?? "value3"
                        strCase = """
                        case .\(`case`.name)(
                            let \(firstName),
                            let \(secondName),
                            let \(thirdName)
                        ):
                            try container.encodeValues(
                                \(firstName),
                                \(secondName),
                                \(thirdName)
                                for: .\(`case`.name)
                            )
                        """
                    } else if `case`.arguments.count == 4 {
                        let firstName = makeVariableName(argument: `case`.arguments[0]) ?? "value1"
                        let secondName = makeVariableName(argument: `case`.arguments[1]) ?? "value2"
                        let thirdName = makeVariableName(argument: `case`.arguments[2]) ?? "value3"
                        let fourthName = makeVariableName(argument: `case`.arguments[3]) ?? "value4"
                        strCase = """
                        case .\(`case`.name)(
                            let \(firstName),
                            let \(secondName),
                            let \(thirdName),
                            let \(fourthName)
                        ):
                            try container.encodeValues(
                                \(firstName),
                                \(secondName),
                                \(thirdName),
                                \(fourthName)
                                for: .\(`case`.name)
                            )
                        """
                    } else if `case`.arguments.count == 5 {
                        let firstName = makeVariableName(argument: `case`.arguments[0]) ?? "value1"
                        let secondName = makeVariableName(argument: `case`.arguments[1]) ?? "value2"
                        let thirdName = makeVariableName(argument: `case`.arguments[2]) ?? "value3"
                        let fourthName = makeVariableName(argument: `case`.arguments[3]) ?? "value4"
                        let fifthName = makeVariableName(argument: `case`.arguments[4]) ?? "value5"
                        strCase = """
                        case .\(`case`.name)(
                            let \(firstName),
                            let \(secondName),
                            let \(thirdName),
                            let \(fourthName),
                            let \(fifthName)
                        ):
                            try container.encodeValues(
                                \(firstName),
                                \(secondName),
                                \(thirdName),
                                \(fourthName),
                                \(fifthName)
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
            \(casesSequence)
            }
        }
        """
    }

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
                    imports: imports(fromEnum: `enum`)
                )
                let declaredSequence = declaration(fromEnum: `enum`, forSpecifications: specifications)
                let codingKeySequence = codingKeys(fromEnum: `enum`, forSpecifications: specifications)
                var decodeInitializerCode = ""
                var encodeSequence = ""
                if specifications.isCodable(`enum`) {
                    decodeInitializerCode = decodeInitializer(fromEnum: `enum`).indent + "\n"
                    encodeSequence = encode(fromEnum: `enum`).indent
                } else if specifications.isDecodable(`enum`) {
                    decodeInitializerCode = decodeInitializer(fromEnum: `enum`).indent
                } else if specifications.isEncodable(`enum`) {
                    encodeSequence = encode(fromEnum: `enum`).indent
                }
                let sourceCode = """
                    \(headerSequence)
                    \(rawObject)
                    \(declaredSequence)
                    \(codingKeySequence)
                    \(decodeInitializerCode)
                    \(encodeSequence)
                    }
                    """
                return AutographImplementation(
                    filePath: "\(enumsFolder)/\(`enum`.name).swift",
                    sourceCode: sourceCode
                )
            }
    }
}

