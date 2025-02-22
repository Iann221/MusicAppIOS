//
//  MainViewModel.swift
//  MusicAppIOS
//
//  Created by Vincentius Ian Widi Nugroho on 22/02/25.
//

import RxSwift
import RxCocoa

class MainViewModel {
    let cellViewModels: BehaviorRelay<[TrackCellViewModel]> = BehaviorRelay(value: [])
    let lastCellChosen: BehaviorRelay<Int> = BehaviorRelay(value: -1)

    func fetchTracks(with artist: String){
        let urlString = "https://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=\(artist)&api_key=a7a42bb92340cf6fd72fb167a9cd1f90&limit=10&format=json"
            
        guard let url = URL(string: urlString) else {
            // TODO: add error update
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                // TODO: add error update
                return
            }
            
            var tracks: [TrackModel] = []
            do {
                let decodedResponse = try JSONDecoder().decode(TopTracksResponse.self, from: data)
                tracks = decodedResponse.toptracks.track
            } catch {
                // TODO: error
            }
            
            var tempVM: [TrackCellViewModel] = []
            for t in tracks {
                tempVM.append(TrackCellViewModel(model: t))
            }
            self.cellViewModels.accept(tempVM)
        }.resume()
    }
}
