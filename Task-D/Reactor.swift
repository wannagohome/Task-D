//
//  Reactor.swift
//  Task-D
//
//  Created by jinho jang on 2020/09/22.
//  Copyright © 2020 Pete. All rights reserved.
//

import ReactorKit

final class RoomListReactor: Reactor {
    let initialState = State()
    let model: Model
    init(model: Model = Model()) {
        self.model = model
    }
    
    enum Action {
        case getWholeList
        case loadNextPage
        case filterRoomType(Int)
        case filterSellingType(Int)
        case switchSortation
    }
    
    enum Mutation {
        case setList([Room])
        case appendList([Room])
        case setAverage([Average])
        case setLoading(Bool)
        case setPage(Int)
        case setRoomTypeFilter(Int)
        case setSellingTypeFilter(Int)
        case switchSortation
    }
    
    struct State {
        var roomList: [Room]?
        var average: [Average]?
        var page = 1
        var isLoading: Bool = false
        var isLastPage: Bool = false
        var roomTypeFilter: [Int] = [0,1,2,3]
        var sellTypeFilter: [Int] = [0,1,2]
        var sort: Sort = .ascending
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        let startLoading = Observable<Mutation>.just(.setLoading(true))
        let endLoading = Observable<Mutation>.just(.setLoading(false))
        let firstPage = Observable<Mutation>.just(.setPage(1))
        let nextPage = Observable<Mutation>.just(.setPage(self.currentState.page+1))
        let getList = model.getRoom()
            .asObservable()
            .map { room -> [Room] in
                room.sorted {
                    if self.currentState.sort == .ascending {
                        return $0.price > $1.price
                    } else {
                        return $0.price < $1.price
                    }
                }
        }
        .map {
            $0.filter {
                self.currentState.roomTypeFilter.contains($0.roomType!) &&
                        self.currentState.sellTypeFilter.contains($0.sellingType!)
                }
        }
        .map { $0.at(page: self.currentState.page) }

        let setList = getList.map { Mutation.setList($0) }
        let appendList = getList.map { Mutation.appendList($0) }
        let getAverage = model.getAverage()
            .asObservable()
            .map { Mutation.setAverage($0) }
        
        switch action {
        case .getWholeList:
            guard !self.currentState.isLoading else { return .empty() }
            guard !self.currentState.isLastPage else { return .empty() }
            

            return .concat([startLoading, firstPage, setList, getAverage, endLoading])
            
        case .loadNextPage:
            guard !self.currentState.isLoading else { return .empty() }
            guard !self.currentState.isLastPage else { return .empty() }
            return .concat([startLoading, nextPage, appendList, endLoading])
            
        case .filterRoomType(let n):
            let filtering = Observable.just(Mutation.setRoomTypeFilter(n))
            return .concat([startLoading, filtering, firstPage, setList, getAverage, endLoading])
            
        case .filterSellingType(let n):
            let filtering = Observable.just(Mutation.setSellingTypeFilter(n))
            return .concat([startLoading, filtering, firstPage, setList, getAverage, endLoading])
            
        case .switchSortation:
            let sorting = Observable.just(Mutation.switchSortation)
            return .concat([startLoading, sorting, firstPage, setList, getAverage, endLoading])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setList(let list):
            newState.roomList = list
            newState.isLastPage = false
            
        case .appendList(let list):
            newState.roomList?.append(contentsOf: list)
            newState.isLastPage = list.count == 0
            
        case .setAverage(let average):
            newState.average = average
            
        case .setLoading(let bool):
            newState.isLoading = bool
            
        case .setPage(let page):
            newState.page = page
            
        case .setRoomTypeFilter(let n):
            if newState.roomTypeFilter.contains(n) {
                newState.roomTypeFilter.remove(at: newState.roomTypeFilter.firstIndex(of: n)!)
            } else {
                newState.roomTypeFilter.append(n)
            }
            
        case .setSellingTypeFilter(let n):
            if newState.sellTypeFilter.contains(n) {
                newState.sellTypeFilter.remove(at: newState.sellTypeFilter.firstIndex(of: n)!)
            } else {
                newState.sellTypeFilter.append(n)
            }
            
        case .switchSortation:
            if newState.sort == .ascending {
                newState.sort = .descending
            } else {
                newState.sort = .ascending
            }
        }
        return newState
    }
}

enum Sort {
    case ascending
    case descending
}
