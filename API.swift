//  This file was automatically generated and should not be edited.

#if canImport(AWSAPIPlugin)
import Foundation

public protocol GraphQLInputValue {
}

public struct GraphQLVariable {
  let name: String
  
  public init(_ name: String) {
    self.name = name
  }
}

extension GraphQLVariable: GraphQLInputValue {
}

extension JSONEncodable {
  public func evaluate(with variables: [String: JSONEncodable]?) throws -> Any {
    return jsonValue
  }
}

public typealias GraphQLMap = [String: JSONEncodable?]

extension Dictionary where Key == String, Value == JSONEncodable? {
  public var withNilValuesRemoved: Dictionary<String, JSONEncodable> {
    var filtered = Dictionary<String, JSONEncodable>(minimumCapacity: count)
    for (key, value) in self {
      if value != nil {
        filtered[key] = value
      }
    }
    return filtered
  }
}

public protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

public extension GraphQLMapConvertible {
  var jsonValue: Any {
    return graphQLMap.withNilValuesRemoved.jsonValue
  }
}

public typealias GraphQLID = String

public protocol APISwiftGraphQLOperation: AnyObject {
  
  static var operationString: String { get }
  static var requestString: String { get }
  static var operationIdentifier: String? { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLSelectionSet
}

public extension APISwiftGraphQLOperation {
  static var requestString: String {
    return operationString
  }

  static var operationIdentifier: String? {
    return nil
  }

  var variables: GraphQLMap? {
    return nil
  }
}

public protocol GraphQLQuery: APISwiftGraphQLOperation {}

public protocol GraphQLMutation: APISwiftGraphQLOperation {}

public protocol GraphQLSubscription: APISwiftGraphQLOperation {}

public protocol GraphQLFragment: GraphQLSelectionSet {
  static var possibleTypes: [String] { get }
}

public typealias Snapshot = [String: Any?]

public protocol GraphQLSelectionSet: Decodable {
  static var selections: [GraphQLSelection] { get }
  
  var snapshot: Snapshot { get }
  init(snapshot: Snapshot)
}

extension GraphQLSelectionSet {
    public init(from decoder: Decoder) throws {
        if let jsonObject = try? APISwiftJSONValue(from: decoder) {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(jsonObject)
            let decodedDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
            let optionalDictionary = decodedDictionary.mapValues { $0 as Any? }

            self.init(snapshot: optionalDictionary)
        } else {
            self.init(snapshot: [:])
        }
    }
}

enum APISwiftJSONValue: Codable {
    case array([APISwiftJSONValue])
    case boolean(Bool)
    case number(Double)
    case object([String: APISwiftJSONValue])
    case string(String)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode([String: APISwiftJSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([APISwiftJSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            self = .null
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .array(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

public protocol GraphQLSelection {
}

public struct GraphQLField: GraphQLSelection {
  let name: String
  let alias: String?
  let arguments: [String: GraphQLInputValue]?
  
  var responseKey: String {
    return alias ?? name
  }
  
  let type: GraphQLOutputType
  
  public init(_ name: String, alias: String? = nil, arguments: [String: GraphQLInputValue]? = nil, type: GraphQLOutputType) {
    self.name = name
    self.alias = alias
    
    self.arguments = arguments
    
    self.type = type
  }
}

public indirect enum GraphQLOutputType {
  case scalar(JSONDecodable.Type)
  case object([GraphQLSelection])
  case nonNull(GraphQLOutputType)
  case list(GraphQLOutputType)
  
  var namedType: GraphQLOutputType {
    switch self {
    case .nonNull(let innerType), .list(let innerType):
      return innerType.namedType
    case .scalar, .object:
      return self
    }
  }
}

public struct GraphQLBooleanCondition: GraphQLSelection {
  let variableName: String
  let inverted: Bool
  let selections: [GraphQLSelection]
  
  public init(variableName: String, inverted: Bool, selections: [GraphQLSelection]) {
    self.variableName = variableName
    self.inverted = inverted;
    self.selections = selections;
  }
}

public struct GraphQLTypeCondition: GraphQLSelection {
  let possibleTypes: [String]
  let selections: [GraphQLSelection]
  
  public init(possibleTypes: [String], selections: [GraphQLSelection]) {
    self.possibleTypes = possibleTypes
    self.selections = selections;
  }
}

public struct GraphQLFragmentSpread: GraphQLSelection {
  let fragment: GraphQLFragment.Type
  
  public init(_ fragment: GraphQLFragment.Type) {
    self.fragment = fragment
  }
}

public struct GraphQLTypeCase: GraphQLSelection {
  let variants: [String: [GraphQLSelection]]
  let `default`: [GraphQLSelection]
  
  public init(variants: [String: [GraphQLSelection]], default: [GraphQLSelection]) {
    self.variants = variants
    self.default = `default`;
  }
}

public typealias JSONObject = [String: Any]

public protocol JSONDecodable {
  init(jsonValue value: Any) throws
}

public protocol JSONEncodable: GraphQLInputValue {
  var jsonValue: Any { get }
}

public enum JSONDecodingError: Error, LocalizedError {
  case missingValue
  case nullValue
  case wrongType
  case couldNotConvert(value: Any, to: Any.Type)
  
  public var errorDescription: String? {
    switch self {
    case .missingValue:
      return "Missing value"
    case .nullValue:
      return "Unexpected null value"
    case .wrongType:
      return "Wrong type"
    case .couldNotConvert(let value, let expectedType):
      return "Could not convert \"\(value)\" to \(expectedType)"
    }
  }
}

extension String: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
    }
    self = string
  }

  public var jsonValue: Any {
    return self
  }
}

extension Int: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Int.self)
    }
    self = number.intValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Float: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Float.self)
    }
    self = number.floatValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Double: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Double.self)
    }
    self = number.doubleValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Bool: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let bool = value as? Bool else {
        throw JSONDecodingError.couldNotConvert(value: value, to: Bool.self)
    }
    self = bool
  }

  public var jsonValue: Any {
    return self
  }
}

extension RawRepresentable where RawValue: JSONDecodable {
  public init(jsonValue value: Any) throws {
    let rawValue = try RawValue(jsonValue: value)
    if let tempSelf = Self(rawValue: rawValue) {
      self = tempSelf
    } else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Self.self)
    }
  }
}

extension RawRepresentable where RawValue: JSONEncodable {
  public var jsonValue: Any {
    return rawValue.jsonValue
  }
}

extension Optional where Wrapped: JSONDecodable {
  public init(jsonValue value: Any) throws {
    if value is NSNull {
      self = .none
    } else {
      self = .some(try Wrapped(jsonValue: value))
    }
  }
}

extension Optional: JSONEncodable {
  public var jsonValue: Any {
    switch self {
    case .none:
      return NSNull()
    case .some(let wrapped as JSONEncodable):
      return wrapped.jsonValue
    default:
      fatalError("Optional is only JSONEncodable if Wrapped is")
    }
  }
}

extension Dictionary: JSONEncodable {
  public var jsonValue: Any {
    return jsonObject
  }
  
  public var jsonObject: JSONObject {
    var jsonObject = JSONObject(minimumCapacity: count)
    for (key, value) in self {
      if case let (key as String, value as JSONEncodable) = (key, value) {
        jsonObject[key] = value.jsonValue
      } else {
        fatalError("Dictionary is only JSONEncodable if Value is (and if Key is String)")
      }
    }
    return jsonObject
  }
}

extension Array: JSONEncodable {
  public var jsonValue: Any {
    return map() { element -> (Any) in
      if case let element as JSONEncodable = element {
        return element.jsonValue
      } else {
        fatalError("Array is only JSONEncodable if Element is")
      }
    }
  }
}

extension URL: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
    self.init(string: string)!
  }

  public var jsonValue: Any {
    return self.absoluteString
  }
}

extension Dictionary {
  static func += (lhs: inout Dictionary, rhs: Dictionary) {
    lhs.merge(rhs) { (_, new) in new }
  }
}

#elseif canImport(AWSAppSync)
import AWSAppSync
#endif

public struct CreateWorkoutSessionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, userId: GraphQLID, startTime: String, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil) {
    graphQLMap = ["id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var userId: GraphQLID {
    get {
      return graphQLMap["userId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userId")
    }
  }

  public var startTime: String {
    get {
      return graphQLMap["startTime"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "startTime")
    }
  }

  public var endTime: String? {
    get {
      return graphQLMap["endTime"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "endTime")
    }
  }

  public var distance: Double? {
    get {
      return graphQLMap["distance"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "distance")
    }
  }

  public var duration: Int? {
    get {
      return graphQLMap["duration"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }
}

public struct ModelWorkoutSessionConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(userId: ModelIDInput? = nil, startTime: ModelStringInput? = nil, endTime: ModelStringInput? = nil, distance: ModelFloatInput? = nil, duration: ModelIntInput? = nil, and: [ModelWorkoutSessionConditionInput?]? = nil, or: [ModelWorkoutSessionConditionInput?]? = nil, not: ModelWorkoutSessionConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var userId: ModelIDInput? {
    get {
      return graphQLMap["userId"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userId")
    }
  }

  public var startTime: ModelStringInput? {
    get {
      return graphQLMap["startTime"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "startTime")
    }
  }

  public var endTime: ModelStringInput? {
    get {
      return graphQLMap["endTime"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "endTime")
    }
  }

  public var distance: ModelFloatInput? {
    get {
      return graphQLMap["distance"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "distance")
    }
  }

  public var duration: ModelIntInput? {
    get {
      return graphQLMap["duration"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }

  public var and: [ModelWorkoutSessionConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelWorkoutSessionConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelWorkoutSessionConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelWorkoutSessionConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelWorkoutSessionConditionInput? {
    get {
      return graphQLMap["not"] as! ModelWorkoutSessionConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct ModelIDInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil, size: ModelSizeInput? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "attributeExists": attributeExists, "attributeType": attributeType, "size": size]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }

  public var size: ModelSizeInput? {
    get {
      return graphQLMap["size"] as! ModelSizeInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

public enum ModelAttributeTypes: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case binary
  case binarySet
  case bool
  case list
  case map
  case number
  case numberSet
  case string
  case stringSet
  case null
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "binary": self = .binary
      case "binarySet": self = .binarySet
      case "bool": self = .bool
      case "list": self = .list
      case "map": self = .map
      case "number": self = .number
      case "numberSet": self = .numberSet
      case "string": self = .string
      case "stringSet": self = .stringSet
      case "_null": self = .null
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .binary: return "binary"
      case .binarySet: return "binarySet"
      case .bool: return "bool"
      case .list: return "list"
      case .map: return "map"
      case .number: return "number"
      case .numberSet: return "numberSet"
      case .string: return "string"
      case .stringSet: return "stringSet"
      case .null: return "_null"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: ModelAttributeTypes, rhs: ModelAttributeTypes) -> Bool {
    switch (lhs, rhs) {
      case (.binary, .binary): return true
      case (.binarySet, .binarySet): return true
      case (.bool, .bool): return true
      case (.list, .list): return true
      case (.map, .map): return true
      case (.number, .number): return true
      case (.numberSet, .numberSet): return true
      case (.string, .string): return true
      case (.stringSet, .stringSet): return true
      case (.null, .null): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ModelSizeInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }
}

public struct ModelStringInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil, size: ModelSizeInput? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "attributeExists": attributeExists, "attributeType": attributeType, "size": size]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }

  public var size: ModelSizeInput? {
    get {
      return graphQLMap["size"] as! ModelSizeInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

public struct ModelFloatInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Double? = nil, eq: Double? = nil, le: Double? = nil, lt: Double? = nil, ge: Double? = nil, gt: Double? = nil, between: [Double?]? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "attributeExists": attributeExists, "attributeType": attributeType]
  }

  public var ne: Double? {
    get {
      return graphQLMap["ne"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Double? {
    get {
      return graphQLMap["eq"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Double? {
    get {
      return graphQLMap["le"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Double? {
    get {
      return graphQLMap["lt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Double? {
    get {
      return graphQLMap["ge"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Double? {
    get {
      return graphQLMap["gt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Double?]? {
    get {
      return graphQLMap["between"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }
}

public struct ModelIntInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "attributeExists": attributeExists, "attributeType": attributeType]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }
}

public struct UpdateWorkoutSessionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, userId: GraphQLID? = nil, startTime: String? = nil, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil) {
    graphQLMap = ["id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var userId: GraphQLID? {
    get {
      return graphQLMap["userId"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userId")
    }
  }

  public var startTime: String? {
    get {
      return graphQLMap["startTime"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "startTime")
    }
  }

  public var endTime: String? {
    get {
      return graphQLMap["endTime"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "endTime")
    }
  }

  public var distance: Double? {
    get {
      return graphQLMap["distance"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "distance")
    }
  }

  public var duration: Int? {
    get {
      return graphQLMap["duration"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }
}

public struct DeleteWorkoutSessionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateLocationDataInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, workoutSessionLocationsId: GraphQLID? = nil) {
    graphQLMap = ["id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "workoutSessionLocationsId": workoutSessionLocationsId]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var sessionId: GraphQLID {
    get {
      return graphQLMap["sessionId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sessionId")
    }
  }

  public var latitude: Double {
    get {
      return graphQLMap["latitude"] as! Double
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "latitude")
    }
  }

  public var longitude: Double {
    get {
      return graphQLMap["longitude"] as! Double
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "longitude")
    }
  }

  public var altitude: Double? {
    get {
      return graphQLMap["altitude"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "altitude")
    }
  }

  public var timestamp: String {
    get {
      return graphQLMap["timestamp"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var workoutSessionLocationsId: GraphQLID? {
    get {
      return graphQLMap["workoutSessionLocationsId"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "workoutSessionLocationsId")
    }
  }
}

public struct ModelLocationDataConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(sessionId: ModelIDInput? = nil, latitude: ModelFloatInput? = nil, longitude: ModelFloatInput? = nil, altitude: ModelFloatInput? = nil, timestamp: ModelStringInput? = nil, and: [ModelLocationDataConditionInput?]? = nil, or: [ModelLocationDataConditionInput?]? = nil, not: ModelLocationDataConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, workoutSessionLocationsId: ModelIDInput? = nil) {
    graphQLMap = ["sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId]
  }

  public var sessionId: ModelIDInput? {
    get {
      return graphQLMap["sessionId"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sessionId")
    }
  }

  public var latitude: ModelFloatInput? {
    get {
      return graphQLMap["latitude"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "latitude")
    }
  }

  public var longitude: ModelFloatInput? {
    get {
      return graphQLMap["longitude"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "longitude")
    }
  }

  public var altitude: ModelFloatInput? {
    get {
      return graphQLMap["altitude"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "altitude")
    }
  }

  public var timestamp: ModelStringInput? {
    get {
      return graphQLMap["timestamp"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var and: [ModelLocationDataConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelLocationDataConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelLocationDataConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelLocationDataConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelLocationDataConditionInput? {
    get {
      return graphQLMap["not"] as! ModelLocationDataConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var workoutSessionLocationsId: ModelIDInput? {
    get {
      return graphQLMap["workoutSessionLocationsId"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "workoutSessionLocationsId")
    }
  }
}

public struct UpdateLocationDataInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, sessionId: GraphQLID? = nil, latitude: Double? = nil, longitude: Double? = nil, altitude: Double? = nil, timestamp: String? = nil, workoutSessionLocationsId: GraphQLID? = nil) {
    graphQLMap = ["id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "workoutSessionLocationsId": workoutSessionLocationsId]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var sessionId: GraphQLID? {
    get {
      return graphQLMap["sessionId"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sessionId")
    }
  }

  public var latitude: Double? {
    get {
      return graphQLMap["latitude"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "latitude")
    }
  }

  public var longitude: Double? {
    get {
      return graphQLMap["longitude"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "longitude")
    }
  }

  public var altitude: Double? {
    get {
      return graphQLMap["altitude"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "altitude")
    }
  }

  public var timestamp: String? {
    get {
      return graphQLMap["timestamp"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var workoutSessionLocationsId: GraphQLID? {
    get {
      return graphQLMap["workoutSessionLocationsId"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "workoutSessionLocationsId")
    }
  }
}

public struct DeleteLocationDataInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct ModelWorkoutSessionFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, userId: ModelIDInput? = nil, startTime: ModelStringInput? = nil, endTime: ModelStringInput? = nil, distance: ModelFloatInput? = nil, duration: ModelIntInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelWorkoutSessionFilterInput?]? = nil, or: [ModelWorkoutSessionFilterInput?]? = nil, not: ModelWorkoutSessionFilterInput? = nil) {
    graphQLMap = ["id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var userId: ModelIDInput? {
    get {
      return graphQLMap["userId"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userId")
    }
  }

  public var startTime: ModelStringInput? {
    get {
      return graphQLMap["startTime"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "startTime")
    }
  }

  public var endTime: ModelStringInput? {
    get {
      return graphQLMap["endTime"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "endTime")
    }
  }

  public var distance: ModelFloatInput? {
    get {
      return graphQLMap["distance"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "distance")
    }
  }

  public var duration: ModelIntInput? {
    get {
      return graphQLMap["duration"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelWorkoutSessionFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelWorkoutSessionFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelWorkoutSessionFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelWorkoutSessionFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelWorkoutSessionFilterInput? {
    get {
      return graphQLMap["not"] as! ModelWorkoutSessionFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelLocationDataFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, sessionId: ModelIDInput? = nil, latitude: ModelFloatInput? = nil, longitude: ModelFloatInput? = nil, altitude: ModelFloatInput? = nil, timestamp: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelLocationDataFilterInput?]? = nil, or: [ModelLocationDataFilterInput?]? = nil, not: ModelLocationDataFilterInput? = nil, workoutSessionLocationsId: ModelIDInput? = nil) {
    graphQLMap = ["id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not, "workoutSessionLocationsId": workoutSessionLocationsId]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var sessionId: ModelIDInput? {
    get {
      return graphQLMap["sessionId"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sessionId")
    }
  }

  public var latitude: ModelFloatInput? {
    get {
      return graphQLMap["latitude"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "latitude")
    }
  }

  public var longitude: ModelFloatInput? {
    get {
      return graphQLMap["longitude"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "longitude")
    }
  }

  public var altitude: ModelFloatInput? {
    get {
      return graphQLMap["altitude"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "altitude")
    }
  }

  public var timestamp: ModelStringInput? {
    get {
      return graphQLMap["timestamp"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelLocationDataFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelLocationDataFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelLocationDataFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelLocationDataFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelLocationDataFilterInput? {
    get {
      return graphQLMap["not"] as! ModelLocationDataFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var workoutSessionLocationsId: ModelIDInput? {
    get {
      return graphQLMap["workoutSessionLocationsId"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "workoutSessionLocationsId")
    }
  }
}

public enum ModelSortDirection: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case asc
  case desc
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ASC": self = .asc
      case "DESC": self = .desc
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .asc: return "ASC"
      case .desc: return "DESC"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: ModelSortDirection, rhs: ModelSortDirection) -> Bool {
    switch (lhs, rhs) {
      case (.asc, .asc): return true
      case (.desc, .desc): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ModelSubscriptionWorkoutSessionFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, userId: ModelSubscriptionIDInput? = nil, startTime: ModelSubscriptionStringInput? = nil, endTime: ModelSubscriptionStringInput? = nil, distance: ModelSubscriptionFloatInput? = nil, duration: ModelSubscriptionIntInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionWorkoutSessionFilterInput?]? = nil, or: [ModelSubscriptionWorkoutSessionFilterInput?]? = nil, workoutSessionLocationsId: ModelSubscriptionIDInput? = nil) {
    graphQLMap = ["id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "workoutSessionLocationsId": workoutSessionLocationsId]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var userId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["userId"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userId")
    }
  }

  public var startTime: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["startTime"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "startTime")
    }
  }

  public var endTime: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["endTime"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "endTime")
    }
  }

  public var distance: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["distance"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "distance")
    }
  }

  public var duration: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["duration"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionWorkoutSessionFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionWorkoutSessionFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionWorkoutSessionFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionWorkoutSessionFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var workoutSessionLocationsId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["workoutSessionLocationsId"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "workoutSessionLocationsId")
    }
  }
}

public struct ModelSubscriptionIDInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "in": `in`, "notIn": notIn]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var `in`: [GraphQLID?]? {
    get {
      return graphQLMap["in"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [GraphQLID?]? {
    get {
      return graphQLMap["notIn"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionStringInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "in": `in`, "notIn": notIn]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var `in`: [String?]? {
    get {
      return graphQLMap["in"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [String?]? {
    get {
      return graphQLMap["notIn"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionFloatInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Double? = nil, eq: Double? = nil, le: Double? = nil, lt: Double? = nil, ge: Double? = nil, gt: Double? = nil, between: [Double?]? = nil, `in`: [Double?]? = nil, notIn: [Double?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "in": `in`, "notIn": notIn]
  }

  public var ne: Double? {
    get {
      return graphQLMap["ne"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Double? {
    get {
      return graphQLMap["eq"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Double? {
    get {
      return graphQLMap["le"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Double? {
    get {
      return graphQLMap["lt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Double? {
    get {
      return graphQLMap["ge"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Double? {
    get {
      return graphQLMap["gt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Double?]? {
    get {
      return graphQLMap["between"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var `in`: [Double?]? {
    get {
      return graphQLMap["in"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [Double?]? {
    get {
      return graphQLMap["notIn"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionIntInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil, `in`: [Int?]? = nil, notIn: [Int?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "in": `in`, "notIn": notIn]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var `in`: [Int?]? {
    get {
      return graphQLMap["in"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [Int?]? {
    get {
      return graphQLMap["notIn"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionLocationDataFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, sessionId: ModelSubscriptionIDInput? = nil, latitude: ModelSubscriptionFloatInput? = nil, longitude: ModelSubscriptionFloatInput? = nil, altitude: ModelSubscriptionFloatInput? = nil, timestamp: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionLocationDataFilterInput?]? = nil, or: [ModelSubscriptionLocationDataFilterInput?]? = nil) {
    graphQLMap = ["id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var sessionId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["sessionId"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sessionId")
    }
  }

  public var latitude: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["latitude"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "latitude")
    }
  }

  public var longitude: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["longitude"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "longitude")
    }
  }

  public var altitude: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["altitude"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "altitude")
    }
  }

  public var timestamp: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["timestamp"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionLocationDataFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionLocationDataFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionLocationDataFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionLocationDataFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }
}

public final class CreateWorkoutSessionMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateWorkoutSession($input: CreateWorkoutSessionInput!, $condition: ModelWorkoutSessionConditionInput) {\n  createWorkoutSession(input: $input, condition: $condition) {\n    __typename\n    id\n    userId\n    startTime\n    endTime\n    distance\n    duration\n    locations {\n      __typename\n      nextToken\n    }\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateWorkoutSessionInput
  public var condition: ModelWorkoutSessionConditionInput?

  public init(input: CreateWorkoutSessionInput, condition: ModelWorkoutSessionConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createWorkoutSession", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateWorkoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createWorkoutSession: CreateWorkoutSession? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createWorkoutSession": createWorkoutSession.flatMap { $0.snapshot }])
    }

    public var createWorkoutSession: CreateWorkoutSession? {
      get {
        return (snapshot["createWorkoutSession"] as? Snapshot).flatMap { CreateWorkoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createWorkoutSession")
      }
    }

    public struct CreateWorkoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["WorkoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
        GraphQLField("endTime", type: .scalar(String.self)),
        GraphQLField("distance", type: .scalar(Double.self)),
        GraphQLField("duration", type: .scalar(Int.self)),
        GraphQLField("locations", type: .object(Location.selections)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, userId: GraphQLID, startTime: String, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil, locations: Location? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "WorkoutSession", "id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "locations": locations.flatMap { $0.snapshot }, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userId")
        }
      }

      public var startTime: String {
        get {
          return snapshot["startTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startTime")
        }
      }

      public var endTime: String? {
        get {
          return snapshot["endTime"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endTime")
        }
      }

      public var distance: Double? {
        get {
          return snapshot["distance"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "distance")
        }
      }

      public var duration: Int? {
        get {
          return snapshot["duration"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var locations: Location? {
        get {
          return (snapshot["locations"] as? Snapshot).flatMap { Location(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "locations")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLocationDataConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLocationDataConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class UpdateWorkoutSessionMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateWorkoutSession($input: UpdateWorkoutSessionInput!, $condition: ModelWorkoutSessionConditionInput) {\n  updateWorkoutSession(input: $input, condition: $condition) {\n    __typename\n    id\n    userId\n    startTime\n    endTime\n    distance\n    duration\n    locations {\n      __typename\n      nextToken\n    }\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateWorkoutSessionInput
  public var condition: ModelWorkoutSessionConditionInput?

  public init(input: UpdateWorkoutSessionInput, condition: ModelWorkoutSessionConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateWorkoutSession", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateWorkoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateWorkoutSession: UpdateWorkoutSession? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateWorkoutSession": updateWorkoutSession.flatMap { $0.snapshot }])
    }

    public var updateWorkoutSession: UpdateWorkoutSession? {
      get {
        return (snapshot["updateWorkoutSession"] as? Snapshot).flatMap { UpdateWorkoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateWorkoutSession")
      }
    }

    public struct UpdateWorkoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["WorkoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
        GraphQLField("endTime", type: .scalar(String.self)),
        GraphQLField("distance", type: .scalar(Double.self)),
        GraphQLField("duration", type: .scalar(Int.self)),
        GraphQLField("locations", type: .object(Location.selections)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, userId: GraphQLID, startTime: String, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil, locations: Location? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "WorkoutSession", "id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "locations": locations.flatMap { $0.snapshot }, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userId")
        }
      }

      public var startTime: String {
        get {
          return snapshot["startTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startTime")
        }
      }

      public var endTime: String? {
        get {
          return snapshot["endTime"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endTime")
        }
      }

      public var distance: Double? {
        get {
          return snapshot["distance"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "distance")
        }
      }

      public var duration: Int? {
        get {
          return snapshot["duration"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var locations: Location? {
        get {
          return (snapshot["locations"] as? Snapshot).flatMap { Location(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "locations")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLocationDataConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLocationDataConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class DeleteWorkoutSessionMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteWorkoutSession($input: DeleteWorkoutSessionInput!, $condition: ModelWorkoutSessionConditionInput) {\n  deleteWorkoutSession(input: $input, condition: $condition) {\n    __typename\n    id\n    userId\n    startTime\n    endTime\n    distance\n    duration\n    locations {\n      __typename\n      nextToken\n    }\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteWorkoutSessionInput
  public var condition: ModelWorkoutSessionConditionInput?

  public init(input: DeleteWorkoutSessionInput, condition: ModelWorkoutSessionConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteWorkoutSession", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteWorkoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteWorkoutSession: DeleteWorkoutSession? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteWorkoutSession": deleteWorkoutSession.flatMap { $0.snapshot }])
    }

    public var deleteWorkoutSession: DeleteWorkoutSession? {
      get {
        return (snapshot["deleteWorkoutSession"] as? Snapshot).flatMap { DeleteWorkoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteWorkoutSession")
      }
    }

    public struct DeleteWorkoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["WorkoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
        GraphQLField("endTime", type: .scalar(String.self)),
        GraphQLField("distance", type: .scalar(Double.self)),
        GraphQLField("duration", type: .scalar(Int.self)),
        GraphQLField("locations", type: .object(Location.selections)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, userId: GraphQLID, startTime: String, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil, locations: Location? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "WorkoutSession", "id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "locations": locations.flatMap { $0.snapshot }, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userId")
        }
      }

      public var startTime: String {
        get {
          return snapshot["startTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startTime")
        }
      }

      public var endTime: String? {
        get {
          return snapshot["endTime"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endTime")
        }
      }

      public var distance: Double? {
        get {
          return snapshot["distance"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "distance")
        }
      }

      public var duration: Int? {
        get {
          return snapshot["duration"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var locations: Location? {
        get {
          return (snapshot["locations"] as? Snapshot).flatMap { Location(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "locations")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLocationDataConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLocationDataConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class CreateLocationDataMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateLocationData($input: CreateLocationDataInput!, $condition: ModelLocationDataConditionInput) {\n  createLocationData(input: $input, condition: $condition) {\n    __typename\n    id\n    sessionId\n    latitude\n    longitude\n    altitude\n    timestamp\n    createdAt\n    updatedAt\n    workoutSessionLocationsId\n  }\n}"

  public var input: CreateLocationDataInput
  public var condition: ModelLocationDataConditionInput?

  public init(input: CreateLocationDataInput, condition: ModelLocationDataConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createLocationData", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateLocationDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createLocationData: CreateLocationDatum? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createLocationData": createLocationData.flatMap { $0.snapshot }])
    }

    public var createLocationData: CreateLocationDatum? {
      get {
        return (snapshot["createLocationData"] as? Snapshot).flatMap { CreateLocationDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createLocationData")
      }
    }

    public struct CreateLocationDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["LocationData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sessionId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("workoutSessionLocationsId", type: .scalar(GraphQLID.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, createdAt: String, updatedAt: String, workoutSessionLocationsId: GraphQLID? = nil) {
        self.init(snapshot: ["__typename": "LocationData", "id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var sessionId: GraphQLID {
        get {
          return snapshot["sessionId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "sessionId")
        }
      }

      public var latitude: Double {
        get {
          return snapshot["latitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "latitude")
        }
      }

      public var longitude: Double {
        get {
          return snapshot["longitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "longitude")
        }
      }

      public var altitude: Double? {
        get {
          return snapshot["altitude"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "altitude")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var workoutSessionLocationsId: GraphQLID? {
        get {
          return snapshot["workoutSessionLocationsId"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "workoutSessionLocationsId")
        }
      }
    }
  }
}

public final class UpdateLocationDataMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateLocationData($input: UpdateLocationDataInput!, $condition: ModelLocationDataConditionInput) {\n  updateLocationData(input: $input, condition: $condition) {\n    __typename\n    id\n    sessionId\n    latitude\n    longitude\n    altitude\n    timestamp\n    createdAt\n    updatedAt\n    workoutSessionLocationsId\n  }\n}"

  public var input: UpdateLocationDataInput
  public var condition: ModelLocationDataConditionInput?

  public init(input: UpdateLocationDataInput, condition: ModelLocationDataConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateLocationData", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateLocationDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateLocationData: UpdateLocationDatum? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateLocationData": updateLocationData.flatMap { $0.snapshot }])
    }

    public var updateLocationData: UpdateLocationDatum? {
      get {
        return (snapshot["updateLocationData"] as? Snapshot).flatMap { UpdateLocationDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateLocationData")
      }
    }

    public struct UpdateLocationDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["LocationData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sessionId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("workoutSessionLocationsId", type: .scalar(GraphQLID.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, createdAt: String, updatedAt: String, workoutSessionLocationsId: GraphQLID? = nil) {
        self.init(snapshot: ["__typename": "LocationData", "id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var sessionId: GraphQLID {
        get {
          return snapshot["sessionId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "sessionId")
        }
      }

      public var latitude: Double {
        get {
          return snapshot["latitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "latitude")
        }
      }

      public var longitude: Double {
        get {
          return snapshot["longitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "longitude")
        }
      }

      public var altitude: Double? {
        get {
          return snapshot["altitude"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "altitude")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var workoutSessionLocationsId: GraphQLID? {
        get {
          return snapshot["workoutSessionLocationsId"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "workoutSessionLocationsId")
        }
      }
    }
  }
}

public final class DeleteLocationDataMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteLocationData($input: DeleteLocationDataInput!, $condition: ModelLocationDataConditionInput) {\n  deleteLocationData(input: $input, condition: $condition) {\n    __typename\n    id\n    sessionId\n    latitude\n    longitude\n    altitude\n    timestamp\n    createdAt\n    updatedAt\n    workoutSessionLocationsId\n  }\n}"

  public var input: DeleteLocationDataInput
  public var condition: ModelLocationDataConditionInput?

  public init(input: DeleteLocationDataInput, condition: ModelLocationDataConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteLocationData", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteLocationDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteLocationData: DeleteLocationDatum? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteLocationData": deleteLocationData.flatMap { $0.snapshot }])
    }

    public var deleteLocationData: DeleteLocationDatum? {
      get {
        return (snapshot["deleteLocationData"] as? Snapshot).flatMap { DeleteLocationDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteLocationData")
      }
    }

    public struct DeleteLocationDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["LocationData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sessionId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("workoutSessionLocationsId", type: .scalar(GraphQLID.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, createdAt: String, updatedAt: String, workoutSessionLocationsId: GraphQLID? = nil) {
        self.init(snapshot: ["__typename": "LocationData", "id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var sessionId: GraphQLID {
        get {
          return snapshot["sessionId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "sessionId")
        }
      }

      public var latitude: Double {
        get {
          return snapshot["latitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "latitude")
        }
      }

      public var longitude: Double {
        get {
          return snapshot["longitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "longitude")
        }
      }

      public var altitude: Double? {
        get {
          return snapshot["altitude"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "altitude")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var workoutSessionLocationsId: GraphQLID? {
        get {
          return snapshot["workoutSessionLocationsId"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "workoutSessionLocationsId")
        }
      }
    }
  }
}

public final class GetWorkoutSessionQuery: GraphQLQuery {
  public static let operationString =
    "query GetWorkoutSession($id: ID!) {\n  getWorkoutSession(id: $id) {\n    __typename\n    id\n    userId\n    startTime\n    endTime\n    distance\n    duration\n    locations {\n      __typename\n      nextToken\n    }\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getWorkoutSession", arguments: ["id": GraphQLVariable("id")], type: .object(GetWorkoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getWorkoutSession: GetWorkoutSession? = nil) {
      self.init(snapshot: ["__typename": "Query", "getWorkoutSession": getWorkoutSession.flatMap { $0.snapshot }])
    }

    public var getWorkoutSession: GetWorkoutSession? {
      get {
        return (snapshot["getWorkoutSession"] as? Snapshot).flatMap { GetWorkoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getWorkoutSession")
      }
    }

    public struct GetWorkoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["WorkoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
        GraphQLField("endTime", type: .scalar(String.self)),
        GraphQLField("distance", type: .scalar(Double.self)),
        GraphQLField("duration", type: .scalar(Int.self)),
        GraphQLField("locations", type: .object(Location.selections)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, userId: GraphQLID, startTime: String, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil, locations: Location? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "WorkoutSession", "id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "locations": locations.flatMap { $0.snapshot }, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userId")
        }
      }

      public var startTime: String {
        get {
          return snapshot["startTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startTime")
        }
      }

      public var endTime: String? {
        get {
          return snapshot["endTime"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endTime")
        }
      }

      public var distance: Double? {
        get {
          return snapshot["distance"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "distance")
        }
      }

      public var duration: Int? {
        get {
          return snapshot["duration"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var locations: Location? {
        get {
          return (snapshot["locations"] as? Snapshot).flatMap { Location(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "locations")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLocationDataConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLocationDataConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class ListWorkoutSessionsQuery: GraphQLQuery {
  public static let operationString =
    "query ListWorkoutSessions($filter: ModelWorkoutSessionFilterInput, $limit: Int, $nextToken: String) {\n  listWorkoutSessions(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      userId\n      startTime\n      endTime\n      distance\n      duration\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelWorkoutSessionFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelWorkoutSessionFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listWorkoutSessions", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListWorkoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listWorkoutSessions: ListWorkoutSession? = nil) {
      self.init(snapshot: ["__typename": "Query", "listWorkoutSessions": listWorkoutSessions.flatMap { $0.snapshot }])
    }

    public var listWorkoutSessions: ListWorkoutSession? {
      get {
        return (snapshot["listWorkoutSessions"] as? Snapshot).flatMap { ListWorkoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listWorkoutSessions")
      }
    }

    public struct ListWorkoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelWorkoutSessionConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelWorkoutSessionConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["WorkoutSession"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("userId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
          GraphQLField("endTime", type: .scalar(String.self)),
          GraphQLField("distance", type: .scalar(Double.self)),
          GraphQLField("duration", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, userId: GraphQLID, startTime: String, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "WorkoutSession", "id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var userId: GraphQLID {
          get {
            return snapshot["userId"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userId")
          }
        }

        public var startTime: String {
          get {
            return snapshot["startTime"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "startTime")
          }
        }

        public var endTime: String? {
          get {
            return snapshot["endTime"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "endTime")
          }
        }

        public var distance: Double? {
          get {
            return snapshot["distance"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "distance")
          }
        }

        public var duration: Int? {
          get {
            return snapshot["duration"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "duration")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetLocationDataQuery: GraphQLQuery {
  public static let operationString =
    "query GetLocationData($id: ID!) {\n  getLocationData(id: $id) {\n    __typename\n    id\n    sessionId\n    latitude\n    longitude\n    altitude\n    timestamp\n    createdAt\n    updatedAt\n    workoutSessionLocationsId\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getLocationData", arguments: ["id": GraphQLVariable("id")], type: .object(GetLocationDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getLocationData: GetLocationDatum? = nil) {
      self.init(snapshot: ["__typename": "Query", "getLocationData": getLocationData.flatMap { $0.snapshot }])
    }

    public var getLocationData: GetLocationDatum? {
      get {
        return (snapshot["getLocationData"] as? Snapshot).flatMap { GetLocationDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getLocationData")
      }
    }

    public struct GetLocationDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["LocationData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sessionId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("workoutSessionLocationsId", type: .scalar(GraphQLID.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, createdAt: String, updatedAt: String, workoutSessionLocationsId: GraphQLID? = nil) {
        self.init(snapshot: ["__typename": "LocationData", "id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var sessionId: GraphQLID {
        get {
          return snapshot["sessionId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "sessionId")
        }
      }

      public var latitude: Double {
        get {
          return snapshot["latitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "latitude")
        }
      }

      public var longitude: Double {
        get {
          return snapshot["longitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "longitude")
        }
      }

      public var altitude: Double? {
        get {
          return snapshot["altitude"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "altitude")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var workoutSessionLocationsId: GraphQLID? {
        get {
          return snapshot["workoutSessionLocationsId"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "workoutSessionLocationsId")
        }
      }
    }
  }
}

public final class ListLocationDataQuery: GraphQLQuery {
  public static let operationString =
    "query ListLocationData($filter: ModelLocationDataFilterInput, $limit: Int, $nextToken: String) {\n  listLocationData(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      sessionId\n      latitude\n      longitude\n      altitude\n      timestamp\n      createdAt\n      updatedAt\n      workoutSessionLocationsId\n    }\n    nextToken\n  }\n}"

  public var filter: ModelLocationDataFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelLocationDataFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listLocationData", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListLocationDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listLocationData: ListLocationDatum? = nil) {
      self.init(snapshot: ["__typename": "Query", "listLocationData": listLocationData.flatMap { $0.snapshot }])
    }

    public var listLocationData: ListLocationDatum? {
      get {
        return (snapshot["listLocationData"] as? Snapshot).flatMap { ListLocationDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listLocationData")
      }
    }

    public struct ListLocationDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelLocationDataConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelLocationDataConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["LocationData"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("sessionId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
          GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
          GraphQLField("altitude", type: .scalar(Double.self)),
          GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("workoutSessionLocationsId", type: .scalar(GraphQLID.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, createdAt: String, updatedAt: String, workoutSessionLocationsId: GraphQLID? = nil) {
          self.init(snapshot: ["__typename": "LocationData", "id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var sessionId: GraphQLID {
          get {
            return snapshot["sessionId"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "sessionId")
          }
        }

        public var latitude: Double {
          get {
            return snapshot["latitude"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "latitude")
          }
        }

        public var longitude: Double {
          get {
            return snapshot["longitude"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "longitude")
          }
        }

        public var altitude: Double? {
          get {
            return snapshot["altitude"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "altitude")
          }
        }

        public var timestamp: String {
          get {
            return snapshot["timestamp"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var workoutSessionLocationsId: GraphQLID? {
          get {
            return snapshot["workoutSessionLocationsId"] as? GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "workoutSessionLocationsId")
          }
        }
      }
    }
  }
}

public final class LocationsBySessionQuery: GraphQLQuery {
  public static let operationString =
    "query LocationsBySession($sessionId: ID!, $sortDirection: ModelSortDirection, $filter: ModelLocationDataFilterInput, $limit: Int, $nextToken: String) {\n  locationsBySession(\n    sessionId: $sessionId\n    sortDirection: $sortDirection\n    filter: $filter\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      sessionId\n      latitude\n      longitude\n      altitude\n      timestamp\n      createdAt\n      updatedAt\n      workoutSessionLocationsId\n    }\n    nextToken\n  }\n}"

  public var sessionId: GraphQLID
  public var sortDirection: ModelSortDirection?
  public var filter: ModelLocationDataFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(sessionId: GraphQLID, sortDirection: ModelSortDirection? = nil, filter: ModelLocationDataFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.sessionId = sessionId
    self.sortDirection = sortDirection
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["sessionId": sessionId, "sortDirection": sortDirection, "filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("locationsBySession", arguments: ["sessionId": GraphQLVariable("sessionId"), "sortDirection": GraphQLVariable("sortDirection"), "filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(LocationsBySession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(locationsBySession: LocationsBySession? = nil) {
      self.init(snapshot: ["__typename": "Query", "locationsBySession": locationsBySession.flatMap { $0.snapshot }])
    }

    public var locationsBySession: LocationsBySession? {
      get {
        return (snapshot["locationsBySession"] as? Snapshot).flatMap { LocationsBySession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "locationsBySession")
      }
    }

    public struct LocationsBySession: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelLocationDataConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelLocationDataConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["LocationData"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("sessionId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
          GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
          GraphQLField("altitude", type: .scalar(Double.self)),
          GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("workoutSessionLocationsId", type: .scalar(GraphQLID.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, createdAt: String, updatedAt: String, workoutSessionLocationsId: GraphQLID? = nil) {
          self.init(snapshot: ["__typename": "LocationData", "id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var sessionId: GraphQLID {
          get {
            return snapshot["sessionId"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "sessionId")
          }
        }

        public var latitude: Double {
          get {
            return snapshot["latitude"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "latitude")
          }
        }

        public var longitude: Double {
          get {
            return snapshot["longitude"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "longitude")
          }
        }

        public var altitude: Double? {
          get {
            return snapshot["altitude"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "altitude")
          }
        }

        public var timestamp: String {
          get {
            return snapshot["timestamp"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var workoutSessionLocationsId: GraphQLID? {
          get {
            return snapshot["workoutSessionLocationsId"] as? GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "workoutSessionLocationsId")
          }
        }
      }
    }
  }
}

public final class OnCreateWorkoutSessionSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateWorkoutSession($filter: ModelSubscriptionWorkoutSessionFilterInput) {\n  onCreateWorkoutSession(filter: $filter) {\n    __typename\n    id\n    userId\n    startTime\n    endTime\n    distance\n    duration\n    locations {\n      __typename\n      nextToken\n    }\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionWorkoutSessionFilterInput?

  public init(filter: ModelSubscriptionWorkoutSessionFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateWorkoutSession", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnCreateWorkoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateWorkoutSession: OnCreateWorkoutSession? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateWorkoutSession": onCreateWorkoutSession.flatMap { $0.snapshot }])
    }

    public var onCreateWorkoutSession: OnCreateWorkoutSession? {
      get {
        return (snapshot["onCreateWorkoutSession"] as? Snapshot).flatMap { OnCreateWorkoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateWorkoutSession")
      }
    }

    public struct OnCreateWorkoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["WorkoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
        GraphQLField("endTime", type: .scalar(String.self)),
        GraphQLField("distance", type: .scalar(Double.self)),
        GraphQLField("duration", type: .scalar(Int.self)),
        GraphQLField("locations", type: .object(Location.selections)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, userId: GraphQLID, startTime: String, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil, locations: Location? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "WorkoutSession", "id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "locations": locations.flatMap { $0.snapshot }, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userId")
        }
      }

      public var startTime: String {
        get {
          return snapshot["startTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startTime")
        }
      }

      public var endTime: String? {
        get {
          return snapshot["endTime"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endTime")
        }
      }

      public var distance: Double? {
        get {
          return snapshot["distance"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "distance")
        }
      }

      public var duration: Int? {
        get {
          return snapshot["duration"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var locations: Location? {
        get {
          return (snapshot["locations"] as? Snapshot).flatMap { Location(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "locations")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLocationDataConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLocationDataConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class OnUpdateWorkoutSessionSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateWorkoutSession($filter: ModelSubscriptionWorkoutSessionFilterInput) {\n  onUpdateWorkoutSession(filter: $filter) {\n    __typename\n    id\n    userId\n    startTime\n    endTime\n    distance\n    duration\n    locations {\n      __typename\n      nextToken\n    }\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionWorkoutSessionFilterInput?

  public init(filter: ModelSubscriptionWorkoutSessionFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateWorkoutSession", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnUpdateWorkoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateWorkoutSession: OnUpdateWorkoutSession? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateWorkoutSession": onUpdateWorkoutSession.flatMap { $0.snapshot }])
    }

    public var onUpdateWorkoutSession: OnUpdateWorkoutSession? {
      get {
        return (snapshot["onUpdateWorkoutSession"] as? Snapshot).flatMap { OnUpdateWorkoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateWorkoutSession")
      }
    }

    public struct OnUpdateWorkoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["WorkoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
        GraphQLField("endTime", type: .scalar(String.self)),
        GraphQLField("distance", type: .scalar(Double.self)),
        GraphQLField("duration", type: .scalar(Int.self)),
        GraphQLField("locations", type: .object(Location.selections)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, userId: GraphQLID, startTime: String, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil, locations: Location? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "WorkoutSession", "id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "locations": locations.flatMap { $0.snapshot }, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userId")
        }
      }

      public var startTime: String {
        get {
          return snapshot["startTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startTime")
        }
      }

      public var endTime: String? {
        get {
          return snapshot["endTime"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endTime")
        }
      }

      public var distance: Double? {
        get {
          return snapshot["distance"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "distance")
        }
      }

      public var duration: Int? {
        get {
          return snapshot["duration"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var locations: Location? {
        get {
          return (snapshot["locations"] as? Snapshot).flatMap { Location(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "locations")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLocationDataConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLocationDataConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class OnDeleteWorkoutSessionSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteWorkoutSession($filter: ModelSubscriptionWorkoutSessionFilterInput) {\n  onDeleteWorkoutSession(filter: $filter) {\n    __typename\n    id\n    userId\n    startTime\n    endTime\n    distance\n    duration\n    locations {\n      __typename\n      nextToken\n    }\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionWorkoutSessionFilterInput?

  public init(filter: ModelSubscriptionWorkoutSessionFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteWorkoutSession", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnDeleteWorkoutSession.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteWorkoutSession: OnDeleteWorkoutSession? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteWorkoutSession": onDeleteWorkoutSession.flatMap { $0.snapshot }])
    }

    public var onDeleteWorkoutSession: OnDeleteWorkoutSession? {
      get {
        return (snapshot["onDeleteWorkoutSession"] as? Snapshot).flatMap { OnDeleteWorkoutSession(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteWorkoutSession")
      }
    }

    public struct OnDeleteWorkoutSession: GraphQLSelectionSet {
      public static let possibleTypes = ["WorkoutSession"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
        GraphQLField("endTime", type: .scalar(String.self)),
        GraphQLField("distance", type: .scalar(Double.self)),
        GraphQLField("duration", type: .scalar(Int.self)),
        GraphQLField("locations", type: .object(Location.selections)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, userId: GraphQLID, startTime: String, endTime: String? = nil, distance: Double? = nil, duration: Int? = nil, locations: Location? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "WorkoutSession", "id": id, "userId": userId, "startTime": startTime, "endTime": endTime, "distance": distance, "duration": duration, "locations": locations.flatMap { $0.snapshot }, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var userId: GraphQLID {
        get {
          return snapshot["userId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userId")
        }
      }

      public var startTime: String {
        get {
          return snapshot["startTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startTime")
        }
      }

      public var endTime: String? {
        get {
          return snapshot["endTime"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endTime")
        }
      }

      public var distance: Double? {
        get {
          return snapshot["distance"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "distance")
        }
      }

      public var duration: Int? {
        get {
          return snapshot["duration"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "duration")
        }
      }

      public var locations: Location? {
        get {
          return (snapshot["locations"] as? Snapshot).flatMap { Location(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "locations")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Location: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLocationDataConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLocationDataConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class OnCreateLocationDataSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateLocationData($filter: ModelSubscriptionLocationDataFilterInput) {\n  onCreateLocationData(filter: $filter) {\n    __typename\n    id\n    sessionId\n    latitude\n    longitude\n    altitude\n    timestamp\n    createdAt\n    updatedAt\n    workoutSessionLocationsId\n  }\n}"

  public var filter: ModelSubscriptionLocationDataFilterInput?

  public init(filter: ModelSubscriptionLocationDataFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateLocationData", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnCreateLocationDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateLocationData: OnCreateLocationDatum? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateLocationData": onCreateLocationData.flatMap { $0.snapshot }])
    }

    public var onCreateLocationData: OnCreateLocationDatum? {
      get {
        return (snapshot["onCreateLocationData"] as? Snapshot).flatMap { OnCreateLocationDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateLocationData")
      }
    }

    public struct OnCreateLocationDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["LocationData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sessionId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("workoutSessionLocationsId", type: .scalar(GraphQLID.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, createdAt: String, updatedAt: String, workoutSessionLocationsId: GraphQLID? = nil) {
        self.init(snapshot: ["__typename": "LocationData", "id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var sessionId: GraphQLID {
        get {
          return snapshot["sessionId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "sessionId")
        }
      }

      public var latitude: Double {
        get {
          return snapshot["latitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "latitude")
        }
      }

      public var longitude: Double {
        get {
          return snapshot["longitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "longitude")
        }
      }

      public var altitude: Double? {
        get {
          return snapshot["altitude"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "altitude")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var workoutSessionLocationsId: GraphQLID? {
        get {
          return snapshot["workoutSessionLocationsId"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "workoutSessionLocationsId")
        }
      }
    }
  }
}

public final class OnUpdateLocationDataSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateLocationData($filter: ModelSubscriptionLocationDataFilterInput) {\n  onUpdateLocationData(filter: $filter) {\n    __typename\n    id\n    sessionId\n    latitude\n    longitude\n    altitude\n    timestamp\n    createdAt\n    updatedAt\n    workoutSessionLocationsId\n  }\n}"

  public var filter: ModelSubscriptionLocationDataFilterInput?

  public init(filter: ModelSubscriptionLocationDataFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateLocationData", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnUpdateLocationDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateLocationData: OnUpdateLocationDatum? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateLocationData": onUpdateLocationData.flatMap { $0.snapshot }])
    }

    public var onUpdateLocationData: OnUpdateLocationDatum? {
      get {
        return (snapshot["onUpdateLocationData"] as? Snapshot).flatMap { OnUpdateLocationDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateLocationData")
      }
    }

    public struct OnUpdateLocationDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["LocationData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sessionId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("workoutSessionLocationsId", type: .scalar(GraphQLID.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, createdAt: String, updatedAt: String, workoutSessionLocationsId: GraphQLID? = nil) {
        self.init(snapshot: ["__typename": "LocationData", "id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var sessionId: GraphQLID {
        get {
          return snapshot["sessionId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "sessionId")
        }
      }

      public var latitude: Double {
        get {
          return snapshot["latitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "latitude")
        }
      }

      public var longitude: Double {
        get {
          return snapshot["longitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "longitude")
        }
      }

      public var altitude: Double? {
        get {
          return snapshot["altitude"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "altitude")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var workoutSessionLocationsId: GraphQLID? {
        get {
          return snapshot["workoutSessionLocationsId"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "workoutSessionLocationsId")
        }
      }
    }
  }
}

public final class OnDeleteLocationDataSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteLocationData($filter: ModelSubscriptionLocationDataFilterInput) {\n  onDeleteLocationData(filter: $filter) {\n    __typename\n    id\n    sessionId\n    latitude\n    longitude\n    altitude\n    timestamp\n    createdAt\n    updatedAt\n    workoutSessionLocationsId\n  }\n}"

  public var filter: ModelSubscriptionLocationDataFilterInput?

  public init(filter: ModelSubscriptionLocationDataFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteLocationData", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnDeleteLocationDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteLocationData: OnDeleteLocationDatum? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteLocationData": onDeleteLocationData.flatMap { $0.snapshot }])
    }

    public var onDeleteLocationData: OnDeleteLocationDatum? {
      get {
        return (snapshot["onDeleteLocationData"] as? Snapshot).flatMap { OnDeleteLocationDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteLocationData")
      }
    }

    public struct OnDeleteLocationDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["LocationData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("sessionId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
        GraphQLField("altitude", type: .scalar(Double.self)),
        GraphQLField("timestamp", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("workoutSessionLocationsId", type: .scalar(GraphQLID.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, sessionId: GraphQLID, latitude: Double, longitude: Double, altitude: Double? = nil, timestamp: String, createdAt: String, updatedAt: String, workoutSessionLocationsId: GraphQLID? = nil) {
        self.init(snapshot: ["__typename": "LocationData", "id": id, "sessionId": sessionId, "latitude": latitude, "longitude": longitude, "altitude": altitude, "timestamp": timestamp, "createdAt": createdAt, "updatedAt": updatedAt, "workoutSessionLocationsId": workoutSessionLocationsId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var sessionId: GraphQLID {
        get {
          return snapshot["sessionId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "sessionId")
        }
      }

      public var latitude: Double {
        get {
          return snapshot["latitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "latitude")
        }
      }

      public var longitude: Double {
        get {
          return snapshot["longitude"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "longitude")
        }
      }

      public var altitude: Double? {
        get {
          return snapshot["altitude"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "altitude")
        }
      }

      public var timestamp: String {
        get {
          return snapshot["timestamp"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public var workoutSessionLocationsId: GraphQLID? {
        get {
          return snapshot["workoutSessionLocationsId"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "workoutSessionLocationsId")
        }
      }
    }
  }
}