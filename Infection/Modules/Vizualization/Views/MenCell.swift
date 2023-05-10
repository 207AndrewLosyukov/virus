//
//  MenCell.swift
//  Infection
//
//  Created by Андрей Лосюков on 07.05.2023.
//

import UIKit

class MenCell: UICollectionViewCell, ConfigurableViewProtocol {

    enum Constants {
        static var reuseIdentifier = "itemCollectionViewCell"
    }

    typealias ConfigurationModel = MenCellModel
    func configure(with model: MenCellModel) {
        imageView.image = model.image ?? Resources.Images.placeholder
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        if model.isInfected {
            label.text = "Заражен"
            contentView.backgroundColor = .red
        } else {
            label.text = "Здоров"
            contentView.backgroundColor = .green
        }
        contentView.addSubview(label)
        setupConstraints()
    }

    private var imageView: UIImageView = UIImageView()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textAlignment = .center
        return label
    }()

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: label.bottomAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
