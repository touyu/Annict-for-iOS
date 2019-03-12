//
//  HomeViewController.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2018/10/23.
//  Copyright © 2018 Yuto Akiba. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift

final class HomeViewController: UIViewController, StoryboardView {
    typealias Reactor = HomeViewReactor

    @IBOutlet weak var tableView: UITableView!

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(ActivityRecordTableViewCell.self,
                           ActivityStatusTableViewCell.self)
        tableView.tableFooterView = UIView()
    }

    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .take(1)
            .map { Reactor.Action.fetchActivities }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        tableView.rx.setDataSource(self)
            .disposed(by: disposeBag)

        reactor.state.map { $0.activities }
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reactor = reactor else { return 0 }
        return reactor.currentState.activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reactor = reactor else { return .init() }
        let acitivity = reactor.currentState.activities[indexPath.row]
        switch acitivity.itemType {
        case .status(let item):
            let cell = tableView.dequeueReusableCell(classType: ActivityStatusTableViewCell.self, for: indexPath)
            cell.configure(activityItem: item)
            return cell
        case .record(let item):
            let cell = tableView.dequeueReusableCell(classType: ActivityRecordTableViewCell.self, for: indexPath)
            cell.configure(activityItem: item)
            return cell
        case .review(let item):
            return .init()
        case .multipleRecord(let item):
            return .init()
        case .unknown:
            return .init()
        }
    }
}
