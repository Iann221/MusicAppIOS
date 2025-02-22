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
    
    init(){
        guard let url = Bundle.main.url(forResource: "Elevator-music", withExtension: "mp3") else {
            self.error.onNext(.audioError)
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            self.error.onNext(.parsingError)
        }
    }

    func fetchTracks(with artist: String){
        isLoading.accept(true)
        let urlString = "https://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=\(artist)&api_key=a7a42bb92340cf6fd72fb167a9cd1f90&limit=10&format=json"
            
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
        if let player = audioPlayer {
            player.prepareToPlay()
            player.currentTime = player.duration * interval
            player.play()
        } else {
            self.error.onNext(.audioError)
        }
    }
    
    func pauseAudio() {
        if let player = audioPlayer {
            player.pause()
        } else {
            self.error.onNext(.audioError)
        }
    }

}
