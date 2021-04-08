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
    -project_name $PROJECT_NAME

```

Available arguments

| Parameter         | Description                                                                       | Example                                                      |
|-------------------|-----------------------------------------------------------------------------------|--------------------------------------------------------------|
| help              | Print help info                                                                   | `./codex-autograph -help`                                    |
| projectName       | Project name to be used in generated files                                        | `./codex-autograph -projectName yourName`                    |
| plains            | Path to the folder, where plain objects files to be processed are stored          | `./codex-autograph -plains "./Models/Plain"`                 |
| verbose           | Forces generator to print the whole process of generation                         | `./codex-autograph -verbose`                                 |

**5. Add generated files manually to your project.**

### Example project

You can see how it works in the exmaple folder `Sources/Sandbox`. Run `sandbox_run.command` and then there will be several options to test the generator:

1. You can add or remove some property from any current plain object and change the inherited protocol(s), press `Cmd B` – you'll see how it changes
2. Eventually, you can create a new plain object with your own properties and desired inheritance protocol(s), press `Cmd B` – your model will be created (but you should still add them manually to project)
