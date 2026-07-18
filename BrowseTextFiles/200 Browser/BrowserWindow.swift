//
//  BrowserWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct BrowserWindow: Scene {
    @Environment(AppState.self) var app

    init() {
        printLog("init browser window")
    }

    var body: some Scene {
        // WindowGroup(... for:) 를 사용해 오픈할 디렉토리 인자를 전달하였더니 BrowserView 가 3번 생성되는 현상이 있다.
        // for: 없는 WindowGroup(...) 을 사용하면 그런 현상이 없다.
        // 먼가 일이 복잡해 지면서 루트 뷰가 여러번 생성되는 것 같다;

        // 오픈할 디렉토리를 for: 로 전달하더라도 디렉토리가 같으면 같은 윈도우로 인식한다.
        // 새로운 윈도우를 만들어주지 않는다.
        // 이걸 해결하려면 UUID 필드를 추가행야 한다.
        // 이것도 좀 문제인 것 같다.

        // 위 현상들을 피하기 위해 for: 인자를 쓰지 말고,
        // 오픈할 디렉토리는 app 로 전달하는 방식으로 우회하는 것이 안정적일 것 같다;

        // WindowGroup("Browser", id: "browser" , for: BrowserInitParam.self ) { $initParam in
        //     BrowserView(app: app, initParam: initParam)
        // }
        // defaultValue: {
        //     BrowserInitParam()
        // }

        WindowGroup("Browser", id: "browser") {
            BrowserContainer()
        }
        .defaultWindowPlacement { proxy, context in
            app.makeWindowPlacement(
                for: "browser",
                uuid: nil,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 960, height: 600)
            )
        }
        .commands {
            TextEditingCommands()
            BrowserCommands()
        }
    }

}

