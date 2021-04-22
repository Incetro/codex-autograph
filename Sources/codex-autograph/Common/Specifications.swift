//
//  Specifications.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 28.03.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis

// MARK: - Specifications

extension Specifications {

    // MARK: - Structures

    func isCodable(_ structure: StructureSpecification) -> Bool {
        structure.isCodable || consolidatedStructures[structure]?.filter(\.isCodable).isEmpty == false
    }

    func isEncodable(_ structure: StructureSpecification) -> Bool {
        structure.isEncodable || consolidatedStructures[structure]?.filter(\.isEncodable).isEmpty == false
    }

    func isDecodable(_ structure: StructureSpecification) -> Bool {
        structure.isDecodable || consolidatedStructures[structure]?.filter(\.isDecodable).isEmpty == false
    }

    func targetStructures() -> [StructureSpecification] {
        structures.filter {
            $0.isCodexAppropriate || (consolidatedStructures[$0]?.filter(\.isCodexAppropriate).isEmpty == false)
        }
    }

    // MARK: - Enums

    func isCodable(_ enum: EnumSpecification) -> Bool {
        `enum`.isCodable || consolidatedEnums[`enum`]?.filter(\.isCodable).isEmpty == false
    }

    func isEncodable(_ enum: EnumSpecification) -> Bool {
        `enum`.isEncodable || consolidatedEnums[`enum`]?.filter(\.isEncodable).isEmpty == false
    }

    func isDecodable(_ enum: EnumSpecification) -> Bool {
        `enum`.isDecodable || consolidatedEnums[`enum`]?.filter(\.isDecodable).isEmpty == false
    }

    func targetEnums() -> [EnumSpecification] {
        enums.filter {
            $0.isCodexAppropriate || (consolidatedEnums[$0]?.filter(\.isCodexAppropriate).isEmpty == false)
        }
    }
}
