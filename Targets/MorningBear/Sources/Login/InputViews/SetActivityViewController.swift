//
//  SetActivityViewController.swift
//  MorningBear
//
//  Created by 이건우 on 2023/01/20.
//  Copyright © 2023 com.dache. All rights reserved.
//

import UIKit
import MorningBearUI

import RxSwift
import RxCocoa

class SetActivityViewController: UIViewController {
    
    private let bag = DisposeBag()
    private let viewModel = InitialInfoViewModel.shared
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = MorningBearUIFontFamily.Pretendard.bold.font(size: 24)
            titleLabel.textColor = .white
            titleLabel.text = "주로 어떤 활동을 하시나요?"
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = MorningBearUIFontFamily.Pretendard.regular.font(size: 16)
            descriptionLabel.textColor = MorningBearUIAsset.Colors.disabledText.color
            descriptionLabel.text = "관심있는 미라클 모닝 활동을 모두 선택해 주세요"
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            configureCompositionalCollectionView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SetActivityViewController: CollectionViewCompositionable {
    func layoutCollectionView() {
        let provider = CompositionalLayoutProvider()
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            return provider.dynamicGridLayoutSection(column: 2, height: 140, inset: .zero, spacing: 15)
        }
        
        collectionView.collectionViewLayout = layout
    }
    
    func designCollectionView() {
        collectionView.isScrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.backgroundColor = .clear
    }
    
    func connectCollectionViewWithDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func registerCells() {
        let bundle =  MorningBearUIResources.bundle
        let cellNib = UINib(nibName: ActivityCell.reuseIdentifier, bundle: bundle)
        collectionView.register(cellNib, forCellWithReuseIdentifier: ActivityCell.reuseIdentifier)
    }
}

extension SetActivityViewController: UICollectionViewDelegate {}
extension SetActivityViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ActivityCell.reuseIdentifier, for: indexPath
        ) as! ActivityCell
        
        let item = viewModel.activities[indexPath.row]
        cell.prepate(item)
        
        return cell
    }
}
