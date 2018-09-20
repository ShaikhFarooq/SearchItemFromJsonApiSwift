//
//  Person.swift
//  Task
//
//  Created by Admin on 9/17/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation

struct ItemModel: Codable {
    let query: Query?
}

struct Query: Codable {
    let pages: [Page]?
}

struct Page: Codable {
    let title: String?
    let pageid: Int?
    let thumbnail: Thumbnail?
    let terms: Terms?
}

struct Thumbnail: Codable {
    let source: String
    let width: Int
    let height: Int
}

struct Terms: Codable {
    let description: [String]?
}
