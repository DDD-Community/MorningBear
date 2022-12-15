// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MorningBearAPI

public class LoginBaseInfo: MockObject {
  public static let objectType: Object = MorningBearAPI.Objects.LoginBaseInfo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<LoginBaseInfo>>

  public struct MockFields {
    @Field<String>("jsKey") public var jsKey
    @Field<String>("nativeKey") public var nativeKey
    @Field<String>("redirectUri") public var redirectUri
    @Field<String>("state") public var state
  }
}

public extension Mock where O == LoginBaseInfo {
  convenience init(
    jsKey: String? = nil,
    nativeKey: String? = nil,
    redirectUri: String? = nil,
    state: String? = nil
  ) {
    self.init()
    self.jsKey = jsKey
    self.nativeKey = nativeKey
    self.redirectUri = redirectUri
    self.state = state
  }
}
