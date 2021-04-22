//
//  CodexAutographExecutionParameters.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 28.03.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Autograph
import Foundation

// MARK: - CodexAutographExecutionParameters

public enum CodexAutographExecutionParameters: String {

    /// Plain objects folder
    case plains = "-plains"

    /// Enum objects folder
    case enums = "-enums"
}

// MARK: - ExecutionParameters
public extension AutographExecutionParameters {

    subscript(_ parameter: CodexAutographExecutionParameters) -> String? {
        self[parameter.rawValue]
    }
}
