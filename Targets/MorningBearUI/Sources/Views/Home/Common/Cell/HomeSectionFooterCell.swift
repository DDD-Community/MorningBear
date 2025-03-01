//
//  HomeSectionFooterCell.swift
//  MorningBear
//
//  Created by 이영빈 on 2022/12/26.
//  Copyright © 2022 com.dache. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

public class HomeSectionFooterCell: UICollectionViewCell {
    public typealias Action = () -> Void
    
    // View components
    @IBOutlet weak var button: UIButton! {
        didSet {
            configureFont()
            designCell()
        }
    }
    
    // Internal variables
    private let bag = DisposeBag()
    private var buttonAction: Action = {}
    
    /// 버튼이 바인드 되었는지 확인하는 플래그 변수(중복 바인드 방지)
    private var isButtonBound = false
    
    // Methods
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        
        prepareCell(buttonText: nil, buttonAction: nil)
        bindButton()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        prepareCell(buttonText: nil, buttonAction: nil)
    }
}


// MARK: Public tools
extension HomeSectionFooterCell {
    public func prepare(buttonText text: String, buttonAction action: @escaping Action) {
        prepareCell(buttonText: text, buttonAction: action)
    }
}


// MARK: Internal tools
extension HomeSectionFooterCell {
    /// 내부용 셀 설정 함수
    private func prepareCell(buttonText: String?, buttonAction: Action? = nil) {
        self.button.setTitle(buttonText, for: .normal)
        self.buttonAction = buttonAction ?? {}
    }
    
    /// 버튼에 탭 액션 설정
    private func bindButton() {
        guard isButtonBound == false else {
            return
        }
        
        self.button.rx.tap.bind { [weak self] in
            guard let self = self else {
                return
            }
            
            self.buttonAction()
            self.isButtonBound = true
        }
        .disposed(by: bag)
        
    }
    
    /// 기타 모양, 디자인요소 설정
    private func designCell() {
        button.backgroundColor = MorningBearUIAsset.Colors.gray800.color
        button.sizeToFit()
        
        button.layer.cornerRadius = 10
        
        // Set shadows
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 15
    }
    
    /// 폰트 설정
    private func configureFont() {
        button.titleLabel?.font = MorningBearUIFontFamily.Pretendard.bold.font(size: 16)
        button.setTitleColor(.white, for: .normal)
    }
}
