# Folder instructions

This folder is a copy of the third-party KLTableViewAndCollectionViewPlaceholder
draft, inspired by CYLTableViewPlaceHolder (see its `README.md`). Keep its original license, README and
author attribution. It inherits the repository instructions.

## Linked issues

None. It is the reference for the automatic placeholder API
(`cyl_placeholderViewBlock:`), which answers
[#11](https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/11) (collection
views) for this repository; reproduce that in `Examples/Example` (**Auto → Collection**).

## Notes

- It has its own `KLTableViewAndCollectionViewPlaceholder.xcodeproj`; it is not built
  by CI.
- Carthage discovers its shared scheme and builds
  `KLTableViewAndCollectionViewPlaceholder.xcframework`; apps do not need it.
