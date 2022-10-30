//
//  PhotoViewController.swift
//  UnsplashExample
//
//  Created by 박관규 on 2022/10/29.
//

import UIKit
import RxSwift
import RxCocoa

class PhotoViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = PhotoViewModel()
    
    let disposeBag = DisposeBag()
    
    private var dataSource : UICollectionViewDiffableDataSource<Int, SearchResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
        collectionView.delegate = self
        
        bindData()
    }
    
    func bindData() {
        viewModel.photoList
            .withUnretained(self)
            .subscribe(onNext: { (vc, photo) in
                var snapshot = NSDiffableDataSourceSnapshot<Int, SearchResult>()
                snapshot.appendSections([0])
                snapshot.appendItems(photo.results)
                vc.dataSource.apply(snapshot)
            }, onError: { error in
                print("=== error: \(error)")
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { (vc, value) in
                vc.viewModel.requestSearchPhoto(query: value)
            }
            .disposed(by: disposeBag)
    }
    
}

extension PhotoViewController: UISearchBarDelegate {
    
}

extension PhotoViewController {
    
    private func createLayout() -> UICollectionViewLayout {

        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)

        return layout

    }

    private func configureDataSource() {

        let cellRegisteration = UICollectionView.CellRegistration<UICollectionViewListCell, SearchResult>(handler: { cell, indexPath, itemIdentifier in

            var content = UIListContentConfiguration.valueCell()

            content.text = "\(itemIdentifier.likes)"

            DispatchQueue.global().async {
                let url = URL(string: itemIdentifier.urls.thumb)!
                let data = try? Data(contentsOf: url)

                DispatchQueue.main.async {
                    content.image = UIImage(data: data!)
                    cell.contentConfiguration = content
                }
            }

            var background = UIBackgroundConfiguration.listPlainCell()

            background.strokeWidth = 2
            background.strokeColor = .lightGray

            cell.backgroundConfiguration = background

        })

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in

            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegisteration, for: indexPath, item: itemIdentifier)

            return cell

        })
    }
}
