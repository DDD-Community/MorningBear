//
//  MyCellType.swift
//  MorningBearUI
//
//  Created by Young Bin on 2023/01/31.
//  Copyright © 2023 com.dache. All rights reserved.
//

import UIKit

public protocol CustomCellType: UICollectionViewCell {
    associatedtype ModelType
    
    static var filename: String { get }
    static var reuseIdentifier: String { get }
    static var bundle: Bundle { get }
    
    func prepare(_ data: ModelType)
}

// MARK: Register
public extension CustomCellType {
    static func registerHeader(to collectionView: UICollectionView, bundle: Bundle = Self.bundle) {
        let cellNib = UINib(nibName: Self.filename, bundle: bundle)
        collectionView.register(cellNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Self.reuseIdentifier)
    }
    
    static func registerFooter(to collectionView: UICollectionView, bundle: Bundle = Self.bundle) {
        let cellNib = UINib(nibName: Self.filename, bundle: bundle)
        collectionView.register(cellNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: Self.reuseIdentifier)
    }
    
    static func register(to collectionView: UICollectionView, bundle: Bundle = Self.bundle) {
        let cellNib = UINib(nibName: Self.filename, bundle: bundle)
        collectionView.register(cellNib, forCellWithReuseIdentifier: Self.reuseIdentifier)
    }
}

// MARK: Dequeue and prepare
public extension CustomCellType {
    /// 인스턴스를 어레이 형태로 전달하고 받은 `indexPath`를 기반으로 셀에 넣을 데이터를 결정
    static func dequeueAndPrepare(
        from collectionView: UICollectionView,
        at indexPath: IndexPath,
        sources: [ModelType]
    ) -> UICollectionViewCell {
        self.dequeueAndPrepare(from: collectionView, at: indexPath, prepare: sources[indexPath.row])
    }
    
    /// `dequeue`와 `prepare`를 한 번에 처리하는 메소드
    static func dequeueAndPrepare(
        from collectionView: UICollectionView,
        at indexPath: IndexPath,
        prepare data: ModelType
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.reuseIdentifier, for: indexPath
        ) as! Self
        
        DispatchQueue.main.async {
            cell.prepare(data)
        }
        
        return cell
    }
}
