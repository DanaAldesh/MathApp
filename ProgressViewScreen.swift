import SwiftUI

struct LiveSession: Identifiable {
    let id = UUID()
    let title: String
    let zoomLink: String
    let startTime: Date
}

struct LiveBroadcastView: View {
    @State private var sessions: [LiveSession] = [
        LiveSession(title: "Ондық бөлшектер. Қайталау сабағы", zoomLink: "https://zoom.us/j/123456789", startTime: Date().addingTimeInterval(3600)),
        LiveSession(title: "Натурал сандар. Қатемен жұмыс", zoomLink: "https://zoom.us/j/987654321", startTime: Date().addingTimeInterval(7200)),
        LiveSession(title: "Математикалық сауаттылық. ОЛИМПИАДА", zoomLink: "https://zoom.us/j/112233445", startTime: Date().addingTimeInterval(10800)),
        LiveSession(title: "Математикалық сауаттылық. ОЛИМПИАДА II-тур", zoomLink: "https://zoom.us/j/987654321", startTime: Date().addingTimeInterval(54000)),
    ]
    @State private var currentTime = Date()
    @State private var animateGradient = false

    var body: some View {
        NavigationView {
            ZStack {
                // Плавно ауысатын градиент
                LinearGradient(
                    gradient: Gradient(colors: [.white, .orange, .white, .orange]),
                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }

                List(sessions) { session in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.title)
                            .font(.headline)
                            .foregroundColor(.black)

                        Text("Басталу уақыты: \(session.startTime.formatted(date: .numeric, time: .shortened))")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack {
                            Link("Join Zoom", destination: URL(string: session.zoomLink)!)
                                .foregroundColor(.blue)

                            Spacer()

                            Text(timeRemaining(to: session.startTime))
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                }
                .navigationTitle("Тікелей эфир")
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }

    func timeRemaining(to date: Date) -> String {
        let diff = Int(date.timeIntervalSince(currentTime))
        if diff <= 0 { return "Сессия басталды!" }
        let hours = diff / 3600
        let minutes = (diff % 3600) / 60
        let seconds = diff % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct LiveBroadcastView_Previews: PreviewProvider {
    static var previews: some View {
        LiveBroadcastView()
    }
}
