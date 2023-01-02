//
//  SceneDelegate.swift
//  MorningBear
//
//  Created by 이건우 on 2022/12/07.
//  Copyright © 2022 com.dache. All rights reserved.
//

import UIKit
import MorningBearUI

import RxKakaoSDKAuth
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
//        let viewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "OnboardingVC")
        // FIXME: .
        let mainViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home")
        let navigationController = UINavigationController(rootViewController: mainViewController)
        let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "Login")
        
        // Design navigation controller
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = MorningBearUIAsset.Colors.gray100.color
        
        appearance.titleTextAttributes = [
            .font: MorningBearUIFontFamily.Pretendard.bold.font(size: 20)
        ]
        
        let backButton = MorningBearUIAsset.Asset.backArrow.image.withTintColor(.black, renderingMode: .alwaysOriginal)
        appearance.setBackIndicatorImage(backButton, transitionMaskImage: backButton)

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.topItem?.backButtonTitle = ""
//        navigationController.hidesBarsOnSwipe = true

        // Set root view
        window.rootViewController = navigationController // 루트 뷰컨트롤러 생성
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }
}
