# FeatherSQLMySQL

MySQL dialect for [FeatherSQL](https://github.com/feather-framework/feather-sql).
It provides MySQL-specific SQL syntax and serialization; it does not include a
database connection or query execution layer.

[![Release: 1.0.0-alpha.2](https://img.shields.io/badge/Release-1.0.0--alpha.2-F05138)](https://github.com/feather-framework/feather-sql-mysql/releases/tag/1.0.0-alpha.2)
![Swift 6.3+](https://img.shields.io/badge/Swift-6.3%2B-F05138)

## Requirements

- Swift 6.3 or later
- macOS 15+, iOS 18+, tvOS 18+, watchOS 11+, or visionOS 2+
- Linux

## Installation

Add FeatherSQL and its MySQL dialect to your package:

```swift
.package(url: "https://github.com/feather-framework/feather-sql", exact: "1.0.0-alpha.1"),
.package(url: "https://github.com/feather-framework/feather-sql-mysql", exact: "1.0.0-alpha.2"),
```

```swift
.product(name: "FeatherSQL", package: "feather-sql"),
.product(name: "FeatherSQLMySQL", package: "feather-sql-mysql"),
```

This is an alpha release; APIs may change before the stable `1.0.0` release.

## Usage

Select the MySQL builder to generate SQL using MySQL syntax:

```swift
import FeatherSQL
import FeatherSQLMySQL

let statement = SQLBuilder.mysql
    .select()
    .column("id")
    .column("email")
    .from("users")
    .build()

print(statement.sql)
```

FeatherSQLMySQL only generates SQL. Use a database adapter to execute it.

## Origins and attribution

FeatherSQLMySQL is a fork and adaptation of the MySQL dialect code from Vapor's
[MySQLKit](https://github.com/vapor/mysql-kit) and
[SQLKit](https://github.com/vapor/sql-kit), ported to use FeatherSQL and
excluding connection and execution layers. It is not an official Vapor
project or release. Upstream copyright and license notices are retained in
[LICENSES.md](LICENSES.md).
FeatherSQLMySQL's own work is copyright Binary Birds Kft. and is distributed
under the MIT License in [LICENSE](LICENSE).
