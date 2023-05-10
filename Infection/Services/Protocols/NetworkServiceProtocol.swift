//
//  NetworkServiceProtocol.swift
//  Infection
//
//  Created by Андрей Лосюков on 07.05.2023.
//

import Foundation

protocol NetworkServiceProtocol {
    var session: URLSession { get }

    func fetch<Model, Parser>(request: RequestProtocol, parser: Parser,
                              handler: @escaping(Result<Model, Error>) -> Void)
    where Parser: ResponseParserProtocol, Parser.Model == Model
}
