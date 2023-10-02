import ballerina/io;
import ballerina/http;

public function main() returns error? {
    transaction {
        _ = check dbservcall();
        _ = check msgservcall();
        io:println("Commiting...");
        check commit;
    }
}

transactional function dbservcall() returns error? {
    http:Client clientEndpoint = check new("http://localhost:9090");
    http:Response response = check clientEndpoint->get("/dbupdate?num=70&name=Wayne&size=4");
    string resp = check response.getTextPayload();
    io:println(resp);
    if (response.statusCode == 200) {
        io:println("Database1 ready!");
    } else {
        io:println("Database1 failed!");
        return error("Database1 failed!");
    }
}

transactional function db2servcall() returns error? {
    http:Client clientEndpoint2 = check new("http://localhost:9097");   
    http:Response response2 = check clientEndpoint2->get("/addprod?prod_id=47&prod_name=Itachi&prod_price=14.99");
    string resp2 = check response2.getTextPayload();
    io:println(resp2);
    if (response2.statusCode == 200) {
        io:println("Database2 ready!");
    } else {
        io:println("Database2 failed!");
        return error("Database2 failed!");
    }
}

transactional function msgservcall() returns error? {
    http:Client clientEndpoint = check new("http://localhost:9092");
    http:Response response = check clientEndpoint->get("/sendmsg?msg=hellotransaction");
    io:println(response.statusCode);
    if (response.statusCode == 200) { 
        io:println("Message ready to send!");
        return ();
    } else {
        io:println("Message failed!");
        return error("Message failed!");
    }
}


