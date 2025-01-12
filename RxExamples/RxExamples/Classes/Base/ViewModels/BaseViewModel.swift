//
//  BaseViewModel.swift
//  RxExamples
//
//  Created by jinxiansen on 2019/6/17.
//  Copyright © 2019 晋先森. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

class BaseViewModel: NSObject {

    let error = ErrorTracker()
    let parseError = PublishSubject<ResultError>()

    let loading = ActivityIndicator() //
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()

    let disposeBag = DisposeBag()
    var page = 1

    override init() {
        super.init()

        error.asObservable().map { error -> ResultError? in
            if let errResponse = error as? ResultError {
                return errResponse
            }
            return nil
            }.filterNil().bind(to: parseError).disposed(by: rx.disposeBag)

        error.asDriver().drive(onNext: { error in
            logError(" \(type(of: self).nameOfClass) Response Failed：\(error)")
        }).disposed(by: rx.disposeBag)
    }

}
