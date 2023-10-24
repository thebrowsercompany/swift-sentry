// SPDX-License-Identifier: BSD-3-Clause

struct BreadcrumbNestedSerialization: Codable {
    struct BreadcrumbDataTest: Codable {
        let foo: Bool
        let fooList: [String]
    }

    let category: String
    let level: String
    let data: BreadcrumbDataTest
}

struct BreadcrumbNestedLists: Codable {
    struct BreadcrumbDataTest: Codable {
        let nested: [[String]]
    }

    let category: String
    let level: String
    let data: BreadcrumbDataTest
}

struct BreadcrumbNestedObject: Codable {
    struct BreadcrumbDataTest: Codable {
        let nested: [String: [String: [[Int]]]]
    }

    let category: String
    let level: String
    let data: BreadcrumbDataTest
}
