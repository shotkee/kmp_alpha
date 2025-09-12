//
//  RestHealthAcademyService.swift
//  AlfaStrah
//
//  Created by mac on 08.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class RestHealthAcademyService: HealthAcademyService {
    private let rest: FullRestClient
    private var cacheCardGroup: [HealthAcademyCardGroup]

    init(rest: FullRestClient) {
        self.rest = rest
        cacheCardGroup = []
    }
    
    func getData(completion: @escaping (Result<[HealthAcademyCardGroup]?, AlfastrahError>) -> Void) {
        if !cacheCardGroup.isEmpty {
            completion(.success(cacheCardGroup))
            return
        }

        rest.read(
            path: "/api/academzdrav/",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "card_group_list",
                transformer: JsonTransformer()
            ),
            completion: mapCompletion { result in
                switch result {
                    case .success(let json):
                        completion(.success(self.parseJsonData(json)))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }

    private func parseJsonData(_ json: Legacy.Json) -> [HealthAcademyCardGroup]? {
        guard let jsonArray = json.array as? [[String: Any]] else {
            return nil
        }
        
        cacheCardGroup = jsonArray.compactMap { parseCardGroup($0) }
        return cacheCardGroup
    }
    
    private func parseCardType(_ jsonDictionary: [String: Any]) -> HealthAcademyCard.CardType? {
        if let cardType = jsonDictionary["type"] as? String {
            switch cardType {
                case "url":
                    if let cardLink = jsonDictionary["link"] as? String {
                        return HealthAcademyCard.CardType.url(URL(string: cardLink))
                    } else {
                        return nil
                    }
                case "group":
                    if let cardGroup = jsonDictionary["card_group"] as? [String: Any] {
                        return HealthAcademyCard.CardType.group(parseCardGroup(cardGroup))
                    } else {
                        return nil
                    }
                default:
                    return nil
            }
        } else {
            return nil
        }
    }
    
    private func parseCardGroup(_ jsonObject: [String: Any]) -> HealthAcademyCardGroup? {
        var cardGroup: HealthAcademyCardGroup
        var cards = [HealthAcademyCard]()
        if let cardGroupId = jsonObject["card_group_id"] as? Int,
            let title = jsonObject["title"] as? String,
            let type = jsonObject["type"] as? String,
            let jsonCardList = jsonObject["card_list"] as? [[String: Any]],
            let cardGroupType = HealthAcademyCardGroup.Kind(rawValue: type) {
            for jsonCard in jsonCardList {
                var card: HealthAcademyCard
                
                if let cardId = jsonCard["card_id"] as? Int,
                   let cardTitle = jsonCard["title"] as? String,
                   let cardImage = jsonCard["image"] as? String,
                   let imageUrl = URL(string: cardImage),
                   let type = parseCardType(jsonCard) {
					var imageThemedUrl: ThemedValue?
					if jsonCard.keys.contains("image_themed"),
					   let imageThemed = jsonCard["image_themed"] as? [String: String],
					   let imageThemedDark = imageThemed["dark"],
					   let imageThemedLight = imageThemed["light"] {
						imageThemedUrl = .init(light: imageThemedLight, dark: imageThemedDark)
					}
                        card = HealthAcademyCard(
                            cardId: cardId,
                            title: cardTitle,
                            imageURL: imageUrl,
							imageThemedURL: imageThemedUrl,
                            type: type
                        )
                } else {
                    continue
                }

                cards.append(card)
            }

            cardGroup = HealthAcademyCardGroup(
                            cardGroupId: cardGroupId,
                            cards: cards,
                            title: title,
                            type: cardGroupType
            )
        } else {
            return nil
        }

        return cardGroup
    }
}
