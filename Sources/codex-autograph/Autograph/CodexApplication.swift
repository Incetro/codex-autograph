//
//  CodexApplication.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 28.03.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Autograph

// MARK: - CodexApplication

final class CodexApplication: AutographApplication<CodexImplementationComposer, CodexInputFoldersProvider> {

    override func printHelp() {
        super.printHelp()
        print(
            """

            -plains <directory>
            Path to the folder, where plain objects to be processed are stored.
            If not set, current working directory is used by default.
            """
        )
    }
}
