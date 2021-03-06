//
//  CodexAutographError.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 28.03.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - CodexAutographError

public enum CodexAutographError {

    // MARK: - Cases

    /// You haven't specified a path to plain objects
    case noPlainsFolder

    /// You haven't specified a path to enum objects
    case noEnumsFolder

    /// You haven't specified a path to any objects
    case noFolders

    /// You heven't specefied a project name of needed project
    case noProjectName
}

// MARK: - LocalizedError

extension CodexAutographError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .noPlainsFolder:
            return "You haven't specified a path to plain objects"
        case .noEnumsFolder:
            return "You haven't specified a path to enum objects"
        case .noFolders:
            return "You haven't specified a path to any objects"
        case .noProjectName:
            return "You heven't specefied a project name of needed project"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension CodexAutographError: CustomDebugStringConvertible {

    public var debugDescription: String {
        errorDescription ?? ""
    }
}
