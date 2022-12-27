//
//  HomeViewController.swift
//  MorningBear
//
//  Created by 이영빈 on 2022/12/26.
//  Copyright © 2022 com.dache. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    private var dataSource = Mock.dataSource
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            layoutCollectionView()
            configureCollectionView()
            connectCollectionView()
            registerCells()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Collection view setting tools
extension HomeViewController {
    private func layoutCollectionView() {
        let provider = CompositionalLayoutProvider()
        
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            switch self.dataSource[section] {
            case .state:
                return nil
            case .recentMornings:
                return provider.staticGridLayoutSection(column: 2)
            case .badges:
                return provider.horizontalScrollLayoutSection(cellWidth: 50)
            case .articles:
                return provider.horizontalScrollLayoutSection(cellWidth: 50)
            }
        }
        
        collectionView.collectionViewLayout = layout
    }
    
    private func configureCollectionView() {
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
    }
    
    private func connectCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func registerCells() {
        var cellNib = UINib(nibName: "RecentMorningCell", bundle: nil)
        collectionView.register(cellNib,
                                forCellWithReuseIdentifier: "RecentMorningCell")
        
        // 헤더 - 공용
        cellNib = UINib(nibName: "TitleHeaderViewCell", bundle: nil)
        collectionView.register(cellNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "TitleHeaderViewCell")
        
        // 푸터 - 공용
        cellNib = UINib(nibName: "FooterViewCell", bundle: nil)
        collectionView.register(cellNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "FooterViewCell")
    }
}


// MARK: - Delegate methods
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch dataSource[section] {
        case .state:
            return 1
        case let .recentMornings(states):
            return min(4, states.count) // 고정값(최근 미라클 모닝은 상위 4개만 표시)
        case let .badges(badges):
            return badges.count
        case let .articles(articles):
            return articles.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.dataSource[indexPath.section] {
        case let .state(state):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "StateCell", for: indexPath
            ) as! StateCell
            
            let item = state
            cell.prepare(titleText: item.nickname)
            
            return UICollectionViewCell()
            
        case let .recentMornings(mornings):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "RecentMorningCell", for: indexPath
            ) as! RecentMorningCell
            
            let item = mornings.prefix(4)[indexPath.item] // 최근 미라클 모닝은 상위 4개만 표시; MARK: 정렬 필수
            cell.prepare(image: item.image, titleText: item.title)
            
            return cell
            
        case let .badges(badges):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "RecentMorningCell", for: indexPath
            ) as! RecentMorningCell
            
            let item = badges[indexPath.item]
            cell.prepare(image: item.image, titleText: item.title)
            
            return cell
            
        case let .articles(badges):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "RecentMorningCell", for: indexPath
            ) as! RecentMorningCell
            
            let item = badges[indexPath.item]
            cell.prepare(image: item.image, titleText: item.title)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 헤더 & 푸터 설정
        switch kind {
            // Header case
        case UICollectionView.elementKindSectionHeader:
            return properHeaderCell(for: indexPath)
            
        case UICollectionView.elementKindSectionFooter:
            return properFooterCell(for: indexPath)
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: - Internal tools
extension HomeViewController {
    /// 섹션 별로 적절한 헤더 뷰를 제공
    ///
    /// 현재로서는 버튼 유무만 조정
    private func properHeaderCell(for indexPath: IndexPath) -> HomeSectionHeaderCell {
        let headerCell = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "TitleHeaderViewCell",
            for: indexPath
        ) as! HomeSectionHeaderCell
        
        // 버튼 유무 조정
        switch dataSource[indexPath.section] {
        case .state:
            headerCell.prepare(descText: nil, titleText: "나의 최근 미라클모닝", needsButton: false)
        default:
            headerCell.prepare(descText: "더 보기", titleText: "나의 최근 미라클모닝", needsButton: true)
        }
        
        return headerCell
    }

    /// 섹션 별로 적절한 푸터 뷰를 제공
    ///
    /// 현재로서는 차이가 없음
    private func properFooterCell(for indexPath: IndexPath) -> HomeSectionFooterCell {
        let footerCell = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "FooterViewCell",
            for: indexPath
        ) as! HomeSectionFooterCell
        
        footerCell.prepare(buttonText: "더 알아보기")
        
        return footerCell
    }

}
