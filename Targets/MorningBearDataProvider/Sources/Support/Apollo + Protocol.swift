//
//  ApolloAdapting.swift
//  MorningBearData
//
//  Created by Young Bin on 2023/02/12.
//  Copyright © 2023 com.dache. All rights reserved.
//

import Apollo
import ApolloAPI

public protocol ApolloAdaptable: SelectionSet {
    associatedtype NativeType: Hashable
    
    func toNativeType() throws -> NativeType
}

public protocol ApolloNetworking {
    var apolloClient: ApolloClient { get }
}
