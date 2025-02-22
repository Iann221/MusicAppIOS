//
//  TrackCellViewModel.swift
//  MusicAppIOS
//
//  Created by Vincentius Ian Widi Nugroho on 22/02/25.
//
import RxCocoa

class TrackCellViewModel {
    let name: String
    let playCount: String
    let chosen: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    init(model: TrackModel) {
        self.name = model.name
        self.playCount = "play count: \(model.playcount)"
    }
}
