//
//  ImageLoaderServiceProtocol.swift
//  Infection
//
//  Created by Андрей Лосюков on 07.05.2023.
//

import Foundation

protocol ImageLoaderServiceProtocol {

    func loadImageListByAPI(groupSize: Int, handler: @escaping((Result<[String], Error>) -> Void))

    func loadImageByURL(url: String, handler: @escaping ((Result<Data, Error>) -> Void))
}
