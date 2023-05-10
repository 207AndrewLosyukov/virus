//
//  ConfigurableViewProtocol.swift
//  Infection
//
//  Created by Андрей Лосюков on 08.05.2023.
//

import Foundation

protocol ConfigurableViewProtocol {

    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}
