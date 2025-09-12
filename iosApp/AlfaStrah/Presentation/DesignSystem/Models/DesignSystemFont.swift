//
//  DesignSystemFont.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 31.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

struct DesignSystemFont {
    let title: String
    let uiFont: UIFont
    let description: String

    static let allFonts: [DesignSystemFont] = [
        .init(
            title: "Header Medium",
            uiFont: Style.Font.title1,
            description: """
                    Пока нигде не используется
                    """
        ),
        .init(
            title: "Header Small",
            uiFont: Style.Font.title1,
            description: """
                    Самый крупный заголовок на странице, используется вместе \
                    с Body на экранах полиса в меню SOS
                    """
        ),
        .init(
            title: "Subtitle Large",
            uiFont: Style.Font.headline1,
            description: """
                    Подзаголовок, служит для заголовков в ошибках, а также для\
                    разбивки карточных блоков или групп SmallValueCard, может \
                    использоваться вместе с Body.Используется в качестве value\
                    /placeholder в ValueCard и title в BottomSheet
                    """
        ),
        .init(
            title: "Subtitle Medium",
            uiFont: Style.Font.headline2,
            description: """
                    Подзаголовок, служит для разбивки карточек ValueCard. Испол\
                    ьзуется в качестве title в NavigationCard, в качестве title\
                    в Appbar (Android)
                    """
        ),
        .init(
            title: "Subtitle Small",
            uiFont: Style.Font.headline3,
            description: """
                    Используется в качестве value в ReadonlyValueCard, title в C\
                    heckbox
                    """
        ),
        .init(
            title: "Body",
            uiFont: Style.Font.text,
            description: """
                    Текстовый блок, служит для описания нескольких абзацев на экр\
                    ане или в качестве разъяснения заголовку. Используется в каче\
                    стве title, subtitle, value, placeholder в некоторых карточка\
                    х, полях ввода и сегмент контролах,а также в RichText и descr\
                    iption для Checkbox
                    """
        ),
        .init(
            title: "Description",
            uiFont: Style.Font.caption2,
            description: """
                    Используется для Title и Error message в карточках и полях ввода
                    """
        ),
        .init(
            title: "Button Medium",
            uiFont: Style.Font.headline2,
            description: """
                    Используется в больших кнопках: PrimaryButton, RoundButton, \
                    OutlinedButton, TextButton
                    """
        ),
        .init(
            title: "Button Small",
            uiFont: Style.Font.text,
            description: """
                    Используется в маленьких кнопках: PrimaryButtonSmall, Secondar\
                    yButtonSmall, OutlinedButtonSmall,TextButtonSmall, ToggleButto\
                    n, CardButton, IconButton
                    """
        )
    ]
}
