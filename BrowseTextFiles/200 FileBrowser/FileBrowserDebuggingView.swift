//
//  FileBrowserDebuggingView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/23/26.
//

import SwiftUI

struct FileBrowserDebuggingView: View {
    @Environment(\.openWindow) private var openWindow
    @SceneStorage("sceneValue") private var sceneValue: String = ""

    // init 가 여러 상황에서 계속 호출된다.
    // 초기화 인자가 유의미하게 들어오기 전에 nil 인자로 3번정도 실행된다;
    // initParam 을 State에 저장하면 안 될 듯.
    // @State var initParam: FileBrowserInitParam?

    let initParam: FileBrowserInitParam?

    init(_ initParam: FileBrowserInitParam?) {
        // init 에서 state 변수를 수정하는 것은 잘 되지 않는다; 쓰면 안 된다;
        // guard let initParam else { return }
        // self.id  = initParam.id

        self.initParam = initParam

        printInitParamID("init")
    }

    var body: some View {
        let _ = printInitParamID("body")
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            TextField("SceneValue", text: $sceneValue)
            Button("Open window") {
                openWindow(id: "browser", value: FileBrowserInitParam())
            }
        }
        .padding()
        // init 에서 state 에 값을 넣을 수 없으므로,
        // init 에서 임시 프로퍼티에 initParam 을 넣어두고,
        // task 에서 id 로 변경을 감지한 후, 후작업을 해야 한다.
        .task(id: initParam) {
            printInitParamID("task")
        }
    }

    func printInitParamID(_ part: String) {
        print("\(part): id, \(self.initParam?.id.uuidString ?? "nil")")
    }
}

#Preview {
//    FileBrowserDebuggingView()
}
