import ballerina/io;
import ballerinax/mysql.driver as _; // Importing the MySQL driver.
import ballerinax/mysql; // Importing the MySQL module.
import ballerina/sql; // Importing the SQL module.

// Configuring the MySQL client.
configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

// Creating a record type to store the data retrieved from the database.
type Product record {
    int id;
    string product;
    string price;
};

final mysql:Client dbClient = check new (
        host=HOST, user=USER, password=PASSWORD, port=3306, database=DATABASE
    );

public function main() returns error? {
    string str = "";
    transaction {
        str += "transaction started";
        check doStage1();
        check doStage2();
        var commitResult = commit;
        if commitResult is () {
            str += " -> transaction committed";
        } else {
            str += " -> transaction failed";
        }
        str += " -> transaction ended.";
    }

    io:println(str);    

    // =============
    // >> Retrieve Data From Table
    // =============
    // sql:ParameterizedQuery query1 = `SELECT * FROM product_test`; // Query to retrieve data from the table.
    // stream<Product, sql:Error?> resultStream = dbClient->query(query1); // Retrieving data from the table.
    // io:println("Data retrieved successfully - " + resultStream.toString());

    // io:println("========= Products ==========");
    // // Iterating the returned table.
    // check from Product product in resultStream
    //     do {
    //         io:println(product.toString()); 
    //     };
    // return;
}

transactional function doStage1() returns error? {
    // =============
    // >> Update Data
    // =============
    sql:ParameterizedQuery query2 =`UPDATE product_test SET price = '69.99' WHERE id = 001`; // Query to update data in the table.
    sql:ExecutionResult result2 = check dbClient->execute(query2); // Updating data in the table.
    io:println("Data updated successfully. - " + result2.toString()); 

    io:println("Stage1 completed");
}

transactional function doStage2() returns error?{
    // =============
    // >> Insert Data
    // =============
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO product_test (id, product, price)
        VALUES (25, "Test Figurine", 29.99)
    `); // Inserting data into the table.

    // io:println( result.toString());
    io:println("Data inserted successfully - " + result.toString());
    io:println("Stage2 completed");
}
