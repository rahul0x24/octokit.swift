//
//  TagsTests.swift
//  OctoKitTests
//
//  Created by Claude on 01/01/2024.
//  Copyright © 2024 nerdish by nature. All rights reserved.
//

import OctoKit
import XCTest

final class TagsTests: XCTestCase {
    // MARK: Actual Request tests

    func testListTags() {
        let session = OctoKitURLTestSession(
            expectedURL: "https://api.github.com/repos/octocat/Hello-World/tags?page=1&per_page=30",
            expectedHTTPMethod: "GET",
            jsonFile: "Fixtures/tags",
            statusCode: 200)
        let task = Octokit(session: session).listTags(
            owner: "octocat",
            repository: "Hello-World"
        ) {
            switch $0 {
            case let .success(tags):
                XCTAssertEqual(tags.count, 2)
                if let tag = tags.first {
                    XCTAssertEqual(tag.name, "v1.0.0")
                    XCTAssertEqual(tag.commit.sha, "c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc")
                    XCTAssertEqual(
                        tag.zipballURL.absoluteString,
                        "https://api.github.com/repos/octocat/Hello-World/zipball/v1.0.0")
                    XCTAssertEqual(
                        tag.tarballURL.absoluteString,
                        "https://api.github.com/repos/octocat/Hello-World/tarball/v1.0.0")
                } else {
                    XCTFail("Failed to unwrap `tags.first`")
                }
                if let tag = tags.last {
                    XCTAssertEqual(tag.name, "v0.9.0")
                    XCTAssertEqual(tag.commit.sha, "a84d88e7554fc1fa21bcbc4efae3c782a70d2b9d")
                    XCTAssertEqual(
                        tag.zipballURL.absoluteString,
                        "https://api.github.com/repos/octocat/Hello-World/zipball/v0.9.0")
                    XCTAssertEqual(
                        tag.tarballURL.absoluteString,
                        "https://api.github.com/repos/octocat/Hello-World/tarball/v0.9.0")
                } else {
                    XCTFail("Failed to unwrap `tags.last`")
                }
            case let .failure(error):
                XCTFail("Endpoint failed with error \(error)")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testListTagsCustomLimit() {
        let perPage = (0...50).randomElement()!
        let session = OctoKitURLTestSession(
            expectedURL:
                "https://api.github.com/repos/octocat/Hello-World/tags?page=1&per_page=\(perPage)",
            expectedHTTPMethod: "GET",
            jsonFile: "Fixtures/tags",
            statusCode: 200)
        let task = Octokit(session: session).listTags(
            owner: "octocat",
            repository: "Hello-World",
            perPage: perPage
        ) {
            switch $0 {
            case .success:
                break
            case let .failure(error):
                XCTAssert(false, "Endpoint failed with error \(error)")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testListTagsWithPagination() {
        let page = 2
        let perPage = 10
        let session = OctoKitURLTestSession(
            expectedURL:
                "https://api.github.com/repos/octocat/Hello-World/tags?page=\(page)&per_page=\(perPage)",
            expectedHTTPMethod: "GET",
            jsonFile: "Fixtures/tags",
            statusCode: 200)
        let task = Octokit(session: session).listTags(
            owner: "octocat",
            repository: "Hello-World",
            page: page,
            perPage: perPage
        ) {
            switch $0 {
            case .success:
                break
            case let .failure(error):
                XCTAssert(false, "Endpoint failed with error \(error)")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    #if compiler(>=5.5.2) && canImport(_Concurrency)
        @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        func testListTagsAsync() async throws {
            let session = OctoKitURLTestSession(
                expectedURL:
                    "https://api.github.com/repos/octocat/Hello-World/tags?page=1&per_page=30",
                expectedHTTPMethod: "GET",
                jsonFile: "Fixtures/tags",
                statusCode: 200)
            let tags = try await Octokit(session: session).listTags(
                owner: "octocat",
                repository: "Hello-World"
            )
            XCTAssertEqual(tags.count, 2)
            if let tag = tags.first {
                XCTAssertEqual(tag.name, "v1.0.0")
                XCTAssertEqual(tag.commit.sha, "c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc")
                XCTAssertEqual(
                    tag.zipballURL.absoluteString,
                    "https://api.github.com/repos/octocat/Hello-World/zipball/v1.0.0")
                XCTAssertEqual(
                    tag.tarballURL.absoluteString,
                    "https://api.github.com/repos/octocat/Hello-World/tarball/v1.0.0")
            } else {
                XCTFail("Failed to unwrap `tags.first`")
            }
            if let tag = tags.last {
                XCTAssertEqual(tag.name, "v0.9.0")
                XCTAssertEqual(tag.commit.sha, "a84d88e7554fc1fa21bcbc4efae3c782a70d2b9d")
                XCTAssertEqual(
                    tag.zipballURL.absoluteString,
                    "https://api.github.com/repos/octocat/Hello-World/zipball/v0.9.0")
                XCTAssertEqual(
                    tag.tarballURL.absoluteString,
                    "https://api.github.com/repos/octocat/Hello-World/tarball/v0.9.0")
            } else {
                XCTFail("Failed to unwrap `tags.last`")
            }
            XCTAssertTrue(session.wasCalled)
        }

        @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        func testListTagsAsyncWithPagination() async throws {
            let page = 2
            let perPage = 10
            let session = OctoKitURLTestSession(
                expectedURL:
                    "https://api.github.com/repos/octocat/Hello-World/tags?page=\(page)&per_page=\(perPage)",
                expectedHTTPMethod: "GET",
                jsonFile: "Fixtures/tags",
                statusCode: 200)
            let tags = try await Octokit(session: session).listTags(
                owner: "octocat",
                repository: "Hello-World",
                page: page,
                perPage: perPage
            )
            XCTAssertEqual(tags.count, 2)
            XCTAssertTrue(session.wasCalled)
        }
    #endif

    func testGetTag() {
        let session = OctoKitURLTestSession(
            expectedURL: "https://api.github.com/repos/octocat/Hello-World/git/refs/tags/v1.0.0",
            expectedHTTPMethod: "GET",
            jsonFile: "Fixtures/tag",
            statusCode: 200)
        let task = Octokit(session: session).getTag(
            owner: "octocat", repository: "Hello-World", tagName: "v1.0.0"
        ) {
            switch $0 {
            case let .success(tag):
                XCTAssertEqual(tag.name, "v1.0.0")
                XCTAssertEqual(tag.commit.sha, "c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc")
                XCTAssertEqual(
                    tag.zipballURL.absoluteString,
                    "https://api.github.com/repos/octocat/Hello-World/zipball/v1.0.0")
                XCTAssertEqual(
                    tag.tarballURL.absoluteString,
                    "https://api.github.com/repos/octocat/Hello-World/tarball/v1.0.0")
            case let .failure(error):
                XCTAssert(false, "Endpoint failed with error \(error)")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    #if compiler(>=5.5.2) && canImport(_Concurrency)
        @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        func testGetTagAsync() async throws {
            let session = OctoKitURLTestSession(
                expectedURL:
                    "https://api.github.com/repos/octocat/Hello-World/git/refs/tags/v1.0.0",
                expectedHTTPMethod: "GET",
                jsonFile: "Fixtures/tag",
                statusCode: 200)
            let tag = try await Octokit(session: session).getTag(
                owner: "octocat", repository: "Hello-World", tagName: "v1.0.0")
            XCTAssertEqual(tag.name, "v1.0.0")
            XCTAssertEqual(tag.commit.sha, "c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc")
            XCTAssertEqual(
                tag.zipballURL.absoluteString,
                "https://api.github.com/repos/octocat/Hello-World/zipball/v1.0.0")
            XCTAssertEqual(
                tag.tarballURL.absoluteString,
                "https://api.github.com/repos/octocat/Hello-World/tarball/v1.0.0")
            XCTAssertTrue(session.wasCalled)
        }
    #endif

    func testCreateTag() {
        let session = OctoKitURLTestSession(
            expectedURL: "https://api.github.com/repos/octocat/Hello-World/git/tags",
            expectedHTTPMethod: "POST",
            jsonFile: "Fixtures/create_tag",
            statusCode: 201)
        let task = Octokit(session: session).createTag(
            owner: "octocat",
            repository: "Hello-World",
            tagName: "v1.0.0",
            message: "Initial release",
            objectSha: "c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc",
            type: "commit"
        ) { response in
            switch response {
            case let .success(tag):
                XCTAssertEqual(tag.name, "v1.0.0")
                XCTAssertEqual(tag.commit.sha, "c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc")
                XCTAssertEqual(
                    tag.zipballURL.absoluteString,
                    "https://api.github.com/repos/octocat/Hello-World/zipball/v1.0.0")
                XCTAssertEqual(
                    tag.tarballURL.absoluteString,
                    "https://api.github.com/repos/octocat/Hello-World/tarball/v1.0.0")
            case let .failure(error):
                XCTFail("Endpoint failed with error \(error)")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    #if compiler(>=5.5.2) && canImport(_Concurrency)
        @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        func testCreateTagAsync() async throws {
            let session = OctoKitURLTestSession(
                expectedURL: "https://api.github.com/repos/octocat/Hello-World/git/tags",
                expectedHTTPMethod: "POST",
                jsonFile: "Fixtures/create_tag",
                statusCode: 201)
            let tag = try await Octokit(session: session).createTag(
                owner: "octocat",
                repository: "Hello-World",
                tagName: "v1.0.0",
                message: "Initial release",
                objectSha: "c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc",
                type: "commit")
            XCTAssertEqual(tag.name, "v1.0.0")
            XCTAssertEqual(tag.commit.sha, "c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc")
            XCTAssertEqual(
                tag.zipballURL.absoluteString,
                "https://api.github.com/repos/octocat/Hello-World/zipball/v1.0.0")
            XCTAssertEqual(
                tag.tarballURL.absoluteString,
                "https://api.github.com/repos/octocat/Hello-World/tarball/v1.0.0")
            XCTAssertTrue(session.wasCalled)
        }
    #endif
}
