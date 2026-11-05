//
//  MovieViewCell.swift
//  TableView
//
//  Created by Arman Myrzakanurov on 29.10.2026.
//

import UIKit

class MovieViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var movieImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "Example"
        subtitleLabel.text = "Subtitle Example"
        movieImage.image = UIImage(systemName: "heart.fill")
    }

    func configure(_ movie: Movie) {
        titleLabel.text = movie.title
        subtitleLabel.text = movie.subtitle
        movieImage.image = movie.image
    }
}
