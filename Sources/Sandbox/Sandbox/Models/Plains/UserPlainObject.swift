//
//  UserPlainObject.swift
//  Sandbox
//
//  Created by Alexander Lezya on 01.04.2021.
//

import Foundation

// MARK: - UserPlainObject

struct UserPlainObject: Codable {

    // MARK: - Properties

    /// User's first name
    /// @json first_name
    let firstName: String

    /// User's last name
    /// @json last_name
    let lastName: String

    /// User's favorite book
    /// @json
    let favoriteBooks: [BookPlainObject]

    /// User's email
    /// @json
    let email: String?

    /// User's gender
    /// @json
    let gender: String

    /// User's phones
    /// @json
    let phones: [String]

    /// User's register date
    /// @json register_date
    /// @format seconds
    let registerDate: Date

    /// User's birthday
    /// @json
    /// @format yyyy-MM-dd
    let birthday: Date
}
