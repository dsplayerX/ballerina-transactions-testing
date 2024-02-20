import ballerina/io;
import ballerina/sql;
// import ballerinax/java.jdbc;
import ballerinax/postgresql;
// import ballerinax/postgresql.driver as _;

postgresql:Options pgoptions = {
    preparedStatementCacheSize: 4000
};

public function main() returns error? {

    // jdbc:Client dbClient1 = check new ("jdbc:postgresql://localhost:5432/test", "postgres", "root123");

    // Create a client to the PostgreSQL database
    postgresql:Client dbClient1 = check new (username = "postgres", password = "root123",
        database = "test", options = pgoptions   
    );
    io:println("Client created successfully!");

    transaction {

        sql:ExecutionResult result1 = check dbClient1->execute(`INSERT INTO public.stock(amount)
    VALUES (69)`);
        io:println("Number of records inserted: ", result1.affectedRowCount);

        //     sql:ExecutionResult result = check dbClient1->execute(`INSERT INTO public.stock( id,
        // amount)
        // VALUES (1, 200)`);
        //     io:println("Number of records inserted: ", result.affectedRowCount);

        check commit;
    }
}

// import ballerina/http;
// import ballerinax/mysql;
// import ballerinax/mysql.driver as _;

// service / on new http:Listener(9896) {
//     final mysql:Client testDB;
//     function init() returns error? {
//         self.testDB = check new (host = "localhost", user = "root", password = "root", port = 3306, database = "test", options = {useXADatasource: true});
//     }

//     transactional resource function get hola(http:Caller caller, string name) {
//         http:Response res = new;
//         res.setTextPayload("Hola, " + name + "!");
//         checkpanic caller->respond(res);
//     }
// }

