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


#Preview {

    let sample = ContentMeta(
        title: "눈 떠보니 내가 T1 페이커?!",
        summary: "2025 월즈가 코 앞인데 아이언인 내가 어느날 눈 떠보니 페이커 몸에 들어와버렸다.",
        type: .story,
        hashtags: [
            Hashtag(value: "빙의"),
            Hashtag(value: "LOL"),
            Hashtag(value: "고트")
        ],
        thumbnailName: nil
    )

    TournamentView(content: sample)
}
