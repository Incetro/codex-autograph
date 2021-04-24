//
//  CodexImplementationComposer.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 16.04.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - CodexImplementationComposer

public final class CodexImplementationComposer {

    public init() {
    }
}

// MARK: - ImplementationComposer

extension CodexImplementationComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        let structModels = try CodexStructuresImplementationComposer()
            .compose(forSpecifications: specifications, parameters: parameters)
        let enumModels = try CodexEnumsImplementationComposer()
            .compose(forSpecifications: specifications, parameters: parameters)
        let helper = try CodeKeyedContainerImplementationComposer()
            .compose(forSpecifications: specifications, parameters: parameters)
        return structModels + enumModels + helper
    }
}
