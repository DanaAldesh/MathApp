import SwiftUI
import Combine

// MARK: - Models

struct User {
    var name: String
    var points: Int = 0
    var level: Int { max(1, points / 100 + 1) }
    var accuracy: Double = 0 // percent
    var attempts: Int = 0
    var correctToday: Int = 0
        var wrongToday: Int = 0
        var attemptsToday: Int { correctToday + wrongToday }
    mutating func updateStats(correct: Bool) {
        attempts += 1
        if correct { points += 10 }
        accuracy = attempts == 0 ? 0 : Double(points) / Double(attempts * 10) * 100
    }
    mutating func resetStats() {
        points = 0
        accuracy = 0
        attempts = 0
    }
}

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let choices: [String]
    let correct: String
}

struct Category: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let pointValue: Int
    let iconName: String
    let questions: [Question]
}

// MARK: - App State (ViewModel)

final class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user = User(name: "Dana")
    @Published var selectedCategory: Category?
    @Published var currentQuestionIndex = 0
    @Published var currentQuestionSet: [Question] = []
    @Published var currentScore = 0
    @Published var showingResult = false
    @Published var showAllConspects = false

    
    // Статистика бойынша: бүгінгі тапсырмалар
    @Published var todayAttempts = 0
    @Published var todayCorrect = 0
     // mock per day

    // Sample categories/questions — 4 sections with short descriptions
    // MARK: - Sample categories/questions

    let categories: [Category] = [
        // 1) Натурал сандар
        Category(
            title: "Натурал сандар",
            description: "Натурал сандар – санауға арналған оң бүтін сандар.",

            pointValue: 10,
            iconName: "number",
            questions: [
                Question(text: "Натурал сандар қай саннан басталады?", choices: ["0","1","2","10"], correct: "1"),
                Question(text: "5 пен 9 арасындағы сандар саны?", choices: ["3","4","5","2"], correct: "3"),
                Question(text: "1–ден 10–ға дейін қанша сан бар?", choices: ["8","9","10","11"], correct: "10"),
                Question(text: "7 саны қандай сан?", choices: ["жұп","тақ","теріс","бүтін емес"], correct: "тақ"),
                Question(text: "3 + 6 = ?", choices: ["8","9","7","10"], correct: "9"),
                Question(text: "10 алдындағы сан?", choices: ["8","9","11","7"], correct: "9"),
                Question(text: "4 кейінгі сан?", choices: ["3","5","6","7"], correct: "5"),
                Question(text: "Натурал сандар жиыны шексіз бе?", choices: ["иә","жоқ","әрқашан емес","тек 1000-ге дейін"], correct: "иә"),
                Question(text: "1 + 1 = ?", choices: ["1","2","3","0"], correct: "2"),
                Question(text: "2, 4, 6, 8 — қандай?", choices: ["тақ","жұп","теріс","ондық"], correct: "жұп")
            ]
        ),
        
        // 2) Проценттер
        Category(
            title: "Проценттер",
            description: "Проценттер – 100 бөлікке бөлінген сандық өлшем.",
            pointValue: 15,
            iconName: "percent",
            questions: [
                Question(text: "100%-дың 50%-ы?", choices: ["25","40","50","60"], correct: "50"),
                Question(text: "80%-ды ондыққа айналдыр?", choices: ["0.8","0.08","8","0.18"], correct: "0.8"),
                Question(text: "200-дің 10%-ы?", choices: ["10","20","30","40"], correct: "20"),
                Question(text: "25% = ?", choices: ["1/2","1/3","1/4","3/4"], correct: "1/4"),
                Question(text: "90%-ға 10% қосса = ?", choices: ["95","100","90","110"], correct: "100"),
                Question(text: "30%-ы 9 болса, толық сан?", choices: ["27","30","40","20"], correct: "30"),
                Question(text: "60%-ы 12 болса, 100%?", choices: ["20","24","30","15"], correct: "20"),
                Question(text: "10%-дың ондық көрінісі?", choices: ["0.001","0.1","1","0.01"], correct: "0.1"),
                Question(text: "Бүтінді 100 бөлікке бөлген өлшем?", choices: ["процент","градус","метр","үлес"], correct: "процент"),
                Question(text: "50% + 25% + 25% = ?", choices: ["100%","90%","110%","80%"], correct: "100%")
            ]
        ),
        
        // 3) Жиындар
        Category(
            title: "Жиындар",
            description: "Жиын – объектілердің топтары, қосу, қиылысу, толықтауыш операциялары бар.",

            pointValue: 20,
            iconName: "square.grid.2x2",
            questions: [
                Question(text: "Жиын деген не?", choices: ["әріп тобы","сан тізімі","объектілер жиынтығы","формула"], correct: "объектілер жиынтығы"),
                Question(text: "A={1,2,3}. Қанша элемент бар?", choices: ["2","3","4","5"], correct: "3"),
                Question(text: "{a,b,c} — қандай жиын?", choices: ["сандық","табиғи","әріптік","жабық"], correct: "әріптік"),
                Question(text: "{1,1,2,3} элемент саны?", choices: ["3","4","2","5"], correct: "3"),
                Question(text: "Бос жиын белгісі?", choices: ["Ø","{}","()","∪"], correct: "Ø"),
                Question(text: "A∪B деген не?", choices: ["қиылысу","бірігу","айырма","толықтау"], correct: "бірігу"),
                Question(text: "A∩B?", choices: ["бірігу","ерекше бөлік","қиылысу","жабық топ"], correct: "қиылысу"),
                Question(text: "Элемент ∈ A?", choices: ["қосылады","қатысты","бөлінеді","тең"], correct: "қатысты"),
                Question(text: "A={1,2}, B={2,3}. A∩B?", choices: ["{1}","{3}","{2}","{1,2,3}"], correct: "{2}"),
                Question(text: "A={1,2,3}. 4 ∈ A?", choices: ["иә","жоқ","кейде","анықталмайды"], correct: "жоқ")
            ]
        ),
        
        // 4) Ондық бөлшектер
        Category(
            title: "Ондық бөлшектер",
            description: "Ондық бөлшектер – бөлшектің ондық жүйедегі жазылуы.",
            pointValue: 15,
            iconName: "decimal",
            questions: [
                Question(text: "0.5 = ?", choices: ["1/4","1/2","2/5","5/10"], correct: "1/2"),
                Question(text: "0.25 = ?", choices: ["1/2","1/4","2/3","0.2"], correct: "1/4"),
                Question(text: "0.1 × 10 = ?", choices: ["1","0.1","0.01","10"], correct: "1"),
                Question(text: "1.2 + 0.3 = ?", choices: ["1.3","1.5","1.4","1.2"], correct: "1.5"),
                Question(text: "0.09 қалай оқылады?", choices: ["тоқсан","нөл бүтін жүзден тоғыз","жүзден тоғыз","тоғыз"], correct: "нөл бүтін жүзден тоғыз"),
                Question(text: "0.4 = ?", choices: ["4/10","2/5","0.40","барлығы дұрыс"], correct: "барлығы дұрыс"),
                Question(text: "1.5 – 0.5 = ?", choices: ["1","0.5","2","1.2"], correct: "1"),
                Question(text: "0.7 × 2 = ?", choices: ["1.2","1.4","1.0","0.9"], correct: "1.4"),
                Question(text: "0.33 жуық мәні?", choices: ["1/4","1/3","3/4","1/2"], correct: "1/3"),
                Question(text: "0.01 = ?", choices: ["1/10","1/100","10","0.1"], correct: "1/100")
            ]
        )
    ]
    

    func startCategory(_ category: Category) {
        selectedCategory = category
        currentQuestionSet = category.questions.shuffled()
        currentQuestionIndex = 0
        currentScore = 0
        showingResult = false
    }

    func answerCurrent(choice: String) -> Bool {
        guard currentQuestionIndex < currentQuestionSet.count else { return false }
        let q = currentQuestionSet[currentQuestionIndex]
        let correct = (choice == q.correct)

        // Статистика бойынша
        todayAttempts += 1
        if correct { todayCorrect += 1 }

        // Ұпай қосу
        if correct {
            let pointsToAdd = selectedCategory?.pointValue ?? 10
            currentScore += pointsToAdd
            user.points += pointsToAdd    // <- осы жол қосылды
        }

        // Дұрыс пайызы
        let percent = todayAttempts == 0 ? 0 : Double(todayCorrect) / Double(todayAttempts) * 100
        user.accuracy = percent

        return correct
    }


    func nextQuestion() {
        if currentQuestionIndex + 1 < currentQuestionSet.count {
            currentQuestionIndex += 1
        } else {
            showingResult = true
        }
    }

    func resetForNewUser(name: String) {
            user.name = name
            user.resetStats()
            isLoggedIn = true
            todayAttempts = 0
            todayCorrect = 0
        }
}

// MARK: - Views

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        NavigationStack {
            if appState.isLoggedIn {
                DashboardView()
                    .environmentObject(appState)
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
        .accentColor(.orange)
    }
}

// MARK: Login & Signup

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var password = ""
    @State private var showSignup = false
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)
            Image(systemName: "sum")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
                .padding()
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.orange.opacity(0.95)))
                .foregroundColor(.white)
            Text("Login")
                .font(.largeTitle.weight(.bold))
            VStack(spacing: 12) {
                TextField("Name", text: $name)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            Button {
                // mock authentication: on first login ensure stats reset
                withAnimation {
                    let username = name.isEmpty ? "Dana" : name
                    appState.resetForNewUser(name: username)
                }
            } label: {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            HStack {
                Button("Forgot Password?") {}
                Spacer()
                Button("Sign Up") { showSignup = true }
            }
            .padding(.horizontal)
            .font(.footnote)
            Spacer()
            Text("Math Practice — interactive learning")
                .foregroundColor(.secondary)
                .font(.caption)
            Spacer(minLength: 30)
        }
        .padding()
        .sheet(isPresented: $showSignup) {
            SignupView()
                .environmentObject(appState)
        }
    }
}

struct SignupView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Create new Account")
                    .font(.title2.weight(.semibold))
                TextField("Name", text: $name)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                TextField("Email", text: $email)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $password)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                Button {
                    // mock sign up: create new user with zeroed stats
                    let username = name.isEmpty ? "Dana" : name
                    appState.resetForNewUser(name: username)
                    dismiss()
                } label: {
                    Text("Sign up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: Dashboard & Categories

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("darkMode") private var darkMode = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hello, \(appState.user.name)!")
                        .font(.title2.weight(.bold))
                    Text("\(appState.user.points)  •  Level \(appState.user.level)")
                        .font(.headline)
                }
                Spacer()
                Button {
                    // sign out
                    withAnimation { appState.isLoggedIn = false }
                } label: {
                    Image(systemName: "person.crop.circle.fill.badge.xmark")
                        .font(.title)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            
            Button {
                withAnimation {
                    appState.showAllConspects = true
                }
            } label: {
                Text("Видео сабақтар")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            
            HStack(spacing: 12) {
                VStack {
                    // show total questions as simple sum
                    let totalQuestions = appState.categories.reduce(0) { $0 + $1.questions.count }
                    Text("\(totalQuestions)")
                        .font(.title2.weight(.bold))
                    Text("Weekly exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                
                VStack {
                    Text(String(format: "%.0f%%", appState.user.accuracy))
                        .font(.title2.weight(.bold))
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            }
            .padding(.horizontal)
            
            Text("Math Practice")
                .font(.headline)
                .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(appState.categories) { cat in
                        NavigationLink(destination: CategoryDetailView(category: cat).environmentObject(appState)) {
                            CategoryCard(category: cat)
                        }
                        
                        
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
            
            HStack(spacing: 24) {
                NavigationLink(destination: LiveBroadcastView().environmentObject(appState)) {
                       VStack {
                           Image("LivePhoto") // Assets ішіне қосқан суреттің аты
                               .resizable()
                               .scaledToFit()
                               .frame(width: 15, height: 15)
                               .clipShape(Circle()) // дөңгелек ету үшін
                               .overlay(Circle().stroke(Color.orange, lineWidth: 2)) // шекара қосу
                           Text("Live")
                               .font(.caption)
                               .foregroundColor(.white)
                       }
                       .padding()
                       .background(Color.orange.opacity(0.3)) // жартылай прозрачный фон
                       .cornerRadius(12)
                   }
                Spacer()
                NavigationLink(destination: SettingsView().environmentObject(appState)) {
                    VStack { Image(systemName: "gearshape"); Text("Settings").font(.caption) }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top)
        // Navigate to Practice when category selected
        .background(
            NavigationLink(
                destination: VideoLessonsView(
                    videos: [
                        ("Натурал сандар", "натурал"),
                        ("Проценттер", "процент"),
                        ("Жиын", "жиын"),
                        ("Ондық бөлшектер", "ondyk")
                    ]
                ),
                isActive: $appState.showAllConspects
            ) {
                EmptyView()
            }
                .hidden()
    )

    }
}


struct CategoryCard: View {
    let category: Category
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: category.iconName)
                        .padding(8)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(8)
                        .foregroundColor(.orange)
                    Spacer()
                    Text("\(category.pointValue) pts")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(category.title)
                    .font(.headline)
                Text(category.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding()
        }
        .frame(height: 120)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
    }
}

// MARK: Practice View

struct PracticeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedChoice: String?
    @State private var showFeedback = false
    @State private var didAnswerCorrectly = false
    var body: some View {
        VStack {
            if let cat = appState.selectedCategory, appState.currentQuestionIndex < appState.currentQuestionSet.count {
                let q = appState.currentQuestionSet[appState.currentQuestionIndex]
                VStack(spacing: 12) {
                    HStack {
                        Text(cat.title)
                            .font(.headline)
                        Spacer()
                        Text("\(appState.currentQuestionIndex + 1)/\(appState.currentQuestionSet.count)")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    ZStack {
                        RoundedRectangle(cornerRadius: 16).fill(Color.orange.opacity(0.12))
                        VStack(spacing: 16) {
                            Text(q.text)
                                .font(.title2.weight(.bold))
                                .multilineTextAlignment(.center)
                                .padding(.top, 12)
                            ForEach(q.choices, id: \.self) { choice in
                                Button {
                                    selectedChoice = choice
                                } label: {
                                    HStack {
                                        Text(choice)
                                            .font(.body.weight(.semibold))
                                        Spacer()
                                        if selectedChoice == choice {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).fill(selectedChoice == choice ? Color.orange.opacity(0.22) : Color.white))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .accessibilityLabel("Answer \(choice)")
                            }
                            Button {
                                guard let sel = selectedChoice else { return }
                                let correct = appState.answerCurrent(choice: sel)
                                didAnswerCorrectly = correct
                                showFeedback = true
                                // delay then next
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation {
                                        appState.nextQuestion()
                                        selectedChoice = nil
                                        showFeedback = false
                                    }
                                }
                            } label: {
                                Text("Submit")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange))
                                    .foregroundColor(.white)
                            }
                            .disabled(selectedChoice == nil)
                            .padding(.horizontal)

                            Spacer(minLength: 6)
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding()
                .overlay(
                    VStack {
                        if showFeedback {
                            HStack {
                                Image(systemName: didAnswerCorrectly ? "star.fill" : "xmark.octagon.fill")
                                    .foregroundColor(didAnswerCorrectly ? .yellow : .red)
                                Text(didAnswerCorrectly ? "Correct!" : "Wrong")
                                    .font(.headline)
                            }
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)
                            .transition(.scale)
                        }
                    }
                    .padding(.top, 12)
                    , alignment: .top
                )
            } else if appState.showingResult {
                VStack(spacing: 18) {
                    Text("Result")
                        .font(.title2.weight(.bold))
                    Text("You scored \(appState.currentScore) points")
                        .font(.headline)
                    Button("Back to Dashboard") {
                        withAnimation {
                            appState.selectedCategory = nil
                            appState.showingResult = false
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange))
                    .foregroundColor(.white)
                }
                .padding()
            } else {
                Text("No category selected")
            }
        }
        .navigationTitle(appState.selectedCategory?.title ?? "Practice")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top)
    }
}

// MARK: Statistics View


// Simple sparkline
struct SparklineView: View {
    let values: [Double]
    var body: some View {
        GeometryReader { geo in
            let maxVal = max(1, values.max() ?? 1)
            let step = geo.size.width / CGFloat(max(values.count - 1, 1))
            Path { path in
                for idx in values.indices {
                    let x = CGFloat(idx) * step
                    let y = geo.size.height - (CGFloat(values[idx]) / CGFloat(maxVal) * geo.size.height)
                    if idx == 0 { path.move(to: CGPoint(x: x, y: y)) }
                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(Color.orange, lineWidth: 2)
        }
    }
}

struct CategoryDetailView: View {
    @EnvironmentObject var appState: AppState
    let category: Category
    @State private var showTest = false

    var body: some View {
        VStack(spacing: 20) {
            if showTest {
                PracticeView()
                    .environmentObject(appState)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category.title)
                            .font(.largeTitle)
                            .bold()
                        
                        // Конспект мәтіні
                        Text(getConspect(for: category.title))
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding()
                }

                Button(action: {
                    withAnimation {
                        appState.startCategory(category)
                        showTest = true
                    }
                }) {
                    Text("Тест бастау")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange))
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

func getConspect(for title: String) -> String {
    switch title {
    case "Натурал сандар":
        return """
    Натурал сандар – санауға арналған оң бүтін сандар. Олар ең кіші мәні 1-ден басталады: 1, 2, 3, 4, … және шексіз жалғасады.

    Негізгі қасиеттері:
    - Қосу: Натурал сандарды қосу нәтижесінде тағы да натурал сан шығады. Мысалы, 3 + 5 = 8.
    - Алу: Бір саннан екіншісін алу әрдайым натурал сан болмайды. Мысалы, 3 − 5 = −2 (натурал сан емес).
    - Көбейту: Көбейту нәтижесі әрдайым натурал сан. Мысалы, 4 × 3 = 12.
    - Бөлу: Бөлу нәтижесі әрдайым натурал сан бола бермейді. Мысалы, 5 ÷ 2 = 2,5.

    Қосымша ұғымдар:
    - Жұп және тақ сандар: Жұп сан 2-ге бөлінеді (мысалы, 4, 8), тақ сан 2-ге бөлінбейді (мысалы, 3, 7).
    - Жай және күрделі сандар: Жай санның бөлгіші тек 1 және өзі ғана (мысалы, 2, 3, 5), күрделі санның бірнеше бөлгіші бар (мысалы, 4, 6, 8).
    - Санның цифрлары: Әр сан бір немесе бірнеше цифрдан тұрады. Мысалы, 345 санында 3 цифр бар: 3, 4, 5.

    Натурал сандар жиыны:
    - Шексіз, әр саннан кейін әрдайым келесі сан бар.
    - Математикада санау, есептеу және негізгі арифметикалық амалдарда қолданылады.

    Практикалық кеңестер:
    - Натурал сандармен амалдар жасағанда нәтижені тексеріп, теріс сан шықпайтынына назар аудару.
    - Қосу және көбейтуді жиі қолдану арқылы есептерді жеңілдетуге болады.
    - Натурал сандар жиынының қасиеттерін пайдаланып, жұп, тақ, жай және күрделі сандарды анықтау ыңғайлы.
    """

    case "Проценттер":
        return """
    Процент (латынша per cent — «жүзден бір») — бүтінді 100 бөлікке бөлетін сандық өлшем.
    1% = 1/100 = 0.01
    50% = 50/100 = 0.5

    Негізгі формулалар:
    Санның пайызын табу:
    Пайыздық мән = сан × пайыз / 100
    Мысалы: 200-дің 10%-ы = 200 × 10 / 100 = 20

    Пайыздан санды табу:
    Сан = пайыздық мән × 100 / пайыз
    Мысалы: 12 — бұл санның 60%-ы, онда сан = 12 × 100 / 60 = 20

    Пайызды ондыққа айналдыру:
    25% = 0.25
    80% = 0.8

    Пайыздық амалдар:
    Қосу: 100% + 10% = 110%
    Алу: 100% − 20% = 80%
    Күрделі пайыз: бастапқы санға бірнеше пайыздық өзгерістерді кезекпен қолдану.

    Қолданылу салалары:
    Сауда: жеңілдіктер мен бағаны есептеу
    Банк: пайыздық ставка, депозит, несие
    Статистика: үлестерді көрсету
    Ғылым: тәжірибе нәтижелерін пайызбен көрсету

    Мысал есептер:
    50%-дың 25%-ы = 50 × 25 / 100 = 12.5
    30%-ы 9 болса, толық сан = 9 × 100 / 30 = 30
    Баға 2000 теңге, 15% жеңілдік → жеңілдік = 2000 × 15 / 100 = 300; жаңа баға = 1700
    90%-ға 10% қосса: 90 + 10% = 90 × 1.10 = 99

    Процент түрлері:
    Жай пайыз: нақты пайыздық өзгеріс бір реттік есепте.
    Күрделі пайыз: пайыздық өзгерістер бірнеше кезеңдерде қосылады, мысалы, банктік депозитте.

    Пайыздарды салыстыру:
    25% = 0.25
    1/4 = 0.25
    0.25 × 100 = 25%

    Қосымша ережелер:
    Пайыздық мән 100%–дан артық болса, сан өскенін білдіреді.
    100%–дан аз болса, сан азайғанын білдіреді.
    0% — өзгеріс жоқ.

    Практикалық кеңестер:
    Кез келген пайыздық есепті ондыққа айналдырып, содан кейін санға көбейту ыңғайлы.
    Күрделі пайызды есептегенде әр кезеңнің нәтижесін келесі кезеңге қолдану керек.
    Процентті графикте көрсету арқылы үлестерді визуалды салыстыруға болады.
    """

    case "Жиындар":
        return """
    Жиын — белгілі бір қасиетке ие элементтердің толық тобы. Мысалы: A = {1, 2, 3, 4, 5}, B = {қызыл, жасыл, көк}.

    Элемент және мүшелік белгісі:
    - a ∈ A — элемент a жиын A-ға тиесілі.
    - a ∉ A — элемент a жиын A-ға жатпайды.

    Жиынның түрлері:
    - Бос жиын (∅) — ешқандай элементі жоқ жиын.
    - Шексіз жиын — элементтері шексіз.
    - Қайталау жоқ — әр элемент тек бір рет көрсетіледі.

    Жиындардың операциялары:
    - Қосынды (біріктіру): A ∪ B — екі жиынның барлық элементтері.
    - Кесіспе (intersection): A ∩ B — ортақ элементтер.
    - Айырым (difference): A  B — A-да бар, B-де жоқ элементтер.
    - Қосымша жиын (complement): A' — барлық мүмкін элементтер ішінде A-ға жатпайтын элементтер.

    Жиынның қасиеттері:
    - Коммутативтілік: A ∪ B = B ∪ A, A ∩ B = B ∩ A
    - Ассоциативтік: (A ∪ B) ∪ C = A ∪ (B ∪ C)
    - Дистрибутивтік: A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C)

    Субжиын (подмножество):
    - A ⊆ B — әр элементі B-де бар.
    - Мысал: A = {1, 2}, B = {1, 2, 3} ⇒ A ⊆ B

    Қуат жиын (Power set):
    - Жиынның барлық мүмкін қосымша жиындары.
    - Мысал: A = {1, 2}, P(A) = {∅, {1}, {2}, {1,2}}

    Декарттық көбейтінді:
    - A × B = {(a, b) | a ∈ A, b ∈ B}
    - Мысал: A = {1,2}, B = {x,y} ⇒ A × B = {(1,x),(1,y),(2,x),(2,y)}

    Практикалық кеңестер:
    - Venn диаграммаларын қолдану арқылы операцияларды оңай көрсетуге болады.
    - Айырым, қосынды, кесіспені сурет арқылы есептеу ыңғайлы.
    - Субжиын және қуат жиындары логикалық есептерде жиі пайдаланылады.
    """

    case "Ондық бөлшектер":
        return """
    Ондық бөлшектер — бөлшектің ондық сандық жазылуы, яғни бөлшектің 10 негізінде жазылуы. Мысалы: 0.1, 1.25, 3.141.

    Ондық бөлшектердің түрлері:
    - Таза ондық бөлшек: 0.5, 0.75 — бөлшектің соңында бүтін саны жоқ.
    - Аралас ондық бөлшек: 1.2, 3.75 — бүтін сан мен ондық бөлік бірге көрсетіледі.
    - Шексіз ондық бөлшек: π ≈ 3.141592… — кейбір бөлшектерді дәл көрсету мүмкін емес, үтірден кейін шексіз жалғасады.
    - Дөңгелектелген ондық бөлшек: шексіз бөлшекті қажетті дәлдікке дейін қысқарту.

    Ондық бөлшектерді жазу:
    - Бөлшекті ондыққа айналдыру: 1/2 = 0.5, 3/4 = 0.75
    - Ондық бөлшекті пайызға айналдыру: 0.25 × 100% = 25%
    - Пайыздан ондыққа: 40% = 0.4

    Ондық бөлшектермен амалдар:
    - Қосу: 1.2 + 3.5 = 4.7
    - Алу: 5.0 − 2.25 = 2.75
    - Көбейту: 0.5 × 0.2 = 0.1
    - Бөлу: 1.2 ÷ 0.4 = 3

    Ондық бөлшектердің қасиеттері:
    - Коммутативтік: a + b = b + a, a × b = b × a
    - Ассоциативтік: (a + b) + c = a + (b + c)
    - Дистрибутивтік: a × (b + c) = a × b + a × c

    Ондық бөлшектерді салыстыру:
    - Үлкендігі бүтін бөлігінен және кейінгі ондық бөлігінен анықталады.
    - Мысал: 0.75 > 0.5, 1.2 < 1.25

    Практикалық кеңестер:
    - Ондық бөлшектерді есептеуде нүкте мен үтірді шатастырмау.
    - Күрделі есептерде ондық бөлшектерді бөлшекке айналдырып есептеген ыңғайлы.
    - Қарапайым калькуляторлар мен электрондық кестелерде ондық бөлшектермен амалдар жиі қолданылады.
    """

    default:
        return ""
    }
}



// MARK: Settings (placeholder)

struct SettingsView: View {
    @AppStorage("darkMode") private var darkMode = false // @AppStorage қолдану
    @State private var soundOn = true
    @State private var difficulty = "Medium"
    
    let levels = ["Easy", "Medium", "Hard"]

    var body: some View {
        ZStack {
            // Фонды ауыстыру
            (darkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            Form {
                Section(header: Text("Appearance").foregroundColor(darkMode ? .white : .black)) {
                    Toggle("Dark Mode", isOn: $darkMode)
                        .onChange(of: darkMode) { _ in
                            // фон автоматты өзгереді
                        }
                }

                Section(header: Text("Sound").foregroundColor(darkMode ? .white : .black)) {
                    Toggle("Sound On", isOn: $soundOn)
                        .toggleStyle(SwitchToggleStyle(tint: darkMode ? .orange : .blue))
                }

                Section(header: Text("Difficulty").foregroundColor(darkMode ? .white : .black)) {
                    Picker("Level", selection: $difficulty) {
                        ForEach(levels, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section {
                    Button("Reset Statistics") {
                        // статистиканы қалпына келтіру
                    }
                    .foregroundColor(.red)
                }
            }
            .accentColor(darkMode ? .orange : .blue)
        }
        .navigationTitle("Settings")
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}




// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct AllConspectsView: View {
    let categories: [Category]
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            ForEach(categories) { cat in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(cat.title)
                            .font(.largeTitle)
                            .bold()
                        Text(getConspect(for: cat.title))
                            .font(.body)
                    }
                    .padding()
                }
                .tag(cat.id)
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

