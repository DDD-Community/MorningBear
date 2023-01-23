//
//  MyMorningDataEditor.swift
//  MorningBearDataEditor
//
//  Created by 이영빈 on 2023/01/19.
//  Copyright © 2023 com.dache. All rights reserved.
//

import Foundation

import RxSwift

@_exported import MorningBearData

import UIKit

import MorningBearUI
import MorningBearAPI
import MorningBearNetwork
import MorningBearStorage

public protocol MyMorningDataEditing: DataEditing where InputType == MorningRegistrationInfo,
                                                       ReturnType == (photoLink: String, updateBadges: [Badge]) {
    func request(_ data: InputType) -> Single<ReturnType>
}

public struct MyMorningDataEditor: MyMorningDataEditing {
    public typealias ReturnType = (photoLink: String, updateBadges: [Badge])
    public typealias Firebase = FirebaseStorageService

    private let remoteStorageManager: any RemoteStorageType
//    private let networkClient: ApolloClient

    public init(
        _ remoteStorageManager: any RemoteStorageType = RemoteStorageManager<Firebase>()
//        _ networkClient: ApolloClientProtocol = Network.shared.apollo
    ) {
        self.remoteStorageManager = remoteStorageManager
//        self.networkClient = networkClient
    }
}

public extension MyMorningDataEditor {
    func request(_ data: MorningRegistrationInfo) -> Single<ReturnType> {
        let singleTrait = remoteStorageManager
            .saveImage(data.image)
            .map { photoUrl -> PhotoInput in
                return data.toApolloMuataionType(photoLink: photoUrl)
            }
            .map { requestMutation($0) }
            .flatMap { $0 }

        return singleTrait
    }
}

private extension MyMorningDataEditor {
    func requestMutation(_ photoInput: PhotoInput) -> Single<ReturnType> {
        let singleTrait = Network.shared.apollo.rx
            .perform(mutation: SaveMyPhotoMutation(input: .some(photoInput)))
            .map { data -> SaveMyPhotoMutation.Data.SaveMyPhoto in
                guard let mutationResult = data.data else {
                    throw DataEditorError.cannotGetResponseFromServer
                }
                
                guard let valueInResult = mutationResult.saveMyPhoto else {
                    throw DataEditorError.emptyResponse
                }
                
                return valueInResult
            }
            .map { mutationResult -> ReturnType in
                guard let photoLink = mutationResult.photoLink else {
                    throw DataEditorError.invalidPayloadData
                }
                
                guard let receivedBadges = mutationResult.updatedBadge,
                      receivedBadges.contains(nil)
                else {
                    throw DataEditorError.invalidPayloadData
                }
                
                let updatedBadges = receivedBadges.compactMap { $0?.toNativeType }
                
                return (photoLink, updatedBadges)
            }
        
        return singleTrait
    }
}

fileprivate extension MorningRegistrationInfo {
    func toApolloMuataionType(photoLink: URL) -> PhotoInput {
        return PhotoInput(
            photoId: .some("?"),
            photoLink: .some(photoLink.absoluteString),
            photoDesc: .some(self.comment),
            categoryId: .some("0"),
            startAt: .some(self.startTime.toString()),
            endAt: .some(self.endTime.toString())
        )
    }
}

fileprivate extension SaveMyPhotoMutation.Data.SaveMyPhoto.UpdatedBadge {
    var toNativeType: Badge {
        // TODO: Get badge id
        Badge(image: MorningBearUIAsset.Images.streakTen.image,
              title: self.badgeTitle ?? "",
              desc: self.badgeDesc ?? "")
    }
}
