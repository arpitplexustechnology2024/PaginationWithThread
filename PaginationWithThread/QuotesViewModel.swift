//
//  ItemViewModel.swift
//  PaginationWithThread
//
//  Created by Arpit iOS Dev. on 28/06/24.
//

import Foundation
import RxSwift
import RxCocoa

class QuotesViewModel {
    private let networkManager = NetworkManager.shared
    private let disposeBag = DisposeBag()
    private var currentPage = 1
    private var isFetching = false

    let quotes = BehaviorRelay<[QuoteResult]>(value: [])
    let error = PublishSubject<Error>()
    let loading = BehaviorRelay<Bool>(value: false)

    func fetchQuotes() {
        guard !isFetching else { return }
        isFetching = true
        loading.accept(true)

        networkManager.fetchQuotes(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            
            // Simulate a delay
            Observable.just(result)
                .delay(.seconds(1), scheduler: MainScheduler.instance)
                .subscribe(onNext: { result in
                    self.isFetching = false
                    self.loading.accept(false)

                    switch result {
                    case .success(let welcome):
                        self.quotes.accept(self.quotes.value + welcome.results)
                        self.currentPage += 1
                    case .failure(let error):
                        print("Fetch Error: \(error)")
                        self.error.onNext(error)
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }
}
