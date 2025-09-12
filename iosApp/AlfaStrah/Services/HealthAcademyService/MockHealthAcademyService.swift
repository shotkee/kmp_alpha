//
//  MockHealthAcademyService.swift
//  AlfaStrah
//
//  Created by mac on 06.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class MockHealthAcademyService: HealthAcademyService {
    func getData(completion: @escaping (Result<[HealthAcademyCardGroup]?, AlfastrahError>) -> Void) {
        completion(.success(Constans.mockCardGroups))
    }

    // MARK: - Constants
    private enum Constans {
        static let mockCardGroups: [HealthAcademyCardGroup] = {
            func createCardGroup(
                cardAmount cardAmount: Int,
                id id: Int,
                type cardGrouptype: HealthAcademyCardGroup.Kind,
                cardGroupDepth: Int
            ) -> HealthAcademyCardGroup {
                var cards = [HealthAcademyCard]()
                for cardId in 0...(cardAmount - 1) {
                    if let imageUrl = URL(
                        string: "https://alfa-stage.entelis.team/static/academzdrav/preventive_medicine.png"
                    ) {
                        cards.append(
                            HealthAcademyCard(
                                cardId: cardId,
                                title: "Заголовок карты",
                                imageURL: imageUrl,
                                type: cardGroupDepth <= 1 ?
                                    .url(
                                        URL(string: "https://alfaacademzdrav.ru/department/physical/articles/")
                                    ) :
                                    .group(
                                        createCardGroup(cardAmount: 4, id: 3, type: .tile, cardGroupDepth: cardGroupDepth - 1)
                                    )
                            )
                        )
                    }
                }

                return .init(
                    cardGroupId: id,
                    cards: cards,
                    title: "Заголовок группы",
                    type: cardGrouptype
                )
            }

            return [
                createCardGroup(cardAmount: 4, id: 1, type: .tile, cardGroupDepth: 2),
                createCardGroup(cardAmount: 8, id: 2, type: .list, cardGroupDepth: 1)
            ]
        }()
    }
}
