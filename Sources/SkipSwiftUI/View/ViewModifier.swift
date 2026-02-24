// Copyright 2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import SkipUI

@MainActor @preconcurrency public protocol ViewModifier {
    associatedtype Body : View

    @ViewBuilder @MainActor @preconcurrency func body(content: Self.Content) -> Self.Body

    typealias Content = JavaBackedView

    nonisolated var Java_modifier: any SkipUI.ViewModifier { get }
}

extension ViewModifier {
    nonisolated public var Java_modifier: any SkipUI.ViewModifier {
        return SkipUI.EmptyModifier()
    }
}

extension ViewModifier where Self.Body == Never {
    @MainActor @preconcurrency public func body(content: Self.Content) -> Self.Body {
        fatalError()
    }
}

extension ViewModifier {
    @inlinable nonisolated public func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        return ModifiedContent(content: self, modifier: modifier)
    }
}

extension ViewModifier {
    @available(*, unavailable)
    /* @inlinable */ nonisolated public func transaction(_ transform: @escaping (inout Transaction) -> Void) -> some ViewModifier {
        stubViewModifier()
    }

    @available(*, unavailable)
    @MainActor /* @inlinable */ @preconcurrency public func animation(_ animation: Animation?) -> some ViewModifier {
        stubViewModifier()
    }
}

func stubViewModifier() -> EmptyModifier {
    return EmptyModifier()
}

extension Never : ViewModifier {
    public typealias Content = Never
}

public struct ModifiedContent<Content, Modifier> where Content : View, Modifier : ViewModifier {
    public var content: Content
    public var modifier: Modifier

    @inlinable nonisolated public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
}

extension ModifiedContent : View {
    public typealias Body = Never
}

extension ModifiedContent : SkipUIBridging {
    public var Java_view: any SkipUI.View {
        return content.Java_viewOrEmpty.modifier(modifier.Java_modifier)
    }
}

extension View {
    @inlinable nonisolated public func modifier<T>(_ modifier: T) -> ModifiedContent<Self, T> where T : ViewModifier {
        return ModifiedContent(content: self, modifier: modifier)
    }
}
