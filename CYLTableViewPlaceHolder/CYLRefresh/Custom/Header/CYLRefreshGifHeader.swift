//
//  CYLRefreshGifHeader.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API (`gifView`,
//      `setImages:duration:forState:`, `setImages:forState:`): the MJRefresh names call the general methods of
//      CYLRefreshAnimationHeader, so old code keeps working.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API（`gifView`、`setImages:duration:forState:`、
//      `setImages:forState:`）不变：MJRefresh 的方法名调用 CYLRefreshAnimationHeader 的通用方法，旧代码照常工作。

import UIKit

/**
 * [EN] The MJRefresh name of `CYLRefreshAnimationHeader`, kept for compatibility: `gifView` and `setImages:…` call the general
 *      methods. New code can use `CYLRefreshAnimationHeader`. [CN] `CYLRefreshAnimationHeader` 在 MJRefresh 中的名字，为兼容保留：`gifView` 与
 *      `setImages:…` 调用通用方法。新代码可以使用 `CYLRefreshAnimationHeader`。
 */
@objc(CYLRefreshGifHeader)
open class CYLRefreshGifHeader: CYLRefreshAnimationHeader {

    /**
     * [EN] The same view as `animationView`. [CN] 与 `animationView` 是同一个视图。
     */
    @objc open var gifView: UIImageView {
        animationView
    }

    /**
     * [EN] Calls `-setAnimationImages:duration:forState:` with the images among `images`.
     * [CN] 以 `images` 中的图片调用 `-setAnimationImages:duration:forState:`。
     */
    @discardableResult
    @objc(setImages:duration:forState:)
    open func setImages(_ images: [Any], duration: TimeInterval, for state: CYLRefreshState) -> Self {
        setAnimationImages(images.compactMap { $0 as? UIImage }, duration: duration, for: state)
    }

    /**
     * [EN] Calls `-setAnimationImages:forState:` with the images among `images`.
     * [CN] 以 `images` 中的图片调用 `-setAnimationImages:forState:`。
     */
    @discardableResult
    @objc(setImages:forState:)
    open func setImages(_ images: [Any], for state: CYLRefreshState) -> Self {
        setAnimationImages(images.compactMap { $0 as? UIImage }, for: state)
    }
}
