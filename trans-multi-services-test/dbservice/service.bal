import ballerina/http;
import ballerinax/mysql.driver as _; // Importing the MySQL driver.
import ballerinax/mysql; // Importing the MySQL module.
import ballerina/sql; // Importing the SQL module.
import ballerina/io;



# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {
    private final mysql:Client db;
    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        string USER = "root";
        string PASSWORD = "root";
        string HOST = "localhost";
        int PORT = 3306;
        string DATABASE = "test2";
        self.db = check new (HOST, USER, PASSWORD, DATABASE, PORT,  options = {useXADatasource: true});
    }
    transactional resource function get dbupdate(int num, string name, string size) returns string|error {
        // Execute simple query to insert a new record to the `product_test` table.
        sql:ExecutionResult result = check self.db->execute(`INSERT INTO figurines (id, name, size) VALUES (${num}, ${name}, ${size})`);
        io:println(result);
        // Process the result and return a string or error.
        return result.toString();
        
    }
}
