import ballerina/http;
// import ballerina/log;
import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/io;
import ballerina/sql;


// Configuring the MySQL client.
configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    private final mysql:Client db;

    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.db = check new (HOST, USER, PASSWORD, DATABASE, PORT);
    }

    // resource function get transferfunds(string toaccount, string fromaccount, int amount) returns boolean {
    //     // Withdraw funds from the account
    //     // Return true if successful, false if not
    //     var e1 = check self.db->execute(`INSERT INTO product_test VALUES (${id}, ${prod_name}, ${prod_price})`);
    //     var e2 = check self.db->execute(`INSERT INTO product_test VALUES (${id}, ${prod_name}, ${prod_price})`);

    // }

    transactional resource function get withdraw(string account, int amount) returns boolean {
        // Withdraw funds from the account
        // Return true if successful, false if not
        sql:ExecutionResult|sql:Error e = self.db->execute(`UPDATE account SET balance = balance - ${amount} WHERE owner = ${account}`);
        if e is sql:Error {
            io:println("Error occurred while updating the account balance" + e.message());
            return false;
        }
        return true;

    }

    transactional resource function get deposit(string account, int amount) returns boolean {
        // Deposit funds into the account
        // Return true if successful, false if not
        sql:ExecutionResult|sql:Error e = self.db->execute(`UPDATE account SET balance = balance + ${amount} WHERE owner = ${account}`);
        if e is sql:Error {
            io:println("Error occurred while updating the account balance" + e.message());
            return false;
        }
        return true;
    }
}
