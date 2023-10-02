import ballerinax/mysql.driver as _; // Importing the MySQL driver.
import ballerinax/mysql; // Importing the MySQL module.
import ballerina/sql; // Importing the SQL module.
import ballerina/io;

final mysql:Client dbClient1 = check new (
        host="localhost", user="root", password="my-secret-pw", port=3308, database="temp1", options = {useXADatasource: true}
    );

final mysql:Client dbClient2 = check new (
        host="localhost", user="root", password="root", port=3306, database="test1", options = {useXADatasource: true}
    );

public function main() returns error? {
    transaction {
        sql:ParameterizedQuery query1 = `INSERT INTO persons (name) VALUES ('John Doe');`;    
        sql:ParameterizedQuery query2 = `UPDATE product_test SET price = 500.00 WHERE id = 2`;
        boolean trans = transactional;
        io:println(trans);
        _ = check dbClient1->execute(query1);
        _ = check dbClient2->execute(query2);

        check commit;
    }
}