import ballerinax/mysql.driver as _; // Importing the MySQL driver.
import ballerinax/mysql; // Importing the MySQL module.
import ballerina/sql; // Importing the SQL module.
import ballerina/io;

// Configuring the MySQL client.
string USER = "root";
string PASSWORD = "root";
string HOST = "localhost";
int PORT = 3306;

final mysql:Client dbClient1 = check new (
        host="localhost", user="root", password="root", port=3306, database="test1", options = {useXADatasource: true}
    );

// final mysql:Client dbClient2 = check new (
//         host="localhost", user="root", password="root", port=3306, database="test2", options = {useXADatasource: true}
//     );

public function main() returns error? {
    transaction {
        sql:ParameterizedQuery query1 = `UPDATE product_test SET price =300.00 WHERE id = 1`;    
        sql:ParameterizedQuery query2 = `UPDATE product_test SET price = 2300.00 WHERE id = 2`;
        boolean trans = transactional;
        io:println(trans);
        _ = check dbClient1->execute(query1);
        _ = check dbClient1->execute(query2);

        check commit;
    }
}