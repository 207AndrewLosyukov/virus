//
//  NetworkService.swift
//  Infection
//
//  Created by Андрей Лосюков on 07.05.2023.
//

import Foundation

class NetworkService: NetworkServiceProtocol {

    enum Errors: Error {
        case requestError(_ string: String)
    }

    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func fetch<Model, Parser>(request: RequestProtocol, parser: Parser,
                              handler: @escaping(Result<Model, Error>) -> Void)
    where Model == Parser.Model, Parser: ResponseParserProtocol {

        guard let urlRequest = request.urlRequest else {
            handler(.failure(Errors.requestError("nil request")))
            return
        }
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                handler(.failure(error))
                return
            } else if let response = (response as? HTTPURLResponse),
                      !(200...299).contains(response.statusCode) {
                handler(.failure(Errors.requestError("error")))
            } else if let data = data {
                if let model = parser.parse(data: data) {
                    handler(.success(model))
                } else {
                    handler(.failure(Errors.requestError("can't parse")))
                }
            }
        }
        task.resume()
    }
}

