//
//  SearchViewController.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2018/11/30.
//  Copyright © 2018 Yuto Akiba. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

final class SearchViewController: UIViewController, StoryboardView {
    typealias Reactor = SearchViewReactor

    @IBOutlet private weak var collectionView: UICollectionView!

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: SearchResultViewController.loadStoryboard())
        sc.searchBar.searchBarStyle = .minimal
        sc.searchResultsUpdater = self
        sc.hidesNavigationBarDuringPresentation = false
        sc.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        return sc
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reactor = Reactor()

        prepareNavigationBar()
        prepareCollectionView()
    }

    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .take(1)
            .map { Reactor.Action.fetchWorksOfThisTerm }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.works }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func prepareNavigationBar() {
        navigationItem.titleView = searchController.searchBar
        navigationItem.titleView?.frame = searchController.searchBar.frame
        navigationController?.navigationBar.transparent()
    }

    private func prepareCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellTypes: UserWorkCollectionViewCell.self)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let reactor = reactor else { return 0 }
        return reactor.currentState.works.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let reactor = reactor else { return .init() }
        let work = reactor.currentState.works[indexPath.item]
        let cell = collectionView.dequeueReusableCell(type: UserWorkCollectionViewCell.self, for: indexPath)
        cell.prepare(url: work.image?.twitterAvatarUrl, title: work.title)
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let colmunCount: CGFloat = 3
        let width = (collectionView.bounds.width - 16 * (colmunCount + 1)) / colmunCount
        let height = width * 129 / 88
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

    }
}