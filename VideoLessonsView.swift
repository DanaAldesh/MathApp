import SwiftUI
import AVKit

struct VideoLessonsView: View {
    let videos: [(title: String, file: String)]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(videos, id: \.title) { video in
                    NavigationLink {
                        VideoPlayerView(videoName: video.file)
                            .navigationTitle(video.title)
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)

                            Text(video.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 6)
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Видеосабақтар")
    }
}

struct VideoPlayerView: View {
    let videoName: String
    @State private var player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if let path = Bundle.main.path(forResource: videoName, ofType: "mp4") {
                    player = AVPlayer(url: URL(fileURLWithPath: path))
                    player?.play()
                }
            }
    }
}

