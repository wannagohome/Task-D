//
//  ViewController.swift
//  Task-D
//
//  Created by jinho jang on 2020/09/21.
//  Copyright © 2020 Pete. All rights reserved.
//

import UIKit
import ReactorKit
import RxCocoa


final class ViewController: UIViewController, StoryboardView {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        tableView.register(RightCell.nib(), forCellReuseIdentifier: "RightCell")
        tableView.register(LeftCell.nib(), forCellReuseIdentifier: "LeftCell")
        tableView.register(AverageCell.nib(), forCellReuseIdentifier: "AverageCell")
        tableView.separatorStyle = .none
    }
    
    func bind(reactor: RoomListReactor) {
        self.searchBar.rx.text.orEmpty
            .skip(1)
            .distinctUntilChanged()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.getWholeList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.tableView.rx.isReachedBottom
            .map { Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let firstPage = reactor.state
            .compactMap { $0.roomList?.prefix(12).map { $0 as Decodable } }
        let average = reactor.state
            .compactMap { $0.average?.map { $0 as Decodable } }
        let nextPages = reactor.state
            .compactMap { $0.roomList?.dropFirst(12).map { $0 as Decodable } }
        
        Observable.combineLatest(firstPage, average, nextPages) { $0 + $1 + $2 }
            .bind(to: self.tableView.rx.items) { tb, row, data in
                if let room = data as? Room {
                    if room.roomType ?? 0 < 2 {
                        let cell = tb.dequeueReusableCell(withIdentifier: "RightCell") as! RightCell
                        cell.selectionStyle = .none
                        cell.room = room
                        return cell
                    } else {
                        let cell = tb.dequeueReusableCell(withIdentifier: "LeftCell") as! LeftCell
                        cell.selectionStyle = .none
                        cell.room = room
                        return cell
                    }
                } else {
                    let average = data as! Average
                    let cell = tb.dequeueReusableCell(withIdentifier: "AverageCell") as! AverageCell
                    cell.average = average
                    return cell
                }
        }
    .disposed(by: disposeBag)
    }
}
