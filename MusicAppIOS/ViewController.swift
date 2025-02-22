//
//  ViewController.swift
//  MusicAppIOS
//
//  Created by Vincentius Ian Widi Nugroho on 22/02/25.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var trackView: UIView!
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: TrackTableViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: TrackTableViewCell.cellIdentifier)
        setupBinding()
        viewModel.fetchDatas("Queen")
    }
        
    private func setupBinding() {
        viewModel.cellViewModels
            .bind(to: tableView.rx.items(cellIdentifier: TrackTableViewCell.cellIdentifier, cellType: TrackTableViewCell.self)) { row, vm, cell in
                cell.configure(vm: vm)
            }
            .disposed(by: disposeBag)
        
        viewModel.lastCellChosen
            .map {$0 == -1}
            .bind(to: trackView.rx.isHidden)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                var selectIndex = self.viewModel.lastCellChosen.value
                if(selectIndex != -1 && indexPath.row != selectIndex){
                    self.viewModel.cellViewModels.value[selectIndex].chosen.accept(false)
                }
                selectIndex = indexPath.row
                self.viewModel.cellViewModels.value[selectIndex].chosen.accept(true)
                self.viewModel.lastCellChosen.accept(selectIndex)
            })
            .disposed(by: disposeBag)

    }
}
