//
//  NewFileWithTemplateSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/19/26.
//

import SwiftUI

struct NewFileWithTemplateSheet: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @Environment(\.dismiss) private var dismiss

    @State private var newFilePath = ""

    var body: some View {
        VStack(alignment: .leading) {
            form
            buttons
                .padding()
        }
        .frame(width: 700 /*, height: 600*/)
        .task {
            initSheet()
        }
    }

    var form: some View {
        Form {
            @Bindable var app = app

            Section("New File") {
                TextField("New File", text: $newFilePath)
                    .labelsHidden()
                    .textFieldStyle(.roundedBorder)
            }

            Section("Filename Templates") {
                Picker("Filename Templates", selection: $app.newFileTemplateIndex) {
                    let range = 0 ..< app.newFileTemplates.count
                    ForEach(range, id: \.self) { index in
                        TextField("", text: $app.newFileTemplates[index])
                            .frame(maxWidth: .infinity)
                            .labelsHidden()
                            .textFieldStyle(.roundedBorder)
                            .tag(index)
                    }
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()
                .onChange(of: app.newFileTemplateIndex, initial: true) {
                    updateNewFilePath()
                }
            }

            Section("Expressions") {
                Text(expressionExamples())
                    .textSelection(.enabled)
            }
        }
        .formStyle(.grouped)
    }

    var buttons: some View {
        HStack {
            Button("Reset templates to defaults") {
                app.resetNewFileTemplatesToDefaults()
            }
            Spacer()

            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.escape)

            Button("OK") {
                submit()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }
    }

    func initSheet() {
        updateNewFilePath()
    }

    func submit() {
        browser.newFileWithTemplateSubmitted(with: newFilePath)
    }

    func updateNewFilePath() {
        let template = app.newFileTemplates[app.newFileTemplateIndex]
        newFilePath = expand(template: template)
    }

    func expressionExamples() -> String {
        let exps = ["{year}", "{month}", "{day}", "{hour}", "{minute}", "{second}", "{weekday}", "{weekday-short}", "{selected-folder}"]
        var result = ""
        for exp in exps {
            result += "\(exp): \(expand(template: exp)), "
        }
        return result
    }

    func expand(template: String) -> String {
        guard let param = browser.newFileWithTemplateContext else { return "" }
        let calendar = Calendar.current
        let date = Date()
        let components = calendar.dateComponents(in: calendar.timeZone, from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        let weekday = components.weekday ?? 0
        let folderRelativePath = param.folderRelativePath
        return template
            .replacingOccurrences(of: "{year}", with: year.formatted(.number.grouping(.never).precision(.integerLength(4))))
            .replacingOccurrences(of: "{month}", with: month.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{day}", with: day.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{hour}", with: hour.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{minute}", with: minute.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{second}", with: second.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{weekday}", with: calendar.standaloneWeekdaySymbols[weekday - 1])
            .replacingOccurrences(of: "{weekday-short}", with: calendar.shortWeekdaySymbols[weekday - 1])
            .replacingOccurrences(of: "{selected-folder}", with: folderRelativePath)
    }
}
