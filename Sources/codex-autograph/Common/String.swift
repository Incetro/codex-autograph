//
//  String.swift
//  codex-autograph
//
//
//  Created by Alexander Lezya on 28.03.2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - String

extension String {

    func uppercasedFirstChar() -> Self {
        prefix(1).capitalized + dropFirst()
    }
}
