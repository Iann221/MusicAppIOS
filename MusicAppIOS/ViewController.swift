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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var trackSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    private let viewModel = MainViewModel(audioFileName: "Elevator-music", apiURL: "https://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=")
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setupAudioPlayer()
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
                self.viewModel.isLoading.accept(false)
                cell.configure(vm: vm)
            }
            .disposed(by: disposeBag)
        
        viewModel.lastCellChosen
            .map {$0 == -1}
            .bind(to: trackView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map { ($0,!$0) }
            .bind { [weak loadingIndicator] isAnimating, isHidden in
                isAnimating ? loadingIndicator?.startAnimating() : loadingIndicator?.stopAnimating()
                loadingIndicator?.isHidden = isHidden
            }
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance) // main thread
            .subscribe(onNext: { err in
                self.viewModel.isLoading.accept(false)
                var msg = ""
                switch err {
                case .invalidURL:
                    msg = "invalid url"
                case .parsingError:
                    msg = "there was an error in fetching data"
                case .audioError:
                    msg = "there was a problem with the audio"
                }
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.updateSelectedCell(row: indexPath.row)
            })
            .disposed(by: disposeBag)

        Observable<Int>
            .interval(.milliseconds(500), scheduler: MainScheduler.instance)
            .compactMap { [weak self] _ -> TimeInterval? in
                guard let self = self else { return nil }
                return self.viewModel.audioPlayer?.currentTime
            }
            .map { [weak self] currentTime -> Float in
                guard let self = self else { return 0 }
                let duration = self.viewModel.audioPlayer?.duration ?? 1
                return Float(currentTime / duration)
            }
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
