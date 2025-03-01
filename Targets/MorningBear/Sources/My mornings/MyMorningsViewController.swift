//
//  MyMorningsViewController.swift
//  MorningBear
//
//  Created by Young Bin on 2023/01/02.
//  Copyright © 2023 com.dache. All rights reserved.
//

import UIKit

import RxSwift

import MorningBearUI

class MyMorningsViewController: UIViewController, DiffableDataSourcing {
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, MyMorning>
    
    private let viewModel = MyMorningsViewModel()
    private let bag = DisposeBag()
    
    var diffableDataSource: DiffableDataSource!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            configureCompositionalCollectionView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        navigationItem.title = "나의 미라클모닝"
        
        diffableDataSource = makeDiffableDataSource(with: collectionView)
        diffableDataSource.initDataSource(allSection: Section.allCases)
        
        commit(diffableDataSource)
        
        viewModel.fetchNewMorning()
    }
}

extension MyMorningsViewController: CollectionViewCompositionable {
    func layoutCollectionView() {
        let provider = CompositionalLayoutProvider()
        let section = provider.squareCellDynamicGridLayoutSection(column: 2)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        collectionView.collectionViewLayout = layout
    }
    
    func designCollectionView() {
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = .clear
    }
    
    func connectCollectionViewWithDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = diffableDataSource
    }
    
    func registerCells() {
        let bundle = MorningBearUIResources.bundle
        // 상태(헤더)
        var cellNib = UINib(nibName: "HomeSectionHeaderCell", bundle: bundle)
        collectionView.register(cellNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HomeSectionHeaderCell")
        
        // 나의 모닝
        cellNib = UINib(nibName: "RecentMorningCell", bundle: bundle)
        collectionView.register(cellNib,
                                forCellWithReuseIdentifier: "RecentMorningCell")
    }
}

extension MyMorningsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row > viewModel.myMornings.count - 4 { // 끝에서 4개 전에 새로운 이미지 요청
//            viewModel.fetchNewMorning()
        }
    }
}

extension MyMorningsViewController {
    func bindDataSourceWithObservable(_ dataSource: DiffableDataSource) {
        viewModel.$myMornings
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] newMorningData in
                guard let self else { return }
                
                self.diffableDataSource.replaceDataSource(in: .main, to: newMorningData)
            })
            .disposed(by: bag)
    }
        
    func makeDiffableDataSource(with collectionView: UICollectionView) -> DiffableDataSource {
        let dataSource = configureDiffableDataSource(with: collectionView) { [weak self] collectionView, indexPath, model in
            guard let self else { return UICollectionViewCell() }
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "RecentMorningCell", for: indexPath
            ) as! RecentMorningCell
            
            let item = self.viewModel.myMornings[indexPath.row]
            cell.prepare(item)
            return cell
        }
        
        return dataSource
    }
    
    func addSupplementaryView(_ diffableDataSource: DiffableDataSource) {
        diffableDataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                return self.properHeaderCell(for: indexPath)
            default:
                return UICollectionReusableView()
            }
        }
    }
    
    enum Section: Hashable, CaseIterable {
        case main
    }
}


// MARK: - Internal tools
extension MyMorningsViewController {
    /// 섹션 별로 적절한 헤더 뷰를 제공
    private func properHeaderCell(for indexPath: IndexPath) -> HomeSectionHeaderCell {
        let headerCell = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HomeSectionHeaderCell",
            for: indexPath
        ) as! HomeSectionHeaderCell
        
        let menuItems: [UIAction] = {
            return [
                UIAction(title: "최신순", image: UIImage(systemName: "arrow.down.circle"), handler: { _ in
                    self.viewModel.fetchNewMorning(sort: .desc)
                }),
                UIAction(title: "오래된순", image: UIImage(systemName: "arrow.up.circle"), handler: { _ in
                    self.viewModel.fetchNewMorning(sort: .asc)
                }),
            ]
        }()
        
        let menu = UIMenu(title: "정렬 방식", children: menuItems)
        headerCell.prepare(title: "나의 최근 미라클 모닝", buttonText: "정렬 방식", menu: menu)
        
        return headerCell
    }
}
