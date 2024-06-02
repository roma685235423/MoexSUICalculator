import Combine
import Foundation

/// Загрузчик текущих курсов валют с сайта МосБиржи
final class MoexDataLoader {
    
    private static let endpoint = URL(string: "http://iss.moex.com/iss/statistics/engines/currency/markets/selt/rates.json?iss.meta=off")!
    
    func fetch(_ endpoint: URL = endpoint) -> AnyPublisher<CurrencyRates, Error> {
        
        URLSession.shared.dataTaskPublisher(for: endpoint)
            .map { $0.data }
            .decode(type: MoexQuote.self, decoder: JSONDecoder())
            .map { $0.currencyRates }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

/// Структура, в которую декодируются данные с сайта Мосбиржи
struct MoexQuote: Decodable {
    let wap_rates: RawQuotes
}

/// Вычисляемое свойство currencyRates, которое
/// преобразует сырые данные в словарь типа CurrencyRates
extension MoexQuote {
    
    var currencyRates: CurrencyRates {

        // Инициализируем выходной словарь. Курс рубля к рублю всегда равен 1.
        var result: CurrencyRates = [.RUR: 1.0]
        
        // Находим индексы полей с названием валюты и котировкой из массива columns
        guard
            let currencyNameIndex = wap_rates.columns.map ({ $0.lowercased() }).firstIndex(of: "shortname"),
            let priceIndex = wap_rates.columns.map ({ $0.lowercased() }).firstIndex(of: "price")
        else { return result }
      
        // Перебираем массивы атрибутов для каждой валюты
        wap_rates.data.forEach { quoteArray in

            // Если название валюты и котировка есть в массиве,
            // преобразуем их к нужному типу и сохраняем.
            guard
                quoteArray.indices.contains(currencyNameIndex),
                quoteArray.indices.contains(priceIndex),
                let rate = Double(quoteArray[priceIndex]),
                let currency = Currency(rawValue: String(quoteArray[currencyNameIndex].prefix(3)).uppercased())
            else { return }

            result[currency] = rate
        }

        return result
    }
}

/// Структура, декодирующая сырые данные в массивы строк
struct RawQuotes: Decodable {
    
    // Декодируемые поля
    enum CodingKeys: String, CodingKey {
        case columns, data
    }
    
    // Названия полей атрибутов валюты
    let columns: [String]
    
    // Массивы атрибутов валют
    let data: [[String]]
    
    init(from decoder: Decoder) throws {
        
        // Декодируем атрибут columns в массив строк
        let container = try decoder.container(keyedBy: CodingKeys.self)
        columns = try container.decode([String].self, forKey: .columns)
        
        var result = [[String]]()
        var arraysContainer = try container.nestedUnkeyedContainer(forKey: .data)
        
        // Атрибут data, содержащий массивы [Any], требует обработки
        // специальной функцией для преобразования [Any] в [String]
        while !arraysContainer.isAtEnd {
            var singleArrayContainer = try arraysContainer.nestedUnkeyedContainer()
            let array = singleArrayContainer.decode(fromArray: &singleArrayContainer)
            result.append(array)
        }
        
        data = result
    }
}

/// Служебная функция, преобразующая [Any] в [String].
/// UnkeyedDecodingContainer позволяет декодировать значения массивов.
extension UnkeyedDecodingContainer {
    
    func decode(fromArray container: inout UnkeyedDecodingContainer) -> [String] {
        
        // Инициализируем выходной массив
        var result = [String]()
        
        // Перебираем значения входного массива в цикле
        while !container.isAtEnd {
            
            // Значения типа String записываем как есть
            if let value = try? container.decode(String.self) {
                result.append(value)
                
            // Значения типа Int преобразуем в строку
            } else if let value = try? container.decode(Int.self) {
                result.append("\(value)")
                
            // Значения типа Double преобразуем в строку
            } else if let value = try? container.decode(Double.self) {
                result.append("\(value)")
            }
        }
        return result
    }
}
