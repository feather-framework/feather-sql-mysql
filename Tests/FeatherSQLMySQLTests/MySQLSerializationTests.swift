// Serialization scenarios adapted from Vapor SQLKit and MySQLKit tests.
import FeatherSQL
import FeatherSQLMySQL
import Testing

@Suite("SQLKit-derived MySQL serialization")
struct MySQLSerializationTests {

    @Test("serializes identifiers and positional bindings")
    func selectWithBoundValue() {
        let result = SQLBuilder.mysql
            .select()
            .column("id")
            .column("display_name")
            .from("items")
            .where("display_name", .equal, SQLBind("Feather"))
            .build()

        #expect(
            result.sql
                == "SELECT `id`, `display_name` FROM `items` WHERE `display_name` = ?"
        )
        #expect(result.bindings.count == 1)
        #expect(result.bindings.first as? String == "Feather")
    }

    // SQL generation scenarios adapted from Vapor MySQLKit's query tests.
    @Test("serializes MySQL-specific schema, upsert, and JSON expressions")
    func mysqlSpecificExpressions() throws {
        let table = SQLBuilder.mysql
            .create(table: "items")
            .column("id", type: .int, .primaryKey(autoIncrement: true))
            .column("payload", type: .custom(SQLRaw("JSON")))
            .build()

        #expect(
            table.sql
                == "CREATE TABLE `items` (`id` INTEGER PRIMARY KEY AUTO_INCREMENT, `payload` JSON)"
        )

        let insert = SQLBuilder.mysql
            .insert(into: "items")
            .columns("id", "payload")
            .values(SQLLiteral.default, SQLBind("{}"))
            .ignoringConflicts()
            .build()

        #expect(
            insert.sql
                == "INSERT IGNORE INTO `items` (`id`, `payload`) VALUES (DEFAULT, ?)"
        )
        #expect(insert.bindings.first as? String == "{}")

        let jsonPath = SQLBuilder.mysql.build(
            SQLNestedSubpathExpression(
                column: "payload",
                path: ["member", "name"]
            )
        )
        #expect(
            jsonPath.sql
                == "json_unquote(json_extract(`payload`, '$.member.name'))"
        )
    }

    @Test("covers MySQL dialect features and fallback paths")
    func dialectFeaturesAndFallbacks() throws {
        let dialect = MySQLDialect()

        #expect(dialect.name == "mysql")
        #expect(SQLBuilder.mysql.build(dialect.identifierQuote).sql == "`")
        #expect(SQLBuilder.mysql.build(dialect.literalStringQuote).sql == "'")
        #expect(
            SQLBuilder.mysql.build(dialect.bindPlaceholder(at: 42)).sql == "?"
        )
        #expect(SQLBuilder.mysql.build(dialect.literalBoolean(true)).sql == "1")
        #expect(
            SQLBuilder.mysql.build(dialect.literalBoolean(false)).sql == "0"
        )
        #expect(dialect.supportsAutoIncrement)
        #expect(
            SQLBuilder.mysql.build(dialect.autoIncrementClause).sql
                == "AUTO_INCREMENT"
        )
        #expect(dialect.enumSyntax == .inline)
        #expect(
            SQLBuilder.mysql
                .build(dialect.alterTableSyntax.alterColumnDefinitionClause!)
                .sql == "MODIFY COLUMN"
        )
        #expect(
            dialect.alterTableSyntax.alterColumnDefinitionTypeKeyword == nil
        )
        #expect(dialect.triggerSyntax.create.contains(.supportsBody))
        #expect(dialect.triggerSyntax.create.contains(.supportsOrder))
        #expect(dialect.upsertSyntax == .mysqlLike)
        #expect(dialect.unionFeatures.contains(.unionAll))
        #expect(
            SQLBuilder.mysql.build(dialect.sharedSelectLockExpression!).sql
                == "LOCK IN SHARE MODE"
        )
        #expect(
            SQLBuilder.mysql.build(dialect.exclusiveSelectLockExpression!).sql
                == "FOR UPDATE"
        )

        let textType = try #require(dialect.customDataType(for: .text))
        #expect(SQLBuilder.mysql.build(textType).sql == "VARCHAR(255)")
        #expect(dialect.customDataType(for: .int) == nil)

        let normalized = SQLBuilder.mysql.build(
            dialect.normalizeSQLConstraint(
                identifier: SQLIdentifier("items_owner_id_fkey")
            )
        )
        #expect(normalized.sql.count == 42)
        #expect(
            SQLBuilder.mysql
                .build(
                    dialect.normalizeSQLConstraint(
                        identifier: SQLRaw("raw_constraint")
                    )
                )
                .sql == "raw_constraint"
        )

        #expect(
            dialect.nestedSubpathExpression(
                in: SQLIdentifier("payload"),
                for: []
            ) == nil
        )
        let nestedPath = try #require(
            dialect.nestedSubpathExpression(
                in: SQLIdentifier("payload"),
                for: ["member"]
            )
        )
        #expect(
            SQLBuilder.mysql.build(nestedPath).sql
                == "json_unquote(json_extract(`payload`, '$.member'))"
        )
    }
}
