// SPDX-License-Identifier: BSD-3-Clause
@testable import SwiftSentry
import XCTest

final class BreadcrumbTests: XCTestCase {
    func testBreadCrumbSerializesCorrectly() throws {
        let crumb = Breadcrumb(withLevel: .debug, category: "http")
        let serialized = crumb.serialized()
        XCTAssertTrue(sentry_value_is_null(serialized) == 1)
    }

    func testBreadcrumbDefaultInitializer() throws {
        let crumb = Breadcrumb()
        XCTAssertEqual(crumb.level, SentryLevel.info, "Default level should be info.")
        XCTAssertEqual(crumb.category, "default", "Default category should be 'default'.")
    }

    func testNestedDataSerializedCorrectly() throws {
        var crumb = Breadcrumb(withLevel: .debug, category: "http")
        crumb.message = "hi"

        crumb.data = [
            "foo": true,
            "fooList": ["l1", "l1", "l3"],
            "fooListDict": ["one", [
                "cool": false
            ]],
            "fooDict": [
                "dk1": "dv1",
                "dv2": [
                    "dvn1": [Int32(1), Int32(2), Int32(3), Int32(4)]
                ]
            ],
            "fooListNested": [Int32(8), [Int32(9), Int32(10)]],
            "nullValue": NSNull()
        ]

        let json = try JSONDecoder().decode(BreadcrumbNestedSerialization.self, from:crumb.jsonData())

        XCTAssertTrue(json.data.fooList.count == 3, "There should be three items set")
        XCTAssertTrue(json.data.foo, "This should be true")
    }

    func testNestedListsSerializeCorrectly() throws {
        var crumb = Breadcrumb(withLevel: .debug, category: "http")
        crumb.message = "hi"

        crumb.data = [
            "nested": [["test"], ["test"], ["test"]]
        ]

        let json = try JSONDecoder().decode(BreadcrumbNestedLists.self, from: crumb.jsonData())

        XCTAssertTrue(json.data.nested.count == 3, "There should be 3 sub-elements")
        for item in json.data.nested {
            XCTAssertEqual(item[0], "test", "The inner-most value should be equal to 'test'")
        }
    }

    func testNestedDictionariesSerializeCorrectly() throws {
        var crumb = Breadcrumb(withLevel: .debug, category: "http")
        crumb.message = "hi"

        crumb.data = [
            "nested": [
                "cool": [
                    "values": [
                        [Int32(1)], [Int32(1)], [Int32(1)]
                    ]
                ]
            ]
        ]

        let json = try JSONDecoder().decode(BreadcrumbNestedObject.self, from: crumb.jsonData())
        let inner = try XCTUnwrap(json.data.nested["cool"]?["values"])
        for item in inner {
            XCTAssertEqual(item[0], 1, "The inner-most value should be equal to 1")
        }
    }
}
