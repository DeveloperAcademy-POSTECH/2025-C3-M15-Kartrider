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
                            tournamentViewModel.handleSelection(firstCandidate)
                        },
                        onSelectB: {
                            tournamentViewModel.selectedOption = .b
                            tournamentViewModel.handleSelection(secondCandiate)
                        },
                        buttonDisabled: tournamentViewModel.isTTSPlaying,
                        selectedOption: tournamentViewModel.selectedOption
                    )
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task {
            tournamentViewModel.setContext(context)
            tournamentViewModel.loadTournament(context: context)
            tournamentViewModel.speakCurrentMatch()
        }
    }
}


#Preview {

    let sample = ContentMeta(
        title: "눈 떠보니 내가 T1 페이커?!",
        summary: "2025 월즈가 코 앞인데 아이언인 내가 어느날 눈 떠보니 페이커 몸에 들어와버렸다.",
        type: .story,
        hashtags: ["빙의", "LOL", "고트"],
        thumbnailName: nil
    )

    TournamentView(content: sample)
}
