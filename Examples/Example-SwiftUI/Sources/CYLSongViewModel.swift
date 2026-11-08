//
//  CYLSongViewModel.swift
//  Example-SwiftUI
//
//  Created by 王双伟 on 2025/11/12.
//

import Foundation
import SwiftUI

class CYLSongViewModel: ObservableObject {
    @Published var librarySongList: [CYLSongInfo]?

    init() {
        // 生成假数据
        generateMockData()
    }

    private func generateMockData() {
        let mockSongs = [
            CYLSongInfo(title: "夜曲", artist: "周杰伦", album: "十一月的萧邦", duration: "3:45"),
            CYLSongInfo(title: "青花瓷", artist: "周杰伦", album: "我很忙", duration: "4:12"),
            CYLSongInfo(title: "稻香", artist: "周杰伦", album: "魔杰座", duration: "3:58"),
            CYLSongInfo(title: "告白气球", artist: "周杰伦", album: "周杰伦的床边故事", duration: "3:35"),
            CYLSongInfo(title: "听妈妈的话", artist: "周杰伦", album: "依然范特西", duration: "4:23"),
            CYLSongInfo(title: "简单爱", artist: "周杰伦", album: "范特西", duration: "4:30"),
            CYLSongInfo(title: "七里香", artist: "周杰伦", album: "七里香", duration: "4:59"),
            CYLSongInfo(title: "双截棍", artist: "周杰伦", album: "范特西", duration: "3:50"),
            CYLSongInfo(title: "东风破", artist: "周杰伦", album: "叶惠美", duration: "4:28"),
            CYLSongInfo(title: "千里之外", artist: "周杰伦", album: "依然范特西", duration: "4:16"),
            CYLSongInfo(title: "发如雪", artist: "周杰伦", album: "十一月的萧邦", duration: "4:58"),
            CYLSongInfo(title: "菊花台", artist: "周杰伦", album: "依然范特西", duration: "4:53"),
            CYLSongInfo(title: "不能说的秘密", artist: "周杰伦", album: "不能说的秘密", duration: "4:56"),
            CYLSongInfo(title: "珊瑚海", artist: "周杰伦", album: "十一月的萧邦", duration: "4:15"),
            CYLSongInfo(title: "安静", artist: "周杰伦", album: "范特西", duration: "4:30"),
            CYLSongInfo(title: "晴天", artist: "周杰伦", album: "叶惠美", duration: "4:29"),
            CYLSongInfo(title: "以父之名", artist: "周杰伦", album: "叶惠美", duration: "5:42"),
            CYLSongInfo(title: "龙卷风", artist: "周杰伦", album: "Jay", duration: "3:43"),
            CYLSongInfo(title: "星晴", artist: "周杰伦", album: "Jay", duration: "4:16"),
            CYLSongInfo(title: "可爱女人", artist: "周杰伦", album: "Jay", duration: "3:56")
        ]

        librarySongList = mockSongs
    }

    // 刷新数据
    func refreshData() {
        generateMockData()
    }

    // 加载更多数据
    func loadMoreData() {
        guard var currentList = librarySongList else {
            generateMockData()
            return
        }

        let moreSongs = [
            CYLSongInfo(title: "黑色幽默", artist: "周杰伦", album: "Jay", duration: "4:40"),
            CYLSongInfo(title: "完美主义", artist: "周杰伦", album: "Jay", duration: "4:28"),
            CYLSongInfo(title: "娘子", artist: "周杰伦", album: "Jay", duration: "4:00"),
            CYLSongInfo(title: "斗牛", artist: "周杰伦", album: "范特西", duration: "4:36"),
            CYLSongInfo(title: "忍者", artist: "周杰伦", album: "范特西", duration: "2:36")
        ]

        currentList.append(contentsOf: moreSongs)
        librarySongList = currentList
    }
}
