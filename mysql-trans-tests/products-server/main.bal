// import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/sql;

public type Product record {
    int id?;
    string name;
    string price;};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new(
    host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE
);

isolated function addProduct(Product prod) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO product_test VALUES (${prod.id}, ${prod.name}, ${prod.price})`);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

isolated function getProduct(int id) returns Product|error {
    Product product = check dbClient->queryRow(`SELECT * FROM product_test WHERE id = ${id}`);
    return product;
}

isolated function getAllProducts() returns Product[]|error {
    Product[] prods = [];
    stream<Product, error?> resultStream = dbClient->query(
        `SELECT * FROM product_test`
    );
    check from Product prod in resultStream
        do {
            prods.push(prod);
        };
    check resultStream.close();
    return prods;
}

isolated function updateProduct(Product prod) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`UPDATE product_test SET product = ${prod.name}, price = ${prod.price} WHERE id = ${prod.id};`);
    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Unable to obtain last insert ID");
    }
}

isolated function removeProduct(int id) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`DELETE FROM product_test WHERE id = ${id};`);
    int? affectedRowCount = result.affectedRowCount;
    if affectedRowCount is int {
        return affectedRowCount;
    } else {
        return error("Unable to obtain the affected row count");
    }
}