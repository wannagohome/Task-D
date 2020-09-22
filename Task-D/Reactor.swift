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
    }
    
    enum Mutation {
        case setList([Room])
        case appendList([Room])
        case setAverage([Average])
        case setLoading(Bool)
        case setPage(Int)
    }
    
    struct State {
        var roomList: [Room]?
        var average: [Average]?
        var page = 1
        var isLoading: Bool = false
        var isLastPage: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        let startLoading = Observable<Mutation>.just(.setLoading(true))
        let endLoading = Observable<Mutation>.just(.setLoading(false))
        let firstPage = Observable<Mutation>.just(.setPage(1))
        let nextPage = Observable<Mutation>.just(.setPage(self.currentState.page+1))
        
        switch action {
        case .getWholeList:
            guard !self.currentState.isLoading else { return .empty() }
            guard !self.currentState.isLastPage else { return .empty() }
            let getList = model.getRoom(page: self.currentState.page)
                .asObservable()
                .map { Mutation.setList($0) }
            let getAverage = model.getAverage()
                .asObservable()
                .map { Mutation.setAverage($0) }
            return .concat([startLoading, firstPage, getList, getAverage, endLoading])
            
        case .loadNextPage:
            guard !self.currentState.isLoading else { return .empty() }
            guard !self.currentState.isLastPage else { return .empty() }
            let appendList = model.getRoom(page: self.currentState.page)
                .asObservable()
                .map { Mutation.appendList($0) }
            return .concat([startLoading, nextPage, appendList, endLoading])
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
        }
        return newState
    }
}
