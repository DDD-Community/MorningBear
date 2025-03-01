//
//  MyPageQuery.swift
//  MorningBearDataProvider
//
//  Created by Young Bin on 2023/02/12.
//  Copyright © 2023 com.dache. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import Apollo

@_exported import MorningBearData
import MorningBearUI
import MorningBearAPI
import MorningBearNetwork

public struct MyPageQuery: Queryable {
    private let apolloClient: ApolloClient
    
    public var singleTrait: Single<MyPageData> {
        apolloClient.rx.fetch(query: GetMyPageDataQuery())
            .map { data -> GetMyPageDataQuery.Data.FindMyInfo in
                guard let data = data.data else {
                    throw DataProviderError.cannotGetResponseFromServer
                }
                
                guard let findMyInfo = data.findMyInfo else {
                    throw DataProviderError.invalidPayloadData(message: "잘못된 쿼리 응답(\(#function)")
                }
                
                return findMyInfo
            }
            .map { findMyInfo -> MyPageData in
                try findMyInfo.toNativeType()
            }
    }
    
    public init(_ apolloClient: ApolloClient = Network.shared.apollo) {
        self.apolloClient = apolloClient
    }
}

extension GetMyPageDataQuery.Data.FindMyInfo: ApolloAdaptable {
    typealias Category = MorningBearData.Category
    
    public func toNativeType() throws -> MyPageData {
        guard let photoLink, let profileImageURL = URL(string: photoLink), let nickName else {
            throw DataProviderError.invalidPayloadData(message: "프로필을 불러올 수 없음")
        }
        
        let profile = Profile(
            imageURL: profileImageURL,
            nickname: nickName,
            counts: Profile.CountContext(
                postCount: self.reportInfo?.countSucc ?? 0,
                supportCount: self.takenLikeCnt ?? 0,
                badgeCount: self.badgeList?.count ?? 0
            )
        )
        
        let categories: [Category] = try (self.categoryList ?? []).compactMap { categorySet throws -> Category in
            guard let categorySet else {
                throw DataProviderError.invalidPayloadData(message: "잘못된 응답")
            }
            
            guard let stringId = categorySet.categoryId else {
                throw DataProviderError.invalidPayloadData(message: "잘못된 카테고리 아이디")
            }
            
            guard let category = Category.fromId(stringId) else {
                throw DataProviderError.invalidPayloadData(message: "잘못된 카테고리 정보")
            }
            
            return category
        }
        
        let unwrappedPhotoInfoByCategory = (self.photoInfoByCategory ?? []).compactMap { $0 }
        
        var photos = MyPageData.PhotoDictionary()
        try unwrappedPhotoInfoByCategory.forEach { photoInfoByCategory throws in
            guard var photoInfos = photoInfoByCategory.photoInfo else {
                throw DataProviderError.invalidPayloadData(message: "잘못된 사진 정보")
            }
            
            photoInfos = photoInfos.compactMap { $0 }
            
            photoInfos.forEach { photoInfo in
                guard let link = photoInfo?.photoLink,
                      let url = URL(string: link),
                      let photoId = photoInfo?.photoId,
                      let categoryId = photoInfo?.categoryId,
                      let category = Category.fromId(categoryId)
                else {
                    return
                }
                
                let morning = MyMorning(id: photoId, imageURL: url)
                
                photos[category, default: []].append(morning)
            }
        }
        
        return MyPageData(profile: profile, favoriteCategories: categories, photos: photos)
    }
}
