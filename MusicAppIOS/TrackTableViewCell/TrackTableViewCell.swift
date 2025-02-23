//
//  TrackTableViewCell.swift
//  MusicAppIOS
//
//  Created by Vincentius Ian Widi Nugroho on 22/02/25.
//

import UIKit
import RxSwift

class TrackTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var playingImage: UIImageView!
    static let cellIdentifier = "TrackTableViewCell"
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(vm: TrackCellViewModel){
        titleLabel.text = vm.name
        playCountLabel.text = vm.playCount
        vm.chosen
            .map {!$0}
            .bind(to: playingImage.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
}
