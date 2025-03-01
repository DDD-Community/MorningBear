// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MorningBearAPI

public class Mutation: MockObject {
  public static let objectType: Object = MorningBearAPI.Objects.Mutation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Mutation>>

  public struct MockFields {
    @Field<User>("saveMyInfo") public var saveMyInfo
    @Field<Photo>("saveMyPhoto") public var saveMyPhoto
  }
}

public extension Mock where O == Mutation {
  convenience init(
    saveMyInfo: Mock<User>? = nil,
    saveMyPhoto: Mock<Photo>? = nil
  ) {
    self.init()
    self.saveMyInfo = saveMyInfo
    self.saveMyPhoto = saveMyPhoto
  }
}
