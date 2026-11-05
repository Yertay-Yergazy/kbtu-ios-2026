//
//  ViewController.swift
//  TableView
//
//  Created by Arman Myrzakanurov on 29.10.2026.
//

import UIKit

struct Movie {
    let title: String
    let subtitle: String
    let image: UIImage
}

class ViewController: UIViewController, UITableViewDataSource {

    var movies: [Movie] = [
        Movie(title: "Spider-Man", subtitle: "Marvel • 2002", image: UIImage(systemName: "figure.climbing")!),
        Movie(title: "Top Gun", subtitle: "Action • 1986", image: UIImage(systemName: "airplane")!),
        Movie(title: "Avengers", subtitle: "Marvel • 2012", image: UIImage(systemName: "shield.fill")!),
        Movie(title: "Batman", subtitle: "DC • 1989", image: UIImage(systemName: "moon.stars.fill")!),
        Movie(title: "Iron Man", subtitle: "Marvel • 2008", image: UIImage(systemName: "bolt.circle.fill")!),
        Movie(title: "Avatar", subtitle: "Sci-Fi • 2009", image: UIImage(systemName: "leaf.fill")!),
        Movie(title: "The Sopranos", subtitle: "TV Series • HBO • 1999", image: UIImage(systemName: "person.3.fill")!),
        Movie(title: "Harry Potter", subtitle: "Fantasy • 2001", image: UIImage(systemName: "wand.and.stars")!),
        Movie(title: "Breaking Bad", subtitle: "TV Series • AMC • 2008", image: UIImage(systemName: "flask.fill")!),
        Movie(title: "The Boys", subtitle: "TV Series • Prime • 2019", image: UIImage(systemName: "bolt.shield.fill")!)
    ]

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    /// Default cell implementation
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        var config = cell.defaultContentConfiguration()
//        config.text = "Number of Row: \(indexPath.row)"
//        config.image = UIImage(systemName: "heart.fill")
//        config.secondaryText = "iOS Dev 🍎"
//        cell.contentConfiguration = config
//        cell.backgroundColor = indexPath.row % 2 == 0 ? .yellow : .red
//        return cell
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieViewCell

        let movie = movies[indexPath.row]
        cell.configure(movie)

        return cell
    }
}

