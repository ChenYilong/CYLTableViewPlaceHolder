//
//  ContentView.swift
//  Adapted from MJRegreshDemo by 王双伟, 2025/11/12.
//

import SwiftUI
import SwiftUIIntrospect
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
                scrollReference.scrollView?.cyl_header?.beginRefreshing()
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
            .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18, .v26)) { scrollView in
                scrollReference.scrollView = scrollView
                if reproducesOriginalIssue {
                    scrollView.contentInsetAdjustmentBehavior = .automatic
                    scrollView.contentInset = .zero
                    configureRefresh(for: scrollView)
                } else if scrollView.cyl_header == nil && scrollView.cyl_footer == nil {
                    scrollView.contentInsetAdjustmentBehavior = .automatic
                    configureRefresh(for: scrollView)
                }
            }
          }
          .background(Color(cyl_hexString: "#F4F4F4"))
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
                      let header = scrollView.cyl_header,
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
                scrollView?.cyl_header?.endRefreshing()
                refreshStatus = "Finished"
            }
        }
        scrollView.cyl_header = header
        scrollView.cyl_footer = CYLRefreshAutoNormalFooter { [weak scrollView] in
            viewModel.loadMoreData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                scrollView?.cyl_footer?.endRefreshing()
            }
        }
    }
}
