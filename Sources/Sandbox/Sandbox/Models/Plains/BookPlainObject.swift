//
//  BookPlainObject.swift
//  Sandbox
//
//  Created by Alexander Lezya on 31.03.2021.
//

import Foundation

// MARK: - BookPlainObject

struct BookPlainObject: Codable {

    // MARK: - Properties

    /// Book's unique identifier
    /// @json
    let id: Int

    /// Book's name
    /// @json first_name
    let firstName: String

    /// Book's author
    /// @json
    let author: String

    /// Book's release date
    /// @json
    /// @format yyyy-MM-dd#customName
    let release: Date
}
