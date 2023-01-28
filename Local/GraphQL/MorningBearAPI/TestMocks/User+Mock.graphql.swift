// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MorningBearAPI

public class User: MockObject {
  public static let objectType: Object = MorningBearAPI.Objects.User
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<User>>

  public struct MockFields {
    @Field<String>("accountId") public var accountId
    @Field<[BadgeDetail?]>("badgeList") public var badgeList
    @Field<String>("memo") public var memo
    @Field<String>("nickName") public var nickName
    @Field<[Photo?]>("photoInfo") public var photoInfo
    @Field<String>("photoLink") public var photoLink
    @Field<Report>("reportInfo") public var reportInfo
    @Field<String>("wakeUpAt") public var wakeUpAt
  }
}

public extension Mock where O == User {
  convenience init(
    accountId: String? = nil,
    badgeList: [Mock<BadgeDetail>?]? = nil,
    memo: String? = nil,
    nickName: String? = nil,
    photoInfo: [Mock<Photo>?]? = nil,
    photoLink: String? = nil,
    reportInfo: Mock<Report>? = nil,
    wakeUpAt: String? = nil
  ) {
    self.init()
    self.accountId = accountId
    self.badgeList = badgeList
    self.memo = memo
    self.nickName = nickName
    self.photoInfo = photoInfo
    self.photoLink = photoLink
    self.reportInfo = reportInfo
    self.wakeUpAt = wakeUpAt
  }
}
