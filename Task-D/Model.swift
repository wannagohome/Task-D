//
//  Model.swift
//  Task-D
//
//  Created by jinho jang on 2020/09/22.
//  Copyright © 2020 Pete. All rights reserved.
//

import Foundation
import RxSwift

struct Model {
    private func getRoomList() -> Single<RoomList> {
        return Single<RoomList>.create { observer in
            guard let url = Bundle.main.path(forResource: "RoomListData", ofType: "txt") else {
                observer(.error(RoomError.fileNotFound))
                return Disposables.create {}
            }
            
            guard let data = try? String(contentsOfFile: url).data(using: .utf8) else {
                observer(.error(RoomError.encodingError))
                return Disposables.create {}
            }
            
            guard let room = try? JSONDecoder().decode(RoomList.self, from: data) else {
                observer(.error(RoomError.decodingError))
                return Disposables.create {}
            }
            observer(.success(room))
            
            return Disposables.create {}
        }
    }
    
    func getRoom(page: Int) -> Single<[Room]> {
        return getRoomList().map { $0.rooms?.at(page: page) ?? [] }
    }
    
    func getAverage() -> Single<[Average]> {
        return getRoomList().map { $0.average ?? [] }
    }
}


enum RoomError: Error {
    case fileNotFound
    case encodingError
    case decodingError
}


extension Array {
    func at(page: Int) -> [Element] {
        Array(self[Swift.min((page-1) * 12, self.count) ..< Swift.min(page * 12, self.count)])
    }
}
