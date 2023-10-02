import ballerina/http;
// import ballerina/io;

import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/sql;

// Configuring the MySQL client.
configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;


type Product record {
    int id;
    string product;
    string price;
};


# A service representing a network-accessible API
# bound to port `9090`.
# //CORS configuration
@http:ServiceConfig {
    cors: {
        allowOrigins: ["0.0.0.0"], // Allowed origins
        allowMethods: ["OPTIONS", "GET", "POST" ,"DELETE"], // Allowed methods
        allowHeaders: ["Origin", "Content-Type", "Accept"], // Allowed headers
        allowCredentials: false // Allow credentials (cookies, authorization headers), if needed
    }
}
service / on new http:Listener(9090) {
    private final mysql:Client db;

    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.db = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    }

    resource function get get_all_products() returns Product[]|error {
        // Execute simple query to retrieve all records from the `product_test` table.
        stream<Product, sql:Error?> prodStream = self.db->query(`SELECT * FROM product_test`);

        // Process the stream and convert results to Products[] or return error.
        return from Product product in prodStream
            select product;
    }

    resource function get get_product/[int id]() returns Product|http:NotFound|error {
        // Execute simple query to fetch record with requested id.
        Product|sql:Error result = self.db->queryRow(`SELECT * FROM product_test WHERE id = ${id}`);

        // Check if record is available or not
        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        } else {
            return result;
        }
    }

    resource function get add_new_product(int prod_id, string prod_name, string prod_price) returns string|error {
        // Execute simple query to insert a new record to the `product_test` table.
        sql:ExecutionResult result = check self.db->execute(`INSERT INTO product_test VALUES (${prod_id}, ${prod_name}, ${prod_price})`);

        // Process the result and return a string or error.
        return result.toString();
        
    }

    resource function get update_product/[int id](string prod_name, string prod_price) returns string|error {
        // Execute simple query to insert a new record to the `product_test` table.
        sql:ExecutionResult result = check self.db->execute(`UPDATE product_test SET product = ${prod_name}, price = ${prod_price} WHERE id = ${id};`);

        // Process the result and return a string or error.
        return result.toString();
        
    }

    resource function get delete_product/[int id]() returns string|error {
        // Execute simple query to insert a new record to the `product_test` table.
        sql:ExecutionResult result = check self.db->execute(`DELETE FROM product_test WHERE id = ${id};`);

        // Process the result and return a string or error.
        return result.toString();
        
    }

    resource function get replace_product/[int id](string prod_name, string prod_price) returns string|error? {
        // Execute simple query to insert a new record to the `product_test` table.
        transaction {
            _ = check self.db->execute(`DELETE FROM product_test WHERE id = ${id};`);
            _ = check self.db->execute(`INSERT INTO product_test VALUES (${id}, ${prod_name}, ${prod_price})`);
            check commit;
        }
        
    }
}
