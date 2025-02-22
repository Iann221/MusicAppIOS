//
//  ViewController.swift
//  MusicAppIOS
//
//  Created by Vincentius Ian Widi Nugroho on 22/02/25.
//

import UIKit
import RxSwift

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var trackView: UIView!
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: TrackTableViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: TrackTableViewCell.cellIdentifier)
        setupTextField()
        setupBinding()
    }
    
    private func setupTextField() {
        searchTextField.returnKeyType = .done
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Hide", style: .done, target: self, action: #selector(doneTapped))
        ]
        toolbar.sizeToFit()
        searchTextField.inputAccessoryView = toolbar
        searchTextField.delegate = self
    }
    
    @objc func doneTapped() {
        searchTextField.resignFirstResponder() // Hide keyboard
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.lastCellChosen.accept(-1)
        viewModel.fetchTracks(with: searchTextField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}
