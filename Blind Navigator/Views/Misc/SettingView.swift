//
//  SettingView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/2/25.
//

import SwiftUI

// MARK: - Data Models
struct SettingItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let iconColor: Color
    let type: SettingType
}

enum SettingType {
    case toggle(Binding<Bool>)
    case navigation(() -> AnyView)
    case action(() -> Void)
    case picker(Binding<String>, options: [String])
    case intPicker(Binding<Int>, entries: Int)
}

struct SettingsSection: Identifiable {
    let id = UUID()
    let title: String?
    let items: [SettingItem]
}

// MARK: - View Components
struct SettingsRowView: View {
    let item: SettingItem
    
    var body: some View {
        HStack(spacing: 16) {
            iconView
            titleView
            Spacer()
            accessoryView
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { handleTap() }
    }
    
    private var iconView: some View {
        Image(systemName: item.iconName)
            .font(.system(size: 18, weight: .medium))
            .frame(width: 32, height: 32)
            .background(item.iconColor.opacity(0.2))
            .foregroundColor(item.iconColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var titleView: some View {
        Text(item.title)
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.primary)
    }
    
    @ViewBuilder
    private var accessoryView: some View {
        switch item.type {
        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(.blue)
        case .navigation, .action:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.systemGray4))
        case .picker(let binding, let options):
            Picker(selection: binding, label: Label(item.title, systemImage: item.iconName)
                .foregroundColor(item.iconColor)
            ) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        case .intPicker(let binding, let entries):
            Picker(selection: binding, label: Label(item.title, systemImage: item.iconName)
                .foregroundColor(item.iconColor)
            ) {
                ForEach(1...entries, id: \.self) { i in
                    Text("\(i)").tag(i)
                }
            }
        }
    }
    
    private func handleTap() {
        switch item.type {
        // Unused but useful
        //case .navigation(let destination):
        //    break
        case .action(let action):
            action()
        default:
            break
        }
    }
}

struct SettingsSectionView: View {
    let section: SettingsSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = section.title {
                sectionHeader(title)
            }
            
            VStack(spacing: 0) {
                ForEach(section.items) { item in
                    SettingsRowView(item: item)
                    if item.id != section.items.last?.id {
                        Divider().padding(.leading, 48)
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
    }
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
            .padding(.leading, 4)
    }
}

struct SettingsView: View {
    let sections: [SettingsSection]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(sections) { section in
                        SettingsSectionView(section: section)
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var notificationsEnabled = true
    @State static var darkModeEnabled = false
    @State static var pickerOption = "Left"
    
    static var previews: some View {
        SettingsView(sections: [
            SettingsSection(title: "Account", items: [
                SettingItem(
                    title: "Session History",
                    iconName: "person",
                    iconColor: .blue,
                    type: .navigation({ AnyView(Text("Personal Info View")) })
                ),
                SettingItem(
                    title: "Picker",
                    iconName: "square.and.arrow.up",
                    iconColor: .orange,
                    type: .picker($pickerOption, options: ["Left", "Right", "Up", "Down"])
                )
            ]),
            
            SettingsSection(title: "Preferences", items: [
                SettingItem(
                    title: "Notifications",
                    iconName: "bell",
                    iconColor: .red,
                    type: .toggle($notificationsEnabled)
                ),
                SettingItem(
                    title: "Dark Mode",
                    iconName: "moon",
                    iconColor: .indigo,
                    type: .toggle($darkModeEnabled)
                )
            ]),
            
            SettingsSection(title: "Support", items: [
                SettingItem(
                    title: "Contact Support",
                    iconName: "questionmark.circle",
                    iconColor: .green,
                    type: .navigation({ AnyView(Text("Help View")) })
                ),
            ])
        ])
    }
}
