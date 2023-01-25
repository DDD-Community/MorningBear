//
//  RemoteStorageType.swift
//  MorningBearStorage
//
//  Created by Young Bin on 2023/01/21.
//  Copyright © 2023 com.dache. All rights reserved.
//

import UIKit

import RxSwift

public protocol RemoteStoraging {
    associatedtype Storage: StorageType

    var remoteStorageService: Storage { get }
    func saveImage(_ image: UIImage) -> Single<URL>
    func loadImage(_ url: URL) -> Single<UIImage>
}

extension RemoteStoraging {
    typealias Mock = MockRemoteStorageManager
}

struct MockRemoteStorageManager: RemoteStoraging {
    let saveAction: () -> Single<URL>
    let loadAction: () -> Single<UIImage>
    
    let remoteStorageService = MockStorage()
    
    func saveImage(_ image: UIImage) -> RxSwift.Single<URL> {
        saveAction()
    }
    
    func loadImage(_ url: URL) -> RxSwift.Single<UIImage> {
        loadAction()
    }
    
    init(saveAction: @escaping () -> Single<URL>, loadAction: @escaping () -> Single<UIImage>) {
        self.saveAction = saveAction
        self.loadAction = loadAction
    }
}
