import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MockHomeViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    // MARK: - Profile Section
                    Text("my page")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                    ZStack{
                        RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 370,height: 140)
                                
                                .offset(y:20)
                        VStack(spacing: 15) {
                            
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .center, spacing: 10) {
                                Text(viewModel.userName)
                                    .font(.title2)
                                    .bold()
                                
                                HStack(alignment: .center, spacing: 10) {
                                    VStack(alignment: .center) {
                                        Text("Total fasts")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(viewModel.totalFasts)")
                                            .font(.headline)
                                    }
                                    .offset(x:-6)
                                    
                                    VStack(alignment: .center) {
                                        Text("Achievements")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(viewModel.achievements)")
                                            .font(.headline)
                                    }
                                    
                                    VStack(alignment: .center) {
                                        Text("Longest streak")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(viewModel.longestStreak)")
                                            .font(.headline)
                                    }
                                }
                                .offset(x:13)
                                
                            }
                            .padding(.horizontal)
                            
                            
                            
                        }
                    }
                    .padding(.bottom,20)
                    // MARK: - Calendar Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Calendar")
                                .font(.headline)
                            Spacer()
                            Button("SEE ALL") {
                                // Handle See All tap
                            }
                            .font(.caption)
                            .foregroundColor(Color.purple)
                            .bold()
                        }
                        .padding(.horizontal)

                        CalendarView(datesWithReduction: viewModel.datesWithReduction)
                    }

                    // MARK: - Weekly Message Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weekly Metrics")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)

                        Text(viewModel.weeklyMessage)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                    }
                }
                .padding(.top,30)
                .padding(.bottom, 10)
            }
        }
    }
}

struct CalendarView: View {
    private let calendar = Calendar.current
    let datesWithReduction: [Date: Bool]

    private var dates: [Date] {
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(dates, id: \.self) { date in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .strokeBorder(isReduced(date) ? Color.green : Color.gray.opacity(0.2), lineWidth: 3)
                                .frame(width: 32, height: 32)

                            Text("\(calendar.component(.day, from: date))")
                                .font(.caption)
                                .foregroundColor(isToday(date) ? .black : .gray)
                        }
                        if isToday(date) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }

            HStack(spacing: 16) {
                LegendCircle(color: .green, text: "Nutrition")
                LegendCircle(color: .pink, text: "Activity")
                LegendCircle(color: .orange, text: "Restoration")
                LegendCircle(color: .purple, text: "Sleep")
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func isReduced(_ date: Date) -> Bool {
        datesWithReduction[calendar.startOfDay(for: date)] ?? false
    }
}

struct LegendCircle: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption)
        }
    }
}


#Preview {
    HomeView()
}
