//
//  TrackTableViewCell.swift
//  MusicAppIOS
//
//  Created by Vincentius Ian Widi Nugroho on 22/02/25.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var playingLabel: UILabel!
    static let cellIdentifier = "TrackTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
