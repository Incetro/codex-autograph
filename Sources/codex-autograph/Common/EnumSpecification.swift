//
//  EnumSpecification.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 28.03.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis

// MARK: - EnumSpecification

extension EnumSpecification {

    var unnecessaryInheritedTypes: [String] {
        [Constants.codable, Constants.decodable, Constants.encodable]
    }

    var codexType: String? {
        if isCodable {
            return Constants.codable
        } else if isDecodable {
            return Constants.decodable
        } else if isEncodable {
            return Constants.encodable
        }
        return nil
    }

    var isCodexAppropriate: Bool {
        isCodable || isDecodable || isEncodable
    }

    var isCodable: Bool {
        inheritedTypes.contains(Constants.codable)
    }

    var isDecodable: Bool {
        inheritedTypes.contains(Constants.decodable)
    }

    var isEncodable: Bool {
        inheritedTypes.contains(Constants.encodable)
    }
}
