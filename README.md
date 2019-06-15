# HTTPLayer
A boilerplate HTTP Layer framework created by me using Swift 5

## How to use:

Create a class, that conforms to Decodable protocol:
```
class Example: Decodable {
    var stringVariable: String
    var intVariable: Int
    var doubleArrayVariable: [Double]
}
```

Use CodingKeys enumeration if the names of the variables do not match with the corresponding names in response's JSON:
```
class Example: Decodable {
    var stringVariable: String
    var intVariable: Int
    var doubleArrayVariable: [Double]

    private enum CodingKeys: String, CodingKey {
        case stringVariable = "otherStringName"
        case intVariable = "otherIntName"
        case doubleArrayVariable = "otherDoubleArrayName"
    }
}
```

Then in your API-management class you can recieve data using this kind of request:
```
func loadExample(completion: @escaping ((Result<Example, Error>) -> ())) {
    HTTPLayer.shared.get(url: "https://your-url.com") { (result: Result<Example, Error>) in
        completion(result)
    }
}
```

You are also welcome to specify your query parameters of type `[String: Any]`:
```
func loadExample(queryParams: [String: Any], completion: @escaping ((Result<Example, Error>) -> ())) {
    HTTPLayer.shared.get(url: "https://your-url.com", queryParams: queryParams) { (result: Result<Example, Error>) in
        completion(result)
    }
}
```
