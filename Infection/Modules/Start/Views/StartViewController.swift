//
//  ViewController.swift
//  Infection
//
//  Created by Андрей Лосюков on 05.05.2023.
//

import UIKit

enum TypeOfSimulation {
    case network
    case local
}

class StartViewController: UIViewController {

    enum Constants {
        static let inset = 15.0
        static let largeInset = 30.0
        static let textFieldHeight = 40.0
        static let cornerRadius = 15.0

        static let startButtonHeight = 50.0
        static let startButtonBottomConstraint = 35.0
        static let animationDuration = 0.3

        static let defaultGroupSize = 100
        static let defaultInfectionFactor = 3
        static let defaultPeriod = 1.0
    }

    private var currentType: TypeOfSimulation = .network

    private var isButtonAnimating = false

    private var vkEmitter: VKEmitter?

    private lazy var groupSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "Количество людей"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var infectionFactorLabel: UILabel = {
        let label = UILabel()
        label.text = "Фактор инфекции"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var periodLabel: UILabel = {
        let label = UILabel()
        label.text = "Период пересчета"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Загрузка людей"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var networkLabel: UILabel = {
        let networkLabel = UILabel()
        networkLabel.text = "По сети"
        networkLabel.textColor = .white
        networkLabel.font = UIFont.boldSystemFont(ofSize: 15)
        networkLabel.translatesAutoresizingMaskIntoConstraints = false
        return networkLabel
    }()

    private let localLabel: UILabel = {
        let localLabel = UILabel()
        localLabel.text = "Локально"
        localLabel.textColor = .white
        localLabel.font = UIFont.boldSystemFont(ofSize: 15)
        localLabel.translatesAutoresizingMaskIntoConstraints = false
        return localLabel
    }()

    private lazy var groupSizeTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.layer.borderWidth = 2.0
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.text = "\(Constants.defaultGroupSize)"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: textField.frame.size.height))
        textField.leftViewMode = .always
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var infectionFactorTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.layer.borderWidth = 2.0
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.text = "\(Constants.defaultInfectionFactor)"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: textField.frame.size.height))
        textField.leftViewMode = .always
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var periodTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.layer.borderWidth = 2.0
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.text = "\(Constants.defaultPeriod)"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: textField.frame.size.height))
        textField.leftViewMode = .always
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var networkButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonsHandler), for: .touchUpInside)
        button.setImage(UIImage(systemName: "checkmark.circle.fill",
        withConfiguration: UIImage.SymbolConfiguration(scale: .large))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .selected)
        let image = UIImage(systemName: "circle",
                           withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.isSelected = true
        return button
    }()

    private lazy var localButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonsHandler), for: .touchUpInside)
        button.setImage(UIImage(systemName: "checkmark.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(scale: .large))?.withTintColor(.white, renderingMode: .alwaysOriginal),
                        for: .selected)
        let image = UIImage(systemName: "circle",
                           withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()

    private lazy var stackView: UIStackView = {
        let networkStackView = UIStackView(arrangedSubviews: [
            networkLabel, networkButton
        ])
        networkStackView.axis = .vertical
        networkStackView.spacing = 10
        networkStackView.alignment = .center
        networkStackView.distribution = .fill

        let localStackView = UIStackView(arrangedSubviews: [
            localLabel, localButton
        ])
        localStackView.spacing = 10
        localStackView.alignment = .center
        localStackView.distribution = .fill
        localStackView.axis = .vertical

        let horizontalStackView = UIStackView(arrangedSubviews: [
            networkStackView, localStackView
        ])
        horizontalStackView.spacing = 30
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .fill
        horizontalStackView.axis = .horizontal
        let stackView = UIStackView(arrangedSubviews: [
            groupSizeLabel,
            groupSizeTextField,
            infectionFactorLabel,
            infectionFactorTextField,
            periodLabel,
            periodTextField,
            typeLabel,
            horizontalStackView
        ])
        stackView.backgroundColor = Resources.Colors.mainColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.layer.cornerRadius = Constants.cornerRadius
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.setCustomSpacing(30, after: groupSizeTextField)
        stackView.setCustomSpacing(30, after: infectionFactorTextField)
        stackView.setCustomSpacing(30, after: periodTextField)
        stackView.layoutMargins = UIEdgeInsets(top: Constants.largeInset, left: 0, bottom: Constants.largeInset, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    private var startButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Resources.Colors.mainColor
        button.tintColor = .white
        button.setTitle("Запустить моделирование", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Resources.Strings.mainScreenTitle
        startButton.addTarget(self, action: #selector(startButtonOnTapHandler), for: .touchUpInside)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onPressed(_:)))
        startButton.addGestureRecognizer(longPressRecognizer)
        view.backgroundColor = .white
        view.addSubview(stackView)
        view.addSubview(startButton)
        vkEmitter = VKEmitter(in: view)
        setupTextFieldBorderColor()
        setupStackViewConstraints()
        setupStartButtonConstraints()
    }

    private func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.inset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.inset)
        ])

        NSLayoutConstraint.activate([
            groupSizeTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            groupSizeTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: Constants.inset),
            groupSizeTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -Constants.inset),

            infectionFactorTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            infectionFactorTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: Constants.inset),
            infectionFactorTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -Constants.inset),

            periodTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            periodTextField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: Constants.inset),
            periodTextField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -Constants.inset)
        ])
    }

    func setupStartButtonConstraints() {
        NSLayoutConstraint.activate([
            startButton.heightAnchor.constraint(equalToConstant: Constants.startButtonHeight),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.largeInset),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.largeInset),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                constant: -Constants.startButtonBottomConstraint)
        ])
    }

    @objc func startButtonOnTapHandler() {
        if checkErrors() {
            setupTextFieldBorderColor()
            guard let groupSize = Int(groupSizeTextField.text ?? ""),
                  let infectionFactor = Int(infectionFactorTextField.text ?? ""),
                  let period = Double(periodTextField.text ?? "") else {
                return
            }
            let vizualizationModel = VizualizationModel(
                groupSize: groupSize,
                infectionFactor: infectionFactor,
                period: period, typeOfSimulation: currentType)
            let vizualizationViewController = VizualizationViewController(
                vizualizationModel: vizualizationModel)
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .moveIn
            transition.subtype = .fromTop
            navigationController?.view.layer.add(transition, forKey: nil)
            navigationController?.pushViewController(vizualizationViewController, animated: false)
        }
    }

    private func checkErrors() -> Bool {
        guard let groupSize = Int(groupSizeTextField.text ?? "") else {
            showErrorAlert(message: "Введите размер группы целым числом")
            groupSizeTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        if groupSize < 1 {
            showErrorAlert(message: "Введите размер группы положительным числом")
            groupSizeTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        if groupSize > 200 && currentType == .network {
            showErrorAlert(message: "API не позволяет загрузить более 200, попробуйте локально")
            groupSizeTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        if groupSize > 2000 && currentType == .local {
            showErrorAlert(message: "Оперативка не всесильна...")
            groupSizeTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        guard let infectionFactor = Int(infectionFactorTextField.text ?? "") else {
            showErrorAlert(message: "Введите фактор инфекции целым числом")
            infectionFactorTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        if infectionFactor < 1 {
            showErrorAlert(message: "Введите фактор инфекции положительным числом")
            infectionFactorTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        if infectionFactor > 4 {
            showErrorAlert(message: "У зараженного не может быть более 4 соседей")
            infectionFactorTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        guard let period = Double(periodTextField.text ?? "") else {
            showErrorAlert(message: "Введите период дробным числом (через точку)")
            periodTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        if period <= 0 {
            showErrorAlert(message: "Введите период положительным дробным числом")
            periodTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        if period < 0.1 {
            showErrorAlert(message: "Оперативка не всесильна...")
            periodTextField.layer.borderColor = UIColor.systemRed.cgColor
            return false
        }
        return true
    }

    func showErrorAlert(message: String) {
        let errorTextAlert = UIAlertController(title: "Неправильный ввод",
        message: message, preferredStyle: .alert)
        errorTextAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
        }))
        present(errorTextAlert, animated: true)
    }

    private func setupTextFieldBorderColor() {
        groupSizeTextField.layer.borderColor = UIColor.systemGray3.cgColor
        infectionFactorTextField.layer.borderColor = UIColor.systemGray3.cgColor
        periodTextField.layer.borderColor = UIColor.systemGray3.cgColor
    }

    @objc func onPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            if !isButtonAnimating {
                isButtonAnimating = true
                animateButton(with: Constants.animationDuration)
            } else {
                isButtonAnimating = false
                if let presentationLayer = startButton.layer.presentation() {
                    startButton.layer.transform = presentationLayer.transform
                    startButton.layer.removeAnimation(forKey: "shake")
                }
                UIView.animate(withDuration: Constants.animationDuration, animations: {
                    self.startButton.transform = .identity
                }, completion: { _ in
                    self.startButton.layer.removeAllAnimations()
                })
            }
        }
    }

    @objc private func buttonsHandler(_ sender: UIButton) {
        if sender == networkButton {
            networkButton.isSelected = true
            localButton.isSelected = false
            currentType = .network
        } else {
            localButton.isSelected = true
            networkButton.isSelected = false
            currentType = .local
        }
    }

    func animateButton(with duration: Double) {
        let translationAnimation = CABasicAnimation(keyPath: "position")
        let yPosition = view.frame.height -
        Constants.startButtonHeight / 2 - Constants.startButtonBottomConstraint
        translationAnimation.autoreverses = true
        translationAnimation.fromValue = CGPoint(x: view.frame.width / 2.0 - 5, y: yPosition - 5)
        translationAnimation.toValue = CGPoint(x: view.frame.width / 2.0 + 5, y: yPosition + 5)
        translationAnimation.duration = duration / 2
        translationAnimation.repeatCount = .infinity

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.autoreverses = true
        rotationAnimation.fromValue = -.pi / 20.0
        rotationAnimation.toValue = .pi / 20.0
        rotationAnimation.duration = duration / 2
        rotationAnimation.repeatCount = .infinity

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [rotationAnimation, translationAnimation]
        animationGroup.autoreverses = true
        animationGroup.duration = Constants.animationDuration
        animationGroup.repeatCount = .infinity
        startButton.layer.add(animationGroup, forKey: "shake")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            vkEmitter?.start(at: location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            vkEmitter?.move(to: location)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        vkEmitter?.stop()
    }
}
