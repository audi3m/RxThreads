//
//  NetworkManager.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/8/24.
//

import Foundation
import Alamofire
import RxSwift


enum APIError: Error {
    case invalidURL
    case unknownResponse
    case statusError
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() { }
    
    // Observable 객체로 통신
    static let jokeURL = "https://v2.jokeapi.dev/joke/Programming?type=single"
    
    func fetchJoke() -> Observable<Joke> {
        
        return Observable.create { observer -> Disposable in
            
            AF.request(NetworkManager.jokeURL)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: Joke.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer.onNext(success)
                        observer.onCompleted() // *****
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
        .debug("JOKE API 통신")
    }
    
    // Single 객체로 통신
    func fetchJokeWithSingle() -> Single<Joke> {
        
        // Single 객체로 통신 + Result Type
        return Single.create { observer -> Disposable in
            
            AF.request(NetworkManager.jokeURL)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: Joke.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer(.success(success)) // onNext + onComplete
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
        .debug("JOKE API 통신")
    }
    
    // Result
    func fetchJokeWithSingleResultType() -> Single<Joke> {
        
        return Single.create { observer -> Disposable in
            
            AF.request(NetworkManager.jokeURL)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: Joke.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer(.success(success)) // onNext + onComplete
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
        .debug("JOKE API 통신")
    }
    
    // combineLatest, withLatestFrom, zip, just, debounce랑 비슷한 형태
    func callBoxOffice(date: String) -> Observable<Movie> {
        
        let result = Observable<Movie>.create { observer in
            guard let url = URL(string: APIKey.url + date) else {
                observer.onError(APIError.invalidURL)
                return Disposables.create()
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error != nil {
                    observer.onError(APIError.unknownResponse)
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                    observer.onError(APIError.statusError)
                    return
                }
                
                if let data, let appData = try? JSONDecoder().decode(Movie.self, from: data) {
                    observer.onNext(appData)
                    observer.onCompleted() // 누수 제거
                } else {
                    print("응답 ㅇ, 디코딩 실패")
                    observer.onError(APIError.unknownResponse)
                }
                
            }.resume()
            
            return Disposables.create()
        }
            .debug("박스오피스 조회")
        // 박스오피스 조회 -> subscribed
        // 계속 구독해서 메모리 누수 생김
        // -> onCompleted 해주어야 함
        // create에서 next + complete -> ㄴ
        
        return result
    }
    
    func requestBoxOffice(date: String) -> Single<Movie> {
        return Single.create { observer -> Disposable in
            
            AF.request(APIKey.url + date)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: Movie.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer(.success(success))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
        .debug("박스오피스 API 통신")
    }
}


// subscribe -> next error complete (RxSwift)
//
// bind -> next처리. error 없음: UI에 좋음 (RxCocoa)
//   tap 한번이지만 다 개별적으로
//   대부분 메인쓰레드. Binder가 main
// drive -> next처리. (bind+share)
//   같은 값. share 내부적으로 저장
//   항상 메인쓰레드에서 진행. stream이 공유됨
