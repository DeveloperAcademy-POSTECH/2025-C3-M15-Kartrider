//
//  TournamentView.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import SwiftData
import SwiftUI

struct TournamentView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Environment(\.modelContext) private var context
    
    @StateObject private var tournamentViewModel: TournamentViewModel

    init(content: ContentMeta) {
        _tournamentViewModel = StateObject(
            wrappedValue: TournamentViewModel(content: content))
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: .play(title: tournamentViewModel.title),
            onTapLeft: {
                tournamentViewModel.cleanup()
                coordinator.pop()
            }
        ) {
            VStack(spacing: 16) {
                Divider()

                if tournamentViewModel.isFinished,
                    let winner = tournamentViewModel.winner
                {
                    TournamentResultView(winner: winner.name) {
                        coordinator.popToRoot()
                    }
                } else if let (firstCandidate, secondCandiate) = tournamentViewModel.currentCandidates {
                    TournamentMatchView(
                        roundDescription: tournamentViewModel.currentRoundDescription,
                        a: firstCandidate.name,
                        b: secondCandiate.name,
                        onSelectA: {
                            tournamentViewModel.selectedOption = .a
                            tournamentViewModel.processSelection(firstCandidate)
                        },
                        onSelectB: {
                            tournamentViewModel.selectedOption = .b
                            tournamentViewModel.processSelection(secondCandiate)
                        },
                        buttonDisabled: tournamentViewModel.isTTSPlaying,
                        selectedOption: tournamentViewModel.selectedOption
                    )
                    
                    Spacer()

                    TTSControlButton(
                        isSpeaking: tournamentViewModel.isTTSPlaying
                    ) {
                        tournamentViewModel.toggleSpeaking()
                    }
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task {
            tournamentViewModel.configure(context: context)
            tournamentViewModel.loadTournament()
            tournamentViewModel.speakMatchIntro()
        }
    }
}

#Preview("매치") {
    TournamentMatchView(
        roundDescription: "4강\n2개의 경기 중 1번째 경기",
        a: "아이스크림",
        b: "초콜릿",
        onSelectA: {},
        onSelectB: {},
        buttonDisabled: false,
        selectedOption: nil
    )
    .environmentObject(NavigationCoordinator())
}

#Preview("결과") {
    TournamentResultView(winner: "아이스크림") {}
        .environmentObject(NavigationCoordinator())
}
