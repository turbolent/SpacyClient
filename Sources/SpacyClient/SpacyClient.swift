import Foundation
import Result

public struct Token: Codable, Equatable {
    public let text: String
    public let tag: String
    public let lemma: String
    public let entity: String?
}


public final class SpacyClient {

    public typealias Completion = (Result<[Token], Error>) -> Void

    public enum Error: Swift.Error {
        case failedToConstructURL
        case failedResponse(Swift.Error)
        case invalidResponse
    }

    private struct Constants {
        static let defaultTimeoutIntervalForRequest: TimeInterval = 10
    }

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    public let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, sessionConfiguration: URLSessionConfiguration? = nil) {
        self.baseURL = baseURL
        let sessionConfiguration = sessionConfiguration ?? {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = Constants.defaultTimeoutIntervalForRequest
            return config
        }()
        self.session = URLSession(configuration: sessionConfiguration)
    }

    public func tag(sentence: String, completion: @escaping Completion) throws {
        try request(path: "/tag", sentence: sentence, completion: completion)
    }

    public func ner(sentence: String, completion: @escaping Completion) throws {
        try request(path: "/ner", sentence: sentence, completion: completion)
    }

    private func request(path: String, sentence: String, completion: @escaping Completion) throws {
        guard let url = URL(string: path, relativeTo: self.baseURL) else {
            throw Error.failedToConstructURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try SpacyClient.encoder.encode(["sentence": sentence])

        let completionHandler = SpacyClient.makeCompletionHandler(completion: completion)
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }

    private static func makeCompletionHandler(completion: @escaping Completion)
        -> (Data?, URLResponse?, Swift.Error?) -> Void
    {
        return { (data, response, error) in
            if let error = error {
                completion(.failure(.failedResponse(error)))
                return
            }

            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let tokens = try? SpacyClient.decoder.decode([Token].self, from: data)
                else {
                    completion(.failure(.invalidResponse))
                    return
            }

            completion(.success(tokens))
        }
    }
}
