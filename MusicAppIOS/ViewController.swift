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
    @IBOutlet weak var trackSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: TrackTableViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: TrackTableViewCell.cellIdentifier)
        setupTextField()
        trackSlider.addTarget(self, action: #selector(continueAudio), for: [.touchUpInside, .touchUpOutside])
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.pauseAudio()
        viewModel.lastCellChosen.accept(-1)
        viewModel.fetchTracks(with: searchTextField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
    
    @objc func continueAudio() {
        if(playBtn.isSelected){
            viewModel.playAudioFrom(TimeInterval(trackSlider.value))
        } else {
            viewModel.pauseAudio()
        }
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
                self.updateSelectedCell(row: indexPath.row)
            })
            .disposed(by: disposeBag)
        
        Observable<Int>.interval(.milliseconds(500), scheduler: MainScheduler.instance)
            .compactMap { [weak self] _ in self?.viewModel.audioPlayer?.currentTime }
            .map {Float($0/(self.viewModel.audioPlayer?.duration ?? 1))}
            .distinctUntilChanged()
            .bind(to: trackSlider.rx.value)
            .disposed(by: disposeBag)
    }
    
    @IBAction func btnAction(_ sender: UIButton){
        if(sender == playBtn){
            sender.isSelected.toggle()
            continueAudio()
        } else if(sender == prevBtn){
            guard viewModel.lastCellChosen.value != 0 else {return}
            updateSelectedCell(row: viewModel.lastCellChosen.value - 1)
        } else if(sender == nextBtn){
            guard viewModel.lastCellChosen.value != 9 else {return}
            updateSelectedCell(row: viewModel.lastCellChosen.value + 1)
        }
    }
    
    private func updateSelectedCell(row: Int){
        playBtn.isSelected = true
        var selectIndex = viewModel.lastCellChosen.value
        if(selectIndex != -1 && row != selectIndex){
            viewModel.cellViewModels.value[selectIndex].chosen.accept(false)
        }
        selectIndex = row
        viewModel.cellViewModels.value[selectIndex].chosen.accept(true)
        viewModel.lastCellChosen.accept(selectIndex)
        viewModel.playAudioFrom(0)
    }

}
