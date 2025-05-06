//
//  WeeklyView.swift
//  SDGP6
//
//  Created by 박현빈 on 5/6/25.
//

// WeeklyView.swift - mock data 기반으로 구성

import SwiftUI

struct WeeklyView: View {
    @StateObject private var viewModel = MockWeeklyViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - 원형 통계 표시
                ZStack {
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.progress))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 120, height: 120)

                    VStack {
                        Text("\(viewModel.score)")
                            .font(.title)
                            .bold()
                        Text("\(viewModel.steps) steps")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                // MARK: - 상세 통계
                HStack(spacing: 32) {
                    VStack {
                        Text("\(viewModel.calories)")
                            .font(.headline)
                        Text("cal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text("\(viewModel.distance)")
                            .font(.headline)
                        Text("miles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text("\(viewModel.moveMinutes)")
                            .font(.headline)
                        Text("Move Min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: - 수면 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last sleep")
                        .font(.headline)
                    HStack {
                        Text(viewModel.lastSleep)
                            .font(.subheadline)
                        Spacer()
                        Text("Asleep")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal)

                // MARK: - 일별 목표 달성
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your daily goals")
                        .font(.headline)
                    Text("Last 7 days")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        ForEach(viewModel.dailyGoals, id: \ .self) { reached in
                            Image(systemName: reached ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(reached ? .blue : .gray)
                        }
                        Text("\(viewModel.achievedCount)/7")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                //.padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding(.top, 32)
        }
        .navigationTitle("Weekly Summary")
    }
}

#Preview {
    WeeklyView()
}
