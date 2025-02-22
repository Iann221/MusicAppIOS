//
//  MainViewModel.swift
//  MusicAppIOS
//
//  Created by Vincentius Ian Widi Nugroho on 22/02/25.
//

import RxSwift
import RxCocoa
import AVFoundation

class MainViewModel {
    let cellViewModels: BehaviorRelay<[TrackCellViewModel]> = BehaviorRelay(value: [])
    let lastCellChosen: BehaviorRelay<Int> = BehaviorRelay(value: -1)
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let error: PublishSubject<ErrorEnum> = PublishSubject()
    
    var audioPlayer: AVAudioPlayer?
    private let audioFileName: String
    private let apiURL: String
    
    init(audioFileName: String, apiURL: String){
        self.audioFileName = audioFileName
        self.apiURL = apiURL
    }
    
    func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: "mp3") else {
            self.error.onNext(.audioError)
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            self.error.onNext(.parsingError)
        }
    }
    
    func resetAudioPlayer(){
        audioPlayer = nil
    }

    func fetchTracks(with artist: String){
        isLoading.accept(true)
        let urlString = "\(apiURL)\(artist)&api_key=a7a42bb92340cf6fd72fb167a9cd1f90&limit=10&format=json"
            
        guard let url = URL(string: urlString) else {
            error.onNext(.invalidURL)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                self.error.onNext(.parsingError)
                return
            }
            
            var tracks: [TrackModel] = []
            do {
                let decodedResponse = try JSONDecoder().decode(TopTracksResponse.self, from: data)
                tracks = decodedResponse.toptracks.track
            } catch {
                self.error.onNext(.parsingError)
            }
            
            var tempVM: [TrackCellViewModel] = []
            for t in tracks {
                tempVM.append(TrackCellViewModel(model: t))
            }
            self.cellViewModels.accept(tempVM)
        }.resume()
    }
    
    func playAudioFrom(_ interval: TimeInterval) {
        guard let player = audioPlayer else {
            self.error.onNext(.audioError)
            return
        }
        player.prepareToPlay()
        player.currentTime = player.duration * interval
        player.play()
    }
    
    func pauseAudio() {
        guard let player = audioPlayer else {
            self.error.onNext(.audioError)
            return
        }
        player.pause()
    }

}
