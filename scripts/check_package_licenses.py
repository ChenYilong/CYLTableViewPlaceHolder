#!/usr/bin/env python3
"""[EN] Every package published to an external registry carries this project's license (instructions.md, "License in
every published package").

Each entry below is a copy of the root LICENSE inside a package's own resource folder, so the license ships with the
package itself (the iOS resource bundle, the Android AAR's META-INF, the HarmonyOS ohpm package and its rawfile folder,
the WeChat Mini Program npm package's published folder). The check fails when a copy is missing or differs from LICENSE,
and when a package manifest does not declare the MIT license.

[CN] 每个发布到外部仓库的包都带有本项目的协议文件（instructions.md 的 "License in every published package"）。下面每一项都是根目录
LICENSE 在包内资源目录中的副本；缺失或与 LICENSE 不一致、或包清单未声明 MIT 协议时检查失败。
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# [EN] (registry, copy of LICENSE inside the package). [CN]（发布渠道，包内的 LICENSE 副本）。
COPIES = [
    ('CocoaPods / Carthage (iOS bundle)', 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle/LICENSE'),
    ('Maven (android/placeholder AAR)', 'android/placeholder/src/main/resources/META-INF/cylplaceholder/LICENSE'),
    ('Maven (android/merged/library AAR, CYLRefresh)', 'android/merged/library/src/main/resources/META-INF/cylrefresh/LICENSE'),
    ('Maven (android/merged/library/rive AAR)', 'android/merged/library/rive/src/main/resources/META-INF/cylrefresh-rive/LICENSE'),
    ('ohpm (HarmonyOS package root)', 'CrossPlatform/harmonyos-cylplaceholder/cylplaceholder/LICENSE'),
    ('ohpm (HarmonyOS rawfile)', 'CrossPlatform/harmonyos-cylplaceholder/cylplaceholder/src/main/resources/rawfile/cylplaceholder/LICENSE'),
    ('npm (WeChat Mini Program package root)', 'CrossPlatform/wechat-miniprogram-cylplaceholder/LICENSE'),
    ('npm (WeChat Mini Program published folder src/)', 'CrossPlatform/wechat-miniprogram-cylplaceholder/src/LICENSE'),
]

# [EN] Third-party licenses that must ship inside a package too: (copy, original). [CN] 必须随包发布的第三方协议：（副本，原件）。
THIRD_PARTY = [
    ('android/placeholder/src/main/resources/META-INF/cylplaceholder/LICENSE.placeholder-third-party',
     'android/placeholder/LICENSE.placeholder-third-party'),
    ('android/placeholder/src/main/resources/META-INF/cylplaceholder/LICENSE.material-design-icons',
     'android/placeholder/LICENSE.material-design-icons'),
    ('android/merged/library/src/main/resources/META-INF/cylrefresh/LICENSE.SmartRefreshLayout.txt',
     'android/merged/library/LICENSE.SmartRefreshLayout.txt'),
]

# [EN] Packages of another project copied into this repository unchanged (their own LICENSE, not this project's): the
#      copy must keep its upstream LICENSE and record its source commit. (package folder, file naming the commit)
# [CN] 原样复制到本仓库的其他项目的包（保留其自身的 LICENSE，而不是本项目的）：副本必须保留上游 LICENSE 并记录来源 commit。
VENDORED = [
    # [EN] CYLTabBarController's CYLAnimatedItem for HarmonyOS, by scripts/sync-harmonyos-cylanimateditem.sh (MIT).
    ('CrossPlatform/harmonyos-cylplaceholder/cylanimateditem', 'UPSTREAM_COMMIT'),
]

# [EN] Manifests that must declare the license. [CN] 必须声明协议的包清单。
MANIFESTS = [
    ('CYLTableViewPlaceHolder.podspec', r"s\.license\s*=\s*\{\s*:type\s*=>\s*'MIT'"),
    ('CrossPlatform/harmonyos-cylplaceholder/cylplaceholder/oh-package.json5', r'"license"\s*:\s*"MIT"'),
    ('CrossPlatform/harmonyos-cylplaceholder/cylanimateditem/oh-package.json5', r'"license"\s*:\s*"MIT"'),
    ('CrossPlatform/wechat-miniprogram-cylplaceholder/package.json', r'"license"\s*:\s*"MIT"'),
]


def read(path):
    with open(os.path.join(ROOT, path), 'rb') as handle:
        return handle.read()


def main():
    problems = []
    license_text = read('LICENSE')
    for registry, path in COPIES:
        if not os.path.isfile(os.path.join(ROOT, path)):
            problems.append('%s: missing %s' % (registry, path))
        elif read(path) != license_text:
            problems.append('%s: %s differs from LICENSE' % (registry, path))
    for copy, original in THIRD_PARTY:
        if not os.path.isfile(os.path.join(ROOT, copy)):
            problems.append('missing %s (copy of %s)' % (copy, original))
        elif read(copy) != read(original):
            problems.append('%s differs from %s' % (copy, original))
    for folder, commit_file in VENDORED:
        upstream_license = os.path.join(folder, 'LICENSE')
        if not os.path.isfile(os.path.join(ROOT, upstream_license)):
            problems.append('missing %s (the upstream license of the copied package)' % upstream_license)
        commit_path = os.path.join(folder, commit_file)
        if not os.path.isfile(os.path.join(ROOT, commit_path)) or \
                not re.search(r'^commit=[0-9a-f]{40}$', read(commit_path).decode('utf-8'), re.M):
            problems.append('%s does not record the upstream commit' % commit_path)
    for path, pattern in MANIFESTS:
        if not re.search(pattern, read(path).decode('utf-8')):
            problems.append('%s does not declare the MIT license' % path)
    if problems:
        print('\n'.join(problems))
        print('Copy the license files into each package (instructions.md, "License in every published package").')
        return 1
    print('%d packages carry LICENSE, %d third-party licenses ship, %d copied packages keep their upstream LICENSE, '
          '%d manifests declare MIT.' % (len(COPIES), len(THIRD_PARTY), len(VENDORED), len(MANIFESTS)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
