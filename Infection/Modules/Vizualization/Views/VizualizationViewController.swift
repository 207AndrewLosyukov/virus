//
//  VizualizationViewController.swift
//  Infection
//
//  Created by Андрей Лосюков on 07.05.2023.
//

import UIKit

class VizualizationViewController: UIViewController {

    enum Constants {
        static let lowerBound = 0.5
        static let upperBound = 2.0
        static let spacing = 10.0
    }

    private let pinchGesture = UIPinchGestureRecognizer()

    private var timer: DispatchSourceTimer?

    private var indexesNeedToInfectOthers: Set<Int> = []

    private var countOfInfected = 0

    private let queue = DispatchQueue(label: "com.infection.app.timer", attributes: .concurrent)

    private let imageLoaderService: ImageLoaderServiceProtocol = ImageLoaderService(networkService: NetworkService(), apiKey: "35805955-f078e993bdb5fbd72606dc818")

    private var guys: [MenCellModel] = []

    private var vizualizationModel: VizualizationModel?

    private var activityIndicatorView = UIActivityIndicatorView()

    private var columnsCount = 6

    private var currentScale = 1.0

    init(vizualizationModel: VizualizationModel) {
        super.init(nibName: nil, bundle: nil)
        self.vizualizationModel = vizualizationModel
        startTimer(with: vizualizationModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MenCell.self,
            forCellWithReuseIdentifier: MenCell.Constants.reuseIdentifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(showInfectionInfo)
        )
        collectionView.isEditing = true
        collectionView.allowsMultipleSelectionDuringEditing = true
        navigationItem.title = Resources.Strings.simulation
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.addSubview(activityIndicatorView)
        activityIndicatorView.color = .gray
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.center = view.center
        setupConstraints()
        if vizualizationModel?.typeOfSimulation == .network {
            activityIndicatorView.startAnimating()
            loadImageListFromNetwork()
        } else {
            loadImageListFromAssets()
        }
        pinchGesture.addTarget(self, action: #selector(pinchHandler))
        collectionView.addGestureRecognizer(pinchGesture)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadImageListFromNetwork() {
        activityIndicatorView.startAnimating()
        imageLoaderService.loadImageListByAPI(groupSize: vizualizationModel?.groupSize ?? 0, handler: { [weak self] (result) in
            DispatchQueue.main.async {
                self?.activityIndicatorView.stopAnimating()
            }
            switch result {
            case .success(let imageLinkList):
                let guysModels = imageLinkList.map {
                    MenCellModel(image: nil, url: $0)
                }
                self?.update(with: guysModels)
            case .failure: break
            }
        })
    }

    private func loadImageListFromAssets() {
        var newGuys: [MenCellModel] = []
        for _ in 0..<(vizualizationModel?.groupSize ?? 100) {
            newGuys.append(MenCellModel(image: Resources.Images.notInfected, url: ""))
            update(with: newGuys)
        }
    }


    private func update(with guys: [MenCellModel]) {
        DispatchQueue.main.async { [weak self] in
            self?.guys = guys
            self?.collectionView.reloadData()
        }
    }

    private func fetchImage(at index: Int, for model: MenCellModel) {
        var copyModel = model
        copyModel.isFetching = true
        guys[index] = copyModel
        imageLoaderService.loadImageByURL(url: model.url) { [weak self] (result) in
            switch result {
            case .success(let imageData):
                guard let image = UIImage(data: imageData) else {
                    return
                }
                copyModel.isFetching = false
                copyModel.image = image
                print(imageData)
                self?.updateCell(at: index, with: copyModel)
            case .failure: break
            }
        }
    }

    private func updateCell(at index: Int, with model: MenCellModel) {
        DispatchQueue.main.async { [weak self] in
            self?.guys[index] = model
            self?.collectionView.reloadItems(at: [.init(item: index, section: 0)])
        }
    }

    private func updateCellWithInfected(with index: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadItems(at: [.init(item: index, section: 0)])
        }
    }

    func startTimer(with model: VizualizationModel?) {
        timer = DispatchSource.makeTimerSource(queue: queue)
        if let period = model?.period {
            timer?.schedule(deadline: .now() + period, repeating: .milliseconds(Int(period * 1000)))
            timer?.setEventHandler { [weak self] in
                self?.makeNewInfected()
            }
        }
        timer?.resume()
    }

    private func makeNewInfected() {
        if let infectionFactor = vizualizationModel?.infectionFactor,
           let groupSize = vizualizationModel?.groupSize {
            for i in indexesNeedToInfectOthers {
                let columnPosition = i % columnsCount
                let rowPosition = Int(i / columnsCount)
                var menNeighboors = [Int]()
                if rowPosition != 0 {
                    menNeighboors.append(i - columnsCount)
                }
                if i + columnsCount < groupSize {
                    menNeighboors.append(i + columnsCount)
                }
                if columnPosition != 0 {
                    menNeighboors.append(i - 1)
                }
                if columnPosition != columnsCount - 1 && i + 1 < groupSize {
                    menNeighboors.append(i + 1)
                }
                menNeighboors = menNeighboors.shuffled()
                var indixes = [Int]()
                indixes.append(contentsOf: menNeighboors[safe: 0..<infectionFactor] ?? [])
                print(indixes)
                for j in indixes {
                    if !guys[j].isInfected {
                        indexesNeedToInfectOthers.insert(j)
                        guys[j].isInfected = true
                        if vizualizationModel?.typeOfSimulation == .local {
                            guys[j].image = Resources.Images.infected
                        }
                        countOfInfected += 1
                        updateCellWithInfected(with: j)
                    }
                }
                indexesNeedToInfectOthers.remove(i)
                if countOfInfected == guys.count {
                    stopTimer()
                }
            }
        }
    }

    func stopTimer() {
        timer?.cancel()
    }

    deinit {
        stopTimer()
    }

    @objc private func showInfectionInfo() {
        let message = "Количество зараженных: \(countOfInfected), количество здоровых: \(guys.count - countOfInfected)"

        let infoTextAlert = UIAlertController(title: "Информация о распространении",
        message: message, preferredStyle: .alert)
        infoTextAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
        }))
        present(infoTextAlert, animated: true)
    }

    @objc private func pinchHandler() {
        if (pinchGesture.state == .changed) {
            var newScale = currentScale * pinchGesture.scale
            if newScale < Constants.lowerBound {
                newScale = Constants.lowerBound
            }
            if newScale > Constants.upperBound {
                newScale = Constants.upperBound
            }
            currentScale = newScale
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    @objc private func close() {
        navigationController?.popViewController(animated: true)
    }
}

extension VizualizationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guys.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MenCell.Constants.reuseIdentifier,
            for: indexPath) as? MenCell else {
                return UICollectionViewCell()
            }
        let imageModel = guys[indexPath.item]
        cell.configure(with: imageModel)
        if imageModel.image == nil && !imageModel.isFetching {
            fetchImage(at: indexPath.item, for: imageModel)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard collectionView.dequeueReusableCell(
            withReuseIdentifier: MenCell.Constants.reuseIdentifier,
            for: indexPath) is MenCell else {
                return
            }
        DispatchQueue.main.async { [weak self] in
            if let isInfected = self?.guys[indexPath.item].isInfected {
                if !isInfected {
                    self?.countOfInfected += 1
                    self?.guys[indexPath.item].isInfected = true
                    self?.indexesNeedToInfectOthers.insert(indexPath.item)
                    if self?.vizualizationModel?.typeOfSimulation == .local {
                        self?.guys[indexPath.item].image = Resources.Images.infected
                    }
                    self?.collectionView.reloadItems(at: [.init(item: indexPath.item, section: 0)])
                }
            }
        }
    }
}

extension VizualizationViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let scaledWidth = 50 * currentScale
        columnsCount = Int(floor(320 / scaledWidth))
        let totalSpacingSize = Constants.spacing * (CGFloat(columnsCount) - 1)
        let fittedWidth = (320 - totalSpacingSize) / CGFloat(columnsCount)

        return CGSize(width: fittedWidth, height: fittedWidth)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: Constants.spacing, left: Constants.spacing, bottom: 0, right: Constants.spacing)
    }
}
