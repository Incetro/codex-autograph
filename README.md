codex-autograph
=====

If you decide to find something more convenient and visual for working with Codable, we suggest you use our Swift Codable API wrapper with methods based on type inference - [Codex](https://github.com/Incetro/Codex). 
For the most part, working with Codable involves writing object models for encrypting, decrypting, and converting data. Codex also does not exclude such work, codex-autograph will help you with this!
Routine writing of models often leads to errors that are not immediately noticeable and a waste of time on them, codex-autograph will eliminate these troubles by generating these models from your templates.

See more [Codex](https://github.com/Incetro/codex).

**Important!** We believe that it is better to use structures to create models of objects, so generation works only with them.

In order to generate object models, you just need to specify the desired annotation for the properties and specify the desired type Codable, Decodable or Encodable. Here is a complete list of the annotation arguments you need:


| Arguments|  Examples                |            Description                                                                            |
|----------|--------------------------|---------------------------------------------------------------------------------------------------|
| json     | @json                    | For object mapping, the name of your property is taken                                            |
|          | @json your_needed_name   | To map an object with the name you need                                                           |
| format   | @format seconds          | For converting unix time date in seconds                                                          |
|          | @format ms               | For converting unix time date in milliseconds                                                     |
|          | @format yyyy-MM-dd       | To convert to the type of format you need using DateFormatter                                     |
|          | @format yyyy-MM-dd#name  | Also for converting to the type of format you need using DateFormatter, but already with your name|
|          | @format iso              | If you want to use ISO8601Formatter to convert date                                               |



Let's imagine you have an entity struct:

```swift
// MARK: - UserPlainObject

struct UserPlainObject: Codable {

    // MARK: - Properties

    /// User's first name
    /// @json first_name
    let firstName: String

    /// User's last name
    /// @json last_name
    let lastName: String

    /// User's favorite book
    /// @json
    let favoriteBooks: [BookPlainObject]

    /// User's email
    /// @json
    let email: String?

    /// User's gender
    /// @json
    let gender: String

    /// User's phones
    /// @json
    let phones: [String]

    /// User's register date
    /// @json register_date
    /// @format seconds
    let registerDate: Date

    /// User's birthday
    /// @json 
    /// @format yyyy-MM-dd
    let birthday: Date
}
```

Generator will generate codable extension with decoding initializer, encoding function with unix date formatter instance in them and DateFormatter function:

```swift
// MARK: - Codable

extension UserPlainObject: Codable {

    // MARK: - Formatters

    static func makeBirthdayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    // MARK: - Decodable

    init(from decoder: Decoder) throws {
        let birthdayFormatter = UserPlainObject.makeBirthdayFormatter()
        let secondsTransformer = UnixTransformer(unit: .seconds)
        firstName = try decoder.decode("first_name")
        lastName = try decoder.decode("last_name")
        favoriteBooks = try decoder.decodeIfPresent("favoriteBooks")
        email = try decoder.decodeIfPresent("email")
        gender = try decoder.decode("gender")
        phones = try decoder.decodeIfPresent("phones")
        registerDate = try decoder.decode("register_date", transformedBy: secondsTransformer)
        birthday = try decoder.decode("birthday", using: birthdayFormatter)
    }

    // MARK: - Encodable

    func encode(to encoder: Encoder) throws {
        let secondsTransformer = UnixTransformer(unit: .seconds)
        let birthdayFormatter = UserPlainObject.makeBirthdayFormatter()
        try encoder.encode(firstName, for: "first_name")
        try encoder.encode(lastName, for: "last_name")
        try encoder.encode(favoriteBooks, for: "favoriteBooks")
        try encoder.encode(email, for: "email")
        try encoder.encode(gender, for: "gender")
        try encoder.encode(phones, for: "phones")
        try encoder.encode(registerDate, for: "register_date", transformedBy: secondsTransformer)
        try encoder.encode(birthday, for: "birthday", using: birthdayFormatter)
    }
}
```
If you use custom formats such as `@format yyyy-MM-dd`, generator will add a helper function to the extension for using a DateFormatter instance with the format you want.

Like this:

```swift
// MARK: - Formatters

static func makeBirthdayFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}
```

Or if you use custom name in the argument `@format yyyy-MM-dd#customName` it will look like this:

```swift
// MARK: - Formatters

static func makeCustomNameFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}
```

Of course, if you inherit Decodable or Encodable protocols you will only get decoding initializer or encoding function

#### Codax-autograph also helps in creating enum models, for example, for easy saving of user data.
To do this, you do not need to specify any special arguments, just specify the parameter `-enums` and the path to the folder with enums.
For example we have:

```swift
// MARK: - ExampleEnum

enum ExampleEnum: Codable {

    // MARK: - Cases

    case userName(String)
    case age(count: Int)
    case threeFavoriteColors(String, String, String)
    case someEmptyCase
}
```
The following extension will be generated from this example:

```swift
// MARK: - Codable

extension ExampleEnum: Codable {

    // MARK: - CodingKeys

    enum CodingKeys: CodingKey, CaseIterable {

        // MARK: - Cases

        case userName
        case age
        case threeFavoriteColors
        case someEmptyCase
    }

    // MARK: - Decodable

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        switch key {
        case .userName:
            self = .userName(try container.decode(String.self, forKey: .userName))
        case .age:
            self = .age(count: try container.decode(Int.self, forKey: .age))
        case .threeFavoriteColors:
            let (value1, value2): (String, String) = try container.decodeValues(for: .threeFavoriteColors)
            self = .threeFavoriteColors(value1, value2)
        case .someEmptyCase:
            self = .someEmptyCase
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }

    // MARK: - Encodable

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .userName(let userName):
            try container.encode(userName, forKey: .userName)
        case .age(let age):
            try container.encode(age, forKey: .age)
        case let .threeFavoriteColors( value1, value2):
            try container.encodeValues(value1, value2, for: .threeFavoriteColors)
        case .someEmptyCase:
            try container.encode("someEmptyCase", forKey: .someEmptyCase)
        }
    }
}

```

An auxiliary file will also be generated to handle multiple arguments in the case.
Example:

```swift
// MARK: - KeyedEncodingContainer

extension KeyedEncodingContainer {

    mutating func encodeValues<V1: Encodable, V2: Encodable>(
        _ v1: V1,
        _ v2: V2,
        for key: Key
    ) throws {
        var container = self.nestedUnkeyedContainer(forKey: key)
        try container.encode(v1)
        try container.encode(v2)
    }
 }
 
// MARK: - KeyedDecodingContainer

extension KeyedDecodingContainer {

    func decodeValues<V1: Decodable, V2: Decodable>(
        for key: Key
    ) throws -> (V1, V2) {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return (
            try container.decode(V1.self),
            try container.decode(V2.self)
        )
    }
 }
```
In the default case, this extension will generate methods for processing up to 5 variables. If you need to change the maximum number of variables, just specify the `-keyedContainerCount` `<required number>` parameter before generating

## Setup steps

**1. Add submodule to your project.**

`git@github.com:Incetro/codex-autograph`

**2. Init submodules in your project.**

```bash
git submodule init
git submodule update
```

**3. Run `spm_build.command` to build executable file.**

You should take it from `.build/release/codex-autograph` and place inside your project folder (for example in folder `Codegen`)

**4. Add run script phase in Xcode.**

It may look like this:

```bash
CODEX_AUTOGRAPH_PATH=Codegen/codex-autograph

if [ -f $CODEX_AUTOGRAPH_PATH ]
then
    echo "codex-autograph executable found"
else
    osascript -e 'tell app "Xcode" to display dialog "Codex generator executable not found in \nCodegen/codex-autograph" buttons {"OK"} with icon caution'
fi

$CODEX_AUTOGRAPH_PATH \
    -plains "$SRCROOT/$PROJECT_NAME/Models/Plains" \
    -enums "$SRCROOT/$PROJECT_NAME/Models/Enums" \
    -keyedContainerCount 6 \
    -project_name $PROJECT_NAME

```

Available arguments

| Parameter          | Description                                                                       | Example                                                      |
|--------------------|-----------------------------------------------------------------------------------|--------------------------------------------------------------|
| help               | Print help info                                                                   | `./codex-autograph -help`                                    |
| projectName        | Project name to be used in generated files                                        | `./codex-autograph -projectName yourName`                    |
| plains             | Path to the folder, where plain objects files to be processed are stored          | `./codex-autograph -plains "./Models/Plain"`                 |
| enums              | Path to the folder, where enum objects files to be processed are stroed           | `./codex-autograph -enums "./Models/Enums"`                  |
| keyedContainerCount| Need to specify the desired maximum count of variables in the keyed container extension| `./codex-autograph -keyedContainerCount 6`              |
| verbose            | Forces generator to print the whole process of generation                         | `./codex-autograph -verbose`                                 |

**5. Add generated files manually to your project.**

### Example project

You can see how it works in the exmaple folder `Sources/Sandbox`. Run `sandbox_run.command` and then there will be several options to test the generator:

1. You can add or remove some property from any current plain object and change the inherited protocol(s), press `Cmd B` – you'll see how it changes
2. Eventually, you can create a new plain object with your own properties and desired inheritance protocol(s), press `Cmd B` – your model will be created (but you should still add them manually to project)
