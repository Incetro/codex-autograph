//
//  CodexInputFoldersProvider.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 28.03.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Autograph

// MARK: - CodexInputFoldersProvider

public final class CodexInputFoldersProvider {

    public init() {
    }
}

// MARK: - InputFoldersProvider

extension CodexInputFoldersProvider: InputFoldersProvider {

    public func inputFoldersList(fromParameters parameters: AutographExecutionParameters) throws -> [String] {
        var inputFolders: [String] = []
        if let plainsFolder = parameters[.plains] {
            inputFolders.append(plainsFolder)
        }
        if let enumsFolder = parameters[.enums] {
            inputFolders.append(enumsFolder)
        }
        if inputFolders.isEmpty {
            throw CodexAutographError.noFolders
        }
        return inputFolders
    }
}

