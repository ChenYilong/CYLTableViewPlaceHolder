# Folder instructions

This folder contains refresh component source and inherits the vault's root instructions.

CYLRefresh is the library's only refresh kernel (`instructions.md`, "One refresh library: CYLRefresh"): every control
subclasses `CYLRefreshComponent`. Logic shared by several controls lives once: the state texts in
`CYLRefreshComponent (CYLRefreshStateTitles)`, the animation images and icon files in
`CYLRefreshComponent (CYLRefreshIconLayout)` (`CYLRefreshIconView.h`), and the normal footers' no-more-data image in
`CYLRefreshFooter (CYLRefreshNoMoreDataImage)` (an extension in `Base/CYLRefreshFooter.swift` since 2026-11-20). Add new shared behavior there instead of copying it into each control.
`Custom/Rive/` holds the Rive refresh header, compiled by the Rive subspec.
