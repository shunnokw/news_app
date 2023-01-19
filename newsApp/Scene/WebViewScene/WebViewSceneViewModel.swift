//
//  WebViewSceneViewModel.swift
//  newsApp
//
//  Created by Jason Wong on 19/1/2023.
//

import Foundation
import RxCocoa
import RxSwift

class WebViewSceneViewModel: ViewModelType {
    struct Input {
        let bookmarkBtnTapEvent: Signal<Void>
    }
    
    struct Output {
        let urlDriver: Driver<URL?>
        let isBookmarkedDriver: Driver<Bool>
        let otherSignal: Signal<Void>
    }
    
    let title: String?
    private let article: Article
    private let isBookmarkRelay: BehaviorRelay<Bool>
    private let userDefaultManager: UserDefaultManagerType
    
    init(article: Article, userDefaultManager: UserDefaultManagerType) {
        self.article = article
        self.title = article.title
        self.userDefaultManager = userDefaultManager
        self.isBookmarkRelay = .init(value: userDefaultManager.checkIsBookmarked(article: article))
    }
    
    func transform(input: Input) -> Output {
        
        let urlDriver: Driver<URL?> = Driver.of(article.url).map {
            urlString in
            guard let urlString = urlString,
                  let url = URL(string: urlString)
            else { return nil }
            return url
        }
        
        let otherSignal = input.bookmarkBtnTapEvent.map {
            _ in
            if self.isBookmarkRelay.value {
                self.userDefaultManager.removeBookmark(article: self.article)
            } else {
                self.userDefaultManager.addBookmark(article: self.article)
            }
            self.isBookmarkRelay.accept(self.userDefaultManager.checkIsBookmarked(article: self.article))
        }
    
    return Output(
        urlDriver: urlDriver,
        isBookmarkedDriver: isBookmarkRelay.asDriver(),
        otherSignal: otherSignal
    )
}
}