//
//  Model.swift
//  PaginationWithThread
//
//  Created by Arpit iOS Dev. on 28/06/24.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let count, totalCount, page, totalPages: Int
    let lastItemIndex: Int
    let results: [QuoteResult]
}

// MARK: - QuoteResult
struct QuoteResult: Codable {
    let id: String
    let author: String
    let content: String
    let tags: [String]
    let authorSlug: String
    let length: Int
    let dateAdded, dateModified: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case author, content, tags, authorSlug, length, dateAdded, dateModified
    }
}
