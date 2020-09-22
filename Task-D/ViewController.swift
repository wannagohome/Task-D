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
    
    @IBOutlet weak var oneRoom: FilterButton!
    @IBOutlet weak var twoRoom: FilterButton!
    @IBOutlet weak var officetel: FilterButton!
    @IBOutlet weak var apartment: FilterButton!
    
    @IBOutlet weak var month: FilterButton!
    @IBOutlet weak var year: FilterButton!
    @IBOutlet weak var sell: FilterButton!
    
    @IBOutlet weak var sort: FilterButton!
    
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
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .map { Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.of(oneRoom.rx.tap.map{0},
                      twoRoom.rx.tap.map{1},
                      officetel.rx.tap.map{2},
                      apartment.rx.tap.map{3})
            .merge()
            .map { Reactor.Action.filterRoomType($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.of(month.rx.tap.map{0},
                      year.rx.tap.map{1},
                      sell.rx.tap.map{2})
            .merge()
            .map { Reactor.Action.filterSellingType($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sort.rx.tap
            .map { Reactor.Action.switchSortation }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let firstPage = reactor.state
            .compactMap { $0.roomList?.prefix(12).map { $0 as Decodable } }
            .do(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
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
    
    @IBAction func tapButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
}
