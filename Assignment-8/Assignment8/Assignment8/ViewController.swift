//
//  ViewController.swift
//  Assignment8
//
//  Created by Ергазы on 21.11.2026.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    // Screen state: the current track and the play state live here,
    // the UI is redrawn from them in updateUI().
    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var isPlaying = false

    // Stored as a property so the player lives as long as the screen does.
    private var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSession()
        coverImageView.layer.cornerRadius = 16
        loadTrack(at: 0, autoplay: false)
    }

    // MARK: - Actions

    @IBAction func previousTapped(_ sender: Any) {
        loadTrack(at: (currentIndex - 1 + tracks.count) % tracks.count, autoplay: isPlaying)
    }

    @IBAction func playPauseTapped(_ sender: Any) {
        guard let player else {
            // The current track failed to load earlier: try again.
            loadTrack(at: currentIndex, autoplay: true)
            return
        }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            isPlaying = player.play()
        }
        updateUI()
    }

    @IBAction func nextTapped(_ sender: Any) {
        loadTrack(at: (currentIndex + 1) % tracks.count, autoplay: isPlaying)
    }

    // MARK: - Playback

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    /// Switches to the track at `index` and starts it if `autoplay` is true.
    private func loadTrack(at index: Int, autoplay: Bool) {
        currentIndex = index
        let track = tracks[index]

        player?.stop()
        player = nil
        isPlaying = false

        guard let url = Bundle.main.url(forResource: track.resourceName,
                                        withExtension: track.resourceExtension) else {
            reportError("File \"\(track.fileName)\" was not found in the app bundle.")
            updateUI()
            return
        }

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            player = newPlayer
            if autoplay {
                isPlaying = newPlayer.play()
            }
        } catch {
            reportError("Could not play \"\(track.fileName)\": \(error.localizedDescription)")
        }
        updateUI()
    }

    private func reportError(_ message: String) {
        print("Playback error: \(message)")
        // During the first load (viewDidLoad) the screen is not in a window yet, so skip the alert.
        guard viewIfLoaded?.window != nil else { return }
        let alert = UIAlertController(title: "Playback error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UI

    private func updateUI() {
        let track = tracks[currentIndex]
        coverImageView.image = UIImage(named: track.coverImageName)
        titleLabel.text = track.title
        artistLabel.text = track.artist
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
}

// MARK: - AVAudioPlayerDelegate

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else {
            isPlaying = false
            updateUI()
            return
        }
        // The track ended: start the next one (wraps around after the last).
        loadTrack(at: (currentIndex + 1) % tracks.count, autoplay: true)
    }
}
