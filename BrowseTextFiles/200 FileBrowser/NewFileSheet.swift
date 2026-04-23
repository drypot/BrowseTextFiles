//
//  NewFileSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/19/26.
//

import SwiftUI

fileprivate struct OptionItem: Identifiable {
    let id = UUID()
    var title: String
    var isSelected: Bool = false
}

struct NewFileSheet: View {
    @Environment(SettingsData.self) var settings
    @Environment(\.dismiss) private var dismiss

    @State private var newFilePath = ""

    @Bindable var status: FileBrowserStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("New File")
                .font(.headline)
                .padding()
            Form {
                Section(header: Text("Relative file path from the root")) {
                    TextField("", text: $newFilePath)
                        .frame(maxWidth: .infinity)
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                }
                Section(header: Text("Templates")) {
                    @Bindable var settings = settings
                    let range = 0 ..< settings.newFileTemplates.count
                    ForEach(range, id: \.self) { index in
                        HStack {
                            let selected = settings.newFileTemplateIndex == index
                            Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.accentColor)
                                .onTapGesture {
                                    settings.newFileTemplateIndex = index
                                    updateNewFilePath()
                                }
                            TextField("", text: $settings.newFileTemplates[index])
                                .frame(maxWidth: .infinity)
                                .labelsHidden()
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: settings.newFileTemplates[index]) {
                                    if selected {
                                        updateNewFilePath()
                                    }
                                }

                        }
                    }
                }
                Section(header: Text("Expressions")) {
                    Text(expressionExamples())
                        .textSelection(.enabled)
                }
            }
            .formStyle(.grouped)

            HStack {
                Button("Reset templates to defaults") {
                    settings.resetNewFileTemplatesToDefaults()
                }
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Button("OK") {
                    saveSheet()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 700, height: 600)
        .onAppear {
            loadSheet()
        }
    }

    func loadSheet() {
        updateNewFilePath()
    }

    func saveSheet() {
        Task {
            status.makeNewFile(path: newFilePath)
        }
    }

    func updateNewFilePath() {
        let template = settings.newFileTemplates[settings.newFileTemplateIndex]
        newFilePath = expand(template: template)
    }

    func expressionExamples() -> String {
        let exps = ["{year}", "{month}", "{day}", "{hour}", "{minute}", "{second}", "{weekday}", "{weekday-short}", "{current-folder}"]
        var result = ""
        for exp in exps {
            result += "\(exp): \(expand(template: exp)), "
        }
        return result
    }

    func expand(template: String) -> String {
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
        let rootPath = status.rootURL?.path ?? ""
        let folderPath = status.selectedFolder?.url.path ?? ""
        let relativeFolderPath = rootPath == folderPath ? "." : String(folderPath.dropFirst(rootPath.count + 1))
        return template
            .replacingOccurrences(of: "{year}", with: year.formatted(.number.grouping(.never).precision(.integerLength(4))))
            .replacingOccurrences(of: "{month}", with: month.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{day}", with: day.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{hour}", with: hour.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{minute}", with: minute.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{second}", with: second.formatted(.number.precision(.integerLength(2))))
            .replacingOccurrences(of: "{weekday}", with: calendar.standaloneWeekdaySymbols[weekday - 1])
            .replacingOccurrences(of: "{weekday-short}", with: calendar.shortWeekdaySymbols[weekday - 1])
            .replacingOccurrences(of: "{current-folder}", with: relativeFolderPath)
    }
}

#Preview {
//    NewFileSheet()
}
