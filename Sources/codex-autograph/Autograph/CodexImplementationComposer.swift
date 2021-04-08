//
//  CodexImplementationComposer.swift
//  codex-autograph
//  
//
//  Created by Alexander Lezya on 28.03.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph
import Foundation

// MARK: - CodexImplementationComposer

public final class CodexImplementationComposer {

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
    /// - Parameter structure: target structure
    /// - Returns: imports from string
    private func imports(
        fromStructure structure: StructureSpecification
    ) -> [String] {
        var imports = structure.declaration.imports
        if !imports.contains("Codex") {
            imports.append("Codex")
        }
        return imports.filter { $0 != "Foundation" }
    }

    /// Declaration
    /// - Parameters:
    ///   - structure: target structure
    ///   - specifications: Specifications instance
    /// - Returns: declaration from string
    private func declaration(
        fromStructure structure: StructureSpecification,
        forSpecifications specifications: Specifications
    ) -> String {
        let inheritedType = specifications
            .consolidatedStructures[structure]?
            .first { $0.isCodexAppropriate }
            .flatMap(\.codexType) ?? structure.codexType.unwrap()
        return """
        // MARK: - \(inheritedType)

        extension \(structure.name): \(inheritedType) {

        """
    }

    /// Formatter instances
    /// - Parameter structure: target structure
    /// - Returns: formatter instances from string
    private func formatterInstances(
        fromStructure structure: StructureSpecification
    ) -> String {
        let formattersInstance = structure
            .properties
            .filter { $0.annotations.contains(annotationName: Constants.formatArgument) }
            .map { property -> String in
                let formatter = property.annotations[Constants.formatArgument]?.value ?? ""
                if formatter == Constants.iso {
                    return "let isoFormatter = ISO8601DateFormatter()".indent
                } else if formatter == Constants.ms {
                    return "let \(formatter)Transformer = UnixTransformer(unit: .milliseconds)".indent
                } else if formatter == Constants.seconds {
                    return "let \(formatter)Transformer = UnixTransformer(unit: .seconds)".indent
                } else {
                    if formatter.contains("#") {
                        let typeFormatWithName = formatter.components(separatedBy: "#")
                        guard let name = typeFormatWithName.last else { return "" }
                        return "let \(name)Formatter = \(structure.name).make\(name.uppercasedFirstChar())Formatter()".indent
                    } else {
                        return "let \(property.name)Formatter = \(structure.name).make\(property.name.uppercasedFirstChar())Formatter()".indent
                    }
                }
            }
        return Set(formattersInstance).joined(separator: "\n") + "\n"
    }

    /// Decode initializer
    /// - Parameter structure: target structure
    /// - Returns: decode initializer from string
    private func decodeInitializer(
        fromStructure structure: StructureSpecification
    ) -> String {
        var propertiesSequence = formatterInstances(fromStructure: structure)
        propertiesSequence
            .append(
                structure
                    .properties
                    .filter { $0.annotations.contains(annotationName: Constants.jsonArgument) }
                    .map { property in
                        let decodeName = property.annotations[Constants.jsonArgument]?.value ?? property.name
                        let formatterName = property.annotations[Constants.formatArgument]?.value ?? ""
                        switch property.type {
                        case .date:
                            if formatterName == Constants.iso {
                                return "\(property.name) = try decoder.decode(\"\(decodeName)\", using: isoFormatter)".indent
                            } else if formatterName == Constants.ms {
                                return "\(property.name) = try decoder.decode(\"\(decodeName)\", transformedBy: msTransformer)".indent
                            } else if formatterName == Constants.seconds {
                                return "\(property.name) = try decoder.decode(\"\(decodeName)\", transformedBy: secondsTransformer)".indent
                            } else {
                                if formatterName.contains("#") {
                                    guard let lastName = formatterName.components(separatedBy: "#").last else { return "" }
                                    return "\(property.name) = try decoder.decode(\"\(decodeName)\", using: \(lastName)Formatter)".indent
                                } else {
                                    return "\(property.name) = try decoder.decode(\"\(decodeName)\", using: \(property.name)Formatter)".indent
                                }
                            }
                        case .optional(wrapped: .array):
                            return "\(property.name) = try decoder.decodeIfPresent(\"\(decodeName)\")".indent
                        case .optional:
                            return "\(property.name) = try decoder.decodeIfPresent(\"\(decodeName)\")".indent
                        default:
                            return "\(property.name) = try decoder.decode(\"\(decodeName)\")".indent
                        }
                    }.joined(separator: "\n")
            )
        return """
        // MARK: - \(Constants.decodable)

        init(from decoder: Decoder) throws {
        \(propertiesSequence)
        }
        """
    }

    /// Date formatter function
    /// - Parameter structure: target structure
    /// - Returns: date formatter function from string
    private func dateFormatter(
        fromStructure structure: StructureSpecification
    ) -> String {
        let makeFormatterSequence = structure
            .properties
            .filter {
                let value = $0.annotations[Constants.formatArgument]?.value
                return value != Constants.iso
                    && value != Constants.seconds
                    && value != Constants.ms
                    && $0.annotations.contains(annotationName: Constants.formatArgument)
            }
            .compactMap { property -> String? in
                guard let typeFormatWithName = property.annotations[Constants.formatArgument]?.value?.components(separatedBy: "#")
                else { return nil }
                var formatterName = ""
                if typeFormatWithName.count == 2 {
                    formatterName = (typeFormatWithName.last ?? "").uppercasedFirstChar()
                } else {
                    formatterName = property.name.uppercasedFirstChar()
                }
                return """
                static func make\(formatterName)Formatter() -> DateFormatter {
                    let formatter = DateFormatter()
                    formatter.dateFormat = \"\(typeFormatWithName.first.unwrap())\"
                    return formatter
                }

                """
            }
        var finalSequence = [String]()
        if !makeFormatterSequence.isEmpty {
            finalSequence = ["// MARK: - Formatters\n"]
            finalSequence.append(contentsOf: Array(Set(makeFormatterSequence)))
        }
        return finalSequence.map(\.indent).joined(separator: "\n")
    }

    /// Encode function
    /// - Parameter structure: target structure
    /// - Returns: needed encode function from string
    private func encode(
        fromStructure structure: StructureSpecification
    ) -> String {
        var propertySequence = formatterInstances(fromStructure: structure)
        propertySequence.append(
            structure
                .properties
                .filter { $0.annotations.contains(annotationName: Constants.jsonArgument) }
                .compactMap { property -> String? in
                    let encodeName = property.annotations[Constants.jsonArgument]?.value ?? property.name
                    let formatterName = property.annotations[Constants.formatArgument]?.value ?? ""
                    switch property.type {
                    case .date:
                        if formatterName == Constants.iso {
                            return "try encoder.encode(\(property.name), for: \"\(encodeName)\", using: isoFormatter)".indent
                        } else if formatterName == Constants.ms {
                            return "try encoder.encode(\(property.name), for: \"\(encodeName)\", transformedBy: msTransformer)".indent
                        } else if formatterName == Constants.seconds {
                            return "try encoder.encode(\(property.name), for: \"\(encodeName)\", transformedBy: secondsTransformer)".indent
                        } else {
                            if formatterName.contains("#") {
                                guard let lastName = formatterName.components(separatedBy: "#").last else { return nil }
                                return "try encoder.encode(\(property.name), for: \"\(encodeName)\", using: \(lastName)Formatter)".indent
                            } else {
                                return "try encoder.encode(\(property.name), for: \"\(encodeName)\", using: \(property.name)Formatter)".indent
                            }
                        }
                    default:
                        return "try encoder.encode(\(property.name), for: \"\(encodeName)\")".indent
                    }
                }.joined(separator: "\n")
        )
        return """
        // MARK: - \(Constants.encodable)

        func encode(to encoder: Encoder) throws {
        \(propertySequence)
        }
        """
    }

    /// Template of current structure
    /// - Parameter structure: target structure
    /// - Returns: template of current structure
    private func template(
        fromStructure structure: StructureSpecification
    ) -> String {
        return StructureSpecification.template(
            comment: structure.comment,
            accessibility: structure.accessibility,
            attributes: structure.attributes,
            name: structure.name,
            inheritedTypes: structure.inheritedTypes.filter {
                !structure.unnecessaryInheritedTypes.contains($0)
            },
            properties: structure.properties,
            methods: structure.methods
        ).verse
    }
}

// MARK: - ImplementationComposer

extension CodexImplementationComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        guard let plainsFolder = parameters[.plains] else {
            throw CodexAutographError.noPlainsFolder
        }
        return specifications
            .targetStructures()
            .map { structure in
                let rawObject = template(fromStructure: structure)
                let headerSequence = headerComment(
                    fileName: structure.name,
                    projectName: parameters.projectName,
                    imports: imports(fromStructure: structure)
                )
                let declaredSequence = declaration(fromStructure: structure, forSpecifications: specifications)
                var decodeInitializerCode = ""
                var encodeSequence = ""
                let dateFormatterSequence = dateFormatter(fromStructure: structure)
                if specifications.isCodable(structure) {
                    decodeInitializerCode = decodeInitializer(fromStructure: structure).indent + "\n"
                    encodeSequence = encode(fromStructure: structure).indent
                } else if specifications.isDecodable(structure) {
                    decodeInitializerCode = decodeInitializer(fromStructure: structure).indent
                } else if specifications.isEncodable(structure) {
                    encodeSequence = encode(fromStructure: structure).indent
                }
                var sourceCode = ""
                if dateFormatterSequence != "" {
                    sourceCode = """
                    \(headerSequence)
                    \(rawObject)
                    \(declaredSequence)
                    \(dateFormatterSequence)
                    \(decodeInitializerCode)
                    \(encodeSequence)
                    }
                    """
                } else {
                    sourceCode = """
                    \(headerSequence)
                    \(rawObject)
                    \(declaredSequence)
                    \(decodeInitializerCode)
                    \(encodeSequence)
                    }
                    """
                }
                return AutographImplementation(
                    filePath: "\(plainsFolder)/\(structure.name).swift",
                    sourceCode: sourceCode
                )
            }
    }
}
