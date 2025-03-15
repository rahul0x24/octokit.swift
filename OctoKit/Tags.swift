//
//  Tags.swift
//  OctoKit
//
//  Created by Claude on 01/01/2024.
//  Copyright © 2024 nerdish by nature. All rights reserved.
//

import Foundation
import RequestKit

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// MARK: model

/// Represents a Git tag in a GitHub repository.
public struct Tag: Codable {
    /// The name of the tag
    public let name: String

    /// URL for a zipball of the tag
    public let zipballURL: URL

    /// URL for a tarball of the tag
    public let tarballURL: URL

    /// Commit information for this tag
    public let commit: TagCommit

    /// The node ID of the tag
    public let nodeId: String

    /**
     * Initializes a new Tag instance.
     *
     * - Parameters:
     *   - name: The name of the tag
     *   - zipballURL: URL for a zipball of the tag
     *   - tarballURL: URL for a tarball of the tag
     *   - commit: Commit information for this tag
     *   - nodeId: The node ID of the tag
     */
    public init(
        name: String,
        zipballURL: URL,
        tarballURL: URL,
        commit: TagCommit,
        nodeId: String
    ) {
        self.name = name
        self.zipballURL = zipballURL
        self.tarballURL = tarballURL
        self.commit = commit
        self.nodeId = nodeId
    }

    enum CodingKeys: String, CodingKey {
        case name
        case commit
        case nodeId = "node_id"
        case zipballURL = "zipball_url"
        case tarballURL = "tarball_url"
    }
}

/// Represents a commit associated with a Git tag.
///
/// Example:
/// ```swift
/// let commit = TagCommit(sha: "abc123", url: URL(string: "https://api.github.com/repos/owner/repo/commits/abc123")!)
/// ```
public struct TagCommit: Codable {
    /// The SHA hash of the commit
    public let sha: String

    /// URL to the commit API resource
    public let url: URL

    /**
     * Initializes a new TagCommit instance.
     *
     * - Parameters:
     *   - sha: The SHA hash of the commit
     *   - url: URL to the commit API resource
     */
    public init(sha: String, url: URL) {
        self.sha = sha
        self.url = url
    }
}

// MARK: request

public extension Octokit {
    /// Fetches the list of tags for a repository.
    /// - Parameters:
    ///   - owner: The user or organization that owns the repository.
    ///   - repository: The name of the repository.
    ///   - page: Page number of the results to fetch. Default: `1`.
    ///   - perPage: Results per page (max 100). Default: `30`.
    ///   - completion: Callback for the outcome of the fetch.
    @discardableResult
    func listTags(
        owner: String,
        repository: String,
        page: Int = 1,
        perPage: Int = 30,
        completion: @escaping (_ response: Result<[Tag], Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = TagRouter.listTags(configuration, owner, repository, page, perPage)
        return router.load(
            session, dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Tag].self
        ) { tags, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let tags = tags {
                    completion(.success(tags))
                }
            }
        }
    }

    /// Fetches a specific tag by name.
    /// - Parameters:
    ///   - owner: The user or organization that owns the repository.
    ///   - repository: The name of the repository.
    ///   - tagName: The name of the tag to fetch.
    ///   - completion: Callback for the outcome of the fetch.
    @discardableResult
    func getTag(
        owner: String,
        repository: String,
        tagName: String,
        completion: @escaping (_ response: Result<Tag, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = TagRouter.getTag(configuration, owner, repository, tagName)
        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: Tag.self
        ) { tag, error in
            if let error = error {
                completion(.failure(error))
            } else if let tag = tag {
                completion(.success(tag))
            }
        }
    }

    /// Creates a new tag in a repository.
    /// - Parameters:
    ///   - owner: The user or organization that owns the repository.
    ///   - repository: The name of the repository.
    ///   - tagName: The name of the tag.
    ///   - message: The tag message.
    ///   - objectSha: The SHA of the git object this is tagging.
    ///   - type: The type of the object we're tagging. Normally this is a `commit` but it can also be a `tree` or a `blob`.
    ///   - completion: Callback for the outcome of the created tag.
    @discardableResult
    func createTag(
        owner: String,
        repository: String,
        tagName: String,
        message: String,
        objectSha: String,
        type: String = "commit",
        completion: @escaping (_ response: Result<Tag, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = TagRouter.createTag(
            configuration, owner, repository, tagName, message, objectSha, type)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(session, decoder: decoder, expectedResultType: Tag.self) { tag, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let tag = tag {
                    completion(.success(tag))
                }
            }
        }
    }

    #if compiler(>=5.5.2) && canImport(_Concurrency)
        /// Fetches the list of tags for a repository.
        /// - Parameters:
        ///   - owner: The user or organization that owns the repository.
        ///   - repository: The name of the repository.
        ///   - page: Page number of the results to fetch. Default: `1`.
        ///   - perPage: Results per page (max 100). Default: `30`.
        @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        func listTags(
            owner: String,
            repository: String,
            page: Int = 1,
            perPage: Int = 30
        ) async throws -> [Tag] {
            let router = TagRouter.listTags(configuration, owner, repository, page, perPage)
            return try await router.load(
                session, dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                expectedResultType: [Tag].self)
        }

        /// Fetches a specific tag by name.
        /// - Parameters:
        ///   - owner: The user or organization that owns the repository.
        ///   - repository: The name of the repository.
        ///   - tagName: The name of the tag to fetch.
        @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        func getTag(owner: String, repository: String, tagName: String) async throws -> Tag {
            let router = TagRouter.getTag(configuration, owner, repository, tagName)
            return try await router.load(
                session, dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                expectedResultType: Tag.self)
        }

        /// Creates a new tag in a repository.
        /// - Parameters:
        ///   - owner: The user or organization that owns the repository.
        ///   - repository: The name of the repository.
        ///   - tagName: The name of the tag.
        ///   - message: The tag message.
        ///   - objectSha: The SHA of the git object this is tagging.
        ///   - type: The type of the object we're tagging. Normally this is a `commit` but it can also be a `tree` or a `blob`.
        @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        func createTag(
            owner: String,
            repository: String,
            tagName: String,
            message: String,
            objectSha: String,
            type: String = "commit"
        ) async throws -> Tag {
            let router = TagRouter.createTag(
                configuration, owner, repository, tagName, message, objectSha, type)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)
            return try await router.post(session, decoder: decoder, expectedResultType: Tag.self)
        }
    #endif
}

// MARK: Router

/// Router for Tag-related API endpoints.
enum TagRouter: JSONPostRouter {
    case listTags(Configuration, String, String, Int, Int)
    case getTag(Configuration, String, String, String)
    case createTag(Configuration, String, String, String, String, String, String)

    var configuration: Configuration {
        switch self {
        case let .listTags(config, _, _, _, _): return config
        case let .getTag(config, _, _, _): return config
        case let .createTag(config, _, _, _, _, _, _): return config
        }
    }

    var method: HTTPMethod {
        switch self {
        case .listTags, .getTag:
            return .GET
        case .createTag:
            return .POST
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .listTags, .getTag:
            return .url
        case .createTag:
            return .json
        }
    }

    var params: [String: Any] {
        switch self {
        case let .listTags(_, _, _, page, perPage):
            return ["page": "\(page)", "per_page": "\(perPage)"]
        case .getTag:
            return [:]
        case let .createTag(_, _, _, tagName, message, objectSha, type):
            return [
                "tag": tagName,
                "message": message,
                "object": objectSha,
                "type": type,
            ]
        }
    }

    var path: String {
        switch self {
        case let .listTags(_, owner, repo, _, _):
            return "repos/\(owner)/\(repo)/tags"
        case let .getTag(_, owner, repo, tagName):
            return "repos/\(owner)/\(repo)/git/refs/tags/\(tagName)"
        case let .createTag(_, owner, repo, _, _, _, _):
            return "repos/\(owner)/\(repo)/git/tags"
        }
    }
}
