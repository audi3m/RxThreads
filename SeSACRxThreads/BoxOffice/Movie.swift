//
//  Movie.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/8/24.
//

import Foundation

struct Movie: Decodable, Sequence {
    let boxOfficeResult: BoxOfficeResult
    
    func makeIterator() -> Array<DailyBoxOfficeList>.Iterator {
        return boxOfficeResult.dailyBoxOfficeList.makeIterator()
    }
}

struct BoxOfficeResult: Decodable {
    let dailyBoxOfficeList: [DailyBoxOfficeList]
}

struct DailyBoxOfficeList: Decodable {
    let movieNm: String
    let openDt: String
}
