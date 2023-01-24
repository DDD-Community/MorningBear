//
//  HomeViewModel.swift
//  MorningBear
//
//  Created by 이영빈 on 2022/12/28.
//  Copyright © 2022 com.dache. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import MorningBearDataProvider
import MorningBearKit

class HomeViewModel<Provider: DataProviding> {
    private var dataProvider: HomeViewDataProvider // FIXME: 로컬 저장소 관련 분리할 것
    
    private var bag = DisposeBag()
    
    // MARK: Public stored properties
    var state: State?
    var recentMorningList: [RecentMorning] = []
    var badgeList: [Badge] = []
    var articleList: [Article] = []

    // MARK: Observables
    /// `accept`로 인한 수정을 막기 위해 Relay를 `observable`로 변환해서 씀
    /// - warning: `Observable`의 상태는 직접 수정되어서는 안됨.
    ///     반드시 `startRecording`, `stopRecording`에 의해서만 수정될 수 있도록 유의할 것
    @Bound(MyInfo()) var myInfo: MyInfo
    @Bound([]) var recentMornings: [RecentMorning]
    @Bound([]) var badges: [Badge]
    @Bound([]) var articles: [Article]
    
    private var myInfoRelay: BehaviorRelay<MyInfo>
    var myInfoObservable: Observable<MyInfo> {
        myInfoRelay.asObservable()
    }
    
    private var elapsedTimeRelay: BehaviorRelay<String>
    var elapsedTimeObservable: Observable<String> {
        elapsedTimeRelay.asObservable()
    }
    
    private var recordingStateRelay: BehaviorRelay<MyMorningRecordingState>
    var recordingStateObservable: Observable<MyMorningRecordingState> {
        recordingStateRelay.asObservable()
    }
    
    func fetchRemoteData() {
        dataProvider.fetch(BadgeQuery())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onSuccess: { data in
                print("@@ badge", data)
                self.badges = data
            }, onFailure: { print("@@", $0) })
            .disposed(by: bag)
        
        dataProvider.fetch(HomeQuery())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onSuccess: { [weak self] badges, myInfo, mornings, articles in
                guard let self else { return }
                
                print("@@", badges, myInfo, mornings, articles)
                
                self.myInfo = myInfo
                self.recentMornings = mornings
                self.badges = badges
                self.articles = articles
            }, onFailure: { print("@@", $0) })
            .disposed(by: bag)
    }
    
    init(_ dataProvider: Provider = HomeViewDataProvider()) {
        self.dataProvider = dataProvider as! HomeViewDataProvider
        
        self.elapsedTimeRelay = BehaviorRelay<String>(value: "00:00:00")
        self.recordingStateRelay = BehaviorRelay<MyMorningRecordingState>(value: .waiting)
        self.myInfoRelay = BehaviorRelay<MyInfo>(value: MyInfo())
    
        // 리코딩 기록 있으면 녹화 재개
        if case .recording(let startDate) = fetchMyMorningRecordingState {
            startRecording(with: startDate)
        }
        
        fetchRemoteData()
    }
}

// MARK: - Public tools
extension HomeViewModel {
    var isMyMorningRecording: MyMorningRecordingState {
        recordingStateRelay.value
    }
    
    /// 기록을 시작함. 시작 시간 주어지지 않으면 현재 시간으로 자동 설정
    func startRecording(with startDate: Date = Date()) {
        guard isMyMorningRecording == .waiting || isMyMorningRecording == .stop else {
            return
        }
        
        timeIntervalObservable(from: startDate)
            .bind(to: elapsedTimeRelay)
            .disposed(by: bag)
        
        recordingStateRelay.accept(.recording(startDate: startDate))
    }
    
    func stopRecording() throws -> Date {
        if case .recording(let startDate) = isMyMorningRecording {
            bag = DisposeBag() // reset bindings
            configureBindings() // set bindings again
            
            recordingStateRelay.accept(.stop)
            return startDate
        } else {
            
            recordingStateRelay.accept(.stop)
            throw HomeError.stopRecordingWhileIdle
        }
    }
}

// MARK: - Internal tools
private extension HomeViewModel {
    func configureBindings() {
        recordingStateObservable.withUnretained(self)
            .bind { weakSelf, state in
                // Setter
                switch state {
                case .recording(startDate: let date):
                    weakSelf.dataProvider.persistentMyMorningRecordDate = date
                case .stop:
                    weakSelf.elapsedTimeRelay.accept("00:00:00")
                    weakSelf.dataProvider.persistentMyMorningRecordDate = nil
                case .waiting:
                    weakSelf.elapsedTimeRelay.accept("00:00:00")
                }
            }
            .disposed(by: bag)
    }
    
    var fetchMyMorningRecordingState: MyMorningRecordingState {
        if let savedDate = dataProvider.persistentMyMorningRecordDate {
            return .recording(startDate: savedDate)
        } else {
            return .stop
        }
    }
    
    var timerObservable: Observable<Int> {
        return Observable<Int>.interval(
            .seconds(1), scheduler: SerialDispatchQueueScheduler(qos: .background)
        )
    }
    
    func timeIntervalObservable(from startDate: Date) -> Observable<String> {
        let stringObservable = timerObservable.withUnretained(self)
            .map { (weakSelf, elapsedTime) -> String in
                let current = Date()
                
                let diffComponents = Calendar.current.dateComponents(
                    [.hour, .minute, .second], from: startDate, to: current
                )
                
                let timeString = String(
                    format: "%02d:%02d:%02d", diffComponents.hour ?? 0, diffComponents.minute ?? 0, diffComponents.second ?? 0
                )
                
                return timeString
            }
        
        return stringObservable
    }
}

private extension HomeViewModel {
    enum HomeError: LocalizedError {
        case stopRecordingWhileIdle
        
        var errorDescription: String? {
            switch self {
            case .stopRecordingWhileIdle:
                return "잘못된 동작입니다. 다시 시도해주세요"
            }
        }
    }
}

enum MyMorningRecordingState: Equatable {
    case recording(startDate: Date)
    case stop
    case waiting
}
