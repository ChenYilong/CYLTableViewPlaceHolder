//
//  ContentView.swift
//  Adapted from MJRegreshDemo by 王双伟, 2025/11/12.
//

import SwiftUI
// Advanced SPI: open version ranges (`.iOS(.v13...)`), so a new iOS release keeps finding the scroll view.
@_spi(Advanced) import SwiftUIIntrospect
import CYLTableViewPlaceHolder

private final class CYLScrollViewReference: ObservableObject {
    weak var scrollView: UIScrollView?
}

struct CYLContentView: View {
    @StateObject private var viewModel = CYLSongViewModel()
    @StateObject private var scrollReference = CYLScrollViewReference()
    @State private var refreshStatus = "Idle"

    private var reproducesOriginalIssue: Bool {
        ProcessInfo.processInfo.arguments.contains("-reproduce-1628")
    }

    var body: some View {
        NavigationView {
          VStack {
            NavigationLink("Open footer lifecycle", destination: CYLFooterLifecycleView())
            Text(refreshStatus)
                .accessibilityIdentifier("refreshStatus")
            Button("Start refresh") {
                scrollReference.scrollView?.cylHeader?.beginRefreshing()
            }
            ScrollView {
                LazyVStack(spacing: 1) {
                    if let songList = viewModel.librarySongList {
                        ForEach(Array(songList.enumerated()), id: \.element.id) { index, _ in
                            Text("\(index)")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color.blue)
                        }
                    }
                }
            }
            .accessibilityIdentifier("songList")
            // An open range: the closed list (.v13 … .v26) never called the closure on iOS 27, so no refresh control was
            // installed and every #1628 check failed (2026-11-22, Xcode 27.2, iOS 27.2 simulator).
            .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                scrollReference.scrollView = scrollView
                if reproducesOriginalIssue {
                    scrollView.contentInsetAdjustmentBehavior = .automatic
                    scrollView.contentInset = .zero
                    configureRefresh(for: scrollView)
                } else if scrollView.cylHeader == nil && scrollView.cylFooter == nil {
                    scrollView.contentInsetAdjustmentBehavior = .automatic
                    configureRefresh(for: scrollView)
                }
            }
          }
          .background(Color(cylHexString: "#F4F4F4"))
          .navigationTitle("Refresh demo")
        }
    }

    private struct CYLRepresentedFooter: UIViewRepresentable {
        func makeUIView(context: Context) -> CYLRefreshBackNormalFooter {
            let footer = CYLRefreshBackNormalFooter {}
            footer.accessibilityIdentifier = "representedFooter"
            return footer
        }

        func updateUIView(_ uiView: CYLRefreshBackNormalFooter, context: Context) {}
    }

    private struct CYLFooterLifecycleView: View {
        var body: some View {
            VStack {
                Text("Footer lifecycle")
                CYLRepresentedFooter()
                    .frame(height: 60)
            }
            .navigationTitle("Footer lifecycle")
        }
    }

    private func configureRefresh(for scrollView: UIScrollView) {
        let header = CYLRefreshNormalHeader { [weak scrollView] in
            viewModel.refreshData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                guard let scrollView = scrollView,
                      let header = scrollView.cylHeader,
                      let window = scrollView.window else {
                    refreshStatus = "Lost refresh"
                    return
                }
                let viewport = scrollView.convert(scrollView.bounds, to: window)
                let headerFrame = header.convert(header.bounds, to: window)
                let visible = !headerFrame.intersection(viewport).isEmpty
                    && !header.isHidden && header.alpha > 0
                refreshStatus = header.isRefreshing && header.superview === scrollView && visible
                    ? "Refreshing" : "Lost refresh"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                scrollView?.cylHeader?.endRefreshing()
                refreshStatus = "Finished"
            }
        }
        scrollView.cylHeader = header
        scrollView.cylFooter = CYLRefreshAutoNormalFooter { [weak scrollView] in
            viewModel.loadMoreData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                scrollView?.cylFooter?.endRefreshing()
            }
        }
    }
}
