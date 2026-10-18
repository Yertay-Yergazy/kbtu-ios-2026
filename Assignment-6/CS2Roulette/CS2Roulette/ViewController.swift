//
//  ViewController.swift
//  CS2Roulette
//
//  Created by Ергазы on 20.11.2026.
//

import UIKit

class ViewController: UIViewController {

    let FavoriteArr: Array<Favorite> = [
        Favorite(name: "Five-SeveN", image: "fiveseven", description: "Мой любимый пистолет"),
        Favorite(name: "AK-47", image: "ak47", description: "Мое любимое оружие за террористов"),
        Favorite(name: "M4A1-S", image: "m4a1s", description: "Мое любимое оружие за контр-террористов"),
        Favorite(name: "Белые перчатки", image: "gloves", description: "Мой любимый скин на перчатки"),
        Favorite(name: "Karambit", image: "karambit", description: "Мой любимый нож"),
        Favorite(name: "AK-47 | Neon Rider", image: "akneonrider", description: "Мой любимый скин"),
        Favorite(name: "Mirage", image: "mirage", description: "Моя любимая карта"),
        Favorite(name: "Connector", image: "connector", description: "Моя любимая позиция на карте"),
        Favorite(name: "FURIA", image: "furia", description: "Моя любимая команда"),
        Favorite(name: "donk", image: "donk", description: "Мой любимый игрок. Entry fragger из Team Spirit, лучший игрок 2024 года")
    ]

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var lastIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show(FavoriteArr[0])
        lastIndex = 0
    }
    @IBAction func buttonTapped(_ sender: UIButton) {
        var index = Int.random(in: 0..<FavoriteArr.count)
        while index==lastIndex {
            index = Int.random(in: 0..<FavoriteArr.count)
        }
        lastIndex =  index
        show(FavoriteArr[index])
    }
    func show(_ item: Favorite) {
        titleLabel.text = item.name
        descriptionLabel.text = item.description.isEmpty ? nil : item.description
        if let picture = UIImage(named: item.image) {
            imageView.image = picture
        }
        else {
            imageView.image = nil
        }
    }
    
}

struct Favorite {
    let name: String
    let image: String
    let description: String
}
